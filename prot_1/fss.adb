-------------------------------------------------------------------------
--Nombres:
---- Mauricio Pimienta Fernández
---- José María Cadarso Nieto
---- Wu Kuangcheng
---- Zhang Weiyin
-------------------------------------------------------------------------
--Tareas Implementadas: Velocidad, Sensores, Altitud
-------------------------------------------------------------------------
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;

with Pkg_Position_Altitude;

-- NO ACTIVAR ESTE PAQUETE MIENTRAS NO SE TENGA PROGRAMADA LA INTERRUPCION
-- Packages needed to generate button interrupts       
-- with Ada.Interrupts.Names;
-- with Button_Interrupt; use Button_Interrupt;

package body fss is

    ----------------------------------------------------------------------
    ------------- procedure exported 
    ----------------------------------------------------------------------
    procedure Background is
    begin
      loop
        null;
      end loop;
    end Background;
    ----------------------------------------------------------------------

    -----------------------------------------------------------------------
    ------------- declaration of protected objects 
    -----------------------------------------------------------------------

    -- Aqui se declaran los objetos protegidos para los datos compartidos  


    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------

    -- Aqui se declaran las tareas que forman el STR
    Task Velocidad is 
    	pragma priority (5);
    end Velocidad;
    
    Task Sensores is
    	pragma priority (3);
    end Sensores;


    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------

    -- Aqui se escriben los cuerpos de las tareas 
    
    Task body Velocidad is
    	Current_Pw: Power_Samples_Type := 0;
        Current_S: Speed_Samples_Type := 500; 
        Calculated_S: Speed_Samples_type := 0; 
             
        Current_D: Distance_Samples_Type := 0;
        Current_L: Light_Samples_Type := 0;
        
        Siguiente_Instante : Time;
        Intervalo : Time_Span := Milliseconds (300);
    begin
    	Siguiente_Instante := Clock + Intervalo;
    	loop
    	Start_Activity ("Task Velocidad");  
    	
         
         	if (Current_D < 2000) then
         		Alarm(4);
         	elsif (Current_D < 4000) then
         		Alarm(2);
         	end if;
                   
            -- Prueba potencia del piloto 
            Read_Power (Current_Pw);  -- lee la potencia de motor indicada por el piloto
            Display_Pilot_Power (Current_Pw);
                      
            -- transfiere la potencia/velocidad a la aeronave
            Calculated_S := Speed_Samples_type (float (Current_Pw) * 1.2); -- aplicar fórmula
                 
            if (Calculated_S > 1000) then 
            	Calculated_S := 1000;
            	Light_1 (On);
            
            else 
            	Light_1 (Off);
            end if;
            
            Set_Speed (Calculated_S);
            
            -- Comprueba la velocidad real de la aeronave
            Current_S := Read_Speed;        -- lee la velocidad actual de la aeronave
            Display_Speed (Current_S);

            -- Prueba distancia con obstaculos
            Read_Distance (Current_D);
            Display_Distance (Current_D);
            
            if (Current_D < 1000) then
         		Set_Aircraft_Roll(+40);
         	else
         		Set_Aircraft_Roll(0);
         	end if;
         	
         	Display_Roll(Read_Roll);
                                 
         Finish_Activity ("Task Velocidad");   
         delay until Siguiente_Instante;
         Siguiente_Instante := Siguiente_Instante + Intervalo;
         end loop;
    end Velocidad;
    
    
    Task body Sensores is
    	Current_Pp: PilotPresence_Samples_Type := 1;
        Current_Pb: PilotButton_Samples_Type := 0;
        
        Siguiente_Instante : Time;
        Intervalo : Time_Span := Milliseconds (300);
    begin
    	Siguiente_Instante := Clock + Intervalo;
    	loop
    	    Start_Activity ("Task Sensores");  
    	    
    	    -- Prueba presencia piloto
            Current_Pp := Read_PilotPresence;
            if (Current_Pp = 0) then Alarm (1); end if;   
            Display_Pilot_Presence (Current_Pp);
                 
            -- Prueba botón para selección de modo 
            Current_Pb := Read_PilotButton;            
            Display_Pilot_Button (Current_Pb); 
    	
    	    Finish_Activity ("Task Sensores");   
            delay until Siguiente_Instante;
            Siguiente_Instante := Siguiente_Instante + Intervalo;
        end loop;
    
    end Sensores;
    


    ----------------------------------------------------------------------
    ------------- procedimientos para probar los dispositivos 
    ------------- SE DEBERÁN QUITAR PARA EL PROYECTO
    ----------------------------------------------------------------------

begin
   Start_Activity ("Programa Principal");
   --Prueba_Velocidad_Distancia;
   --Prueba_Altitud_Joystick;
   --Prueba_Sensores_Piloto;
   Finish_Activity ("Programa Principal");
end fss;



