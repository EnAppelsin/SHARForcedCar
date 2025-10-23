local Path = GetPath()
local GamePath = GetGamePath(Path)

local MissionLoad = MFKLexer.Lexer:Parse(ReadFile(GamePath))
MissionInit = MFKLexer.Lexer:Parse(ReadFile(GamePath:sub(1, -6) .. "i.mfk"))

local isForced = false
local oldForcedCar = nil
for Function in MissionLoad:GetFunctions("LoadDisposableCar", true) do
	if Function.Arguments[3] == "OTHER" then
		oldForcedCar = Function.Arguments[2]
		Function.Arguments[1] = CarPath
		Function.Arguments[2] = CarName
		isForced = true
		break
	end
end
if not isForced then
	MissionLoad:AddFunction("LoadDisposableCar", {CarPath, CarName, "OTHER"})
end

if isForced then
	MissionInit:SetAll("InitLevelPlayerVehicle", 1, CarName)
	MissionInit:SetAll("SetCondTargetVehicle", 1, CarName, oldForcedCar)
else
	local CarLocator
	local LastStageIndex
	local ResetToHereIndex
	
	for Function, Index in MissionInit:GetFunctions() do
		local name = Function.Name:lower()
		
		if name == "setmissionresetplayeroutcar" then
			CarLocator = Function.Arguments[2]
		elseif name == "setmissionresetplayerincar" then
			CarLocator = Function.Arguments[1]
		elseif name == "addstage" then
			LastStageIndex = Index
		elseif name == "reset_to_here" then
			ResetToHereIndex = LastStageIndex
		end
		
		if CarLocator and ResetToHereIndex then
			break
		end
	end
	if not CarLocator then
		-- TODO: Is this even possible?
		Alert("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
	end
	MissionInit:InsertFunction(2, "SetForcedCar")
	MissionInit:InsertFunction(2, "InitLevelPlayerVehicle", {CarName, CarLocator, "OTHER"})
	
	local stageVehicles = {}
	local stageVehiclesN = 0
	
	if ResetToHereIndex then
		local remove = false
		local functions = MissionInit.Functions
		for i=ResetToHereIndex+1,1,-1 do -- We want the function before AddStage. We've inserted 2. Add 1.
			local func = functions[i]
			local name = func.Name:lower()
			
			if name == "addstagevehicle" then
				stageVehiclesN = stageVehiclesN + 1
				stageVehicles[stageVehiclesN] = func.Arguments
			end
			
			if name == "closestage" then
				remove = true
			end
			
			if remove then
				table.remove(functions, i)
			end
			
			if name == "addstage" then
				remove = false
			end
		end
	end
	
	if stageVehiclesN > 0 then
		local Function, Index = MissionInit:GetFunction("AddStage")
		MissionInit:InsertFunction(Index, "AddStage")
		Index = Index + 1
		for i=1,stageVehiclesN do
			MissionInit:InsertFunction(Index, "AddStageVehicle", stageVehicles[i])
			Index = Index + 1
		end
		MissionInit:InsertFunction(Index, "AddObjective", "timer")
		Index = Index + 1
		MissionInit:InsertFunction(Index, "SetDurationTime", 0)
		Index = Index + 1
		MissionInit:InsertFunction(Index, "CloseObjective")
		Index = Index + 1
		MissionInit:InsertFunction(Index, "CloseStage")
		Index = Index + 1
	end
	
	local Function, Index = MissionInit:GetFunction("CloseStage", true)
	MissionInit:InsertFunction(Index, "SetSwapDefaultCarLocator", CarLocator)
	MissionInit:InsertFunction(Index, "SwapInDefaultCar")
	MissionInit:InsertFunction(Index, "SetFadeOut", 0.1)
end

if Settings.AddBustedCondition or Settings.AddDamageCondition then
	local inStage = false
	local hasBusted = false
	local hasDamage = false
	for Function, Index in MissionInit:GetFunctions(nil, true) do
		local name = Function.Name:lower()
		if name == "closestage" then
			inStage = true
			hasBusted = false
		elseif name == "addstage" then
			inStage = false
			if not hasBusted and Settings.AddBustedCondition then
				MissionInit:InsertFunction(Index + 1, "CloseCondition")
				MissionInit:InsertFunction(Index + 1, "AddCondition", "hitandruncaught")
			end
			if not hasDamage and Settings.AddDamageCondition then
				MissionInit:InsertFunction(Index + 1, "CloseCondition")
				MissionInit:InsertFunction(Index + 1, "SetCondTargetVehicle", CarName)
				MissionInit:InsertFunction(Index + 1, "SetCondMinHealth", 0.0)
				MissionInit:InsertFunction(Index + 1, "AddCondition", "damage")
			end
		elseif inStage and name == "addcondition" then
			if Function.Arguments[1] == "hitandruncaught" then
				hasBusted = true
			elseif Function.Arguments[1] == "damage" then
				hasDamage = true
			end
		end
	end
end

MissionLoad:Output(true)