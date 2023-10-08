local frames,data = {},{};
local systems = {["NES"] = 4, ["SNES"] = 5, ["GB"] = -1, ["GBA"] = -1, ["GBC"] = -1, ["VB"] = 1};
local system = emu.getsystemid();
local started = false;
local magic_frame;

-- minimal tas information
local record_date = os.date("%Y-%m-%d");
local used_frames = 0;
local total_inputs = 0;
local rom = gameinfo.getromname();

print("System: "..system.." "..systems[system]);
print("ROM: "..rom);
print("To start recording the data press the 'R' key");
print("To finish recording press 'R' again.");

function LogButton(button, frame)
   if button then
      for __,_ in pairs(button) do
         if _ then
            gui.text(0, 68, 'Logging Frame: ' ..tostring(frame));
            if not frames[frame] then
               frames[frame] = {};
               used_frames = used_frames + 1;
            end;
            total_inputs = total_inputs + 1;              
            table.insert(frames[frame], __);
         end;
      end;  
   end;
end;

while true do
   local frame = emu.framecount();
   local key = input.get()["R"];
   
   if key and not started then
      if not magic_frame or frame - magic_frame >= 10 then
         print("Starting...");
         started = true;
         magic_frame = frame;
      end;
   elseif key and started then
      if frame - magic_frame >= 10 then
         print("Ending...");
         started = false;
         magic_frame = frame;
      end;
   end;
         
   if system and systems[system] and started then
      if systems[system] == -1 then
         if movie.mode() == "PLAY" then
            LogButton(movie.getinput(frame), frame);
         end;
      else
         for i = 1,systems[system] do
            if movie.mode() == "PLAY" then
               LogButton(movie.getinput(frame, i), frame);
            end;
         end;
      end;
      
      gui.text(0, 36, 'Active Frames: ' ..tostring(used_frames));
      gui.text(0, 52, 'Total Inputs: ' ..tostring(total_inputs));
   end;
      
	for __,_ in pairs(frames) do
      data[1] = "System: "..system.." ROM: "..rom.." Record Date: "..record_date.." Active Frames: "..tostring(used_frames).." Inputs: "..tostring(total_inputs).."\n\n";
      data[#data + 1] = tostring(__).." "..table.concat(_,",").."\n";
		frames[__] = nil;
	end;
   
   if #data > 0 and not started then
      local file = io.open(rom..".wtf","a+");
      for __,_ in ipairs(data) do
         file:write(_);
         data[__] = nil;
      end;
      file:close();
   end;
  
   emu.frameadvance();
end;
