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
// Needed for constants...
#import "AQTAdapter.h" 

//
// Using an undocumented method in NSFont.
//
@interface NSFont (NSFontHiddenMethods)
- (NSGlyph)_defaultGlyphForChar:(unichar)theChar;
@end

@implementation AQTGraphic (AQTGraphicDrawingMethods)
+ (NSImage *)sharedScratchPad
{
   static NSImage *scratchPadImage;
   if (!scratchPadImage)
   {
      scratchPadImage = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
   }
   return scratchPadImage;
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

   // Model object is responsible for background...
   [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
   NSRectFill(dirtyRect);

   while ((graphic = [enumerator nextObject]))
   {
      [graphic renderInRect:dirtyRect];
   }
}
@end

@implementation AQTLabel (AQTLabelDrawing)

-(void)_aqtLabelUpdateCache
{
   int i = 0;
   float subFontAdjust = 0.6;
   float subBaseAdjust = 0.3;
   NSFont *normalFont = [NSFont fontWithName:fontName size:fontSize];
   NSFont *subFont = [NSFont fontWithName:fontName size:fontSize*subFontAdjust];
   NSFont *aFont = normalFont;
   NSString *text = [string string]; // Yuck!
   int strLen = [text length];
   NSAffineTransform *aTransform = [NSAffineTransform transform];
   NSBezierPath *tmpPath = [NSBezierPath bezierPath];
   NSSize tmpSize;
   NSPoint adjust = NSZeroPoint;
   NSPoint pos = NSZeroPoint;
   float leftUnderlineEdge;
   float leftSubEdge, rightSubEdge;
   BOOL underlineState = NO;
   int newSubscriptState;
   int subscriptState = 0;
   float baselineOffset = 0.0;
   //
   // appendBezierPathWithGlyph needs a valid context...
   //
   [[AQTGraphic sharedScratchPad] lockFocus];
   //
   // Create glyphs and convert to path
   //
   [tmpPath moveToPoint:pos];

   for(i=0; i<strLen; i++)
   {
      NSGlyph theGlyph;
      NSSize offset;
      NSDictionary *attrDict = [string attributesAtIndex:i effectiveRange:nil];
      // underlining

      if(underlineState == NO)
      {
         if ([attrDict valueForKey:NSUnderlineStyleAttributeName])
         {
            leftUnderlineEdge = pos.x;
            underlineState = YES;
         }
      }
      else
      {
         if (![attrDict valueForKey:NSUnderlineStyleAttributeName])
         {
            [tmpPath appendBezierPathWithRect:NSMakeRect(leftUnderlineEdge, -1.0, pos.x - leftUnderlineEdge, 0.5)];
            underlineState = NO;
            [tmpPath moveToPoint:pos];
         }
      }
      
      // subscript
      newSubscriptState = [[attrDict valueForKey:NSSuperscriptAttributeName] intValue];
      newSubscriptState = newSubscriptState>1?1:newSubscriptState;
      newSubscriptState = newSubscriptState<-1?-1:newSubscriptState; 
      // FIXME: this is way too ugly... 
      switch (subscriptState)
      {
         case 0:
            switch (newSubscriptState)
            {
               case 0:
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  // [tmpPath relativeMoveToPoint:NSMakePoint(0.0, baselineOffset)];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  leftSubEdge = pos.x;
                  break;
               case 1:
                  aFont = subFont;
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  baselineOffset = [normalFont ascender]-fontSize*subBaseAdjust;
                  [tmpPath relativeMoveToPoint:NSMakePoint(0.0, baselineOffset)];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
               case -1:
                  aFont = subFont;
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  baselineOffset = -fontSize*subBaseAdjust;
                  [tmpPath relativeMoveToPoint:NSMakePoint(0.0, baselineOffset)];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
            }
            break;
         case 1:
            switch (newSubscriptState)
            {
               case 0:
                  aFont = normalFont;
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  baselineOffset = 0.0;
                  pos.x = rightSubEdge;
                  [tmpPath moveToPoint:pos];
                  [tmpPath relativeMoveToPoint:NSMakePoint(0.0, baselineOffset)];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  leftSubEdge = pos.x;
                  break;
               case 1:
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  [tmpPath relativeMoveToPoint:NSMakePoint(0.0, baselineOffset)];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
               case -1:
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  baselineOffset = -fontSize*subBaseAdjust;
                  pos.x = leftSubEdge;
                  [tmpPath moveToPoint:pos];
                  [tmpPath relativeMoveToPoint:NSMakePoint(0.0, baselineOffset)];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
            }            
            break;
         case -1:
            switch (newSubscriptState)
            {
               case 0:
                  aFont = normalFont;
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  baselineOffset = 0.0;
                  pos.x = rightSubEdge;
                  [tmpPath moveToPoint:pos];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  leftSubEdge = pos.x;
                  break;
               case 1:
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  baselineOffset = [normalFont ascender]-fontSize*subBaseAdjust;
                  pos.x = leftSubEdge;
                  [tmpPath moveToPoint:pos];
                  [tmpPath relativeMoveToPoint:NSMakePoint(0.0, baselineOffset)];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
               case -1:
                  theGlyph = [aFont _defaultGlyphForChar:[text characterAtIndex:i]];
                  offset = [aFont advancementForGlyph:theGlyph];
                  [tmpPath relativeMoveToPoint:NSMakePoint(0.0, baselineOffset)];
                  [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
                  pos.x += offset.width;
                  pos.y += offset.height;
                  [tmpPath moveToPoint:pos];
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
            }
            break;
         default:
            NSLog(@"Subscript parameter error, only -1, 0, and 1 allowed");
            break;
      }
      subscriptState = newSubscriptState;
   }
   [[AQTGraphic sharedScratchPad] unlockFocus];
   tmpSize = [tmpPath bounds].size;
   //
   // Place the path according to position, angle and align
   //   
   // hAlign:
   adjust.x = -(float)(justification & 0x03)*0.5*tmpSize.width;
   // vAlign:
   switch (justification & 0x1C)
   {
      case AQTAlignMiddle: // align middle wrt *font size*
         adjust.y = -([aFont descender] + [aFont capHeight])*0.5; 
         break;
      case AQTAlignBaseline: // align baseline (do nothing)
         break;
      case AQTAlignBottom: // align bottom wrt *bounding box*
         adjust.y = -[tmpPath bounds].origin.y;
         break;
      case AQTAlignTop: // align top wrt *bounding box*
         adjust.y = -([tmpPath bounds].origin.y + tmpSize.height) ;
         break;
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
   if (![self _cache])
   {
      [self _aqtLabelUpdateCache];
   }
   tempBounds = [_cache bounds];
   [self setBounds:tempBounds];
   return tempBounds;
}

-(void)renderInRect:(NSRect)boundsRect
{
   if (NSIntersectsRect(boundsRect, [self bounds]))
   {
      [[NSColor colorWithCalibratedRed:_color.red green:_color.green blue:_color.blue alpha:1.0] set];
      [_cache  fill];
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
}
@end

