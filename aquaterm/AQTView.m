//
//  AQTView.m
//  AquaTerm
//
//  Created by Per Persson on Wed Apr 17 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "AQTView.h"
#import "AQTModel.h"
#import "AQTColorMap.h"

@implementation AQTView

// Should provide a -initWithFrame:model: 

-(void)dealloc
{
  [model release];
  [super dealloc];
}

-(void)setModel:(AQTModel *)newModel
{
  [newModel retain];
  [model release];		
  model = newModel;		
}

- (AQTModel *)model
{
  return model;
}

-(BOOL)isOpaque
{
  return YES;
}

-(BOOL)isPrinting
{
  return isPrinting;
}

-(void)setIsPrinting:(BOOL)flag
{
  isPrinting = flag;
}

-(void)drawRect:(NSRect)aRect
{
  NSRect theBounds = [self bounds];	// Depends on whether we're printing or drawing to screen
  if (!isPrinting)
  {
    //
    // Erase by drawing background color and a stylish line around the view
    //
    [[[model colormap] colorForIndex:-4] set];
    [[NSBezierPath bezierPathWithRect:theBounds] fill];
    [[NSColor blackColor] set];
    [[NSBezierPath bezierPathWithRect:theBounds] stroke];
  }
  //
  // Tell the model to draw itself
  //
  [model renderInRect:theBounds];
}

@end
