//
//  AQTPlotBuilder.m
//  AquaTerm
//
//  Created by Per Persson on Sat Aug 16 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import "AQTPlotBuilder.h"
#import "AQTGraphic.h"
#import "AQTModel.h"
#import "AQTLabel.h"
#import "AQTPath.h"
#import "AQTPatch.h"
#import "AQTImage.h"
#import "AQTColorMap.h"

#define AQT_COLORMAP_SIZE 256

@implementation AQTPlotBuilder
- (void)_aqtPlotBuilderSetDefaultValues
{
   _color.red = 0.0;
   _color.green = 0.0;
   _color.blue = 0.0;
   _fontName = @"Times-Roman";
   _fontSize = 14.0;
   _linewidth = 1.0;
   _transform.m11 = 1.0;
   _transform.m22 = 1.0;
}

- (void)_aqtPlotBuilderSetModelIsDirty:(BOOL)isDirty
{
   _modelIsDirty = isDirty;
   // Any coalescing of render call may be performed here (use timer)
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
      _model = [[AQTModel alloc] initWithSize:NSZeroSize]; 
      [self _aqtPlotBuilderSetDefaultValues];
      _colormap = [[AQTColorMap alloc] initWithColormapSize:AQT_COLORMAP_SIZE];
      [self _aqtPlotBuilderSetModelIsDirty:NO];
      _shouldAppend = NO;
   }
   return self;
}

- (void)dealloc
{
   [_handler release];
   [_model release];
   [_colormap release];
   [super dealloc];
}

-(void)setOwner:(id)object
{
   owner = object;
}

- (void)setSize:(NSSize)canvasSize
{
   [_model setSize:canvasSize];
}

- (void)setTitle:(NSString *)title
{
   [_model setTitle:title];
}

- (void)setHandler:(id)newHandler
{
   [newHandler retain];
   [_handler release];
   _handler = newHandler;
}

- (AQTColor)color
{
   return _color;
}

- (void)setColor:(AQTColor)newColor
{
   if ((newColor.red != _color.red) || (newColor.green != _color.green) || (newColor.blue != _color.blue))
   {
      [self _flushBuffers];
      _color = newColor;
   }
}

- (void)setBackgroundColor:(AQTColor)newColor
{
   AQTColor oldColor = [_model color];
   if ((newColor.red != oldColor.red) || (newColor.green != oldColor.green) || (newColor.blue != oldColor.blue))
   {
      [_model setColor:newColor];
      [self _aqtPlotBuilderSetModelIsDirty:YES];
   }
}

- (void)takeColorFromColormapEntry:(int)index
{
   [self setColor:[_colormap colorForIndex:index]];
}

- (void)takeBackgroundColorFromColormapEntry:(int)index
{
   [self setBackgroundColor:[_colormap colorForIndex:index]];   
}

- (int)colormapSize
{
   return [_colormap size];
}

- (void)setColor:(AQTColor)newColor forColormapEntry:(int)entryIndex
{
   [_colormap setColor:newColor forIndex:entryIndex];
}

- (AQTColor)colorForColormapEntry:(int)entryIndex
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
   if (newLinewidth != _linewidth)
   {
      [self _flushPolylineBuffer];
      _linewidth = newLinewidth;
   }
}

- (void)setLineCapStyle:(int)capStyle
{
   _capStyle = capStyle;
}

- (void)eraseRect:(NSRect)aRect
{
   NS_DURING
      [_handler removeGraphicsInRect:aRect];
   NS_HANDLER
      if((nil != owner) && [owner respondsToSelector:@selector(_handlerError:)])
         [owner _handlerError:[localException name]]; 
      else
         [localException raise];
   NS_ENDHANDLER
}

- (void)render
{
   if (_modelIsDirty && !NSEqualSizes([_model canvasSize], NSZeroSize))
   {
      [self _flushBuffers];
      [self _aqtPlotBuilderSetModelIsDirty:NO];
      NS_DURING
         if (_shouldAppend == YES)
         {
            [_handler appendPlot:_model];
            if([_handler isProxy])
               [_model removeAllModelObjects];
         }
         else
         {
            [_handler setPlot:_model];
            if([_handler isProxy])
               [_model removeAllModelObjects];
            if(NSEqualSizes([_model canvasSize], NSZeroSize) == NO)
            {
               _shouldAppend = YES;
            }
         }
      NS_HANDLER
         if((nil != owner) && [owner respondsToSelector:@selector(_handlerError:)])
            [owner _handlerError:[localException name]]; 
         else
            [localException raise];
      NS_ENDHANDLER
   }
}

