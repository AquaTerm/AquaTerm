//
//  AQTImage.m
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 05 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
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

-(void)updateColors:(AQTColorMap *)colorMap
{
}



-(void)renderInRect:(NSRect)boundsRect
{
  NSSize docSize = NSMakeSize(842,595); // FIXME!!! Should refer to document size instead
  NSAffineTransform *localTransform = [NSAffineTransform transform];
  NSRect scaledBounds = [self bounds];
  float xScale = boundsRect.size.width/docSize.width;
  float yScale = boundsRect.size.height/docSize.height;
  //
  // Get the transform due to view resizing
  //
  [localTransform scaleXBy:xScale yBy:yScale];
  scaledBounds.size = [localTransform transformSize:scaledBounds.size];
  scaledBounds.origin = [localTransform transformPoint:scaledBounds.origin]; 
  [image drawInRect:scaledBounds fromRect:NSMakeRect(0,0,[image size].width,[image size].height) operation:NSCompositeSourceOver fraction:1.0];
}
@end
