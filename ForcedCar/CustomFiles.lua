dofile(GetModPath() .. "/Resources/lib/MFKLexer.lua")
function GetGamePath(Path)
	Path = FixSlashes(Path,false,true)
	if Path:sub(1,1) ~= "/" then
		return "/GameData/" .. Path
	end
	return Path
end

-- CAR LIST
local CarPool = {
	"ambul",
	"apu_v",
	"atv_v",
	"bart_v",
	"bbman_v",
	"bookb_v",
	"burns_v",
	"burnsarm",
	"carhom_v",
	"cArmor",
	"cBlbart",
	"cBone",
	"cCellA",
	"cCellB",
	"cCellC",
	"cCellD",
	"cCola",
	"cCube",
	"cCurator",
	"cDonut",
	"cDuff",
	"cFire_v",
	"cHears",
	"cKlimo",
	"cletu_v",
	"cLimo",
	"cMilk",
	"cNerd",
	"cNonup",
	"coffin",
	"comic_v",
	"compactA",
	"cPolice",
	"cSedan",
	"cVan",
	"dune_v",
	"elect_v",
	"famil_v",
	"fishtruc",
	"fone_v",
	"frink_v",
	"garbage",
	"glastruc",
	"gramp_v",
	"gramR_v",
	"hallo",
	"hbike_v",
	"homer_v",
	"honor_v",
	"hype_v",
	"icecream",
	"IStruck",
	"knigh_v",
	"krust_v",
	"lisa_v",
	"marge_v",
	"minivanA",
	"moe_v",
	"mono_v",
	"mrplo_v",
	"nuctruck",
	"oblit_v",
	"otto_v",
	"pickupA",
	"pizza",
	"plowk_v",
	"redbrick",
	"rocke_v",
	"schoolbu",
	"scorp_v",
	"sedanA",
	"sedanB",
	"ship",
	"skinn_v",
	"smith_v",
	"snake_v",
	"sportsA",
	"sportsB",
	"SUVA",
	"taxiA",
	"tt",
	"votetruc",
	"wagonA",
	"wiggu_v",
	"willi_v",
	"witchcar",
	"zombi_v",
}

Settings = GetSettings()
CarName = CarPool[Settings.Vehicle]
CarPath = "art\\cars\\" .. CarName .. ".p3d"
ConPath = "scripts\\cars\\" .. CarName .. ".con"

if not Exists(GetGamePath(CarPath), true, false) then
	Alert("Could not find car at path: " .. CarPath)
	os.exit()
	return
end

if not Exists(GetGamePath(ConPath), true, false) then
	Alert("Could not find car config at path: " .. ConPath)
	os.exit()
	return
end

print("Forced Car chosen is: " .. CarName)

function RemoveLocks(MFK, type)
	local toRemove = {}
	local toRemoveN = 0
	
	local previousLocked = false
	local remove = false
	for Function, Index in MFK:GetFunctions() do
		local name = Function.Name:lower()
		
		if name == "addstage" then
			if previousLocked then
				remove = true
				previousLocked = false
			elseif Function.Arguments[1] == "locked" and Function.Arguments[2] == type then
				Function.Arguments = {}
				previousLocked = true
			end
		end
		
		if remove then
			toRemoveN = toRemoveN + 1
			toRemove[toRemoveN] = Index
			
			if name == "closestage" then
				remove = false
			end
		end
	end
	
	for i=toRemoveN,1,-1 do
		MFK:RemoveFunction(toRemove[i])
	end
	
	return toRemoveN > 0
end