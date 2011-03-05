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
   float alpha;
} AQTColor;

typedef struct _AQTPoint {
  float x;
  float y;
} AQTPoint;

typedef struct _AQTSize {
  float width;
  float height;
} AQTSize;

typedef struct _AQTRect {
  AQTPoint origin;
  AQTSize size;
} AQTRect;

@interface AQTGraphic : NSObject <NSCoding>
{
    AQTColor _color;
    NSRect _bounds;
    NSRect _clipRect;
    BOOL _isClipped;
    BOOL _shouldShowBounds;
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
