package body protectedSpeedAltitude is

   protected body protectedSpeedAltitude is

      procedure Calcular_velocidad_aeronave
        (Potencia  : in  Integer;
         Velocidad : out Integer) is
         Resultado : Integer;
      begin
         Resultado := Integer (Float (Potencia) * 1.2);
         if Resultado > 1023 then
            Resultado := 1023;
         end if;
         Velocidad := Resultado;
      end Calcular_velocidad_aeronave;

   end protectedSpeedAltitude;

end protectedSpeedAltitude;
