-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ThemeRDL.lua

ThemeRDL = {}

local RD_Theme_Branch_Path = {
	Seat = "Arrow/Theme/Seat/%d",
	Award = "Arrow/Theme/Award/%d"
}
local KEY_RD_THEME_NEW = "KEY_RD_THEME_NEW"
local NEW_THEME = {}
local CAN_RECEIVE_THEME_AWARD = {}

function ThemeRDL.Init()
	NEW_THEME = PersistentStoreUtil.GetList(KEY_RD_THEME_NEW)

	for _, id in pairs(NEW_THEME) do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Theme_Branch_Path.Seat, 1, tonumber(id))
	end

	local t = ThemeManager:GetAll()

	for _, theme in pairs(t) do
		if theme.pb.surplus ~= nil and theme.pb.surplus >= theme.data.Minutes[2] * 60 then
			table.insert(CAN_RECEIVE_THEME_AWARD, theme.id)
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Theme_Branch_Path.Award, 1, theme.id)
		end
	end
end

function ThemeRDL.AddNewPlayerPrefs(_id)
	if table.contains(NEW_THEME, tostring(_id)) then
		return
	end

	PersistentStoreUtil.AddList(KEY_RD_THEME_NEW, _id)
	table.insert(NEW_THEME, tostring(_id))
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Theme_Branch_Path.Seat, 1, _id)
end

function ThemeRDL.RemoveNewPlayerPrefs(_id)
	if not table.contains(NEW_THEME, tostring(_id)) then
		return
	end

	table.removeByValue(NEW_THEME, tostring(_id))
	PersistentStoreUtil.SetList(KEY_RD_THEME_NEW, NEW_THEME)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Theme_Branch_Path.Seat, 0, _id)
end

function ThemeRDL.AddThemeAward(_id)
	if table.contains(CAN_RECEIVE_THEME_AWARD, _id) then
		return
	end

	table.insert(CAN_RECEIVE_THEME_AWARD, _id)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Theme_Branch_Path.Award, 1, _id)
end

function ThemeRDL.RemoveThemeAward(_id)
	if not table.contains(CAN_RECEIVE_THEME_AWARD, _id) then
		return
	end

	table.removeByValue(CAN_RECEIVE_THEME_AWARD, _id)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Theme_Branch_Path.Award, 0, _id)
end

return ThemeRDL
