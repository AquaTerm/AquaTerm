//
//  GPTLabel.h
//  AGPTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GPTGraphic.h"


#define justifyLeft 0
#define justifyCenter 1
#define justifyRight 2

@interface GPTLabel : GPTGraphic
{
    NSColor *_strokeColor;	/*" The (actual) stroke- and textcolor for a graphic object "*/
    int	_linestyle;		/*" The linestyle given by gnuplot, could mean color or dash depending on graphic object "*/
    NSString *_gptString;	/*" The text (label, legend etc.) "*/
    NSDictionary *_attributes;	/*" The attributes associated with the text (font, size etc.) "*/
    NSPoint _origin;		/*" The position of the text "*/
    int _justify;		/*" Justification with respect to the position of the text "*/
    float _angle;		
}
-(id)initWithLinestyle:(int)linestyle origin:(NSPoint)aPoint justification:(int)justify angle:(float)angle string:(NSString *)string attributes:(NSDictionary *)attrs;
-(void)renderInRect:(NSRect)boundsRect;
@end
