//
//  AQTGraphicDrawingMethods.m
//  AquaTerm
//
//  Created by Per Persson on Mon Oct 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "AQTGraphicDrawingMethods.h"

#import "AQTLabel.h"
#import "AQTPath.h"
#import "AQTPatch.h"
#import "AQTImage.h"

@implementation AQTGraphic (AQTGraphicDrawingMethods)
-(void)renderInRect:(NSRect)boundsRect
{
   NSLog(@"Error: *** AQTGraphicDrawing ***");
}

-(NSRect)updateBounds
{
   return _bounds; // Default is to do nothing.
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
-(NSRect)updateBounds
{
   NSRect tmpRect = NSZeroRect;
   AQTGraphic *graphic;
   NSEnumerator *enumerator = [modelObjects objectEnumerator];
   while ((graphic = [enumerator nextObject]))
   {
      NSRect graphRect = [graphic updateBounds];
      if (NSWidth(graphRect) < 0.0001 || NSHeight(graphRect) < 0.0001)
      {
         NSLog(@"**** Zero/neg W/H! : %@", [graphic description]);
      }
      tmpRect = NSUnionRect(tmpRect, graphRect);
   }
   [self setBounds:tmpRect];
   return tmpRect;
}

-(void)renderInRect:(NSRect)dirtyRect
{
   AQTGraphic *graphic;
   NSEnumerator *enumerator = [modelObjects objectEnumerator];
#ifdef TIMING
   static float totalTime = 0.0;
   float thisTime;
   NSDate *startTime = [NSDate date];
#endif
   NSRect debugRect;

   // Model object is responsible for background...
   [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
   NSRectFill(dirtyRect);

   while ((graphic = [enumerator nextObject]))
   {
      [graphic renderInRect:dirtyRect];
#ifdef DEBUG_BOUNDS
      [[NSColor greenColor] set];
      debugRect = [graphic bounds];
      [NSBezierPath strokeRect:debugRect];
#endif
   }
#ifdef DEBUG_BOUNDS
   [[NSColor redColor] set];
   debugRect = [self bounds];
   [NSBezierPath strokeRect:debugRect];
#endif
#ifdef TIMING
   thisTime = -[startTime timeIntervalSinceNow];
   totalTime += thisTime;
   NSLog(@"Render time: %f for %d objects. Total: %f", thisTime, [modelObjects count], totalTime);
#endif
}
@end

@implementation AQTLabel (AQTLabelDrawing)
-(void)_aqtLabelUpdateCache
{
   int i = 0;
   NSRange fullRange, effRange;

   [_cache release];
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

-(NSRect)updateBounds
{
    NSAffineTransform *tempTrans = [NSAffineTransform transform];
    NSRect tempBounds;
    NSSize tempSize;
    NSPoint tempJust;

    if (![self _cache])
    {
       [self _aqtLabelUpdateCache];
    }
    
    [tempTrans rotateByDegrees:angle];
    tempSize = [(NSAttributedString *)[self _cache] size];
    tempJust = [tempTrans  transformPoint:NSMakePoint(-justification*tempSize.width/2, -tempSize.height/2)];
    tempBounds.size = [tempTrans transformSize:[(NSAttributedString *)[self _cache] size]];

    tempBounds.origin.x = position.x+tempJust.x;
    tempBounds.origin.y = position.y+tempJust.y;
    [self setBounds:tempBounds];
    return tempBounds;
}

-(void)renderInRect:(NSRect)boundsRect
{
   NSSize boundingBox;
   if (![self _cache])
   {
      [self _aqtLabelUpdateCache];
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
-(void)_aqtPathUpdateCache
{
   NSBezierPath *scratch = [NSBezierPath bezierPath];
   [scratch appendBezierPathWithPoints:path count:pointCount];
   [scratch setLineJoinStyle:NSRoundLineJoinStyle];
   [scratch setLineCapStyle:lineCapStyle];
   [scratch setLineWidth:linewidth];
   [self _setCache:scratch];
}

-(NSRect)updateBounds
{
   NSRect tmpBounds;
   if (![self _cache])
   {
      [self _aqtPathUpdateCache];
   }
   
   tmpBounds = NSInsetRect([[self _cache] bounds], -.001, -.001);
   [self  setBounds:tmpBounds];
   return tmpBounds;
}
   
-(void)renderInRect:(NSRect)boundsRect
{
   if (NSIntersectsRect(boundsRect, [self bounds]))
   {
      if (pointCount == 0)
         return;
      if (![self _cache])
      {
         [self _aqtPathUpdateCache];
      }
      [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
      [_cache stroke];
   }
}
@end

@implementation AQTPatch (AQTPatchDrawing)
-(void)_aqtPatchUpdateCache
{
   NSBezierPath *scratch = [NSBezierPath bezierPath];
   [scratch appendBezierPathWithPoints:path count:pointCount];
   [scratch setLineWidth:linewidth];
   [scratch closePath];
   [self _setCache:scratch];   
}

-(NSRect)updateBounds
{
   NSRect tmpBounds;
   if (![self _cache])
   {
      [self _aqtPatchUpdateCache];
   }

   tmpBounds = NSInsetRect([[self _cache] bounds], -.001, -.001);
   [self  setBounds:tmpBounds];
   return tmpBounds;
}

-(void)renderInRect:(NSRect)boundsRect
{
   if (NSIntersectsRect(boundsRect, [self bounds]))
   {
      if (pointCount == 0)
         return;
      if (![self _cache])
      {
         [self _aqtPatchUpdateCache];
      }
      [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
      [_cache stroke];
      [_cache fill];
   }
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

@implementation AQTModel (AQTModelExtensions)
-(void)appendModel:(AQTModel *)aModel
{
   [self setTitle:[aModel title]];
   [self setColor:[aModel color]];
   [self setBounds:NSUnionRect([self bounds], [aModel updateBounds])];
   [modelObjects addObjectsFromArray:[aModel modelObjects]];
}

-(void)removeObjectsInRect:(NSRect)targetRect
{
   // FIXME: It is possible to recursively nest models in models,
   // but this method doesn't work in that case

   NSRect testRect;
   NSRect newBounds = NSZeroRect;
   int i;
   int  objectCount = [modelObjects count];
#if 0
   NSDate *startTime=  [NSDate date];
#endif
   targetRect = NSInsetRect(targetRect, -0.5, -0.5); // Try to be smart...

   if(objectCount == 0)
      return;

   if (NSContainsRect(targetRect, [self bounds]))
   {
      [modelObjects removeAllObjects];
      [self setBounds:newBounds];
   }
   else
   {
      for (i = objectCount - 1; i >= 0; i--)
      {
         testRect = [[modelObjects objectAtIndex:i] bounds];
         if (testRect.size.height == 0.0 || testRect.size.width == 0.0)
         {
            testRect = NSInsetRect(testRect, -0.1, -0.1); // FIXME: Try to be smarter...
         }
         if (NSContainsRect(targetRect, testRect))
         {
            [modelObjects removeObjectAtIndex:i];
         }
         else
         {
            newBounds = NSUnionRect(newBounds, testRect);
         }
      }
   }
   [self setBounds:newBounds];
#if 0
   NSLog(@"Time taken: %f", -[startTime timeIntervalSinceNow]);
#endif
}

@end

