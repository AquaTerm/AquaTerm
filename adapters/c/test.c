#include <math.h>
#include "c2aqt.h"

enum {
  LEFT,
  CENTER,
  RIGHT
};

int main(void)
{
  int i;
  float x_max, y_max;
  float x[16], y[16];
  float pi = 4.0*atan(1.0);
  //
  // Testing all functions in c2aqt.h
  //

  // Initialize AquaTerm adapter
  aqtInit();
  
  // Get info from AquaTerm

  // Set color entries in colortable
  aqtSetColormapEntry(0, 0.0, 0.0, 0.0);	// color 0 is now black
  aqtSetColormapEntry(1, 1.0, 0.0, 0.0);	// color 1 is now red
  aqtSetColormapEntry(2, 0.0, 1.0, 0.0);	// color 2 is now green
  aqtSetColormapEntry(3, 0.0, 0.0, 1.0);	// color 3 is now blue

  // Open a new graph for drawing into
  aqtOpenGraph(1);
  // Set the title (Default is "Figure n")
  aqtSetTitle("Test of c2aqt");
  aqtUseTextJustification(LEFT);
  for (i=0;i<4;i++)
  {
    // Select the pen color (default is 0)
    aqtUseColor(i);
    // Set the linewidth (default is 1.0)
    aqtUseLinewidth((i+1.0)*0.5);
    // Add a line using current attributes
    aqtAddLine(100, i*50.0+100, 400, i*50.0+100);
    // Select font and size (default is Times-Roman 16pt)
    aqtUseFont("Times-Roman", 10.0+i*10.0);
    // Add the text with the current attributes
    aqtAddText(400, i*50.0+100, "Hello World!");
  }
  // Close current graph => render it in window
  aqtCloseGraph();

  // Open a new graph for drawing into
  aqtOpenGraph(2);
  // Get the size of the canvas
  aqtGetSize(&x_max, &y_max);
  // Set the title (Default is "Figure n")
  aqtSetTitle("More tests of c2aqt");
  // Set the linewidth (default is 1.0)
  aqtUseLinewidth(1.0);

  // Draw a circle
  aqtUseColor(1);
  aqtAddCircle(x_max/2, y_max/2, 200.0, 0);
  // Create a nice polygon
  for (i=0; i < 5;i++)
  {
    x[i] = 200.0*cos(i*2.0*pi/5.0)+x_max/2;
    y[i] = 200.0*sin(i*2.0*pi/5.0)+y_max/2;
  }
  // Draw a filled polygon inside it
  aqtUseColor(2);
  aqtAddPolygon(x, y, 5, 1);
  // Draw a filled circle inside the polygon
  aqtUseColor(3);
  aqtAddCircle(x_max/2, y_max/2, 100.0, 1);

  // Create another polygon (a polyline really...)
  for (i=0; i < 16;i++)
  {
    x[i] = 50.0*i+50;
    y[i] = 100.0*sin(i*2.0*pi/15.0)+y_max/2;
  }
  // Draw the polygon (no fill)
  aqtUseColor(1);
  aqtAddPolygon(x, y, 16, 0);

  // Close current graph => render it in window
  aqtCloseGraph();

  return 0;
}
