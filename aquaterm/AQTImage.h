//
//  AQTImage.h
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 05 2002.
//  Copyright (c) 2001 AquaTerm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTGraphic.h"

@interface AQTImage : AQTGraphic
{
  NSImage *image;
  NSRect renderBounds;
}
- (id)initWithContentsOfFile:(NSString *)filename;
- (id)initWithImage:(NSImage *)anImage;
-(void)setBounds:(NSRect)theBounds;
@end
