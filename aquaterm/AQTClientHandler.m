//
//  AQTClientHandler.m
//  AquaTerm
//
//  Created by Per Persson on Mon Jun 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "AQTClientHandler.h"
#import "AQTController.h"
// Temporary for stub creation:
#import "AQTModel.h"
#import "AQTColorMap.h"

@implementation AQTClientHandler
-(id)init
{
  if (self =  [super init])
  {
    NSLog(@"Initing handler");
  }
  return self;
}

-(void)dealloc
{
  NSLog(@"Over and out from %@", [self description]);
  [super dealloc];
}

-(void)setOwner:(AQTController *)ref
{
  owner = ref;
}

-(void)selectView:(int)aView
{
  NSLog(@"selectView: %d", aView);
  currentView = aView;
}

/*" The following methods applies to the currently selected view "*/
-(void)setModel:(id)aModel
{
  // Stub model
  AQTModel *stub = [[AQTModel alloc] initWithSize:NSMakeSize(300,200)];
  AQTColorMap *cm = [[AQTColorMap alloc] init];
  [stub setColormap:cm];
  [cm release];
  [owner setModel:stub forView:currentView];
  [stub release];
}

-(NSDictionary *)status
{
  NSDictionary *tmpDict = [NSDictionary dictionaryWithObject:@"Status line" forKey:@"theKey"];
  return tmpDict;
}

-(BOOL)doCursorFromPoint:(NSPoint)startPoint withOptions:(NSDictionary *)cursorOptions
{
  NSLog(@"doCursorFromPoint:");
  return NO;
}

-(void)close
{
  NSLog(@"close");
}
@end
