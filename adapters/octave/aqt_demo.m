% aqt_demo.m --- octave script to demonstrate aqt/octave binding
%
% Testing functions in c2aqt.h from octave
%
  
aqt_stub % Must call this before the rest of commands
         
% Initialize AquaTerm adapter
aqtInit
% Get the size of the canvas from AquaTerm, 
% note that octave doesn't return data by ref
% but rather as a number of return parameters.  
[x_max, y_max] = aqtGetSize    

% Set color entries in colortable
aqtSetColormapEntry(0, 0.0, 0.0, 0.0);  % color 0 is now black
aqtSetColormapEntry(1, 1.0, 0.0, 0.0);	% color 1 is now red
aqtSetColormapEntry(2, 0.0, 1.0, 0.0);	% color 2 is now green
aqtSetColormapEntry(3, 0.0, 0.0, 1.0);	% color 3 is now blue

% Open a new graph for drawing into
aqtOpenGraph(1);
% Set the title (Default is "Figure n")
aqtSetTitle("aqt/octave binding");
aqtUseTextJustification(0); % 0 = Flush left
for i=0:3
    % Select the pen color (default is 0)
    aqtUseColor(i);
    % Set the linewidth (default is 1.0)
    aqtUseLinewidth((i+1.0)*0.5);
    % Add a line using current attributes
    aqtAddLine(100, i*50.0+100, 400, i*50.0+100);
    % Select font and size (default is Times-Roman 16pt)
    aqtUseFont("Times-Roman", 10.0+i*10.0);
    % Add the text with the current attributes
    aqtAddText(400, i*50.0+100, "Hello World!");
end  
% Close current graph => render it in window
aqtCloseGraph;

% Open a new graph for drawing into
aqtOpenGraph(2);
% Set the title (Default is "Figure n")
aqtSetTitle("More tests");
% Set the linewidth (default is 1.0)
aqtUseLinewidth(1.0);

% Draw a circle
aqtUseColor(1);
aqtAddCircle(x_max/2, y_max/2, 200.0, 0);
% Create a nice polygon
i=0:4;
x = 200.0*cos(i*2.0*pi/5.0)+x_max/2;
y = 200.0*sin(i*2.0*pi/5.0)+y_max/2;
% Draw a filled polygon inside it
aqtUseColor(2);
aqtAddPolygon(x', y', 1); % Must be column vector
% Draw a filled circle inside the polygon
aqtUseColor(3);
aqtAddCircle(x_max/2, y_max/2, 100.0, 1);

% Create another polygon (a polyline really...)
i=0:15;
x = 50.0*i+50;
y = 100.0*sin(i*2.0*pi/15.0)+y_max/2;
% Draw the polygon (no fill)
aqtUseColor(1);
aqtAddPolygon(x', y', 0); % Must be column vector

aqtAddImageFromFile("/Users/per/Pictures/soffa.jpg", 400.0, 400.0, 200.0, 160.0);

% Close current graph => render it in window
aqtCloseGraph;
