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
    AQTColor _color;
    NSRect _bounds;
    NSRect _clipRect;
    BOOL _isClipped;
    @protected
       id _cache;   
}

/*" accessor methods "*/
-(NSRect)bounds;
-(void)setBounds:(NSRect)bounds;
-(NSRect)clipRect;
-(void)setClipRect:(NSRect)clipRect;
-(void)setIsClipped:(BOOL)clipState;

/*" color handling "*/
-(AQTColor)color;
-(void)setColor:(AQTColor)newColor;
@end
