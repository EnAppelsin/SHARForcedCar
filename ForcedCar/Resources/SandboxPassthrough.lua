if IsWriting() then
	return
end

local Path = GetPath()

--[[local SavedGame = Path:match("^Save(%d)$")
if ModSandbox and SavedGame then
	local ModSavePath = "/UserData/Debug/Saved Games/" .. ModSandbox.MainMod .. "/Save" .. SavedGame
	if not Exists(ModSavePath, true, false) then
		Redirect(nil)
		return
	end

	Output(ReadFile("/UserData/Debug/Saved Games/" .. ModSandbox.MainMod .. "/Save" .. SavedGame))
end]]

local Handlers = {
	["scripts\\missions\\level0?\\level.mfk"] = "Resources/HandleLevelLoad.lua",
	["scripts\\missions\\level0?\\leveli.mfk"] = "Resources/HandleLevelInit.lua",
	["scripts\\missions\\level0?\\m?sdi.mfk"] = "Resources/HandleSundayDriveInit.lua",
	["scripts\\missions\\level0?\\m?l.mfk"] = "Resources/HandleMissionLoad.lua",
	["scripts\\missions\\level0?\\m?i.mfk"] = "Resources/HandleMissionInit.lua",
	["scripts\\missions\\level0?\\bm?l.mfk"] = "Resources/HandleMissionLoad.lua",
	["scripts\\missions\\level0?\\bm?i.mfk"] = "Resources/HandleMissionInit.lua",
	["scripts\\missions\\level0?\\sr?l.mfk"] = "Resources/HandleMissionLoad.lua",
	["scripts\\missions\\level0?\\sr?i.mfk"] = "Resources/HandleMissionInit.lua",
	["scripts\\missions\\level0?\\gr?l.mfk"] = "Resources/HandleMissionLoad.lua",
	["scripts\\missions\\level0?\\gr?i.mfk"] = "Resources/HandleMissionInit.lua",

	-- TT fixes
	["scripts\\cars\\tt.con"] = "Resources/HandleCarConfig.lua",
	["art\\cars\\tt.p3d"] = "Resources/HandleTTModel.lua",
	["sound\\scripts\\car_tune.spt"] = "Resources/HandleCarTune.lua",
}

for k,v in pairs(Handlers) do
	if WildcardMatch(Path, k, true, true) then
		dofile(GetModPath() .. "/" .. v)
		return
	end
end

if ModSandbox then
	local GamePath = GetGamePath(Path)
	
	local Contents = ReadFile(GamePath)
	
	if Contents then
		Output(Contents)
	end
end