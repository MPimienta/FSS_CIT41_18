-- FSS v2 - entrega final, curso 2025-2026
-- CADARSO NIETO JOSE M
-- PIMIENTA FERNANDEZ MAURICIO
-- WU KUANGCHENG
-- ZHANG WEIYIN
-- Grupo: CIT41-LAB-G18. Entrega realizada por ZHANG WEIYIN.
-- Tareas: Position_Altitude, Speed, Collision, Display, Mode,
-- Maneuver_Timer, FSS_Trace.Transmitter y Button_Interrupt.Interrupt.
-- Objetos protegidos: Flight_Control, Mode_Interrupt.Event,
-- FSS_Trace.Output y los dispositivos suministrados por el profesor.
-- Los requisitos y las decisiones de interpretacion se documentan en
-- 1-Especificacion y 8-Aclaraciones. No se usan datos globales sin proteger.

with Ada.Real_Time; use Ada.Real_Time;
with System;
with Tools; use Tools;
with DevicesFSS_V1; use DevicesFSS_V1;
with FSS_Config; use FSS_Config;
with FSS_Rules;
with FSS_Trace; use FSS_Trace;
with Mode_Interrupt;
with Button_Interrupt;
pragma Elaborate_All (Mode_Interrupt);
pragma Elaborate_All (Button_Interrupt);

