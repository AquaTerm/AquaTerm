C   Testing all functions in c2aqt.h
C
      INTEGER i
      REAL x, y, x_max, y_max, pi
      DIMENSION x(16)
      DIMENSION y(16)
      PARAMETER (pi = 4.0*atan(1.0))
C     
C     
C     Initialize AquaTerm adapter
      CALL aqt_init()
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
C     Open a new graph for drawing into
      CALL aqt_open(1)
C     Set the title (Default is "Figure n")
      CALL aqt_title("Test of c2aqt")
      CALL aqt_textjust(LEFT)
      DO 10 i = 0, 3
C     Select the pen color (default is 0)
         CALL aqt_use_color(i)
C     Set the linewidth (default is 1.0)
         CALL aqt_linewidth((i+1.0)*0.5)
C     Add a line using current attributes
         CALL aqt_line(100.0, i*50.0+100, 400.0, i*50.0+100.0)
C     Select font and size (default is Times-Roman 16pt)
         CALL aqt_font("Times-Roman", 10.0+i*10.0)
C     Add the text with the current attributes
         CALL aqt_text(400.0, i*50.0+100.0, "Hello World!")
 10   END DO
C     Close current graph => render it in window
      CALL aqt_close()
C     
C     Open a new graph for drawing into
      CALL aqt_open(2)
C     Get the size of the canvas
      CALL aqt_get_size(x_max, y_max)
C     Set the title (Default is "Figure n")
      CALL aqt_title("More tests of c2aqt")
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
C     Close current graph => render it in window
      CALL aqt_close()
      END

