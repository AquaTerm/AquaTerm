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
    image = [anImage copy];
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
  // NSRect theBounds = NSMakeRect(0,0,0,0);
  // theBounds.size = [image size];
  return renderBounds; //theBounds;
}

-(void)updateColors:(AQTColorMap *)colorMap
{
}



-(void)renderInRect:(NSRect)boundsRect
{
  NSRect iBounds = NSMakeRect(0,0,0,0);
  iBounds.size = [image size];
  // FIXME: Scaling not implemented
  [image drawInRect:[self bounds] fromRect:iBounds operation:NSCompositeSourceOver fraction:1.0];

}
@end
