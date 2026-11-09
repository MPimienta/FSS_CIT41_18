package body Pkg_PO_Status_Record is
    protected body PO_Status_Record is
    
        procedure Update_Pitch_Status(Pitch : Pitch_Samples_Type) is
        begin
            Current_Pitch_Status := Pitch;
        end Update_Pitch_Status;

        procedure Update_Roll_Status(Roll : Roll_Samples_Type) is
        begin
            Current_Roll_Status := Roll;
        end Update_Roll_Status;

        procedure Update_Altitude_Status(Altitude : Altitude_Samples_Type) is
        begin
            Current_Altitude_Status := Altitude;
        end Update_Altitude_Status;

        procedure Update_Joystick_Status(Joystick : Joystick_Samples_Type) is
        begin
            Current_Joystick_Status := Joystick;
        end Update_Joystick_Status;

        procedure Update_Pilot_Power_Status(Power : Power_Samples_Type) is
        begin
            Current_Pilot_Power_Status := Power;
        end Update_Pilot_Power_Status;

        procedure Update_Speed_Status(Speed : Speed_Samples_Type) is
        begin
            Current_Speed_Status := Speed;
        end Update_Speed_Status;

        procedure Update_Warning_Roll_High(B : Boolean) is
        begin
            Current_Warning_Roll_High := B;
        end Update_Warning_Roll_High;

        procedure Update_Warning_Roll_Low(B : Boolean) is
        begin
            Current_Warning_Roll_Low := B;
        end Update_Warning_Roll_Low;

        function Read_All_Status return System_Snapshot is
            Snapshot : System_Snapshot;
        begin
            Snapshot.Pitch    := Current_Pitch_Status;
            Snapshot.Roll     := Current_Roll_Status;
            Snapshot.Altitude := Current_Altitude_Status;
            Snapshot.Joystick := Current_Joystick_Status;
            Snapshot.Power    := Current_Pilot_Power_Status;
            Snapshot.Speed    := Current_Speed_Status;
            Snapshot.Warning_Roll_High := Current_Warning_Roll_High;
            Snapshot.Warning_Roll_Low := Current_Warning_Roll_Low;

            return Snapshot;
        end Read_All_Status;
        
    end PO_Status_Record;
end Pkg_PO_Status_Record;
