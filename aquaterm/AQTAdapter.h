//
//  AQTAdapter.h
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import <Foundation/NSString.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSDistantObject.h>

@class AQTPlotBuilder;
@protocol AQTConnectionProtocol, AQTClientProtocol;
@interface AQTAdapter : NSObject
{
  NSString *_uniqueId; 	/*" A unique string used to identify this adapter in AquaTerm "*/
  NSString *_procName; 	/*" Holds the name of the process who instantiated the object "*/
  int _procId;		/*" Holds the pid of the process who instantiated the object "*/
  NSDistantObject <AQTConnectionProtocol> *_server;		/*" The viewer app's (AquaTerm) default connection "*/
  NSDistantObject <AQTClientProtocol> *_handler; /*" The handler object in AquaTerm responsible for communication "*/
  AQTPlotBuilder *_builder; /*" The object responsible for assembling a model object from client's calls"*/
  void (*_errorHandler)(NSString *msg);	/*" A callback function optionally installed by the client "*/
}
/*" Class initialization "*/
- (id)init;
- (id)initWithHandler:(id)localHandler;
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr;
- (void)setBuilder:(AQTPlotBuilder *)newBuilder;
  /*" Control operations "*/
- (void)openPlotIndex:(int)refNum size:(NSSize)canvasSize title:(NSString *)title; // if title param is nil, title defaults to Figure <n>
- (void)closePlot;
- (void)render; //(push [partial] model to renderer)
- (void)eraseRect:(NSRect)aRect;
/*" Interactions with user "*/
- (char)getMouseInput:(NSPoint *)mouseLoc options:(unsigned)options;

/*" Plot related commands "*/
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
@end
