with devicesFSS_V1; use devicesFSS_V1;

package protectedSpeedAltitude is

   protected Speed is
      procedure Set (Valor : in Speed_Samples_Type);
      function  Get return Speed_Samples_Type;
   private
      Velocidad : Speed_Samples_Type := 0;
   end Speed;
   
   protected Altitude is
      procedure Set (Valor : in Altitude_Samples_Type);
      function  Get return Altitude_Samples_Type;
   private
      Valor_Alt : Altitude_Samples_Type := 8000;  -- el sistema arranca a 8000 m
   end Altitude;

end protectedSpeedAltitude;
