//
//  AQTGraphicDrawingMethods.h
//  AquaTerm
//
//  Created by Per Persson on Mon Oct 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTGraphic.h"


@interface AQTGraphic (AQTGraphicDrawingMethods)
-(id)_cache;
-(void)_setCache:(id)object;
-(void)renderInRect:(NSRect)boundsRect;
@end
