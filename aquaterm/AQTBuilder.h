//
//  AQTBuilder.h
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 19 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AQTBaseMethods.h>
#import <AQTExtendedMethods.h>

#define AQT_XMAX (11.69*72.0)    /* paper width times screen resolution. 11.69*72 = 841.68 */
#define AQT_YMAX (8.26*72.0)	/* paper height times screen resolution. 8.26*72 = 594.72 */


@class AQTController, AQTModel, AQTColorMap;
@interface AQTBuilder : NSObject <AQTBaseMethods, AQTExtendedMethods>
{
  AQTModel 		*model;			/*" Graph being built "*/
  AQTColorMap	*colormap;		/*" Current Colormap, defaults to FIXME! "*/
  int			modelNumber;	/*" Current model number, set by client when initializing model "*/
  NSFont		*font;			/*" Current font, defaults to Times-Roman at 16pt "*/
  AQTController *renderer;		/*" Reference to object responsible for storing and rendering (finished) models "*/
  // ---- Timing for adapter testing -----
  NSDate		*startTime;
}
-(void)setRenderer:(AQTController *)newRenderer;
-(AQTController *)renderer;
@end
