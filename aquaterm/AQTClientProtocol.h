@protocol AQTClientProtocol
- (void)setPlot:(bycopy id)aPlot; // (id)?
- (void)appendPlot:(bycopy id)aPlot;
- (void)setAcceptingEvents:(BOOL)flag;
- (void)close;
@end
