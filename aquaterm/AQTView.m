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
#import "AQTPatch.h"
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
-(void)awakeFromNib
{
  NSImage *curImg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Cross" ofType:@"tiff"]];
  crosshairCursor = [[NSCursor alloc] initWithImage:curImg hotSpot:NSMakePoint(7,7)];
  [curImg release];
  [self setMouseIsActive:YES];
}

-(void)dealloc
{
  [super dealloc];
}

-(BOOL)acceptsFirstResponder
{
  return YES;
}

-(void)setModel:(AQTModel *)newModel
{
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
  return ![NSGraphicsContext currentContextDrawingToScreen]; //isPrinting;
}

/*
 -(void)setIsPrinting:(BOOL)flag
{
  isPrinting = flag;
}
*/

- (BOOL)mouseIsActive
{
  return _mouseIsActive;
}

- (void)setMouseIsActive:(BOOL)flag
{
  _mouseIsActive = flag;
  [[self window] invalidateCursorRectsForView:self];
}

-(void)resetCursorRects
{
  if ([self mouseIsActive])
  {
    [self addCursorRect:[self bounds] cursor:crosshairCursor];
  }
}

- (NSPoint)_convertToCanvasCoordinatesFromPoint:(NSPoint) aPoint
{
  NSAffineTransform *localTransform = [NSAffineTransform transform];
  [localTransform scaleXBy:[model canvasSize].width/NSWidth([self bounds])
                       yBy:[model canvasSize].height/NSHeight([self bounds])];

  return [localTransform transformPoint:aPoint]; 
}
-(void)mouseDown:(NSEvent *)theEvent
{
   NSPoint pos;
   char aKey = '\0';
  //NSLog(NSStringFromPoint([theEvent locationInWindow]));
  if (![self mouseIsActive])
  {
    return;
  }
  // Inform the delegate...
  pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  switch([theEvent type])
  {
    case NSLeftMouseDown:
       aKey = 'A';
       //      NSLog(@"A");
      break;
    case NSRightMouseDown:
       aKey = 'X';
       //      NSLog(@"X");
      break;
    default:
      NSLog(@"Other key");
      break;
  }
  [[[self window] delegate] mouseDownAt:[self _convertToCanvasCoordinatesFromPoint:pos] key:aKey];
}

-(void)keyDown:(NSEvent *)theEvent
{
  NSPoint pos;
   NSRect viewBounds = [self bounds];
   char aKey;
  NSLog([theEvent characters]);
  aKey = [[theEvent characters] UTF8String][0];
//  NSLog(NSStringFromPoint([[self window] mouseLocationOutsideOfEventStream]));
  pos = [self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil];
  NSLog(NSStringFromPoint(pos));
  if (!NSPointInRect(pos, viewBounds))
  {
     // Just crop it to be inside [self bounds];
     if (pos.x < 0 )
        pos.x = 0;
     else if (pos.x > NSWidth(viewBounds))
        pos.x = NSWidth(viewBounds);
     if (pos.y < 0 )
        pos.y = 0;
     else if (pos.y > NSHeight(viewBounds))
        pos.y = NSHeight(viewBounds);
  }
  NSLog(NSStringFromPoint(pos));
  [[[self window] delegate] mouseDownAt:[self _convertToCanvasCoordinatesFromPoint:pos] key:aKey];
}

-(void)drawRect:(NSRect)aRect // FIXME: Consider dirty rect!!! 
{
  AQTColor canvasColor = [model color]; 
  NSRect scaledBounds = [self bounds];	// Depends on whether we're printing or drawing to screen
  NSAffineTransform *localTransform = [NSAffineTransform transform];
//  [localTransform translateXBy:.5 yBy:.5];
  [localTransform scaleXBy:NSWidth(scaledBounds)/[model canvasSize].width
                       yBy:NSHeight(scaledBounds)/[model canvasSize].height];
  [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone]; // FIXME: user prefs
  [[NSGraphicsContext currentContext] setShouldAntialias:YES]; // FIXME: user prefs
  if (![self isPrinting])
  {
    //
    // Erase by drawing background color
    //
    [[NSColor colorWithCalibratedRed:canvasColor.red green:canvasColor.green blue:canvasColor.blue alpha:1.0] set];
    [[NSBezierPath bezierPathWithRect:scaledBounds] fill];
  }
  //
  // Tell the model to draw itself
  //
  [localTransform set];
  [model renderInRect:scaledBounds];
}

@end

@implementation AQTGraphic (AQTGraphicDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
  NSLog(@"Error: *** AQTGraphicDrawing ***");
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
  NSDate *startTime=  [NSDate date];
  NSRect debugRect;
  NSAffineTransform *localTransform = [NSAffineTransform transform];
  [localTransform scaleXBy:NSWidth(boundsRect)/canvasSize.width
                       yBy:NSHeight(boundsRect)/canvasSize.height];
  
  while ((graphic = [enumerator nextObject]))
  {
     [graphic renderInRect:boundsRect];
#ifdef DEBUG_BOUNDS
     [[NSColor yellowColor] set];
     debugRect = [graphic bounds];
     [NSBezierPath strokeRect:debugRect];
#endif
  }
#ifdef DEBUG_BOUNDS
  [[NSColor redColor] set];
  debugRect = [self bounds];
  [NSBezierPath strokeRect:debugRect];
#endif
  NSLog(@"Render time: %f for %d objects", -[startTime timeIntervalSinceNow], [modelObjects count]);
}
@end

