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
#import <Foundation/NSDictionary.h>

#define AQT_COLORMAP_SIZE 256

enum {
  AQTButtLineCapStyle = 0,
  AQTRoundLineCapStyle = 1,
  AQTSquareLineCapStyle = 2
};


@class AQTPlotBuilder;
@protocol AQTConnectionProtocol, AQTClientProtocol;
@interface AQTAdapter : NSObject
{
  NSMutableDictionary *_builders;
  NSMutableDictionary *_handlers; 

  NSString *_uniqueId; 	/*" A unique string used to identify this adapter in AquaTerm "*/
  NSString *_procName; 	/*" Holds the name of the process who instantiated the object "*/
  int _procId;		/*" Holds the pid of the process who instantiated the object "*/
  NSDistantObject <AQTConnectionProtocol> *_server;	/*" The viewer app's (AquaTerm) default connection "*/
//  NSDistantObject <AQTClientProtocol> *_handler; 	/*" The handler object in AquaTerm responsible for communication "*/
  AQTPlotBuilder *_selectedBuilder; 	/*" The object responsible for assembling a model object from client's calls"*/
  NSDistantObject <AQTClientProtocol> *_selectedHandler; 	/*" The handler object in AquaTerm responsible for communication "*/
  void (*_errorHandler)(NSString *msg);	/*" A callback function optionally installed by the client "*/
}

/*" Class initialization "*/
- (id)init;
- (id)initWithServer:(id)localServer;
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr;
// - (void)setBuilder:(AQTPlotBuilder *)newBuilder;

  /*" Control operations "*/
- (void)openPlotIndex:(int)refNum;  // size:(NSSize)canvasSize title:(NSString *)title; // if title param is nil, title defaults to Figure <n>
- (BOOL)selectPlot:(int)refNum;
- (void)clearPlot;
- (void)closePlot;
- (void)setPlotSize:(NSSize)canvasSize;
- (void)setPlotTitle:(NSString *)title;
- (void)render; //(push [partial] model to renderer)

  /*" Interactions with user "*/
- (char)getMouseInput:(NSPoint *)mouseLoc options:(unsigned)options;

/*" Plot related commands "*/

  /*" Color handling "*/
- (void)setColorRed:(float)r green:(float)g blue:(float)b;
- (void)takeColorFromColormapEntry:(int)index;
- (void)setBackgroundColorRed:(float)r green:(float)g blue:(float)b;
- (void)takeBackgroundColorFromColormapEntry:(int)index;
- (void)getCurrentColorRed:(float *)r green:(float *)g blue:(float *)b;
- (void)setColormapEntry:(int)entryIndex red:(float)r green:(float)g blue:(float)b;
- (void)getColormapEntry:(int)entryIndex red:(float *)r green:(float *)g blue:(float *)b;

  /*" Text handling "*/
- (NSString *)fontname;
- (void)setFontname:(NSString *)newFontname;
- (float)fontsize;
- (void)setFontsize:(float)newFontsize;
- (void)addLabel:(NSString *)text position:(NSPoint)pos angle:(float)angle justification:(int)just;

  /*" Line handling "*/
- (float)linewidth;
- (void)setLinewidth:(float)newLinewidth;
- (void)setLineCapStyle:(int)capStyle;
- (void)moveToPoint:(NSPoint)point;  // AQTPath
- (void)addLineToPoint:(NSPoint)point;  // AQTPath
- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc;

  /*" Rect and polygon handling"*/
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc; // AQTPatch
- (void)addFilledRect:(NSRect)aRect;
- (void)eraseRect:(NSRect)aRect;

  /*" Image handling "*/
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds; // AQTImage
@end
