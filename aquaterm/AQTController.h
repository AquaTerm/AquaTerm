//
//  AQTController.h
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 25 2003.
//  Copyright (c) 2003 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTConnectionProtocol.h"

@class AQTClientHandler, GPTWindowController, AQTView, AQTModel, AQTColorInspector;
@interface AQTController : NSObject <AQTConnectionProtocol>
{
  NSMutableArray	*handlerList;		/*" Array of client handlers "*/
  NSMutableArray	*clientList;		/*" Array of client proxies "*/
  NSMutableArray	*gptWindowControllers;	/*" Array of windowcontrollers "*/
  NSWindow		*frontWindow;		/*" The main (frontmost) window of the app "*/
  AQTView		*frontView;
  NSPopUpButton		*saveFormatPopup;
  NSBox			*extendSavePanelView;
  //AQTColorInspector 	*inspector;
  NSConnection		*doConnection;
}
-(GPTWindowController *)controllerForView:(int)index;

-(void)setModel:(AQTModel *)gptModel forView:(int)index;

-(NSWindow *)frontWindow;
-(void)setFrontWindow:(NSWindow *)mainWindow;

-(IBAction)print:(id)sender;
-(IBAction)saveFigureAs:(id)sender;
-(void)savePanelDidEnd:(NSSavePanel *)theSheet returnCode:(int)returnCode contextInfo:(NSPopUpButton *)formatPopUp;
-(IBAction)copy:(id)sender;
-(IBAction)help:(id)sender;
-(IBAction)test:(id)sender;
@end
