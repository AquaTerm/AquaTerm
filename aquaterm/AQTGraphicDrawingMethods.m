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
#import "AQTImage.h"
#import "AQTFunctions.h"
#import "AQTStringDrawingAdditions.h"

/* _aqtMinimumLinewidth is used by view to pass user prefs to line drawing routine,
this is ugly, but I can't see a simple way to do it without affecting performance. */
static float _aqtMinimumLinewidth; 

@implementation AQTGraphic (AQTGraphicDrawingMethods)
- (void)setAQTColor
{
   static AQTColor currentColor;
   if (!AQTEqualColors(currentColor, _color)) {
      [[NSColor colorWithCalibratedRed:_color.red
                                 green:_color.green
                                  blue:_color.blue
                                 alpha:1.0] set];
      currentColor = _color;
   }
}

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
   
   _aqtMinimumLinewidth = [[NSUserDefaults standardUserDefaults] boolForKey:@"limitMinimumLinewidth"]?0.25:0.0; // FIXME: make limit (0.25) a pref
   
   while ((graphic = [enumerator nextObject]))
   {
      /*       NSRect graphRect = [graphic updateBounds];
      
      if (NSIsEmptyRect(graphRect))
   {
         NSLog(@"**** rect = %@ : %@", NSStringFromRect(graphRect), [graphic description]);
   }
      
      tmpRect = AQTUnionRect(tmpRect, graphRect);
      */
      tmpRect = AQTUnionRect(tmpRect, [graphic updateBounds]);
   }
   [self setBounds:tmpRect];
   return tmpRect;
}

-(void)renderInRect:(NSRect)aRect
{
   AQTGraphic *graphic;
   NSEnumerator *enumerator = [modelObjects objectEnumerator];
   
   // Model object is responsible for background...
   [self setAQTColor];
   // FIXME: needed to synchronize colors
   [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
   NSRectFill(aRect);
   
   while ((graphic = [enumerator nextObject])) {
      [graphic renderInRect:aRect];
   }
}
@end

@implementation AQTLabel (AQTLabelDrawing)
-(void)_aqtLabelUpdateCache
{
   NSFont *normalFont; 
   NSAffineTransform *aTransform = [NSAffineTransform transform];
   NSBezierPath *tmpPath = [NSBezierPath bezierPath];
   NSSize tmpSize;
   NSPoint adjust = NSZeroPoint;
   // Make sure we get a valid font....
   if ((normalFont = [NSFont fontWithName:fontName size:fontSize]) == nil)
      normalFont = [NSFont systemFontOfSize:fontSize]; // Fall back to a system font 
                                                       // Convert (attributed) string into a path
   tmpPath = [string aqtBezierPathInFont:normalFont]; // Implemented in AQTStringDrawingAdditions
   tmpSize = [tmpPath bounds].size;
   // Place the path according to position, angle and align  
   adjust.x = -(float)(justification & 0x03)*0.5*tmpSize.width; // hAlign:
   switch (justification & 0x1C) { // vAlign:
      case 0x00:// AQTAlignMiddle: // align middle wrt *font size*
         adjust.y = -([normalFont descender] + [normalFont capHeight])*0.5; 
         break;
      case 0x08:// AQTAlignBottom: // align bottom wrt *bounding box*
         adjust.y = -[tmpPath bounds].origin.y;
         break;
      case 0x10:// AQTAlignTop: // align top wrt *bounding box*
         adjust.y = -([tmpPath bounds].origin.y + tmpSize.height) ;
         break;
      case 0x04:// AQTAlignBaseline: // align baseline (do nothing)
      default:
         // default to align baseline (do nothing) in case of error
         break;
   }
   [aTransform translateXBy:position.x yBy:position.y];
   [aTransform rotateByDegrees:angle];
   [aTransform translateXBy:adjust.x yBy:adjust.y]; 
   [tmpPath transformUsingAffineTransform:aTransform];
   
   [self _setCache:tmpPath];
}

-(NSRect)updateBounds
{
   NSRect tempBounds;
   if (![self _cache]) {
      [self _aqtLabelUpdateCache];
   }
   tempBounds = [_cache bounds];
   [self setBounds:tempBounds];
   return tempBounds;
}

-(void)renderInRect:(NSRect)boundsRect
{
   if (AQTIntersectsRect(boundsRect, [self bounds])) {
      [self setAQTColor];
      [_cache  fill];
   }
#ifdef DEBUG_BOUNDS
   [[NSColor yellowColor] set];
   NSFrameRect([self bounds]);
#endif
   
}
@end

@implementation AQTPath (AQTPathDrawing)
-(void)_aqtPathUpdateCache
{
   float lw = [self isFilled]?1.0:linewidth; // FIXME: this is a hack to avoid tiny gaps between filled patches
   NSBezierPath *scratch = [NSBezierPath bezierPath];
   [scratch appendBezierPathWithPoints:path count:pointCount];
   [scratch setLineJoinStyle:NSRoundLineJoinStyle];
   [scratch setLineCapStyle:lineCapStyle];
   [scratch setLineWidth:(lw<_aqtMinimumLinewidth)?_aqtMinimumLinewidth:lw];
   if([self isFilled]) {
      [scratch closePath];
   }
   [self _setCache:scratch];
}

-(NSRect)updateBounds
{
   NSRect tmpBounds;
   if (![self _cache]) {
      [self _aqtPathUpdateCache];
   }   
   tmpBounds = [[self _cache] bounds];
   [self  setBounds:tmpBounds];
   return tmpBounds;
}

-(void)renderInRect:(NSRect)boundsRect
{
   if (AQTIntersectsRect(boundsRect, [self bounds])) {
      [self setAQTColor];
      [_cache stroke];
      if ([self isFilled]) {
         [_cache fill];
      }
   }
}
@end

@implementation AQTImage (AQTImageDrawing)
-(void)renderInRect:(NSRect)boundsRect
{
   if (AQTIntersectsRect(boundsRect, [self bounds])) {
      if (![self _cache]) {
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
      if (fitBounds == YES) {
         [_cache drawInRect:_bounds
                   fromRect:NSMakeRect(0,0,[_cache size].width,[_cache size].height)
                  operation:NSCompositeSourceOver
                   fraction:1.0];
      } else {
         NSAffineTransform *transf = [NSAffineTransform transform];
         NSGraphicsContext *context = [NSGraphicsContext currentContext];
         [context saveGraphicsState];
         [NSBezierPath clipRect:_bounds];
         [transf setTransformStruct:CAST_STRUCT_TO(NSAffineTransformStruct)transform];
         [transf concat];
         [_cache drawAtPoint:NSMakePoint(0,0)
                    fromRect:NSMakeRect(0,0,[_cache size].width,[_cache size].height)
                   operation:NSCompositeSourceOver
                    fraction:1.0];
         [context restoreGraphicsState];
      }
   }
}
@end

