-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/TitleRDL.lua

TitleRDL = {}
PLAYER_TITLE_TYPE = {
	Frame = "Frame",
	Head = "Head",
	Medal = "Medal"
}

local RD_Title_Branch_Path = {
	Frame = "Player/Avatar/Frame",
	Head = "Player/Avatar/Head",
	Medal = "Player/Medal"
}
local KEY_RD_TITLE = {
	Frame = "KEY_RD_TITLE_FRAME",
	Head = "KEY_RD_TITLE_HEAD",
	Medal = "KEY_RD_TITLE_MEDAL"
}

function TitleRDL.Init()
	for _, v in pairs(PLAYER_TITLE_TYPE) do
		if PersistentStoreUtil.GetBool(KEY_RD_TITLE[v], false) then
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Title_Branch_Path[v], 1)
		end
	end
end

function TitleRDL.AddPlayerPrefs(_type)
	if PersistentStoreUtil.GetBool(KEY_RD_TITLE[_type], false) then
		return
	end

	PersistentStoreUtil.SetBool(KEY_RD_TITLE[_type], true)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Title_Branch_Path[_type], 1)
end

function TitleRDL.RemovePlayerPrefs(_type)
	if not PersistentStoreUtil.GetBool(KEY_RD_TITLE[_type], false) then
		return
	end

	PersistentStoreUtil.SetBool(KEY_RD_TITLE[_type], false)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Title_Branch_Path[_type], 0)
end

return TitleRDL
