//
//  AQTColorMap.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface AQTColorMap : NSObject	
{
    NSMutableArray *indexedColormap;
}
-(void)setColor:(NSColor *)newColor forIndex:(int)index;
-(NSColor *)colorForIndex:(int)index;
-(NSArray *)colorList;
-(void)setColorList:(NSArray *)colorList;
@end
