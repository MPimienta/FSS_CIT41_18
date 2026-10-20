with Ada.Real_Time; use Ada.Real_Time;
with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;
with pkg_flight_data; use pkg_flight_data;
with pkg_evading_state; use pkg_evading_state;

Package body Pkg_Position_Altitude is 
   Task body Position_Altitude is
      Current_J: Joystick_Samples_Type := (0,0);
      Target_Pitch: Pitch_Samples_Type := 0;
      Target_Roll: Roll_Samples_Type := 0; 
      Aircraft_Pitch: Pitch_Samples_Type; 
      Aircraft_Roll: Roll_Samples_Type;
        
      Current_A: Altitude_Samples_Type := 8000;
        
      Siguiente_Instante : Time;
      Intervalo : Time_Span := Milliseconds (200);
        
    begin
      Siguiente_Instante := Big_Bang + Intervalo;
    	loop
    	    Start_Activity ("Task Position_Altitude launched");

            -- mantener la lectura de los sensores y acciones que no tengan que ver con pitch y roll

            -- Lee Joystick del piloto
            Read_Joystick (Current_J);
            
            -- Lee altitud
            Current_A := Read_Altitude;

            -- Uncomment for testing
            --Display_Altitude (Current_A);
                
            -- Comprueba altitud
            if (Current_A < 2500 or Current_A > 9500) then
                Light_1 (On);
            else
                Light_1 (Off);
            end if;

            if not Evading_State.Read_Evading_State then

            

                -- establece Pitch y Roll en la aeronave
                Target_Pitch := Pitch_Samples_Type (Current_J(x));
                Target_Roll := Roll_Samples_Type (Current_J(y));

                -- Detectar el rango de [-3, +3] como 0
                if (Target_Pitch <= 3 and Target_Pitch >= -3) then
                    Target_Pitch := 0;
                end if;

                if (Target_Roll <= 3 and Target_Roll >= -3) then
                    Target_Roll := 0;
                end if;

                -- Limites de cabeceo y nivelacion por altitud
                if (Target_Pitch > 0 and Current_A >= 10000) then
                    Target_Pitch := 0;
                elsif (Target_Pitch > 30) then
                    Target_Pitch := 30;
                elsif (Target_Pitch < 0 and Current_A <= 2000) then
                    Target_Pitch := 0;
                elsif (Target_Pitch < -30) then
                    Target_Pitch := -30;
                end if;

                -- Uncomment displays for testing
                -- Limites de alabeo y aviso
                if Target_Roll > 35 then
                    --   Display_Message ("Angulo alabeo superior a 35");
                    if Target_Roll > 45 then
                        Target_Roll := 45;
                    end if;
                elsif Target_Roll < -35 then
                    --   Display_Message ("Angulo alabeo inferior a -35");
                    if Target_Roll < -45 then
                        Target_Roll := -45;
                    end if;
                end if;

                -- Actualizar posicion
                Flight_Data.Update_Roll_Protected(Target_Roll);   
                Flight_Data.Update_Pitch_Protected (Target_Pitch);
            
                Set_Aircraft_Pitch (Target_Pitch);
                Set_Aircraft_Roll (Target_Roll);
                       
            

            end if; -- no hacer nada si el avión está evadiendo pero mantener las acciones que no influyen en la evasión

            Aircraft_Pitch := Read_Pitch;       -- lee la posición pitch de la aeronave
            Aircraft_Roll := Read_Roll;         -- lee la posición roll  de la aeronave
                
            -- Uncomment for testing
            -- Display_Joystick (Current_J);       -- muestra por display el joystick  
            -- Display_Pitch (Aircraft_Pitch);     -- muestra por display la posición de la aeronave  

            -- Uncomment for testing
            -- Display_Roll (Aircraft_Roll);
            
            Finish_Activity ("Task Position_Altitude Ended");   
            delay until Siguiente_Instante;
            Siguiente_Instante := Siguiente_Instante + Intervalo;
        end loop;

    end Position_Altitude;
end Pkg_Position_Altitude;

