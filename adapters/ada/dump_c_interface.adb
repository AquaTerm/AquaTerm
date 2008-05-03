with Ada.Text_IO;
with Ada.Strings.Unbounded;

procedure Dump_C_Interface is

-- This program is used to generate Aquaterm.C_Interface
-- The main part is an edit of "aquaterm.h"

use Ada.Strings.Unbounded;
use Ada.Text_IO;

type Types is
  (Type_char_ptr,
   Type_const_char_ptr,
   Type_const_void_ptr,
   Type_float,
   Type_float_ptr,
   Type_int,
   Type_Proc_Ptr);

procedure Start is begin
   Put_Line ("with Interfaces.C;");
   Put_Line ("with Interfaces.C.Strings;");
   Put_Line ("with System;");
   New_Line;
   Put_Line ("package AquaTerm.C_Interface is");
   New_Line;
   Put_Line ("   -- thin binding to the AquaTerm C API");
   Put_Line ("   -- this is the output of Dump_C_Interface");
   Put_Line ("   -- consider editing that to make changes to this");
   New_Line;
   Put_Line ("   subtype C_CHAR_PTR is Interfaces.C.Strings.chars_ptr;");
   Put_Line ("   subtype C_CONST_CHAR_PTR is Interfaces.C.Strings.chars_ptr;");
   Put_Line ("   subtype C_CONST_VOID_PTR is System.Address;");
   Put_Line ("   subtype C_FLOAT is Interfaces.C.C_float;");
   Put_Line ("   subtype C_FLOAT_PTR is System.Address;");
   Put_Line ("   subtype C_INT is Interfaces.C.int;");
   Put_Line ("   subtype C_PROC_PTR is System.Address;");
   New_Line;
end;

