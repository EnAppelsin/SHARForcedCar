local Path = GetPath()

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
	["sound\\scripts\\bookb_v.spt"] = "Resources/HandleBookbv.lua",
	["sound\\scripts\\car_tune.spt"] = "Resources/HandleCarTune.lua",
}

for k,v in pairs(Handlers) do
	if WildcardMatch(Path, k, true, true) then
		dofile(GetModPath() .. "/" .. v)
		return
	end
end

if ModSandbox then
	ModSandbox.SimulatePathHandler()
end