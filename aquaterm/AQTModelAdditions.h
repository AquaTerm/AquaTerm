//
//  AQTModelAdditions.h
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 09 2004.
//  Copyright (c) 2004-2012 The AquaTerm Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTModel.h"

@interface AQTModel (AQTModelAdditions)
-(void)invalidate;
-(void)clearDirtyRect;
-(void)appendModel:(AQTModel *)newModel;
-(void)removeGraphicsInRect:(AQTRect)targetRect;
@end
