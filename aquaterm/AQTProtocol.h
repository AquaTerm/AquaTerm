#import "AQTBaseMethods.h"
#import "AQTExtendedMethods.h"


#define AQTProtocolVersion 0.3.1


@protocol AQTProtocol<AQTBaseMethods, AQTExtendedMethods>
/*" Compatibility definition. As of v0.3.1 the methods previoulsy declared in 
AQTProtocol has been split into AQTBaseMethods containing only Foundation code and  AQTExtendedMethods containing AppKit code "*/
@end
