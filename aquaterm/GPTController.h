//
//  GPTController.h
//  AGPT3
//
//  Created by per on Sat Oct 06 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AQTBuilder, GPTWindowController, GPTView, AQTModel, AQTColorInspector;

@interface GPTController : NSObject 
{
    AQTBuilder 			*builder;				/*" Implements AQTProtocol methods "*/
    NSMutableArray 		*gptWindowControllers;	/*" Array of windowcontrollers "*/
    NSWindow			*frontWindow;			/*" The main (frontmost) window of the app "*/
    NSPopUpButton 		*saveFormatPopup;
    NSBox				*extendSavePanelView;	
    AQTColorInspector 	*inspector;
    NSConnection		*doConnection;
}

/* FAQ: since the window controller is made a delegate of the window (in the NIB) does that mean that it has "first access" to all window calls??? */

-(id)init;
-(void)awakeFromNib;

-(NSArray *)windowControllers;
-(void)addWindowController:(GPTWindowController *)newWindowController;
-(GPTWindowController *)controllerForView:(int)index;

-(void)setModel:(AQTModel *)gptModel forView:(int)index;

-(NSWindow *)frontWindow;
-(void)setFrontWindow:(NSWindow *)mainWindow;

-(IBAction)print:(id)sender; 
-(IBAction)saveFigureAs:(id)sender;
-(void)savePanelDidEnd:(NSSavePanel *)theSheet returnCode:(int)returnCode contextInfo:(NSPopUpButton *)formatPopUp;
-(IBAction)copy:(id)sender;
-(IBAction)help:(id)sender;
@end
