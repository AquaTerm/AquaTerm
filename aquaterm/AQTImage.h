//
//  AQTImage.h
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 05 2002.
//  Copyright (c) 2001 AquaTerm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AQTGraphic.h"

typedef struct _AQTAffineTransformStruct {
  float m11, m12, m21, m22;
  float tX, tY;
} AQTAffineTransformStruct;

@interface AQTImage : AQTGraphic
{
  NSData *bitmap;
  NSSize bitmapSize;
  AQTAffineTransformStruct transform;
}
- (id)initWithBitmap:(const char *)bytes size:(NSSize)size bounds:(NSRect)bounds;
- (NSData *)bitmap;
- (void)setTransform:(AQTAffineTransformStruct)newTransform;
@end
