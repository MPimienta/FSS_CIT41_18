with devicesFSS_V1; use devicesFSS_V1;

package Pkg_PO_Speed_Altitude is

   protected PO_Speed is
      procedure Update_Speed_Protected (Valor : in Speed_Samples_Type);
      function  Read_Speed_Protected return Speed_Samples_Type;
   private
      Velocidad : Speed_Samples_Type := 0;
   end PO_Speed;
   
   protected PO_Altitude is
      procedure Update_Altitude_Protected (Valor : in Altitude_Samples_Type);
      function  Read_Altitude_Protected return Altitude_Samples_Type;
   private
      Valor_Alt : Altitude_Samples_Type := 8000;  -- el sistema arranca a 8000 m
   end PO_Altitude;

end Pkg_PO_Speed_Altitude;
