C     demo.f
C     AquaTerm
C     
C     Created by Per Persson on Fri Nov 07 2003.
C     Modified by Joe Koski on Mon Feb 09 2004.
C     Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
C     
C     
C     This file contains an example of what can be done with
C     AquaTerm and the corresponding AquaTerm.framework
C     
      program demo
      integer i
      character*64 strBuf
C     output strings
      character numstr1*1,numstr13*13,numstr48*48
      real xPtr, yPtr, x, y, f, lw, r
      dimension xPtr(128) 
      dimension yPtr(128) 
      parameter (pi = 3.14152692)
      integer middle, baseline, bottom, top, left, center, right
C     Declare the image: it will be 2x2 in size.
      character rgbImage(6,2)
C     
C     labels (probably better ways to do this...)
C     
C     verticalAlign: {middle, baseline, bottom, top} = {0,4,8,16}
      middle = 0
      baseline = 4
      bottom = 8
      top = 16
C     horizontalAlign: {left, center, right} = {0,1,2}       
      left = 0
      center = 1
      right = 2
C     
C     Initialize. Do it or fail miserably...
      call aqtInit()
C     Open up a plot for drawing
      call aqtOpenPlot(1)
      width=620.0
      height=420.0
      call aqtSetPlotSize(width, height)
      call aqtSetPlotTitle('Testview')
C     Set colormap
C     white
      call aqtSetColormapEntry(0, 1.0, 1.0, 1.0) 
C     black
      call aqtSetColormapEntry(1, 0.0, 0.0, 0.0) 
C     red
      call aqtSetColormapEntry(2, 1.0, 0.0, 0.0) 
C     green
      call aqtSetColormapEntry(3, 0.0, 1.0, 0.0) 
C     blue
      call aqtSetColormapEntry(4, 0.0, 0.0, 1.0) 
C     purple
      call aqtSetColormapEntry(5, 1.0, 0.0, 1.0) 
C     yellow
      call aqtSetColormapEntry(6, 1.0, 1.0, 0.5) 
C     dark green
      call aqtSetColormapEntry(7, 0.0, 0.5, 0.5) 

C     Set color explicitly
      call aqtSetColor(0.0, 0.0, 0.0)
      call aqtSetFontname('Helvetica')
      call aqtSetFontsize(12.0)
      iwidth=width
      iheight=height
      write(numstr48,140)iwidth,iheight
 140  format('Testview ',I3,'x',I3,' pt')
      call aqtAddLabel(numstr48, 4.0, 412.0, 0.0, 0)
C     Frame plot
      call aqtMoveTo(20., 20.)
      call aqtAddLineTo(600.,20.)
      call aqtAddLineTo(600.,400.)
      call aqtAddLineTo(20.,400.)
      call aqtAddLineTo(20.,20.)
      call aqtAddLabel('Frame 600x400 pt', 24., 30., 0.0, 0)
C     Colormap
C     write Custom colormap string
      write(numstr48,120)
 120  format('Custom colormap (showing 8 of 256 entries)')
      call aqtAddLabel(numstr48, 30., 390., 0.0, 0)
C     Display the colormap, but first create a background for the white box...
      call aqtSetColor(0.8, 0.8, 0.8)

      call aqtAddFilledRect(28., 348., 24., 24.)
      f = 0.0
      do 10 i = 0, 7
         call aqtTakeColorFromColormapEntry(i)
         call aqtAddFilledRect(30.+f*30., 350., 20., 20.)
C     Print the color index
         call aqtSetColor(0.5, 0.5, 0.5)
C     Writing with a format to internal character variables
         write(numstr1,100)i
 100     format(I1)
         call aqtAddLabel(numstr1, 40.+f*30., 360., 0.0, middle+center)
         f = f+1.0
 10   end do
C     Continuous colors
      call aqtRenderPlot()
      call aqtTakeColorFromColormapEntry(1)
      call aqtAddLabel('Continuous colors',320., 390., 0.0, 0)
      call aqtSetLinewidth(1.0)
      f = 0.0
      do 20 i = 0, 255
         call aqtSetColor(1.0, f/256.0, f/512.0)
         call aqtAddFilledRect(320.+f, 350., 1., 20.);
         call aqtSetColor(0.0, f/256.0, (1.0-f/256.0))
         call aqtAddFilledRect(320.+f, 328., 1., 20.);
         call aqtSetColor((1.0-f/256.0), (1.0-f/256.0), (1.0-f/256.0))
         call aqtAddFilledRect(320.+f, 306., 1., 20.);
         f = f+1.0
 20   end do
C     Lines
      call aqtTakeColorFromColormapEntry(1)
      do 30 i = 1, 12, 2
         f = i
         call aqtSetLinewidth(f/2.0)
         call aqtMoveTo(30., 200.5+f*10.)
         call aqtAddLineTo(200., 200.5+f*10.)
C     write to 3 character string
         fhalf = f/2.0
         write(numstr13,110)fhalf
 110     format('linewidth ',f3.1)
         call aqtAddLabel(numstr13, 210., 201.5+f*10., 0.0, left)
 30   end do
