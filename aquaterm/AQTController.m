//
//  AQTController.m
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 25 2003.
//  Copyright (c) 2003 Aquaterm. All rights reserved.
//

#import "AQTController.h"
#import "GPTWindowController.h"
#import "AQTView.h"
#import "AQTColorInspector.h"
#import "AQTClientHandler.h"
#import "AQTModel.h"
#import "AQTAdapter.h"

@implementation AQTController
/**"
*** AQTController is the main controller object which coordinates all the
*** action and manages the main DO connection.
"**/

-(id)init
{
  if (self =  [super init])
  {
//--->    builder = [[AQTBuilder alloc] init];
//    [builder setRenderer:self];
    gptWindowControllers = [[NSMutableArray arrayWithCapacity:16] retain];
  }
  return self;
}

/**"
*** When the NIB file is loaded, the controller vends an object of class AQTBuilder
*** via the distributed objects system and also adds itself to
*** the list of observers for NSWindowDidBecomeMainNotification
*** to keep track of the model to render when the user print.
*** The name of the DO connection registered is 'aquatermServer'.
"**/
-(void)awakeFromNib
{
   //
   // First of all, create a local client for testing purposes:
   //
   AQTAdapter *localClient;
   id h = [[AQTClientHandler alloc] init];
   clientList = [[[NSMutableArray alloc] initWithCapacity:16] retain];
   handlerList = [[[NSMutableArray alloc] initWithCapacity:16] retain];
   localClient = [[AQTAdapter alloc] initWithHandler:h]; 

   [clientList addObject:localClient];
   [h setOwner:self];
   [handlerList addObject:h];
   [h release];
   [localClient release];
   //
   // Next, set up a DO connection:
   //   
  doConnection = [[NSConnection defaultConnection] retain];
  [doConnection setIndependentConversationQueueing:YES];	// FAQ: Needed to sync calls!!!!
  [doConnection setRootObject:self];

  if([doConnection registerName:@"aquatermServer"] == NO)
  {
    NSLog(@"Error registering \"aquatermServer\" with defaultConnection");
  }
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowChanged:)
                                               name:NSWindowDidBecomeMainNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowResigned:)
                                               name:NSWindowDidResignMainNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowClosing:)
                                               name:NSWindowWillCloseNotification
                                             object:nil];
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self ];
  [clientList release];
  [handlerList release];
  [gptWindowControllers release];
  [super dealloc];
}
//
// Methods from AQTConnectionProtocol
//
-(id)addAQTClient:(id)aClient
{
  id h;
  if (!clientList)
  {
    clientList = [[[NSMutableArray alloc] initWithCapacity:16] retain];
    handlerList = [[[NSMutableArray alloc] initWithCapacity:16] retain];
  }
  if ([clientList containsObject:aClient])
  {
    h = [handlerList objectAtIndex:[clientList indexOfObject:aClient]];
  }
  else
  {
    NSLog(@"Adding client!");
    [clientList addObject:aClient];
    h = [[AQTClientHandler alloc] init];
    [h setOwner:self];
    [handlerList addObject:h];
    [h release];
  }
  return h;
}

-(BOOL)removeAQTClient:(id)aClient
{
  AQTClientHandler *tmpHandler;
  id tmpClient;
  unsigned index = [clientList indexOfObject:aClient];
  if (index == NSNotFound)
  {
    NSLog(@"Not found!");
    return NO;
  }
  else
  {
    NSLog(@"Removing client!");
    tmpHandler = [handlerList objectAtIndex:index];
    tmpClient = [clientList objectAtIndex:index];
    NSLog(@"handler rc: %d", [tmpHandler retainCount] );
    [handlerList removeObjectAtIndex:index];
    [clientList removeObject:aClient];
  }
  return YES;
}



-(void)setFrontWindow:(NSWindow *)mainWindow
{
  NSWindowController *controller = [mainWindow windowController];

  if (controller && [controller isKindOfClass:[GPTWindowController class]])
  {
    frontWindow = mainWindow;
    frontView = [[frontWindow windowController] viewOutlet];
  }
  else
  {
    frontWindow = nil;
    frontView = nil;
  }
}

-(NSWindow *)frontWindow
{
  return frontWindow;
}

-(AQTView *)frontView
{
  return frontView;
}

/**"
*** Called when mainWindow is changed. Checks if the main window is
*** an AquaTerm window, and updates the frontWindow instance accordingly.
"**/
-(void)mainWindowChanged:(NSNotification *)notification
{
  [self setFrontWindow:[notification object]];
}

