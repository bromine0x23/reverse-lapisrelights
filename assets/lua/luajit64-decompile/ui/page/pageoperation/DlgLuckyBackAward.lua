-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgLuckyBackAward.lua

require("UI/Page/PageRoleCard/Page/PageRoleCard")

local ActiveConditionData = require("luaData/ActiveCondition")

DlgLuckyBackAward = class("DlgLuckyBackAward", UIPanel)

function DlgLuckyBackAward:ctor()
	self.UIPrefabPath = "UI/PanelOperation/New/DlgLuckyBackAward"
end

function DlgLuckyBackAward:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function DlgLuckyBackAward:Purge()
	if self.UIScrollToolPanel then
		self.UIScrollToolPanel:Purge()

		self.UIScrollToolPanel = nil
	end

	ResourceMgr.Unload(self.PrefabCell)
	self:UnloadRef()

	self.PrefabCell = nil

	DlgLuckyBackAward.base.Purge(self)
end

function DlgLuckyBackAward:UnloadRef()
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

function DlgLuckyBackAward:OnRegisterEvent()
	self:AddClick(self.btn_buy, self.OnClickBtnBuy)
	self:AddClick(self.Btn_close, self.OnClickClose)
	Event.Instance:Add("DlgLuckyBackAwardBuyEvent", self.DlgLuckyBackAwardBuyEvent, self)
end

function DlgLuckyBackAward:OnUnRegisterEvent()
	self:RemoveClick(self.btn_buy, self.OnClickBtnBuy)
	self:RemoveClick(self.Btn_close, self.OnClickClose)
	Event.Instance:Remove("DlgLuckyBackAwardBuyEvent", self.DlgLuckyBackAwardBuyEvent, self)
	UIMgr.RemoveUpdatePanel(self)
end

function DlgLuckyBackAward:OnEnter(vParam)
	self.info = vParam.info
	self.info.isShow = true

	if vParam.callBack then
		self.callBack = vParam.callBack
	end

	UIMgr.SetUpdatePanel(self)

	self.Btn_close = self:GetChildGameObject("Btn_close")

	SetActiveFunc(self.Btn_close, vParam.isShowBG)

	self.tex_num = self:GetChildComponent("panel/go_tex/tex_num", "Text")
	self.tex_time = self:GetChildComponent("panel/go_tex/tex_time", "Text")
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
	self.mask = self:GetChildGameObject("panel/mask")
	self.img_title = self:GetChildComponent("panel/img_title", "Image")
	self.tex_title = self:GetChildComponent("panel/go_tex/tex_title", "Text")

	self:UpdateData()
end

