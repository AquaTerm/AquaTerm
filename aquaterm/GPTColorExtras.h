#import <AppKit/NSColor.h>

@interface NSColor (GPTColorExtras) 
+(NSColor *)interpolateColorFrom:(NSColor *)c0 to: (NSColor *)c1 by:(double)param;
@end
