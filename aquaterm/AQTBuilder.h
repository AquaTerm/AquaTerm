//
//  AQTBuilder.h
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 19 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AQTProtocol.h>

@class GPTController, AQTModel, AQTColorMap;
@interface AQTBuilder : NSObject <AQTProtocol>
{
  AQTModel 		*model;			/*" Graph being built "*/
  AQTColorMap	*colormap;		/*" Current Colormap, defaults to FIXME! "*/
  int			modelNumber;	/*" Current model number, set by client when initializing model "*/
  NSFont		*font;			/*" Current font, defaults to Times-Roman at 16pt "*/
  GPTController *renderer;		/*" Reference to object responsible for storing and rendering (finished) models "*/
}
-(void)setRenderer:(GPTController *)newRenderer;
-(GPTController *)renderer;
@end
