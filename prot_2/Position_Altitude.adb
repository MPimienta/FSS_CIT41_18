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
    	Siguiente_Instante := Clock + Intervalo;
    	loop
    	Start_Activity ("Task Position_Altitude launched");  
            
            -- Lee Joystick del piloto
            Read_Joystick (Current_J);
            
            -- Comprueba altitud
            Current_A := Read_Altitude;         -- lee y muestra por display la altitud de la aeronave  
            Display_Altitude (Current_A);

            -- establece Pitch y Roll en la aeronave
            Target_Pitch := Pitch_Samples_Type (Current_J(x));
            Target_Roll := Roll_Samples_Type (Current_J(y));

            -- Comprueba altitud
            if (Current_A < 2500 or Current_A > 9500) then
               Light_1 (On);
            else
               Light_1 (Off);
            end if;


            -- Detecta el rango de [-3, +3] como 0
            if (Target_Pitch <= 3 and Target_Pitch >= -3) then
               Target_Pitch := 0;
            end if;

            -- Limita el cabeceo a +30 o -30 grados y
            -- Nivela la nave si la altitud es igual o superior a 10000m, ignorando input de ascenso en tal caso
            -- Nivela la nave si la altitud es igual o inferior a 2000m, ignorando input de descenso en tal caso
            if (Target_Pitch > 0 and Current_A >= 10000) then
               Target_Pitch := 0;
            elsif (Target_Pitch > 30) then
               Target_Pitch := 30;
            elsif (Target_Pitch < 0 and Current_A <= 2000) then
               Target_Pitch := 0;
            elsif (Target_Pitch < -30) then
               Target_Pitch := -30;
            end if;
               
            Set_Aircraft_Pitch (Target_Pitch);
             
                       
            Aircraft_Pitch := Read_Pitch;       -- lee la posición pitch de la aeronave
            Aircraft_Roll := Read_Roll;         -- lee la posición roll  de la aeronave
            
            Display_Joystick (Current_J);       -- muestra por display el joystick  
            Display_Pitch (Aircraft_Pitch);     -- muestra por display la posición de la aeronave  
            Display_Roll (Aircraft_Roll);

            end if; 
            Finish_Activity ("Task Altitud");   
            delay until Siguiente_Instante;
            Siguiente_Instante := Siguiente_Instante + Intervalo;
        end loop;

    end Position_Altitude;

