-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/PageBossRaidShop.lua

require("UI/Page/PageShop/CellGood")

local RaidBossUIData = require("luaData/RaidBossUIData")

PageBossRaidShop = class("PageBossRaidShop", UIPanel)

function PageBossRaidShop:ctor()
	self.UIPrefabPath = "UI/PanelActivityBossRaid/PageBossRaidShop"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_BossRaid"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageBossRaidShop:OnBack()
	UIMgr.PopPanel()
end

function PageBossRaidShop:Purge()
	PageBossRaidShop.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	if self.spineCnt then
		for i = 1, self.spineCnt do
			if self["SpineHandle" .. i] then
				ResourceMgr.Cancel(self["SpineHandle" .. i])

				self["SpineHandle" .. i] = nil
			end
		end

		self.spineCnt = nil
	end

	ResourceMgr.Unload(self.PrefabCell)
end

function PageBossRaidShop:PreLoad()
	self:LoadResAsync("UI/PageShop/CellBossRaidProduct", "PrefabCell")
end

function PageBossRaidShop.InitNetData(data)
	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			UIMgr.SwitchPanel(PageBossRaidShop, data)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestGetPurchaseList(callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageBossRaidShop:OnEnter(vParam)
	self.info = ActivityBossRaidMgr.bossRaidTimeData
	self.GoSpinePoint = self:GetChildGameObject("BG")
	self.BG = self:GetChildComponent("BG", "RawImage")
	self.Icon = self:GetChildComponent("Panel/Icon", "Image")
	self.LittleTitalImage = self:GetChildComponent("Panel/Line", "Image")
	self.Desc = self:GetChildComponent("Panel/Line/Text", "Text")
	self.Time = self:GetChildComponent("Panel/Time/Text", "Text")
	self.TimeObj = self:GetChildGameObject("Panel/Time")
	self.TimeImage = self:GetChildComponent("Panel/Time", "Image")
	self.infoShop = ShopManager:Get(self.info.data.ShopId)
	self.listGood = self.infoShop.listGood
	self.CostImage = self:GetChildComponent("Panel/Main/LineImage/Cost/Image", "Image")
	self.TextNum = self:GetChildComponent("Panel/Main/LineImage/Cost/TextNum", "Text")
	self.Time.text = self:GetTime(ActivityBossRaidMgr.bossRaidTimeData.data.StartTime) .. "—" .. self:GetTime(ActivityBossRaidMgr.bossRaidTimeData.data.CloseTime)
	self.AutoCloseTime = GetTimeTampByString(ActivityBossRaidMgr.bossRaidTimeData.data.CloseTime)

	self:InitScrollView()
	self:UpdateBossRaidUI()
	self:UpdateCount()
end

function PageBossRaidShop:OnRegisterEvent()
	Event.Instance:Add("UpdateShop", self.UpdateShop, self)
end

function PageBossRaidShop:OnUnRegisterEvent()
	Event.Instance:Remove("UpdateShop", self.UpdateShop, self)
end

function PageBossRaidShop:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/Main/Bg/ScrollArea")
	local content = self:GetChildComponent("Panel/Main/Bg/ScrollArea/Content", "Transform")
	local count = #self.listGood

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellGood, self, false)
end

function PageBossRaidShop:UpdateCell(item, index)
	item.Index = index

	local info = self.listGood[index]

	info.isTextLimitWrap = true

	item:UpdateData(info)
end

function PageBossRaidShop:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function PageBossRaidShop:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local infoProduct = self.listGood[info.Item.Index]
	local lock = GOUtil.FindChildGameObject(go, "ImageLock")

	if lock and lock.activeSelf then
		UIMgr.ShowMsg(_("Desc_BuyGood_Limit"))

		return
	end

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

