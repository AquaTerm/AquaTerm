//
//  AQTClientManager.h
//  AquaTerm
//
//  Created by Per Persson on Wed Nov 19 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AQTPlotBuilder, AQTPlotController;
@interface AQTClientManager : NSObject
{
   id _server; /* The viewer app's (AquaTerm) default connection */
   NSMutableDictionary *_builders; /* The objects responsible for assembling a model object from client's calls. */
   NSMutableDictionary *_plotControllers; /* The objects responsible for assembling a model object from client's calls. */
   id _activePlotKey;
   void (*_errorHandler)(NSString *msg);	/* A callback function optionally installed by the client */
   void (*_eventHandler)(int index, NSString *event); /* A callback function optionally installed by the client */
   id _eventBuffer;
   int _logLimit;
}
+ (AQTClientManager *)sharedManager;
- (void)setServer:(id)server;
- (BOOL)connectToServer;
- (BOOL)launchServer;
- (void)terminateConnection;
- (void)setErrorHandler:(void (*)(NSString *errMsg))fPtr;
- (void)setEventHandler:(void (*)(int index, NSString *event))fPtr;

- (void)logMessage:(NSString *)msg logLevel:(int)level;

- (NSNumber *)keyForPlotController:(AQTPlotController *)pc;

- (AQTPlotBuilder *)newPlotWithIndex:(int)refNum;
- (AQTPlotBuilder *)selectPlotWithIndex:(int)refNum;
- (void)closePlot; 

- (void)renderPlot; 
- (void)clearPlot; 

- (void)setAcceptingEvents:(BOOL)flag; 
- (void)processEvent:(NSString *)event sender:(id)sender;
- (NSString *)lastEvent; 
@end
