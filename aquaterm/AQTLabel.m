//
//  AQTLabel.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTLabel.h"
#import "math.h"

#define max(a, b) a>b?a:b 

@implementation AQTLabel
    /**"
    *** A leaf object class representing an actual item in the plot. 
    *** Since the app is a viewer we do three things with the object:
    *** create (once), draw (any number of times) and (eventually) dispose of it.
    "**/

-(id)initWithString:(NSString *)aString attributes:(NSDictionary *)attrs position:(NSPoint)aPoint angle:(float)textAngle justification:(int)justify colorIndex:(int)cIndex 
{
  if (self=[super init])
  {
    string = [[NSString alloc] initWithString:aString];
    fontName = [[NSString alloc] initWithString:[[attrs objectForKey:NSFontAttributeName] fontName]];
    fontSize =  [[attrs objectForKey:NSFontAttributeName] pointSize];
    position=aPoint;
    angle = textAngle;
    justification = justify;
    colorIndex=cIndex; 
  }
  return self; 
}

-(void)dealloc
{
  [string release];
  [fontName release];
  [super dealloc];
}

-(NSRect)bounds
{
  NSAffineTransform *tempTrans = [NSAffineTransform transform];
  NSDictionary *tempAttrs = [NSDictionary dictionaryWithObject:[NSFont fontWithName:fontName 																						  size:fontSize] 
                                                        forKey:NSFontAttributeName];
  NSRect tempBounds;
  NSPoint tempJust;

  [tempTrans rotateByDegrees:angle];
      
  tempBounds.size = [string sizeWithAttributes:tempAttrs];
  tempJust = [tempTrans  transformPoint:NSMakePoint(-justification*tempBounds.size.width/2, -tempBounds.size.height/2)];
  tempBounds.size = [tempTrans transformSize:[string sizeWithAttributes:tempAttrs]];
  
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
  NSAffineTransform *transf = [NSAffineTransform transform];
  NSMutableDictionary *scaledAttrs = [NSMutableDictionary dictionaryWithCapacity:2];
  NSSize docSize = NSMakeSize(842,595); 	// FIXME!!! Magic numbers representing an iso_a4 at 72dpi (max size)
  NSSize boundingBox;
  float xScale = boundsRect.size.width/docSize.width;				// get scale changes wrt max size
  float yScale = boundsRect.size.height/docSize.height;
  float fontScale = sqrt(0.5*(xScale*xScale + yScale*yScale));	// Scale font size sensibly;
  // 
  // Set the attributes for the scaled string (restrict font size to [9pt - fontSize])
  // and get the bounding box for the string
  // FIXME!: another magic number (9) for min. font size
  //
  [scaledAttrs setObject:[NSFont fontWithName:fontName size:max((fontSize * fontScale), 9.0)] forKey:NSFontAttributeName];
  [scaledAttrs setObject:color forKey:NSForegroundColorAttributeName]; 
  boundingBox = [string sizeWithAttributes:scaledAttrs];
  //
  // Position local coordinate system and apply justification
  //
  [transf translateXBy:xScale*position.x yBy:yScale*position.y];	// get translated origin
  [transf rotateByDegrees:angle];
  [transf translateXBy:-justification*boundingBox.width/2 yBy:-boundingBox.height/2];
  [transf concat];
  //
  // Draw (finally!)
  //
  [string drawAtPoint:NSMakePoint(0,0) withAttributes:scaledAttrs];
  // 
  // Restore orientation
  // 
  [transf invert];
  [transf concat];
  }
@end
