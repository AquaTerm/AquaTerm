//
//  AQTLabel.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AQTGraphic.h"


#define justifyLeft 0
#define justifyCenter 1
#define justifyRight 2

@interface AQTLabel : AQTGraphic
{
    NSString *string;			/*" The text (label, legend etc.) "*/
    NSString *fontName;
    float fontSize;
    NSPoint position;			/*" The position of the text "*/
    float angle;		
    int justification;			/*" Justification with respect to the position of the text "*/
    int	colorIndex;				/*" The linestyle, could mean color or dash depending on graphic object "*/
}
-(id)initWithString:(NSString *)string attributes:(NSDictionary *)attrs position:(NSPoint)aPoint angle:(float)textAngle justification:(int)justify colorIndex:(int)cIndex;
-(void)renderInRect:(NSRect)boundsRect;
@end
