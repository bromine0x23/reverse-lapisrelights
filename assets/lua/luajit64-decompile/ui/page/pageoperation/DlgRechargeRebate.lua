-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgRechargeRebate.lua

require("UI/Page/PageRoleCard/Page/PageRoleCard")

DlgRechargeRebate = class("DlgRechargeRebate", UIPanel)

function DlgRechargeRebate:ctor()
	self.UIPrefabPath = "UI/PanelOperation/DlgRechargeRebate2"

	if OperationActiveMgr.PagRechargeRebateType == 2 then
		self.UIPrefabPath = "UI/PanelOperation/DlgRechargeRebate1"
	end
end

function DlgRechargeRebate:PreLoad()
	return
end

function DlgRechargeRebate:Purge()
	DlgRechargeRebate.base.Purge(self)
end

function DlgRechargeRebate:OnRegisterEvent()
	self:AddClick(self.GoToShopBtn, self.OnClickGoToShop)
	self:AddClick(self.CloseBtn, self.Close)
end

function DlgRechargeRebate:OnUnRegisterEvent()
	self:RemoveClick(self.GoToShopBtn, self.OnClickGoToShop)
	self:RemoveClick(self.CloseBtn, self.Close)
end

function DlgRechargeRebate:OnEnter(vParam)
	self.RebateNumText = self:GetChildComponent("Panel/InfoBg/RebateNumText", "Text")
	self.GoToShopBtn = self:GetChildGameObject("Panel/InfoBg/Button")
	self.CloseBtn = self:GetChildGameObject("Bg")

	local text = self:GetChildComponent("Panel/InfoBg/RebateText", "Text")

	text = _("Desc_Rebate")

	self:UpdateData()
end

function DlgRechargeRebate:UpdateData()
	local info = OperationActiveMgr:GetRechargeRebate()

	if info then
		self.rebateValue = info.data.DailyTime[1][1]
		self.RebateNumText.text = info.pb.record * self.rebateValue / 100
	end
end

function DlgRechargeRebate:OnClickGoToShop()
	self:Close()
	require("UI/Page/PageShop/PageShop")

	local data = {
		tagIndex = 1,
		tabMainIndex = tabMainType.charge
	}

	PageShop.InitNetData(data)
end
