//
//  GPTPath.h
//  AGPTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GPTGraphic.h"

@interface GPTPath : GPTGraphic
{
    NSBezierPath *_gptPath;	/*" A collection of bezier paths sharing the same (style)properties "*/
    NSColor *_strokeColor;	/*" The (actual) stroke- and textcolor for a graphic object "*/
    NSColor *_fillColor;	/*" The fill color for a bezier path "*/
    int	_linestyle;		/*" The linestyle given by gnuplot, could mean color or dash depending on graphic object "*/
    BOOL _isFilled;		/*" TRUE => fill and stroke in _fillColor; FALSE => stroke in _strokeColor "*/
    float _gray;		/*" The parametrized fill color [0..1] "*/
    float _linewidth;		/*" The linewidth for a bezier path ** NOT USED ** "*/
}
-(id)initWithLinestyle:(int)linestyle  linewidth:(float)linewidth isFilled:(BOOL)isFilled gray:(float)gray path:(NSBezierPath *)path;
-(void)renderInRect:(NSRect)boundsRect;
@end
