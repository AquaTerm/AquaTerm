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

/*" The following methods applies to the currently selected view "*/
-(void)setModel:(id)aModel
{
  NSString *key = [NSString stringWithFormat:@"%d", currentView];
  AQTPlot *thePlot = [plotList objectForKey:key]; 
  
  if (!thePlot)
  {
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