function PageBossRaidShop:UpdateBossRaidUI()
	self.UIData = RaidBossUIData[ActivityBossRaidMgr.bossRaidTimeData.data.ID]

	UIUtil.SetRawImageTexture(self.BG, self.UIData.ShopBgImage, self, true)
	UIUtil.SetImageSprite(self.Icon, self.UIData.ShopTitalImage, self, true)
	GOUtil.SetRectTransformAnchoredPosition(self.Icon.gameObject, self.UIData.ShopTitalPos[1], self.UIData.ShopTitalPos[2])

	self.Time.color = getColorFromString(self.UIData.ShopTimePos[3])

	GOUtil.SetRectTransformAnchoredPosition(self.TimeObj, self.UIData.ShopTimePos[1], self.UIData.ShopTimePos[2])

	self.TimeImage.color = getColorFromString(self.UIData.ShopTimePos[4])

	UIUtil.SetImageSprite(self.LittleTitalImage, self.UIData.ShopSubTitalImage, self)
	GOUtil.SetRectTransformAnchoredPosition(self.LittleTitalImage.gameObject, self.UIData.ShopSubTitalDescPos[1], self.UIData.ShopSubTitalDescPos[2])
	GOUtil.SetRectTransformSizeDelta(self.LittleTitalImage.gameObject, self.UIData.ShopSubTitalDescLength[1], self.UIData.ShopSubTitalDescLength[2])

	self.Desc.text = Lang(self.UIData.ShopSubTitalDesc)
	self.Desc.color = getColorFromString(self.UIData.ShopSubTitalDescPos[3])

	self:UpdateCost()
	self:LoadSpine()
end

function PageBossRaidShop:LoadSpine(cb)
	local canvas = GOUtil.AddMissingComponent(self.GoSpinePoint, "Canvas")

	canvas.overrideSorting = true
	canvas.sortingOrder = -5

	local spinePath = self.UIData.ShopSpinePath
	local pos = self.UIData.ShopSpinePos
	local roa = self.UIData.ShopSpineRoa
	local scale = self.UIData.ShopSpineScale

	self.spineCnt = #spinePath

	local idx = 1

	local function LoadSpineAsync(path)
		local function asyncFinishCallback()
			if self["SpineRef" .. idx] then
				self["Go" .. idx] = GOUtil.InstantiateUIPrefab(self["SpineRef" .. idx], self.GoSpinePoint)

				GOUtil.UpdateSpineSkeleton(self["Go" .. idx])
				GOUtil.SetRectTransformAnchoredPosition(self["Go" .. idx], pos[idx][1], pos[idx][2])
				GOUtil.SetTransformRotation(self["Go" .. idx], roa[idx][1], roa[idx][2], roa[idx][3])
				GOUtil.SetTransformLocalScale(self["Go" .. idx], scale[idx])
				DealWithListSpineRef(self, self["SpineRef" .. idx])

				self["SpineHandle" .. idx] = nil
				self["SpineRef" .. idx] = nil
				self["Go" .. idx].layer = 5

				local canvas = GOUtil.AddMissingComponent(self["Go" .. idx], "Canvas")

				canvas.overrideSorting = true
				canvas.sortingOrder = idx - #spinePath - 1
				idx = idx + 1

				if idx <= self.spineCnt then
					LoadSpineAsync(spinePath[idx])
				elseif cb then
					cb()
				end
			end
		end

		self["SpineHandle" .. idx] = ResourceMgr.BeginSubmit(asyncFinishCallback)

		ResourceMgr.SubmitCache(path, self, "SpineRef" .. idx, GameObject)
		ResourceMgr.EndSubmit()
	end

	if self.spineCnt > 0 then
		LoadSpineAsync(spinePath[idx])
	end
end

function PageBossRaidShop:UpdateCost()
	local itemId = self.infoShop.data.ResList[1]
	local infoItem = ItemManager:Get(itemId)
	local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

	UIUtil.SetImageOverrideSprite(self.CostImage, pathIcon .. "_S", self)
end

function PageBossRaidShop:UpdateCount()
	local itemId = self.infoShop.data.ResList[1]

	self.TextNum.text = ItemManager:GetItemCount(itemId)
end

function PageBossRaidShop:UpdateShop()
	self:UpdateCount()
	self.UIScrollTool:UpdateListDataKeepPos(self.listGood)
end

function PageBossRaidShop:GetTime(strTime)
	local str = ""
	local a = string.split(strTime, " ")

	if #a > 0 then
		local date = string.split(a[1], "-")
		local yearT = tonumber(date[1])
		local monthT = tonumber(date[2])
		local dayT = tonumber(date[3])

		str = yearT .. "/" .. monthT .. "/" .. dayT
	end

	return str
end

function PageBossRaidShop:OnUpdateSecond()
	if not self.AutoCloseTime then
		return
	end

	local time = self.AutoCloseTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if time <= 0 then
		self.AutoCloseTime = nil

		UIMgr.ClearAndSavePageMainStage()
		UIMgr.ClearChildAndSavePageMainStage()
		UIMgr.PopPanel(nil, 0)
	end
end
