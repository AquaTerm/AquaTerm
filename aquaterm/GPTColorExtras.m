//
// GPTColorExtras.m
//

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

@end
