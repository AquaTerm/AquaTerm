#import <Cocoa/Cocoa.h>
#import <AQTProtocol.h>

@class GPTController, AQTModel;
@interface GPTReceiverObject : NSObject <AQTProtocol>
{
    NSConnection 	*gptConnection;		/*" The DO connection object "*/
    GPTController 	*listener;		/*" The object that listens to the messages from this object "*/
    AQTModel 		*aqtModel;		/*" The graph being built "*/
    unsigned		currentFigure;		/*" The current term number, set by "set term aqua <n>" in gnuplot "*/
    NSFont		*currentFont;		/*" The current font, defaults to Times-Roman at 16pt"*/
}
- (id)initWithListener:(GPTController *)listeningObject;
- (void)dealloc;
- (NSConnection *)connection;
@end
