with devicesFSS_V1; use devicesFSS_V1;
with Tools; use Tools;

package Pkg_Status_Record is
    protected Status_Record is
        procedure Update_Pitch_Status(Pitch : Pitch_Samples_Type);
        procedure Update_Roll_Status(Roll : Roll_Samples_Type);
        procedure Update_Altitude_Status(Altitude : Altitude_Samples_Type);
        procedure Update_Joystick_Status(Joystick : Joystick_Samples_Type);
        procedure Update_Pilot_Power_Status(Power : Power_Samples_type);
        procedure Update_Speed_Status(Speed : Speed_Samples_Type);
        function Read_Pitch_Status;
        function Read_Roll_Status;
        function Read_Altitude_Status;
        function Read_Joystick_Status;
        function Read_Pilot_Power_Status;
        function Read_Speed_Status;
    private 
        Current_Pitch_Status: Pitch_Samples_Type := 0;
        Current_Roll_Status: Roll_Samples_Type := 0;
        Current_Altitude: Altitude_Samples_Type := 0;
        Current_Joystick_Status: Joystick_Samples_Type := 0;
        Current_Pilot_Power_Status: Power_Samples_Type := 0;
        Current_Speed_Status: Speed_Samples_Type := 0;
    end Status_Record;
end Pkg_Status_Record;




