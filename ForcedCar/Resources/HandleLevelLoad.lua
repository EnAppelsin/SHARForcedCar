local Path = GetPath()
local Level = tonumber(Path:match("level0(%d)"))

local LevelLoad = MFKLexer.Lexer:Parse(ReadFile("/GameData/scripts/missions/level0" .. Level .. "/level.mfk"))
LevelInit = MFKLexer.Lexer:Parse(ReadFile("/GameData/scripts/missions/level0" .. Level .. "/leveli.mfk"))

local needsAdd = true
for Function in LevelLoad:GetFunctions("LoadDisposableCar", true) do
	if Function.Arguments[3] == "DEFAULT" then
		Function.Arguments[1] = CarPath
		Function.Arguments[2] = CarName
		needsAdd = false
		break
	end
end
if needsAdd then
	LevelLoad:AddFunction("LoadDisposableCar", {CarPath, CarName, "DEFAULT"})
end

local needsAdd = true
for Function in LevelInit:GetFunctions("InitLevelPlayerVehicle", true) do
	if Function.Arguments[3] == "DEFAULT" then
		Function.Arguments[1] = CarName
		needsAdd = false
		break
	end
end
if needsAdd then
	LevelInit:AddFunction("LoadDisposableCar", {CarPath, CarName, "DEFAULT"})
end

LevelLoad:Output(true)