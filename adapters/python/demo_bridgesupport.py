import objc
import math
from Foundation import *

objc.initFrameworkWrapper("AquaTerm", "/Library/Frameworks/AquaTerm.framework", "net.sourceforge.AquaTerm_Framework", globals())

adapter = AQTAdapter.alloc().init()

pi = 4.0 * math.atan(1)
rgbImage = [ 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0 ]

adapter.openPlotWithIndex_(1)
adapter.setPlotSize_(NSMakeSize(620,420))
adapter.setPlotTitle_("Testview")

# Set colormap
adapter.setColormapEntry_red_green_blue_(0, 1.0, 1.0, 1.0) # white
adapter.setColormapEntry_red_green_blue_(1, 0.0, 0.0, 0.0) # black
adapter.setColormapEntry_red_green_blue_(2, 1.0, 0.0, 0.0) # red
adapter.setColormapEntry_red_green_blue_(3, 0.0, 1.0, 0.0) # green
adapter.setColormapEntry_red_green_blue_(4, 0.0, 0.0, 1.0) # blue
adapter.setColormapEntry_red_green_blue_(5, 1.0, 0.0, 1.0) # purple
adapter.setColormapEntry_red_green_blue_(6, 1.0, 1.0, 0.5) # yellow
adapter.setColormapEntry_red_green_blue_(7, 0.0, 0.5, 0.5) # dark green

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

# Colormap
adapter.addLabel_atPoint_angle_align_("Custom colormap (8 out of 256)", NSMakePoint(30, 385), 0.0, AQTAlignLeft)

# Display the colormap, but first create a background for the white box...
adapter.setColorRed_green_blue_(0.8, 0.8, 0.8)
adapter.addFilledRect_(NSMakeRect(28, 348, 24, 24))
for i in range(8):
	adapter.takeColorFromColormapEntry_(i)
	adapter.addFilledRect_(NSMakeRect(30+i*30, 350, 20, 20))
	# Print the color index
	adapter.setColorRed_green_blue_(0.5, 0.5, 0.5)
	adapter.addLabel_atPoint_angle_align_(str(i), NSMakePoint(40+i*30, 360), 0.0, AQTAlignCenter)

# Continuous colors
adapter.takeColorFromColormapEntry_(1)
adapter.addLabel_atPoint_angle_align_('"Any color you like"', NSMakePoint(320, 385), 0.0, AQTAlignLeft)
adapter.setLinewidth_(1.0)
for i in range(256):
	f = i / 255.0
	adapter.setColorRed_green_blue_(1.0, f, f/2.0)
	adapter.addFilledRect_(NSMakeRect(320+i, 350, 1, 20))
	adapter.setColorRed_green_blue_(0.0, f, 1.0-f)
	adapter.addFilledRect_(NSMakeRect(320+i, 328, 1, 20))
	adapter.setColorRed_green_blue_(1.0-f, 1.0-f, 1.0-f)
	adapter.addFilledRect_(NSMakeRect(320+i, 306, 1, 20))

# Lines
pat = [(4,2,4,2),(4,2,2,2),(8,4,8,4),(2,2,2,2)]

adapter.takeColorFromColormapEntry_(1)
adapter.addLabel_atPoint_("Specify linewidth and pattern", NSMakePoint(30, 325))
for f in range(1, 13, 2):
	lw = f/2.0
	adapter.setLinewidth_(round(lw-.5))
	adapter.setLinestylePattern_count_phase_(pat[f%3], 4, 0.0)
	adapter.moveToPoint_(NSMakePoint(30, 200.5+f*10))
	adapter.addLineToPoint_(NSMakePoint(180, 200.5+f*10))
adapter.setLinestyleSolid()

