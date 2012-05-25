*     eventdemo1.f
*     AquaTerm
*     
*     Created by Per Persson on Tue Dec 16 2003.
*     Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.

      program demo
      integer i, running, eventNum
      character*64 buffer
      integer middle, center
*     Initialize
      middle = 0 ! verticalAlign: {middle, baseline, bottom, top} = {0,4,8,16}
      center = 1 ! horizontalAlign: {left, center, right} = {0,1,2}      
      call aqtInit()
      call aqtOpenPlot(1)
      call aqtSetPlotSize(100.0, 200.0)
      call aqtSetFontsize(18.0)
      call aqtSetFontname('Verdana')
      call aqtSetPlotTitle('Menu')
*     The menu
      call aqtAddLabel('Menu', 50.0, 175.0, 0.0, middle+center)      
      call aqtSetColor(0.8, 0.8, 0.8)
      call aqtAddFilledRect(10., 110., 80., 30.)
      call aqtSetColor(1.0, 0.0, 0.0)
      call aqtAddLabel('Red', 50.0, 125.0, 0.0, middle+center)
      call aqtSetColor(0.8, 0.8, 0.8)
      call aqtAddFilledRect(10., 60., 80., 30.)
      call aqtSetColor(0.0, 0.0, 1.0)
      call aqtAddLabel('Blue', 50.0, 75.0, 0.0, middle+center)
      call aqtSetColor(0.8, 0.8, 0.8)
      call aqtAddFilledRect(10., 10., 80., 30.)
      call aqtSetColor(1.0, 1.0, 1.0)
      call aqtAddLabel('Quit', 50.0, 25.0, 0.0, middle+center)
*     Draw the menu
      call aqtRenderPlot()
*     Set up 2nd window for output
      call aqtOpenPlot(2)
      call aqtSetPlotSize(400.0, 400.0)
      call aqtSetPlotTitle('Display')
*     Eventloop
 100  running = 1
      call aqtSelectPlot(1)
      call aqtWaitNextEvent(buffer)
      call decodeEvent(buffer, eventNum)
      goto(110, 120, 130, 140),eventNum+1
      write(*,*) '*** Error ***'
      stop
 110  write(*,*) 'No action, ignoring'
      goto 999
*     Menu choice 1
 120  call aqtSelectPlot(2)
      call aqtSetColor(1.0, 0.0, 0.0)
      call aqtAddFilledRect(100., 100., 200., 200.)
      call aqtRenderPlot()
      goto 999
*     Menu choice 2
 130  call aqtSelectPlot(2)
      call aqtSetColor(0.0, 0.0, 1.0)
      call aqtAddFilledRect(100., 100., 200., 200.)
      call aqtRenderPlot()
      goto 999
*     Menu choice 3
 140  write(*,*) 'Exit selected. Bye'
      running = 0
 999  if (running .GT. 0) then 
         go to 100 
      end if
*     Cleaning
      call aqtSelectPlot(1)
      call aqtClosePlot()
      call aqtSelectPlot(2)
      call aqtClosePlot()
      end
      
      subroutine decodeEvent(event, res)
      CHARACTER*(*) event
      INTEGER res
*       
*
      integer n, x, y, sep1, sep2
*      write(*,*) event
      sep1 = index(event, ':')
      read(event(1:sep1-1), *) n
      if (n .GT. 2) then
*     Error event or unknown event
         res = -1
      else if (n .EQ. 0) then
*     Nil-event
         res = 0
      else
*     Key or mouse-down event lumped together
         sep2 = index(event(sep1+1:), ':')
*     Parse coordinates
         read(event(sep1+2:sep2+sep1-2), *) x, y
*     Use y-pos to determine menu choice
         res = 3-(y/50)
      end if
      end
