//
//  AQTColorMap.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AQTColorMap : NSObject	
{
    NSMutableArray *indexedColormap;
}
-(void)setColor:(NSColor *)newColor forIndex:(int)index;
-(NSColor *)colorForIndex:(int)index;
@end
