local frames = {};

while true do
	for i = 1,5,1 do
		if movie.mode() == 'PLAY' then
			local frame = emu.framecount();
			local button = movie.getinput(frame, i);
			for __,_ in pairs(button) do
				if _ then
					print("Logging: "..tostring(frame));
					if not frames[frame] then
						frames[frame] = {};
					end;
					table.insert(frames[frame], __);
				end;
			end;
		end;
	end;
	
	local file = io.open("output.wtf","a+");
	for __,_ in pairs(frames) do
		file:write(tostring(__).." "..table.concat(_,","), "\n");
		frames[__] = nil;
	end;
	file:close();
	
	emu.frameadvance();
end;
