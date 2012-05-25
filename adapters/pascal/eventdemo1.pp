program eventdemo1;
{
  eventdemo1.pp
  AquaTerm

  Created by Karl-Michael Schindler on Tue Jul 07 2010
  based on the C and Fortran examples
  Copyright (c) 2012 The AquaTerm Project. All rights reserved.

  This file contains an example of what can be done with
  AquaTerm and the corresponding AquaTerm framework

  This code can be build as a stand-alone executable (tool)
  from the command line:
      fpc eventdemo1.pp

}

{$H+} // This enables easy conversion of strings to Pchar.

uses
  Classes,
  SysUtils,
  ctypes,
  strings,
  aquaterm;

function decodeEvent(event: pchar): integer;
  var
    argv: TStringlist;
    x, y: cint;
    variables: array [1..2] of pointer;
  begin
    // Split arguments separated by a ':'
    argv := TStringlist.Create;
    ExtractStrings([':'], [], event, argv);
    if argv[0] = '42' then
      exit (-1);
    if argv[0] <> '1' then
      exit (0);
    variables[1] := @x;
    variables[2] := @y;
    sscanf(argv[1], '{%d ,%d}', variables);
    // writeln('Clicked (', x, y, ')');
    argv.Destroy;

    decodeevent := 0;
    if (10 <= x) and (x <= 90) then
    begin
      if (10 <= y) and (y <= 40) then    // exit
        decodeEvent := 3;
      if (60 <= y) and (y <= 90) then    // blue
        decodeEvent := 2;
      if (110 <= y) and (y <= 140) then  // red
        decodeEvent := 1;
    end;
  end;

var
  running: boolean;
  buffer:  pchar;

begin
  buffer := stralloc(AQT_EVENTBUF_SIZE);
  aqtInit;
  aqtOpenPlot(1);
  aqtSetPlotSize(100, 200);
  aqtSetFontsize(18);
  aqtSetFontname('Verdana');
  aqtSetPlotTitle('Menu');
  // The menu
  aqtAddLabel('Menu', 50, 175, 0.0, AQTAlignCenter or AQTAlignMiddle);

  aqtSetColor(0.8, 0.8, 0.8);
  aqtAddFilledRect(10, 110, 80, 30);
  aqtSetColor(1.0, 0.0, 0.0);
  aqtAddLabel('Red', 50, 125, 0.0, AQTAlignCenter or AQTAlignMiddle);

  aqtSetColor(0.8, 0.8, 0.8);
  aqtAddFilledRect(10, 60, 80, 30);
  aqtSetColor(0.0, 0.0, 1.0);
  aqtAddLabel('Blue', 50, 75, 0.0, AQTAlignCenter or AQTAlignMiddle);

  aqtSetColor(0.8, 0.8, 0.8);
  aqtAddFilledRect(10, 10, 80, 30);
  aqtSetColor(1.0, 1.0, 1.0);
  aqtAddLabel('Quit', 50, 25, 0.0, AQTAlignCenter or AQTAlignMiddle);

  aqtRenderPlot;

  aqtOpenPlot(2);
  aqtSetPlotSize(400, 400);
  aqtSetPlotTitle('Display');

  running := true;
  while running do
  begin
    aqtSelectPlot(1);
    aqtWaitNextEvent(buffer);
    writeln('---> ', buffer);
    case decodeEvent(buffer) of
      0: // Nil event
        writeln('No action (ignoring)');
      1: // Red square
        begin
        aqtSelectPlot(2);
        aqtSetColor(1.0, 0.0, 0.0);
        aqtAddFilledRect(100, 100, 200, 200);
        aqtRenderPlot();
        end;
      2: // Blue square
        begin
        aqtSelectPlot(2);
        aqtSetColor(0.0, 0.0, 1.0);
        aqtAddFilledRect(100, 100, 200, 200);
        aqtRenderPlot();
        end;
      3: // Exit
        begin
        writeln('Exit selected. Bye!');
        running := false;
        end;
      -1: // Error
        begin
        writeln('Error, exiting!');
        running := false;
        end;
      else
        writeln('Que?');
    end;
  end;

  // Cleaning
  StrDispose(buffer);

  aqtSelectPlot(1);
  aqtClosePlot;
  aqtSelectPlot(2);
  aqtClosePlot;
end.
