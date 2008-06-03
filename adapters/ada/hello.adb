with AquaTerm;
procedure Hello is
   use AquaTerm;
   Plot : Plot_Type;
begin
   Create_Plot (Plot, Size => (600.0, 400.0));
   Put_Text (Plot => Plot,
             Base => (300.0, 200.0),
             Text => "HelloAquaTerm! (Ada)",
             Align => (Horizontal => Left,
                       Vertical => Default_Vertical_Alignment));
   Show_Plot;
   Close_Plot;
end;
-- (C) 2008 Marius Amado-Alves

-- Built with: gnatmake hello -largs -framework AquaTerm