//
//  AQTClientHandler.m
//  AquaTerm
//
//  Created by Per Persson on Mon Jun 09 2003.
//  Copyright (c) 2003 AquaTerm. All rights reserved.
//

#import "AQTClientHandler.h"
#import "AQTController.h"
#import "AQTPlot.h"

@implementation AQTClientHandler
-(id)init
{
  if (self =  [super init])
  {
    NSLog(@"Initing handler");
    plotList = [[NSMutableDictionary alloc] initWithCapacity:16];
  }
  return self;
}

-(void)dealloc
{
  NSLog(@"Over and out from %@", [self description]);
  [plotList release];
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

-(AQTPlot *)_plotForView:(int)ref
{
  NSString *key = [NSString stringWithFormat:@"%d", ref];
  return [plotList objectForKey:key]; 
}

/*" The following methods applies to the currently selected view "*/
-(void)setModel:(id)aModel
{
  AQTPlot *thePlot = [self _plotForView:currentView]; //[plotList objectForKey:key]; 
  
  if (!thePlot)
  {
    NSString *key = [NSString stringWithFormat:@"%d", currentView];
    thePlot = [[AQTPlot alloc] initWithModel:aModel index:currentView];
    [plotList setObject:thePlot forKey:key];
    [thePlot release];
  }

  [thePlot setModel:aModel];
}

-(NSDictionary *)status
{
  NSDictionary *tmpDict = [NSDictionary dictionaryWithObject:@"Status line" forKey:@"theKey"];
  return tmpDict;
}

-(void)beginMouse
{
 [[self _plotForView:currentView] beginMouseInput];//FIXME: change method to beginMouse
}

-(BOOL)mouseIsDone
{
  return [[self _plotForView:currentView] selectedPointIsValid]; //FIXME: change method to mouseIsDone
}

-(char)mouseDownInfo:(inout NSPoint *)mouseLoc
{
  *mouseLoc = [[self _plotForView:currentView] selectedPoint];
  return [[self _plotForView:currentView] keyPressed];
}

/*
-(BOOL)doCursorFromPoint:(NSPoint)startPoint withOptions:(NSDictionary *)cursorOptions
{
  NSLog(@"doCursorFromPoint:");
  return NO;
}
*/
-(void)close
{
  NSLog(@"close");
}
@end
