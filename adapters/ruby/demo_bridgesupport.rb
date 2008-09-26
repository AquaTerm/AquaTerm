require 'osx/cocoa'
include OSX
OSX.require_framework 'AquaTerm'

adapter = AQTAdapter.alloc().init()

adapter.openPlotWithIndex_(1)
adapter.setPlotSize_(NSMakeSize(620,420))
adapter.setPlotTitle_("Testview")

# Set color directly
adapter.setColorRed_green_blue_(0.0, 0.0, 0.0)
adapter.setFontname_("Helvetica")
adapter.setFontsize_(12.0)
adapter.addLabel_atPoint_angle_align_("Testview 620x420 pt", NSMakePoint(4,412), 0.0, AQTAlignLeft)

# Frame plot
adapter.moveToPoint_(NSMakePoint(20,20))
adapter.addLineToPoint_(NSMakePoint(600,20));
adapter.addLineToPoint_(NSMakePoint(600,400));
adapter.addLineToPoint_(NSMakePoint(20,400));
adapter.addLineToPoint_(NSMakePoint(20,20));
adapter.addLabel_atPoint_angle_align_("Frame 600x400 pt", NSMakePoint(24,30), 0.0, AQTAlignLeft)

adapter.renderPlot()