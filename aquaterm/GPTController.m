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
    // FIXME: this is just a printout of the screen image...
    [[NSPrintOperation printOperationWithView:[[frontWindow windowController] viewOutlet]] runOperation];
}
-(IBAction)debugInfo:(id)sender
{
  NSLog(@"Debug log: %@", [[receiverObject connection] remoteObjects]);
}

@end
