//
//  AQTPlotBuilder.h
//  AquaTerm
//
//  Created by Per Persson on Sat Aug 16 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"
#import "AQTImage.h"
#import "AQTClientProtocol.h"

// This is the maximum practically useable path length due to the way Quartz renders a path
// FIXME: establish some "optimal" value
#define MAX_POLYLINE_POINTS 64
#define MAX_POLYGON_POINTS 256

@class AQTModel, AQTColorMap;
@interface AQTPlotBuilder : NSObject
{
  AQTModel *_model;	/*" The graph currently being built "*/
  AQTColor _color;	/*" Currently selected color "*/
  NSString *_fontName;	/*" Currently selected font "*/
  float _fontSize;	/*" Currently selected fontsize [pt]"*/
  float _linewidth;	/*" Currently selected linewidth [pt] "*/
  int _capStyle; /*" Currently selected linecap style "*/
  NSPoint _polylinePoints[MAX_POLYLINE_POINTS];	/*" A cache for coalescing connected line segments into a single path "*/
  int _polylinePointCount;	/*" The current number of points in _polylinePoints"*/
  NSPoint _polygonPoints[MAX_POLYGON_POINTS];	/*" A cache for coalescing connected line segments into a single path "*/
  int _polygonPointCount;	/*" The current number of points in _polylinePoints"*/
  BOOL _modelIsDirty;	/*" A flag indicating that AquaTerm has not been updated with the latest info "*/
  BOOL _shouldAppend;
  AQTAffineTransformStruct _transform;
  NSDistantObject <AQTClientProtocol> *_handler; 	/*" The handler object in AquaTerm responsible for communication "*/
  id owner;
  AQTColorMap *_colormap;
}

/*" Acessors "*/
- (void)setSize:(NSSize)canvasSize;
- (void)setTitle:(NSString *)title;
- (void)setHandler:(id)newHandler;
- (void)setOwner:(id)object;


  /*" Color handling "*/
- (AQTColor)color;
- (void)setColor:(AQTColor)newColor;
- (void)setBackgroundColor:(AQTColor)newColor;

- (void)takeColorFromColormapEntry:(int)index;
- (void)takeBackgroundColorFromColormapEntry:(int)index;

- (int)colormapSize;
- (void)setColor:(AQTColor)newColor forColormapEntry:(int)entryIndex;
- (AQTColor)colorForColormapEntry:(int)entryIndex;

  /*" Text handling "*/
//- (NSString *)fontname;
- (void)setFontname:(NSString *)newFontname;
//- (float)fontsize;
- (void)setFontsize:(float)newFontsize;
- (void)addLabel:(id)text position:(NSPoint)pos angle:(float)angle justification:(int)just;

  /*" Line handling "*/
//- (float)linewidth;
- (void)setLinewidth:(float)newLinewidth;
- (void)setLineCapStyle:(int)capStyle;
- (void)moveToPoint:(NSPoint)point;  // AQTPath
- (void)addLineToPoint:(NSPoint)point;  // AQTPath
- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc;
//- (void)addPolylineWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc;

  /*" Filled areas"*/
- (void)moveToVertexPoint:(NSPoint)point;
- (void)addEdgeToPoint:(NSPoint)point; 
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc; // AQTPatch
//- (void)addPolygonWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc;
- (void)addFilledRect:(NSRect)aRect;

  /*" Image handling "*/
- (void)setImageTransform:(AQTAffineTransformStruct)trans;
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds; // AQTImage
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds;

  /*" Control operations "*/
- (void)eraseRect:(NSRect)aRect;
- (void)render;
- (void)clearAll; 

   /*" Interactions with user "*/
- (void)setAcceptingEvents:(BOOL)flag;
- (void)processEvent:(NSString *)event;
@end
