//
//  AQTPlotBuilder.m
//  AquaTerm
//
//  Created by Per Persson on Sat Aug 16 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import <stdint.h>
#import "AQTPlotBuilder.h"
#import "AQTGraphic.h"
#import "AQTModel.h"
#import "AQTLabel.h"
#import "AQTPath.h"
#import "AQTImage.h"
#import "AQTColorMap.h"


@implementation AQTPlotBuilder
- (void)_aqtPlotBuilderSetDefaultValues
{
   _color.red = 0.0;
   _color.green = 0.0;
   _color.blue = 0.0;
   _color.alpha = 1.0;
   _fontName = @"Times-Roman";
   _fontSize = 14.0;
   _linewidth = 1.0;
   _transform.m11 = 1.0;
   _transform.m22 = 1.0;
   _hasPattern = NO;
   _patternCount = 0;
   _patternPhase = 0.0;
}

- (void)_aqtPlotBuilderSetModelIsDirty:(BOOL)isDirty
{
   // Any coalescing of render call may be performed here (use timer)

   // It ain't dirty until the fat lady has a size
   _modelIsDirty = isDirty && _hasSize;
#ifdef DEBUG
   if (_modelIsDirty && NSEqualSizes(NSZeroSize, [_model canvasSize]))
   {
#warning 64BIT: Check formatting arguments
      [NSException raise:@"AQTDebugException" format:NSStringFromSelector(_cmd)];
   }
#endif
}

- (BOOL)_flushPolylineBuffer
{
   BOOL didFlush = NO;
   if (_polylinePointCount > 1)
   {
      [self addPolylineWithPoints:_polylinePoints pointCount:_polylinePointCount];
      _polylinePointCount = 0;
      didFlush = YES;
   }
   return didFlush;
}

- (BOOL)_flushPolygonBuffer
{
   BOOL didFlush = NO;
   if (_polygonPointCount > 1)
   {
      [self addPolygonWithPoints:_polygonPoints pointCount:_polygonPointCount];
      _polygonPointCount = 0;
      didFlush = YES;
   }
   return didFlush;
}

-(void)_flushBuffers
{
   // Possibly more stuff??
   [self _flushPolylineBuffer];
   [self _flushPolygonBuffer];
}

- (id)init
{
   if(self = [super init])
   {
      _model = [[AQTModel alloc] initWithCanvasSize:NSZeroSize];  // FIXME: cf. -init;
      [self _aqtPlotBuilderSetDefaultValues];
      _colormap = [[AQTColorMap alloc] initWithColormapSize:AQT_COLORMAP_SIZE];
      [self _aqtPlotBuilderSetModelIsDirty:NO];
   }
   return self;
}

- (void)dealloc
{
#ifdef MEM_DEBUG
#warning 64BIT: Check formatting arguments
   NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
#endif
   [_model release];
   [_colormap release];
   [super dealloc];
}

- (BOOL)modelIsDirty
{
   return _modelIsDirty;
}

- (AQTModel *)model
{
   [self _flushBuffers];
   return _model;
}


- (void)setSize:(NSSize)canvasSize
{
   _hasSize = !NSEqualSizes(NSZeroSize, canvasSize); 
   [_model setCanvasSize:canvasSize];
}

- (void)setTitle:(NSString *)title
{
   [_model setTitle:title];
}

- (void)setClipRect:(NSRect)clip
{
   [self _flushBuffers];
   _clipRect = clip;
   _isClipped = YES;
}

- (void)setDefaultClipRect
{
   [self _flushBuffers];
   _clipRect = NSZeroRect;
   _isClipped = NO;
}

- (AQTColor)color
{
   return _color;
}

- (void)setColor:(AQTColor)newColor
{
   // FIXME: Use AQTEqualColor instead
   if ((newColor.red != _color.red) || (newColor.green != _color.green) || (newColor.blue != _color.blue) || (newColor.alpha != _color.alpha))
   {
      [self _flushBuffers];
      _color = newColor;
   }
}

- (void)setBackgroundColor:(AQTColor)newColor
{
   AQTColor oldColor = [_model color];
   // FIXME: Use AQTEqualColor instead
   if ((newColor.red != oldColor.red) || (newColor.green != oldColor.green) || (newColor.blue != oldColor.blue) || (newColor.alpha != oldColor.alpha))
   {
      [_model setColor:newColor];
      [self _aqtPlotBuilderSetModelIsDirty:YES];
   }
}

