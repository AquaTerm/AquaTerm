//
//  AQTColorMap.m
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//
#define specialsCount 4

#import "AQTColorMap.h"

@implementation AQTColorMap
-(id)init
{
  if (self = [super init])
  {
    indexedColormap = [[NSMutableArray alloc] initWithCapacity:256];	// 256 is a _hint_, not allocated!

    // Expand colormap to 8+4 colors
    [self setColor:[NSColor whiteColor] forIndex:-4];
    [self setColor:[NSColor blackColor] forIndex:-2];
    [self setColor:[NSColor lightGrayColor] forIndex:-1];
    [self setColor:[NSColor redColor] forIndex:0];
    [self setColor:[NSColor blueColor] forIndex:1];
    [self setColor:[NSColor greenColor] forIndex:2];
    [self setColor:[NSColor cyanColor] forIndex:3];
    [self setColor:[NSColor magentaColor] forIndex:4];
    [self setColor:[NSColor purpleColor] forIndex:5];
    [self setColor:[NSColor orangeColor] forIndex:6];
    [self setColor:[NSColor brownColor] forIndex:7];
    /*
    [self setColor:[NSColor purpleColor] forIndex:8];
    [self setColor:[NSColor redColor] forIndex:9];
    [self setColor:[NSColor blueColor] forIndex:10];
    [self setColor:[NSColor greenColor] forIndex:11];
    [self setColor:[NSColor cyanColor] forIndex:12];
    [self setColor:[NSColor magentaColor] forIndex:13];
    [self setColor:[NSColor brownColor] forIndex:14];
    [self setColor:[NSColor orangeColor] forIndex:15];
    [self setColor:[NSColor brownColor] forIndex:16];
    [self setColor:[NSColor purpleColor] forIndex:17];
    */
  }
  return self;
}

-(void)dealloc {
  [indexedColormap release];
  [super dealloc];
}

-(NSArray *)colorList
{
  return (NSArray *)indexedColormap;
}

-(void)setColorList:(NSArray *)colorList
{
  [indexedColormap setArray:colorList];
}

-(id)copyWithZone:(NSZone *)zone
{
  AQTColorMap *newColormap = [[AQTColorMap allocWithZone:zone] init];
  [newColormap setColorList:[self colorList]];
  return newColormap;
}

-(void)setColor:(NSColor *)newColor forIndex:(int)index
{
  // Grow list automagically
  int i, maxColors = [indexedColormap count];
  // Allow for specials
  index += specialsCount;

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
  else
  {
    NSLog(@"AQTColorMap(setColor::) - Invalid color index specified: %d", index-specialsCount);
  }
}

-(NSColor *)colorForIndex:(int)index
  /**"
  *** AquaTerm uses a color index to map to a set of
  *** colors.
  *** Negative numbers have special meanings (-4 = background, -2 = axes, -1 = grid).
  "**/
{
  // Allow for specials
  index += specialsCount;

  if (index < 0 || index >= [indexedColormap count])
  {
    NSLog(@"AQTColorMap(colorForIndex:) - Invalid color index specified");
    return [NSColor clearColor];
  }
  else
  {
    return [indexedColormap objectAtIndex:index];
  }
}

@end
