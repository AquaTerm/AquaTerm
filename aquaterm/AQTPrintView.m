#import "AQTPrintView.h"
#import "AQTModel.h"

@implementation AQTPrintView
- (id)initWithFrame:(NSRect)frameRect model:(AQTModel *)aModel
{
  if (self = [super initWithFrame:frameRect])
  {
    model = aModel;
  }
  return self;
}

-(void)dealloc
{
  [super dealloc];
}

-(BOOL)isOpaque
{
  return YES;	// FIXME: Is this correct in this context? (Printing)
}

-(void)drawRect:(NSRect)aRect
{
  NSRect theBounds = [self bounds];
  [model renderInRect:theBounds];
}
@end















