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
  [self setIsProcessingEvents:NO];
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

- (BOOL)isProcessingEvents
{
  return _isProcessingEvents;
}

- (void)setIsProcessingEvents:(BOOL)flag
{
  _isProcessingEvents = flag;
  [[self window] invalidateCursorRectsForView:self];
}

-(void)resetCursorRects
{
  if ([self isProcessingEvents])
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
  if ([self isProcessingEvents])
  {
    NSString *eventString;
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    char aKey = '\0';
    // Inform the delegate...
    switch([theEvent type])
    {
      // Do some stuff here...
      case NSLeftMouseDown:
        // aKey = 'A';
        break;
      case NSRightMouseDown:
        // aKey = 'X';
        break;
      default:
        NSLog(@"Other key");
        break;
    }
    eventString = [NSString stringWithFormat:@"1:%@:misc", NSStringFromPoint([self _convertToCanvasCoordinatesFromPoint:pos])];
    [[[self window] delegate] setLastEvent:eventString];
  }
}

-(void)keyDown:(NSEvent *)theEvent
{
  if ([self isProcessingEvents])
  {
    NSString *eventString;
    NSPoint pos = [self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil];
    NSRect viewBounds = [self bounds];
    char aKey = [[theEvent characters] UTF8String][0];;
    // NSLog([theEvent characters]);
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
    eventString = [NSString stringWithFormat:@"2:%@:%c", NSStringFromPoint([self _convertToCanvasCoordinatesFromPoint:pos]), aKey];
    [[[self window] delegate] setLastEvent:eventString];
  }
}

-(void)drawRect:(NSRect)aRect // FIXME: Consider dirty rect!!! 
{
  AQTColor canvasColor = [model color]; 
  NSRect scaledBounds = [self bounds];	// Depends on whether we're printing or drawing to screen
  NSAffineTransform *localTransform = [NSAffineTransform transform];
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
//  NSRect debugRect;
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
   NSSize boundingBox;
   if (![self _cache])
   {
      int i = 0;
      NSRange fullRange, effRange;
      
      _cache = [[NSMutableAttributedString alloc] initWithAttributedString:string];
      fullRange = NSMakeRange (0, [(NSAttributedString *)_cache length]);
      [_cache addAttribute:NSFontAttributeName
                     value:[NSFont fontWithName:fontName size:fontSize]
                     range:fullRange];
      [_cache addAttribute:NSForegroundColorAttributeName
                     value:[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0]
                     range:fullRange];
      //
      // Fix sub/superscript appearance
      //
      while(i < fullRange.length)
      {
         id attrValue = [_cache attribute:NSSuperscriptAttributeName
                                  atIndex:i
                    longestEffectiveRange:&effRange
                                  inRange:fullRange];
         if (attrValue)
         {
            float subcriptLevel = [attrValue floatValue]; 
            [_cache addAttribute:NSFontAttributeName
                           value:[NSFont fontWithName:fontName size:fontSize*0.75]
                           range:effRange];
            [_cache addAttribute:NSBaselineOffsetAttributeName
                           value:[NSNumber numberWithFloat:-subcriptLevel*fontSize*0.1]
                           range:effRange];
                        
         }
         i += effRange.length;
      }
   }
   boundingBox = [_cache size];
   //NSLog([tmpString description]);
   {
      NSAffineTransform *transf = [NSAffineTransform transform];
      NSGraphicsContext *context = [NSGraphicsContext currentContext];
      //
      // Position local coordinate system and apply justification
      //
      [transf translateXBy:position.x yBy:position.y];	
      [transf rotateByDegrees:angle];
      [transf translateXBy:-justification*boundingBox.width/2.0 yBy:-boundingBox.height/2.0];
      [context saveGraphicsState];
      [transf concat];
      [(NSAttributedString *)_cache drawAtPoint:NSMakePoint(0.0, 0.0)];
      [context restoreGraphicsState];
   }
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
   if (fitBounds == YES)
   {
      [_cache drawInRect:_bounds
                fromRect:NSMakeRect(0,0,[_cache size].width,[_cache size].height)
               operation:NSCompositeSourceOver
                fraction:1.0];
   }
   else
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

      [context saveGraphicsState];
      [NSBezierPath clipRect:_bounds];
      [transf setTransformStruct:tmpStruct];
      [transf concat];
      [_cache drawAtPoint:NSMakePoint(0,0)
                 fromRect:NSMakeRect(0,0,[_cache size].width,[_cache size].height)
                operation:NSCompositeSourceOver
                 fraction:1.0];
      [context restoreGraphicsState];
   }
}
@end

