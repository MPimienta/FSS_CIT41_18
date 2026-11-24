package body PO_Mode is

    protected body PO_Mode is

        procedure Change_Mode_Protected is
        begin
            if Current_Mode = Automatic then
                Current_Mode := Manual;
            else
                Current_Mode := Automatic;
            end if;
        end Change_Mode_Protected;

        function Read_Mode_Protected return Plane_Mode is
        begin
            return Current_Mode;
        end Read_Mode_Protected;

    end PO_Mode;

end PO_Mode;
