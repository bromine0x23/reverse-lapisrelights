-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ManualRDL/ManualRDL.lua

local CollectionData = require("luaData/Figure")
local IllustrationData = require("luaData/Illustration")
local SongSubtitleData = require("luaData/SongSubtitleData")
local VideoData = require("luaData/VideoData")

ManualRDL = {}
ManualRDL.VideoRDL = require("RedDot/SystemRDL/ManualRDL/ManualVideoRDL")
ManualRDL.StoryRDL = require("RedDot/SystemRDL/ManualRDL/ManualStoryRDL")
ManualRDL.NotesRDL = require("RedDot/SystemRDL/ManualRDL/ManualNotesRDL")

function ManualRDL.Init()
	ManualRDL.VideoRDL.Init()
	ManualRDL.NotesRDL.Init()
	ManualRDL.StoryRDL.Init()
end

return ManualRDL
