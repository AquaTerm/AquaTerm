//
//  AQTView.m
//  AquaTerm
//
//  Created by Per Persson on Wed Apr 17 2002.
//  Copyright (c) 2001 AquaTerm. All rights reserved.
//

#import "AQTView.h"
#import "AQTGraphic.h"
#import "AQTLabel.h"
#import "AQTModel.h"
#import "AQTPath.h"
#import "AQTImage.h"
//#import "AQTColorMap.h"

#define AQT_MIN_FONTSIZE 9.0

//#define MAX(a, b) ((a)>(b)?(a):(b))

@interface AQTGraphic (AQTGraphicDrawing)
-(id)_cache;
-(void)_setCache:(id)object;
-(void)renderInRect:(NSRect)boundsRect;
@end


@implementation AQTView

-(void)dealloc
{
  [model release];
  [super dealloc];
}

-(void)setModel:(AQTModel *)newModel
{
  [newModel retain];
  [model release];
  model = newModel;
}

- (AQTModel *)model
{
  return model;
}

-(BOOL)isOpaque
{
  return YES;
}

-(BOOL)isPrinting
{
  return isPrinting;
}

-(void)setIsPrinting:(BOOL)flag
{
  isPrinting = flag;
}

-(void)drawRect:(NSRect)aRect
{
  AQTColor canvasColor = [model color]; 
  NSRect theBounds = [self bounds];	// Depends on whether we're printing or drawing to screen
  if (!isPrinting)
  {
    //
    // Erase by drawing background color
    //
    [[NSColor colorWithCalibratedRed:canvasColor.red green:canvasColor.green blue:canvasColor.blue alpha:1.0] set];
    [[NSBezierPath bezierPathWithRect:theBounds] fill];
  }
  //
  // Tell the model to draw itself
  //
  [model renderInRect:theBounds];
}

@end

@implementation AQTGraphic (AQTGraphicDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
  // Not purely abstract, draw a filled box to indicate trouble;-)
  [[NSColor redColor] set];
  [NSBezierPath fillRect:boundsRect];
}

-(void)_setCache:(id)object
{
   [object retain];
   [_cache release];
   _cache = object;
}

-(id)_cache
{
   return _cache;
}

@end

/**"
*** Tell every object in the collection to draw itself.
"**/
@implementation AQTModel (AQTModelDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
  AQTGraphic *graphic;
  NSEnumerator *enumerator = [modelObjects objectEnumerator];
  NSDate		*startTime=  [NSDate date];

  while ((graphic = [enumerator nextObject]))
  {
    [graphic renderInRect:boundsRect];
#ifdef DEBUG_BOUNDS
     [[NSColor yellowColor] set];
     [NSBezierPath strokeRect:[graphic bounds]];
#endif
  }
#ifdef DEBUG_BOUNDS
  [[NSColor redColor] set];
  [NSBezierPath strokeRect:[self bounds]];
#endif
  NSLog(@"Render time: %f", -[startTime timeIntervalSinceNow]);
}
@end

@implementation AQTLabel (AQTLabelDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
  NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  NSAffineTransform *transf = [NSAffineTransform transform];
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  NSSize boundingBox;
  int i, l = [tmpString length];
  float xScale = boundsRect.size.width/canvasSize.width; // get scale changes wrt max size
  float yScale = boundsRect.size.height/canvasSize.height;
  float fontScale = sqrt(0.5*(xScale*xScale + yScale*yScale));
  //
  // Scale the string FIXME: Speed up by using effective range!
  //
  for (i=0;i<l;i++)
  {
    NSFont *tmpFont = [[tmpString attributesAtIndex:i effectiveRange:nil] objectForKey:NSFontAttributeName];
    [tmpString addAttribute:NSFontAttributeName
                      value:[NSFont fontWithName:[tmpFont fontName] size:MAX([tmpFont pointSize]*fontScale, AQT_MIN_FONTSIZE)] 				 					  range:NSMakeRange(i,1)];
  }
  boundingBox = [tmpString size];
  //
  // Position local coordinate system and apply justification
  //
  [transf translateXBy:xScale*position.x yBy:yScale*position.y];	// get translated origin
  [transf rotateByDegrees:angle];
  [transf translateXBy:-justification*boundingBox.width/2 yBy:-boundingBox.height/2];
  [context saveGraphicsState];
  [transf concat];
  [tmpString drawAtPoint:NSMakePoint(0,0)];
  [context restoreGraphicsState];

  [tmpString release];
}
@end


@implementation AQTPath (AQTPathDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
   NSBezierPath *scratch;// = [NSBezierPath bezierPath];
   NSAffineTransform *localTransform = [NSAffineTransform transform];
   float xScale = boundsRect.size.width/canvasSize.width;
   float yScale = boundsRect.size.height/canvasSize.height;
   //
   // Get the transform due to view resizing
   //
   if (pointCount == 0)
      return;
   if (![self _cache])
   {
      scratch = [NSBezierPath bezierPath];
      [scratch appendBezierPathWithPoints:path count:pointCount];
      [self _setCache:scratch];
   }
   [localTransform scaleXBy:xScale yBy:yScale];
   [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
   if (isFilled)
   {
      [[localTransform transformBezierPath:_cache] fill];
   }
   [[localTransform transformBezierPath:_cache] stroke];	// FAQ: Needed unless we holes in the surface?
}
@end

@implementation AQTImage (AQTImageDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
  NSAffineTransform *localTransform = [NSAffineTransform transform];
  NSRect scaledBounds = [self bounds];
  float xScale = boundsRect.size.width/canvasSize.width;
  float yScale = boundsRect.size.height/canvasSize.height;
  //
  // Get the transform due to view resizing
  //
  [localTransform scaleXBy:xScale yBy:yScale];
  scaledBounds.size = [localTransform transformSize:scaledBounds.size];
  scaledBounds.origin = [localTransform transformPoint:scaledBounds.origin];
  [image drawInRect:scaledBounds fromRect:NSMakeRect(0,0,[image size].width,[image size].height) operation:NSCompositeSourceOver fraction:1.0];
}
@end

