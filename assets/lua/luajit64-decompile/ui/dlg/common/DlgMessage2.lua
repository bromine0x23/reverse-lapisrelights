-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgMessage2.lua

require("UI/UIPanel")
require("Info/InfoItem")

DlgMessage2OffType = {
	default = 0,
	offset2 = 2,
	offset1 = 1
}
DlgMessage2 = class("DlgMessage2", UIPanel)

function DlgMessage2:ctor()
	self.UIPrefabPath = "UI/Common/DlgMessagePrompt/DlgMessagePrompt2"
	self.closed = true
	self.DlgMessage2Off = DlgMessage2OffType.default
	self.isSyncLoad = true
end

function DlgMessage2:OnEnter(vParam)
	self.IsObjShow = true
	self.Text = self:GetChildComponent("Text", "Text")

	self:Show(vParam[1], vParam[2])
end

function DlgMessage2:Purge()
	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)

		self.timeId = nil
	end

	self.IsObjShow = nil

	self.base.Purge(self)
end

function DlgMessage2:OnEndMsg()
	if not self.IsObjShow then
		return
	end

	if not IsNil(self.UIRootObject) then
		self.UIRootObject:SetActive(false)

		self.IsObjShow = false
	end
end

function DlgMessage2:Show(strPrompt, noTimer)
	if not self.IsObjShow then
		self.UIRootObject:SetActive(true)

		self.IsObjShow = true
	end

	self:ResetPosition()

	self.Text.text = strPrompt

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)

		self.timeId = nil
	end

	if not noTimer then
		self.timeId = TimerMgr.AddTimer(eTimerType.RealTime, 5, self.OnEndMsg, self)
	end
end

function DlgMessage2:ResetPosition()
	if self.DlgMessage2Off == DlgMessage2OffType.offset1 then
		GOUtil.SetRectTransformAnchoredPosition(self.UIRootObject, -200, 258)
	elseif self.DlgMessage2Off == DlgMessage2OffType.offset2 then
		GOUtil.SetRectTransformAnchoredPosition(self.UIRootObject, -370, 258)
	else
		GOUtil.SetRectTransformAnchoredPosition(self.UIRootObject, 0, 258)
	end
end
