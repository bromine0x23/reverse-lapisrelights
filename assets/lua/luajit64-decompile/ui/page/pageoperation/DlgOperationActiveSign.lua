-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveSign.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellSignAward")

DlgOperationActiveSign = class("DlgOperationActiveSign", UIItemBase)

function DlgOperationActiveSign:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveSign:Purge()
	if self.UIScrollTool then
		if self.UIScrollTool.ItemRoot2ItemDict then
			for _, v in self.UIScrollTool.ItemRoot2ItemDict:Enumerator() do
				v.Item:Purge()
			end
		end

		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	UIMgr.RemoveUpdatePanel(self)

	if not IsNil(self.btn_mask) then
		self:RemoveClick(self.btn_mask, self.BtnMaskOnClicked)

		self.btn_mask = nil
	end

	if not IsNil(self.btn_sign_double) then
		self:RemoveClick(self.btn_sign_double, self.BtnDouleOnClicked)

		self.btn_sign_double = nil
	end

	self:UnloadRef()

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end
end

function DlgOperationActiveSign:UnloadRef()
	self.infoActive:ClearOperationSpine()
	UnloadAllImageSprite(self)
end

function DlgOperationActiveSign:OnRegisterEvent()
	return
end

function DlgOperationActiveSign:OnUnRegisterEvent()
	return
end

function DlgOperationActiveSign:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell

	local g = self.UIRootObject

	UIMgr.SetUpdatePanel(self)

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.FX_UI_Welfare = GOUtil.FindChildGameObject(g, "Panel/Model/Fx/FX_UI_Welfare")
	self.btn_sign_double = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Model/Pic/img_sign_double/btn_sign_double")

	GOUtil.SetGameObjectLayer(self.FX_UI_Welfare, LayerMask.NameToLayer("RT"))

	if not IsNil(self.btn_sign_double) then
		self:AddClick(self.btn_sign_double, self.BtnDouleOnClicked)
	end

	self.recvGetAwardList = {}
	self.btn_mask = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/btn_mask")

	if not IsNil(self.btn_mask) then
		self:AddClick(self.btn_mask, self.BtnMaskOnClicked)
	end
end

function DlgOperationActiveSign:BtnMaskOnClicked()
	if self.recvGetAwardList and self.recvGetAwardList[1] then
		Event.Instance:Fire("ReceiveOperationActiveAward", self.recvGetAwardList[1], nil, nil, self.btn_mask)
	end

	self.BtnMaskEvent = true
end

function DlgOperationActiveSign:BtnDouleOnClicked()
	require("UI/Page/PageShop/PageShop")
	PageShop.InitNetData({
		tagIndex = 3,
		tabMainIndex = tabMainType.month
	})
end

function DlgOperationActiveSign:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveSign:Init(infoActive, BGRaw, ParentUIRootObject)
	self.img_sign_double = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Pic/img_sign_double", "Image")
	self.tex_sign_double = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Pic/img_sign_double/btn_sign_double/tex_sign_double", "Text")
	self.tex_sign_time = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Pic/img_sign_double/tex_sign_time", "Text")

	if OperationActiveMgr.PageOperationActiveType == 2 then
		self.img_pic1 = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Pic/Pic1", "Image")
		self.tex_des = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text1", "RectTransform")

		GOUtil.SetRectTransformAnchoredPosition(self.img_pic1.gameObject, -200, 345)
		GOUtil.SetRectTransformAnchoredPosition(self.tex_des.gameObject, -250, 256)
	end

	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:DealWithLocalization(self.ActiveID)

	self.ParentUIRootObject = ParentUIRootObject
	self.listSignAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)
	self.retroactiveIndex = OperationActiveMgr:JPGetLoginSignRetroactiveDay(infoActive)
	self.LoginSignDay = OperationActiveMgr:GetLoginSignDay(infoActive.data.UIType)

	local count = #self.listSignAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local data = self.listSignAward[index]

		item:UpdateData(data, infoActive, self.retroactiveIndex, self.LoginSignDay)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellSignAward, self, true, addCallback, updateCallback)

	self.UIScrollTool.ScrollView.horizontal = false

	self:GetAwardList()
end

function DlgOperationActiveSign:GetAwardList()
	local Day = self.LoginSignDay

	if self.listSignAward then
		for i = 1, #self.listSignAward do
			local data = self.listSignAward[i]
			local isGeted = self.infoActive:IsGetIndexAward(data.index)

			if data.index == Day and not isGeted then
				table.insert(self.recvGetAwardList, data.index)
			elseif data.index == Day and OperationActiveMgr.PageOperationActiveType == 2 then
				local isDouble = data.extraReward == 40002 and ShopManager:GetMonthIdState(data.extraReward)

				TaskManager.signAwardDouble = isDouble
			end
		end
	end

	self.isActive = ShopManager:GetMonthIdState(40002)

	local picPath = TenaryOp(self.isActive, "UI/PanelOperation/New/AtlasCommon/IC_signtip_card_01", "UI/PanelOperation/New/AtlasCommon/IC_signtip_card_02")

	UIUtil.SetImageSprite(self.img_sign_double, picPath, self, true)
	SetActiveFunc(self.btn_sign_double, not self.isActive and OperationActiveMgr.PageOperationActiveType == 1)
	SetActiveFunc(self.tex_sign_time.gameObject, self.isActive)

	local listShop = ShopManager.listAll[tabMainType.month]
	local infoShop = {}

	for i = 1, #listShop do
		if listShop[i].data.SubType == 3 then
			infoShop = listShop[i]
		end
	end

	self.infoProduct = ShopManager:GetProduct(infoShop.listGood[1].id)
	self.tex_sign_time.text = _("Shop_leftDay") .. DateUtil.GetDayMomentByMillis(self.infoProduct.endAt - NetData:GetCurServerTime())
end

function DlgOperationActiveSign:OnUpdate()
	if not IsNil(self.ParentUIRootObject) and self.ParentUIRootObject.activeSelf and #self.recvGetAwardList ~= 0 and not self.BtnMaskEvent and OperationActiveMgr.PageOperationActiveType == 2 then
		OperationActiveMgr.isAuto = true

		self:BtnMaskOnClicked()
	end

	if not IsNil(self.tex_sign_time) and self.tex_sign_time.gameObject.activeSelf and self.infoProduct then
		self.tex_sign_time.text = _("Shop_leftDay") .. DateUtil.GetDayMomentByMillis(self.infoProduct.endAt - NetData:GetCurServerTime())

		if self.infoProduct.endAt - NetData:GetCurServerTime() < 0 then
			local function callback(vPBMessage)
				LoadingMgr.Hide(eLoadingType.Repeat)
			end

			NetManager:RequestGetPurchaseList(callback)
			LoadingMgr.Show(eLoadingType.Repeat)
		end
	end
end

function DlgOperationActiveSign:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.infoActive = infoActive
	self.listSignAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)
	self.retroactiveIndex = OperationActiveMgr:JPGetLoginSignRetroactiveDay(infoActive)
	self.LoginSignDay = OperationActiveMgr:GetLoginSignDay(infoActive.data.UIType)

	self.UIScrollTool:UpdateListDataKeepPos(self.listSignAward)
	self:GetAwardList()
end
