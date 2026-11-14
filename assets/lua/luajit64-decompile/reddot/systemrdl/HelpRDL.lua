-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/HelpRDL.lua

local GuideData = require("luaData/GuideShow")

HelpRDL = {}

local RD_Help_Branch_Path = {
	Help = "Setting/Help/%d/%d"
}
local KEY_RD_HELP_UNREAD = "KEY_RD_HELP_UNREAD"
local UnreadHelpIds = {}

function HelpRDL.Init()
	local t = PersistentStoreUtil.GetList(KEY_RD_HELP_UNREAD)

	for _, v in ipairs(t) do
		local guideId = tonumber(v)
		local data = GuideData[guideId]

		if data ~= nil and data.HelpOrder ~= 0 and not table.contains(UnreadHelpIds, guideId) then
			table.insert(UnreadHelpIds, guideId)
			RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Help_Branch_Path.Help, 1, data.HelpOrder, guideId)
		end
	end
end

function HelpRDL.FixAndClearLocalCache()
	PersistentStoreUtil.DelList(KEY_RD_HELP_UNREAD)
end

function HelpRDL.AddUnreadHelpId(newbieId)
	for _, v in pairsByKeys(GuideData) do
		if v.NewBieId == newbieId and v.HelpOrder ~= 0 and not table.contains(UnreadHelpIds, v.ID) then
			table.insert(UnreadHelpIds, v.ID)
			PersistentStoreUtil.AddList(KEY_RD_HELP_UNREAD, v.ID)
			RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Help_Branch_Path.Help, 1, v.HelpOrder, v.ID)
		end
	end
end

function HelpRDL.SubUnreadHelpId(guideId)
	if not table.contains(UnreadHelpIds, guideId) then
		return
	end

	local data = GuideData[guideId]

	if data == nil then
		return
	end

	table.removeByValue(UnreadHelpIds, guideId)
	PersistentStoreUtil.SetList(KEY_RD_HELP_UNREAD, UnreadHelpIds)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Help_Branch_Path.Help, -1, data.HelpOrder, guideId)
end

return HelpRDL
