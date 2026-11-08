Package body Pkg_Status_Record is
    protected body Status_Record is
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
        end Update_Pitch_Status;

        procedure Update_Speed_Status(Speed : Speed_Samples_Type) is
        begin
            Current_Speed_Status := Speed;
        end Update_Speed_Status;









