//
//  AQTClientHandler.m
//  AquaTerm
//
//  Created by Per Persson on Mon Jun 09 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import "AQTClientHandler.h"
#import "AQTController.h"
// Temporary for stub creation:
#import "AQTModel.h"
#import "AQTPath.h"
#import "AQTLabel.h"
//#import "AQTColorMap.h"

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
/*
 // Stub model
  AQTModel *stub = [[AQTModel alloc] initWithSize:NSMakeSize(300,200)];
  AQTColorMap *cm = [[AQTColorMap alloc] init];
  AQTLabel *lb = [[AQTLabel alloc] initWithAttributedString:[[[NSAttributedString alloc]initWithString:@"Hello world!"] autorelease]
                                                   position:NSMakePoint(150, 100)
                                                      angle:45
                                              justification:1];
  AQTPath *pt = [[AQTPath alloc] initWithPolyline:[NSBezierPath bezierPathWithRect:NSMakeRect(10, 10, 280, 180)] colorIndex:2];
  [stub addObject:lb];
  [stub addObject:pt];
//  [stub setColormap:cm];
  [stub updateColors:cm];
  [owner setModel:stub forView:currentView];
  [pt release];
  [lb release];
  [cm release];
  [stub release];
*/
//  AQTColorMap *cm = [[AQTColorMap alloc] init];
//  [aModel setColormap:cm];
//  [aModel updateColors:cm];
  [owner setModel:aModel forView:currentView];
//  [cm release];
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
