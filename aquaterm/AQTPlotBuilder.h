//
//  AQTPlotBuilder.h
//  AquaTerm
//
//  Created by Per Persson on Sat Aug 16 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

@class AQTModel;
@interface AQTPlotBuilder : NSObject
{
  AQTModel *_model;	/*" The graph currently being built "*/
  int _modelRefNumber;	/*" Index into our handler's list of views "*/
  AQTColor _color;	/*" Currently selected color "*/
  NSString *_fontname;	/*" Currently selected font "*/
  float _fontsize;	/*" Currently selected fontsize [pt]"*/
  float _linewidth;	/*" Currently selected linewidth [pt] "*/
  NSPoint _path[256];	/*" A cache for coalescing connected line segments into a single path "*/
  int _pointCount;	/*" The current number of points in _path"*/
  BOOL _modelIsDirty;	/*" A flag indicating that AquaTerm has not been updated with the latest info "*/  
}
/*" Acessors "*/
- (void)setModel:(AQTModel *)newModel;
- (AQTModel *)model;
- (BOOL)modelIsDirty;
/*" Color handling "*/
  //- (AQTColor)color;
- (void)setColorRed:(float)r green:(float)g blue:(float)b;
 //- (void)setColor:(AQTColor)newColor;
  /*" Text handling "*/
- (NSString *)fontname;
- (void)setFontname:(NSString *)newFontname;
- (float)fontsize;
- (void)setFontsize:(float)newFontsize;
- (void)addLabel:(NSString *)text position:(NSPoint)pos angle:(float)angle justification:(int)just;
  /*" Line handling "*/
- (float)linewidth;
- (void)setLinewidth:(float)newLinewidth;
- (void)addLineAtPoint:(NSPoint)point;  // AQTPath
- (void)appendLineToPoint:(NSPoint)point;  // AQTPath
- (void)addPolygonWithPoints:(NSPoint *)points pointCount:(int)pc; // AQTPatch
  /*" Image handling "*/
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds; // AQTImage

  /*" Control operations "*/
- (void)eraseRect:(NSRect)aRect;

@end
