#import <Cocoa/Cocoa.h>
#import <AQTProtocol.h>

@class GPTController, GPTModel;
@interface GPTReceiverObject : NSObject <AQTProtocol>
{
    NSConnection 	*gptConnection;		/*" The DO connection object "*/
    GPTController 	*listener;		/*" The object that listens to the messages from this object "*/
    GPTModel 		*gptModel;		/*" The graph being built "*/
    unsigned		currentFigure;		/*" The current term number, set by "set term aqua <n>" in gnuplot "*/
}
- (id)initWithListener:(GPTController *)listeningObject;
- (void)dealloc;
@end
