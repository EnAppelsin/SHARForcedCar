if not Settings.RemoveCarLocks and not Settings.RemoveCostumeLocks and not Settings.RemoveFMVs then
	return
end

local Path = GetPath()
local GamePath = GetGamePath(Path)
local MFK = MFKLexer.Lexer:Parse(ReadFile(GamePath))

local changed = false

if Settings.RemoveFMVs then
	changed = MFK:SetAll("addobjective", 1, "timer", "fmv") or changed
	if changed then
		for Function in MFK:GetFunctions("SetFMVInfo") do
			Function.Name = "SetDurationTime"
			Function.Arguments[1] = 0
		end
	end
end

if Settings.RemoveCarLocks then
	changed = RemoveLocks(MFK, "car") or changed
end

if Settings.RemoveCostumeLocks then
	changed = RemoveLocks(MFK, "skin") or changed
end

if changed then
	MFK:Output(true)
end