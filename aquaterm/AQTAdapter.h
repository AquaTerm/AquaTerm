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

enum {
   AQTAlignLeft = 0,
   AQTAlignCenter = 1,
   AQTAlignRight = 2
};


@protocol AQTConnectionProtocol;
@class AQTPlotBuilder;
@interface AQTAdapter : NSObject
{
  /*" All instance variables are private. "*/
  NSDistantObject <AQTConnectionProtocol> *_server; /* The viewer app's (AquaTerm) default connection */
  NSMutableDictionary *_builders; /* The objects responsible for assembling a model object from client's calls. */
  AQTPlotBuilder *_selectedBuilder; 	
  BOOL _serverIsLocal;
  void (*_errorHandler)(NSString *msg);	/* A callback function optionally installed by the client */
  void (*_eventHandler)(int index, NSString *event); /* A callback function optionally installed by the client */
  id _eventBuffer;
  id _aqtReserved1;
  id _aqtReserved2;
}

/*" Class initialization "*/
- (id)init;
- (id)initWithServer:(id)localServer;
- (void)setErrorHandler:(void (*)(NSString *msg))fPtr;
- (void)setEventHandler:(void (*)(int index, NSString *event))fPtr;


  /*" Control operations "*/
- (void)openPlotWithIndex:(int)refNum; 
- (BOOL)selectPlotWithIndex:(int)refNum;
- (void)setPlotSize:(NSSize)canvasSize;
- (void)setPlotTitle:(NSString *)title;
- (void)renderPlot;
- (void)clearPlot;
- (void)closePlot;

  /*" Event handling "*/
- (void)setAcceptingEvents:(BOOL)flag;
- (NSString *)lastEvent;

/*" Plotting related commands "*/

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
- (void)addLabel:(id)text position:(NSPoint)pos angle:(float)angle align:(int)just;

  /*" Line handling "*/
- (float)linewidth;
- (void)setLinewidth:(float)newLinewidth;
- (void)setLineCapStyle:(int)capStyle;
- (void)moveToPoint:(NSPoint)point;  
- (void)addLineToPoint:(NSPoint)point; 
- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc;

  /*" Rect and polygon handling"*/
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc; 
- (void)addFilledRect:(NSRect)aRect;
- (void)eraseRect:(NSRect)aRect;

  /*" Image handling "*/
- (void)setImageTransformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m22 tX:(float)tX tY:(float)tY;
- (void)resetImageTransform;
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds; 
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds; 
@end
