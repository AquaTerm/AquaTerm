//
//  AQTAdapter.h
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003-2004 AquaTerm.
//

#import <Foundation/NSString.h>
#import <Foundation/NSGeometry.h>

/*" Constants that specify linecap styles. "*/
extern const int AQTButtLineCapStyle;
extern const int AQTRoundLineCapStyle;
extern const int AQTSquareLineCapStyle;

/*" Constants that specify horizontal and vertical alignment for labels. See #addLabel:atPoint:angle:align: for definitions and use."*/
extern const int AQTAlignLeft;
extern const int AQTAlignCenter;
extern const int AQTAlignRight;
/* Constants that specify vertical alignment for labels. */
extern const int AQTAlignMiddle;
extern const int AQTAlignBaseline;
extern const int AQTAlignBottom;
extern const int AQTAlignTop;

@class AQTPlotBuilder, AQTClientManager;
@interface AQTAdapter : NSObject
{
   /*" All instance variables are private. "*/
   AQTClientManager *_clientManager;
   AQTPlotBuilder *_selectedBuilder;
   id _aqtReserved1;
   id _aqtReserved2;
}

/*" Class initialization etc."*/
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
- (NSString *)waitNextEvent; 

/*" Plotting related commands "*/

/*" Clip rect, applies to all objects "*/
- (void)setClipRect:(NSRect)clip;
- (void)setDefaultClipRect;

/*" Colormap (utility) "*/
- (int)colormapSize;
- (void)setColormapEntry:(int)entryIndex red:(float)r green:(float)g blue:(float)b;
- (void)getColormapEntry:(int)entryIndex red:(float *)r green:(float *)g blue:(float *)b;
- (void)takeColorFromColormapEntry:(int)index;
- (void)takeBackgroundColorFromColormapEntry:(int)index;

  /*" Color handling "*/
- (void)setColorRed:(float)r green:(float)g blue:(float)b;
- (void)setBackgroundColorRed:(float)r green:(float)g blue:(float)b;
- (void)getColorRed:(float *)r green:(float *)g blue:(float *)b;
- (void)getBackgroundColorRed:(float *)r green:(float *)g blue:(float *)b;

  /*" Text handling "*/
- (void)setFontname:(NSString *)newFontname;
- (void)setFontsize:(float)newFontsize;
- (void)addLabel:(id)text atPoint:(NSPoint)pos;
- (void)addLabel:(id)text atPoint:(NSPoint)pos angle:(float)angle align:(int)just;
- (void)addLabel:(id)text atPoint:(NSPoint)pos angle:(float)angle shearAngle:(float)shearAngle align:(int)just;

  /*" Line handling "*/
- (void)setLinewidth:(float)newLinewidth;
- (void)setLinestylePattern:(float *)newPattern count:(int)newCount phase:(float)newPhase;
- (void)setLinestyleSolid;
- (void)setLineCapStyle:(int)capStyle;
- (void)moveToPoint:(NSPoint)point;  
- (void)addLineToPoint:(NSPoint)point; 
- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc;

  /*" Rect and polygon handling"*/
- (void)moveToVertexPoint:(NSPoint)point;
- (void)addEdgeToVertexPoint:(NSPoint)point; 
- (void)addPolygonWithVertexPoints:(NSPoint *)points pointCount:(int)pc;
- (void)addFilledRect:(NSRect)aRect;
- (void)eraseRect:(NSRect)aRect;

  /*" Image handling "*/
- (void)setImageTransformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m22 tX:(float)tX tY:(float)tY;
- (void)resetImageTransform;
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds; 
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds;
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize;
@end
