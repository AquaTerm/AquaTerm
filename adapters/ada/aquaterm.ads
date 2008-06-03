with Ada.Numerics.Generic_Complex_Types;
with AquaTerm_C;
with Interfaces.C.Strings;

package AquaTerm is

   --  This package approximates Ada.Text_IO in structure

   type Plot_Type is limited private;
   --  "plot" is AquaTerm parlance for window, canvas;
   --  a plot is either created or closed;
   --  only created plots can be drawn on or shown
   --  (we avoid the word "open" for its ambiguity between created or shown)
   
   type Real is digits 5;

   package Complex_Types is new Ada.Numerics.Generic_Complex_Types (Real);
   use Complex_Types;

   subtype Vector is Complex;
   --  a 2D vector, used for position or size;
   --  we reuse the standard complex type for ready-made 2D arithmetic;
   --  a rectangle is specified by 2 vectors Base and Size:
   --  Base = bottom left position of the rectangle,
   --  Base + Size = top right position of the rectangle

   --  We follow standard mathematics. Just to clarify:
   --  the real part Re corresponds to the horizontal axis X,
   --  the imaginary part Im corresponds to the vertical axis Y,
   --  and the origin (0,0) is the bottom left point of a plot.

   type Vector_Array is array (Positive range <>) of Vector;
   
   subtype Fraction is Real range 0.0 .. 1.0;
   
   type RGB_Color is array (1 .. 3) of Fraction;
   --  AquaTerm uses the ubiquitous Red, Green, Blue scheme for color;
   --  we make it a type so it can be passed around en bloque;
   --  naturally, index 1 corresponds to Red, 2 to Green, 3 to Blue

   ---------------------
   -- Alignment types --
   ---------------------
   
   type Horizontal_Alignment is (Left, Center, Right);
   type Vertical_Alignment is (Top, Middle, Bottom);
   
   type Alignment is record
      Horizontal : Horizontal_Alignment;
      Vertical : Vertical_Alignment;
   end record;
   
   ----------------
   -- Line style --
   ----------------
   
   type Line_Cap is (Butt, Round, Square);
   
   type Line_Style is record
      Thickness : Real;
      Color : RGB_Color;
      Cap : Line_Cap;
   end record;
   
   --------------------
   -- Default values --
   --------------------
      
   Default_Plot_Size : Vector := (500.0, 500.0);
   
   Default_Color : RGB_Color := (0.0, 0.0, 0.0);
   
   Default_Horizontal_Alignment : Horizontal_Alignment := Left;
   Default_Vertical_Alignment : Vertical_Alignment := Top;
   Default_Alignment : Alignment :=
     (Horizontal => Default_Horizontal_Alignment,
      Vertical => Default_Vertical_Alignment);

   Default_Line_Cap : Line_Cap := Butt;
   Default_Line_Thickness : Real := 1.0;   
   Default_Line_Style : Line_Style :=
      (Cap => Default_Line_Cap,
       Thickness => Default_Line_Thickness,
       Color => Default_Color);

   ----------------------
   --  Plot management --
   ----------------------

   procedure Create_Plot
     (Plot : in out Plot_Type;
      Size : Vector := Default_Plot_Size;
      Title : String := "";
      Set_As_Default : Boolean := True);
   --  if Plot is already created then Status_Error is propagated;
   --  flag Set_As_Default controls whether Set_Default_Plot (Plot) is
   --  automatically called upon a successfull creation or reuse
   
   procedure Reuse_Plot
     (Plot : in out Plot_Type;
      Size : Vector := Default_Plot_Size;
      Title : String := "";
      Set_As_Default : Boolean := True);
   --  intended to facilitate the reuse of variable Plot;
   --  equivalent to Close_Plot (Plot) followed by Create_Plot with the same arguments
   
   procedure Close_Plot (Plot : in out Plot_Type);
   procedure Close_Plot;
   
   procedure Set_Plot_Size (Plot : in out Plot_Type; Size : Vector);
   procedure Set_Plot_Size (Size : Vector);

   procedure Set_Plot_Title (Plot : in out Plot_Type; Title : String);
   procedure Set_Plot_Title (Title : String);

   procedure Show_Plot (Plot : in out Plot_Type);
   procedure Show_Plot;

   function Is_Created (Plot : in Plot_Type) return Boolean;

   procedure Set_Default_Plot (Plot : in out Plot_Type);
       
   ------------------
   -- Line drawing --
   ------------------
   
   procedure Put_Line
     (Plot : in out Plot_Type;
      Vertices : Vector_Array;
      Color : RGB_Color := Default_Color;
      Style : Line_Style := Default_Line_Style;
      Show : Boolean := True);
   --  flag Show controls whether Show_Plot (Plot)
   --  is called automatically after the new drawing

   procedure Put_Line
     (Vertices : Vector_Array;
      Color : RGB_Color := Default_Color;
      Style : Line_Style := Default_Line_Style;
      Show : Boolean := True);

   ----------------
   -- Exceptions --
   ----------------
   
   Status_Error : exception;

private
   use AquaTerm_C;
   
   type Plot_Record is record
      Nr : C_INT;
      Created : Boolean := False;
      Title_ptr : Interfaces.C.Strings.chars_ptr;
   end record;
   
   type Plot_Type is access all Plot_Record;
end;