procedure Define (Name : String; Number : Integer) is begin
   Put_Line ("   C_" & Name & " : constant :=" & Integer'Image (Number) & ";");
end;

procedure Comment (Text : String) is begin
   New_Line;
   Put_Line ("-- " & Text);
   New_Line;
end;

procedure Extern_Const_Int (Name : String; Value : Integer := Integer'First) is begin
   Put_Line ("   C_" & Name & " : constant :=" & Integer'Image (Value) & ";");
end;

procedure Import (Name : String) is begin
   Put_Line ("   pragma Import (C, C_" & Name & ", """ & Name & """);");
end;

type Typed_Name is record
   The_Type : Types;
   Name : Unbounded_String;
end record;

function Type_Of (X : Typed_Name) return String is
   Z : String := Types'Image (X.The_Type);
begin
   return "C_" & Z (6 .. Z'Last);
end;

function Name_Of (X : Typed_Name) return String is begin
   return To_String (X.Name);
end;

type Typed_Name_Series is array (Positive range <>) of Typed_Name;

Null_Series : Typed_Name_Series (1 .. 0);

procedure Put_Parameters (X : Typed_Name_Series) is
begin
   if X'Length > 0 then
      Put (" (");
      for I in X'Range loop
         if I > X'First then Put ("; "); end if;
         Put (Name_Of (X(I)) & " : " & Type_Of (X(I)));
      end loop;
      Put (")");
   end if;
end;

procedure Proc (Name : String; Parameters : Typed_Name_Series := Null_Series) is
begin
   Put ("   procedure C_" & Name);
   Put_Parameters (Parameters);
   Put_Line (";");
   Import (Name);
end;

procedure Func (X : Typed_Name_Series) is
begin
   Put ("   function C_" & Name_Of (X(X'First)));
   Put_Parameters (X(X'First + 1 .. X'Last));
   Put_Line (" return " & Type_Of(X(X'First)) & ";");
   Import (Name_Of (X(X'First)));
end;

-- SYNTAX SUGAR

function char_ptr (Name : String) return Typed_Name is
begin
   return (Name => To_Unbounded_String (Name), The_Type => Type_char_ptr);
end;

function const_char_ptr (Name : String) return Typed_Name is
begin
   return (Name => To_Unbounded_String (Name), The_Type => Type_const_char_ptr);
end;

function const_void_ptr (Name : String) return Typed_Name is
begin
   return (Name => To_Unbounded_String (Name), The_Type => Type_const_void_ptr);
end;

function float (Name : String) return Typed_Name is
begin
   return (Name => To_Unbounded_String (Name), The_Type => Type_float);
end;

function float_ptr (Name : String) return Typed_Name is
begin
   return (Name => To_Unbounded_String (Name), The_Type => Type_float_ptr);
end;

function int (Name : String) return Typed_Name is
begin
   return (Name => To_Unbounded_String (Name), The_Type => Type_int);
end;

function Proc_Ptr (Name : String) return Typed_Name is
begin
   return (Name => To_Unbounded_String (Name), The_Type => Type_Proc_Ptr);
end;

procedure Func (X1 : Typed_Name) is begin Func (Typed_Name_Series'(1 => X1)); end;
procedure Proc (Name : String; X1 : Typed_Name) is begin Proc (Name,Typed_Name_Series'(1 => X1)); end;

-- MAIN PROGRAM

begin

Start;

Define ("AQT_EVENTBUF_SIZE", 128);

Comment (" Constants that specify linecap styles. ");
Extern_Const_Int ("AQTButtLineCapStyle",0);
Extern_Const_Int ("AQTRoundLineCapStyle",1);
Extern_Const_Int ("AQTSquareLineCapStyle",2);

Comment (" Constants that specify horizontal alignment for labels. ");
Extern_Const_Int ("AQTAlignLeft",0);
Extern_Const_Int ("AQTAlignCenter",1);
Extern_Const_Int ("AQTAlignRight",2);

Comment (" Constants that specify vertical alignment for labels. ");
Extern_Const_Int ("AQTAlignMiddle",0);
Extern_Const_Int ("AQTAlignBaseline",4);
Extern_Const_Int ("AQTAlignBottom",8);
Extern_Const_Int ("AQTAlignTop",16);

Comment (" Class initialization etc.");
Func (int ("aqtInit"));
Proc ("aqtTerminate");
Proc ("aqtSetEventHandler", Proc_Ptr ("func"));
 --(void (*func)(int ref, const char *event));

Comment (" Control operations ");
Proc ("aqtOpenPlot", int ("refNum"));
Func (int ("aqtSelectPlot") & int ("refNum"));
Proc ("aqtSetPlotSize", float ("width") & float ("height"));
Proc ("aqtSetPlotTitle", const_char_ptr ("title"));
Proc ("aqtRenderPlot");
Proc ("aqtClearPlot");
Proc ("aqtClosePlot");

Comment (" Event handling ");
Proc ("aqtSetAcceptingEvents", int ("flag"));
Func (int ("aqtGetLastEvent") & char_ptr ("buffer"));
Func (int ("aqtWaitNextEvent") & char_ptr ("buffer"));

Comment (" Plotting related commands ");

Comment (" Clip rect, applies to all objects ");
Proc ("aqtSetClipRect", float ("originX") & float ("originY") & float ("width") & float ("height"));
Proc ("aqtSetDefaultClipRect");

Comment (" Colormap (utility) ");
Func (int ("aqtColormapSize"));
Proc ("aqtSetColormapEntry", int ("entryIndex") & float ("r") & float ("g") & float ("b"));
Proc ("aqtGetColormapEntry", int ("entryIndex") & float_ptr ("r") & float_ptr ("g") & float_ptr ("b"));
Proc ("aqtTakeColorFromColormapEntry", int ("index"));
Proc ("aqtTakeBackgroundColorFromColormapEntry", int ("index"));

Comment (" Color handling ");
Proc ("aqtSetColor", float ("r") & float ("g") & float ("b"));
Proc ("aqtSetBackgroundColor", float("r") & float("g") & float("b"));
Proc ("aqtGetColor", float_ptr("r") & float_ptr("g") & float_ptr("b"));
Proc ("aqtGetBackgroundColor", float_ptr("r") & float_ptr("g") & float_ptr("b"));

Comment (" Text handling ");
Proc ("aqtSetFontname", const_char_ptr ("newFontname"));
Proc ("aqtSetFontsize", float ("newFontsize"));
Proc ("aqtAddLabel", const_char_ptr("text") & float("x") & float("y") & float("angle") & int("align"));
Proc ("aqtAddShearedLabel", const_char_ptr("text") & float("x") & float("y") & float("angle") & float ("shearAngle") & int ("align"));

Comment (" Line handling ");
Proc ("aqtSetLinewidth", float ("newLinewidth"));
Proc ("aqtSetLinestylePattern", float_ptr ("newPattern") & int ("newCount") & float ("newPhase"));
Proc ("aqtSetLinestyleSolid");
Proc ("aqtSetLineCapStyle", int ("capStyle"));
Proc ("aqtMoveTo", float ("x") & float ("y"));
Proc ("aqtAddLineTo", float("x") & float("y"));
Proc ("aqtAddPolyline", float_ptr("x") & float_ptr("y") & int("pointCount"));

Comment(" Rect and polygon handling");
Proc ("aqtMoveToVertex", float ("x") & float ("y"));
Proc ("aqtAddEdgeToVertex", float ("x") & float ("y"));
Proc ("aqtAddPolygon", float_ptr("x") & float_ptr("y") & int ("pointCount"));
Proc ("aqtAddFilledRect", float ("originX") & float ("originY") & float("width") & float("height"));
Proc ("aqtEraseRect", float ("originX") & float("originY") & float("width") & float("height"));

Comment (" Image handling ");
Proc ("aqtSetImageTransform", float ("m11") & float ("m12") & float ("m21") & float ("m22") & float ("tX") & float ("tY"));
Proc ("aqtResetImageTransform");
Proc ("aqtAddImageWithBitmap", const_void_ptr ("bitmap") & int ("pixWide") & int ("pixHigh") & float ("destX") & float ("destY") & float ("destWidth") & float ("destHeight"));
Proc ("aqtAddTransformedImageWithBitmap", const_void_ptr("bitmap") & int ("pixWide") & int ("pixHigh") & float ("clipX") & float ("clipY") & float ("clipWidth") & float ("clipHeight"));

Put_Line ("end;");
Put_Line ("-- (C) 2008 Marius Amado-Alves");
end;
-- (C) 2008 Marius Amado-Alves
