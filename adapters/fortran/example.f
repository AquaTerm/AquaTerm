C Simple example to use AquaTerm from FORTRAN
C
      INTEGER x, y, x_size, y_size
C      
C     Start up AquaTerm
      CALL f2aqt_init()
C     get size of view
      CALL f2aqt_info(x_size, y_size)
C
C     draw a box
      CALL f2aqt_move(10,10)
      CALL f2aqt_vector(x_size-10,10)
      CALL f2aqt_vector(x_size-10, y_size-100)
      CALL f2aqt_vector(10, y_size-100)
      CALL f2aqt_vector(10,10)
      CALL f2aqt_color(2)
      DO 1 x=1,((x_size-40)/40)
         CALL f2aqt_move(40*x, 10)
         CALL f2aqt_vector(40*x, y_size-100)
 1    CONTINUE
      DO 2 y=1,((y_size-100)/40)
         CALL f2aqt_move(10, 40*y)
         CALL f2aqt_vector(x_size-10, 40*y)
 2    CONTINUE
C     make text centered
      CALL f2aqt_justify(1)
C     put som text
      CALL f2aqt_put_text(x_size/2, y_size-50, 'Hello FORTRAN World')
C     render the view (for efficiency, nothing is rendered until this command)
      CALL f2aqt_render()
      END
