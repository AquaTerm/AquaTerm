with ada.text_io; use ada.text_io;
with Ada.Finalization;

package body AquaTerm is

   Init_Called : Boolean := False;
   Init_Result : C_INT;
   Plot_Count : Natural := 0;   
   Default_Plot : Plot_Type;

   Cap_Code : array (Line_Cap) of C_INT :=
      (Butt => C_AQTButtLineCapStyle,
       Round => C_AQTRoundLineCapStyle,
       Square => C_AQTSquareLineCapStyle);

   -------------------
   -- Abbreviations --
   -------------------
   
   procedure Inc (X : in out Integer) is begin X := X + 1; end;

   procedure Check (Plot : Plot_Type; Message : String) is
   begin
      if not Is_Created (Plot) then
         raise Status_Error with Message;
      end if;
   end;

   procedure aqtSelectPlot (refNum : C_INT) is
      Result : C_INT;
   begin
      Result := AquaTerm_C.C_aqtSelectPlot (refNum);
   end;

   procedure aqtSetColor (Color : RGB_Color) is
   begin
      C_aqtSetColor (C_FLOAT (Color (1)),
                     C_FLOAT (Color (2)),
                     C_FLOAT (Color (3)));
   end;
   
   pragma Inline (Inc);
   pragma Inline (Check);
   pragma Inline (aqtSelectPlot);
   pragma Inline (aqtSetColor);

   -------------------------------------------------------
   -- Package initialization and finalization (private) --
   -------------------------------------------------------
   
   procedure Initialize_Package is
   begin
      if not Init_Called then
         Init_Result := C_aqtInit;
         Init_Called := True;
      end if;
   end;
   
   procedure Finalize_Package is
   begin
      C_aqtTerminate;
   end;

   type Dummy_Controlled_Type is
      new Ada.Finalization.Controlled with null record;
   Dummy : Dummy_Controlled_Type;
   procedure Finalize (Dummy : in out Dummy_Controlled_Type) is
   begin
      Finalize_Package;
   end;

   ---------------------
   -- Plot management --
   ---------------------
   
   procedure Create_Plot
     (Plot : in out Plot_Type;
      Size : Vector := Default_Plot_Size;
      Title : String := "";
      Set_As_Default : Boolean := True) is
   begin
      if Is_Created (Plot) then
         raise Status_Error with "Create_Plot";
      end if;
      if Plot = null then
         Plot := new Plot_Record;
      end if;
      Inc (Plot_Count);
      Plot.Nr := C_INT (Plot_Count);
      C_aqtOpenPlot (Plot.Nr);
      Plot.Created := True;
      Set_Plot_Size (Plot, Size);
      Set_Plot_Title (Plot, Title);
      if Set_As_Default then
         Set_Default_Plot (Plot);
      end if;
   end;

   procedure Reuse_Plot
     (Plot : in out Plot_Type;
      Size : Vector := Default_Plot_Size;
      Title : String := "";
      Set_As_Default : Boolean := True) is
   begin
      if Is_Created (Plot) then Close_Plot (Plot); end if;
      Create_Plot (Plot, Size, Title, Set_As_Default);
   end;

   procedure Close_Plot (Plot : in out Plot_Type) is
   begin
      Check (Plot, "Close_Plot");
      aqtSelectPlot(Plot.Nr);
      C_aqtClosePlot;
      Interfaces.C.Strings.Free (Plot.Title_ptr);
      Plot.Created := False;
   end;

   procedure Set_Plot_Size (Plot : in out Plot_Type; Size : Vector) is
   begin
      Check (Plot, "Set_Plot_Size");
      aqtSelectPlot(Plot.Nr);
      C_aqtSetPlotSize (C_FLOAT(Size.Re), C_FLOAT(Size.Im));
   end;

   procedure Set_Plot_Title (Plot : in out Plot_Type; Title : String) is
      use Interfaces.C.Strings;
   begin
      
      Free (Plot.Title_ptr);
      Plot.Title_ptr := New_String (Title & Character'Val(0));
      aqtSelectPlot (Plot.Nr);
      C_aqtSetPlotTitle (Plot.Title_ptr);
   end;

   procedure Show_Plot (Plot : in out Plot_Type) is
   begin
      Check (Plot, "Show_Plot");
      aqtSelectPlot(Plot.Nr);
      C_aqtRenderPlot;
   end;
   
   ----------------------------------
   -- Is_Created, Set_Default_Plot --
   ----------------------------------

   function Is_Created (Plot : in Plot_Type) return Boolean is
   begin
      return Plot /= null and then Plot.Created;
   end;
   
   procedure Set_Default_Plot (Plot : in out Plot_Type) is
   begin
      Default_Plot := Plot;
   end;

   ------------------
   -- Line drawing --
   ------------------
         
   procedure Put_Line
     (Plot : in out Plot_Type;
      Vertices : Vector_Array;
      Color : RGB_Color := Default_Color;
      Style : Line_Style := Default_Line_Style;
      Show : Boolean := True)
   is
      V : array (1 .. 2, Vertices'Range) of C_FLOAT;
   begin
      Check (Plot, "Put_Line");
      aqtSelectPlot (Plot.Nr);
      aqtSetColor (Style.Color);
      C_aqtSetLinewidth (C_FLOAT(Style.Thickness));
      C_aqtSetLineCapStyle(Cap_Code (Style.Cap));
      for I in Vertices'Range loop
         V (1, I) := C_FLOAT (Vertices (I).Re);
         V (2, I) := C_FLOAT (Vertices (I).Im);
      end loop;
      C_aqtAddPolyline
        (V (1, V'First(1))'Address,
         V (2, V'First(2))'Address,
         C_INT (V'Length));
      if Show then Show_Plot (Plot); end if;
   end;

   -----------------------------------------
   -- Default plot variants of operations --
   -----------------------------------------
   
   procedure Set_Plot_Size (Size : Vector) is
   begin
      Set_Plot_Size (Default_Plot, Size);
   end;

   procedure Set_Plot_Title (Title : String) is
   begin
      Set_Plot_Title (Default_Plot, Title);
   end;

   procedure Show_Plot is
   begin
      Show_Plot (Default_Plot);
   end;

   procedure Close_Plot is
   begin
      Close_Plot (Default_Plot);
   end;

   procedure Put_Line
     (Vertices : Vector_Array;
      Color : RGB_Color := Default_Color;
      Style : Line_Style := Default_Line_Style;
      Show : Boolean := True) is
   begin
      Put_Line (Default_Plot, Vertices, Color, Style, Show);
   end;

begin
   Initialize_Package;
end;