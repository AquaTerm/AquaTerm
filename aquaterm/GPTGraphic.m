//
//  GPTGraphic.m
//  AGPTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "GPTGraphic.h"


@implementation GPTGraphic
    /**"
    *** An abstract class to derive model objects from
    *** (Overkill at present but could come in handy if the app grows…)
    "**/

-(id)init
{
    return [super init]; 
}

-(void)dealloc
{
    [super dealloc];
}

    /**" 
    *** Needs to be overridden in all subclasses to do actual drawing 
    "**/
-(void)renderInRect:(NSRect)boundsRect
{
    // Not purely abstract, draw a filled box to indicate trouble;-)
    [[NSColor redColor] set];
    [NSBezierPath fillRect:boundsRect];
}

@end
