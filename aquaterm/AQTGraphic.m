//
//  AQTGraphic.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTGraphic.h"

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
       _color.red = .5;
       _color.green = .5;
       _color.blue = .5;
    }
    return self; 
}

-(void)dealloc
{
  [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeValueOfObjCType:@encode(float) at:&_color.red];
   [coder encodeValueOfObjCType:@encode(float) at:&_color.green];
   [coder encodeValueOfObjCType:@encode(float) at:&_color.blue];
  [coder encodeValueOfObjCType:@encode(NSSize) at:&canvasSize];
}

-(id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  [coder decodeValueOfObjCType:@encode(float) at:&_color.red];
  [coder decodeValueOfObjCType:@encode(float) at:&_color.green];
  [coder decodeValueOfObjCType:@encode(float) at:&_color.blue];
  [coder decodeValueOfObjCType:@encode(NSSize) at:&canvasSize];
  return self;
}


-(NSSize)canvasSize
{
  return canvasSize;
}

-(void)setCanvasSize:(NSSize)cs
{
  canvasSize = cs;
}

-(AQTColor)color
{
   return _color;
}
//
//	Stubs, needs to be overridden by subclasses
//
-(NSRect)bounds {return  _bounds;}
-(void)addObject:(AQTGraphic *)graphic {;}
-(void)removeObject:(AQTGraphic *)graphic {;}
-(void)removeObjectsInRect:(NSRect)targetRect {;}

-(void)setColor:(AQTColor)newColor
{
  _color = newColor;
}
@end
