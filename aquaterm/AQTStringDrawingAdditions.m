//
//  AQTStringDrawingAdditions.m
//  AquaTerm
//
//  Created by Per Persson on Thu Oct 14 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "AQTStringDrawingAdditions.h"

NSPoint recurse(NSBezierPath *path, const NSAttributedString *attrString, NSString *defaultFontName, float defaultFontSize, int *i, int sublevel, NSPoint pos, float fontScale);



NSImage *_aqtSharedScratchPad(void)
{
   static NSImage *scratchPadImage;
   if (!scratchPadImage) {
      scratchPadImage = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
   }
   return scratchPadImage;
}

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
      0x20AC, 0x03D2, 0x2032, 0x2264, 0x2044, 0x221E, 0x0192, 0x2663, 0x2666, 0x2665, 0x2660, 0x2194, 0x2190, 0x2191, 0x2192, 0x2193,
      0x00B0, 0x00B1, 0x2033, 0x2265, 0x00D7, 0x221D, 0x2202, 0x2022, 0x00F7, 0x2260, 0x2261, 0x2248, 0x2026, 0xF8E6, 0xF8E7, 0x21B5,
      0x2135, 0x2111, 0x211C, 0x2118, 0x2297, 0x2295, 0x2205, 0x2229, 0x222A, 0x2283, 0x2287, 0x2284, 0x2282, 0x2286, 0x2208, 0x2209,
      0x2220, 0x2207, 0x00AE, 0x00A9, 0x2122, 0x220F, 0x221A, 0x22C5, 0x00AC, 0x2227, 0x2228, 0x21D4, 0x21D0, 0x21D1, 0x21D2, 0x21D3,
      0x22C4, 0x3008, 0x00AE, 0x00A9, 0x2122, 0x2211, 0x00E6, 0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0xF8F4,
      0xF8FF, 0x3009, 0x222B, 0x2320, 0x00F4, 0x2321, 0x00F6, 0x00F7, 0x00F8, 0x00F9, 0x00FA, 0x00FB, 0x00FC, 0x00FD, 0x00FE, 0x00FF};
   
   return theChar<256?map[theChar]:0x0000;
}


