package FSS_Rules is
   type Position_Result is record
      Pitch, Roll : Integer;
      Altitude_Warning, Roll_Warning : Boolean;
   end record;
   type Speed_Result is record
      Value : Integer;
      Warning : Boolean;
   end record;
   type Collision_Result is record
      TTC : Float;
      Obstacle, Warning, Evade : Boolean;
   end record;
   function Position (JX, JY, Altitude : Integer) return Position_Result;
   function Speed (Power, Pitch, Roll : Integer) return Speed_Result;
   function Collision (Distance, Velocity, Light : Integer;
                       Pilot_Present : Boolean) return Collision_Result;
end FSS_Rules;
