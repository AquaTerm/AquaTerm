//
//  AQTModelAdditions.h
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTModel.h"
#import "AQTFunctions.h"

@interface AQTModel (AQTModelAdditions)
-(void)invalidate;
-(void)clearDirtyRect;
-(void)appendModel:(AQTModel *)newModel;
-(void)removeGraphicsInRect:(NSRect)targetRect;
@end
