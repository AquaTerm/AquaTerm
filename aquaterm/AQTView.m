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

-(void)setModel:(AQTModel *)newModel
{
  [newModel retain];
  [model release];		// let go of old model
  model = newModel;		// Make it point to new model (FIXME: multiplot requires care! OK)
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
/*
-(void)setPrintBounds:(NSRect)newBounds
{
  printBounds = newBounds;
}

-(NSRect)bounds
{
  NSRect theBounds;
  if(isPrinting)
  {
    theBounds = printBounds;
  }
  else
  {
    theBounds = [super bounds];
  }
  return theBounds;
}
*/

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

/*
 -(void)drawRect:(NSRect)aRect
 {
   if (isPrinting)
   {
     [self drawPrintRect:aRect];
   }
   else
   {
     [self drawScreenRect:aRect];
   }
 }

 -(void)drawScreenRect:(NSRect)aRect
 {
   NSRect theBounds = [self bounds];
   //
   // Erase by drawing background color and draw a stylish line around the view
   //
   [[[model colormap] colorForIndex:-4] set];
   [[NSBezierPath bezierPathWithRect:theBounds] fill];
   [[NSColor blackColor] set];
   [[NSBezierPath bezierPathWithRect:theBounds] stroke];
   //
   // Tell the model to draw itself
   //
   [model renderInRect:theBounds];
 }

 -(void)drawPrintRect:(NSRect)aRect
 {
   NSRect theBounds = [self bounds];
   [model renderInRect:theBounds];
 }
 */
@end
