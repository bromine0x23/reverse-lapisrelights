-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/DlgScoreShop.lua

require("UI/Page/PageShop/CellGood")

DlgScoreShop = class("DlgScoreShop", UIPanel)

function DlgScoreShop:ctor()
	self.UIPrefabPath = "UI/PageCardShop/DlgScoreShop"
end

function DlgScoreShop:OnBack()
	self:Close()
end

function DlgScoreShop:Purge()
	DlgScoreShop.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	ResourceMgr.Unload(self.PrefabCell)
end

function DlgScoreShop:PreLoad()
	self:LoadResAsync("UI/PageShop/CellCardShopProduct", "PrefabCell")
end

function DlgScoreShop.InitNetData(data)
	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			UIMgr.AddPanel(DlgScoreShop(), data)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestGetPurchaseList(callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgScoreShop:OnEnter(vParam)
	self.info = vParam
	self.ButtonQuit = self:GetChildGameObject("Panel/Button")
	self.TextNum = self:GetChildComponent("Panel/TextNum", "Text")
	self.TextTip = self:GetChildComponent("Panel/TextTip", "Text")
	self.TextTime = self:GetChildComponent("Panel/TextTime", "Text")

	local id = self.info.data.ScoreNum[1]
	local infoItem = ItemManager:Get(id)

	self.TextNum.text = infoItem:GetNum()

	local t2 = GetTimeTampByString(self.info.data.ShopEndTime)

	self.TextTip.text = DateUtil.GetTwoMomentByMillis(t2)
	self.infoShop = ShopManager:Get(self.info.data.ShopId)
	self.listGood = self.infoShop.listGood

	self:InitScrollView()
end

function DlgScoreShop:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnBack)
end

function DlgScoreShop:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnBack)
end

function DlgScoreShop:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listGood

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellGood, self, false)
end

function DlgScoreShop:UpdateCell(item, index)
	item.Index = index

	local info = self.listGood[index]

	item:UpdateData(info)
end

function DlgScoreShop:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function DlgScoreShop:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local infoProduct = self.listGood[info.Item.Index]
	local id = infoProduct.data.GoodsItemList[1][1]
	local infoItem = ItemManager:Get(id)

	if infoProduct.data.CostType == 3 then
		require("UI/Page/PageShop/DlgChangeStar")
		UIMgr.AddPanel(DlgChangeStar(), infoProduct, self.UIRootObject)
	else
		require("UI/Page/PageShop/DlgShopProductDetail")
		UIMgr.AddPanel(DlgShopProductDetail(), infoProduct, self.UIRootObject)
	end
end
