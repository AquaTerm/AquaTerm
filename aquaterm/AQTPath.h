//
//  AQTPath.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

#define MAX_PATH_POINTS 256

@interface AQTPath : AQTGraphic 
{
   NSPoint path[MAX_PATH_POINTS];
   int pointCount;
   BOOL isFilled;
}
-(id)initWithPoints:(NSPointArray)points pointCount:(int)pointCount filled:(BOOL)fill color:(AQTColor)aColor;
@end
