//
//  AQTController.h
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 25 2003.
//  Copyright (c) 2003 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTConnectionProtocol.h"

@class AQTAdapter;
@interface AQTController : NSObject <AQTConnectionProtocol>
{
  NSMutableArray	*handlerList;		/*" Array of client handlers "*/
  NSPopUpButton		*saveFormatPopup;
  NSBox			*extendSavePanelView;
  NSPoint cascadingPoint;
}

- (AQTAdapter *)sharedAdapter;
- (void)removePlot:(id)aPlot;
- (void)setWindowPos:(NSWindow *)plotWindow;

-(IBAction)tileWindows:(id)sender;
-(IBAction)cascadeWindows:(id)sender;
-(IBAction)showHelp:(id)sender;
-(IBAction)showPrefs:(id)sender;
-(IBAction)debug:(id)sender;
-(IBAction)mailBug:(id)sender;
-(IBAction)mailFeedback:(id)sender;
-(IBAction)testview:(id)sender;
-(IBAction)stringDrawingTest:(id)sender;
-(IBAction)lineDrawingTest:(id)sender;
@end
