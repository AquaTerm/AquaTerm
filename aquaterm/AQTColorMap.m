//
//  AQTColorMap.m
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002-2003 Aquaterm. All rights reserved.
//

#import "AQTColorMap.h"

@implementation AQTColorMap
-(id)init
{
    return [self initWithColormapSize:1]; // Black
}

-(id)initWithColormapSize:(int)mapsize
{
  if (self = [super init])
  {
     size = (mapsize < 1)?1:mapsize;
     colormap = malloc(size*sizeof(AQTColor));
     if(!colormap)
     {
        [self autorelease];
        return nil;
     }
  }
  return self;
}

-(void)dealloc
{
   if (colormap)
   {
      free(colormap);
   }
   [super dealloc];
}

-(int)size
{
   return size;
}

-(void)setColor:(AQTColor)newColor forIndex:(int)index
{
   if (index >= 0 || index < size)
   {
      colormap[index] = newColor;
   }
}

-(AQTColor)colorForIndex:(int)index
{
  if (index < 0 || index >= size)
  {
    return colormap[0];
  }
  else
  {
    return colormap[index];
  }
}
@end
