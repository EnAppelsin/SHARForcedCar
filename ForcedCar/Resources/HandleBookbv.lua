local Path = GetPath()
local GamePath = GetGamePath(Path)

local SPT = SPTParser.SPTFile(GamePath)

local class = SPTParser.Class("daSoundResourceData", "book_fire")
class:AddMethod("AddFilename", { "sound\\carsound\\book_fire.rsd", 1.0 })
class:AddMethod("SetLooping", { true })
class:AddMethod("SetTrim", { 1.0 })
class:AddMethod("SetStreaming", { true })

SPT.Classes[#SPT.Classes + 1] = class

Output(tostring(SPT))