# Clip rect
r = NSMakeRect(200, 200, 60, 120)
points = []
adapter.addLabel_atPoint_("Clip rects", NSMakePoint(200, 325))
adapter.setColorRed_green_blue_(.9, .9, .9)
adapter.addFilledRect_(r)
adapter.setColorRed_green_blue_(0, 0, 0)
adapter.setClipRect_(r)
adapter.addLabel_atPoint_angle_align_("Clipped text. Clipped text. Clipped text.", NSMakePoint(180, 230), 30.0, AQTAlignCenter | AQTAlignMiddle)
adapter.setLinewidth_(1.0)
for i in range(5):
	radians = i*pi*0.8
	r = 30.0
	points.append(NSMakePoint(240.0+r*math.cos(radians), 215.0+r*math.sin(radians)))
adapter.takeColorFromColormapEntry_(3)
adapter.addPolygonWithVertexPoints_pointCount_(points, 5)
adapter.takeColorFromColormapEntry_(1)
points.append(points[0])
adapter.addPolylineWithPoints_pointCount_(points, 6)
adapter.addImageWithBitmap_size_bounds_(rgbImage, NSMakeSize(2,2), NSMakeRect(190, 280, 50, 50)) # ClipRect demo
adapter.setDefaultClipRect()
# ***** Reset clip rect! *****

# linecap styles
adapter.setFontsize_(8.0)
adapter.setLinewidth_(11.0)
adapter.takeColorFromColormapEntry_(1)
adapter.setLineCapStyle_(AQTButtLineCapStyle)
adapter.moveToPoint_(NSMakePoint(40.5, 170.5))
adapter.addLineToPoint_(NSMakePoint(150.5, 170.5))
adapter.addLabel_atPoint_angle_align_("AQTButtLineCapStyle", NSMakePoint(160.5, 170.5), 0.0, AQTAlignLeft);
adapter.setLinewidth_(1.0)
adapter.takeColorFromColormapEntry_(6)
adapter.moveToPoint_(NSMakePoint(40.5, 170.5))
adapter.addLineToPoint_(NSMakePoint(150.5, 170.5))

adapter.setLinewidth_(11.0)
adapter.takeColorFromColormapEntry_(1)
adapter.setLineCapStyle_(AQTRoundLineCapStyle)
adapter.moveToPoint_(NSMakePoint(40.5, 150.5))
adapter.addLineToPoint_(NSMakePoint(150.5, 150.5))
adapter.addLabel_atPoint_angle_align_("AQTRoundLineCapStyle", NSMakePoint(160.5, 150.5), 0.0, AQTAlignLeft)
adapter.setLinewidth_(1.0)
adapter.takeColorFromColormapEntry_(6)
adapter.moveToPoint_(NSMakePoint(40.5, 150.5))
adapter.addLineToPoint_(NSMakePoint(150.5, 150.5))

adapter.setLinewidth_(11.0)
adapter.takeColorFromColormapEntry_(1)
adapter.setLineCapStyle_(AQTSquareLineCapStyle)
adapter.moveToPoint_(NSMakePoint(40.5, 130.5))
adapter.addLineToPoint_(NSMakePoint(150.5, 130.5))
adapter.addLabel_atPoint_angle_align_("AQTSquareLineCapStyle", NSMakePoint(160.5, 130.5), 0.0, AQTAlignLeft)
adapter.setLinewidth_(1.0)
adapter.takeColorFromColormapEntry_(6)
adapter.moveToPoint_(NSMakePoint(40.5, 130.5))
adapter.addLineToPoint_(NSMakePoint(150.5, 130.5))
adapter.setFontsize_(12.0)

# line joins
adapter.takeColorFromColormapEntry_(1)
adapter.addLabel_atPoint_angle_align_("Line joins:", NSMakePoint(40, 90), 0.0, AQTAlignLeft)
adapter.setLinewidth_(11.0)
adapter.setLineCapStyle_(AQTButtLineCapStyle)
adapter.moveToPoint_(NSMakePoint(40, 50))
adapter.addLineToPoint_(NSMakePoint(75, 70))
adapter.addLineToPoint_(NSMakePoint(110, 50))
adapter.setLinewidth_(1.0)
adapter.takeColorFromColormapEntry_(6)
adapter.moveToPoint_(NSMakePoint(40, 50))
adapter.addLineToPoint_(NSMakePoint(75, 70))
adapter.addLineToPoint_(NSMakePoint(110, 50))

