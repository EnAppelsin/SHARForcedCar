-- Load the file
local Path = "/GameData/" .. GetPath();
local File = ReadFile(Path);

-- Determine if the file is for a mission (bonus, main or races)
local Midx = string.match(Path, "b?m%di.mfk") or string.match(Path, "[gs]r%di.mfk")
local Lidx = string.match(Path, "b?m%dl.mfk") or string.match(Path, "[gs]r%dl.mfk")
-- Determine if the file is for a level
local LevelLoad = string.match(Path, "level.mfk")
local LevelInit = string.match(Path, "leveli.mfk")
-- Determine if the file is for "sunday drive" (pre-mission)
local SDLoad = string.match(Path, "m%dsdl.mfk")
local SDInit = string.match(Path, "m%dsdi.mfk")

-- Remove comments because there's A LOT of commented out stuff that can confuse the simple regexes below
local NewFile = string.gsub(File, "//.-\n", "")	

if Midx ~= nil then
	-- Try to find a forced vehicle spawn
	local Match = string.match(NewFile, "InitLevelPlayerVehicle%(%s*\".-\"%s*,%s*\".-\"%s*,%s*\"OTHER\"%s*%)")
	if Match ~= nil then
		-- Replace it with the random vehicle
		NewFile = string.gsub(NewFile, "InitLevelPlayerVehicle%(%s*\".-\"%s*,%s*\"(.-)\"%s*,%s*\"OTHER\"%s*%)", "InitLevelPlayerVehicle(\"" .. CarName .. "\",\"%1\",\"OTHER\")", 1)
	end
	if GetSetting("SkipFMVs") then
		NewFile = string.gsub(NewFile, "AddObjective%(\"fmv\"%);.-CloseObjective%(%);", "AddObjective(\"timer\");\nSetDurationTime(1);\nCloseObjective();", 1)
	end
	Output(NewFile)
elseif Lidx ~= nil then
	-- Try to find a forced vehicle spawn
	local Match = string.match(NewFile, "LoadDisposableCar%(%s*\".-\"%s*,%s*\".-\"%s*,%s*\"OTHER\"%s*%)")
	if Match ~= nil then
		ForcedMission = true
		NewFile = string.gsub(NewFile, "(.*)LoadDisposableCar%(%s*\".-\"%s*,%s*\".-\"%s*,%s*\"OTHER\"%s*%);", "%1LoadDisposableCar(\"art\\cars\\" .. CarName .. ".p3d\",\"" .. CarName .. "\",\"OTHER\");", 1)
	end
	Output(NewFile)
elseif LevelLoad ~= nil then
	NewFile = string.gsub(NewFile, "(.*)LoadDisposableCar%(%s*\".-\"%s*,%s*\".-\"%s*,%s*\"DEFAULT\"%s*%);", "%1LoadDisposableCar(\"art\\cars\\" .. CarName .. ".p3d\",\"" .. CarName .. "\",\"DEFAULT\");", 1)
	Output(NewFile)
elseif LevelInit ~= nil then
	NewFile = string.gsub(NewFile, "InitLevelPlayerVehicle%(%s*\".-\"%s*,%s*\"(.-)\"%s*,%s*\"DEFAULT\"%s*%)", "InitLevelPlayerVehicle(\"" .. CarName .. "\",\"%1\",\"DEFAULT\")", 1)
	Output(NewFile)
elseif SDInit ~= nil then
	if GetSetting("SkipLocks") then
		if string.match(NewFile, "locked") then
			NewFile = string.gsub(NewFile, "AddStage%(\"locked\".-%);(.-)CloseStage%(%);%s*AddStage%(.-%);.-CloseStage%(%);", "AddStage();%1CloseStage();", 1);
		end
	end
	if GetSetting("SkipFMVs") then
		NewFile = string.gsub(NewFile, "AddObjective%(\"fmv\"%);.-CloseObjective%(%);", "AddObjective(\"timer\");\nSetDurationTime(1);\nCloseObjective();", 1)
	end
	Output(NewFile)
else
	LastLevel = nil
	-- Don't modify other scripts
	--print("Script " .. Path)
	Output(NewFile);
end