- (void)clearAll
{
   // Honor size, title and background color
   AQTModel *newModel = [[AQTModel alloc] initWithSize:[_model size]];
   [newModel setTitle:[_model title]];
   [newModel setColor:[_model color]];
   [_model release];
   _model = newModel;
   [self _aqtPlotBuilderSetDefaultValues]; // FIXME: colormap etc. too
   [self _aqtPlotBuilderSetModelIsDirty:YES];
   _shouldAppend = NO;
   [self render];
}


- (void)setAcceptingEvents:(BOOL)flag
{
   NS_DURING
      [_handler setAcceptingEvents:flag];
   NS_HANDLER
      if((nil != owner) && [owner respondsToSelector:@selector(_handlerError:)])
         [owner _handlerError:[localException name]]; 
      else
         [localException raise];
   NS_ENDHANDLER
}


- (void)processEvent:(NSString *)event
{
   [owner processEvent:event sender:self]; // FIXME: Needs autoreleasing here???
}

//
// AQTLabel
//
- (void)addLabel:(id)text position:(NSPoint)pos angle:(float)angle justification:(int)just
{
   AQTLabel *lb;
   if ([text isKindOfClass:[NSString class]])
   {
      lb = [[AQTLabel alloc] initWithString:text
                                   position:pos
                                      angle:angle
                              justification:just];
   }
   else
   {
      if ([text isKindOfClass:[NSAttributedString class]])
      {
         lb = [[AQTLabel alloc] initWithAttributedString:text
                                                position:pos
                                                   angle:angle
                                           justification:just];
      }
      else
      {
         NSLog(@"Error, not a string.");
      }
   }
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

- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc
{
   AQTPath *tmpPath;
   tmpPath = [[AQTPath alloc] initWithPoints:points pointCount:pc];
   [tmpPath setColor:_color];
   [tmpPath setLinewidth:_linewidth];
   [tmpPath setLineCapStyle:_capStyle];
   [_model addObject:tmpPath];
   [tmpPath release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}
/*
- (void)addPolylineWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc
{
   AQTPath *tmpPath;
   tmpPath = [[AQTPath alloc] initWithXCoords:x yCoords:y pointCount:pc];
   [tmpPath setColor:_color];
   [tmpPath setLinewidth:_linewidth];
   [tmpPath setLineCapStyle:_capStyle];
   [_model addObject:tmpPath];
   [tmpPath release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}
*/
//
// AQTPatch
//

- (void)moveToVertexPoint:(NSPoint)point
{
   if (_polygonPointCount > 1)
   {
      // Only flush if this creates a disjoint path,
      // if the point is just the latest endpoint, skip it
      if (!NSEqualPoints(point, _polygonPoints[_polygonPointCount-1]))
      {
         [self _flushPolygonBuffer];
         _polygonPoints[0]=point;
         _polygonPointCount = 1;
      }
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

- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc
{
   AQTPatch *tmpPatch;
   tmpPatch = [[AQTPatch alloc] initWithPoints:points pointCount:pc];
   [tmpPatch setColor:_color];
   [_model addObject:tmpPatch];
   [tmpPatch release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}
/*
- (void)addPolygonWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc
{
   AQTPatch *tmpPatch;
   tmpPatch = [[AQTPatch alloc] initWithXCoords:x yCoords:y pointCount:pc];
   [tmpPatch setColor:_color];
   [_model addObject:tmpPatch];
   [tmpPatch release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}
*/

- (void)addFilledRect:(NSRect)aRect
{
   // FIXME: This could (should) be implemented by a separate class, using NSDrawFilledRect(List)
   // to improve drawing speed. For now, use AQTPatch
   NSPoint pointList[4]={
      NSMakePoint(NSMinX(aRect), NSMinY(aRect)),
      NSMakePoint(NSMaxX(aRect), NSMinY(aRect)),
      NSMakePoint(NSMaxX(aRect), NSMaxY(aRect)),
      NSMakePoint(NSMinX(aRect), NSMaxY(aRect))};
   [self eraseRect:aRect];
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
   [_model addObject:tmpImage];
   [tmpImage release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}

- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds
{
   AQTImage *tmpImage = [[AQTImage alloc] initWithBitmap:bitmap size:bitmapSize bounds:destBounds];
   [tmpImage setTransform:_transform];
   [_model addObject:tmpImage];
   [tmpImage release];
   [self _aqtPlotBuilderSetModelIsDirty:YES];
}
@end
