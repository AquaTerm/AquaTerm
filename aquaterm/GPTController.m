//
//  GPTController.m
//  AGPT3
//
//  Created by per on Sat Oct 06 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "GPTController.h"
#import "GPTWindowController.h"
#import "GPTReceiverObject.h"
#import "GPTView.h"
#import "AQTPrintView.h"

@implementation GPTController
    /**"
    *** GPTController is the main controller object which coordinates all the
    *** action and manages the DO connection object.
    "**/
    
-(id)init
{
    if (self =  [super init])
    {
        receiverObject = [[GPTReceiverObject alloc] initWithListener:self];
        gptWindowControllers = [[NSMutableArray arrayWithCapacity:0] retain];
    }
    return self;
}

    /**" 
    *** When the NIB file is loaded, the controller adds itself to 
    *** the list of observers for NSWindowDidBecomeMainNotification
    *** to keep track of the model to render when the user print.
    "**/
-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
        selector:@selector(mainWindowChanged:)
        name:NSWindowDidBecomeMainNotification
        object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    [receiverObject release];
    [gptWindowControllers release];
    [super dealloc];
}

-(void)setFrontWindow:(NSWindow *)mainWindow
{
    frontWindow = mainWindow;
}
    /**" 
    *** When the controller receives a model from the sender (e.g. gnuplot) 
    *** this method hands it over to the windowController corresponding to
    *** the current terminal (figure), indexed from zero and upwards.
    *** If a windowController for terminal <n> doesn't exist, it is created. 
    "**/
-(void)setModel:(AQTModel *)aqtModel forView:(unsigned)index
{
    GPTWindowController *theController;
    //
    // Get controller for view, create if neccessary
    //
    theController = [self controllerForView:index];
    if (theController == nil)
    {
        theController = [[GPTWindowController allocWithZone:[self zone]] initWithIndex:index];
        [gptWindowControllers addObject:theController];	// The windowController is added to the array, and thus retained
        [theController release];			// By releasing here, every windowController is released when the main nib is deallocated
    }
    [theController setModel:aqtModel];    		// Then hand the model over to the corresponding controller
    if (![[theController window] isVisible])
    {
        // The window was hidden (due to e.g. a close action)
        [[theController window] orderFront:self];
    } 
}
    /**" 
    *** Returns the windowController for terminal <n> or nil if
    *** it doesn't exist. 
    "**/
-(GPTWindowController *)controllerForView:(unsigned)index
{
    //
    // FIXME! should be a dictionary of some kind
    //
    GPTWindowController *gptWindowController;
    NSEnumerator *enumerator = [gptWindowControllers objectEnumerator];
    
    while ((gptWindowController = [enumerator nextObject]))
    {
       if ([gptWindowController viewIndex] == index)
       {
            return gptWindowController;
       }
    }
    return nil;
   
}

    /**" 
    *** Called when mainWindow is changed. Checks if the main window is 
    *** an AquaTerm window, and updates the frontWindow instance accordingly.
    "**/
-(void)mainWindowChanged:(NSNotification *)notification
{
    NSWindowController *controller = [[notification object] windowController];
    
    if([controller isKindOfClass:[GPTWindowController class]])
    {
        [self setFrontWindow:[notification object]];
    }
}

    /**" 
    *** Called when user selects print…. Runs a print operation with the model 
    *** corresponding to the main window.
    "**/
-(IBAction)print:(id)sender 
{
    AQTPrintView *printView;
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo]; // [self printInfo];
    NSSize paperSize = [printInfo paperSize];
    NSPrintOperation *printOp;
    
    paperSize.width -= ([printInfo leftMargin] + [printInfo rightMargin]);
    paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
    if ([printInfo orientation] == NSPortraitOrientation)
    {
      paperSize.height = (AQUA_YMAX * paperSize.width) / AQUA_XMAX;
    }
    else
    {
      paperSize.width = (AQUA_XMAX * paperSize.height) / AQUA_YMAX;
    }
    
    printView = [[AQTPrintView alloc] initWithFrame:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height) model:[[frontWindow windowController] model]];
    printOp = [NSPrintOperation printOperationWithView:printView];
    (void)[printOp runOperationModalForWindow:frontWindow delegate:nil didRunSelector:NULL contextInfo:NULL];
    [printView release];
}

- (IBAction)saveFigureAs:(id)sender
{
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  if (![NSBundle loadNibNamed:@"ExtendSavePanel" owner:self])  
  {
	NSLog(@"Failed to load ExtendSavePanel.nib");
  }
  [savePanel setAccessoryView:extendSavePanelView];
  [savePanel beginSheetForDirectory:NSHomeDirectory() /* FIXME: Should store and use latest dir used */
                               file:[frontWindow title] 
                     modalForWindow:frontWindow 
                      modalDelegate:self 
                     didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) 
                        contextInfo:saveFormatPopup
  ];
}

- (void)savePanelDidEnd:(NSSavePanel *)theSheet returnCode:(int)returnCode contextInfo:(NSPopUpButton *)formatPopUp
{
  NSData *data;
  NSString *filename;
  AQTPrintView *printView;
  
  if (NSFileHandlingPanelOKButton == returnCode)
  {
    printView = [[AQTPrintView alloc] initWithFrame:NSMakeRect(0.0, 0.0, AQUA_XMAX, AQUA_YMAX) model:[[frontWindow windowController] model]];
    filename = [[theSheet filename] stringByDeletingPathExtension];
    if ([[formatPopUp titleOfSelectedItem] isEqualToString:@"PDF"])
    {
      data = [printView dataWithPDFInsideRect: [printView bounds]];
      [data writeToFile: [filename stringByAppendingPathExtension:@"pdf"] atomically: NO];
    }
    else
    {
      data = [printView dataWithEPSInsideRect: [printView bounds]];     
      [data writeToFile: [filename stringByAppendingPathExtension:@"eps"] atomically: NO];
    }
    [printView release];
  }
}

- (IBAction)copy:(id)sender
{
  //
  // Copy figure to pasteboard as EPS (FIXME: format should be set in prefs)
  //
  AQTPrintView *printView = [[AQTPrintView alloc] initWithFrame:NSMakeRect(0.0, 0.0, AQUA_XMAX, AQUA_YMAX) model:[[frontWindow windowController] model]];
  NSData *data = [printView dataWithEPSInsideRect:[printView bounds]];
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  [pasteboard declareTypes:[NSArray arrayWithObjects:NSPDFPboardType, NSPostScriptPboardType, NSStringPboardType, nil] owner:nil];
  if (YES !=[pasteboard setData:data forType:NSStringPboardType])
    NSLog(@"write to pasteboard failed");
/* --- what's wrong with this?
  data = [printView dataWithEPSInsideRect: [printView bounds]];
  [printView writeEPSInsideRect:[printView bounds] toPasteboard:[NSPasteboard generalPasteboard]]; 
*/  
  [printView release];
}


-(IBAction)help:(id)sender
{
  NSString *helpURL = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
  if (helpURL)
  {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:helpURL]];
  }
}
@end
