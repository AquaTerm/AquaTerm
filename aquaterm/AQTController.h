//
//  AQTController.h
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 25 2003.
//  Copyright (c) 2003 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTConnectionProtocol.h"

@interface AQTController : NSObject <AQTConnectionProtocol>
{
//  NSMutableArray	*handlerList;		/*" Array of client handlers "*/
  NSPopUpButton		*saveFormatPopup;
  NSBox			*extendSavePanelView;
  NSConnection		*doConnection;
}
-(IBAction)showHelp:(id)sender;
-(IBAction)test:(id)sender;
@end
