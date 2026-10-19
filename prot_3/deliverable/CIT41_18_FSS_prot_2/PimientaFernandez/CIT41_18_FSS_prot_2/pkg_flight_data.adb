package body Pkg_Flight_Data is
    protected body Flight_Data is
        
        procedure Update_Pitch_Protected (Pitch : Pitch_Samples_Type) is
        begin
            Current_Pitch := Pitch;
        end Update_Pitch_Protected;

        procedure Update_Roll_Protected (Roll: Roll_Samples_Type) is
        begin
            Current_Roll := Roll;
        end Update_Roll_Protected;

        function Read_Pitch_Protected return Pitch_Samples_Type is
        begin
            return Current_Pitch;
        end Read_Pitch_Protected;

        function Read_Roll_Protected return Roll_Samples_Type is
        begin
            return Current_Roll;
        end Read_Roll_Protected;
        
    end Flight_Data;
end Pkg_Flight_Data;
