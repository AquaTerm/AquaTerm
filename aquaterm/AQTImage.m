//
//  AQTImage.m
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 05 2002.
//  Copyright (c) 2001 AquaTerm. All rights reserved.
//
#import <Foundation/NSURL.h>
#import "AQTImage.h"
#import <CoreServices/CoreServices.h>

@implementation AQTImage
- (id)initWithContentsOfFile:(NSString *)filename
{
  if (self = [super init])
  {
    image = [[NSImage alloc] initWithContentsOfFile:filename];
  }
  return self;
}

- (id)initWithImage:(NSImage *)anImage
{
  if (self = [super init])
  {
    [anImage retain];
    [image release];
    image = anImage;
  }
  return self;
}


-(void)dealloc
{
  [image release];
  [super dealloc];
}
-(void)setBounds:(NSRect)theBounds
{
  renderBounds = theBounds;
}

-(NSRect)bounds
{
  return renderBounds;
}

@end
