//
//  GPTModel.m
//  AquaTerm
//
//  Created by per on Fri Nov 02 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "GPTModel.h"
#import "GPTLabel.h"

@implementation GPTModel
    /**"
    *** A class representing a collection of objects making up the plot. 
    *** The objects can be leaf object like GPTPath and GPTLabel or a 
    *** collection itself (not exploited at present).
    "**/

-(id)init	
{
    self = [super init];
    if (self)
    {
        modelObjects = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

-(void)dealloc
{
   [modelObjects release];
   [super dealloc];
}

    /**"
    *** A description of the collection of objects (for debugging).
    "**/
-(NSString *)description
{
    int labels=0, paths=0;
    GPTGraphic *gptObject;

    NSEnumerator *enumerator = [modelObjects objectEnumerator];
    
    while ((gptObject = [enumerator nextObject]))
    {
       if ([gptObject isKindOfClass:[GPTLabel class]])
       {
            labels++;
       }
       else
       {
            paths++;
       }
    }
    return [NSString stringWithFormat:@"GPTModel with %d GPTPath(s) and %d GPTLabel(s)\n", paths, labels];
}

    /**"
    *** Add any subclass of GPTGraphic to the collection of objects.
    "**/
-(void)addObject:(GPTGraphic *)aGPTObject
{
    [modelObjects addObject:aGPTObject];
}

    /**"
    *** Tell every object in the collection to draw itself.
    "**/
-(void)renderInRect:(NSRect)boundsRect
{
    GPTGraphic *gptObject;
    NSEnumerator *enumerator = [modelObjects objectEnumerator];
    
    while ((gptObject = [enumerator nextObject]))
    {
       [gptObject renderInRect:boundsRect];
    }
}
@end
