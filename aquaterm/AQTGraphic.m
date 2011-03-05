//
//  AQTGraphic.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTGraphic.h"

typedef struct _AQTColor_v100 {
   float red;
   float green;
   float blue;
} AQTColor_v100;

@implementation AQTGraphic
    /**"
    *** An abstract class to derive model objects from
    *** (Overkill at present but could come in handy if the app grows…)
    "**/
- (id)replacementObjectForPortCoder:(NSPortCoder *)portCoder
{
  if ([portCoder isBycopy])
    return self;
  return [super replacementObjectForPortCoder:portCoder];
}  

-(id)init
{
    if (self = [super init])
    {
       _color.red = 1.;
       _color.green = 1.;
       _color.blue = 1.;
       _color.alpha = 1.;
    }
    return self; 
}

-(void)dealloc
{
   [_cache release];
   [super dealloc];
}
-(NSString *)description
{
  return NSStringFromRect(_bounds);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  AQTRect r;
  [coder encodeValueOfObjCType:@encode(AQTColor) at:&_color];
  r.origin.x = _bounds.origin.x; r.origin.y = _bounds.origin.y;
  r.size.width = _bounds.size.width; r.size.height = _bounds.size.height;
  [coder encodeValueOfObjCType:@encode(AQTRect) at:&r];
  r.origin.x = _clipRect.origin.x; r.origin.y = _clipRect.origin.y;
  r.size.width = _clipRect.size.width; r.size.height = _clipRect.size.height;
  [coder encodeValueOfObjCType:@encode(AQTRect) at:&r];
  [coder encodeValueOfObjCType:@encode(BOOL) at:&_isClipped];
}

-(id)initWithCoder:(NSCoder *)coder
{
  AQTRect r;
  self = [super init];
  [coder decodeValueOfObjCType:@encode(AQTColor) at:&_color];
  [coder decodeValueOfObjCType:@encode(AQTRect) at:&r];
  _bounds.origin.x = r.origin.x; _bounds.origin.y = r.origin.y;
  _bounds.size.width = r.size.width; _bounds.size.height = r.size.height;
  [coder decodeValueOfObjCType:@encode(AQTRect) at:&r];
  _clipRect.origin.x = r.origin.x; _clipRect.origin.y = r.origin.y;
  _clipRect.size.width = r.size.width; _clipRect.size.height = r.size.height;
  [coder decodeValueOfObjCType:@encode(BOOL) at:&_isClipped];
  return self;
}

-(AQTColor)color
{
   return _color;
}

-(NSRect)clipRect
{
   return _clipRect;
}
-(void)setClipRect:(NSRect)newClipRect
{
   _clipRect = newClipRect;
}

-(void)setIsClipped:(BOOL)clipState
{
   _isClipped = clipState;
}

- (BOOL)shouldShowBounds
{
   return _shouldShowBounds;
}

- (void)toggleShouldShowBounds
{
   _shouldShowBounds = !_shouldShowBounds;
}
//
//	Stubs, needs to be overridden by subclasses
//
-(NSRect)bounds {return  _bounds;}
-(void)setBounds:(NSRect)bounds {_bounds = bounds;}

-(void)setColor:(AQTColor)newColor
{
  _color = newColor;
}
@end
