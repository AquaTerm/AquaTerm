//
//  AQTLabel.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AQTGraphic.h"

/*" Justification Constants "*/
#define justifyLeft 0
#define justifyCenter 1
#define justifyRight 2

@interface AQTLabel : AQTGraphic /*" NSObject "*/
{
    NSAttributedString *string;		/*" The text (label, legend etc.) "*/
    NSPoint position;		/*" The position of the text "*/
    float angle;		
    int justification;		/*" Justification with respect to the position of the text "*/
}
-(id)initWithAttributedString:(NSAttributedString *)aString position:(NSPoint)aPoint angle:(float)textAngle justification:(int)justify;
-(void)renderInRect:(NSRect)boundsRect;
@end
