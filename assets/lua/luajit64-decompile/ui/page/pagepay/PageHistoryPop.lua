-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/PageHistoryPop.lua

PageHistoryPop = class("PageHistoryPop", UIPanel)

function PageHistoryPop:ctor()
	PageHistory.base.ctor(self, "UI/PanelPay/PanelHisPopup")
end

function PageHistoryPop:Purge()
	PageHistory.base.Purge(self)
	self:OnLeave()
end

function PageHistoryPop:OnLeave()
	self.BtnAsc = nil
	self.BtnDesc = nil
	self.BtnClose = nil
	self.BtnFilter = nil
	self.TxtFilter = nil
	self.BtnRece = nil
	self.listMail = nil
	self.listState = nil
end

function PageHistoryPop:OnRegisterEvent()
	self:AddClick(self.btnClose, self.Close)
end

function PageHistoryPop:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose, self.Close)
end

function PageHistoryPop:OnEnter(vParam)
	self.btnClose = self:GetChildGameObject("bg/close")
	self.txt_content = self:GetChildComponent("bg/bgInner/text", "Text")
	self.txt_content.text = _("PageHistory_description_1")
end
