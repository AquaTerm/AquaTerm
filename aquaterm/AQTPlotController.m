//
//  AQTPlotController.m
//  AquaTerm
//
//  Created by Per Persson on Thu Nov 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "AQTPlotController.h"
#import "AQTModel.h"
#import "AQTClientManager.h"

@implementation AQTPlotController
- (void)setHandler:(id)newHandler
{
   [newHandler retain];
   [_handler release];
   _handler = newHandler;
}

- (void)setModel:(AQTModel *)newModel
{
   NS_DURING
         [_handler setPlot:newModel];
   NS_HANDLER
         [[AQTClientManager sharedManager] _aqtHandlerError:[localException name]];
   NS_ENDHANDLER
}

#pragma mark === AQTEventProtocol methods ===

- (void)processEvent:(NSString *)event
{
   [[AQTClientManager sharedManager] processEvent:event sender:self]; // FIXME: Needs autoreleasing here???
}

- (void)setAcceptingEvents:(BOOL)flag
{
   NS_DURING
      [_handler setAcceptingEvents:flag];
   NS_HANDLER
      [[AQTClientManager sharedManager] _aqtHandlerError:[localException name]];
   NS_ENDHANDLER   
}
@end
