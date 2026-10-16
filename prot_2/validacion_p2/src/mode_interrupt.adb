with FSS_Config; use FSS_Config;
package body Mode_Interrupt is
   protected body Event is
      procedure Handler is
         Now : constant Time := Clock;
      begin
         if Enable_Mode and Now - Last_Accepted >= Mode_Separation then
            Last_Accepted := Now;
            Pending := True;
         end if;
      end Handler;
      entry Wait_For_Press when Pending is
      begin
         Pending := False;
      end Wait_For_Press;
   end Event;
end Mode_Interrupt;
