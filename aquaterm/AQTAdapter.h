//
//  AQTAdapter.h
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AQTClientProtocol.h"
//#import "AQTConnectionProtocol.h"
#import "AQTGraphic.h"
//#import "AQTPath.h"

@class AQTModel;
@interface AQTAdapter : NSObject
{
  NSString *uniqueId;
  NSString *procName;
  int procId;
  AQTColor _color;
  NSString *_fontname;
  float _fontsize;
  float _linewidth;
  @private
  id _server;
  id <NSObject> _handler;
  AQTModel *_model;
  int _modelRefNumber;
  NSPoint _path[256];
  int _pointCount;
  BOOL _modelIsDirty;
  void (*_errorHandler)(NSString *msg);
}
- (id)initWithHandler:(id)localHandler;
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr;
- (AQTColor)color;
- (void)setColorRed:(float)r green:(float)g blue:(float)b;
- (void)setColor:(AQTColor)newColor;
- (NSString *)fontname;
- (void)setFontname:(NSString *)newFontname;
- (float)fontsize;
- (void)setFontsize:(float)newFontsize;
- (float)linewidth;
- (void)setLinewidth:(float)newLinewidth;
- (void)eraseRect:(NSRect)aRect;
  //
  // AQTLabel
  //
- (void)addLabel:(NSString *)text position:(NSPoint)pos angle:(float)angle justification:(int)just;
  //
  // AQTPath
  //
- (void)addLineAtPoint:(NSPoint)point;
- (void)appendLineToPoint:(NSPoint)point;
  //
  // AQTPatch
  //
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc;
  //
  // AQTImage
  //
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds;
  //
  // Control operations
  //
- (void)openPlotIndex:(int)refNum size:(NSSize)canvasSize title:(NSString *)title; // if title param is nil, title defaults to Figure <n>
- (void)closePlot;

- (void)render; //(push [partial] model to renderer)
- (char)getMouseInput:(NSPoint *)mouseLoc options:(unsigned)options;
@end
