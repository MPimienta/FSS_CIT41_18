-- Pruebas ejecutables de las mismas funciones utilizadas por las tareas.
with Kernel.Serial_Output; use Kernel.Serial_Output;
with FSS_Rules; use FSS_Rules;
procedure Test_Rules is
   Checks, Failures : Natural := 0;
   P : Position_Result;
   V : Speed_Result;
   C : Collision_Result;
   procedure Check (Condition : Boolean; Label_Text : String) is
   begin
      Checks := Checks + 1;
      if not Condition then
         Failures := Failures + 1;
         Put_Line ("FAIL " & Label_Text);
      end if;
   end Check;
begin
   for X in -90 .. 90 loop
      for Y in -90 .. 90 loop
         P := Position (X, Y, 8000);
         Check (P.Pitch in -30 .. 30 and P.Roll in -45 .. 45, "bounds");
         if abs X <= 3 then Check (P.Pitch = 0, "pitch deadband"); end if;
         if abs Y <= 3 then Check (P.Roll = 0, "roll deadband"); end if;
         if Y > 3 then Check (P.Roll > 0, "right sign"); end if;
         if Y < -3 then Check (P.Roll < 0, "left sign"); end if;
      end loop;
   end loop;
   P := Position (-90, 0, 2000); Check (P.Pitch = 0, "low protection");
   P := Position (90, 0, 2000); Check (P.Pitch = 30, "low recovery");
   P := Position (90, 0, 10000); Check (P.Pitch = 0, "high protection");
   P := Position (-90, 0, 10000); Check (P.Pitch = -30, "high recovery");
   P := Position (0, 35, 2500); Check (not P.Altitude_Warning and not P.Roll_Warning, "warning equality");
   P := Position (0, -36, 2499); Check (P.Altitude_Warning and P.Roll_Warning, "warning below");
   P := Position (0, 0, 9500); Check (not P.Altitude_Warning, "9500 equality");
   P := Position (0, 0, 9501); Check (P.Altitude_Warning, "9501 warning");
   for Power in 0 .. 1023 loop
      for Pitch in -1 .. 1 loop
         for Roll in -1 .. 1 loop
            V := Speed (Power, Pitch * 30, Roll * 45);
            Check (V.Value in 300 .. 1000, "speed bounds");
         end loop;
      end loop;
   end loop;
   V := Speed (500, 0, 0); Check (V.Value = 600, "base");
   V := Speed (500, 10, 0); Check (V.Value = 750, "climb");
   V := Speed (500, 0, -20); Check (V.Value = 700, "turn");
   V := Speed (500, 10, 20); Check (V.Value = 800, "combined");
   V := Speed (500, -10, 0); Check (V.Value = 600, "descent");
   V := Speed (0, 0, 0); Check (V.Value = 300 and V.Warning, "minimum");
   V := Speed (1023, 30, 45); Check (V.Value = 1000 and V.Warning, "maximum");
   C := Collision (5001, 1000, 0, False); Check (not C.Obstacle and not C.Warning and not C.Evade, "no obstacle");
   C := Collision (1000, 360, 500, True); Check (not C.Warning, "normal ten exact");
   C := Collision (999, 360, 500, True); Check (C.Warning, "normal ten below");
   C := Collision (500, 360, 500, True); Check (not C.Evade, "normal five exact");
   C := Collision (499, 360, 500, True); Check (C.Evade, "normal five below");
   C := Collision (1500, 360, 499, True); Check (C.Warning, "enhanced fifteen");
   C := Collision (1000, 360, 499, True); Check (C.Evade, "enhanced ten");
   C := Collision (1000, 360, 1000, False); Check (C.Evade, "pilot absent");
   C := Collision (1000, 0, 1000, True); Check (not C.Evade, "zero speed");
   C := Collision (0, 0, 1000, True); Check (C.Evade, "zero distance");
   Put_Line ("RULE_TESTS|checks=" & Natural'Image (Checks) &
             "|failures=" & Natural'Image (Failures));
end Test_Rules;
