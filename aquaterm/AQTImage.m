//
//  AQTImage.m
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 05 2002.
//  Copyright (c) 2001 AquaTerm. All rights reserved.
//
#import "AQTImage.h"

@implementation AQTImage
/*
- (id)initWithContentsOfFile:(NSString *)filename
{
  if (self = [super init])
  {
    image = [[NSImage alloc] initWithContentsOfFile:filename];
  }
  return self;
}
*/

- (id)initWithBitmap:(const char *)bytes size:(NSSize)size bounds:(NSRect)bounds
{
  if (self = [super init])
  {
    _bounds = bounds;
    bitmapSize = size;
    bitmap = [[NSData alloc] initWithBytes:bytes length:3*size.width*size.height];  // 3 bytes/sample
    // Identity matrix
    transform.m11 = 1.0;
    transform.m22 = 1.0;
    fitBounds = YES;
  }
  return self;
  
}

-(void)dealloc
{
  [bitmap release];
  [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  AQTRect r;
  AQTSize s;

  [super encodeWithCoder:coder];
  [coder encodeObject:bitmap];
  // 64bit compatibility
  s.width = bitmapSize.width; s.height = bitmapSize.height;
  [coder encodeValueOfObjCType:@encode(AQTSize) at:&s];
  r.origin.x = _bounds.origin.x; r.origin.y = _bounds.origin.y;
  r.size.width = _bounds.size.width; r.size.height = _bounds.size.height;
  [coder encodeValueOfObjCType:@encode(AQTRect) at:&r];
  [coder encodeValueOfObjCType:@encode(AQTAffineTransformStruct) at:&transform];
  [coder encodeValueOfObjCType:@encode(BOOL) at:&fitBounds];
}

-(id)initWithCoder:(NSCoder *)coder
{
  AQTRect r;
  AQTSize s;

  self = [super initWithCoder:coder];
  bitmap = [[coder decodeObject] retain];
  [coder decodeValueOfObjCType:@encode(AQTSize) at:&s];
  bitmapSize.width = s.width; bitmapSize.height = s.height;
  [coder decodeValueOfObjCType:@encode(AQTRect) at:&r];
  _bounds.origin.x = r.origin.x; _bounds.origin.y = r.origin.y;
  _bounds.size.width = r.size.width; _bounds.size.height = r.size.height;
  [coder decodeValueOfObjCType:@encode(AQTAffineTransformStruct) at:&transform];
  [coder decodeValueOfObjCType:@encode(BOOL) at:&fitBounds];
  return self;
}


- (NSData *)bitmap
{
  return bitmap;
}

- (void)setTransform:(AQTAffineTransformStruct)newTransform
{
  transform = newTransform;
   fitBounds = NO;
}

@end
