//
//  AQTPath.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

/*" This balances the fixed size of the objects vs. the need for dynamic allocation of storage. "*/
#define STATIC_POINT_STORAGE 24
// FIXME: Base actual number on tests

@interface AQTPath : AQTGraphic 
{
   NSPointArray path;
   NSPoint staticPathStore[STATIC_POINT_STORAGE];
   NSPointArray dynamicPathStore;
   int pointCount;
   float linewidth;
   int lineCapStyle;
   BOOL isFilled;
}
- (id)initWithPoints:(NSPointArray)points pointCount:(int)pointCount;
- (void)setLinewidth:(float)lw;
- (void)setLineCapStyle:(int)capStyle;
- (void)setIsFilled:(BOOL)flag;
- (BOOL)isFilled;
@end
