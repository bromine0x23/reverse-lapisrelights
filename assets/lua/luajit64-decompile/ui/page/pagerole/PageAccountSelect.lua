-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/PageAccountSelect.lua

PageAccountSelect = class("PageAccountSelect", UIPanel)

function PageAccountSelect:ctor()
	PageAccountSelect.base.ctor(self, "UI/PanelRole/PanelPlayerSelect")
end

function PageAccountSelect:OnPageLoaded()
	return
end

function PageAccountSelect:OnEnter(vParms)
	self.btnSure = self:GetChildComponent("Panel/gridButton/sureBtn", "Button")
	self.btnCancel = self:GetChildComponent("Panel/gridButton/cancelBtn", "Button")
	self.panelRole1 = self:GetChildComponent("Panel/gridContent/Role1", "Transform")
	self.panelRole2 = self:GetChildComponent("Panel/gridContent/Role2", "Transform")
	self.txtRole1Name = self:GetChildComponent("Panel/gridContent/Role1/Name", "Text")
	self.txtRole1Rank = self:GetChildComponent("Panel/gridContent/Role1/Rank", "Text")
	self.txtRole1PayCoin = self:GetChildComponent("Panel/gridContent/Role1/money1_val", "Text")
	self.txtRole1FreeCoin = self:GetChildComponent("Panel/gridContent/Role1/money2_val", "Text")
	self.txtRole2Name = self:GetChildComponent("Panel/gridContent/Role2/Name", "Text")
	self.txtRole2Rank = self:GetChildComponent("Panel/gridContent/Role2/Rank", "Text")
	self.txtRole2PayCoin = self:GetChildComponent("Panel/gridContent/Role2/money1_val", "Text")
	self.txtRole2FreeCoin = self:GetChildComponent("Panel/gridContent/Role2/money2_val", "Text")
	self.txtRole1Name.text = vParms.role1.Name
	self.txtRole1Rank.text = vParms.role1.Rank
	self.txtRole1PayCoin.text = vParms.role1.PayCoin
	self.txtRole1FreeCoin.text = vParms.role1.FreeCoin

	if not vParms.role2 then
		self.panelRole2.gameObject:SetActive(false)
	else
		self.txtRole2Name.text = vParms.role2.Name
		self.txtRole2Rank.text = vParms.role2.Rank
		self.txtRole2PayCoin.text = vParms.role2.PayCoin
		self.txtRole2FreeCoin.text = vParms.role2.FreeCoin
	end
end

function PageAccountSelect:OnLeave()
	self.btnSure = nil
	self.btnCancel = nil
	self.panelRole1 = nil
	self.panelRole2 = nil
	self.txtRole1Name = nil
	self.txtRole1Rank = nil
	self.txtRole1PayCoin = nil
	self.txtRole1FreeCoin = nil
	self.txtRole2Name = nil
	self.txtRole2Rank = nil
	self.txtRole2PayCoin = nil
	self.txtRole2FreeCoin = nil
end

function PageAccountSelect:OnRegisterEvent()
	self:AddClick(self.btnSure.gameObject, self.OnSure)
	self:AddClick(self.btnCancel.gameObject, self.OnCancel)
end

function PageAccountSelect:OnUnRegisterEvent()
	self:RemoveClick(self.btnSure.gameObject, self.OnSure)
	self:RemoveClick(self.btnCancel.gameObject, self.OnCancel)
end

function PageAccountSelect:OnSure()
	return
end

function PageAccountSelect:OnCancel()
	self:Close()
end

function PageChooseAccount:OnBackAndroid()
	self:OnCancel()
end
