local Path = GetPath()
local GamePath = GetGamePath(Path)

local SPT = SPTParser.SPTFile(GamePath)

local changed = false

local bookbVCarSoundParameters = SPT:GetClass("carSoundParameters", false, "bookb_v")
if bookbVCarSoundParameters then
	local overlayClipMethod = bookbVCarSoundParameters:GetMethod(false, "SetOverlayClipName")
	if overlayClipMethod and overlayClipMethod.Parameters[1] == "" then
		overlayClipMethod.Parameters[1] = "book_fire"
		changed = true
	end
end

local monorailCarSoundParameters  = SPT:GetClass("carSoundParameters", false, "mono_v")
if monorailCarSoundParameters  then
	local overlayClipMethod = monorailCarSoundParameters :GetMethod(false, "SetOverlayClipName")
	if overlayClipMethod and overlayClipMethod.Parameters[1] == "generator" then
		overlayClipMethod.Parameters[1] = "mono_overlay"
		changed = true
	end
end

local ttCarSoundParameters = SPT:GetClass("carSoundParameters", false, "tt")
if ttCarSoundParameters then
	local engineClipMethod = ttCarSoundParameters:GetMethod(false, "SetEngineClipName")
	if engineClipMethod and engineClipMethod.Parameters[1] == "tt" then
		changed = true
		engineClipMethod.Parameters[1] = "apu_car"
	end
	
	local engineIdleClipMethod = ttCarSoundParameters:GetMethod(false, "SetEngineIdleClipName")
	if engineIdleClipMethod and engineIdleClipMethod.Parameters[1] == "tt" then
		changed = true
		engineIdleClipMethod.Parameters[1] = "apu_car"
	end
end

if changed then
	Output(tostring(SPT))
end