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

    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------

    -- Aqui se escriben los cuerpos de las tareas 
    


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



