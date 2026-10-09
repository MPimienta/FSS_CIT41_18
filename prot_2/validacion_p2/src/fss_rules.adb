package body FSS_Rules is
   function Limit (V, Low, High : Integer) return Integer is
   begin
      if V < Low then return Low;
      elsif V > High then return High;
      else return V;
      end if;
   end Limit;

   function Axis (V, Bound : Integer) return Integer is
   begin
      if abs V <= 3 then return 0;
      else return Limit (V, -Bound, Bound);
      end if;
   end Axis;

   function Position (JX, JY, Altitude : Integer) return Position_Result is
      R : Position_Result;
   begin
      R.Pitch := Axis (JX, 30);
      R.Roll := Axis (JY, 45);
      R.Altitude_Warning := Altitude < 2500 or Altitude > 9500;
      R.Roll_Warning := abs R.Roll > 35;
      if (Altitude <= 2000 and R.Pitch < 0) or
         (Altitude >= 10000 and R.Pitch > 0)
      then R.Pitch := 0;
      end if;
      return R;
   end Position;

   function Speed (Power, Pitch, Roll : Integer) return Speed_Result is
      -- Positive integer arithmetic implements nearest km/h consistently.
      Base : Integer := (Limit (Power, 0, 1023) * 12 + 5) / 10;
      Extra : Integer := 0;
      R : Speed_Result;
   begin
      if Pitch > 0 and Roll /= 0 then Extra := 200;
      elsif Pitch > 0 then Extra := 150;
      elsif Roll /= 0 then Extra := 100;
      end if;
      R.Warning := Base + Extra <= 300 or Base + Extra >= 1000;
      R.Value := Limit (Base + Extra, 300, 1000);
      return R;
   end Speed;

   function Collision (Distance, Velocity, Light : Integer;
                       Pilot_Present : Boolean) return Collision_Result is
      R : Collision_Result := (TTC => 9999.0, Obstacle => False,
                               Warning => False, Evade => False);
   begin
      if Distance > 5000 then return R; end if;
      R.Obstacle := True;
      if Distance <= 0 then R.TTC := 0.0;
      elsif Velocity > 0 then
         R.TTC := Float (Distance) * 3.6 / Float (Velocity);
      else return R;
      end if;
      if Light < 500 or not Pilot_Present then
         R.Warning := R.TTC <= 15.0;
         R.Evade := R.TTC <= 10.0;
      else
         R.Warning := R.TTC < 10.0;
         R.Evade := R.TTC < 5.0;
      end if;
      return R;
   end Collision;
end FSS_Rules;