package body FSS is
   type Generation is mod 65536;
   type Snapshot is record
      Automatic : Boolean := True;
      Evading : Boolean := False;
      Altitude : Altitude_Samples_Type := Initial_Altitude;
      Power : Power_Samples_Type := 0;
      Velocity : Speed_Samples_Type := 300;
      J : Joystick_Samples_Type := (0, 0);
      Pitch : Pitch_Samples_Type := 0;
      Roll : Roll_Samples_Type := 0;
      Distance : Distance_Samples_Type := 9000;
      Light : Light_Samples_Type := 1023;
      Present : PilotPresence_Samples_Type := 1;
      Altitude_Warning, Roll_Warning, Speed_Warning,
        Collision_Warning : Boolean := False;
   end record;

   protected Flight_Control is
      pragma Priority (Control_Ceiling);
      function Read_State return Snapshot;
      procedure Position_Data (J : Joystick_Samples_Type;
                               A : Altitude_Samples_Type;
                               Alt_Warn, Roll_Warn : Boolean);
      procedure Power_Data (P : Power_Samples_Type; Warn : Boolean);
      procedure Collision_Data (D : Distance_Samples_Type;
                                L : Light_Samples_Type;
                                P : PilotPresence_Samples_Type;
                                Warn : Boolean);
      procedure Apply_Pitch (P : Pitch_Samples_Type);
      procedure Apply_Roll (R : Roll_Samples_Type);
      procedure Apply_Speed (V : Speed_Samples_Type);
      procedure Start_Evasion (Release : Time);
      entry Wait_For_Evasion (Id : out Generation; Due : out Time);
      procedure End_Evasion (Id : Generation);
      procedure Toggle_Mode;
   private
      State : Snapshot;
      Token : Generation := 0;
      Timer_Pending : Boolean := False;
      End_Time : Time := Big_Bang;
   end Flight_Control;

   protected body Flight_Control is
      function Read_State return Snapshot is
      begin return State; end Read_State;

      procedure Position_Data (J : Joystick_Samples_Type;
                               A : Altitude_Samples_Type;
                               Alt_Warn, Roll_Warn : Boolean) is
      begin
         State.J := J; State.Altitude := A;
         State.Altitude_Warning := Alt_Warn;
         State.Roll_Warning := abs State.Roll > 35;
      end Position_Data;

      procedure Power_Data (P : Power_Samples_Type; Warn : Boolean) is
      begin State.Power := P; State.Speed_Warning := Warn; end Power_Data;

      procedure Collision_Data (D : Distance_Samples_Type;
                                L : Light_Samples_Type;
                                P : PilotPresence_Samples_Type;
                                Warn : Boolean) is
      begin
         State.Distance := D; State.Light := L; State.Present := P;
         State.Collision_Warning := Warn;
      end Collision_Data;

      procedure Apply_Pitch (P : Pitch_Samples_Type) is
      begin
         if State.Automatic then
            Set_Aircraft_Pitch (P); State.Pitch := P;
            Emit ("PITCH|value=" & Integer'Image (Integer (P)));
         end if;
      end Apply_Pitch;

      procedure Apply_Roll (R : Roll_Samples_Type) is
      begin
         if State.Automatic and not State.Evading then
            Set_Aircraft_Roll (R); State.Roll := R;
            State.Roll_Warning := abs R > 35;
            Emit ("ROLL|value=" & Integer'Image (Integer (R)));
         end if;
      end Apply_Roll;

      procedure Apply_Speed (V : Speed_Samples_Type) is
      begin
         if State.Automatic then
            Set_Speed (V); State.Velocity := V;
            Emit ("SPEED|value=" & Integer'Image (Integer (V)));
         end if;
      end Apply_Speed;

      procedure Start_Evasion (Release : Time) is
         Issued : Time;
      begin
         if State.Automatic and not State.Evading then
            Token := Token + 1;
            State.Evading := True;
            Issued := Clock;
            End_Time := Issued + Evasion_Duration;
            Set_Aircraft_Roll (45); State.Roll := 45;
            State.Roll_Warning := True;
            Timer_Pending := True;
            Emit ("EVADE_START|id=" & Generation'Image (Token) &
                  "|start=" & Duration'Image (To_Duration (Issued - Big_Bang)) &
                  "|due=" & Duration'Image (To_Duration (End_Time - Big_Bang)) &
                  "|response=" & Duration'Image (To_Duration (Clock - Release)));
         end if;
      end Start_Evasion;

      entry Wait_For_Evasion (Id : out Generation; Due : out Time)
        when Timer_Pending is
      begin
         Id := Token; Due := End_Time; Timer_Pending := False;
      end Wait_For_Evasion;

      procedure End_Evasion (Id : Generation) is
         Issued : Time;
      begin
         if Id = Token and State.Automatic and State.Evading then
            Issued := Clock;
            Set_Aircraft_Roll (0); State.Roll := 0;
            State.Roll_Warning := False;
            State.Evading := False;
            Emit ("EVADE_END|id=" & Generation'Image (Id) &
                  "|issued=" & Duration'Image (To_Duration (Issued - Big_Bang)) &
                  "|lateness=" & Duration'Image (To_Duration (Issued - End_Time)));
         else
            Emit ("TIMER_CANCELLED|id=" & Generation'Image (Id));
         end if;
      end End_Evasion;

      procedure Toggle_Mode is
      begin
         State.Automatic := not State.Automatic;
         if not State.Automatic then
            State.Evading := False;
            Token := Token + 1;
            -- Manual mode must not write even a levelling actuator command.
         end if;
         Emit ("MODE|automatic=" & Boolean'Image (State.Automatic));
      end Toggle_Mode;
   end Flight_Control;

   procedure Wait_Next (Next : in out Time; Period : Time_Span;
                        Name : String) is
   begin
      Next := Next + Period;
      if Clock > Next then
         Emit ("OVERRUN|task=" & Name);
         while Next <= Clock loop Next := Next + Period; end loop;
      end if;
      delay until Next;
   end Wait_Next;

   procedure Trace_Job (Name : String; Release : Time) is
   begin
      Emit ("JOB|task=" & Name & "|release=" &
            Duration'Image (To_Duration (Release - Big_Bang)));
      Start_Activity (Name);
   end Trace_Job;

   procedure Trace_End (Name : String; Release : Time) is
      Finished : constant Time := Clock;
   begin
      Emit ("DONE|task=" & Name & "|release=" &
            Duration'Image (To_Duration (Release - Big_Bang)) &
            "|response=" & Duration'Image (To_Duration (Finished - Release)));
      Finish_Activity (Name);
   end Trace_End;

   procedure Stop_Failed_Task (Name, Reason : String) is
   begin
      Fault ("task=" & Name & "|reason=" & Reason);
      -- Explicit failure evidence; a failed Ravenscar task must not terminate.
      loop delay until Clock + Milliseconds (60000); end loop;
   end Stop_Failed_Task;

   task Position_Altitude is
      pragma Priority (Position_Priority);
      pragma Storage_Size (32768);
   end Position_Altitude;
   task Speed is
      pragma Priority (Speed_Priority);
      pragma Storage_Size (32768);
   end Speed;
   task Collision is
      pragma Priority (Collision_Priority);
      pragma Storage_Size (32768);
   end Collision;
   task Display is
      pragma Priority (Display_Priority);
      pragma Storage_Size (32768);
   end Display;
   task Mode is
      pragma Priority (Mode_Priority);
      pragma Storage_Size (32768);
   end Mode;
   task Maneuver_Timer is
      pragma Priority (Timer_Priority);
      pragma Storage_Size (32768);
   end Maneuver_Timer;

   task body Position_Altitude is
      Next : Time := Big_Bang;
      J : Joystick_Samples_Type;
      A : Altitude_Samples_Type;
      R : FSS_Rules.Position_Result;
   begin
      loop
         Trace_Job ("POSITION", Next);
         Read_Joystick (J); A := Read_Altitude;
         R := FSS_Rules.Position (Integer (J (X)), Integer (J (Y)), Integer (A));
         Flight_Control.Position_Data (J, A, R.Altitude_Warning, R.Roll_Warning);
         Flight_Control.Apply_Pitch (Pitch_Samples_Type (R.Pitch));
         Flight_Control.Apply_Roll (Roll_Samples_Type (R.Roll));
         if R.Altitude_Warning then Light_1 (On); else Light_1 (Off); end if;
         Emit ("POSITION_DATA|jx=" & Integer'Image (Integer (J (X))) &
               "|jy=" & Integer'Image (Integer (J (Y))) &
               "|alt=" & Integer'Image (Integer (A)) &
               "|pitch=" & Integer'Image (R.Pitch) &
               "|roll=" & Integer'Image (R.Roll) &
               "|warning=" & Boolean'Image (R.Altitude_Warning));
         -- In prototype 2 there is no display task, but required roll warnings remain.
         if not Enable_Display and R.Roll_Warning then
            Display_Message ("AVISO ALABEO: mas de 35 grados");
         end if;
         Trace_End ("POSITION", Next);
         Wait_Next (Next, Position_Period, "POSITION");
      end loop;
   exception
      when Storage_Error => Stop_Failed_Task ("POSITION", "STORAGE_ERROR");
      when Constraint_Error => Stop_Failed_Task ("POSITION", "CONSTRAINT_ERROR");
      when Program_Error => Stop_Failed_Task ("POSITION", "PROGRAM_ERROR");
      when Tasking_Error => Stop_Failed_Task ("POSITION", "TASKING_ERROR");
      when others => Stop_Failed_Task ("POSITION", "OTHER_EXCEPTION");
   end Position_Altitude;

   task body Speed is
      Next : Time := Big_Bang;
      P : Power_Samples_Type;
      S : Snapshot;
      R : FSS_Rules.Speed_Result;
      Warning : Boolean;
   begin
      loop
         Trace_Job ("SPEED", Next);
         Read_Power (P); S := Flight_Control.Read_State;
         R := FSS_Rules.Speed (Integer (P), Integer (S.Pitch), Integer (S.Roll));
         Warning := R.Warning;
         if not S.Automatic then
            Warning := S.Velocity <= 300 or S.Velocity >= 1000;
         end if;
         Flight_Control.Power_Data (P, Warning);
         Flight_Control.Apply_Speed (Speed_Samples_Type (R.Value));
         if Warning then Light_2 (On); else Light_2 (Off); end if;
         Emit ("SPEED_DATA|power=" & Integer'Image (Integer (P)) &
               "|pitch=" & Integer'Image (Integer (S.Pitch)) &
               "|roll=" & Integer'Image (Integer (S.Roll)) &
               "|target=" & Integer'Image (R.Value) &
               "|warning=" & Boolean'Image (Warning));
         Trace_End ("SPEED", Next);
         Wait_Next (Next, Speed_Period, "SPEED");
      end loop;
   exception
      when Storage_Error => Stop_Failed_Task ("SPEED", "STORAGE_ERROR");
      when Constraint_Error => Stop_Failed_Task ("SPEED", "CONSTRAINT_ERROR");
      when Program_Error => Stop_Failed_Task ("SPEED", "PROGRAM_ERROR");
      when Tasking_Error => Stop_Failed_Task ("SPEED", "TASKING_ERROR");
      when others => Stop_Failed_Task ("SPEED", "OTHER_EXCEPTION");
   end Speed;

   task body Collision is
      Next : Time := Big_Bang;
      D : Distance_Samples_Type;
      L : Light_Samples_Type;
      P : PilotPresence_Samples_Type;
      S : Snapshot;
      R : FSS_Rules.Collision_Result;
   begin
      loop
         if Enable_Collision then
            Trace_Job ("COLLISION", Next);
            Read_Distance (D); Read_Light_Intensity (L); P := Read_PilotPresence;
            S := Flight_Control.Read_State;
            R := FSS_Rules.Collision (Integer (D), Integer (S.Velocity),
                                      Integer (L), P = 1);
            -- The actuator request precedes alarm and diagnostic output.
            if R.Evade then Flight_Control.Start_Evasion (Next); end if;
            Flight_Control.Collision_Data (D, L, P, R.Warning);
            if R.Warning then Alarm (4); else Alarm (0); end if;
            Emit ("COLLISION_DATA|distance=" & Integer'Image (Integer (D)) &
                  "|speed=" & Integer'Image (Integer (S.Velocity)) &
                  "|light=" & Integer'Image (Integer (L)) &
                  "|present=" & Integer'Image (Integer (P)) &
                  "|ttc=" & Float'Image (R.TTC) &
                  "|warning=" & Boolean'Image (R.Warning) &
                  "|evade=" & Boolean'Image (R.Evade));
            Trace_End ("COLLISION", Next);
         end if;
         Wait_Next (Next, Collision_Period, "COLLISION");
      end loop;
   exception
      when Storage_Error => Stop_Failed_Task ("COLLISION", "STORAGE_ERROR");
      when Constraint_Error => Stop_Failed_Task ("COLLISION", "CONSTRAINT_ERROR");
      when Program_Error => Stop_Failed_Task ("COLLISION", "PROGRAM_ERROR");
      when Tasking_Error => Stop_Failed_Task ("COLLISION", "TASKING_ERROR");
      when others => Stop_Failed_Task ("COLLISION", "OTHER_EXCEPTION");
   end Collision;

   task body Maneuver_Timer is
      Id : Generation;
      Due : Time;
   begin
      loop
         Flight_Control.Wait_For_Evasion (Id, Due);
         delay until Due;
         Start_Activity ("MANEUVER_TIMER");
         Flight_Control.End_Evasion (Id);
         Finish_Activity ("MANEUVER_TIMER");
      end loop;
   exception
      when Storage_Error => Stop_Failed_Task ("MANEUVER_TIMER", "STORAGE_ERROR");
      when Constraint_Error => Stop_Failed_Task ("MANEUVER_TIMER", "CONSTRAINT_ERROR");
      when Program_Error => Stop_Failed_Task ("MANEUVER_TIMER", "PROGRAM_ERROR");
      when Tasking_Error => Stop_Failed_Task ("MANEUVER_TIMER", "TASKING_ERROR");
      when others => Stop_Failed_Task ("MANEUVER_TIMER", "OTHER_EXCEPTION");
   end Maneuver_Timer;

   task body Mode is
   begin
      loop
         Mode_Interrupt.Event.Wait_For_Press;
         Start_Activity ("MODE");
         Flight_Control.Toggle_Mode;
         Finish_Activity ("MODE");
      end loop;
   exception
      when Storage_Error => Stop_Failed_Task ("MODE", "STORAGE_ERROR");
      when Constraint_Error => Stop_Failed_Task ("MODE", "CONSTRAINT_ERROR");
      when Program_Error => Stop_Failed_Task ("MODE", "PROGRAM_ERROR");
      when Tasking_Error => Stop_Failed_Task ("MODE", "TASKING_ERROR");
      when others => Stop_Failed_Task ("MODE", "OTHER_EXCEPTION");
   end Mode;

   task body Display is
      Next : Time := Big_Bang;
      S : Snapshot;
   begin
      loop
         if Enable_Display then
            Trace_Job ("DISPLAY", Next);
            S := Flight_Control.Read_State;
            Display_Altitude (S.Altitude);
            Display_Pilot_Power (S.Power);
            Display_Speed (S.Velocity);
            Display_Joystick (S.J);
            Display_Pitch (S.Pitch);
            Display_Roll (S.Roll);
            -- A single bounded message call covers every simultaneous warning.
            Display_Message
              ("AUTO=" & Boolean'Image (S.Automatic) &
               " ALT=" & Boolean'Image (S.Altitude_Warning) &
               " ROLL=" & Boolean'Image (S.Roll_Warning) &
               " SPEED=" & Boolean'Image (S.Speed_Warning) &
               " COLLISION=" & Boolean'Image (S.Collision_Warning) &
               " EVASION=" & Boolean'Image (S.Evading));
            Emit ("DISPLAY_DATA|automatic=" & Boolean'Image (S.Automatic) &
                  "|alt=" & Integer'Image (Integer (S.Altitude)) &
                  "|speed=" & Integer'Image (Integer (S.Velocity)));
            Trace_End ("DISPLAY", Next);
         end if;
         Wait_Next (Next, Display_Period, "DISPLAY");
      end loop;
   exception
      when Storage_Error => Stop_Failed_Task ("DISPLAY", "STORAGE_ERROR");
      when Constraint_Error => Stop_Failed_Task ("DISPLAY", "CONSTRAINT_ERROR");
      when Program_Error => Stop_Failed_Task ("DISPLAY", "PROGRAM_ERROR");
      when Tasking_Error => Stop_Failed_Task ("DISPLAY", "TASKING_ERROR");
      when others => Stop_Failed_Task ("DISPLAY", "OTHER_EXCEPTION");
   end Display;

   procedure Background is
   begin
      loop null; end loop;
   end Background;
begin
   Emit ("CONFIG|scenario=" & Positive'Image (Scenario_Id) &
         "|prototype=" & Positive'Image (Prototype));
end FSS;
