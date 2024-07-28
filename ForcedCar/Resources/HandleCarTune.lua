local Path = GetPath()
local GamePath = GetGamePath(Path)

local SPT = SPTParser.SPTFile(GamePath)

local changed = false

for carSoundParameters in SPT:GetClasses("carSoundParameters") do
	for method, index in carSoundParameters:GetMethods(true) do
		local name = method.Name
		if name == "SetEngineClipName" or name == "SetEngineIdleClipName" then
			if method.Parameters[1] == "tt" then
				method.Parameters[1] = "apu_car"
				changed = true
			end
		end
	end
end

if changed then
	Output(tostring(SPT))
end