-(void)mainWindowResigned:(NSNotification *)notification
{
  [self setFrontWindow:nil];
}

-(void)windowClosing:(NSNotification *)notification
{
  NSWindowController *controller = [[notification object] windowController];
  unsigned index;

  if(controller && [controller isKindOfClass:[GPTWindowController class]])
  {
    index = [gptWindowControllers indexOfObjectIdenticalTo:controller];
    if(index != NSNotFound)
    {
      [[controller retain] autorelease];	// From the docs it seems like _autorelease_ is required.
      [gptWindowControllers removeObjectAtIndex:index];
    }
  }
}

/**"
*** When the controller receives a model from the sender (e.g. gnuplot)
*** this method hands it over to the windowController corresponding to
*** the current terminal (figure), indexed from zero and upwards.
*** If a windowController for terminal <n> doesn't exist, it is created.
"**/
-(void)setModel:(AQTModel *)aqtModel forView:(int)index
{
  GPTWindowController *theController= [self controllerForView:index];
  //
  // Get controller for view, create if neccessary
  //
  if (theController == nil)
  {
    // FIXME: For now, the windowcontroller holds the index, that is unneccessary, see -controllerForView:
    theController = [[GPTWindowController allocWithZone:[self zone]] initWithIndex:index];
    [gptWindowControllers addObject:theController]; // The windowController is added to the array, and thus retained
    [theController release];					// By releasing here, every windowController is released when the main nib is deallocated
  }
  [theController setModel:aqtModel];
}

/**"
*** Returns the windowController for terminal <n> or nil if
*** it doesn't exist.
"**/
-(GPTWindowController *)controllerForView:(int)index
{
  //
  // FIXME! should be a dictionary of some kind => no need for wc to know its index
  //
  GPTWindowController *wc;
  NSEnumerator *enumerator = [gptWindowControllers objectEnumerator];
  while (wc = [enumerator nextObject])
  {
    if ([wc viewIndex] == index)
    {
      return wc;
    }
  }
  return (GPTWindowController *)nil;
}

- (void)printOperationDidRun:(NSPrintOperation *)printOperation success:(BOOL)success  contextInfo:(AQTView *)printView
{
  [printView setIsPrinting:NO];
}

/**"
*** Called when user selects print…. Runs a print operation with the model
*** corresponding to the main window.
"**/
-(IBAction)print:(id)sender
{
  AQTView *printView;
  AQTModel *currentModel = [frontView model];
  NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo]; // [self printInfo];
  NSSize paperSize = [printInfo paperSize];
  NSPrintOperation *printOp;

  if (!frontWindow)
  {
    return;
  }

  paperSize.width -= ([printInfo leftMargin] + [printInfo rightMargin]);
  paperSize.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
  if ([printInfo orientation] == NSPortraitOrientation)
  {
    paperSize.height = ([currentModel canvasSize].height * paperSize.width) / [currentModel canvasSize].width;
  }
  else
  {
    paperSize.width = ([currentModel canvasSize].width * paperSize.height) / [currentModel canvasSize].height;
  }

  printView = [[AQTView alloc] initWithFrame:NSMakeRect(0.0, 0.0, paperSize.width, paperSize.height)];
  [printView setModel:currentModel];
  [printView setIsPrinting:YES];

  printOp = [NSPrintOperation printOperationWithView:printView];
  (void)[printOp runOperationModalForWindow:frontWindow
                                   delegate:self
                             didRunSelector:@selector(printOperationDidRun:success:contextInfo:)
                                contextInfo:printView];
  [printView release];
}

