#import "GPTColorExtras.h"


@implementation NSColor (GPTColorExtras)
    /**"
    *** A category to provide some useful color mappings.
    "**/


    /**"
    *** Gnuplot uses is a mapping from [0 1] to an arbitrary color space and 
    *** +(NSColor *)interpolateColorFrom: to: by: defined does that for us.
    *** It returns an instance of NSColor that is an interpolation between 
    *** the colors c0 and c1. When gray is 0 the color is c0 and when gray 
    *** is 1 the returned color is c1.
    "**/
+(NSColor *)interpolateColorFrom:(NSColor *)c0 to: (NSColor *)c1 by:(double)param
{
    float   r=[c0 redComponent],
            g=[c0 greenComponent],
            b=[c0 blueComponent];
    float   zr = -(r - [c1 redComponent]),
            zg= -(g - [c1 greenComponent]),
            zb= -(b - [c1 blueComponent]);
    
    return [NSColor colorWithCalibratedRed:r+zr*param 
                                     green:g+zg*param 
                                      blue:b+zb*param 
                                     alpha:1.0];
}


    /**"
    *** Gnuplot uses is a color index to map linestyles to a set of fixed
    *** colors. The index is taken modulo max_number_of_colors.
    *** Negative numbers have special meanings (-2 = axes, -1 = grid).
    "**/
+(NSColor *)getColorFromIndex:(int)param
{
    switch (param % 9)
    {
        case -3:	// XOR, solid 
            return [NSColor yellowColor];
        case -2:	// border
            return [NSColor blackColor]; // axes
        case -1:	// X/Y axis
            return [NSColor lightGrayColor]; // grid
        case 0:
            return [NSColor redColor];
        case 1:
            return [NSColor greenColor];
        case 2:
            return [NSColor blueColor];
        case 3:
            return [NSColor cyanColor];
        case 4:
            return [NSColor magentaColor];
        case 5:
            return [NSColor orangeColor];
        case 6:
            return [NSColor purpleColor];
        case 7:
            return [NSColor brownColor];
        case 8:
            return [NSColor grayColor];
        default:
            return [NSColor yellowColor];
       } 
    return [NSColor yellowColor];
}
@end
