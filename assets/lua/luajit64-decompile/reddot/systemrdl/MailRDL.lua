-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/MailRDL.lua

MailRDL = {}

local RD_Mail_Branch_Path = {
	Unread = "Mail/Unread"
}
local PRE_VALUE = 0

function MailRDL.Init()
	local value = 0

	if MailMgr:HaveNotReadMail() then
		value = 1
	end

	if PRE_VALUE ~= value then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Mail_Branch_Path.Unread, value)

		PRE_VALUE = value
	end
end

function MailRDL.DealMail()
	MailRDL.Init()
end

return MailRDL