- (AQTColor)backgroundColor
{
   return [_model color];
}

- (void)takeColorFromColormapEntry:(int32_t)index
{
   [self setColor:[_colormap colorForIndex:index]];
}

- (void)takeBackgroundColorFromColormapEntry:(int32_t)index
{
   [self setBackgroundColor:[_colormap colorForIndex:index]];
}

- (int32_t)colormapSize
{
   return [_colormap size];
}

- (void)setColor:(AQTColor)newColor forColormapEntry:(int32_t)entryIndex
{
   [_colormap setColor:newColor forIndex:entryIndex];
}

- (AQTColor)colorForColormapEntry:(int32_t)entryIndex
{
   return [_colormap colorForIndex:entryIndex];
}

- (void)setFontname:(NSString *)newFontname
{
   if (_fontName != newFontname)
   {
      NSString *oldValue = _fontName;
      _fontName = [newFontname retain];
      [oldValue release];
   }
}

- (void)setFontsize:(float)newFontsize
{
   _fontSize = newFontsize;
}

- (void)setLinewidth:(float)newLinewidth
{
   // FIXME: The following line seems to be a bug...
   [self _flushPolygonBuffer]; // FIXME: expose flush methods in API?
   if (newLinewidth != _linewidth)
   {
      [self _flushPolylineBuffer];
      _linewidth = newLinewidth;
   }
}

- (void)setLinestylePattern:(float *)newPattern count:(int32_t)newCount phase:(float)newPhase //CM
{
   [self _flushBuffers]; // FIXME: expose flush methods in API?
   // Copy the pattern
   int32_t i;
   if (newCount <= 0) // Sanity check
      return;
   // constrain count to MAX_PATTERN_COUNT
   newCount = newCount>MAX_PATTERN_COUNT?MAX_PATTERN_COUNT:newCount;
   for (i=0; i<newCount; i++) {
      _pattern[i] = newPattern[i]; 
   }
   _patternCount = newCount; 
   _patternPhase = newPhase;
   _hasPattern = YES;
}

- (void)setLinestyleSolid
{
   [self _flushBuffers]; // FIXME: expose flush methods in API?
   _hasPattern = NO;
}

- (void)setLineCapStyle:(int32_t)capStyle
{
   [self _flushBuffers];
   _capStyle = capStyle;
}

- (void)removeAllParts
{
   [_model removeAllObjects];
}

