//
//  AQTGraphic.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001, 2002 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AQTModel;

typedef struct _AQTColor {
   float red;
   float green;
   float blue;
} AQTColor;

@interface AQTGraphic : NSObject <NSCoding>
{
    NSSize canvasSize;
    AQTColor _color;
    NSRect _bounds;
    @protected
       id _cache;   
}

/*" accessor methods "*/
-(NSSize)canvasSize;
-(void)setCanvasSize:(NSSize)cs;
-(NSRect)bounds;
-(void)addObject:(AQTGraphic *)graphic;
-(void)removeObject:(AQTGraphic *)graphic;
-(void)removeObjectsInRect:(NSRect)targetRect;

/*" color handling "*/
-(AQTColor)color;
-(void)setColor:(AQTColor)newColor;
@end
