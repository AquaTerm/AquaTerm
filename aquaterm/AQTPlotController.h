//
//  AQTPlotController.h
//  AquaTerm
//
//  Created by Per Persson on Thu Nov 20 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTClientProtocol.h"
#import "AQTEventProtocol.h"

@class AQTModel;
@interface AQTPlotController : NSObject <AQTEventProtocol>
{
   id<AQTClientProtocol> _handler; 	/*" The handler object in AquaTerm responsible for communication "*/
}
- (void)setHandler:(id)newHandler;
- (void)setModel:(AQTModel *)newModel;

- (void)setAcceptingEvents:(BOOL)flag;

@end
