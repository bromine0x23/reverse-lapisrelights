-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgRoleBirthdayAward.lua

DlgRoleBirthdayAward = class("DlgRoleBirthdayAward", UIPanel)

function DlgRoleBirthdayAward:ctor()
	self.UIPrefabPath = "UI/PanelOperation/New/DlgRoleBirthdayAward"
end

function DlgRoleBirthdayAward:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCell")
	self:LoadAssetsAsync(OperationActiveMgr.RoleBirthdayVideoClip, VideoClip)
end

function DlgRoleBirthdayAward:Purge()
	UIMgr.RemoveUpdatePanel(self)

	if self.UIScrollToolPanel then
		self.UIScrollToolPanel:Purge()

		self.UIScrollToolPanel = nil
	end

	self:UnloadRef()
	DlgRoleBirthdayAward.base.Purge(self)

	OperationActiveMgr.RoleBirthdayVideoClip = nil

	if self.DlgPreviewActor then
		self.DlgPreviewActor:Purge()

		self.DlgPreviewActor = nil
	end
end

function DlgRoleBirthdayAward:UnloadRef()
	if self.spineGroupHandle then
		for _, v in pairs(self.spineGroupHandle) do
			ResourceMgr.Cancel(v)
		end
	end

	if self.listRef then
		for _, v in pairs(self.listRef) do
			ResourceMgr.Unload(v)
		end

		self.listRef = nil
	end

	UnloadAllImageSprite(self)
end

function DlgRoleBirthdayAward:OnRegisterEvent()
	self:AddClick(self.btn_buy, self.OnClickBtnBuy)
	self:AddClick(self.Btn_close, self.OnClickClose)
	Event.Instance:Add("CloseRoleBirthdayAward", self.UpdateOperation, self)
	Event.Instance:Add("DlgRoleBirthdayAwardBuyEvent", self.DlgRoleBirthdayAwardBuyEvent, self)
end

function DlgRoleBirthdayAward:OnUnRegisterEvent()
	self:RemoveClick(self.btn_buy, self.OnClickBtnBuy)
	self:RemoveClick(self.Btn_close, self.OnClickClose)
	Event.Instance:Remove("CloseRoleBirthdayAward", self.UpdateOperation, self)
	Event.Instance:Remove("DlgRoleBirthdayAwardBuyEvent", self.DlgRoleBirthdayAwardBuyEvent, self)
end

function DlgRoleBirthdayAward:OnEnter(vParam)
	if vParam.callback then
		self.callBack = vParam.callback
	end

	UIMgr.SetUpdatePanel(self)

	self.Btn_close = self:GetChildGameObject("Btn_close")

	SetActiveFunc(self.Btn_close, vParam.isShowBG)

	self.tex_pre = self:GetChildComponent("panel/go_buy/tex_pre", "Text")
	self.tex_buy = self:GetChildComponent("panel/go_buy/btn_buy/tex_buy", "Text")
	self.btn_buy = self:GetChildGameObject("panel/go_buy/btn_buy")
	self.ScrollArea = self:GetChildGameObject("panel/ScrollArea")
	self.content = self:GetChildComponent("panel/ScrollArea/Content", "Transform")
	self.img_pre = self:GetChildComponent("panel/go_buy/img_pre", "Image")
	self.tex_pre2 = self:GetChildComponent("panel/go_buy/img_pre/tex_pre", "Text")
	self.img_buy = self:GetChildComponent("panel/go_buy/btn_buy/img_buy", "Image")
	self.tex_buy2 = self:GetChildComponent("panel/go_buy/btn_buy/img_buy/tex_buy", "Text")
	self.panel = self:GetChildComponent("panel", "Image")
	self.img_title = self:GetChildComponent("panel/img_title", "Image")
	self.Play = self:GetChildComponent("panel/mask/Play", "VideoPlayer")
	OperationActiveMgr.RoleBirthdayPopupIndex = 0

	self:Init(vParam.infoActive)
end

function DlgRoleBirthdayAward:Init(infoActive)
	self.infoActive = infoActive
	self.goodsID = infoActive.data.DailyTime[1][1]

	local itemInfo = ShopManager:GetProduct(self.goodsID)

	self.infoProduct = itemInfo

	self:UpdateData(infoActive)
