-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgNotice.lua

DlgNotice = class("DlgNotice", UIPanel)

function DlgNotice:ctor()
	self.UIPrefabPath = "UI/PanelLogin/PanelNotice"
end

function DlgNotice:OnRegisterEvent()
	self:AddClick(self.BgNotice, self.OnClickedButton)
end

function DlgNotice:OnUnRegisterEvent()
	self:RemoveClick(self.BgNotice, self.OnClickedButton)
end

function DlgNotice:OnClickedButton()
	self:Close()
end

function DlgNotice:OnEnter(vParam)
	self.TextNotice = self:GetChildComponent("Panel/Text", "Text")
	self.BgNotice = self:GetChildGameObject("Bg")
	self.TextNotice.text = NetManager.NoticeTxt
end
