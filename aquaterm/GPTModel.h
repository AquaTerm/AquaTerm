//
//  GPTModel.h
//  AquaTerm
//
//  Created by per on Fri Nov 02 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPTGraphic.h"

@interface GPTModel : GPTGraphic 
{
    NSMutableArray	*modelObjects;	/*" An array of GPTGraphic objects (leaf or collection) "*/ 
}
-(id)init;
-(void)addObject:(GPTGraphic *)aGPTObject;
-(void)renderInRect:(NSRect)boundsRect;
@end