@implementation NSString (AQTStringDrawingAdditions)
-(NSBezierPath *)aqtBezierPathInFont:(NSFont *)aFont
{
   int i;
   int firstChar = 0;
   int strLen = [self length];
   NSPoint pos = NSZeroPoint;
   NSBezierPath *tmpPath = [NSBezierPath bezierPath];
   BOOL convertFont = [[aFont fontName] isEqualToString:@"Symbol"];
   
   // Remove leading spaces FIXME: trailing as well?, need better solution
   // Don't skip a single space...
   while (strLen>1 && firstChar<strLen && [self characterAtIndex:firstChar] == ' ') {
      firstChar++;
   }
   
   [_aqtSharedScratchPad() lockFocus];
   [tmpPath moveToPoint:pos];
   
   for(i=firstChar; i<strLen; i++)
   {
      NSGlyph theGlyph;
      NSSize offset;
      unichar theChar = [self characterAtIndex:i];
      if (convertFont)
         theChar = _aqtMapAdobeSymbolEncodingToUnicode(theChar);
      theGlyph = [aFont _defaultGlyphForChar:theChar];
      offset = [aFont advancementForGlyph:theGlyph];
      [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
      pos.x += offset.width;
      pos.y += offset.height;
      [tmpPath moveToPoint:pos];      
   }

   [_aqtSharedScratchPad() unlockFocus];
   return tmpPath;
}
@end

@implementation NSAttributedString (AQTStringDrawingAdditions)
-(NSBezierPath *)aqtBezierPathInFont:(NSFont *)defaultFont
{
   int i = 0;
   float subFontAdjust = 0.6;
   float subBaseAdjust = 0.3;
   NSFont *subFont = [NSFont fontWithName:[defaultFont fontName] size:[defaultFont pointSize]*subFontAdjust];
   NSFont *tmpNormalFont;
   NSFont *tmpSubFont;
   NSFont *aFont; 
   NSString *text = [self string]; // Yuck!
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
   int index = 0;
   
   // 
   // Remove leading spaces FIXME: trailing as well?, need better solution
   // Don't skip a single space...
   while (strLen>1 && firstChar<strLen && [text characterAtIndex:firstChar] == ' ')
      firstChar++;
   
   [_aqtSharedScratchPad() lockFocus];
   
   [tmpPath moveToPoint:pos];   
#if  1
   pos = recurse(tmpPath, self, [defaultFont fontName], [defaultFont pointSize], &index, 0, pos, 1.0);
#elif
   for(i=firstChar; i<strLen; i++) {
      NSGlyph theGlyph;
      NSSize offset;
      unichar theChar = [text characterAtIndex:i];
      NSDictionary *attrDict = [self attributesAtIndex:i effectiveRange:nil];
      tmpNormalFont = defaultFont;
      tmpSubFont = subFont;
      // Switch font if set in attribute
      if ([attrDict objectForKey:@"AQTFontname"] != nil && ![[attrDict objectForKey:@"AQTFontname"] isEqualToString:[defaultFont fontName]]) {
         // New font set in character atttribute
         NSFont *aFont = [NSFont fontWithName:[attrDict objectForKey:@"AQTFontname"] size:[defaultFont pointSize]]; // FIXME: Attribute for this!
         if (aFont != nil) {
            tmpNormalFont = aFont;
            tmpSubFont = [NSFont fontWithName:[aFont fontName] size:[defaultFont pointSize]*subFontAdjust]; // FIXME: Attribute for this!
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
                  baselineOffset = [tmpNormalFont ascender]-[defaultFont pointSize]*subBaseAdjust;
                  drawPos = pos;
                  drawPos.y += baselineOffset;
                  pos.x += offset.width;
                  pos.y += offset.height;
                  rightSubEdge = MAX(pos.x, rightSubEdge);
                  break;
               case -1:
                  baselineOffset = -[defaultFont pointSize]*subBaseAdjust;
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
                  baselineOffset = -[defaultFont pointSize]*subBaseAdjust;
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
                  baselineOffset = [tmpNormalFont ascender]-[defaultFont pointSize]*subBaseAdjust;
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
      if ([attrDict objectForKey:@"AQTNonPrintingChar"] == nil || [[attrDict objectForKey:@"AQTNonPrintingChar"] intValue] == 0)
         [tmpPath appendBezierPathWithGlyph:theGlyph inFont:aFont];
      [tmpPath moveToPoint:pos];      
      subscriptState = newSubscriptState;
   }
#endif
   [_aqtSharedScratchPad() unlockFocus];
   return tmpPath;
}
@end

/* This function appends the attributed string to a bezierPath. The following string attributes are honored:
 * AQTFontname - overrides defaultFontName (NSString)
 * AQTFontsize - overrides defaultFontSize (float)
 * NSSuperscript - superscript level (int) [..., -1, 0, 1, ...], negative for subscript FIXME: AQTSuperscript
 * NSUnderline - underline text (int) {0, 1} FIXME: AQTUnderline
 * AQTBaselineAdjust - move baseline relative to glyph height (float) <0 below and 0> above baseline
 * AQTNonPrintingChar - if defined and 1 char will not be drawn, only occupy space (int) {0, 1}
 *
 * If Symbol font is specified (defaultFont or as attribute), automatic conversion to Unicode is performed. FIXME: selectable 
*/
NSPoint recurse(NSBezierPath *path, const NSAttributedString *attrString, NSString *defaultFontName, float defaultFontSize, int *i, int sublevel, NSPoint pos, float fontScale)
{
   static float maxRight = 0.0;
   static NSPoint underlineLeftPoint;
   static NSPoint overprintLeftPoint;
   NSString *text = [attrString string];
   NSPoint subPos = pos;
   BOOL extendsRight = NO;
   BOOL underlining = NO;
   int strLen = [text length];
   float glyphHeight = defaultFontSize * fontScale;
   int attributedSublevel = 0;
   float baselineOffset = 0.0;
    
   while (*i < strLen) {
      // Read attributes
      NSDictionary *attributes = [attrString attributesAtIndex:*i effectiveRange:nil];
      NSString *attributedFontname = ([attributes objectForKey:@"AQTFontname"] != nil)?
         [attributes objectForKey:@"AQTFontname"]:
         defaultFontName; 
      float attributedFontsize = ([attributes objectForKey:@"AQTFontsize"] != nil)?
         [[attributes objectForKey:@"AQTFontsize"] intValue]:
         defaultFontSize;
      attributedSublevel = ([attributes objectForKey:NSSuperscriptAttributeName] != nil)?
         [[attributes objectForKey:NSSuperscriptAttributeName] intValue]:
         0;
      float baselineAdjust = ([attributes objectForKey:@"AQTBaselineAdjust"] != nil)?
         [[attributes objectForKey:@"AQTBaselineAdjust"] floatValue]:
         0.0;
      BOOL isVisible = ([attributes objectForKey:@"AQTNonPrintingChar"] == nil 
         || [[attributes objectForKey:@"AQTNonPrintingChar"] intValue] == 0);
      BOOL newUnderlining = ([attributes objectForKey:@"NSUnderline"] != nil 
                        && [[attributes objectForKey:@"NSUnderline"] intValue] == 1);
      int markOverprinting = ([attributes objectForKey:@"AQTOverprint"] != nil)?
         [[attributes objectForKey:@"AQTOverprint"] intValue]:
         0;
      float overprintAdjust = ([attributes objectForKey:@"AQTOverprintAdjust"] != nil)?
         [[attributes objectForKey:@"AQTOverprintAdjust"] floatValue]:
         1.0;
      if (attributedSublevel == sublevel) {
         NSFont *aFont;
         unichar theChar;
         NSGlyph theGlyph;
         // Get selected font
         if ((aFont = [NSFont fontWithName:attributedFontname size:attributedFontsize * fontScale]) == nil)
            aFont = [NSFont systemFontOfSize:attributedFontsize * fontScale]; 
         theChar = [text characterAtIndex:*i];
         // Perform neccessary conversion to Unicode
         if ([[aFont fontName] isEqualToString:@"Symbol"]) {
            theChar = _aqtMapAdobeSymbolEncodingToUnicode(theChar);
         }
         // Get the glyph
         theGlyph = [aFont _defaultGlyphForChar:theChar];
         // Adjust glyph position
         glyphHeight = [aFont boundingRectForGlyph:theGlyph].size.height;
         if (extendsRight)
            pos.x = maxRight;         
         baselineOffset = glyphHeight*baselineAdjust;
         // check underlining
         if (underlining) {
            if (!newUnderlining) 
               [path appendBezierPathWithRect:NSMakeRect(underlineLeftPoint.x, underlineLeftPoint.y+[aFont underlinePosition], pos.x-underlineLeftPoint.x, [aFont underlineThickness])];
         } else {
            if (newUnderlining)
               underlineLeftPoint = pos;
         }
         underlining = newUnderlining;
         // Overprint
         if (markOverprinting == 1)
            overprintLeftPoint = pos;
         if (markOverprinting == 2)
         {
            [path moveToPoint:NSMakePoint(pos.x + (pos.x-overprintLeftPoint.x-[aFont advancementForGlyph:theGlyph].width)/2.0,
                                          pos.y+[aFont xHeight]*overprintAdjust)];
            // render glyph
            if (isVisible)
               [path appendBezierPathWithGlyph:theGlyph inFont:aFont];
            // advance position
            // pos.x += [aFont advancementForGlyph:theGlyph].width;
         } else {
            [path moveToPoint:NSMakePoint(pos.x, pos.y+baselineOffset)];
            // render glyph
            if (isVisible)
               [path appendBezierPathWithGlyph:theGlyph inFont:aFont];
            // advance position
            pos.x += [aFont advancementForGlyph:theGlyph].width;
         }
         [path moveToPoint:pos];
         maxRight = MAX(pos.x, maxRight);
         extendsRight = NO; 
         (*i)++;
      } else if(abs(attributedSublevel) <= abs(sublevel)) {
         return pos;
      } else {
         float baseline;
         if(attributedSublevel < 0)
            baseline = pos.y - attributedFontsize * 0.3 * fontScale + baselineOffset;
         else
            baseline = pos.y + glyphHeight * 0.7 + baselineOffset; 
         extendsRight = YES;
         subPos = recurse(path, attrString, defaultFontName, defaultFontSize, i, attributedSublevel, NSMakePoint(pos.x, baseline), fontScale * 0.65);
         maxRight = MAX(subPos.x, maxRight);
      }
   }
   maxRight = 0.0; 
   return pos;
}







