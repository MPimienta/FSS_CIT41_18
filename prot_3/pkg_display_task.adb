with Ada.Real_Time; use Ada.Real_Time;
with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;
-- with pkg_status_record

Package body Pkg_Display_Task is
    Task body Display_Task is
        Current_Altitude: Altitude_Samples_Type := 0;
        Current_Pitch: Pitch_Samples_Type := 0;
        Current_Roll: Roll_Samples_Type := 0;
        Current_Joystick: Joystick_Samples_Type := 0;
        Current_Pilot_Power: Power_Samples_Type := 0;
        Current_Speed: Speed_Samples_Type := 0;



