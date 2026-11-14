-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgMessage.lua

require("UI/UIPanel")
require("Info/InfoItem")

DlgMessage = class("DlgMessage", UIPanel)

function DlgMessage:ctor()
	self.UIPrefabPath = "UI/Common/DlgMessagePrompt/DlgMessagePrompt"
	self.closed = true
	self.isSyncLoad = true
end

function DlgMessage:OnEnter(vParam)
	self.isObjShow = true
	self.Text = self:GetChildComponent("Text", "Text")
	self.ImageIcon = self:GetChildComponent("ImageIcon", "Image")
	self.TextNum = self:GetChildComponent("ImageIcon/Text", "Text")
	self.Animator = GOUtil.GetComponent(self.UIRootObject, "Animator")

	if type(vParam) == "table" then
		if #vParam == 1 then
			self:Show(vParam[1])
		else
			self:ShowItem(vParam[1], vParam[2])
		end
	end
end

function DlgMessage:Purge()
	self.base.Purge(self)

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)

		self.timeId = nil
	end

	self.isObjShow = nil
	self.preShowMsg = nil
end

function DlgMessage:OnEndMsg()
	if not self.isObjShow then
		return
	end

	self.UIRootObject:SetActive(false)

	self.isObjShow = false
end

function DlgMessage:Show(strPrompt)
	if not self.isObjShow then
		self.UIRootObject:SetActive(true)

		self.isObjShow = true
	end

	if not self.preShowMsg then
		GOUtil.SetActive(self.Text, true)
		GOUtil.SetActive(self.ImageIcon, false)
	end

	self.Text.text = strPrompt

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)

		self.timeId = nil
	end

	self.Animator:Play("Message", 0, 0)

	self.timeId = TimerMgr.AddTimer(eTimerType.RealTime, 2, self.OnEndMsg, self)
	self.preShowMsg = true
end

function DlgMessage:ShowItem(id, num)
	if not self.isObjShow then
		self.UIRootObject:SetActive(true)

		self.isObjShow = true
	end

	if self.preShowMsg then
		GOUtil.SetActive(self.Text, false)
		GOUtil.SetActive(self.ImageIcon, true)
	end

	self.TextNum.text = num

	local info = ItemManager:GetValueItem(id, num)

	if info then
		UIUtil.SetImageSprite(self.ImageIcon, GetItemIcon(info:GetType(), id), self)
	end

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)

		self.timeId = nil
	end

	self.Animator:Play("Message", 0, 0)

	self.timeId = TimerMgr.AddTimer(eTimerType.RealTime, 1, self.OnEndMsg, self)
	self.preShowMsg = false
end