function DlgLuckyBackAward:UpdateData()
	local uiInfo = InfoOperationActive:GetOperationGiftBagTypeUIInfo(self.info.data.ID)

	self.infoProduct = ShopManager:GetProduct(self.info.id)

	local originValue = self.infoProduct.data.CostValue
	local costValue = self.infoProduct.data.GoodsPrice
	local count = #self.infoProduct.data.GoodsItemList

	local function AddClick(item)
		return
	end

	if self.infoProduct.data.CostType == 1 then
		self.tex_pre.text = "¥" .. costValue[1]
		self.tex_buy.text = "¥" .. originValue[1]

		SetActiveFunc(self.tex_pre.gameObject, true)
		SetActiveFunc(self.tex_buy.gameObject, true)
	else
		self.tex_pre2.text = costValue[2]
		self.tex_buy2.text = originValue[2]

		SetActiveFunc(self.img_pre.gameObject, true)
		SetActiveFunc(self.img_buy.gameObject, true)

		local infoItem = ItemManager:Get(costValue[1])
		local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

		self.diamondID = infoItem.id

		UIUtil.SetImageOverrideSprite(self.img_pre, pathIcon, self)
		UIUtil.SetImageOverrideSprite(self.img_buy, pathIcon, self)
	end

	self.panel = self:GetChildComponent("panel", "Image")
	self.mask = self:GetChildGameObject("panel/mask")
	self.img_title = self:GetChildComponent("panel/img_title", "Image")
	self.tex_title = self:GetChildComponent("panel/go_tex/tex_title", "Text")

	if uiInfo then
		for i = 1, 1 do
			local Rmg = self.panel

			if uiInfo and uiInfo.Bg and uiInfo.Bg[i] and uiInfo.Bg[i][1] and Rmg then
				UIUtil.SetImageSprite(Rmg, uiInfo.Bg[i][1], self, true)
			end
		end

		for i = 1, 1 do
			local goSpine = self.mask

			if uiInfo and uiInfo.Spine and uiInfo.Spine[i] and uiInfo.Spine[i][1] and goSpine and goSpine.transform.childCount == 0 then
				if not self.spineGroupHandle then
					self.spineGroupHandle = {}
				end

				self.spineGroupHandle[i] = ResourceMgr.BeginSubmit(function()
					if self.Spine then
						if not self.listRef then
							self.listRef = {}
						end

						table.insert(self.listRef, self.Spine)

						local cell = GOUtil.InstantiateUIPrefab(self.Spine, goSpine)

						cell.transform.localScale = Vector3(uiInfo.Spine[i][3] or 0.5, uiInfo.Spine[i][3] or 0.5, 1)

						GOUtil.SetTransformLocalPosition(cell.gameObject, 34, -115, 0)

						cell.transform.localEulerAngles = Vector3.New(0, 0, 32)

						GOUtil.UpdateSpineSkeleton(cell.gameObject)
					end
				end)

				ResourceMgr.SubmitCache(uiInfo.Spine[i][1], self, "Spine", GameObject)
				ResourceMgr.EndSubmit()
			end
		end

		for i = 1, 1 do
			local Img = self.img_title

			if uiInfo and uiInfo.Pic and uiInfo.Pic[i] and uiInfo.Pic[i][1] and Img then
				UIUtil.SetImageSprite(Img, uiInfo.Pic[i][1], self, true)
			end
		end

		for i = 1, 1 do
			local Text = self.tex_title

			if uiInfo and uiInfo.Text and uiInfo.Text[i] and uiInfo.Text[i][1] and Text then
				Text.text = Lang(uiInfo.Text[i][1])
			end
		end
	end

	self.tex_num.text = self.infoProduct.data.Discount / 10

	local function CellUpdate(item, index)
		local award = self.infoProduct.data.GoodsItemList[index]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			if award[2] == 0 then
				item:UpdateNoNumType(infoItem)
			else
				item:UpdateWithNumType(infoItem)
			end

			GOUtil.SetRectTransformSizeDelta(item.UIRootObject, 180, 180)
		end
	end

	self.UIScrollToolPanel = UIScrollTool()

	self.UIScrollToolPanel:InitList(self.ScrollArea, self.content, count, self.PrefabCell, CellItem, self, false, AddClick, CellUpdate)
	self:UpdateContext()
end

function DlgLuckyBackAward:OnClickBtnBuy()
	local info = self.infoProduct

	self.buyNum = 1

	if info.data.CostType == 2 then
		if self.diamondID and self.diamondID == 513 and PlayerInst:GetDiamondPay() < info.data.CostValue[2] * self.buyNum then
			UIMgr.ShowMsg(_("Desc_DrawCardNotEnoughRes"))

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

	NetEncapManager:RequestPurchasePruduct(info.id, self.buyNum, extra, {}, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgLuckyBackAward:DlgLuckyBackAwardBuyEvent()
	GoodsInfoListMgr:RemoveLuckyByType(self.info.data.CycleType)
	self:LuckyBackAwardDlgHide()
	Event.Instance:Fire("LuckyBackAwardBtnHide", self.info.data.CycleType)
end

function DlgLuckyBackAward:LuckyBackAwardDlgHide()
	self:Purge()

	if self.callBack then
		self.callBack()
	end
end

function DlgLuckyBackAward:UpdateContext()
	if self.tex_time then
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local time = self.info.endTime - curServerTime

		if time >= 0 then
			self.tex_time.text = _("Desc_ActivityRemain") .. GetStrDisTime(time)
		else
			GoodsInfoListMgr:RemoveLuckyByType(self.info.data.CycleType)
			self:LuckyBackAwardDlgHide()
			Event.Instance:Fire("LuckyBackAwardBtnHide", self.info.data.CycleType)
		end
	end
end

function DlgLuckyBackAward:OnUpdateSecond()
	self:UpdateContext()
end

function DlgLuckyBackAward:OnClickClose()
	self:Purge()
	Event.Instance:Fire("LuckyBackAwardBtnShow")
end
