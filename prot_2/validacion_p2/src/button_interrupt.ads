with System;
package Button_Interrupt is
   task Interrupt is
      pragma Priority (System.Interrupt_Priority'First + 9);
      pragma Storage_Size (32768);
   end Interrupt;
end Button_Interrupt;
