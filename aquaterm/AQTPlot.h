//
//  AQTPlot.h
//  AquaTerm
//
//  Created by Per Persson on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AQTClientProtocol.h"

@class AQTModel, AQTView;
@protocol AQTEventProtocol;
@interface AQTPlot : NSObject <AQTClientProtocol>
{
  IBOutlet AQTView *canvas;	/*" Points to the rendering view "*/
  AQTModel	*model;		/*" Holds the model for the view "*/
  BOOL _isWindowLoaded;
  BOOL _acceptingEvents;
  id <NSObject, AQTEventProtocol> _client;
  int32_t _clientPID;
  NSString *_clientName;
  // interface additions
  IBOutlet NSBox *extendSavePanelView;
  IBOutlet NSPopUpButton *saveFormatPopUp;
}
- (void)cascadeWindowOrderFront:(BOOL)orderFront;
- (void)constrainWindowToFrame:(NSRect)tileFrame;
- (id)canvas;
- (void)setClient:(id)client;
- (void)setClientInfoName:(NSString *)name pid:(int32_t)pid;
- (BOOL)clientValidAndResponding;
- (BOOL)invalidateClient; 
- (BOOL)acceptingEvents;

- (void)processEvent:(NSString *)theEvent;

- (IBAction)refreshView:(id)sender;

// testing methods
- (void)timingTestWithTag:(uint32_t)tag;
@end
