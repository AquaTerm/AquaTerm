//
//  AQTClientManager.h
//  AquaTerm
//
//  Created by Per Persson on Wed Nov 19 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

#import <stdint.h>
#import <Foundation/Foundation.h>
#import "AQTEventProtocol.h"

@class AQTPlotBuilder;
@protocol AQTEventProtocol;
@interface AQTClientManager : NSObject <AQTEventProtocol>
{
   id _server; /* The viewer app's (AquaTerm) default connection */
   NSMutableDictionary *_builders; /* The objects responsible for assembling a model object from client's calls. */
   NSMutableDictionary *_plots; /* The objects responsible for assembling a model object from client's calls. */
   id _activePlotKey;
   void (*_errorHandler)(NSString *msg);	/* A callback function optionally installed by the client */
   void (*_eventHandler)(int32_t index, NSString *event); /* A callback function optionally installed by the client */
   id _eventBuffer;
   int32_t _logLimit;
   BOOL errorState;
}
+ (AQTClientManager *)sharedManager;
- (void)setServer:(id)server;
- (BOOL)connectToServerWithName:(NSString *)registeredName;
- (BOOL)connectToServer;
- (BOOL)launchServer;
- (void)terminateConnection;
- (void)setActivePlotKey:(id)newActivePlotKey;
- (void)setErrorHandler:(void (*)(NSString *errMsg))fPtr;
- (void)setEventHandler:(void (*)(int32_t index, NSString *event))fPtr;

- (void)logMessage:(NSString *)msg logLevel:(int32_t)level;

- (AQTPlotBuilder *)newPlotWithIndex:(int32_t)refNum;
- (AQTPlotBuilder *)selectPlotWithIndex:(int32_t)refNum;
- (void)closePlot; 

- (void)renderPlot; 
- (AQTPlotBuilder *)clearPlot;
- (void)clearPlotRect:(NSRect)aRect;

- (void)setAcceptingEvents:(BOOL)flag; 
- (NSString *)lastEvent;

/* testing methods */
- (void)timingTestWithTag:(uint32_t)tag;
@end
