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
// #import "AQTStringDrawingAdditions.h"

/* Using an undocumented method in NSFont. */
@interface NSFont (NSFontHiddenMethods)
- (NSGlyph)_defaultGlyphForChar:(unichar)theChar;
@end

/* _aqtMinimumLinewidth is used by view to pass user prefs to line drawing routine,
this is ugly, but I can't see a simple way to do it without affecting performance. */
static float _aqtMinimumLinewidth; 

/* Utility function to map Adobe Symbol encoding to unicode */ 
unichar _aqtMapAdobeSymbolEncodingToUnicode(unichar theChar)
{
   unichar map[256] = {
      0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x000E, 0x000F,
      0x0010, 0x0011, 0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017, 0x0018, 0x0019, 0x001A, 0x001B, 0x001C, 0x001D, 0x001E, 0x001F,
      0x0020, 0x0021, 0x2200, 0x0023, 0x2203, 0x0025, 0x0026, 0x220D, 0x0028, 0x0029, 0x2217, 0x002B, 0x002C, 0x2212, 0x002E, 0x002F,
      0x0030, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035, 0x0036, 0x0037, 0x0038, 0x0039, 0x003A, 0x003B, 0x003C, 0x003D, 0x003E, 0x003F,
      0x2245, 0x0391, 0x0392, 0x03A7, 0x0394, 0x0395, 0x03A6, 0x0393, 0x0397, 0x0399, 0x03D1, 0x039A, 0x039B, 0x039C, 0x039D, 0x039F,
      0x03A0, 0x0398, 0x03A1, 0x03A3, 0x03A4, 0x03A5, 0x03C2, 0x03A9, 0x039E, 0x03A8, 0x0396, 0x005B, 0x2234, 0x005D, 0x22A5, 0x005F,
      0xF8E5, 0x03B1, 0x03B2, 0x03C7, 0x03B4, 0x03B5, 0x03C6, 0x03B3, 0x03B7, 0x03B9, 0x03D5, 0x03BA, 0x03BB, 0x03BC, 0x03BD, 0x03BF,
      0x03C0, 0x03B8, 0x03C1, 0x03C3, 0x03C4, 0x03C5, 0x03D6, 0x03C9, 0x03BE, 0x03C8, 0x03B6, 0x007B, 0x007C, 0x007D, 0x223C, 0x007F,
      0x0080, 0x0081, 0x0082, 0x0083, 0x0084, 0x0085, 0x0086, 0x0087, 0x0088, 0x0089, 0x008A, 0x008B, 0x008C, 0x008D, 0x008E, 0x008F,
      0x0090, 0x0091, 0x0092, 0x0093, 0x0094, 0x0095, 0x0096, 0x0097, 0x0098, 0x0099, 0x009A, 0x009B, 0x009C, 0x009D, 0x009E, 0x009F,
      /* --> */      0x20AC, 0x00A1, 0x00A2, 0x00A3, 0x00A4, 0x00A5, 0x00A6, 0x00A7, 0x00A8, 0x00A9, 0x00AA, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x00AF,
      0x00B0, 0x00B1, 0x00B2, 0x00B3, 0x00B4, 0x00B5, 0x00B6, 0x00B7, 0x00B8, 0x00B9, 0x00BA, 0x00BB, 0x00BC, 0x00BD, 0x00BE, 0x00BF,
      0x00C0, 0x00C1, 0x00C2, 0x00C3, 0x00C4, 0x00C5, 0x00C6, 0x00C7, 0x00C8, 0x00C9, 0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE, 0x00CF,
      0x00D0, 0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x00D5, 0x00D6, 0x00D7, 0x00D8, 0x00D9, 0x00DA, 0x00DB, 0x00DC, 0x00DD, 0x00DE, 0x00DF,
      0x00E0, 0x00E1, 0x00E2, 0x00E3, 0x00E4, 0x00E5, 0x00E6, 0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF,
      0x00F0, 0x00F1, 0x222B, 0x2320, 0x222B, 0x2321, 0x00F6, 0x00F7, 0x00F8, 0x00F9, 0x00FA, 0x00FB, 0x00FC, 0x00FD, 0x00FE, 0x00FF};
   
   return theChar<256?map[theChar]:0x0000;
}

