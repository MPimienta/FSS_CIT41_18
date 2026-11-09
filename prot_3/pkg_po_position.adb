package body Pkg_PO_Position is
    protected body PO_Position is
        
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
        
    end PO_Position;
end Pkg_PO_Position;
