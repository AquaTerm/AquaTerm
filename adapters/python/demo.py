import objc
from Foundation import *

objc.loadBundle("AquaTerm", globals(), bundle_path='/Library/Frameworks/AquaTerm.framework')

adapter = AQTAdapter.alloc().init()
adapter.openPlotWithIndex_(11)
adapter.setPlotTitle_("Python --> AquaTerm")
adapter.setPlotSize_((400,400))
adapter.addLabel_atPoint_angle_align_("Hello from Python", (200,200), 0.0, 1)
adapter.renderPlot()
