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
  [super encodeWithCoder:coder];
  [coder encodeObject:bitmap];
  [coder encodeValueOfObjCType:@encode(NSSize) at:&bitmapSize];
  [coder encodeValueOfObjCType:@encode(NSRect) at:&_bounds];
  [coder encodeValueOfObjCType:@encode(AQTAffineTransformStruct) at:&transform];
}

-(id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  bitmap = [[coder decodeObject] retain];
  [coder decodeValueOfObjCType:@encode(NSSize) at:&bitmapSize];
  [coder decodeValueOfObjCType:@encode(NSRect) at:&_bounds];
  [coder decodeValueOfObjCType:@encode(AQTAffineTransformStruct) at:&transform];
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
