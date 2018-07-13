-- Load the file
local Path = "/GameData/" .. GetPath();
local File = ReadFile(Path);

-- Remove comments because there's A LOT of commented out stuff that can confuse the simple regexes below
local NewFile = File:gsub("//.-\r\n", "\r\n")

if Path:match("b?m%di.mfk") or Path:match("[gs]r%di.mfk") then
	NewFile = NewFile:gsub("InitLevelPlayerVehicle%s*%(%s*\".-\"%s*,%s*\"(.-)\"%s*,%s*\"OTHER\"%s*%)", "InitLevelPlayerVehicle(\"" .. CarName .. "\",\"%1\",\"OTHER\")", 1)
	if GetSetting("SkipFMVs") then
		NewFile = NewFile:gsub("AddObjective%s*%(%s*\"fmv\"%s*%);.-CloseObjective%s*%(%s*%);", "AddObjective(\"timer\");\nSetDurationTime(1);\nCloseObjective();", 1)
	end
	Output(NewFile)
elseif Path:match("b?m%dl.mfk") or Path:match("[gs]r%dl.mfk") then
	NewFile = NewFile:gsub("LoadDisposableCar%s*%(%s*\".-\"%s*,%s*\".-\"%s*,%s*\"OTHER\"%s*%);", "LoadDisposableCar(\"art\\cars\\" .. CarName .. ".p3d\",\"" .. CarName .. "\",\"OTHER\");", 1)
	Output(NewFile)
elseif Path:match("level.mfk") then
	NewFile = NewFile:gsub("LoadDisposableCar%s*%(%s*\".-\"%s*,%s*\".-\"%s*,%s*\"DEFAULT\"%s*%);", "LoadDisposableCar(\"art\\cars\\" .. CarName .. ".p3d\",\"" .. CarName .. "\",\"DEFAULT\");", 1)
	Output(NewFile)
elseif Path:match("leveli.mfk") then
	NewFile = NewFile:gsub("InitLevelPlayerVehicle%s*%(%s*\".-\"%s*,%s*\"(.-)\"%s*,%s*\"DEFAULT\"%s*%)", "InitLevelPlayerVehicle(\"" .. CarName .. "\",\"%1\",\"DEFAULT\")", 1)
	Output(NewFile)
elseif Path:match("m%dsdi.mfk") then
	if GetSetting("SkipLocks") and NewFile:match("locked") then
		NewFile = NewFile:gsub("AddStage%s*%(%s*\"locked\".-%);(.-)CloseStage%s*%(%s*%);%s*AddStage%s*%(%s*.-%s*%);.-CloseStage%s*%(%s*%);", "AddStage();%1CloseStage();", 1);
	end
	if GetSetting("SkipFMVs") then
		NewFile = NewFile:gsub("AddObjective%s*%(%s*\"fmv\"%s*%);.-CloseObjective%s*%(%s*%);", "AddObjective(\"timer\");\nSetDurationTime(1);\nCloseObjective();", 1)
	end
	Output(NewFile)
end
