//
//  AQTColorMap.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002-2012 The AquaTerm Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

typedef AQTColor *AQTColorPtr;

@interface AQTColorMap : NSObject	
{
   AQTColorPtr colormap; // NB. Not an object but a pointer to a struct
   int32_t size; 
}
-(id)initWithColormapSize:(int32_t)size;
-(int32_t)size;
-(void)setColor:(AQTColor)newColor forIndex:(int32_t)index;
-(AQTColor)colorForIndex:(int32_t)index;
@end