@implementation AQTGraphic (AQTGraphicDrawingMethods)
+ (NSImage *)sharedScratchPad
{
   static NSImage *scratchPadImage;
   if (!scratchPadImage) {
      scratchPadImage = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
   }
   return scratchPadImage;
}

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
// FIXME: The following to methods should be categories on NSAttributedString and NSString, repectively
-(NSBezierPath *)_aqtPathFromAttributedString:(NSAttributedString *)attrString inFont:(NSFont *)defaultFont;
{
   int i = 0;
   float subFontAdjust = 0.6;
   float subBaseAdjust = 0.3;
   NSFont *subFont = [NSFont fontWithName:[defaultFont fontName] size:fontSize*subFontAdjust];
   NSFont *tmpNormalFont;
   NSFont *tmpSubFont;
   NSFont *aFont; 
   NSString *text = [attrString string]; // Yuck!
   int strLen = [text length];
   NSBezierPath *tmpPath = [NSBezierPath bezierPath];
   NSPoint pos = NSZeroPoint;
   NSPoint drawPos;
   float leftUnderlineEdge;
   float leftSubEdge, rightSubEdge;
   BOOL underlineState = NO;
   int newSubscriptState;
   int subscriptState = 0;
   int firstChar = 0;
   float baselineOffset = 0.0;
   // 
   // Remove leading spaces FIXME: trailing as well?, need better solution
   // Don't skip a single space...
   while (strLen>1 && firstChar<strLen && [text characterAtIndex:firstChar] == ' ')
      firstChar++;
   
   [[AQTGraphic sharedScratchPad] lockFocus];
   
   [tmpPath moveToPoint:pos];   
   for(i=firstChar; i<strLen; i++) {
      unichar theChar = [text characterAtIndex:i];
      NSGlyph theGlyph;
      NSSize offset;
      NSDictionary *attrDict = [string attributesAtIndex:i effectiveRange:nil];
      tmpNormalFont = defaultFont;
      tmpSubFont = subFont;
      // Switch font if set in attribute
      if ([attrDict objectForKey:@"AQTFontname"] != nil && ![[attrDict objectForKey:@"AQTFontname"] isEqualToString:fontName]) {
         // New font set in character atttribute
         NSFont *aFont = [NSFont fontWithName:[attrDict objectForKey:@"AQTFontname"] size:fontSize];
         if (aFont != nil) {
            tmpNormalFont = aFont;
            tmpSubFont = [NSFont fontWithName:[aFont fontName] size:fontSize*subFontAdjust];
         }
      }
      if ([[tmpNormalFont fontName] isEqualToString:@"Symbol"]) {
         theChar = _aqtMapAdobeSymbolEncodingToUnicode(theChar);
      }      
      // underlining      
      if(underlineState == NO) {
         if ([attrDict valueForKey:NSUnderlineStyleAttributeName]) {
            leftUnderlineEdge = pos.x;
            underlineState = YES;
         }
      } else {
         if (![attrDict valueForKey:NSUnderlineStyleAttributeName]) {
            [tmpPath appendBezierPathWithRect:NSMakeRect(leftUnderlineEdge, -1.0, pos.x - leftUnderlineEdge, 0.5)];
            underlineState = NO;
            [tmpPath moveToPoint:pos];
         }
      }      
      // subscript
      newSubscriptState = [[attrDict valueForKey:NSSuperscriptAttributeName] intValue];
      newSubscriptState = newSubscriptState>1?1:newSubscriptState;
      newSubscriptState = newSubscriptState<-1?-1:newSubscriptState; 
      // FIXME: this is still way too ugly... 
      switch (newSubscriptState) {
         case 0:
            aFont = tmpNormalFont;
            break;
         case 1: // Falltrough
         case -1:
            aFont = tmpSubFont;
            break;
         default:
            break;
      }
      theGlyph = [aFont _defaultGlyphForChar:theChar];
      offset = [aFont advancementForGlyph:theGlyph];
      
      switch (subscriptState) {
         case 0:
            switch (newSubscriptState) {
               case 0:
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  leftSubEdge = pos.x;
                  break;
               case 1:
                  baselineOffset = [tmpNormalFont ascender]-fontSize*subBaseAdjust;
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
               case -1:
                  baselineOffset = -fontSize*subBaseAdjust;
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
            }
            break;
         case 1:
            switch (newSubscriptState) {
               case 0:
                  baselineOffset = 0.0;
                  pos.x = rightSubEdge;
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  leftSubEdge = pos.x;
                  break;
               case 1:
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
               case -1:
                  baselineOffset = -fontSize*subBaseAdjust;
                  pos.x = leftSubEdge;
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
            }            
            break;
         case -1:
            switch (newSubscriptState) {
               case 0:
                  baselineOffset = 0.0;
                  pos.x = rightSubEdge;
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  leftSubEdge = pos.x;
                  break;
               case 1:
                  baselineOffset = [tmpNormalFont ascender]-fontSize*subBaseAdjust;
                  pos.x = leftSubEdge;
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
               case -1:
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
            }
            break;
         default:
            NSLog(@"Subscript parameter error, only -1, 0, and 1 allowed");
            break;
      }
      [tmpPath moveToPoint:drawPos];
      if ([attrDict objectForKey:@"AQTPrintingChar"] == nil || [[attrDict objectForKey:@"AQTPrintingChar"] intValue] ==1)
         [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
      [tmpPath moveToPoint:pos];      
      subscriptState = newSubscriptState;
   }
   [[AQTGraphic sharedScratchPad] unlockFocus];
   return tmpPath;
}

-(NSBezierPath *)_aqtPathFromString:(NSString *)text inFont:(NSFont *)aFont
{
   int i;
   int firstChar = 0;
   int strLen = [text length];
   NSPoint pos = NSZeroPoint;
   NSBezierPath *tmpPath = [NSBezierPath bezierPath];
   // Remove leading spaces FIXME: trailing as well?, need better solution
   // Don't skip a single space...
   while (strLen>1 && firstChar<strLen && [text characterAtIndex:firstChar] == ' ')
      firstChar++;
   
   [[AQTGraphic sharedScratchPad] lockFocus];
   
   [tmpPath moveToPoint:pos];
   
   for(i=firstChar; i<strLen; i++) {
      unichar theChar = [text characterAtIndex:i];
      NSGlyph theGlyph = [aFont _defaultGlyphForChar:theChar];
      NSSize offset = [aFont advancementForGlyph:theGlyph];
      
      [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
      pos.x += offset.width;
      pos.y += offset.height;
      [tmpPath moveToPoint:pos];      
   }
   [[AQTGraphic sharedScratchPad] unlockFocus];
   return tmpPath;
}

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
   if ([string isKindOfClass:[NSAttributedString class]]) {
      tmpPath = [self _aqtPathFromAttributedString:string inFont:normalFont];
   } else if ([string isKindOfClass:[NSString class]]) {
      tmpPath = [self _aqtPathFromString:string inFont:normalFont]; 
   } else {
      [NSException raise:@"AQTWrongArgument" format:@"Yo"];
   } // tmpPath = [string aqtBezierPathInFont:normalFont];
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
}
@end

