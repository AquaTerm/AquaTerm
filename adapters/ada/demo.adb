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
   Create_Plot (Plot);
   Put_Line (Plot, ((0.0,0.0), (10.0,10.0)));
   Show_Plot;
   Close_Plot;
end;
-- (C) 2008 Marius Amado-Alves
