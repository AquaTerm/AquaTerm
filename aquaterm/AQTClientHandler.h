//
//  AQTClientHandler.h
//  AquaTerm
//
//  Created by Per Persson on Mon Jun 09 2003.
//  Copyright (c) 2003 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTClientProtocol.h"

@class AQTController;
@interface AQTClientHandler : NSObject <AQTClientProtocol>
{
  AQTController *owner;
  int currentView;
}
-(void)setOwner:(AQTController *)ref;
@end
