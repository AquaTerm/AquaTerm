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
    _fontName = @"Times-Roman";
    _fontSize = 14.0;
    _linewidth = .2;
    _transform.m11 = 1.0;
    _transform.m22 = 1.0;
  }
  return self;
}

- (void)dealloc
{
   NSLog(@"Builder says bye bye!");
   [_handler release];
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

- (void)setHandler:(id)newHandler
{
   [newHandler retain];
   [_handler release];
   _handler = newHandler;
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

- (void)render
{
   if (_modelIsDirty)
   {
      NS_DURING
         [_handler setModel:_model];
      NS_HANDLER
         if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
             // [self _serverError]; Grab from AQTAdapterPrivateMethods
            NSLog(@"Server error");
         else
            [localException raise];
      NS_ENDHANDLER
   }
}

- (void)setAcceptingEvents:(BOOL)flag
{
   _acceptingEvents = flag;
   NS_DURING
      [_handler setAcceptingEvents:flag];
   NS_HANDLER
      if ([[localException name] isEqualToString:@"NSInvalidSendPortException"])
         // [self _serverError]; Grab from AQTAdapterPrivateMethods
         NSLog(@"Server error");
      else
         [localException raise];
   NS_ENDHANDLER   
}

- (void)processEvent:(NSString *)event
{
   NSLog(@"builder got event: %@", event);
/*
 if (_eventHandler != nil)
   {
      _eventHandler(event);
   }
*/
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
  if (pc > MAX_PATH_POINTS)
    NSLog(@"Path too long (%d)", pc);	// FIXME: take action here!
  tmpPath = [[AQTPath alloc] initWithPoints:_path pointCount:_pointCount]; // color:_color];
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
  if (pc > MAX_PATH_POINTS)
    NSLog(@"Path too long (%d)", pc);	// FIXME: take action here!
  tmpPatch = [[AQTPatch alloc] initWithPoints:points pointCount:pc];// color:_color];
  [tmpPatch setColor:_color];
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
