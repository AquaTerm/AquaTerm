//
//  GPTLabel.m
//  Receiver
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "GPTLabel.h"
#import "GPTColorExtras.h"
#import "math.h"

#define max(a, b) a>b?a:b 

@implementation GPTLabel
    /**"
    *** A leaf object class representing an actual item in the plot. 
    *** Since the app is a viewer we do three things with the object:
    *** create (once), draw (any number of times) and (eventually) dispose of it.
    "**/

-(id)initWithLinestyle:(int)linestyle origin:(NSPoint)aPoint justification:(int)justify string:(NSString *)string attributes:(NSDictionary *)attrs;
{
    self=[super init];
    if (self)
    {
        _strokeColor = [[NSColor getColorFromIndex:linestyle] retain];
        _linestyle=linestyle; 
        _gptString = [[NSString alloc] initWithString:string];
        _attributes = [[NSDictionary alloc] initWithDictionary:attrs];
        _origin.x=aPoint.x;
        _origin.y=aPoint.y;
        _justify = justify;
    }
    return self; 
}


-(void)dealloc
{
    [_strokeColor release];
    [_attributes release];
    [_gptString release];
    [super dealloc];
}
/*
 * We don't need no copy-action…
 *
- (id)copyWithZone:(NSZone *)zone {
    id newObj = [[[self class] allocWithZone:zone] initWithLinestyle:_linestyle 
                                                   origin:_origin 
                                                   justification:_justify 
                                                   string:_gptString
                                                   attributes:_attributes];

    return newObj;
}
*/

    /**"
    *** This is where the action happens. 
    *** Scale and draw the string with appropriate justification etc.
    "**/
-(void)renderInRect:(NSRect)boundsRect
{
    float xScale, yScale, fontScale;
    NSSize boundingBox;
    NSSize docSize = NSMakeSize(842,595); // FIXME!!! Magic numbers representing an iso_a4 at 72dpi (max size)
    NSPoint point;
    NSMutableDictionary *scaledAttributes = [NSMutableDictionary dictionaryWithDictionary:_attributes];
    NSFont *theFont = [_attributes objectForKey:NSFontAttributeName];
    //
    // The view is resizable…
    // 
    xScale = boundsRect.size.width/docSize.width;		// get scale changes wrt max size 
    yScale = boundsRect.size.height/docSize.height;
    fontScale = sqrt(0.5*(xScale*xScale + yScale*yScale));	// Scale font size sensibly
    
    point.x=_origin.x*xScale;					// get translated origin
    point.y=_origin.y*yScale;

    // 
    // Set the attributes for the scaled string (restrict font size to [9pt - fontSize])
    // and get the bounding box for the string
    // FIXME!: another magic number (9) for min. font size
    //
    [scaledAttributes setObject:[NSFont fontWithName:[theFont fontName] size:max(([theFont pointSize] * fontScale ), 9.0)] forKey:NSFontAttributeName];
    [scaledAttributes setObject:_strokeColor forKey:NSForegroundColorAttributeName]; 
    boundingBox = [_gptString sizeWithAttributes:scaledAttributes];
    //
    // Apply justification
    //
    switch (_justify)
    {
        case justifyLeft: 
            point = NSMakePoint(point.x, point.y-boundingBox.height/2);
            break;
        case justifyRight:
            point = NSMakePoint(point.x-boundingBox.width, point.y-boundingBox.height/2);
            break;
        case justifyCenter: // Fallthrough
        default:
            point = NSMakePoint(point.x-boundingBox.width/2, point.y-boundingBox.height/2);
            break;        
    }
    //
    // Draw (finally!)
    //
    [_gptString drawAtPoint:point withAttributes:scaledAttributes];
}
@end
