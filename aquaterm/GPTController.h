//
//  GPTController.h
//  AGPT3
//
//  Created by per on Sat Oct 06 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GPTReceiverObject, GPTWindowController, GPTView, AQTModel;

@interface GPTController : NSObject 
{
        GPTReceiverObject *receiverObject;	/*" DO connection handler  "*/
        NSMutableArray 	*gptWindowControllers;	/*" Array of windowcontrollers "*/
        NSWindow	*frontWindow;		/*" The main (frontmost) window of the app "*/
}

/* FAQ: since the window controller is made a delegate of the window (in the NIB) does that mean that it has "first access" to all window calls??? */

-(id)init;
-(void)awakeFromNib;
-(void)setModel:(AQTModel *)gptModel forView:(unsigned)index;
-(GPTWindowController *)controllerForView:(unsigned)index;
-(void)setFrontWindow:(NSWindow *)mainWindow;
-(IBAction)print:(id)sender; 
-(IBAction)saveFigureAs:(id)sender;
-(void)savePanelDidEnd:(NSSavePanel *)theSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (IBAction)copy:(id)sender;
-(IBAction)debugInfo:(id)sender;
@end
