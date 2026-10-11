with Ada.Real_Time; use Ada.Real_Time;
with Ada.Interrupts.Names;
with System;
with Tools;
with FSS_Config;
package Mode_Interrupt is
   protected Event is
      pragma Interrupt_Priority (System.Interrupt_Priority'First + 9);
      procedure Handler;
      pragma Attach_Handler (Handler, Ada.Interrupts.Names.External_Interrupt_2);
      entry Wait_For_Press;
   private
      Pending : Boolean := False;
      Last_Accepted : Time := Tools.Big_Bang - FSS_Config.Mode_Separation;
   end Event;
end Mode_Interrupt;
