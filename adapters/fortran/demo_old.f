C   Testing all functions in f2aqt.h
C
      INTEGER i
      CHARACTER*64 string
      REAL x, y, xpos, ypos, w, h, x_max, y_max, pi
      DIMENSION x(16)
      DIMENSION y(16)
      PARAMETER (pi = 3.14152692)
C     
C     
C     Initialize AquaTerm adapter
      CALL aqtInit()
C
C     Open a new graph for drawing into
      CALL aqtOpenPlot(1)
      CALL aqtSetPlotSize(800.,600.)
      CALL aqtMoveTo(0.,0.)
      CALL aqtAddLineTo(800., 600.)

C     Set the title (Default is 'Figure n')
C      CALL aqtSetPlotTitle('Test of f2aqt')
C
C     Set color entries in colortable
C     Black
C      CALL aqtSetColormapEntry(0, 0.0, 0.0, 0.0)
C     Red
C      CALL aqtSetColormapEntry(1, 1.0, 0.0, 0.0)
C     Green
C      CALL aqtSetColormapEntry(2, 0.0, 1.0, 0.0)
C     Blue
C      CALL aqtSetColormapEntry(3, 0.0, 0.0, 1.0)

C     Set text justification: 0 = left, 1 = center, 2 = right
C      CALL aqt_textjust(0)
C      DO 10 i = 0, 3
C     Select the pen color (default is 0)
C         CALL aqtTakeColorFromColormapEntry(i)
C     Set the linewidth (default is 1.0)
C         CALL aqtSetLinewidth((i+1.0)*0.5)
C     Add a line using current attributes
C     NB. The .5 makes the line look better wrt anti-aliasing...
C         CALL aqtMoveTo(100.5, i*50.0+100.5)
C         CALL aqtAddLineTo(400.5, i*50.0+100.5)
C     Select font and size (default is Times-Roman 16pt)
C         CALL aqtSetFontname('Times-Italic')
C         CALL aqtSetFontsize(10.0+i*10.0)
C     Add the text with the current attributes
C         CALL aqtAddLabel('Hello World!', 400.0, i*50.0+100.0, 0.0, 0)
C 10   END DO
C     Draw it 
      CALL aqtRenderPlot()
C     Close current graph
C       CALL aqt_close()
C C     
C C     Open a new graph for drawing into
C       CALL aqt_open(2)
C C
C C     Set color entries in colortable
C C     Black
C       CALL aqt_set_color(0, 0.0, 0.0, 0.0)
C C     Red
C       CALL aqt_set_color(1, 1.0, 0.0, 0.0)
C C     Green
C       CALL aqt_set_color(2, 0.0, 1.0, 0.0)
C C     Blue
C       CALL aqt_set_color(3, 0.0, 0.0, 1.0)
C C      
C C     Get the size of the canvas
C       CALL aqt_get_size(x_max, y_max)
C C     Set the title (Default is 'Figure n')
C       CALL aqt_title('More tests of f2aqt')
C C     Set the linewidth (default is 1.0)
C       CALL aqt_linewidth(1.0)
C C     Draw a circle
C       CALL aqt_use_color(1)
C       CALL aqt_circle(x_max/2.0, y_max/2.0, 200.0, 0)
C C     Create a nice polygon
C       DO 20 i = 0, 4
C          x(i+1) = 200.0*cos(i*2.0*pi/5.0)+x_max/2
C          y(i+1) = 200.0*sin(i*2.0*pi/5.0)+y_max/2
C  20   END DO
C C     Draw a filled polygon inside it
C       CALL aqt_use_color(2)
C       CALL aqt_polygon(x, y, 5, 1)
C C     Draw a filled circle inside the polygon
C       CALL aqt_use_color(3)
C       CALL aqt_circle(x_max/2, y_max/2, 100.0, 1)
      
C C     Create another polygon (a polyline really...)
C       DO 30 i = 0, 15, 1
C          x(i+1) = 50.0*i+50.0
C          y(i+1) = 100.0*sin(i*2.0*pi/15.0)+y_max/2.0
C  30   END DO
C C     Draw the polygon (no fill)
C       CALL aqt_use_color(1)
C       CALL aqt_polygon(x, y, 16, 0)
C C     Flush pending lines, otherwise they may obscure the images (comment out to see!)
C       CALL aqt_flush()
C       xpos = 100.0
C       ypos = 200.0  
C       w = 300.0
C       h = 400.0 
C C     Nil-terminate strings since they are padded with ' ' characters:      
C       string = '/Library/User Pictures/Animals/Orangutan.tif\0'
C       CALL aqt_image(string, xpos, ypos, w, h)
C C     Constant strings don't _need_ nil-termination, but seem to have a max length of 32
C       CALL aqt_image('~/Pictures/m31.jpg', 10.0, 10.0, 101.0, 102.0)
C C     Draw it 
C       CALL aqt_render()
C C     Close current graph
C       CALL aqt_close()

      END

