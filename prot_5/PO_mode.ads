package PO_Mode is

    type Plane_Mode is (Automatic, Manual);

    protected PO_Mode is
        pragma Priority (18);

        procedure Change_Mode_Protected;
        function  Read_Mode_Protected return Plane_Mode;
    private
        Current_Mode : Plane_Mode := Automatic;
    end PO_Mode;

end PO_Mode;
