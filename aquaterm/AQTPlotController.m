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

- (BOOL)handlerIsProxy
{
   [[AQTClientManager sharedManager]
        logMessage:[NSString stringWithFormat:@"handlerIsProxy: %@", [_handler isProxy]?@"YES":@"NO -- be careful!"]
          logLevel:4];
   NSLog(@"handlerIsProxy: %@", [_handler isProxy]?@"YES":@"NO -- be careful!");
   return [_handler isProxy];
}

- (void)setShouldAppendPlot:(BOOL)flag
{
   shouldAppendPlot = flag && [self handlerIsProxy];
}

- (void)updatePlotWithModel:(AQTModel *)newModel
{
   NS_DURING
      if (shouldAppendPlot)
      {
         [_handler appendModel:newModel];         
      }
      else
      {
         [_handler setModel:newModel];
         [self setShouldAppendPlot:YES];
      }
   NS_HANDLER
         [[AQTClientManager sharedManager] _aqtHandlerError:[localException name]];
   NS_ENDHANDLER
}

- (void)drawPlot
{
   // NSLog(@"implement --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);   
   NS_DURING
      [_handler draw];
   NS_HANDLER
      [[AQTClientManager sharedManager] _aqtHandlerError:[localException name]];
   NS_ENDHANDLER
}

- (void)clearPlotRect:(NSRect)aRect
{
   NS_DURING
      [_handler removeGraphicsInRect:aRect];
   NS_HANDLER
      [[AQTClientManager sharedManager] _aqtHandlerError:[localException name]];
   NS_ENDHANDLER
}

- (void)setAcceptingEvents:(BOOL)flag
{
   NS_DURING
      [_handler setAcceptingEvents:flag];
   NS_HANDLER
      [[AQTClientManager sharedManager] _aqtHandlerError:[localException name]];
   NS_ENDHANDLER   
}

#pragma mark === AQTEventProtocol methods ===

- (void)processEvent:(NSString *)event
{
   [[AQTClientManager sharedManager] processEvent:event sender:self]; // FIXME: Needs autoreleasing here???
}

@end