end

function DlgRoleBirthdayAward:UpdateData(infoActive)
	local itemInfo = ShopManager:GetProduct(self.goodsID)

	self.infoProduct = itemInfo

	local originValue = itemInfo.data.CostValue
	local costValue = itemInfo.data.GoodsPrice
	local count = #itemInfo.data.GoodsItemList

	local function AddClick(item)
		return
	end

	if itemInfo.data.CostType == 1 then
		self.tex_pre.text = "¥" .. costValue[1]
		self.tex_buy.text = "¥" .. originValue[1] / 100

		SetActiveFunc(self.tex_pre.gameObject, costValue[1] ~= originValue[1] / 100)
		SetActiveFunc(self.tex_buy.gameObject, true)
	else
		self.tex_pre2.text = costValue[2]
		self.tex_buy2.text = originValue[2]

		SetActiveFunc(self.img_pre.gameObject, costValue[2] ~= originValue[2])
		SetActiveFunc(self.img_buy.gameObject, true)

		local infoItem = ItemManager:Get(costValue[1])
		local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

		self.diamondID = infoItem.id

		UIUtil.SetImageOverrideSprite(self.img_pre, pathIcon, self)
		UIUtil.SetImageOverrideSprite(self.img_buy, pathIcon, self)
	end

	self.panel = self:GetChildComponent("panel", "Image")
	self.img_title = self:GetChildComponent("panel/img_title", "Image")
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	local uiInfo = InfoOperationActive:GetOperationUIInfo(self.ActiveID)

	if uiInfo then
		for i = 1, 1 do
			local Rmg = self.panel

			if uiInfo and uiInfo.Bg and uiInfo.Bg[i] and uiInfo.Bg[i][1] and Rmg then
				UIUtil.SetImageSprite(Rmg, uiInfo.Bg[i][1], self, true)
			end
		end

		for i = 1, 3 do
			local Img = self:GetChildComponent("panel/pic" .. i, "Image")

			if uiInfo and uiInfo.Pic and uiInfo.Pic[i] and uiInfo.Pic[i][1] and Img then
				print("==============" .. uiInfo.Pic[i][1])
				UIUtil.SetImageSprite(Img, uiInfo.Pic[i][1], self, true)
			end
		end

		self:GetChildComponent("panel/pic3", "Image"):SetNativeSize()

		for i = 1, 2 do
			if uiInfo and uiInfo.Text and uiInfo.Text[i] and uiInfo.Text[i][1] then
				local Text = self:GetChildComponent("panel/tex" .. i, "Text")

				if IsNil(Text) then
					return
				end

				Text.text = Lang(uiInfo.Text[i][1])

				Text.gameObject.transform:SetSiblingIndex(uiInfo.Text[i][2])

				if uiInfo.Text[i][3] and uiInfo.Text[i][4] then
					GOUtil.SetRectTransformAnchoredPosition(Text.gameObject, uiInfo.Text[i][3], uiInfo.Text[i][4])
				end
			end
		end
	end

	local function CellUpdate(item, index)
		local award = itemInfo.data.GoodsItemList[index]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			if award[2] <= 1 then
				item:UpdateNoNumType(infoItem)
			else
				item:UpdateWithNumType(infoItem)
			end

			item:SetBirth(index == count)
			GOUtil.SetRectTransformSizeDelta(item.UIRootObject, 180, 180)
		end
	end

	self.UIScrollToolPanel = UIScrollTool()

	self.UIScrollToolPanel:InitList(self.ScrollArea, self.content, count, self.PrefabCell, CellItem, self, false, AddClick, CellUpdate)
	self:SetVideoPlayerClip(self.Play, OperationActiveMgr.RoleBirthdayVideoClip)
end

