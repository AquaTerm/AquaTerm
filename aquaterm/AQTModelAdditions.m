//
//  AQTModelAdditions.m
//  AquaTerm
//
//  Created by Per Persson on Wed Jun 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "AQTModelAdditions.h"
#import "AQTGraphicDrawingMethods.h"

@implementation AQTModel (AQTModelAdditions)
-(void)invalidate
{
   dirtyRect = AQTRectFromSize([self canvasSize]);
}

-(void)clearDirtyRect
{
   dirtyRect = NSZeroRect;
}

-(void)appendModel:(AQTModel *)newModel
{
   
   // FIXME: Check for change in canvasSize, and act on it!
   BOOL backgroundDidChange; // FIXME
   NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
   backgroundDidChange = !AQTEqualColors([self color], [newModel color]);
   [self setTitle:[newModel title]];
   [self setColor:[newModel color]];
   [self setBounds:AQTUnionRect([self bounds], [newModel updateBounds])];
   [self addObjectsFromArray:[newModel modelObjects]];
   NSLog(@"oldBounds = %@", NSStringFromRect([self bounds]));
   NSLog(@"addedBounds = %@", NSStringFromRect([newModel bounds]));
   
   dirtyRect = backgroundDidChange?AQTRectFromSize([self canvasSize]):AQTUnionRect(dirtyRect, [newModel bounds]);
   NSLog(@"dirtyRect = %@", NSStringFromRect(dirtyRect));
}



- (void)removeGraphicsInRect:(NSRect)targetRect
{
    // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
    NSRect testRect;
    NSRect clipRect = AQTRectFromSize([self canvasSize]);
    NSRect newBounds = NSZeroRect;
    int i;
    int  objectCount = [self count];
    
    // check for nothing to remove or disjoint modelBounds <--> targetRect
    if (objectCount == 0 || AQTIntersectsRect(targetRect, [self bounds]) == NO)
    return;
    
    // Apply clipRect (=canvasRect) to graphic bounds before comparing.
    if (AQTContainsRect(targetRect, NSIntersectionRect([self bounds], clipRect)))
    {
       [self removeAllObjects];
    }
    else
    {
       for (i = objectCount - 1; i >= 0; i--)
       {
          testRect = [[modelObjects objectAtIndex:i] bounds];
          if (AQTContainsRect(targetRect, NSIntersectionRect(testRect, clipRect)))
          {
             [self removeObjectAtIndex:i];
          }
          else
          {
             newBounds = AQTUnionRect(newBounds, testRect);
          }
       }
    }
    [self setBounds:newBounds];
    // NSLog(@"Removed %d objs, new bounds: %@", objectCount - [modelObjects count], [self description]);
    dirtyRect = AQTUnionRect(dirtyRect, targetRect);
}

@end
