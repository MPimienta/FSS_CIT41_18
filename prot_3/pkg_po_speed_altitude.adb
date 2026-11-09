package body Pkg_PO_Speed_Altitude is

   protected body PO_Speed is

      procedure Update_Speed_Protected (Valor : in Speed_Samples_Type) is
      begin
         Velocidad := Valor;
      end Update_Speed_Protected;

      function Read_Speed_Protected return Speed_Samples_Type is
      begin
         return Velocidad;
      end Read_Speed_Protected;

   end PO_Speed;

   protected body PO_Altitude is
   	procedure Update_Altitude_Protected (Valor : in Altitude_Samples_Type) is
	begin
	   Valor_Alt := Valor;
	end Update_Altitude_Protected;

	function Read_Altitude_Protected return Altitude_Samples_Type is
	begin
	   return Valor_Alt;
	end Read_Altitude_Protected;
   end PO_Altitude;

end Pkg_PO_Speed_Altitude;
