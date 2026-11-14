-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/DlgShopProductDetail.lua

DlgShopProductDetail = class("DlgShopProductDetail", UIPanel)

function DlgShopProductDetail:ctor()
	self.UIPrefabPath = "UI/PageShop/DlgShopProductDetail"
	self.payLaw = DlgPayLaw()

	self:AddChildPanel(self.payLaw)
end

function DlgShopProductDetail:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function DlgShopProductDetail:Purge()
	DlgShopProductDetail.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end
end

function DlgShopProductDetail:OnRegisterEvent()
	self:AddClick(self.ButtonExit, self.OnClickedButtonQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonBuy, self.OnClickedButtonBuy)
	self:AddClick(self.ButtonRate, self.OnClickedButtonRate)
	self:AddClick(self.Button1, self.OnClickedButtonAdjust)
	self:AddClick(self.Button2, self.OnClickedButtonAdjust)
	self:AddClick(self.ButtonUp, self.OnClickedButtonAdjust)
end

function DlgShopProductDetail:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonExit, self.OnClickedButtonQuit)
	self:RemoveClick(self.ButtonBuy, self.OnClickedButtonBuy)
	self:RemoveClick(self.ButtonRate, self.OnClickedButtonRate)
	self:RemoveClick(self.Button1, self.OnClickedButtonAdjust)
	self:RemoveClick(self.Button2, self.OnClickedButtonAdjust)
	self:RemoveClick(self.ButtonUp, self.OnClickedButtonAdjust)
end

