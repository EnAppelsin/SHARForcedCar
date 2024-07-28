local Path = GetPath()
local GamePath = GetGamePath(Path)

local MissionLoad = MFKLexer.Lexer:Parse(ReadFile(GamePath))
MissionInit = MFKLexer.Lexer:Parse(ReadFile(GamePath:sub(1, -6) .. "i.mfk"))

local isForced = false
for Function in MissionLoad:GetFunctions("LoadDisposableCar", true) do
	if Function.Arguments[3] == "OTHER" then
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
	
	if Settings.RemoveOutOfVehicle then
		local toRemove = {}
		local toRemoveN = 0
		local addCondition
		local remove = false
		for Function, Index in MissionInit:GetFunctions() do
			local name = Function.Name:lower()
			
			if name == "addcondition" then
				if Function.Arguments[1] == "damage" then
					addCondition = Index
				end
			end
			
			if addCondition then
				if name == "setcondtargetvehicle" then
					if Function.Arguments[1] == CarName then -- TODO: Check if "current" is valid
						remove = true
					end
				end
				
				if name == "closecondition" then
					if remove then
						for j=addCondition,Index do
							toRemoveN = toRemoveN + 1
							toRemove[toRemoveN] = j
						end
					end
					remove = false
					addCondition = nil
				end
			end
		end
		
		for i=toRemoveN,1,-1 do
			MissionInit:RemoveFunction(toRemove[i])
		end
	end
end

MissionLoad:Output(true)