//
//  AQTGraphicDrawingMethods.h
//  AquaTerm
//
//  Created by Per Persson on Mon Oct 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AQTGraphic.h"
#import "AQTModel.h"


@interface AQTGraphic (AQTGraphicDrawingMethods)
+ (NSImage *)sharedScratchPad;
-(id)_cache;
-(void)_setCache:(id)object;
-(NSRect)updateBounds;
-(void)renderInRect:(NSRect)boundsRect; // <--- canvas coords
@end

@interface AQTModel (AQTModelExtensions)
-(void)appendModel:(AQTModel *)aModel;
-(void)removeObjectsInRect:(NSRect)targetRect;
@end


