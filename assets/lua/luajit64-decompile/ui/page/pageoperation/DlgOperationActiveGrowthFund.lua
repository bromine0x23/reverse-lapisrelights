-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveGrowthFund.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellGrowthFund")

local RewardData = require("luaData/RewardPack")

DlgOperationActiveGrowthFund = class("DlgOperationActiveGrowthFund", UIItemBase)

function DlgOperationActiveGrowthFund:ctor()
	return
end

function DlgOperationActiveGrowthFund:Purge()
	DlgOperationActiveGrowthFund.base.Purge(self)
	UnloadAllImageSprite(self)
	self.infoActive:ClearOperationSpine()
	self:OnUnRegisterEvent()
end

function DlgOperationActiveGrowthFund:OnRegisterEvent()
	self:AddClick(self.ButtonBuy, self.GoToShop)
	Event.Instance:Add("GrowthTaskGet", self.GetGrowthFundReward, self)
end

function DlgOperationActiveGrowthFund:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonBuy, self.GoToShop)
	Event.Instance:Remove("GrowthTaskGet", self.GetGrowthFundReward, self)
end

function DlgOperationActiveGrowthFund:OnEnter(vParam)
	self.itemPrefab = ResourceMgr.LoadSync("UI/PanelOperation/New/GrowthFundPrefebs/CellGrowthFound")
	self.TexCurLv = self:GetChildComponent("Panel/Model/Pic/PlayerLv/Lv/TexCurLv", "Text")
	self.TexNextLv = self:GetChildComponent("Panel/Model/Pic/PlayerLv/Lv/TexNextLv", "Text")
	self.TexProgress = self:GetChildComponent("Panel/Model/Pic/ImageBar/TexProgress", "Text")
	self.ImageFill = self:GetChildComponent("Panel/Model/Pic/ImageBar/ImageFill", "Transform")
	self.ButtonBuy = self:GetChildGameObject("Panel/Model/Pic/ButtonBuy")
	self.ImgIsGet = self:GetChildComponent("Panel/Model/Pic/Des/Image", "Image")
	self.TexDes = self:GetChildComponent("Panel/Model/Pic/Des/Text", "Text")
	self.TexDes1 = self:GetChildComponent("Panel/Model/Pic/Des/Text1", "Text")
	self.TexLogoDes = self:GetChildComponent("Panel/Model/Pic/Logo/Text", "Text")
	self.TexPlayerLv = self:GetChildComponent("Panel/Model/Pic/PlayerLv/Text", "Text")
	self.TexButtonBuy = self:GetChildComponent("Panel/Model/Pic/ButtonBuy/Text", "Text")
	self.TexDes.text = _("DlgOperationActiveGrowthFund_Des")
	self.TexDes1.text = _("DlgOperationActiveGrowthFund_Des1")
	self.TexLogoDes.text = _("DlgOperationActiveGrowthFund_LogoDes")
	self.TexPlayerLv.text = _("Player_Lv")

	if ShopManager:GetGrowthFund() then
		self.TexButtonBuy.text = _("DlgAdvancedCard_TextBtnCheck")
	else
		self.TexButtonBuy.text = _("Button_BuyAndGet")
	end

	self:OnRegisterEvent()
end

function DlgOperationActiveGrowthFund:Purge()
	DlgOperationActiveGrowthFund.base.Purge(self)
	UnloadAllImageSprite(self)
	self:OnUnRegisterEvent()
end

function DlgOperationActiveGrowthFund:InitScrollViewPanel()
	local ScrollArea = self:GetChildGameObject("Panel/Model/Pic/ScrollArea")
	local content = self:GetChildComponent("Panel/Model/Pic/ScrollArea/Content", "Transform")
	local count = #self.ItemData

	local function AddClick(item)
		return
	end

	local function CellUpdate(item, index)
		item:UpdateData(self.ItemData[index])
	end

	if self.UIScrollTool ~= nil then
		self.UIScrollTool:UpdateListData(self.ItemData)
	else
		self.UIScrollTool = UIScrollTool()

		self.UIScrollTool:InitList(ScrollArea, content, count, self.itemPrefab, CellGrowthFund, self, false, AddClick, CellUpdate)
	end
end

function DlgOperationActiveGrowthFund:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw

	self:UpdateData(infoActive)
end

function DlgOperationActiveGrowthFund:UpdateData(infoActive)
	local gray = TenaryOp(ShopManager:GetGrowthFund(), 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgIsGet, gray))

	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:DealWithLocalization(self.ActiveID)

	local uiInfo = InfoOperationActive:GetOperationUIInfo(self.ActiveID)
	local list = TaskManager:GetTaskListDataByID(self.infoActive.data.DailyTime[1][1])

	self.curLv = PlayerInst:GetCurLv()
	self.nextLv = self.curLv
	self.ItemData = {}

	for key, value in pairs(list.List) do
		local info = {}
		local task = TaskManager:Get(value)

		info.id = task.pb.id
		info.status = task.pb.status
		info.condition = task:GetNeedNum()
		info.isComplete = task:IsComplete()
		info.reward = task.data.Reward
		info.reward[3] = task.data.ExtraReward[1]

		if self.nextLv == self.curLv and info.condition > self.curLv then
			self.nextLv = info.condition
		end

		table.insert(self.ItemData, info)
	end

	table.sort(self.ItemData, function(a, b)
		if a.status == 3 then
			if b.status < a.status then
				return false
			end
		elseif b.status == 3 then
			if a.status < b.status then
				return true
			end
		else
			return a.id < b.id
		end
	end)

	self.TexCurLv.text = self.curLv
	self.TexNextLv.text = self.nextLv
	self.ImageFill.sizeDelta = Vector2(self.curLv / self.nextLv * 593, self.ImageFill.sizeDelta.y)
	self.TexProgress.text = self.curLv .. "/" .. self.nextLv

	self:InitScrollViewPanel()
end

function DlgOperationActiveGrowthFund:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationBg(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveGrowthFund:GetGrowthFundReward(id)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdateData(self.infoActive)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestTaskChange({
		id
	}, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgOperationActiveGrowthFund:GoToShop()
	local fromwhere = {}

	fromwhere[1] = 1
	fromwhere[2] = tabMainType.month
	fromwhere[3] = 4

	DlgItemTip.GoToFrom(fromwhere)
end