function DlgRoleBirthdayAward:OnClickBtnBuy()
	local info = self.infoProduct

	self.buyNum = 1

	local function vCallBack(idx)
		if idx ~= DlgCommonEvent.ButtonType.Ok then
			return
		end

		if info.data.CostType == 2 then
			if self.diamondID and self.diamondID == 513 and PlayerInst:GetDiamondPay() < info.data.CostValue[2] * self.buyNum then
				UIMgr.ShowMsg(_("Desc_DiamondPayNotEnough"))

				return
			elseif self.diamondID and self.diamondID == 502 and PlayerInst:GetDiamond() < info.data.CostValue[2] * self.buyNum then
				UIMgr.ShowMsg(_("Desc_DrawCardNotEnoughRes"))

				return
			end
		end

		local extra = ""

		local function callback(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				local GoodIdList = {}

				GoodIdList.id = info.id
				GoodIdList.num = 0
				GoodIdList.updateTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

				table.insert(ItemManager.GoodIdList, GoodIdList)
				self:OnClickClose()
				SoundMgr.Play(PATH_SFX_UI_SHOP_BUYSUCCESS)
			else
				UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			end
		end

		if info.data.CostType ~= 1 and info.data.CostType ~= 4 then
			local allprice = info.data.CostValue[2] * self.buyNum
			local infoItemCharge = ItemManager:Get(info.data.CostValue[1])

			if GetItemType(infoItemCharge.data.Type) == eItemType.P_DIAMOND and allprice > PlayerInst:GetDiamond() and allprice <= PlayerInst:GetDiamondAll() then
				local leftNum = allprice - PlayerInst:GetDiamond()
				local strAlert

				if leftNum > 0 then
					strAlert = string.format(_("Desc_CostPayDiamond"), PlayerInst:GetDiamond(), leftNum)
				end

				local function fun(type)
					if type == DlgCommonEvent.ButtonType.Ok then
						NetEncapManager:RequestPurchasePruduct(info.id, self.buyNum, extra, {}, callback)
						LoadingMgr.Show(eLoadingType.Repeat)
					else
						self.fobiden = false
					end
				end

				UIMgr.ShowCommon(DlgCommonEvent.Type.MsgWithAlert, _("Desc_Alert"), {
					strAlert = "",
					content = strAlert
				}, fun)

				return
			end
		end

		if info.data.CostType == 1 then
			local function fun(vPBMessage)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vPBMessage.result.code == NetManager.Result_Sucess then
					SoundMgr.Play(PATH_SFX_UI_SHOP_BUYSUCCESS)
				else
					UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
				end
			end

			NetEncapManager:RequestPurchasePruduct(info.id, self.buyNum, extra, {}, fun)
			LoadingMgr.Show(eLoadingType.Repeat)

			return
		end

		NetManager:RequestPurchaseActivePruduct(self.infoActive.id, callback)
		LoadingMgr.Show(eLoadingType.Repeat)
	end

	if info.data.CostType == 2 then
		UIMgr.ShowCommon(DlgCommonEvent.Type.DiamondBuyTips, _("Desc_Alert"), {
			item2 = "バースデーパック",
			isDiamond = true,
			item1 = self.diamondID,
			num1 = info.data.CostValue[2] * self.buyNum
		}, vCallBack)
	else
		vCallBack(1)
	end
end

function DlgRoleBirthdayAward:DlgRoleBirthdayAwardBuyEvent()
	if self.infoProduct.data.CostType == 1 then
		local GoodIdList = {}

		GoodIdList.id = self.goodsID
		GoodIdList.buyTimes = Mathf.Round(NetData:GetCurServerTime() / DateUtil.MillsPerSecond)

		table.insert(InfoGameInst.gameInfo.birthdayGoods, GoodIdList)
	else
		local GoodIdList = {}

		GoodIdList.id = self.goodsID
		GoodIdList.num = 0
		GoodIdList.updateTime = Mathf.Round(NetData:GetCurServerTime() / DateUtil.MillsPerSecond)

		table.insert(ItemManager.GoodIdList, GoodIdList)
	end

	Event.Instance:Fire("UpdateAfterGetAvatar")
	self:OnClickClose()
end

function DlgRoleBirthdayAward:OnUpdateSecond()
	if not self.infoActive:OnMonthAndDay() then
		UIMgr.RemoveUpdatePanel(self)
		self:OnClickClose()
	end
end

function DlgRoleBirthdayAward:UpdateOperation()
	self:OnClickClose()
end

function DlgRoleBirthdayAward:OnClickClose()
	self:Purge()

	if self.callBack and not UIMgr.GetCurPanel().TipWindow and not UIMgr.GetCurPanel().TipWindowVideo then
		self.callBack()
	end

	Event.Instance:Fire("PageMainStageUpdatePanel")
end
