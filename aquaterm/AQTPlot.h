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

@class AQTModel, AQTView, AQTPlotController;
@interface AQTPlot : NSObject <AQTClientProtocol>
{
  IBOutlet AQTView *canvas;	/*" Points to the rendering view "*/
  AQTModel	*model;		/*" Holds the model for the view "*/
  BOOL _isWindowLoaded;
  BOOL _acceptingEvents;
  AQTPlotController *_client;
  int _clientPID;
  NSString *_clientName;
  NSRect dirtyRect;
  // interface additions
  IBOutlet NSBox *extendSavePanelView;
  IBOutlet NSPopUpButton *saveFormatPopUp;
}
- (id)canvas;
- (void)setClient:(id)client;
- (void)setClientInfoName:(NSString *)name pid:(int)pid;
- (BOOL)clientValidAndResponding;
- (BOOL)invalidateClient:(id)aClient;
- (BOOL)acceptingEvents;

- (void)processEvent:(NSString *)theEvent;

- (IBAction)refreshView:(id)sender;
@end