//
// AQTLabel
//
- (void)addLabel:(id)text position:(NSPoint)pos angle:(float)angle shearAngle:(float)shearAngle justification:(int32_t)just;
{
   AQTLabel *lb = nil;
   if ([text isKindOfClass:[NSString class]])
   {
      lb = [[AQTLabel alloc] initWithString:text
                                   position:pos
                                      angle:angle
                                 shearAngle:shearAngle
                              justification:just];
   }
   else
   {
      if ([text isKindOfClass:[NSAttributedString class]])
      {
         lb = [[AQTLabel alloc] initWithAttributedString:text
                                                position:pos
                                                   angle:angle
                                              shearAngle:shearAngle
                                           justification:just];
      }
      else
      {
         NSLog(@"Error, not a string.");
      }
   }
   [lb setIsClipped:_isClipped];
   [lb setClipRect:_clipRect];
   [lb setColor:_color];
   [lb setFontName:_fontName];
   [lb setFontSize:_fontSize];
   [_model addObject:lb];
   [lb release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}
//
// AQTPath
//
- (void)moveToPoint:(NSPoint)point
{
   [self _flushPolygonBuffer]; // FIXME: expose flush methods in API?
   if (_polylinePointCount > 1)
   {
      // Only flush if this creates a disjoint path,
      // if the point is just the latest endpoint, skip it
      if (!NSEqualPoints(point, _polylinePoints[_polylinePointCount-1]))
      {
         [self _flushPolylineBuffer];
         _polylinePoints[0]=point;
         _polylinePointCount = 1;
      }
   }
   else
   {
      // This is an initial move or a move-after-move case,
      // just accept it
      _polylinePoints[0]=point;
      _polylinePointCount = 1;
   }
}

- (void)addLineToPoint:(NSPoint)point
{
   _polylinePoints[_polylinePointCount]=point;
   _polylinePointCount++;
   if (_polylinePointCount == MAX_POLYLINE_POINTS)
   {
      // NSLog(@"---- Reaching path limit (%d) ----", MAX_POLYLINE_POINTS);
      // Split the line
      [self addPolylineWithPoints:_polylinePoints pointCount:_polylinePointCount];
      _polylinePointCount = 0;
      [self moveToPoint:point];
   }
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}

   // This is where all line-drawing  ends up eventually. 
- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int32_t)pc
{
   AQTPath *tmpPath;
   // Create a path
   tmpPath = [[AQTPath alloc] initWithPoints:points pointCount:pc];
   // Copy current properties to path
   [tmpPath setClipRect:_clipRect];
   [tmpPath setIsClipped:_isClipped];
   [tmpPath setColor:_color];
   [tmpPath setLinewidth:_linewidth];
   [tmpPath setLineCapStyle:_capStyle];
   // [tmpPath setHasPattern:_hasPattern];
   if(_hasPattern == YES) {
      [tmpPath setLinestylePattern:_pattern count:_patternCount phase:_patternPhase];
   }
   [_model addObject:tmpPath];
   [tmpPath release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}
//
// AQTPatch
//
- (void)moveToVertexPoint:(NSPoint)point
{
   [self _flushPolylineBuffer]; // FIXME: expose flush methods in API?
   if (_polygonPointCount > 1)
   {
      [self _flushPolygonBuffer];
      _polygonPoints[0]=point;
      _polygonPointCount = 1;
   }
   else
   {
      // This is an initial move or a move-after-move case,
      // just accept it
      _polygonPoints[0]=point;
      _polygonPointCount = 1;
   }
}

- (void)addEdgeToPoint:(NSPoint)point
{
   _polygonPoints[_polygonPointCount]=point;
   _polygonPointCount++;
   if (_polygonPointCount == MAX_POLYGON_POINTS)
   {
      // NSLog(@"---- Reaching path limit (%d) ----", MAX_POLYGON_POINTS);
      // Split the line
      [self addPolygonWithPoints:_polygonPoints pointCount:_polygonPointCount];
      _polygonPointCount = 0;
      [self moveToVertexPoint:point];
   }
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}

- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int32_t)pc
{
   AQTPath *tmpPath;
   tmpPath = [[AQTPath alloc] initWithPoints:points pointCount:pc];
   [tmpPath setClipRect:_clipRect];
   [tmpPath setIsClipped:_isClipped];
   [tmpPath setColor:_color];
   [tmpPath setLinewidth:0.25]; // FIXME: What to do about the see-through edges?
   //[tmpPath setLineCapStyle:_capStyle];
   [tmpPath setIsFilled:YES];
   [_model addObject:tmpPath];
   [tmpPath release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}

- (void)addFilledRect:(NSRect)aRect
{
   // FIXME: This could (should) be implemented by a separate class, using NSDrawFilledRect(List)
   // to improve drawing speed. 
   NSPoint pointList[4]={
      NSMakePoint(NSMinX(aRect), NSMinY(aRect)),
      NSMakePoint(NSMaxX(aRect), NSMinY(aRect)),
      NSMakePoint(NSMaxX(aRect), NSMaxY(aRect)),
      NSMakePoint(NSMinX(aRect), NSMaxY(aRect))};
   // [self eraseRect:aRect];
   [self addPolygonWithPoints:pointList pointCount:4];
}
//
// AQTImage
//
- (void)setImageTransform:(AQTAffineTransformStruct)trans
{
   _transform = trans;
}

- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
   AQTImage *tmpImage = [[AQTImage alloc] initWithBitmap:bitmap size:bitmapSize bounds:destBounds];
   [tmpImage setClipRect:_clipRect];
   [tmpImage setIsClipped:_isClipped];
   [_model addObject:tmpImage];
   [tmpImage release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}

// FIXME: Deprecated form, rewrite AQTImage
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds
{
   // FIXME: Bounds either needs to be transformed bounds or NOT tested for in AQTDrawingMethods
   AQTImage *tmpImage = [[AQTImage alloc] initWithBitmap:bitmap size:bitmapSize bounds:NSZeroRect];
   [tmpImage setTransform:_transform];
   [tmpImage setClipRect:destBounds]; // Override _clipRect to restore old behaviour
   [tmpImage setIsClipped:YES];
   [_model addObject:tmpImage];
   [tmpImage release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}

- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize
{
   [self addTransformedImageWithBitmap:bitmap size:bitmapSize clipRect:_clipRect];
}
@end
