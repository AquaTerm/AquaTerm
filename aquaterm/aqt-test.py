#! /sw/bin/python
#
## AquaTerm test script
#
# this script (hopefully) creates three windows in 
# Aquaterm (even if it is not running at the time this is launched)
#

import os
gnuplot = os.popen('gnuplot', 'w')

## TEST 1
# open an AQT window,
# draw and redraw into it
#
print >>gnuplot, "set style function linespoints"
print >>gnuplot, "set title 'Test 1'"
for n in range(70):
	print >>gnuplot, "set yrange[-%i:+%i];plot tan(x) lt 3 pt 5" % ((.1*n)+1,(.1*n)+1)
	gnuplot.flush()

## TEST 2
# open a second AQT window
# draw into it with multiple colors
#
print >>gnuplot, "set term aqua 1"
print >>gnuplot, "set title 'Test 2'"
print >>gnuplot, "set style function lines"
print >>gnuplot, "set grid"
gpcmd = "plot sin(x)*x notitle"
for i in range(9):
	gpcmd = gpcmd + ", cos(x)*%i notitle lw %i" % (i+1, i+1)
print >>gnuplot, gpcmd
gnuplot.flush()

## TEST 3
# open a third window
# draw a 3D surface
#
print >>gnuplot, "set term aqua 2"
print >>gnuplot, "set title 'Test 3'"
print >>gnuplot, "set pm3d at s hidden3d 100"
print >>gnuplot, "unset surface"
print >>gnuplot, "set contour"
print >>gnuplot, "set style line 100 lt 8 lw .5"
print >>gnuplot, "splot cos(x)*cos(y)"
gnuplot.flush()

# end of test script