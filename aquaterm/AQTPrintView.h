#import <Cocoa/Cocoa.h>

@class AQTModel;

@interface AQTPrintView : NSView
{
  AQTModel *model;
}
- (id)initWithFrame:(NSRect)frameRect model:(AQTModel *)model;
@end
