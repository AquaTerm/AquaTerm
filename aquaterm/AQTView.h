//
//  AQTView.h
//  AquaTerm
//
//  Created by Per Persson on Wed Apr 17 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

//
// FIXME! These are "magic numbers", a real nono
//
#define AQUA_XMAX (11.69*72.0)    /* paper width times screen resolution. 11.69*72 = 841.68 */
#define AQUA_YMAX (8.26*72.0)	/* paper height times screen resolution. 8.26*72 = 594.72 */

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
