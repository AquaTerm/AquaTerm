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

    /**"
    *** This is where the action happens. 
    *** Scale and draw the string with appropriate justification etc.
    "**/
-(void)renderInRect:(NSRect)boundsRect
{
  NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  NSAffineTransform *transf = [NSAffineTransform transform];
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  NSSize boundingBox;
  int i, l = [tmpString length];
  float xScale = boundsRect.size.width/canvasSize.width; // get scale changes wrt max size
  float yScale = boundsRect.size.height/canvasSize.height;
  float fontScale = sqrt(0.5*(xScale*xScale + yScale*yScale));  
  //
  // Scale the string FIXME: Speed up by using effective range!
  //
  for (i=0;i<l;i++)
  {
    NSFont *tmpFont = [[tmpString attributesAtIndex:i effectiveRange:nil] objectForKey:NSFontAttributeName];
    [tmpString addAttribute:NSFontAttributeName 
                      value:[NSFont fontWithName:[tmpFont fontName] size:max([tmpFont pointSize]*fontScale, MIN_FONTSIZE)] 				 					  range:NSMakeRange(i,1)];
  }
  boundingBox = [tmpString size];
  //
  // Position local coordinate system and apply justification
  //
  [transf translateXBy:xScale*position.x yBy:yScale*position.y];	// get translated origin
  [transf rotateByDegrees:angle];
  [transf translateXBy:-justification*boundingBox.width/2 yBy:-boundingBox.height/2];
  [context saveGraphicsState];
  [transf concat];
  [tmpString drawAtPoint:NSMakePoint(0,0)];
  [context restoreGraphicsState];

  [tmpString release];
}
@end
