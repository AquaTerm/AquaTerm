//
//  AQTModel.h
//  AquaTerm
//
//  Created by per on Fri Nov 02 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

@interface AQTModel : AQTGraphic 
{
    NSMutableArray	*modelObjects;	/*" An array of GPTGraphic objects (leaf or collection) "*/ 
}
-(id)init;
-(void)addObject:(AQTGraphic *)graphic;
-(void)removeObject:(AQTGraphic *)graphic;
-(void)removeObjectsInRect:(NSRect)targetRect;
-(void)renderInRect:(NSRect)boundsRect;
@end
