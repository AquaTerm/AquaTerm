//
//  GPTGraphic.h
//  AGPTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// @interface GPTGraphic : NSObject <NSCopying>	/* FAQ: Does this imply that all subclasses of GPTGraphic adopts NSCopying? */
@interface GPTGraphic : NSObject
{
}
-(id)init;
-(void)renderInRect:(NSRect)boundsRect;
@end
