-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgStoryAward.lua

require("UI/UIPanel")
require("Info/InfoItem")

DlgStoryAward = class("DlgStoryAward", UIPanel)

function DlgStoryAward:ctor()
	self.UIPrefabPath = "UI/PageStory/DlgStoryAward"
end

function DlgStoryAward:OnEnter(vparam)
	if vparam.offset then
		local rt = GOUtil.GetComponent(self.UIRootObject, "RectTransform")
		local ap = rt.anchoredPosition

		GOUtil.SetRectTransformAnchoredPosition(self.UIRootObject, ap.x, vparam.offset)
	end

	self.Image = self:GetChildComponent("HeadMask/Image", "Image")
	self.Text = self:GetChildComponent("Text", "Text")

	Event.Instance:Add("DlgStoryAwardHide", self.DlgStoryAwardHide, self)

	local setter = SetterData.GetSetterData(vparam.setter)
	local wrap_cb

	if SetterData.showLevelup then
		function wrap_cb()
			UIMgr.AddPanel(DlgProducerLevelUp(), {
				callback = panelCb
			})
		end
	else
		wrap_cb = panelCb
	end

	local listNormal = setter:Getlist(protocol_pb.AF_NORMAL)
	local listExtra = setter:Getlist(protocol_pb.AF_EXTRA_AWARD)
	local listTouchExtra = setter:Getlist(protocol_pb.AF_TOUCH_EXTRA)

	if #listNormal > 0 or #listExtra > 0 or #listTouchExtra > 0 then
		local list = setter.list
		local s = list[1]
		local info = SetterData.GetItemFromAsset(s)

		UIUtil.SetImageSprite(self.Image, info:GetIcon(), self)

		self.Text.text = Lang(info.data.Name) .. "x" .. info:GetNum()

		if info:GetType() == eItemType.R_FAVOR_EXP then
			self.Text.text = _("Friendliness") .. "+" .. info:GetNum()
		end

		if self.timeId ~= nil then
			TimerMgr.RemoveTimer(self.timeId)
		end

		self.timeId = TimerMgr.AddTimer(eTimerType.RealTime, 3, self.OnEndMsg, self)
	end

	if vparam.callback then
		vparam.callback()
	end
end

function DlgStoryAward:Purge()
	Event.Instance:Remove("DlgStoryAwardHide", self.DlgStoryAwardHide, self)

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	UnloadAllImageSprite(self)
	DlgStoryAward.base.Purge(self)
end

function DlgStoryAward:DlgStoryAwardHide()
	if not IsNil(self.UIRootObject) then
		self.UIRootObject:SetActive(false)
	end
end

function DlgStoryAward:OnEndMsg()
	self.UIRootObject:SetActive(false)
	Object.Destroy(self.UIRootObject)

	self.UIRootObject = nil

	UnloadAllImageSprite(self)
end
