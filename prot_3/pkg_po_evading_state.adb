package body Pkg_PO_Evading_State is
    protected body PO_Evading_State is
        procedure Update_Evading_State (New_State : Boolean) is
        begin
            Is_Evading := New_State;
        end;

        function Read_Evading_State return Boolean is
        begin
            return Is_Evading;
        end;
    end PO_Evading_State;
end Pkg_PO_Evading_State;
