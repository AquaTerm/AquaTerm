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
#import "AQTAdapter.h"

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

- (BOOL)_flushLineSegmentBuffer
{
   BOOL didFlush = NO;
   if (_pointCount > 1)
   {
      [self addPolylineWithPoints:_path pointCount:_pointCount];
      _pointCount = 0;
      didFlush = YES;
   }
   return didFlush;
}

-(void)_flushBuffers
{
   // Possibly more stuff??
   [self _flushLineSegmentBuffer];
}



- (id)init
{
   if(self = [super init])
   {
      _model = [[AQTModel alloc] initWithSize:NSMakeSize(300,200)];
      [self _aqtPlotBuilderSetDefaultValues];
      _colormap = [[AQTColorMap alloc] initWithColormapSize:AQT_COLORMAP_SIZE];
      _modelIsDirty = YES;
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
      _modelIsDirty = YES;
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

- (void)setColor:(AQTColor)newColor forColormapEntry:(int)entryIndex
{
   [_colormap setColor:newColor forIndex:entryIndex];
}

- (AQTColor)colorForColormapEntry:(int)entryIndex
{
   return [_colormap colorForIndex:entryIndex];
}

- (NSString *)fontname
{
   return _fontName;
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

- (float)fontsize
{
   return _fontSize;
}

- (void)setFontsize:(float)newFontsize
{
   _fontSize = newFontsize;
}

- (float)linewidth
{
   return _linewidth;
}

- (void)setLinewidth:(float)newLinewidth
{
   if (newLinewidth != _linewidth)
   {
      [self _flushLineSegmentBuffer];
      _linewidth = newLinewidth;
   }
}

- (void)setLineCapStyle:(int)capStyle
{
   _capStyle = capStyle;
}

- (void)eraseRect:(NSRect)aRect
{
   [_model removeObjectsInRect:aRect];
   _modelIsDirty = YES; // FIXME: This may not always be true.
}

- (void)render
{
   if (_modelIsDirty)
   {
      [self _flushBuffers];
      NS_DURING
         [_handler setModel:_model];
      NS_HANDLER
         if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
            // [self _serverError]; // FIXME: Grab from AQTAdapterPrivateMethods
            NSLog(@"Server error");
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
   [self _aqtPlotBuilderSetDefaultValues];
   _modelIsDirty = YES;
}


- (void)setAcceptingEvents:(BOOL)flag
{
   _acceptingEvents = flag;
   NS_DURING
      [_handler setAcceptingEvents:flag];
   NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
         // [self _serverError]; // FIXME: Grab from AQTAdapterPrivateMethods
         NSLog(@"Server error");
      else
         [localException raise];
   NS_ENDHANDLER
}


- (void)processEvent:(NSString *)event
{
   [owner processEvent:event]; // FIXME: Needs autoreleasing here???
}

- (NSString *)lastEvent
{
   NS_DURING
      return [[_handler lastEvent] autorelease];
   NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
         // [self _serverError]; // FIXME: Grab from AQTAdapterPrivateMethods
         NSLog(@"Server error");
      else
         [localException raise];
   NS_ENDHANDLER
   return @"0";
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
   //  NSLog([lb description]);
   [lb release];
   _modelIsDirty = YES;
}
//
// AQTPath
//

- (void)moveToPoint:(NSPoint)point
{
   if (_pointCount > 1)
   {
      // Only flush if this creates a disjoint path,
      // if the point is just the latest endpoint, skip it
      if (!NSEqualPoints(point, _path[_pointCount-1]))
      {
         [self _flushLineSegmentBuffer];
         _path[0]=point;
         _pointCount = 1;
      }
   }
   else
   {
      // This is an initial move or a move-after-move case,
      // just accept it
      _path[0]=point;
      _pointCount = 1;
   }
}

- (void)addLineToPoint:(NSPoint)point
{
   _path[_pointCount]=point;
   _pointCount++;
   if (_pointCount == MAX_PATH_POINTS)
   {
      // NSLog(@"---- Reaching path limit (%d) ----", MAX_PATH_POINTS);
      // Split the line
      [self addPolylineWithPoints:_path pointCount:_pointCount];
      _pointCount = 0;
      [self moveToPoint:point];
   }
   _modelIsDirty = YES;
}

- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc
{
   AQTPath *tmpPath;
   tmpPath = [[AQTPath alloc] initWithPoints:_path pointCount:_pointCount];
   [tmpPath setColor:_color];
   [tmpPath setLinewidth:_linewidth];
   [tmpPath setLineCapStyle:_capStyle];
   [_model addObject:tmpPath];
   [tmpPath release];
   _modelIsDirty = YES;
}
//
// AQTPatch
//
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc
{
   AQTPatch *tmpPatch;
   tmpPatch = [[AQTPatch alloc] initWithPoints:points pointCount:pc];
   [tmpPatch setColor:_color];
   [_model addObject:tmpPatch];
   [tmpPatch release];
   _modelIsDirty = YES;

}
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
   _modelIsDirty = YES;
}

- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds
{
   AQTImage *tmpImage = [[AQTImage alloc] initWithBitmap:bitmap size:bitmapSize bounds:destBounds];
   [tmpImage setTransform:_transform];
   [_model addObject:tmpImage];
   [tmpImage release];
   _modelIsDirty = YES;
}
@end
