with devicesFSS_V1; use devicesFSS_V1;
with Tools; use Tools;

package Pkg_PO_Evading_State is
    protected PO_Evading_State is
        procedure Update_Evading_State (New_State : Boolean);
        function Read_Evading_State return Boolean;
    private
        Is_Evading : Boolean := False;
    end PO_Evading_State;
end Pkg_PO_Evading_State;
