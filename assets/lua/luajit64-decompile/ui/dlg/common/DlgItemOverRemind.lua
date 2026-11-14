-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgItemOverRemind.lua

DlgItemOverRemind = class("DlgItemOverRemind", UIPanel)

function DlgItemOverRemind:ctor()
	self.UIPrefabPath = "UI/Common/DlgCommon/DlgItemOverRemind"
	self.Callback = nil
	self.NotRemind = false
end

function DlgItemOverRemind:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function DlgItemOverRemind:Purge()
	DlgGetAward.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellItem)
	self:OnLeave()
end

function DlgItemOverRemind:OnLeave()
	if self.listItem and #self.listItem > 0 then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end

		self.listItem = nil
	end
end

function DlgItemOverRemind:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClickedBtnSelRemind)
	self:AddClick(self.BtnSure, self.OnClickedBtnSure)
end

function DlgItemOverRemind:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClickedBtnSelRemind)
	self:RemoveClick(self.BtnSure, self.OnClickedBtnSure)
end

function DlgItemOverRemind:OnEnter(vParam)
	local _text = self:GetChildComponent("Panel/Title/Text", "Text")

	_text.text = Lang(12199)
	_text = self:GetChildComponent("Panel/Group/Text", "Text")
	_text.text = "上限を超えたアイテムはメールで配布します"
	_text = self:GetChildComponent("Panel/Group/Remind/Text", "Text")
	_text.text = "今日はもう表示しない"
	_text = self:GetChildComponent("Panel/BtnSure/Text", "Text")
	_text.text = Lang(5000019)
	self.Button = self:GetChildGameObject("Panel/Group/Remind/Button")
	self.Select = self:GetChildGameObject("Panel/Group/Remind/Select")

	self.Select:SetActive(self.NotRemind)

	self.BtnSure = self:GetChildGameObject("Panel/BtnSure")

	if vParam and vParam.callback then
		self.Callback = vParam.callback
	end
end

function DlgItemOverRemind:OnClickedBtnSelRemind()
	self.NotRemind = not self.NotRemind

	self.Select:SetActive(self.NotRemind)
end

function DlgItemOverRemind:OnClickedBtnSure()
	self:Close()

	if self.Callback then
		self.Callback()

		self.Callback = nil
	end

	PersistentStoreUtil.SetBool("NotRemindToday", self.NotRemind)

	SetterData.haveOverItem = false
	self.NotRemind = nil
end
