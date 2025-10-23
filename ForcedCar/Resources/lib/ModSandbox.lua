local _print = print
local isTesting = IsTesting()
local function print(...)
	if isTesting then
		_print("Mod Sandbox", ...)
	end
end
local _ReadFile = ReadFile

local MainMod = GetMainMod()
if MainMod == nil then
	print("No main mod detected. Mod sandbox disabled.")
	return
end
local MainModPath = GetModPath(MainMod)

local function CloneTable(obj, seen)
	if type(obj) ~= 'table' then
		return obj
	end
	
	if seen and seen[obj] then
		return seen[obj]
	end
	
	local s = seen or {}
	local res = {}
	s[obj] = res
	
	for k, v in pairs(obj) do
		res[CloneTable(k, s)] = CloneTable(v, s)
	end
	
	return setmetatable(res, getmetatable(obj)) --Should definitely clone the metatable
end

local env = CloneTable(_G)
env._G = env

env.EnvIsModSandbox = true

env.os.exit = function()
	return -- Prevent sandbox from exiting game.
end
env.print = function(...)
	_print(...)
end
--[[env.Alert = function()
	return -- Prevent dupe alerts.
end]]

env.GetModName = function()
	return MainMod
end

env.GetModPath = function(mod)
	return GetModPath(mod or MainMod)
end

env.GetModTitle = function(mod)
	return GetModTitle(mod or MainMod)
end

env.GetModVersion = function(mod)
	return GetModVersion(mod or MainMod)
end

env.GetSetting = function(setting, mod)
	return GetSetting(setting, mod or MainMod)
end

env.GetSettings = function(mod)
	return GetSettings(mod or MainMod)
end

env.dofile = function(path)
	return load(env.ReadFile(path), path, "t", env)()
end

env.load = function(code, name, t)
	return load(code, name, t, env)
end

env.loadfile = function(path)
	return load(env.ReadFile(path), path, "t", env)
end

local CurrentPath
env.GetPath = function()
	return CurrentPath
end

--[[env.ReadFile = function(path)
	if path ~= nil then
		local savedGame = path:match("^/UserData/SavedGames/Save(%d)$")
		if savedGame then
			return _ReadFile("/UserData/Debug/Saved Games/" .. MainMod .. "/Save" .. savedGame)
		end
	end
	return _ReadFile(path)
end]]

