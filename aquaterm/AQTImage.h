//
//  AQTImage.h
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 05 2002.
//  Copyright (c) 2001 AquaTerm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AQTGraphic.h"

@interface AQTImage : AQTGraphic
{
  NSData *bitmap;
  NSSize bitmapSize;
  //NSRect renderBounds;
}
- (id)initWithBitmap:(const char *)bytes size:(NSSize)size bounds:(NSRect)bounds;
- (NSData *)bitmap;
@end