adapter.setLinewidth_(11.0)
adapter.takeColorFromColormapEntry_(1)
adapter.moveToPoint_(NSMakePoint(130, 50))
adapter.addLineToPoint_(NSMakePoint(150, 70))
adapter.addLineToPoint_(NSMakePoint(170, 50))
adapter.setLinewidth_(1.0)
adapter.takeColorFromColormapEntry_(6)
adapter.moveToPoint_(NSMakePoint(130, 50))
adapter.addLineToPoint_(NSMakePoint(150, 70))
adapter.addLineToPoint_(NSMakePoint(170, 50))

adapter.setLinewidth_(11.0)
adapter.takeColorFromColormapEntry_(1)
adapter.setLineCapStyle_(0)
adapter.moveToPoint_(NSMakePoint(190, 50))
adapter.addLineToPoint_(NSMakePoint(200, 70))
adapter.addLineToPoint_(NSMakePoint(210, 50))
adapter.setLinewidth_(1.0)
adapter.takeColorFromColormapEntry_(6)
adapter.moveToPoint_(NSMakePoint(190, 50))
adapter.addLineToPoint_(NSMakePoint(200, 70))
adapter.addLineToPoint_(NSMakePoint(210, 50))

# Polygons
adapter.takeColorFromColormapEntry_(1)
adapter.addLabel_atPoint_angle_align_("Polygons", NSMakePoint(320, 290), 0.0, AQTAlignLeft)
points = []
for i in range(4):
	radians=i*pi/2.0
	r=20.0
	points.append(NSMakePoint(340.0+r*math.cos(radians), 255.0+r*math.sin(radians)))
adapter.takeColorFromColormapEntry_(2)
adapter.addPolygonWithVertexPoints_pointCount_(points, 4)
points = []
for i in range(5):
	radians=i*pi*0.8
	r=20.0
	points.append(NSMakePoint(400.0+r*math.cos(radians), 255.0+r*math.sin(radians)))
adapter.takeColorFromColormapEntry_(3)
adapter.addPolygonWithVertexPoints_pointCount_(points, 5)
adapter.takeColorFromColormapEntry_(1)
points.append(points[0])
adapter.addPolylineWithPoints_pointCount_(points, 6)

points = []
for i in range(8):
	radians=i*pi/4.0
	r=20.0
	points.append(NSMakePoint(460.0+r*math.cos(radians), 255.0+r*math.sin(radians)))

adapter.takeColorFromColormapEntry_(4)
adapter.addPolygonWithVertexPoints_pointCount_(points, 8)
points = []
for i in range(32):
  radians=i*pi/16.0
  r=20.0
  points.append(NSMakePoint(520.0+r*math.cos(radians), 255.0+r*math.sin(radians)))
adapter.takeColorFromColormapEntry_(5)
adapter.addPolygonWithVertexPoints_pointCount_(points, 32)

# Images
adapter.takeColorFromColormapEntry_(1)
adapter.addLabel_atPoint_angle_align_("Images", NSMakePoint(320, 220), 0.0, AQTAlignLeft)
adapter.addImageWithBitmap_size_bounds_(rgbImage, NSMakeSize(2,2), NSMakeRect(328, 200, 4, 4))
adapter.addLabel_atPoint_angle_align_("bits", NSMakePoint(330, 180), 0.0, AQTAlignCenter)
adapter.addImageWithBitmap_size_bounds_(rgbImage, NSMakeSize(2,2), NSMakeRect(360, 190, 40, 15))
adapter.addLabel_atPoint_angle_align_("fit bounds", NSMakePoint(380, 180), 0.0, AQTAlignCenter)
adapter.setImageTransformM11_m12_m21_m22_tX_tY_(9.23880, 3.82683, -3.82683, 9.23880, 494.6, 186.9)
adapter.addTransformedImageWithBitmap_size_clipRect_(rgbImage, NSMakeSize(2,2), NSMakeRect(0, 0, 600, 400))
adapter.addLabel_atPoint_angle_align_("scale, rotate & translate", NSMakePoint(500, 180), 0.0, AQTAlignCenter)
adapter.resetImageTransform() # clean up