- (IBAction)saveFigureAs:(id)sender
{
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  // trying to avert situation where saveas command with no window locks up AQT
  if (!frontWindow)
  {
    NSLog(@"Save as... selected without a window");
    return;
  }
  if (![NSBundle loadNibNamed:@"ExtendSavePanel" owner:self])
  {
    NSLog(@"Failed to load ExtendSavePanel.nib");
    return;
  }
  [savePanel setAccessoryView:extendSavePanelView];
  [savePanel beginSheetForDirectory:NSHomeDirectory()
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
  AQTView *printView;
  AQTModel *currentModel = [frontView model];

  if (NSFileHandlingPanelOKButton == returnCode)
  {
    printView = [[AQTView alloc] initWithFrame:NSMakeRect(0.0, 0.0, [currentModel canvasSize].width, [currentModel canvasSize].height)];
    [printView setModel:currentModel];
    [printView setIsPrinting:YES];
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
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  AQTView *printView;
  AQTModel *currentModel = [frontView model];

  if (!frontWindow)
  {
    NSLog(@"copy selected without a window");
    return;
  }

  printView = [[AQTView alloc] initWithFrame:NSMakeRect(0.0, 0.0, [currentModel canvasSize].width, [currentModel canvasSize].height)];
  [printView setModel:[frontView model]];
  [printView setIsPrinting:YES];
  [pasteboard declareTypes:[NSArray arrayWithObjects:NSPDFPboardType, NSPostScriptPboardType, nil] owner:nil];

  [pasteboard setData:[printView dataWithPDFInsideRect:[printView bounds]] forType:NSPDFPboardType];
  [pasteboard setData:[printView dataWithEPSInsideRect:[printView bounds]] forType:NSPostScriptPboardType];
  [printView release];
}

-(IBAction)showInfo:(id)sender
{
  // make sure inspector panel is visible
  // initialize if needed
/*
 if (!inspector)
  {
    inspector = [[AQTColorInspector allocWithZone:[self zone]] init];
  }
  [inspector showWindow:self];
*/
}

-(IBAction)help:(id)sender
{
  NSURL *helpURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
  if (helpURL)
  {
    [[NSWorkspace sharedWorkspace] openURL:helpURL];
  }
}

-(IBAction)test:(id)sender
{
   AQTAdapter *adapter = [clientList objectAtIndex:0];
   NSPoint polygon[5];
   char bytes[12]={
      255, 0, 0,
      0, 255, 0,
      0, 0, 255,
      0, 0, 0
   };
   float xf=0.0;
   int i;
   int x,y;
   if (!adapter)
   {
      NSLog(@"Failed to init adapter");
   }
   [adapter openPlotIndex:2 size:NSMakeSize(400,300) title:@"Testing"];
   [adapter addLabel:@"Left" position:NSMakePoint(200,160) angle:0.0 justification:0];
   [adapter addLabel:@"Center" position:NSMakePoint(200,150) angle:0.0 justification:1];
   [adapter addLabel:@"Right" position:NSMakePoint(200,170) angle:0.0 justification:2];
   for(i=0; i<1000; i++)
   {
      [adapter setColorRed:drand48() green:drand48() blue:drand48()];
      x = random() % 360 + 20;
      y = random() % 260 + 20;
      [adapter addLineAtPoint:NSMakePoint(x, y)];
      [adapter appendLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
      [adapter appendLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
      [adapter appendLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
      [adapter appendLineToPoint:NSMakePoint(x+random() % 10 - 5, y+random() % 10 - 5)];
   }
   [adapter addLineAtPoint:NSMakePoint(0, 149.5)];
   [adapter appendLineToPoint:NSMakePoint(399, 149.5)];
   [adapter addLineAtPoint:NSMakePoint(199.5, 0)];
   [adapter appendLineToPoint:NSMakePoint(199.5, 299)];
   [adapter addLineAtPoint:NSMakePoint(0, 0)]; // Force end of line
   [adapter closePlot];

   [adapter openPlotIndex:3 size:NSMakeSize(200,200) title:@"Image"];
   [adapter addImageWithBitmap:bytes size:NSMakeSize(2,2) bounds:NSMakeRect(50,50,100,100)];
   [adapter closePlot];

   [adapter openPlotIndex:4 size:NSMakeSize(200,200) title:@"Patch"];
   polygon[0]=NSMakePoint(xf+10.0, 10.0);
   polygon[1]=NSMakePoint(xf+20., 10.);
   polygon[2]=NSMakePoint(xf+20., 20.);
   polygon[3]=NSMakePoint(xf+10., 20.);
   polygon[4]=NSMakePoint(xf+10., 10.);
   [adapter addPolygonWithPoints:polygon pointCount:5];
   xf=10.0;
   polygon[0]=NSMakePoint(xf+10.0, 10.0);
   polygon[1]=NSMakePoint(xf+20., 10.);
   polygon[2]=NSMakePoint(xf+20., 20.);
   polygon[3]=NSMakePoint(xf+10., 20.);
   polygon[4]=NSMakePoint(xf+10., 10.);
   [adapter addPolygonWithPoints:polygon pointCount:5];
   [adapter closePlot];
}
@end
