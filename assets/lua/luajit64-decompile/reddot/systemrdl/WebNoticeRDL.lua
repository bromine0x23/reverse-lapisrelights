-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/WebNoticeRDL.lua

WebNoticeRDL = {}

local KEY_NOTICE = "KEY_NOTICE"
local NoticeRDLPath = "Notice"
local READED_NOTICE = {}
local UNREAD_NOTICE = {}

function WebNoticeRDL.Init()
	READED_NOTICE = PersistentStoreUtil.GetList(KEY_NOTICE)
end

function WebNoticeRDL.CheckNotice(noticeList)
	for i = 0, noticeList.Count - 1 do
		local singleInfo = noticeList:get_Item(i)
		local numBegin = singleInfo.beginAt

		if numBegin then
			local noticeKey = singleInfo.id .. "-" .. singleInfo.beginAt

			if not table.contains(READED_NOTICE, noticeKey) and numBegin + 259200 >= NetData:GetCurServerTime() / 1000 and not table.contains(UNREAD_NOTICE, noticeKey) then
				table.insert(UNREAD_NOTICE, noticeKey)
			end
		end
	end

	WebNoticeRDL.TriggerRD()
end

function WebNoticeRDL.SetRead(id, begin)
	local noticeKey = id .. "-" .. begin

	if table.contains(UNREAD_NOTICE, noticeKey) then
		table.removeByValue(UNREAD_NOTICE, noticeKey)
	end

	if not table.contains(READED_NOTICE, noticeKey) then
		table.insert(READED_NOTICE, noticeKey)
		PersistentStoreUtil.AddList(KEY_NOTICE, noticeKey)
	end

	print("set read " .. #READED_NOTICE)
	print("set unread " .. #UNREAD_NOTICE)
	WebNoticeRDL.TriggerRD()
end

function WebNoticeRDL.TriggerRD()
	RedDotSystemMgr.SetNodeValueByFormatPath(NoticeRDLPath, #UNREAD_NOTICE)
end

return WebNoticeRDL
