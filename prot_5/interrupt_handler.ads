with Ada.Interrupts;
with Ada.Interrupts.Names;
with Button_Interrupt;

package Interrupt_Handler is

   protected Handler_PO is
      pragma Interrupt_Priority (Button_Interrupt.Priority_Of_External_Interrupts_2);

      entry Wait_Press;                  -- la llama Task_Mode

   private
      procedure Handler;                 -- la ejecuta la interrupción
      pragma Attach_Handler (Handler, Ada.Interrupts.Names.External_Interrupt_2);

      Pressed : Boolean := False;
   end Handler_PO;

end Interrupt_Handler;
