#import "AQTPrefController.h"

@implementation AQTPrefController
+ (AQTPrefController *)sharedPrefController
{
   static AQTPrefController *sharedPrefController = nil;
   if (sharedPrefController == nil) {
      sharedPrefController = [[self alloc] init];
   }   return sharedPrefController;
}

-(id)init
{
   if (self = [super init])
   {
      [NSBundle loadNibNamed:@"Preferences.nib" owner:self];
   }
   return self;
}

-(void)awakeFromNib
{
   [self showPrefs]; 
}

- (void)showPrefs {
   float lw = [preferences floatForKey:@"MinimumLinewidth"];
   [imageInterpolateLevel selectItemAtIndex:[preferences integerForKey:@"ImageInterpolationLevel"]];
   [crosshairCursorColor selectItemAtIndex:[preferences integerForKey:@"CrosshairCursorColor"]];
   [shouldAntialiasSwitch setIntegerValue:[preferences integerForKey:@"ShouldAntialiasDrawing"]];
   [minimumLinewidthSlider setDoubleValue:lw];
   [linewidthDisplay setStringValue:(lw < 0.04)?@"off":[NSString stringWithFormat:@"%4.2f", lw]];
   [minimumLinewidthSlider setDoubleValue:[preferences floatForKey:@"MinimumLinewidth"]];
   [convertSymbolFontSwitch setIntegerValue:[preferences integerForKey:@"ShouldConvertSymbolFont"]];
   [closeWindowSwitch setIntegerValue:[preferences integerForKey:@"CloseWindowWhenClosingPlot"]];
   [confirmCloseWindowSwitch setIntegerValue:[preferences integerForKey:@"ConfirmCloseWindowWhenClosingPlot"]];
   [showProcessNameSwitch setIntegerValue:[preferences integerForKey:@"ShowProcessName"]];
   [showProcessIdSwitch setIntegerValue:[preferences integerForKey:@"ShowProcessId"]];
   
   [confirmCloseWindowSwitch setEnabled:([closeWindowSwitch integerValue] == 0)?NO:YES];
   [self updateTitleExample:self];
   [prefWindow makeKeyAndOrderFront:self];
}

- (IBAction)windowClosingChanged:(id)sender
{
   [confirmCloseWindowSwitch setEnabled:([closeWindowSwitch integerValue] == 0)?NO:YES];
}

- (IBAction)updateTitleExample:(id)sender
{
   [titleExample setStringValue:[NSString stringWithFormat:@"%@%@Figure 1", [showProcessNameSwitch integerValue]?@"gnuplot ":@"", [showProcessIdSwitch integerValue]?@"(1151) ":@""]];
}

- (IBAction)cancelButtonPressed:(id)sender
{
   [prefWindow orderOut:self];   
}

- (IBAction)OKButtonPressed:(id)sender
{
   [preferences setInteger:[imageInterpolateLevel indexOfSelectedItem] forKey:@"ImageInterpolationLevel"];
   [preferences setInteger:[crosshairCursorColor indexOfSelectedItem] forKey:@"CrosshairCursorColor"];
   [preferences setInteger:[shouldAntialiasSwitch integerValue] forKey:@"ShouldAntialiasDrawing"];
   [preferences setFloat:[minimumLinewidthSlider doubleValue] forKey:@"MinimumLinewidth"];
   [preferences setInteger:[convertSymbolFontSwitch integerValue] forKey:@"ShouldConvertSymbolFont"];
   [preferences setInteger:[closeWindowSwitch integerValue] forKey:@"CloseWindowWhenClosingPlot"];
   [preferences setInteger:[confirmCloseWindowSwitch integerValue] forKey:@"ConfirmCloseWindowWhenClosingPlot"];
   [preferences setInteger:[showProcessNameSwitch integerValue] forKey:@"ShowProcessName"];
   [preferences setInteger:[showProcessIdSwitch integerValue] forKey:@"ShowProcessId"];
   [prefWindow orderOut:self];
}

- (IBAction)linewidthSliderMoved:(id)sender
{
   float lw = [sender doubleValue];
   [linewidthDisplay setStringValue:(lw < 0.04)?@"off":[NSString stringWithFormat:@"%4.2f", lw]];
}

@end
