//
//  GPTPath.m
//  AGPTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "GPTPath.h"
#import "GPTColorExtras.h"

@implementation GPTPath
    /**"
    *** A leaf object class representing an actual item in the plot. 
    *** Since the app is a viewer we do three things with the object:
    *** create (once), draw (any number of times) and (eventually) dispose of it.
    "**/

-(id)initWithLinestyle:(int)linestyle  linewidth:(float)linewidth isFilled:(BOOL)isFilled gray:(float)gray path:(NSBezierPath *)path
{
    if (self = [super init])
    {
        _gptPath = [[NSBezierPath bezierPath] retain];
        [_gptPath appendBezierPath:path];	
        _strokeColor = [[NSColor getColorFromIndex:linestyle] retain];
        _linestyle=linestyle; 
        _linewidth = linewidth;
        _isFilled = isFilled;
        if (isFilled)
        {
            //
            // gray is a mapping from [0 1] to an arbitrary color space
            // +(NSColor *)interpolateColorFrom: to: by: defined in NSColorExtras.h does that for us
            //
            _gray = gray;
            _fillColor = [[NSColor interpolateColorFrom:[NSColor redColor] to:[NSColor yellowColor] by:gray] retain];
        }
        else
        {
            _gray = 0;
            _fillColor = [[NSColor whiteColor] retain];
        }
    }
    return self; 
}

-(void)dealloc
{
    [_gptPath release];
    [_strokeColor release];
    [_fillColor release];
    [super dealloc];
}

/*
 * We don't need no copy-action…
 *
- (id)copyWithZone:(NSZone *)zone {
    id newObj = [[[self class] allocWithZone:zone]  initWithLinestyle:_linestyle 
                                                    linewidth:_linewidth 
                                                    isFilled:_isFilled
                                                    gray:_gray 
                                                    path:_gptPath];
    return newObj;
}
*/

    /**"
    *** This is where the action happens. 
    *** Scale and draw the path with appropriate color, fill etc.
    "**/
-(void)renderInRect:(NSRect)boundsRect
{
    NSSize docSize = NSMakeSize(842,595); // FIXME!!! Should refer to document size instead
    NSAffineTransform *localTransform = [NSAffineTransform transform];
    float xScale = boundsRect.size.width/docSize.width;
    float yScale = boundsRect.size.height/docSize.height;
    //
    // Get the transform due to view resizing
    //
    [localTransform scaleXBy:xScale yBy:yScale];
    if (_isFilled)
    {
        [_fillColor set];
        [[localTransform transformBezierPath:_gptPath] fill];
        [[localTransform transformBezierPath:_gptPath] stroke];	// FAQ: Needed unless we holes in the surface? 
    }
    else
    {
        [_strokeColor set];
        [[localTransform transformBezierPath:_gptPath] stroke];
    }
}

@end
