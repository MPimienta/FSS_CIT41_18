with devicesFSS_V1; use devicesFSS_V1;
with Tools; use Tools;

package Pkg_PO_Status_Record is

    type System_Snapshot is record
        -- Variables para guardar todos los datos del sistema
        Pitch    : Pitch_Samples_Type;
        Roll     : Roll_Samples_Type;
        Altitude : Altitude_Samples_Type;
        Joystick : Joystick_Samples_Type;
        Power    : Power_Samples_Type;
        Speed    : Speed_Samples_Type;

        -- Booleans para mostrar mensajes de aviso al piloto
        Warning_Roll_High : Boolean;
        Warning_Roll_Low : Boolean;
    end record;

    protected PO_Status_Record is
        pragma Priority(15);
        procedure Update_Pitch_Status(Pitch : Pitch_Samples_Type);
        procedure Update_Roll_Status(Roll : Roll_Samples_Type);
        procedure Update_Altitude_Status(Altitude : Altitude_Samples_Type);
        procedure Update_Joystick_Status(Joystick : Joystick_Samples_Type);
        procedure Update_Pilot_Power_Status(Power : Power_Samples_Type);
        procedure Update_Speed_Status(Speed : Speed_Samples_Type);
        procedure Update_Warning_Roll_High(B : Boolean);
        procedure Update_Warning_Roll_Low(B : Boolean);
        
        function Read_All_Status return System_Snapshot;
        
    private 
        Current_Pitch_Status        : Pitch_Samples_Type := 0;
        Current_Roll_Status         : Roll_Samples_Type := 0;
        Current_Altitude_Status     : Altitude_Samples_Type := 0;
        Current_Joystick_Status     : Joystick_Samples_Type := (0,0);
        Current_Pilot_Power_Status  : Power_Samples_Type := 0;
        Current_Speed_Status        : Speed_Samples_Type := 0;
        Current_Warning_Roll_High   : Boolean := False;
        Current_Warning_Roll_Low    : Boolean := False;
    end PO_Status_Record;
end Pkg_PO_Status_Record;
