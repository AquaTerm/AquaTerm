//
//  AQTColorMap.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002-2003 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

typedef AQTColor *AQTColorPtr;

@interface AQTColorMap : NSObject	
{
   AQTColorPtr colormap; // NB. Not an object but a pointer to a struct
   int size; 
}
-(id)initWithColormapSize:(int)size;
-(void)setColor:(AQTColor)newColor forIndex:(int)index;
-(AQTColor)colorForIndex:(int)index;
@end
