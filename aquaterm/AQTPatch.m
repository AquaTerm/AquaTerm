//
//  AQTPatch.m
//  AquaTerm
//
//  Created by Per Persson on Mon Jul 14 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "AQTPatch.h"


@implementation AQTPatch
-(id)initWithPoints:(NSPointArray)points pointCount:(int)pc //  color:(AQTColor)aColor
{
  if (self = [super initWithPoints:points pointCount:pc]) // color:aColor])
  {
    [self setLinewidth:0.5];
  }
  return self;
}

-(id)initWithXCoords:(float *)x yCoords:(float *)y pointCount:(int)pc // color:(AQTColor)aColor
{
   if (self = [super initWithXCoords:x yCoords:y pointCount:pc]) // color:aColor])
   {
      [self setLinewidth:0.5];
   }
   return self;
}
@end
