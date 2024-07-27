local LibDir = GetModPath() .. "/Resources/lib/"
dofile(LibDir .. "MFKLexer.lua")
dofile(LibDir .. "SPTParser.lua")
dofile(LibDir .. "P3D2.lua")
P3D.LoadChunks(LibDir .. "P3DChunks")
function GetGamePath(Path)
	Path = FixSlashes(Path,false,true)
	if Path:sub(1,1) ~= "/" then
		return "/GameData/" .. Path
	end
	return Path
end

if not IsHackLoaded("FileSystemRCFs") then
	print("Adding RCF support to ReadFile...")
	dofile(LibDir .. "RCF.lua")
	local RCFFiles = {}
	DirectoryGetEntries("/GameData/", function(Path, IsDir)
		if IsDir then
			return true
		end
		
		if GetFileExtension(Path):lower() ~= ".rcf" then
			return true
		end
		
		local GamePath = GetGamePath(Path)
		local RCFFile = RCF.RCFFile(GamePath)
		for i=1,#RCFFile.Files do
			local file = RCFFile.Files[i]
			
			RCFFiles[GetGamePath(file.Name)] = {GamePath, file.Position, file.Size}
		end
		
		return true
	end)
	local _ReadFile = ReadFile
	function ReadFile(Path)
		local RCFFile = RCFFiles[Path]
		if not Exists(Path, true, false) and RCFFile then
			return ReadFileOffset(RCFFile[1], RCFFile[2], RCFFile[3])
		end
		return _ReadFile(Path)
	end
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