//
//  AQTView.h
//  AquaTerm
//
//  Created by Per Persson on Wed Apr 17 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@class AQTModel;
@interface AQTView : NSView
{
  AQTModel *model;
  BOOL isPrinting;
}
- (void)setModel:(AQTModel *)newModel;
- (AQTModel *)model;
- (void)setIsPrinting:(BOOL)flag;
- (BOOL)isPrinting;
@end
