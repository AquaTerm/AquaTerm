      PROGRAM demo
C     Initialize. Do it or fail miserably...
      CALL aqtInit()
C     Open up a plot for drawing
      CALL aqtOpenPlot(1)
      CALL aqtSetPlotSize(620.0,420.0)
      CALL aqtSetPlotTitle('Testview')
C     Set color explicitly
      CALL aqtSetColor(0.0, 0.0, 0.0)
C     Frame plot
      CALL aqtMoveTo(20., 20.)
      CALL aqtAddLineTo(600.,400.)
      CALL aqtRenderPlot()
      CALL aqtAddLabel('Testview', 4.0, 412.0, 0.0, AQTAlignLeft)
      END