C     linecap styles
      call aqtSetLinewidth(11.0)
      call aqtTakeColorFromColormapEntry(1)
      call aqtSetLineCapStyle(0)
      call aqtMoveTo(40.5, 170.5)
      call aqtAddLineTo(150.5, 170.5)
      call aqtAddLabel('AQTButtLineCapStyle', 160.5, 170.5, 0.0, 0)
      call aqtSetLinewidth(1.0)
      call aqtTakeColorFromColormapEntry(6)
      call aqtMoveTo(40.5, 170.5)
      call aqtAddLineTo(150.5, 170.5)

      call aqtSetLinewidth(11.0)
      call aqtTakeColorFromColormapEntry(1)
      call aqtSetLineCapStyle(1)
      call aqtMoveTo(40.5, 150.5)
      call aqtAddLineTo(150.5, 150.5)
      call aqtAddLabel('AQTRoundLineCapStyle', 160.5, 150.5, 0.0, 0)
      call aqtSetLinewidth(1.0)
      call aqtTakeColorFromColormapEntry(6)
      call aqtMoveTo(40.5, 150.5)
      call aqtAddLineTo(150.5, 150.5)

      call aqtSetLinewidth(11.0)
      call aqtTakeColorFromColormapEntry(1)
      call aqtSetLineCapStyle(2)
      call aqtMoveTo(40.5, 130.5)
      call aqtAddLineTo(150.5, 130.5)
      call aqtAddLabel('AQTSquareLineCapStyle', 160.5, 130.5, 0.0, 0)
      call aqtSetLinewidth(1.0)
      call aqtTakeColorFromColormapEntry(6)
      call aqtMoveTo(40.5, 130.5)
      call aqtAddLineTo(150.5, 130.5)

C     line joins
      call aqtTakeColorFromColormapEntry(1)
      call aqtAddLabel('Line joins:', 40., 90., 0.0, 0)
      call aqtSetLinewidth(11.0)
      call aqtSetLineCapStyle(0)
      call aqtMoveTo(40., 50.)
      call aqtAddLineTo(75., 70.)
      call aqtAddLineTo(110., 50.)
      call aqtSetLinewidth(1.0)
      call aqtTakeColorFromColormapEntry(6)
      call aqtMoveTo(40., 50.)
      call aqtAddLineTo(75., 70.)
      call aqtAddLineTo(110., 50.)

      call aqtSetLinewidth(11.0)
      call aqtTakeColorFromColormapEntry(1)
      call aqtMoveTo(130., 50.)
      call aqtAddLineTo(150., 70.)
      call aqtAddLineTo(170., 50.)
      call aqtSetLinewidth(1.0)
      call aqtTakeColorFromColormapEntry(6)
      call aqtMoveTo(130., 50.)
      call aqtAddLineTo(150., 70.)
      call aqtAddLineTo(170., 50.)

      call aqtSetLinewidth(11.0)
      call aqtTakeColorFromColormapEntry(1)
      call aqtSetLineCapStyle(0)
      call aqtMoveTo(190., 50.)
      call aqtAddLineTo(200., 70.)
      call aqtAddLineTo(210., 50.)
      call aqtSetLinewidth(1.0)
      call aqtTakeColorFromColormapEntry(6)
      call aqtMoveTo(190., 50.)
      call aqtAddLineTo(200., 70.)
      call aqtAddLineTo(210., 50.)

C     Polygons
      call aqtTakeColorFromColormapEntry(1)
      call aqtAddLabel('Polygons', 320., 290., 0.0, left)
      f = 0.0
      r = 20.0
      do 40 i = 1, 4
         xPtr(i) = 340.0+r*cos(f*pi/2.0)
         yPtr(i) = 255.0+r*sin(f*pi/2.0)
         f=f+1.0
 40   end do
      call aqtTakeColorFromColormapEntry(2)
      call aqtAddPolygon(xPtr, yPtr, 4);

      f = 0.0
      r = 20.0
      do 50 i = 1, 5
         xPtr(i) = 400.0+r*cos(f*pi*0.8)
         yPtr(i) = 255.0+r*sin(f*pi*0.8)
         f=f+1.0
 50   end do
      call aqtTakeColorFromColormapEntry(3)
      call aqtAddPolygon(xPtr, yPtr, 5);
C     Overlay a polyline
      call aqtTakeColorFromColormapEntry(1)
      xPtr(6) = xPtr(1)
      yPtr(6) = yPtr(1)
      call aqtAddPolyline(xPtr, yPtr, 6) 
C     Alternative to polyline:
      f = 0.0
      r = 20.0
      call aqtTakeColorFromColormapEntry(4)
      call aqtMoveToVertex(460.0+r, 255.0)
      do 60 i = 1, 8
         x = 460.0+r*cos(f*pi/4.0)
         y = 255.0+r*sin(f*pi/4.0)
         call aqtAddEdgeToVertex(x, y)
         f=f+1.0
 60   end do

      f = 0.0
      r = 20.0
      do 70 i = 1, 32
         xPtr(i) = 520.0+r*cos(f*pi/16.0)
         yPtr(i) = 255.0+r*sin(f*pi/16.0)
         f=f+1.0
 70   end do
      call aqtTakeColorFromColormapEntry(5)
      call aqtAddPolygon(xPtr, yPtr, 32);

