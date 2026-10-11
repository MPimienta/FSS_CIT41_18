package FSS_Trace is
   -- Detailed records capture occurrence time, not UART transmission time.
   -- Window: 70 s for P2-2, 20 s for other prescribed scenarios.
   -- Application tasks and live device/display output continue afterwards.
   procedure Emit (Message : String);
   procedure Activity (Message : String);
   procedure Device (Message : String);
   type Indicator is (Altitude_Light, Speed_Light, Collision_Alarm);
   -- Indicators only need a console update when their state changes.
   -- Their original device workload still executes on every call.
   procedure Status (Channel : Indicator; Message : String);
   procedure Fault (Message : String);
end FSS_Trace;
