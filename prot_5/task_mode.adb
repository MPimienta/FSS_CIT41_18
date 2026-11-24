with Tools; use Tools;
with Interrupt_Handler; use Interrupt_Handler;
with Pkg_PO_Mode; use Pkg_PO_Mode;

package body task_Mode is

    task body Task_Mode is
    begin
        loop
            -- Se duerme aqui hasta que el piloto pulse el boton
            Handler_PO.Wait_Press;

            Start_Activity ("Task_Mode launched");

            -- Alterna entre automatico y manual
            PO_Mode.Change_Mode_Protected;

            Finish_Activity ("Task_Mode Ended");
        end loop;
    end Task_Mode;

end task_mode;
