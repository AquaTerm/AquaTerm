//
//  AQTGraphic.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTGraphic.h"
#import "AQTColorMap.h"

@implementation AQTGraphic
    /**"
    *** An abstract class to derive model objects from
    *** (Overkill at present but could come in handy if the app grows…)
    "**/

-(id)init
{
    if (self = [super init])
    {
      // color = [[NSColor clearColor] retain]; // See-through color
      color = [[NSColor blackColor] retain];	// testing, remove!
    }
    return self; 
}

-(void)dealloc
{
  [color release];
  [super dealloc];
}
-(NSColor *)color
{
  return color;
}
//
//	Stubs, needs to be overridden by subclasses
// 
-(NSRect)bounds { return NSMakeRect(0,0,0,0); }
-(void)addObject:(AQTGraphic *)graphic {;}
-(void)removeObject:(AQTGraphic *)graphic {;}
-(void)removeObjectsInRect:(NSRect)targetRect {;}

    /**" 
    *** Needs to be overridden in all subclasses to do actual drawing 
    "**/
-(void)renderInRect:(NSRect)boundsRect
{
    // Not purely abstract, draw a filled box to indicate trouble;-)
    [[NSColor redColor] set];
    [NSBezierPath fillRect:boundsRect];
}

-(void)setColor:(NSColor *)newColor
{
  [newColor retain];
  [color release];
  color = newColor;
}

//
// I found the following commented out Mon Feb  4 01:28:48 CST 2002
// The program seems to be working, therefore I am going to delete this as cruft
// the next time I see it.
//
// Just thought I would make an explicit commit with this comment, in case
// this code unexpectedly disappeared. <BS>
//
/* Not compliant with new color handling 
-(void)setColorFromIndex:(int)theIndex
{
    switch (theIndex % 9)
    {
        case -3:	// XOR, solid 
            [self setColor:[NSColor yellowColor]];
            break;
        case -2:	// border
            [self setColor:[NSColor blackColor]]; // axes
            break;
        case -1:	// X/Y axis
            [self setColor:[NSColor lightGrayColor]]; // grid
            break;
        case 0:
            [self setColor:[NSColor redColor]];
            break;
        case 1:
            [self setColor:[NSColor greenColor]];
            break;
        case 2:
            [self setColor:[NSColor blueColor]];
            break;
        case 3:
            [self setColor:[NSColor cyanColor]];
            break;
        case 4:
            [self setColor:[NSColor magentaColor]];
            break;
        case 5:
            [self setColor:[NSColor orangeColor]];
            break;
        case 6:
            [self setColor:[NSColor purpleColor]];
            break;
        case 7:
            [self setColor:[NSColor brownColor]];
            break;
        case 8:
            [self setColor:[NSColor grayColor]];
            break;
        default:
            [self setColor:[NSColor yellowColor]];
       } 
}
*/

-(void)updateColors:(AQTColorMap *)colorMap
{
  // [self setColor:[NSString stringWithFormat:@"%d",colorIndex]];
  [self setColor:[colorMap colorForIndex:colorIndex]];
/*
 // AQTGraphic supports only indexed colors so we save a few tests by letting
 // subclasses that has continous color implement that
    if (hasIndexedColor)
    {	// Always brace in if-contructs! 
        [self setColor:[NSString stringWithFormat:@"%d",colorIndex]];
    }
    else
    {
        // do whatever is necessary for continuous color mode here
        // FIXME
    }
*/
}

@end
