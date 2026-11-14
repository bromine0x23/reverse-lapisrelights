-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/DlgNewTopicTip.lua

DlgNewTopicTip = class("DlgNewTopicTip", UIPanel, true)

function DlgNewTopicTip:ctor()
	self.UIPrefabPath = "UI/PageCommunication/DlgNewTopicTip"
end

function DlgNewTopicTip:PreLoad()
	return
end

function DlgNewTopicTip:Purge()
	DlgNewTopicTip.base.Purge(self)

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)
	end
end

function DlgNewTopicTip:OnRegisterEvent()
	return
end

function DlgNewTopicTip:OnUnRegisterEvent()
	return
end

function DlgNewTopicTip:OnEnter(vParam)
	self.roleId = vParam.roleId
	self.TopicCount = vParam.count
	self.TextTip = self:GetChildComponent("Text", "Text")

	if self.TopicCount > 1 then
		self.TextTip.text = string.format(_("Desc_UnreadMsgNum"), self.TopicCount)
	else
		local infoRole = RoleMgr:GetRole(self.roleId)

		self.TextTip.text = string.format(_("Desc_UnreadMsgFrom"), tostring(infoRole:GetCommuName()))
	end

	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 5, function()
		self.timer = nil

		self:Close()
	end, {
		1
	})
end
