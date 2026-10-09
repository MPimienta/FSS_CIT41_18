with Ada.Real_Time; use Ada.Real_Time;
with Tools; use Tools;
with FSS_Config; use FSS_Config;
with Mode_Interrupt;
pragma Elaborate_All (Mode_Interrupt);
with Force_External_Interrupt_2;
with FSS_Trace;
package body Button_Interrupt is
   task body Interrupt is
      Next : Time;
   begin
      -- Scenario F3: accepted presses at 4, 6, 9 and 12 s.
      -- Bounce at 4.1 s is rejected by the 330 ms interrupt filter.
      if Enable_Mode and Scenario_Id = 6 then
         Next := Big_Bang + Milliseconds (4000); delay until Next;
         FSS_Trace.Emit ("BUTTON"); Force_External_Interrupt_2;
         Next := Big_Bang + Milliseconds (4100); delay until Next;
         FSS_Trace.Emit ("BUTTON_BOUNCE"); Force_External_Interrupt_2;
         Next := Big_Bang + Milliseconds (6000); delay until Next;
         FSS_Trace.Emit ("BUTTON"); Force_External_Interrupt_2;
         Next := Big_Bang + Milliseconds (9000); delay until Next;
         FSS_Trace.Emit ("BUTTON"); Force_External_Interrupt_2;
         Next := Big_Bang + Milliseconds (12000); delay until Next;
         FSS_Trace.Emit ("BUTTON"); Force_External_Interrupt_2;
      end if;
      -- Ravenscar tasks do not terminate.
      loop delay until Clock + Milliseconds (3600000); end loop;
   end Interrupt;
end Button_Interrupt;