C     Images
C     Pixel(1,1) RGB (red)
      rgbImage(1,1) = achar(255)
      rgbImage(2,1) = achar(0)
      rgbImage(3,1) = achar(0)
C     Pixel(2,1) RGB (green)
      rgbImage(4,1) = achar(0)
      rgbImage(5,1) = achar(255)
      rgbImage(6,1) = achar(0)
C     Pixel(1,2) RGB (blue)
      rgbImage(1,2) = achar(0)
      rgbImage(2,2) = achar(0)
      rgbImage(3,2) = achar(255)
C     Pixel(2,2) RGB (black)
      rgbImage(4,2) = achar(0)
      rgbImage(5,2) = achar(0)
      rgbImage(6,2) = achar(0)
      call aqtTakeColorFromColormapEntry(1)
      call aqtAddLabel('Images', 320., 220., 0.0, left)
      call aqtAddImageWithBitmap(rgbImage, 2, 2, 328., 200., 4., 4.)
      call aqtAddLabel('bits', 330., 180., 0.0, center)
      call aqtAddImageWithBitmap(rgbImage, 2, 2, 360., 190., 40., 15.)
      call aqtAddLabel('fit bounds', 380., 180., 0.0, center)
      call aqtSetImageTransform(9.23880, 3.82683, -3.82683, 9.23880, 
     $     494.6, 186.9 )
      call aqtAddTransformedImageWithBitmap(rgbImage, 2, 2, 
     $     0., 0., 600., 400.)
      call aqtAddLabel('scale, rotate & translate', 500., 180., 0.0, 
     $     center)
      call aqtResetImageTransform()	

C     Text
      call aqtTakeColorFromColormapEntry(1)
      call aqtSetFontname('Times-Roman')
      call aqtSetFontsize(16.0)
      call aqtAddLabel('Times-Roman 16pt', 320.,150., 0.0, 0)
      call aqtTakeColorFromColormapEntry(2)
      call aqtSetFontname('Times-Italic')
      call aqtSetFontsize(16.0)
      call aqtAddLabel('Times-Italic 16pt', 320.,130.,0.0, 0)
      call aqtTakeColorFromColormapEntry(4)
      call aqtSetFontname('Zapfino')
      call aqtSetFontsize(12.0)
      call aqtAddLabel('Zapfino 12pt', 320., 104., 0.0, 0)

      call aqtTakeColorFromColormapEntry(2)
      call aqtSetLinewidth(0.5)
      call aqtMoveTo(510.5, 160.)
      call aqtAddLineTo(510.5, 100.)
      x = 540.5
      y = 75.5
      call aqtMoveTo(x+5., y)
      call aqtAddLineTo(x-5., y)
      call aqtMoveTo(x, y+5.)
      call aqtAddLineTo(x, y-5.)

      call aqtTakeColorFromColormapEntry(1)
      call aqtSetFontname('Verdana')
      call aqtSetFontsize(10.0)
      call aqtAddLabel('left aligned', 510.5, 150., 0.0, left+middle)
      call aqtAddLabel('centered', 510.5, 130., 0.0, center+middle)
      call aqtAddLabel('right aligned', 510.5, 110., 0.0, right+middle)
      call aqtSetFontname('Times-Roman')
      call aqtSetFontsize(14.0)
      call aqtAddLabel('-rotate', x, y, 90.0, 0)
      call aqtAddLabel('-rotate', x, y, 45.0, 0)
      call aqtAddLabel('-rotate', x, y, -30.0, 0)
      call aqtAddLabel('-rotate', x, y, -60.0, 0)
      call aqtAddLabel('-rotate', x, y, -90.0, 0)

C     String styling is _not_ possible from Fortran
      call aqtSetFontsize(12.0)
      call aqtAddLabel('No underline, sub- or superscript in fortran'
     $     ,320.,75.,0.0,0)
      
      call aqtTakeColorFromColormapEntry(2)
      call aqtSetLinewidth(0.5)
      call aqtMoveTo(320., 45.5)
      call aqtAddLineTo(520., 45.5)
      call aqtTakeColorFromColormapEntry(1)
      call aqtSetFontname('Times-Italic')
      call aqtSetFontsize(14.0)
      call aqtAddLabel('Top', 330., 45.5, 0.0, left+top)
      call aqtAddLabel('Bottom', 360., 45.5, 0.0, left+bottom)
      call aqtAddLabel('Middle', 410., 45.5, 0.0, left+middle)
      call aqtAddLabel('Baseline', 460., 45.5,0.0,left+baseline)

C     Draw it
      call aqtRenderPlot()
C     Let go of plot _when done_
      call aqtClosePlot()
      end
