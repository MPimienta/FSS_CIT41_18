with devicesFSS_V1; use devicesFSS_V1;
with Tools; use Tools;

package Pkg_PO_Position is
    protected PO_Position is
        pragma Priority (18);

        procedure Update_Pitch_Protected (Pitch : Pitch_Samples_Type);
        procedure Update_Roll_Protected (Roll : Roll_Samples_Type);
        function Read_Pitch_Protected return Pitch_Samples_Type;
        function Read_Roll_Protected return Roll_Samples_Type;
    private
        Current_Pitch : Pitch_Samples_Type := 0;
        Current_Roll : Roll_Samples_Type := 0;
    end PO_Position;
end Pkg_PO_Position;
