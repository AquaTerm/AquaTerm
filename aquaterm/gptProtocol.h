@protocol gptProtocol
- (oneway void) gptRenderRelease:(BOOL)yesOrNo;
- (oneway void) gptPutString:(bycopy NSString *)textString AtPoint:(bycopy NSPoint)coord WithJustification:(bycopy int) mode WithLinetype:(bycopy int) linetype;
- (oneway void) gptSetFont:(bycopy NSString *)font;
- (oneway void) gptSetPath:(bycopy NSBezierPath *)aPath WithLinetype:(bycopy int) linetype FillColor:(bycopy double) gray PathIsFilled:(bycopy BOOL)isFilled;
- (oneway void) gptCurrentWindow:(int) currentWindow;
// ---- the following two are stubs -----------
- (oneway void) gptPointsize:(double) pointsize;
- (oneway void) gptDidSetPointsize:(double) size;
@end
