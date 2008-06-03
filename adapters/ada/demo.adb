--with Ada.Numerics;
--with Ada.Numerics.Generic_Elementary_Functions;
with ada.text_io;use ada.text_io;
with AquaTerm;

procedure Demo is

   --  The 'standard' Aquaterm demo using the thick Ada binding and in Ada style.
   --  Standard = "demo.c" by Per Persson.
   --  Executable built with: gnatmake demo -largs -laquaterm

   use AquaTerm;
   
   Plot : Plot_Type;
   
   type Colors is (White, Black, Red, Green, Blue, Purple, Yellow, Dark_Green);
   
   Color : array (Colors) of RGB_Color :=
     ( White      => (1.0, 1.0, 1.0),
       Black      => (0.0, 0.0, 0.0),
       Red        => (1.0, 0.0, 0.0),
       Green      => (0.0, 1.0, 0.0),
       Blue       => (0.0, 0.0, 1.0),
       Purple     => (1.0, 0.0, 1.0),
       Yellow     => (1.0, 1.0, 0.5),
       Dark_Green => (0.0, 0.5, 0.5)  );
begin
   Create_Plot
     (Plot,
      Size => (620.0,420.0),
      Title => "Testview (using the thick Ada binding)");
   Put_Text
     (Plot => Plot,
      Text => "Testview 620x420 pt",
      Font => "Helvetica",
      Base => (4.0, 412.0),
      Align => (Horizontal => Left,
                Vertical => Default_Vertical_Alignment),
      Size => 12.0);
   Draw_Line
     (Plot => Plot,
      Vertices => (( 20.0,  20.0),
                   (600.0,  20.0),
                   (600.0, 400.0),
                   ( 20.0, 400.0),
                   ( 20.0,  20.0)),
      Color => (0.0, 0.0, 0.0));
   Show_Plot;
   Close_Plot;
end;
-- (C) 2008 Marius Amado-Alves