# Text
adapter.setFontname_("Times-Roman")
s = u"Unicode: %c %c %c %c%c%c%c%c" % (0x2124, 0x2133, 0x5925, 0x2654, 0x2655, 0x2656, 0x2657, 0x2658) 
as = NSMutableAttributedString.alloc().initWithString_(s)
as.setAttributes_range_({"AQTFontname" : "AppleSymbols"}, NSMakeRange(9,11))
as.setAttributes_range_({"AQTFontname" : "Song Regular"}, NSMakeRange(13,1))

adapter.takeColorFromColormapEntry_(1);
adapter.setFontname_("Times-Roman");
adapter.setFontsize_(12.0);
adapter.addLabel_atPoint_(as, NSMakePoint(320,150));
#adapter.addLabel_atPoint_angle_align_("Times-Roman 16pt", NSMakePoint(320, 150), 0.0, AQTAlignLeft);
adapter.takeColorFromColormapEntry_(2);
adapter.setFontname_("Times-Italic");
adapter.setFontsize_(16.0);
adapter.addLabel_atPoint_angle_align_("Times-Italic 16pt", NSMakePoint(320, 130), 0.0, AQTAlignLeft);
adapter.takeColorFromColormapEntry_(4);
adapter.setFontname_("Zapfino");
adapter.setFontsize_(12.0);
adapter.addLabel_atPoint_angle_align_("Zapfino 12pt", NSMakePoint(320, 104), 0.0, AQTAlignLeft);

adapter.takeColorFromColormapEntry_(2)
adapter.setLinewidth_(0.5)
adapter.moveToPoint_(NSMakePoint(510.5, 160))
adapter.addLineToPoint_(NSMakePoint(510.5, 100))
pos = NSMakePoint(540.5, 75.5)
adapter.moveToPoint_(NSMakePoint(pos.x+5, pos.y))
adapter.addLineToPoint_(NSMakePoint(pos.x-5, pos.y))
adapter.moveToPoint_(NSMakePoint(pos.x, pos.y+5))
adapter.addLineToPoint_(NSMakePoint(pos.x, pos.y-5))

adapter.takeColorFromColormapEntry_(1)
adapter.setFontname_("Verdana")
adapter.setFontsize_(10.0)
adapter.addLabel_atPoint_angle_align_("left align", NSMakePoint(510.5, 150), 0.0, AQTAlignLeft)
adapter.addLabel_atPoint_angle_align_("centered", NSMakePoint(510.5, 130), 0.0, AQTAlignCenter)
adapter.addLabel_atPoint_angle_align_("right align", NSMakePoint(510.5, 110), 0.0, AQTAlignRight)
adapter.setFontname_("Times-Roman")
adapter.setFontsize_(14.0)
adapter.addLabel_atPoint_angle_align_("-rotate", pos, 90.0, AQTAlignLeft)
adapter.addLabel_atPoint_angle_align_("-rotate", pos, 45.0, AQTAlignLeft)
adapter.addLabel_atPoint_angle_align_("-rotate", pos, -30.0, AQTAlignLeft)
adapter.addLabel_atPoint_angle_align_("-rotate", pos, -60.0, AQTAlignLeft)
adapter.addLabel_atPoint_angle_align_("-rotate", pos, -90.0, AQTAlignLeft)
# Shear
adapter.setFontname_("Arial")
adapter.setFontsize_(12.0)
adapter.addLabel_atPoint_angle_shearAngle_align_("Rotate & shear", NSMakePoint(430, 105), 45.0, 45.0, AQTAlignLeft)

