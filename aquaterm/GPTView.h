#import <Cocoa/Cocoa.h>

//
// FIXME! These are "magic numbers", a real nono
//
#define AQUA_XMAX (11.69*72.0)    /* paper width times screen resolution. 11.69*72 = 841.68 */
#define AQUA_YMAX (8.26*72.0)	/* paper height times screen resolution. 8.26*72 = 594.72 */

@class GPTWindowController;

@interface GPTView : NSView
{
}
@end
