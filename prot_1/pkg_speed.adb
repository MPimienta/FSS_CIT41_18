with Ada.Real_Time; use Ada.Real_Time;
with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;
with Pkg_Flight_Data; use Pkg_Flight_Data;

package body Pkg_Speed is
   task body Speed is
      Current_Power : Power_Samples_Type;
      Current_Pitch : Pitch_Samples_Type;
      Current_Roll  : Roll_Samples_Type;
      
      P             : Integer;
      Base_Speed    : Integer;
      Extra_Speed   : Integer;
      Target_Speed  : Integer;
      Final_Speed   : Speed_Samples_Type;
      
      Siguiente_Instante : Time;
      Intervalo : Time_Span := Milliseconds (300);
   begin
      Siguiente_Instante := Clock + Intervalo;
      loop
         Start_Activity ("Task Speed launched");
         
         Read_Power (Current_Power);
         Current_Pitch := Flight_Data.Read_Pitch_Protected;
         Current_Roll  := Flight_Data.Read_Roll_Protected;
         
         P := Integer (Current_Power);
         if P < 0 then 
            P := 0; 
         elsif P > 1023 then 
            P := 1023; 
         end if;
         
         Base_Speed := (P * 12 + 5) / 10;
         
         Extra_Speed := 0;
         if Current_Pitch > 0 and Current_Roll /= 0 then 
            Extra_Speed := 200;
         elsif Current_Pitch > 0 then 
            Extra_Speed := 150;
         elsif Current_Roll /= 0 then 
            Extra_Speed := 100;
         end if;
         
         Target_Speed := Base_Speed + Extra_Speed;
         
         if Target_Speed <= 300 or Target_Speed >= 1000 then
            Light_2 (On);
         else
            Light_2 (Off);
         end if;
         
         if Target_Speed < 300 then 
            Target_Speed := 300;
         elsif Target_Speed > 1000 then 
            Target_Speed := 1000; 
         end if;
         
         Final_Speed := Speed_Samples_Type (Target_Speed);
         
         Set_Speed (Final_Speed);
         
         Finish_Activity ("Task Speed Ended");
         delay until Siguiente_Instante;
         Siguiente_Instante := Siguiente_Instante + Intervalo;
      end loop;
   end Speed;
end Pkg_Speed;
