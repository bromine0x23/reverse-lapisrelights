-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgFirstRecharge.lua

require("UI/Page/PageRoleCard/Page/PageRoleCard")

DlgFirstRecharge = class("DlgFirstRecharge", UIPanel)

function DlgFirstRecharge:ctor()
	self.UIPrefabPath = "UI/PanelOperation/DlgFirstRecharge"
end

function DlgFirstRecharge:PreLoad()
	self.PrefabCellItem = ResourceMgr.LoadSync("UI/Item/CellItem")
	self.PrefabEffect = ResourceMgr.LoadSync("Fx/UI/FX_UI_Welfare/FX_UI_Welfare01")
end

function DlgFirstRecharge:Purge()
	DlgFirstRecharge.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.PrefabCellItem then
		ResourceMgr.Unload(self.PrefabCellItem)

		self.PrefabCellItem = nil
	end

	ResourceMgr.Unload(self.PrefabEffect)
end

function DlgFirstRecharge:OnRegisterEvent()
	self:AddClick(self.GoToShopBtn, self.OnClickGoToShop)
	self:AddClick(self.GetAwardBtn, self.OnClickGetAward)
	self:AddClick(self.CloseBtn, self.Close)
end

function DlgFirstRecharge:OnUnRegisterEvent()
	self:RemoveClick(self.GoToShopBtn, self.OnClickGoToShop)
	self:RemoveClick(self.GetAwardBtn, self.OnClickGetAward)
	self:RemoveClick(self.CloseBtn, self.Close)
end

function DlgFirstRecharge:OnEnter(vParam)
	self.NeedMoneyText = self:GetChildComponent("Panel/NeedMoneyText", "Text")
	self.GoToShopBtn = self:GetChildGameObject("Panel/GoToShopBtn")
	self.GetAwardBtn = self:GetChildGameObject("Panel/GetAwardBtn")
	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	self.CloseBtn = self:GetChildGameObject("Bg")
	self.CardName = self:GetChildComponent("Panel/CardName", "Text")
	self.CardTip = self:GetChildComponent("Panel/CardTip", "Text")

	OperationRDL.FirstRechargeRDL.SubOpenedPlayerPrefs()
	self:UpdateData()
end

function DlgFirstRecharge:UpdateData()
	local _, info = OperationActiveMgr:CheckFirstRechargeExist()

	self.info = info
	self.getIndex = #self.info.pb.awardRecords
	self.needMoney = self.info.data.DailyTime[1][self.getIndex + 1]

	if self.needMoney <= self.info.pb.record then
		SetActiveFunc(self.GetAwardBtn, true)
		SetActiveFunc(self.GoToShopBtn, false)

		OperationActiveMgr.firstChargeType = 3
	else
		SetActiveFunc(self.GetAwardBtn, false)
		SetActiveFunc(self.GoToShopBtn, true)

		OperationActiveMgr.firstChargeType = 2
	end

	self.NeedMoneyText.text = self.info.pb.record .. "/" .. self.needMoney

	local pack = OperationActiveMgr:GetRewardPackData(self.info.data.TypeReward[self.getIndex + 1]).PackItem
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")

	self.listItem = {}

	for i = 1, #pack do
		local award = pack[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			table.insert(self.listItem, infoItem)

			if infoItem:GetType() == eItemType.RC_RECEIVE then
				self.cardId = infoItem:GetNum()
			end
		end
	end

	local cardInfo = RoleCardMgr:GetRoleCard(self.cardId)

	self.CardName.text = Lang(cardInfo.data.Name)
	self.CardTip.text = Lang(cardInfo.data.Location[2])

	local count = #self.listItem

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.PrefabCellItem, CellItem, self, false, nil, ListUpdate)

	self.UIScrollTool.ScrollView.horizontal = false
	self.UIScrollTool.ScrollView.vertical = false
end

function DlgFirstRecharge:OnClickGoToShop()
	self:Close()
	require("UI/Page/PageShop/PageShop")

	local data = {
		tagIndex = 1,
		tabMainIndex = tabMainType.package
	}

	PageShop.InitNetData(data)
end

function DlgFirstRecharge:OnClickGetAward()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self.info:ChangeAwardRecords(self.getIndex + 1)
			self:Close()
			Event.Instance:Fire("UpdateFirstCharge")
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestOperationActiveAward(self.info.data.ID, self.getIndex + 1, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgFirstRecharge:UpdateCell(item, index)
	item:UpdateWithNumType(self.listItem[index])
	GOUtil.SetTransformLocalScale(item.UIRootObject, 1.4)

	if item.info:GetType() == eItemType.RC_RECEIVE then
		item.noClick = true

		local effect = GOUtil.InstantiatePrefab(self.PrefabEffect, item.UIRootObject)

		GOUtil.SetTransformLocalScale(effect, 0.66)
	end
end

function DlgFirstRecharge:AddCellClick(item)
	self:AddClick(item.UIRootObject, function()
		if item.info:GetType() == eItemType.RC_RECEIVE then
			local data = {
				onlyShow = true,
				cardId = item.info:GetNum()
			}

			UIMgr.SwitchPanel(PageRoleCard, data)
			self:Close()

			OperationActiveMgr.firstChargeType = 1
		end
	end)
end