# Some styling is possible
attrStr = NSMutableAttributedString.alloc().initWithString_("Underline, super- and subscript123")
attrStr.addAttribute_value_range_("NSUnderline", 1, NSMakeRange(0,9))
attrStr.addAttribute_value_range_("NSSuperScript", -1, NSMakeRange(31,1))
attrStr.addAttribute_value_range_("NSSuperScript", 1, NSMakeRange(32,2))
adapter.addLabel_atPoint_angle_align_(attrStr, NSMakePoint(320, 75), 0.0, AQTAlignLeft);  

adapter.takeColorFromColormapEntry_(2)
adapter.setLinewidth_(0.5)
adapter.moveToPoint_(NSMakePoint(320, 45.5))
adapter.addLineToPoint_(NSMakePoint(520, 45.5))
adapter.takeColorFromColormapEntry_(1)
adapter.setFontname_("Times-Italic")
adapter.setFontsize_(14.0)
adapter.addLabel_atPoint_angle_align_("Top", NSMakePoint(330, 45.5), 0.0, AQTAlignLeft | AQTAlignTop)
adapter.addLabel_atPoint_angle_align_("Bottom", NSMakePoint(360, 45.5), 0.0, AQTAlignLeft | AQTAlignBottom)
adapter.addLabel_atPoint_angle_align_("Middle", NSMakePoint(410, 45.5), 0.0, AQTAlignLeft | AQTAlignMiddle)
adapter.addLabel_atPoint_angle_align_("Baseline", NSMakePoint(460, 45.5), 0.0, AQTAlignLeft | AQTAlignBaseline)

# Equations
adapter.setFontname_("Helvetica")
adapter.setFontsize_(12.0)
adapter.addLabel_atPoint_angle_align_("Equation style", NSMakePoint(260, 95), 0.0, AQTAlignCenter)

adapter.setFontname_("Times-Roman")
adapter.setFontsize_(14.0)

attrStr = NSMutableAttributedString.alloc().initWithString_("e-ip+1= 0")
attrStr.addAttribute_value_range_("AQTFontname", "Symbol", NSMakeRange(3,1)) # Greek
attrStr.addAttribute_value_range_("NSSuperScript", 1, NSMakeRange(1,3)) # exponent
attrStr.addAttribute_value_range_("AQTFontsize", 6.0, NSMakeRange(7,1)) # extra spacing

adapter.addLabel_atPoint_angle_align_(attrStr, NSMakePoint(260, 75), 0.0, AQTAlignCenter)

attrStr = NSMutableAttributedString.alloc().initWithString_("mSke-wk2")
attrStr.addAttribute_value_range_("AQTFontname", "Symbol", NSMakeRange(0,2))
attrStr.addAttribute_value_range_("AQTFontsize", 20.0, NSMakeRange(1,1))
attrStr.addAttribute_value_range_("AQTBaselineAdjust", -0.25, NSMakeRange(1,1)); # Lower symbol 25%
attrStr.addAttribute_value_range_("NSSuperScript", -1, NSMakeRange(2,1))
attrStr.addAttribute_value_range_("AQTFontname", "Times-Roman", NSMakeRange(3,1))
attrStr.addAttribute_value_range_("NSSuperScript", 1, NSMakeRange(4,2))
attrStr.addAttribute_value_range_("AQTFontname", "Symbol", NSMakeRange(5,1))
attrStr.addAttribute_value_range_("NSSuperScript", -2, NSMakeRange(6,1))
attrStr.addAttribute_value_range_("NSSuperScript", 2, NSMakeRange(7,1))

adapter.addLabel_atPoint_angle_align_(attrStr, NSMakePoint(260, 45), 0.0, AQTAlignCenter);

adapter.renderPlot()