function DlgShopProductDetail:OnEnter(vParam)
	self.infoProduct = vParam
	self.ButtonExit = self:GetChildGameObject("Main/ButtonExit")
	self.ButtonBuy = self:GetChildGameObject("Main/Button")
	self.ButtonRate = self:GetChildGameObject("Main/ButtonDetail")
	self.ImgBuy = self:GetChildComponent("Main/Button", "Image")
	self.Button1 = self:GetChildGameObject("Main/Panel/Info3/Button1")
	self.Button2 = self:GetChildGameObject("Main/Panel/Info3/Button2")
	self.ButtonUp = self:GetChildGameObject("Main/Panel/Info3/ButtonUp")
	self.InputField = self:GetChildComponent("Main/Panel/Info3/InputField", "InputField")

	local function wrap_cb(str)
		self:OnInputFieldChange(str)
	end

	self.InputField.onValueChanged:AddListener(wrap_cb)

	if vParam.shopType == tabMainType.item or vParam.shopType == tabMainType.package or vParam.shopType == tabMainType.exchange then
		self:GetChildComponent("Main/bg_title/Text", "Text").text = _("Desc_CheckExchange")
	else
		self:GetChildComponent("Main/bg_title/Text", "Text").text = _("Desc_GoodsInfo")
	end

	self:GetChildComponent("Main/Panel/Info3/ButtonUp/Text", "Text").text = _("Desc_Max")
	self:GetChildComponent("Main/Button/Text", "Text").text = _("UI_Buy")
	self.ImgRank1 = self:GetChildComponent("Main/Panel/Rank1", "Image")
	self.ImgRank2 = self:GetChildComponent("Main/Panel/Rank2", "Image")

	local info = self.infoProduct
	local productNum = #info.data.GoodsItemList
	local discount = info.data.Discount

	self.Info1 = self:GetChildGameObject("Main/Panel/Info1")
	self.Info2 = self:GetChildGameObject("Main/Panel/Info2")
	self.Info3 = self:GetChildGameObject("Main/Panel/Info3")

	self.Info1:SetActive(false)
	self.Info2:SetActive(false)
	self.Info3:SetActive(false)

	local needShowSingle = vParam.shopType == tabMainType.package

	if productNum > 1 or needShowSingle then
		self.Info2:SetActive(true)
	elseif info.data.CostType == 1 then
		-- block empty
	else
		self.Info3:SetActive(true)
	end

	if info.data.PreGoodsCount > 0 then
		self.Info3:SetActive(false)
	end

	self.Icon = self:GetChildComponent("Main/Panel/Icon", "Image")

	UIUtil.SetImageOverrideSprite(self.Icon, info.data.Icon, self)

	self.ImgSign = self:GetChildGameObject("Main/Panel/Sign")
	self.TextSign = self:GetChildComponent("Main/Panel/Sign/Text", "Text")

	CellGood.SetSign(self.ImgSign, self.TextSign, info)

	self.TextNum = self:GetChildComponent("Main/Panel/TextNum", "Text")

	CellGood.SetItemCount(self.TextNum, info)

	self.ImageNum = self:GetChildGameObject("Main/ImageNum")
	self.TextGoodNum = self:GetChildComponent("Main/ImageNum/TextNum", "Text")

	CellGood.SetItemCount(self.TextGoodNum, info)

	self.TextLimit = self:GetChildGameObject("Main/ImageLimit")
	info.isTextLimitWrap = false

	CellGood.SetLimitBuyTime(self.TextLimit, info)

	local Text1 = self:GetChildComponent("Main/Panel/Text1", "Text")
	local Text2 = self:GetChildComponent("Main/Panel/Text2", "TextView")

	Text1.text = Lang(info.data.Name)

	Text2.gameObject:SetActive(false)

	if productNum == 1 and not needShowSingle then
		Text2.gameObject:SetActive(true)

		Text2.Text = ModifyRichTextForTextView(Lang(info.data.Info))
	end

	if info.data.CostType == 1 then
		if info.pb.firsted then
			Text2.Text = ModifyRichTextForTextView(Lang(info.data.InfoSpe))
		else
			Text2.Text = ModifyRichTextForTextView(Lang(info.data.Info))
		end
	end

	self.TextCost = self:GetChildComponent("Main/TextCost", "Text")
	self.ImageCost = self:GetChildComponent("Main/TextCost/ImageIcon", "Image")
	self.TextCostNoImg = self:GetChildComponent("Main/TextCost2", "Text")
	self.GoDisCost = self:GetChildGameObject("Main/DisCost")
	self.TextCost1 = self:GetChildComponent("Main/DisCost/TextCost1", "Text")
	self.ImgCost1 = self:GetChildComponent("Main/DisCost/TextCost1/ImageIcon", "Image")
	self.ImgCost2 = self:GetChildComponent("Main/DisCost/TextCost1/ImageIcon2", "Image")
	self.TextCost2 = self:GetChildComponent("Main/DisCost/TextCost", "Text")
	self.tex_month = self:GetChildComponent("Main/tex_month", "Text")
	self.bg_Cost = self:GetChildGameObject("Main/bg_Cost")

	CellGood.SetCost(self.GoDisCost, nil, self.ImageCost, self.TextCost, self.TextCostNoImg, self.ImgCost1, self.ImgCost2, self.TextCost1, self.TextCost2, info)

	local gCellRoleCard = self:GetChildGameObject("Main/Panel/CellSelCard")

	gCellRoleCard:SetActive(false)

	local itemCount = #info.data.GoodsItemList

	if itemCount == 1 then
		local id = info.data.GoodsItemList[1][1]
		local num = info.data.GoodsItemList[1][2]
		local infoItem = ItemManager:GetValueItem(id, num)

		if infoItem:GetType() == eItemType.RC_RECEIVE then
			local infoRoleCard = RoleCardMgr:GetRoleCard(num)
			local g = gCellRoleCard
			local CardIcon = GOUtil.FindChildComponent(g, "Icon/Image", "Image")
			local CardRank = GOUtil.FindChildComponent(g, "bg", "Image")
			local RoleJob = GOUtil.FindChildComponent(g, "ImageJob", "Image")

			UIUtil.SetImageSprite(CardIcon, infoRoleCard.data.MidIcon, self)
			UIUtil.SetImageSprite(CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_11", self)

			local roleId = RoleCardMgr:GetRoleId(num)
			local infoRole = RoleMgr:GetRole(roleId)

			UIUtil.SetImageSprite(RoleJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S", self)
			g:SetActive(true)
			SetActiveFunc(self.ImageNum, false)
		end

		GOUtil.SetActive(self.ImgRank1, info.data.ShowRank == 1)
		GOUtil.SetActive(self.ImgRank2, info.data.ShowRank == 1)

		if info.data.ShowRank == 1 then
			ItemManager:SetItemRank(infoItem, self.ImgRank1, self.ImgRank2, self)
		end
	end

	self:CheckItemRateShow(info.data.GoodsItemList)

	local Text = self:GetChildComponent("Main/Button/Text", "Text")

	Text.text = _("UI_Buy")
	Text = self:GetChildComponent("Main/Panel/Info3/TextCost", "Text")
	Text.text = _("Shop_num")
	self.tex_month.text = Lang(43252)
	self.buyNum = 1
	self.adjustNum = self.buyNum

	self:InitScrollView()
	self:UpdateCost(self.buyNum)

	local costValue = info.data.CostValue
	local infoItem = ItemManager:Get(costValue[1])

	if (infoItem:GetType() == eItemType.P_DIAMOND or infoItem:GetType() == eItemType.P_DIAMOND_PAY) and info.data.GoodsPrice[2] ~= 0 then
		self.payLaw:Show(0, GOUtil.IsActiveSelf(self.ButtonBuy) and -180 or -270)
		GOUtil.SetTransformLocalPosition(self.bg_Cost, 300, -250, 0)
		GOUtil.SetTransformLocalPosition(self.TextCost.gameObject, 300, -250, 0)
		GOUtil.SetTransformLocalPosition(self.ButtonRate, self.ButtonRate.transform.localPosition.x, -80, 0)
	end
end

function DlgShopProductDetail:CheckItemRateShow(list)
	if #list > 0 then
		for k, v in pairs(list) do
			local id = v[1]
			local infoItem = ItemManager:GetValueItem(id)

			if infoItem.data.UseId ~= 0 then
				local rewardPack = ItemManager.GetRewardPackData(infoItem.data.UseId)

				if rewardPack.DropGroupList and #rewardPack.DropGroupList > 0 then
					SetActiveFunc(self.ButtonRate, true)

					break
				end
			end
		end
	end
end

function DlgShopProductDetail:OnClickedButtonRate()
	NetManager:SendRequestGetProductRate(self.infoProduct.id, function(vMsg)
		require("UI/Page/PageShop/DlgProductRate")
		UIMgr.AddPanel(DlgProductRate(), {
			info = self.infoProduct,
			probDetail = vMsg.itemsProbDetail
		})
	end)
end

function DlgShopProductDetail:OnClickedButtonQuit()
	self:Close()
end

function DlgShopProductDetail:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Main/Panel/Info2/ScrollArea")
	local content = self:GetChildComponent("Main/Panel/Info2/ScrollArea/Content", "Transform")
	local count = #self.infoProduct.data.GoodsItemList

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellItem, self, false)
end

function DlgShopProductDetail:UpdateCell(item, index)
	item.Index = index

	local data = self.infoProduct.data.GoodsItemList[index]
	local info = ItemManager:GetValueItem(data[1], data[2])

	item:UpdateWithNumType(info, false)
end

function DlgShopProductDetail:AddCellClick(item)
	return
end

function DlgShopProductDetail:OnClickedButtonBuy()
	if self.fobiden then
		local cost = self.infoProduct.data.CostValue

		if cost and #cost == 2 and not ItemManager:IsItemHoldEnough(cost[1], cost[2] * self.buyNum) then
			return
		end

		return
	end

	self.fobiden = true

	local info = self.infoProduct

	if info.data.CostType == 1 then
		self.buyNum = 1
	end

	local extra = ""

	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			SoundMgr.Play(PATH_SFX_UI_SHOP_BUYSUCCESS)
		else
			self.vPBMessage = vPBMessage

			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end

		self:Close()
	end

	if info.data.CostType ~= 1 and info.data.CostType ~= 4 then
		local allprice = info.data.CostValue[2] * self.buyNum
		local infoItemCharge = ItemManager:Get(info.data.CostValue[1])

		if GetItemType(infoItemCharge.data.Type) == eItemType.P_DIAMOND and allprice > PlayerInst:GetDiamond() and allprice <= PlayerInst:GetDiamondAll() then
			-- block empty
		else
			local cost = info.data.CostValue

			if cost and #cost == 2 and not ItemManager:IsItemHoldEnough(cost[1], cost[2] * self.buyNum) then
				return
			end
		end
	end

	NetEncapManager:RequestPurchasePruduct(info.id, self.buyNum, extra, {}, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgShopProductDetail:OnClickedButtonAdjust(data)
	local go = data.pointerPress
	local info = self.infoProduct
	local discount = info.data.Discount
	local costValue = info.data.CostValue
	local infoItem = ItemManager:Get(costValue[1])
	local valueDiscount = costValue[2]
	local curRes = infoItem:GetCurResNum()

	if infoItem:GetType() == eItemType.P_DIAMOND then
		curRes = PlayerInst:GetDiamondAll()
	end

	local maxNum = math.floor(curRes / valueDiscount)
	local storeNumber = info.data.StoreNumber
	local limitBuyTime = storeNumber - info.pb.myCount
	local config = GetConfigArgInt("GoodsLimitBuyCount")

	if storeNumber == -1 or config < limitBuyTime then
		limitBuyTime = config
	end

	if maxNum == 0 then
		maxNum = 1
	end

	if limitBuyTime < maxNum then
		maxNum = limitBuyTime
	end

	if go.name == "Button1" then
		self.adjustNum = self.adjustNum - 1

		if self.adjustNum < 1 then
			self.adjustNum = 1
		end
	elseif go.name == "Button2" then
		self.adjustNum = self.adjustNum + 1

		if maxNum < self.adjustNum then
			self.adjustNum = maxNum
		end
	elseif go.name == "ButtonUp" then
		self.adjustNum = maxNum
	end

	if self.buyNum ~= self.adjustNum then
		self.buyNum = self.adjustNum
		self.InputField.text = self.buyNum

		self:UpdateCost(self.buyNum)
	end
end

function DlgShopProductDetail:OnInputFieldChange(str)
	if str == nil or tonumber(str) == nil then
		self.InputField.text = 1
		self.adjustNum = 1

		if self.buyNum ~= self.adjustNum then
			self.buyNum = self.adjustNum
			self.InputField.text = self.buyNum

			self:UpdateCost(self.buyNum)
		end

		return
	end

	local info = self.infoProduct
	local discount = info.data.Discount
	local costValue = info.data.CostValue
	local infoItem = ItemManager:Get(costValue[1])
	local valueDiscount = costValue[2]
	local curRes = infoItem:GetCurResNum()

	if infoItem:GetType() == eItemType.P_DIAMOND then
		curRes = PlayerInst:GetDiamondAll()
	end

	local maxNum = math.floor(curRes / valueDiscount)
	local limitBuyTime = info.data.StoreNumber - info.pb.myCount
	local config = GetConfigArgInt("GoodsLimitBuyCount")

	if info.data.StoreNumber == -1 or config < limitBuyTime then
		limitBuyTime = config
	end

	if maxNum == 0 then
		maxNum = 1
	end

	if limitBuyTime < maxNum then
		maxNum = limitBuyTime
	end

	local inputNum = tonumber(str)

	if inputNum < 1 then
		inputNum = 1
	end

	if maxNum < inputNum then
		inputNum = maxNum
	end

	self.InputField.text = inputNum
	self.adjustNum = inputNum

	if self.buyNum ~= self.adjustNum then
		self.buyNum = self.adjustNum
		self.InputField.text = self.buyNum

		self:UpdateCost(self.buyNum)
	end
end

function DlgShopProductDetail:UpdateCost(num)
	local info = self.infoProduct
	local discount = info.data.Discount
	local costValue = info.data.CostValue

	if #info.data.GoodsPrice == 1 then
		SetActiveFunc(self.tex_month.gameObject, false)

		return
	end

	local valueOrigin = info.data.GoodsPrice[2] * num
	local valueDiscount = costValue[2] * num

	self.TextCost1.text = valueOrigin
	self.TextCost2.text = valueDiscount

	local infoItem = ItemManager:Get(costValue[1])
	local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

	UIUtil.SetImageOverrideSprite(self.ImgCost1, pathIcon, self)
	UIUtil.SetImageOverrideSprite(self.ImageCost, pathIcon, self)

	self.TextCost.text = valueOrigin

	if infoItem:GetType() ~= eItemType.P_DIAMOND and infoItem:GetType() ~= eItemType.P_DIAMOND_PAY then
		local gray = TenaryOp(valueOrigin > infoItem:GetCurResNum(), 1, 0)

		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBuy, gray))
	end

	if self.infoProduct.isMonThCard then
		if not ShopManager:IsGetAnyMonthCard() then
			SetActiveFunc(self.TextCost.gameObject, false)

			if discount == 100 then
				SetActiveFunc(self.TextCost2.gameObject, false)
			end

			SetActiveFunc(self.bg_Cost, false)
			SetActiveFunc(self.ButtonBuy, false)
			SetActiveFunc(self.tex_month.gameObject, true)
		elseif self.infoProduct.pb.myCount >= self.infoProduct.data.StoreNumber then
			SetActiveFunc(self.TextCost.gameObject, false)
			SetActiveFunc(self.TextCost2.gameObject, false)
			SetActiveFunc(self.bg_Cost, false)
			SetActiveFunc(self.ButtonBuy, false)
			SetActiveFunc(self.tex_month.gameObject, true)

			self.tex_month.text = Lang(90028003)
		else
			SetActiveFunc(self.tex_month.gameObject, false)
		end
	else
		SetActiveFunc(self.tex_month.gameObject, false)
	end
end
