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
   float linewidth;
}
- (id)initWithPoints:(NSPointArray)points pointCount:(int)pointCount color:(AQTColor)aColor;
- (void)setLinewidth:(float)lw;
@end
