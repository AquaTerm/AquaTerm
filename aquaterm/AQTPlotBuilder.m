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
}

- (AQTModel *)model
{
  return _model;
}
- (BOOL)modelIsDirty
{
  return _modelIsDirty; 
}
/*
 - (AQTColor)color {
   return _color;
 }
 */
- (void)setColorRed:(float)r green:(float)g blue:(float)b
{
  _color.red = r;
  _color.green = g;
  _color.blue = b;
}
/*
 - (void)setColor:(AQTColor)newColor
 {
   _color = newColor;
 }
 */
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
  _linewidth = newLinewidth;
}
- (void)eraseRect:(NSRect)aRect
{
  [[self model] removeObjectsInRect:aRect];
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
  [[self model] addObject:lb];
  [lb release];
  _modelIsDirty = YES;
}
//
// AQTPath
//
- (void)addLineAtPoint:(NSPoint)point
{
  if (_pointCount > 1)
  {
    AQTPath *tmpPath = [[AQTPath alloc] initWithPoints:_path pointCount:_pointCount color:_color];
    [tmpPath setLinewidth:_linewidth];
    [[self model] addObject:tmpPath];
    [tmpPath release];
  }
  _path[0]=point;
  _pointCount = 1;
  _modelIsDirty = YES;
}

- (void)appendLineToPoint:(NSPoint)point
{
  _path[_pointCount]=point;
  _pointCount++;
  if (_pointCount == MAX_PATH_POINTS)
  {
    [self addLineAtPoint:point];
  }
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
  [[self model] addObject:tmpPatch];
  [tmpPatch release];
  _modelIsDirty = YES;

}
//
// AQTImage
//
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
  AQTImage *tmpImage = [[AQTImage alloc] initWithBitmap:bitmap size:bitmapSize bounds:destBounds];
  [[self model] addObject:tmpImage];
  [tmpImage release];
  _modelIsDirty = YES;

}
@end
