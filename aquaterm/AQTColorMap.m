//
//  AQTColorMap.m
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import "AQTColorMap.h"

@implementation AQTColorMap
-(id)init
{
  int i;
  NSColor *dummyColor = [NSColor clearColor];
  
  if (self = [super init])
  {
    indexedColormap = [[NSMutableArray alloc] initWithCapacity:256];	// 256 is a _hint_, not allocated!
    // Make sure we have _1_ object in the array
    // [indexedColormap addObject:dummyColor];
    // for (i=0;i<256;i++)
    // {
    //   [indexedColormap addObject:dummyColor];
    // }

    // Expand colormap to 10 colors
    [self setColor:[NSColor redColor] forIndex:0];
    [self setColor:[NSColor blueColor] forIndex:1];
    [self setColor:[NSColor greenColor] forIndex:2];
    [self setColor:[NSColor cyanColor] forIndex:3];
    [self setColor:[NSColor magentaColor] forIndex:4];
    [self setColor:[NSColor brownColor] forIndex:5];
    [self setColor:[NSColor orangeColor] forIndex:6];
    [self setColor:[NSColor brownColor] forIndex:7];
    [self setColor:[NSColor purpleColor] forIndex:8];
    [self setColor:[NSColor blackColor] forIndex:9];
    }
    return self;
}

-(void)dealloc {
	[indexedColormap release];
	[super dealloc];
}

-(void)setColor:(NSColor *)newColor forIndex:(int)index
{
  // Grow list automagically
  int i, maxColors = [indexedColormap count];
  if (index >= 0)
  {
    if (index >= maxColors)
    {
      // grow colormap to accomodate this color too by inserting clearColor inbetween indices
      for(i = 0; i < (index - maxColors + 1); i++)
      {
        [indexedColormap addObject:[NSColor clearColor]];
      }
    }
    [indexedColormap replaceObjectAtIndex:index withObject:newColor];
  }
}

-(NSColor *)colorForIndex:(int)index
    /**"
    *** AquaTerm uses is a color index to map to a set of
    *** colors. 
    *** Negative numbers have special meanings (-4 = background, -2 = axes, -1 = grid).
    "**/
{
  if (index<0)
  {
    switch (index)
    {
      case -1:
        return [NSColor lightGrayColor];
        break;
      case -2:
        return [NSColor blackColor];
        break;
      case -4:
        return [NSColor whiteColor];
        break;
      default:
        return [NSColor yellowColor];
        break;
    }
  }
  else
  {
    return [indexedColormap objectAtIndex:index];
  }
}

@end
