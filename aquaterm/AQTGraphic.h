//
//  AQTGraphic.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AQTGraphic : NSObject
{
    NSColor *color;
}
-(id)init;
-(NSRect)bounds;
-(NSColor *)color;
-(void)addObject:(AQTGraphic *)graphic;
-(void)removeObject:(AQTGraphic *)graphic;
-(void)removeObjectsInRect:(NSRect)targetRect;
-(void)renderInRect:(NSRect)boundsRect;
@end
