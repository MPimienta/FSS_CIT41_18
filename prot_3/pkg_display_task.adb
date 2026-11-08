with Ada.Real_Time; use Ada.Real_Time;
with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;
with Pkg_Status_Record; use Pkg_Status_Record;

package body Pkg_Display_Task is
    
    task body Display_Task is
        Siguiente_Instante : Time;
        Intervalo          : Time_Span := Milliseconds (1000);
        Current_Data    : System_Snapshot;
    begin
        Siguiente_Instante := Big_Bang + Intervalo;

        loop
            Start_Activity ("Task Display launched");
        
            -- Extraer todos los datos actuales del sistema
            Current_Data := Status_Record.Read_All_Status;

            Display_Joystick (Current_Data.Joystick);
            Display_Pitch (Current_Data.Pitch);
            Display_Roll (Current_Data.Roll);
            Display_Altitude (Current_Data.Altitude);
            Display_Pilot_Power (Current_Data.Power);
            Display_Speed (Current_Data.Speed);

            -- Evaluar los booleans para mostrar avisos o no
        
            if Current_Data.Warning_Roll_High then
                Display_Message( "Angulo alabeo superior a 35 grados");
            end if;

            if Current_Data.Warning_Roll_Low then
                Display_Message("Angulo alabeo inferior a -35 grados");
            end if;

         Finish_Activity ("Task Display Ended");

         delay until Siguiente_Instante;
         Siguiente_Instante := Siguiente_Instante + Intervalo;
      end loop;
   end Display_Task;

end Pkg_Display_Task;
