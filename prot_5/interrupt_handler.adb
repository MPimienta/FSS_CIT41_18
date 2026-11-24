package body Interrupt_Handler is

   protected body Handler_PO is

      entry Wait_Press when Pressed is
      begin
         Pressed := False;               -- consume la pulsación
      end Wait_Press;

      procedure Handler is
      begin
         Pressed := True;                -- abre la barrera
      end Handler;

   end Handler_PO;

end Interrupt_Handler;