local OutputTbl = {}
env.Output = function(str)
	OutputTbl[#OutputTbl + 1] = str
end

local RedirectPath
local NilRedirect = false
env.Redirect = function(str)
	if str == nil then
		NilRedirect = true
		return
	end
	RedirectPath = str
end

if Exists(MainModPath .. "/CustomFiles.lua", true, false) then
	env.dofile(MainModPath .. "/CustomFiles.lua")
end

local PathHandlers = {}
local PathHandlersN = 0
local PathRedirections = {}
local PathRedirectionsN = 0
if Exists(MainModPath .. "/CustomFiles.ini", true, false) then
	local assert = assert
	local type = type
	
	local Exists = Exists
	local ReadFile = ReadFile
	
	local string_gmatch = string.gmatch
	local string_gsub = string.gsub
	local string_match = string.match
	local string_sub = string.sub
	local string_unpack = string.unpack
	local table_concat = table.concat
	local table_unpack = table.unpack
	local utf8_char = utf8.char

	local fmtMap = {
		["\xFF\xFE"] = "<H", -- UTF-16LE
		["\xFE\xFF"] = ">H", -- UTF-16BE
	}
	
	local function ReadTextFile(path)
		local content = ReadFile(path)
		if not content then
			return nil
		end
		
		local contentN = #content
		if contentN == 0 then
			return ""
		end
		
		if contentN >= 3 and content:sub(1, 3) == "\xEF\xBB\xBF" then -- UTF-8 BOM
			return content:sub(4)
		end
		
		if contentN >= 2 then -- UTF-16
			local fmt = fmtMap[content:sub(1, 2)]
			
			if fmt then
				local out = {}
				local outN = 0
				
				local chunk = {}
				local chunkN = 0
				
				local i = 3
				local codepoint
				while i <= contentN do
					codepoint, i = string_unpack(fmt, content, i)
					
					-- Handle surrogate pairs
					if codepoint >= 0xD800 and codepoint <= 0xDBFF and i + 1 <= contentN then
						local low, ni2 = string_unpack(fmt, content, i)
						if low >= 0xDC00 and low <= 0xDFFF then
							codepoint = 0x10000 + ((codepoint - 0xD800) * 0x400) + (low - 0xDC00)
							i = ni2
						end
					end
					
					chunkN = chunkN + 1
					chunk[chunkN] = codepoint
					
					if chunkN >= 1024 then
						outN = outN + 1
						out[outN] = utf8_char(table_unpack(chunk))
						
						for j=1,chunkN do
							chunk[j] = nil
						end
						chunkN = 0
					end
				end
				
				if chunkN > 0 then
					outN = outN + 1
					out[outN] = utf8_char(table_unpack(chunk))
				end
				
				if outN == 1 then
					return out[1]
				end
				
				return table_concat(out)
			end
		end
		
		return content -- Assume normal UTF-8
	end
	
	local function UnescapeString(s)
		s = string_gsub(s, "\\\\", "{BACKSLASH}")
		s = string_gsub(s, "\\n", "\n")
		s = string_gsub(s, "\\t", "\t")
		s = string_gsub(s, "\\r", "\r")
		s = string_gsub(s, '\\"', '"')
		s = string_gsub(s, "\\'", "'")
		s = string_gsub(s, "{BACKSLASH}", "\\")
		return s
	end
	
	local CommentChars = {
		["#"] = true,
		[";"] = true,
	}
	
	local function IniParser(Path)
		local Contents = ReadTextFile(Path)
		Contents = string_gsub(Contents, "\r\n", "\n")
		
		local Out = {}
		
		local CurrentHeader
		for line in string_gmatch(Contents, "[^\n]+") do
			if not CommentChars[string_sub(line, 1, 1)] then
				local HeaderName = string_match(line, "^%[([^%]]+)%]$")
				if HeaderName then
					CurrentHeader = {}
					
					local Headers = Out[HeaderName]
					if Headers == nil then
						Headers = {}
						Out[HeaderName] = Headers
					end
					Headers[#Headers + 1] = CurrentHeader
				elseif CurrentHeader then
					local Key, Value = string_match(line, '^(.-)%s*=%s*"(.-)"$')
					if not key then
						Key, Value = string_match(line, '^(.-)%s*=%s*(.-)%s*$')
					end
					if Key and Value then
						Key = UnescapeString(Key)
						local ValueStr = string_match(Value, '^"([^"]+)"$') or string_match(Value, "^'([^']+)'$")
						if ValueStr then
							CurrentHeader[#CurrentHeader + 1] = {Key, UnescapeString(ValueStr)}
						else
							Value = Value:match("^(.-)%s*[;#].*$") or Value
							if Value == "true" then
								CurrentHeader[#CurrentHeader + 1] = {Key, true}
							elseif Value == "false" then
								CurrentHeader[#CurrentHeader + 1] = {Key, false}
							else
								CurrentHeader[#CurrentHeader + 1] = {Key, tonumber(Value) or UnescapeString(Value)}
							end
						end
					end
				end
			end
		end
		
		return Out
	end
	
	local CustomFilesIni = IniParser(MainModPath .. "/CustomFiles.ini")
	
	if CustomFilesIni.PathHandlers then
		for i=1,#CustomFilesIni.PathHandlers do
			for j=1,#CustomFilesIni.PathHandlers[i] do
				PathHandlersN = PathHandlersN + 1
				PathHandlers[PathHandlersN] = {"/GameData/" .. FixSlashes(CustomFilesIni.PathHandlers[i][j][1], false, true), MainModPath .. "/" .. FixSlashes(CustomFilesIni.PathHandlers[i][j][2], false, true)}
			end
		end
	end
	
	if CustomFilesIni.PathRedirections then
		for i=1,#CustomFilesIni.PathRedirections do
			for j=1,#CustomFilesIni.PathRedirections[i] do
				PathRedirectionsN = PathRedirectionsN + 1
				local ext = GetFileExtension(CustomFilesIni.PathRedirections[i][j][2]):lower()
				PathRedirections[PathRedirectionsN] = {"/GameData/" .. FixSlashes(CustomFilesIni.PathRedirections[i][j][1], false, true), (ext == ".lua" and MainModPath or "/GameData") .. "/" .. FixSlashes(CustomFilesIni.PathRedirections[i][j][2], false, true)}
			end
		end
	end
end

local function FindWildcardInTable(haystack, needle)
	for i=#haystack,1,-1 do
		local entry = haystack[i]
		if WildcardMatch(needle, entry[1], true, true) then
			return entry[2]
		end
	end
end

function ReadFile(path)
	print("Simulating \"" .. path .. "\" in \"" .. MainMod .. "\".")
	CurrentPath = FixSlashes(path:sub(1, 10) == "/GameData/" and path:sub(11) or path, true, false)
	OutputTbl = {}
	RedirectPath = nil
	NilRedirect = false
	
	path = FixSlashes(path, false, true)
	
	local pathHandler = FindWildcardInTable(PathHandlers, path)
	if pathHandler then
		print("Running: " .. pathHandler)
		env.dofile(pathHandler)
		if #OutputTbl == 0 then
			if NilRedirect then
				return nil
			end
			
			if RedirectPath ~= nil then
				print("Redirecting: " .. RedirectPath)
				return _ReadFile(RedirectPath)
			end
			
			return _ReadFile(path)
		end
		return table.concat(OutputTbl)
	end
	
	local pathRedirect = FindWildcardInTable(PathRedirections, path)
	if pathRedirect and GetFileExtension(pathRedirect):lower() ~= ".lua" then
		print("Redirecting: " .. pathRedirect)
		path = pathRedirect
	end
	
	if Exists(path, true, false) then
		return _ReadFile(path)
	else
		return nil
	end
end

ModSandbox = {}
ModSandbox.MainMod = MainMod