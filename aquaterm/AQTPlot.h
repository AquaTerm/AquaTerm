//
//  AQTPlot.h
//  AquaTerm
//
//  Created by Per Persson on Mon Jul 28 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class AQTModel, AQTView;

@interface AQTPlot : NSObject
{
  IBOutlet AQTView *viewOutlet;	/*" Points to the rendering view "*/
  AQTModel	*model;		/*" Holds the model for the view "*/
  int 		viewIndex;	/*" The number by which the client refers to the model "*/
  BOOL _isWindowLoaded;
  NSPoint _selectedPoint;
  char _keyPressed;
  BOOL _selectedPointIsValid;

}
-(id)initWithModel:(AQTModel *)aModel index:(int)index;

-(id)viewOutlet;
-(int)viewIndex;
-(void)setModel:(AQTModel *)newModel;

- (void)beginMouseInput;
- (void)mouseDownAt:(NSPoint)pos key:(char)aKey;
- (char)keyPressed;
- (NSPoint) selectedPoint;
- (BOOL) selectedPointIsValid;

@end
