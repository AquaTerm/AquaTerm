//
//  AQTAdapter.h
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

@class AQTModel;
@protocol AQTClientProtocol, AQTConnectionProtocol; 
@interface AQTAdapter : NSObject
{
  AQTModel *_model;	/*" The graph currently being built "*/
  int _modelRefNumber;	/*" Index into our handler's list of views "*/
  AQTColor _color;	/*" Currently selected color "*/ 
  NSString *_fontname;	/*" Currently selected font "*/
  float _fontsize;	/*" Currently selected fontsize [pt]"*/
  float _linewidth;	/*" Currently selected linewidth [pt] "*/
  NSPoint _path[256];	/*" A cache for coalescing connected line segments into a single path "*/
  int _pointCount;	/*" The current number of points in _path"*/
  BOOL _modelIsDirty;	/*" A flag indicating that AquaTerm has not been updated with the latest info "*/
  NSString *_uniqueId; 	/*" A unique string used to identify this adapter in AquaTerm "*/
  NSString *_procName; 	/*" Holds the name of the process who instantiated the object "*/
  int _procId;		/*" Holds the pid of the process who instantiated the object "*/
  NSDistantObject <AQTConnectionProtocol> *_server;		/*" The viewer app's (AquaTerm) default connection "*/
  NSDistantObject <AQTClientProtocol> *_handler; /*" The handler object in AquaTerm responsible for communication "*/
  void (*_errorHandler)(NSString *msg);	/*" A callback function optionally installed by the client "*/
}
/*" Class initialization "*/
- (id)init;
- (id)initWithHandler:(id)localHandler;
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr;

/*" Color handling "*/
//- (AQTColor)color;
- (void)setColorRed:(float)r green:(float)g blue:(float)b;
//- (void)setColor:(AQTColor)newColor;
/*" Text handling "*/
- (NSString *)fontname;
- (void)setFontname:(NSString *)newFontname;
- (float)fontsize;
- (void)setFontsize:(float)newFontsize;
- (void)addLabel:(NSString *)text position:(NSPoint)pos angle:(float)angle justification:(int)just;
/*" Line handling "*/
- (float)linewidth;
- (void)setLinewidth:(float)newLinewidth;
- (void)addLineAtPoint:(NSPoint)point;  // AQTPath
- (void)appendLineToPoint:(NSPoint)point;  // AQTPath
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc; // AQTPatch
/*" Image handling "*/
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds; // AQTImage

/*" Control operations "*/
- (void)openPlotIndex:(int)refNum size:(NSSize)canvasSize title:(NSString *)title; // if title param is nil, title defaults to Figure <n>
- (void)closePlot;
- (void)render; //(push [partial] model to renderer)
- (void)eraseRect:(NSRect)aRect;
/*" Interactions with user "*/
- (char)getMouseInput:(NSPoint *)mouseLoc options:(unsigned)options;
/*" Misc "*/
- (void)setModel:(AQTModel *)newModel;
@end
