//
//  AQTLabel.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTLabel.h"
#import "AQTModel.h"
#import "math.h"

#define max(a, b) a>b?a:b 
#define MIN_FONTSIZE 9.0

@implementation AQTLabel
    /**"
    *** A leaf object class representing an actual item in the plot. 
    *** Since the app is a viewer we do three things with the object:
    *** create (once), draw (any number of times) and (eventually) dispose of it.
    "**/

-(id)initWithAttributedString:(NSAttributedString *)aString position:(NSPoint)aPoint angle:(float)textAngle justification:(int)justify  
{
  if (self=[super init])
  {
    string = [[NSAttributedString alloc] initWithAttributedString:aString];
    position=aPoint;
    angle = textAngle;
    justification = justify;
  }
  return self; 
}

-(void)dealloc
{
  [string release];
  [super dealloc];
}

-(NSRect)bounds
{
  NSAffineTransform *tempTrans = [NSAffineTransform transform];
  NSRect tempBounds;
  NSPoint tempJust;

  [tempTrans rotateByDegrees:angle];

  tempBounds.size = [string size];
  tempJust = [tempTrans  transformPoint:NSMakePoint(-justification*tempBounds.size.width/2, -tempBounds.size.height/2)];
  tempBounds.size = [tempTrans transformSize:[string size]];

  tempBounds.origin.x = position.x+tempJust.x;
  tempBounds.origin.y = position.y+tempJust.y;
  return tempBounds;
}
@end
