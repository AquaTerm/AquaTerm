//
//  AQTLabel.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import "AQTLabel.h"

/*" Justification Constants "*/
#define justifyLeft 0
#define justifyCenter 1
#define justifyRight 2

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
    fontName = @"Times-Roman";
    fontSize = 14.0;
    position=aPoint;
    angle = textAngle;
    justification = justify;
  }
  return self; 
}

-(id)initWithString:(NSString *)aString position:(NSPoint)aPoint angle:(float)textAngle justification:(int)justify
{
  
  return [self initWithAttributedString:[[[NSAttributedString alloc] initWithString:aString] autorelease]
                               position:aPoint
                                  angle:textAngle
                          justification:justify];
}


-(void)dealloc
{
  [string release];
  [fontName release];
  [super dealloc];
}

- (void)setFontName:(NSString *)newFontName
{
  if (fontName != newFontName)
  {
    NSString *oldValue = fontName;
    fontName = [newFontName retain];
    [oldValue release];
  }
}

- (void)setFontSize:(float)newFontSize
{
    fontSize = newFontSize;
}

-(NSString *)description
{
  return [NSString stringWithFormat:@"%@\nwith string:\n%@", [super description], [string description]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder:coder];
  [coder encodeObject:string];
  [coder encodeObject:fontName];
  [coder encodeValueOfObjCType:@encode(float) at:&fontSize];
  [coder encodeValueOfObjCType:@encode(NSPoint) at:&position];
  [coder encodeValueOfObjCType:@encode(float) at:&angle];
  [coder encodeValueOfObjCType:@encode(int) at:&justification];
}

-(id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  string = [[coder decodeObject] retain];
  fontName = [[coder decodeObject] retain];
  [coder decodeValueOfObjCType:@encode(float) at:&fontSize];
  [coder decodeValueOfObjCType:@encode(NSPoint) at:&position];
  [coder decodeValueOfObjCType:@encode(float) at:&angle];
  [coder decodeValueOfObjCType:@encode(int) at:&justification];
  return self;
}

// FIXME: bounds disabled
-(NSRect)bounds
{
  return NSMakeRect(20,20,20,20);
/*
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
 */
  
}
@end
