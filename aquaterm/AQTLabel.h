//
//  AQTLabel.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001-2012 The AquaTerm Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

@interface AQTLabel : AQTGraphic /*" NSObject "*/
{
   id string;		/*" The text (label, legend etc.) "*/
   NSString *fontName;
   float fontSize;
   NSPoint position;		/*" The position of the text "*/
   float angle;
   int32_t justification;		/*" Justification with respect to the position of the text "*/
   float shearAngle;
}
- (id)initWithAttributedString:(NSAttributedString *)aString position:(NSPoint)aPoint angle:(float)textAngle shearAngle:(float)shearAngle justification:(int32_t)justify;
- (id)initWithString:(NSString *)aString position:(NSPoint)aPoint angle:(float)textAngle shearAngle:(float)shearAngle justification:(int32_t)justify;
- (void)setFontName:(NSString *)newFontName;
- (void)setFontSize:(float)newFontSize;
@end
