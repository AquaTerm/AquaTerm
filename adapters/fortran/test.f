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
      CALL aqt_init()
C
C     Open a new graph for drawing into
      CALL aqt_open(1)
C     Set the title (Default is 'Figure n')
      CALL aqt_title('Test of f2aqt')
C
C     Set color entries in colortable
C     Black
      CALL aqt_set_color(0, 0.0, 0.0, 0.0)
C     Red
      CALL aqt_set_color(1, 1.0, 0.0, 0.0)
C     Green
      CALL aqt_set_color(2, 0.0, 1.0, 0.0)
C     Blue
      CALL aqt_set_color(3, 0.0, 0.0, 1.0)

C     Set text justification: 0 = left, 1 = center, 2 = right
      CALL aqt_textjust(0)
      DO 10 i = 0, 3
C     Select the pen color (default is 0)
         CALL aqt_use_color(i)
C     Set the linewidth (default is 1.0)
         CALL aqt_linewidth((i+1.0)*0.5)
C     Add a line using current attributes
C     NB. The .5 makes the line look better wrt anti-aliasing...
         CALL aqt_line(100.5, i*50.0+100.5, 400.5, i*50.0+100.5)
C     Select font and size (default is Times-Roman 16pt)
         CALL aqt_font('Times-Italic', 10.0+i*10.0)
C     Add the text with the current attributes
         CALL aqt_text(400.0, i*50.0+100.0, 'Hello World!')
 10   END DO
C     Draw it 
      CALL aqt_render()
C     Close current graph
      CALL aqt_close()
C     
C     Open a new graph for drawing into
      CALL aqt_open(2)
C
C     Set color entries in colortable
C     Black
      CALL aqt_set_color(0, 0.0, 0.0, 0.0)
C     Red
      CALL aqt_set_color(1, 1.0, 0.0, 0.0)
C     Green
      CALL aqt_set_color(2, 0.0, 1.0, 0.0)
C     Blue
      CALL aqt_set_color(3, 0.0, 0.0, 1.0)
C      
C     Get the size of the canvas
      CALL aqt_get_size(x_max, y_max)
C     Set the title (Default is 'Figure n')
      CALL aqt_title('More tests of f2aqt')
C     Set the linewidth (default is 1.0)
      CALL aqt_linewidth(1.0)
C     Draw a circle
      CALL aqt_use_color(1)
      CALL aqt_circle(x_max/2.0, y_max/2.0, 200.0, 0)
C     Create a nice polygon
      DO 20 i = 0, 4
         x(i+1) = 200.0*cos(i*2.0*pi/5.0)+x_max/2
         y(i+1) = 200.0*sin(i*2.0*pi/5.0)+y_max/2
 20   END DO
C     Draw a filled polygon inside it
      CALL aqt_use_color(2)
      CALL aqt_polygon(x, y, 5, 1)
C     Draw a filled circle inside the polygon
      CALL aqt_use_color(3)
      CALL aqt_circle(x_max/2, y_max/2, 100.0, 1)
      
C     Create another polygon (a polyline really...)
      DO 30 i = 0, 15, 1
         x(i+1) = 50.0*i+50.0
         y(i+1) = 100.0*sin(i*2.0*pi/15.0)+y_max/2.0
 30   END DO
C     Draw the polygon (no fill)
      CALL aqt_use_color(1)
      CALL aqt_polygon(x, y, 16, 0)
C     Flush pending lines, otherwise they may obscure the images (comment out to see!)
      CALL aqt_flush()
      xpos = 100.0
      ypos = 200.0  
      w = 300.0
      h = 400.0 
C     Nil-terminate strings since they are padded with ' ' characters:      
      string = '/Library/User Pictures/Animals/Orangutan.tif\0'
      CALL aqt_image(string, xpos, ypos, w, h)
C     Constant strings don't _need_ nil-termination, but seem to have a max length of 32
      CALL aqt_image('~/Pictures/m31.jpg', 10.0, 10.0, 101.0, 102.0)
C     Draw it 
      CALL aqt_render()
C     Close current graph
      CALL aqt_close()
      END