@implementation AQTLabel (AQTLabelDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
  NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  NSSize boundingBox;
    int i, l = [tmpString length];
  float xScale = boundsRect.size.width/canvasSize.width; // get scale changes wrt max size
  float yScale = boundsRect.size.height/canvasSize.height;
  float fontScale = sqrt(0.5*(xScale*xScale + yScale*yScale));
  float fontsize = [[[string attributesAtIndex:0 effectiveRange:nil] objectForKey:@"AQTFontsizeKey"] floatValue];
  NSFont *tmpFont = [NSFont fontWithName:[[string attributesAtIndex:0 effectiveRange:nil] objectForKey:@"AQTFontnameKey"]
                                    size:fontsize];
  //
  // Scale the string FIXME: Speed up by using effective range!
  //
/*
 for (i=0;i<l;i++)
  {
    [tmpString addAttribute:NSFontAttributeName
                      value:[NSFont fontWithName:[tmpFont fontName] size:MAX([tmpFont pointSize]*fontScale, AQT_MIN_FONTSIZE)] 				 					  range:NSMakeRange(i,1)];
  }
  */
  [tmpString addAttribute:NSFontAttributeName value:tmpFont range:NSMakeRange(0, [tmpString length])];
  [tmpString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] range:NSMakeRange(0, [tmpString length])];
  boundingBox = [tmpString size];
  {
  NSAffineTransform *transf = [NSAffineTransform transform];
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  //
  // Position local coordinate system and apply justification
  //
  [transf translateXBy:position.x yBy:position.y];	// get translated origin
  [transf rotateByDegrees:angle];
  [transf translateXBy:-justification*boundingBox.width/2 yBy:-boundingBox.height/2];
  [context saveGraphicsState];
  [transf concat];
  [tmpString drawAtPoint:NSMakePoint(0,0)];
  [context restoreGraphicsState];
  }
  [tmpString release];
}
@end



@implementation AQTPath (AQTPathDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
   if (pointCount == 0)
      return;
   if (![self _cache])
   {
      NSBezierPath *scratch = [NSBezierPath bezierPath];
      [scratch appendBezierPathWithPoints:path count:pointCount];
      [scratch setLineJoinStyle:NSRoundLineJoinStyle];
      [scratch setLineCapStyle:lineCapStyle];
      [scratch setLineWidth:linewidth];
      [self _setCache:scratch];
   }
   [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
   [_cache stroke];
}
@end

@implementation AQTPatch (AQTPatchDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
  if (pointCount == 0)
    return;
  if (![self _cache])
  {
    NSBezierPath *scratch = [NSBezierPath bezierPath];
    [scratch appendBezierPathWithPoints:path count:pointCount];
    [scratch setLineWidth:linewidth];
    [scratch closePath];
    [self _setCache:scratch];
  }
  [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
// [_cache stroke];	// FIXME: Needed unless we holes in the surface?
  [_cache fill];
}
@end


@implementation AQTImage (AQTImageDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
  if (![self _cache])
  {
    // Install an NSImage in _cache
    const unsigned char *theBytes = [bitmap bytes]; 
    NSImage *tmpImage = [[NSImage alloc] initWithSize:bitmapSize];
    NSBitmapImageRep *tmpBitmap =
      [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&theBytes
                                              pixelsWide:bitmapSize.width
                                              pixelsHigh:bitmapSize.height
                                           bitsPerSample:8
                                         samplesPerPixel:3
                                                hasAlpha:NO
                                                isPlanar:NO
                                          colorSpaceName:NSDeviceRGBColorSpace
                                             bytesPerRow:3*bitmapSize.width
                                            bitsPerPixel:24];
    [tmpImage addRepresentation:tmpBitmap];
    [self _setCache:tmpImage];
    [tmpImage release];
    [tmpBitmap release];
  }
  {
    NSAffineTransform *transf = [NSAffineTransform transform];
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    NSAffineTransformStruct tmpStruct;
    tmpStruct.m11 = transform.m11;
    tmpStruct.m12 = transform.m12;
    tmpStruct.m21 = transform.m21;
    tmpStruct.m22 = transform.m22;
    tmpStruct.tX = transform.tX;
    tmpStruct.tY = transform.tY;
    //
    // Position local coordinate system and apply justification
    //
    [context saveGraphicsState];
    [NSBezierPath clipRect:_bounds];
    [transf setTransformStruct:tmpStruct];
    [transf invert];
    [transf concat];
/*   [_cache drawInRect:_bounds
             fromRect:NSMakeRect(0,0,[_cache size].width,[_cache size].height)
            operation:NSCompositeSourceOver
             fraction:1.0];
*/
    [_cache setFlipped:YES];
   [_cache drawAtPoint:NSMakePoint(0,0)
              fromRect:NSMakeRect(0,0,[_cache size].width,[_cache size].height)
             operation:NSCompositeSourceOver
              fraction:1.0];
    [context restoreGraphicsState];
  }
  
}
@end

