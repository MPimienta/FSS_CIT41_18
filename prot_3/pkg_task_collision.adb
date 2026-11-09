with Ada.Real_Time; use Ada.Real_Time;
with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;
with Pkg_PO_Position; use Pkg_PO_Position;
with Pkg_PO_Evading_State; use Pkg_PO_Evading_State;
with Pkg_PO_Speed_Altitude; use Pkg_PO_Speed_Altitude;

package body Pkg_Task_Collision is

    task body Task_Collision is
        Distancia_Obstaculo : Distance_Samples_Type;
        Velocidad_Aeronave  : Speed_Samples_Type;
        Visibilidad         : Light_Samples_Type;
        Piloto_Presente     : PilotPresence_Samples_type;
      
        Tiempo_Al_Obstaculo : Float;
        Ciclos_Evasion      : Integer := 0; -- Contador para medir los 3 segundos
      
        Siguiente_Instante  : Time;
        Intervalo           : Time_Span := Milliseconds (250);

        procedure Iniciar_Evasion (Contador_Ciclos : in out Integer) is
        begin
            PO_Position.Update_Roll_Protected (45);
            Set_Aircraft_Roll (45);
            PO_Evading_State.Update_Evading_State (True);
            Contador_Ciclos := 0;
        end Iniciar_Evasion;
    begin
        Siguiente_Instante := Big_Bang + Intervalo;
      
        loop
            Start_Activity ("Task Collision launched");
         
            -- 1. Si estamos en plena evasión contamos el tiempo (3 segundos = 12 ciclos de 250ms)
            if PO_Evading_State.Read_Evading_State then
                Ciclos_Evasion := Ciclos_Evasion + 1;
            
                if Ciclos_Evasion >= 12 then
                    -- Fin de la maniobra: estabilizamos a 0 y devolvemos el control
                    PO_Position.Update_Roll_Protected(0);
                    Set_Aircraft_Roll(0);
                    PO_Evading_State.Update_Evading_State(False);
                    Ciclos_Evasion := 0;
                end if;
            
            else
                -- 2. Si NO estamos evadiendo, vigilamos el entorno
                Read_Distance (Distancia_Obstaculo);
            
                if Distancia_Obstaculo <= 5000 then
            
                    Velocidad_Aeronave := PO_Speed.Read_Speed_Protected;
                    Read_Light_Intensity(Visibilidad);
                    Piloto_Presente    := Read_PilotPresence;
               
                    -- Evitar división por cero si la nave está parada
                    if Velocidad_Aeronave > 0 then
                  
                        -- Conversión: km/h a m/s -> V / 3.6
                        Tiempo_Al_Obstaculo := Float(Distancia_Obstaculo) / (Float(Velocidad_Aeronave) / 3.6);
                  
                        -- Lógica de umbrales según visibilidad y piloto
                        if Visibilidad < 500 or Piloto_Presente = 0 then
                            if Tiempo_Al_Obstaculo <= 15.0 then 
                                Alarm (4);
                            end if;
                            if Tiempo_Al_Obstaculo <= 10.0 then 
                                Iniciar_evasion(Ciclos_Evasion);
                            end if;
                        else 
                            if Tiempo_Al_Obstaculo <= 10.0 then 
                                Alarm (4);
                            end if;
                            if Tiempo_Al_Obstaculo <= 5.0 then 
                                Iniciar_Evasion(Ciclos_Evasion);
                            end if;
                        end if;
                    end if;
                end if;
            end if;
         
            Finish_Activity ("Task Collision Ended");
            delay until Siguiente_Instante;
            Siguiente_Instante := Siguiente_Instante + Intervalo;
        end loop;
    end Task_Collision;
end Pkg_Task_Collision;
