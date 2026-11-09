package body protectedSpeedAltitude is

   protected body Speed is

      procedure Set (Valor : in Speed_Samples_Type) is
      begin
         Velocidad := Valor;
      end Set;

      function Get return Speed_Samples_Type is
      begin
         return Velocidad;
      end Get;

   end Speed;

   protected body Altitude is
   	procedure Set (Valor : in Altitude_Samples_Type) is
	begin
	   Valor_Alt := Valor;
	end Set;
	function Get return Altitude_Samples_Type is
	begin
	   return Valor_Alt;
	end Get;
   end Altitude;

end protectedSpeedAltitude;
