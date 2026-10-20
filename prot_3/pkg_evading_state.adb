package body Pkg_Evading_State is
    protected body Evading_State is
        procedure Update_Evading_State (New_State : Boolean) is
        begin
            Current_State := New_State;
        end;

        function Read_Evading_State return Boolean is
        begin
            return Current_State;
        end;
    end Evading_State;
end Pkg_Evading_State;
