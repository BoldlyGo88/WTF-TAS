local frames,data = {},{};
local systems = {["NES"] = 4, ["SNES"] = 5, ["GB"] = -1, ["GBA"] = -1, ["GBC"] = -1, ["VB"] = 1};
local system = emu.getsystemid();

-- minimal tas information
local record_date = os.date("%Y-%m-%d");
local used_frames = 0;
local total_inputs = 0;
local rom = gameinfo.getromname();

print("System: "..system.." "..systems[system]);
print("ROM: "..rom);

function LogButton(button, frame)
   if button then
      for __,_ in pairs(button) do
         if _ then
            print("Logging: "..tostring(frame));
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
   
   if system and systems[system] then
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
   end;
      
	for __,_ in pairs(frames) do
      data[1] = "System: "..system.." ROM: "..rom.." Record Date: "..record_date.." Active Frames: "..tostring(used_frames).." Inputs: "..tostring(total_inputs).."\n\n";
      data[#data + 1] = tostring(__).." "..table.concat(_,",").."\n";
		frames[__] = nil;
	end;
   
   local file = io.open(rom..".wtf","w");
   for __,_ in ipairs(data) do
      file:write(_);
   end;
	file:close();
  
   emu.frameadvance();
end;
