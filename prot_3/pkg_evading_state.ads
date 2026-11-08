with devicesFSS_V1; use devicesFSS_V1;
with Tools; use Tools;

package Pkg_Evading_State is
    protected Evading_State is
        procedure Update_Evading_State (New_State : Boolean);
        function Read_Evading_State return Boolean;
    private
        Current_State : Boolean := False;
    end Evading_State;
end Pkg_Evading_State;
