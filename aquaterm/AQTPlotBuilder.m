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


@implementation AQTPlotBuilder
- (id)init
{
  if(self = [super init])
  {
    // Default values:
    AQTModel *nilModel = [[AQTModel alloc] initWithSize:NSMakeSize(300,200)];
    [self setModel:nilModel];
    [nilModel release];
    _modelIsDirty = NO;
    _color.red = 0.0;
    _color.green = 0.0;
    _color.blue = 0.0;
    _fontname = @"Times-Roman";
    _fontsize = 18.0;
    _linewidth = .2;    
  }
  return self;
}

- (void)dealloc
{
  [_model release];
  [super dealloc];
}

- (void)setModel:(AQTModel *)newModel
{
  [newModel retain];
  [_model release];
  _model = newModel;
  _modelIsDirty = YES;
}

- (AQTModel *)model
{
  // FIXME: Flush buffers before returning the model
  [self flushBuffers];
  _modelIsDirty = NO;
  return _model;
}
- (BOOL)modelIsDirty
{
  return _modelIsDirty; 
}

-(void)flushBuffers
{
  [self _flushLineSegmentBuffer];
}

- (void)setSize:(NSSize)canvasSize
{
  [_model setSize:canvasSize];
}

- (void)setTitle:(NSString *)title
{
  [_model setTitle:title];  
}

 - (AQTColor)color {
   return _color;
 }

 - (void)setColor:(AQTColor)newColor
{
  if ((newColor.red != _color.red) || (newColor.green != _color.green) || (newColor.blue != _color.blue))
  {
    [self flushBuffers];
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


- (NSString *)fontname
{
  return _fontname;
}

- (void)setFontname:(NSString *)newFontname
{
  if (_fontname != newFontname)
  {
    NSString *oldValue = _fontname;
    _fontname = [newFontname retain];
    [oldValue release];
  }
}

- (float)fontsize
{
  return _fontsize;
}

- (void)setFontsize:(float)newFontsize
{
  _fontsize = newFontsize;
}

- (float)linewidth
{
  return _linewidth;
}

- (void)setLinewidth:(float)newLinewidth
{
  if (newLinewidth != _linewidth)
  {
    [self flushBuffers];
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

//
// AQTLabel
//
- (void)addLabel:(NSString *)text position:(NSPoint)pos angle:(float)angle justification:(int)just
{
  AQTLabel *lb = [[AQTLabel alloc] initWithAttributedString:[[[NSAttributedString  alloc] initWithString:text] autorelease]
                                                   position:pos
                                                      angle:angle
                                              justification:just];
  [_model addObject:lb];
  [lb release];
  _modelIsDirty = YES;
}
//
// AQTPath
//
- (BOOL)_flushLineSegmentBuffer
{
  BOOL didFlush = NO;
  if (_pointCount > 1)
  {
    [self addPolylineWithPoints:_path pointCount:_pointCount];
    didFlush = YES;
  }
  _pointCount = 0;
  return didFlush;
}

- (void)moveToPoint:(NSPoint)point
{
  if (_pointCount > 1)
  {
    [self _flushLineSegmentBuffer];
  }
  _path[0]=point;
  _pointCount = 1;
  _modelIsDirty = YES;
}

- (void)addLineToPoint:(NSPoint)point
{
  _path[_pointCount]=point;
  _pointCount++;
  if (_pointCount == MAX_PATH_POINTS)
  {
    [self moveToPoint:point];
  }
  _modelIsDirty = YES;
}

- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int)pc
{
  AQTPath *tmpPath = [[AQTPath alloc] initWithPoints:_path pointCount:_pointCount color:_color];
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
  if (pc > MAX_PATH_POINTS)
    NSLog(@"Path too long (%d)", pc);	// FIXME: take action here!
  tmpPatch = [[AQTPatch alloc] initWithPoints:points pointCount:pc color:_color];
  [_model addObject:tmpPatch];
  [tmpPatch release];
  _modelIsDirty = YES;

}
- (void)addFilledRect:(NSRect)aRect
{
  // This could (should) be implemented by a separate class, using NSDrawFilledRect(List)
  // to improve drawing speed. For now, use AQTPatch
  NSPoint pointList[4]={
    NSMakePoint(NSMinX(aRect), NSMinY(aRect)),
    NSMakePoint(NSMaxX(aRect), NSMinY(aRect)),
    NSMakePoint(NSMaxX(aRect), NSMaxY(aRect)),
    NSMakePoint(NSMinX(aRect), NSMaxY(aRect))};
  [self addPolygonWithPoints:pointList pointCount:4];
}
//
// AQTImage
//
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
  AQTImage *tmpImage = [[AQTImage alloc] initWithBitmap:bitmap size:bitmapSize bounds:destBounds];
  [_model addObject:tmpImage];
  [tmpImage release];
  _modelIsDirty = YES;

}
@end
