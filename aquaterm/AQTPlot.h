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
@interface AQTPlot : NSObject <AQTClientProtocol>
{
  IBOutlet AQTView *viewOutlet;	/*" Points to the rendering view "*/
  AQTModel	*model;		/*" Holds the model for the view "*/
  BOOL _isWindowLoaded;
  NSPoint _selectedPoint;
  char _keyPressed;
  BOOL _acceptingEvents;
  id _client;
}
-(id)initWithModel:(AQTModel *)aModel; 

-(id)viewOutlet;
-(void)setModel:(AQTModel *)newModel;
-(void)setClient:(id)client;

- (void)mouseDownAt:(NSPoint)pos key:(char)aKey;
- (char)keyPressed;
- (NSPoint)selectedPoint;
@end
