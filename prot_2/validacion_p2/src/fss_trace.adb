with System;
with Ada.Real_Time; use Ada.Real_Time;
with Kernel.Serial_Output;
with Tools;
with FSS_Config;

package body FSS_Trace is
   -- Protected operations copy bounded records only; they never wait for UART.
   Max_Length : constant := 256;
   Trace_Capacity : constant := 4096;
   Live_Capacity : constant := 128;
   type Output_Record is record
      Stamp : Time;
      Length : Natural range 0 .. Max_Length;
      Structured : Boolean;
      Live : Boolean;
      Text : String (1 .. Max_Length);
   end record;
   type Trace_Array is array (Positive range 1 .. Trace_Capacity) of Output_Record;
   type Live_Array is array (Positive range 1 .. Live_Capacity) of Output_Record;
   type Status_Record is record
      Known : Boolean := False;
      Length : Natural range 0 .. Max_Length := 0;
      Text : String (1 .. Max_Length) := (others => ' ');
   end record;
   type Status_Array is array (Indicator) of Status_Record;

   function Window_Length return Time_Span is
   begin
      if FSS_Config.Scenario_Id = 2 then return Milliseconds (70000);
      else return Milliseconds (20000);
      end if;
   end Window_Length;
   Capture_End : constant Time := Tools.Big_Bang + Window_Length;

   protected Output is
      pragma Interrupt_Priority (System.Interrupt_Priority'Last);
      procedure Add (Message : String; Structured, Live : Boolean; Stamp : Time);
      procedure Take (Item : out Output_Record; Available : out Boolean);
      procedure Change_Status (Channel : Indicator; Message : String);
      procedure Status (Trace_Lost, Live_Lost, Clipped, Pending : out Natural);
   private
      Trace_Data : Trace_Array;
      Live_Data : Live_Array;
      Trace_Read, Trace_Write : Positive := 1;
      Live_Read, Live_Write : Positive := 1;
      Trace_Count, Live_Count : Natural := 0;
      Lost_Trace, Lost_Live, Truncated : Natural := 0;
      Indicators : Status_Array;
   end Output;

   protected body Output is
      procedure Add (Message : String; Structured, Live : Boolean; Stamp : Time) is
         Item : Output_Record;
         Count : Natural := Message'Length;
      begin
         if Count > Max_Length then
            Count := Max_Length;
            Truncated := Truncated + 1;
         end if;
         Item.Stamp := Stamp;
         Item.Length := Count;
         Item.Structured := Structured;
         Item.Live := Live;
         Item.Text := (others => ' ');
         for I in 1 .. Count loop
            Item.Text (I) := Message (Message'First + I - 1);
         end loop;
         if Live then
            if Live_Count = Live_Capacity then
               Lost_Live := Lost_Live + 1;
            else
               Live_Data (Live_Write) := Item;
               Live_Write := Live_Write mod Live_Capacity + 1;
               Live_Count := Live_Count + 1;
            end if;
         else
            if Trace_Count = Trace_Capacity then
               Lost_Trace := Lost_Trace + 1;
            else
               Trace_Data (Trace_Write) := Item;
               Trace_Write := Trace_Write mod Trace_Capacity + 1;
               Trace_Count := Trace_Count + 1;
            end if;
         end if;
      end Add;

      procedure Change_Status (Channel : Indicator; Message : String) is
      begin
         if Message'Length <= Max_Length then
            if Indicators (Channel).Known and then
              Indicators (Channel).Length = Message'Length and then
              Indicators (Channel).Text (1 .. Message'Length) = Message
            then
               return;
            end if;
            if Live_Count = Live_Capacity then
               -- Count the loss, but retain the old cached state so that a
               -- later call retries this update after the queue recovers.
               Add (Message, False, True, Clock);
               return;
            end if;
            Indicators (Channel).Known := True;
            Indicators (Channel).Length := Message'Length;
            Indicators (Channel).Text (1 .. Message'Length) := Message;
         end if;
         Add (Message, False, True, Clock);
      end Change_Status;

      procedure Take (Item : out Output_Record; Available : out Boolean) is
      begin
         -- Device/display updates are served before background test traces.
         Available := True;
         if Live_Count > 0 then
            Item := Live_Data (Live_Read);
            Live_Read := Live_Read mod Live_Capacity + 1;
            Live_Count := Live_Count - 1;
         elsif Trace_Count > 0 then
            Item := Trace_Data (Trace_Read);
            Trace_Read := Trace_Read mod Trace_Capacity + 1;
            Trace_Count := Trace_Count - 1;
         else
            Available := False;
            Item.Stamp := Tools.Big_Bang;
            Item.Length := 0;
            Item.Structured := False;
            Item.Live := False;
            Item.Text := (others => ' ');
         end if;
      end Take;

      procedure Status (Trace_Lost, Live_Lost, Clipped, Pending : out Natural) is
      begin
         Trace_Lost := Lost_Trace; Live_Lost := Lost_Live;
         Clipped := Truncated; Pending := Trace_Count;
      end Status;
   end Output;

   procedure Emit (Message : String) is
      Stamp : constant Time := Clock;
   begin
      if FSS_Config.Trace_Enabled and Stamp < Capture_End then
         Output.Add (Message, True, False, Stamp);
      end if;
   end Emit;

   procedure Activity (Message : String) is
      Stamp : constant Time := Clock;
   begin
      if FSS_Config.Trace_Enabled and Stamp < Capture_End then
         Output.Add (Message, False, False, Stamp);
      end if;
   end Activity;

   procedure Device (Message : String) is
   begin
      Output.Add (Message, False, True, Clock);
   end Device;

   procedure Status (Channel : Indicator; Message : String) is
   begin
      Output.Change_Status (Channel, Message);
   end Status;

   procedure Fault (Message : String) is
   begin
      -- Fault reporting remains active after the finite detailed trace window.
      Output.Add ("TASK_FAULT|" & Message, True, True, Clock);
   end Fault;

   task Transmitter is
      pragma Priority (1);
      pragma Storage_Size (32768);
   end Transmitter;

   task body Transmitter is
      Item : Output_Record;
      Available : Boolean;
      Trace_Lost, Live_Lost, Clipped, Pending : Natural;
      Summary_Written : Boolean := False;
      Last_Live_Lost, Last_Clipped : Natural := 0;
      Max_Live_Age : Time_Span := Time_Span_Zero;
      Age : Time_Span;
   begin
      loop
         Output.Take (Item, Available);
         if Available then
            -- Only this task writes UART: records cannot interleave even when
            -- transmission is preempted. Timestamp is event occurrence time.
            if Item.Structured then
               Kernel.Serial_Output.Put ("FSS|");
               Kernel.Serial_Output.Put
                 (Duration'Image (To_Duration (Item.Stamp - Tools.Big_Bang)));
               Kernel.Serial_Output.Put ("|");
            else
               Kernel.Serial_Output.Put ("[");
               Kernel.Serial_Output.Put
                 (Duration'Image (To_Duration (Item.Stamp - Tools.Big_Bang)));
               Kernel.Serial_Output.Put ("] ");
            end if;
            Kernel.Serial_Output.Put_Line (Item.Text (1 .. Item.Length));
            if Item.Live then
               Age := Clock - Item.Stamp;
               if Age > Max_Live_Age then Max_Live_Age := Age; end if;
            end if;
         else
            delay until Clock + Milliseconds (1);
         end if;
         Output.Status (Trace_Lost, Live_Lost, Clipped, Pending);
         if FSS_Config.Trace_Enabled and not Summary_Written and
           Clock >= Capture_End and Pending = 0
         then
            Kernel.Serial_Output.Put_Line
              ("FSS|" & Duration'Image (To_Duration (Clock - Tools.Big_Bang)) &
               "|TRACE_SUMMARY|window=" &
               Duration'Image (To_Duration (Window_Length)) &
               "|lost=" & Natural'Image (Trace_Lost) &
               "|live_lost=" & Natural'Image (Live_Lost) &
               "|clipped=" & Natural'Image (Clipped) &
               "|max_live_output_age=" &
               Duration'Image (To_Duration (Max_Live_Age)));
            Summary_Written := True;
            Last_Live_Lost := Live_Lost;
            Last_Clipped := Clipped;
         elsif Summary_Written and
           (Live_Lost /= Last_Live_Lost or Clipped /= Last_Clipped)
         then
            Kernel.Serial_Output.Put_Line
              ("FSS|" & Duration'Image (To_Duration (Clock - Tools.Big_Bang)) &
               "|OUTPUT_LOSS|live_lost=" & Natural'Image (Live_Lost) &
               "|clipped=" & Natural'Image (Clipped));
            Last_Live_Lost := Live_Lost;
            Last_Clipped := Clipped;
         end if;
      end loop;
   end Transmitter;
end FSS_Trace;
