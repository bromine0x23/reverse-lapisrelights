-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/CellGood.lua

require("UI/Item/UIItemBase")

CellGood = class("CellGood", UIItemBase)

function CellGood:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellGood:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageF1 = GOUtil.FindChildGameObject(g, "ImageF1")
	self.ImageF2 = GOUtil.FindChildGameObject(g, "ImageF2")
	self.Icon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.ImgSign = GOUtil.FindChildGameObject(g, "Sign")
	self.GoSignLeft1 = GOUtil.FindChildGameObject(g, "Sign/1")
	self.GoSignLeft2 = GOUtil.FindChildGameObject(g, "Sign/2")
	self.ImgSignLeft1 = GOUtil.FindChildComponent(g, "Sign/1", "Image")
	self.TextSign = GOUtil.FindChildComponent(g, "Sign/Text", "Text")
	self.ImageNumBg = GOUtil.FindChildGameObject(g, "Image")
	self.TextNum = GOUtil.FindChildComponent(g, "Image/TextNum", "Text")
	self.TextName = GOUtil.FindChildComponent(g, "TextName", "Text")
	self.TextCost = GOUtil.FindChildComponent(g, "TextCost", "Text")
	self.ImageCost = GOUtil.FindChildComponent(g, "TextCost/ImageIcon", "Image")
	self.TextCostNoIcon = GOUtil.FindChildComponent(g, "TextCost2", "Text")
	self.GoDownTime = GOUtil.FindChildGameObject(g, "ImgDownTime")
	self.TextDownTime = GOUtil.FindChildComponent(g, "TextDownTime", "Text")
	self.GoTimeLimit = GOUtil.FindChildGameObject(g, "ImageLimit")
	self.TextLimit = GOUtil.FindChildComponent(g, "ImageLimit/TextLimit", "Text")
	self.GoDisCost = GOUtil.FindChildGameObject(g, "DisCost")
	self.TextCost1 = GOUtil.FindChildComponent(g, "DisCost/TextCost1", "Text")
	self.ImgCost1 = GOUtil.FindChildComponent(g, "DisCost/TextCost1/ImageIcon", "Image")
	self.TextCost2 = GOUtil.FindChildComponent(g, "DisCost/TextCost", "Text")
	self.ImgCost2 = GOUtil.FindChildComponent(g, "DisCost/TextCost1/ImageIcon2", "Image")
	self.GoLock = GOUtil.FindChildGameObject(g, "ImageLock")
	self.GoSign2 = GOUtil.FindChildGameObject(g, "ImageLock/Sign2")
	self.TextSign2 = GOUtil.FindChildComponent(g, "ImageLock/Sign2/Text", "Text")
	self.IsBuy = GOUtil.FindChildGameObject(g, "IsBuy")
	self.GoNew = GOUtil.FindChildGameObject(g, "ImageNew")
	self.GoLockMonth = GOUtil.FindChildGameObject(g, "ImageNotBuy")

	for i = 1, 4 do
		self["GoBase" .. i] = GOUtil.FindChildGameObject(g, "base/" .. i)
	end
end

function CellGood:UpdateBase(index)
	for i = 1, 4 do
		if self["GoBase" .. i] then
			self["GoBase" .. i]:SetActive(false)
		end
	end

	local i = math.fmod(index, 4)

	if i == 0 then
		i = 4
	end

	if self["GoBase" .. i] then
		self["GoBase" .. i]:SetActive(true)
	end
end

function CellGood:UpdateItemList(info, prefabCellItem, goParent)
	if info == nil then
		return
	end

	local g = self.UIRootObject
	local gContent = GOUtil.FindChildGameObject(g, "ScrollView/Viewport/Content")
	local scroll = GOUtil.FindChildComponent(g, "ScrollView", "UIScrollRectThrough")

	scroll:SetEventParent(goParent)
	GOUtil.DestroyAllChildren(gContent)
	self.ImageNumBg:SetActive(false)

	local list = info.data.GoodsItemList

	CellGood.listItem = CellGood.listItem or {}

	for i = 1, #list do
		local data = list[i]
		local item = CellItem(prefabCellItem, gContent, self)

		item:Create()

		local infoItem = ItemManager:GetValueItem(data[1], data[2])

		item:SetFree(info, infoItem)
		item:UpdateWithNumType(infoItem, false)
		table.insert(CellGood.listItem, item)
	end

	if gContent then
		local w = GOUtil.GetRectTransformWidth(gContent)

		GOUtil.SetRectTransformSizeDelta(gContent, w, 110 * (#list / 2 - 1))
	end
end

function CellGood.DealWithRef(ref)
	local panel = UIMgr.GetPanel("PageShop")

	if panel ~= nil and ref ~= nil then
		DealWithListRef(panel, ref)
	end
end

function CellGood:OnLeave()
	UnloadAllImageSprite(self)

	local panel = UIMgr.GetPanel("PageShop")

	if panel ~= nil then
		UnloadAllImageSprite(panel)
	end

	if CellGood.listItem then
		for i = 1, #CellGood.listItem do
			CellGood.listItem[i]:OnLeave()
		end
	end

	CellGood.listItem = nil
end

function CellGood:UpdateData(info)
	if info == nil then
		return
	end

	UIUtil.SetImageOverrideSprite(self.Icon, info.data.Icon, self)

	local discount = info.data.Discount

	if discount < 100 then
		discount = 100 - discount
	end

	self.ImgSign:SetActive(false)
	self.GoSignLeft1:SetActive(false)
	self.GoSignLeft2:SetActive(false)
	self.TextSign.gameObject:SetActive(false)

	if info.data.SignBG ~= "" then
		self.ImgSign:SetActive(true)
		self.GoSignLeft1:SetActive(true)
		self.GoSignLeft2:SetActive(false)
		UIUtil.SetImageOverrideSprite(self.ImgSignLeft1, info.data.SignBG, self)
	elseif discount < 100 then
		self.ImgSign:SetActive(true)
		self.GoSignLeft1:SetActive(false)
		self.GoSignLeft2:SetActive(true)

		local dis = discount / 10

		self.TextSign.gameObject:SetActive(true)

		self.TextSign.text = dis
	end

	self.TextName.text = Lang(info.data.Name)

	CellGood.SetItemCount(self.TextNum, info)

	if info.data.CostType == 1 then
		if info.pb.firsted then
			self.TextNum.text = Lang(info.data.InfoSpeShow)
		else
			self.TextNum.text = Lang(info.data.InfoShow)
		end
	end

	CellGood.SetCost(self.GoDisCost, self.GoNew, self.ImageCost, self.TextCost, self.TextCostNoIcon, self.ImgCost1, self.ImgCost2, self.TextCost1, self.TextCost2, info)
	CellGood.SetLimitBuyTime(self.GoTimeLimit, info)
	self.TextDownTime.gameObject:SetActive(false)
	self.GoDownTime:SetActive(false)
	CellGood.SetLock(self.GoLock, info)

	if self.IsBuy ~= nil then
		self.IsBuy:SetActive(self.GoLock.activeSelf)
	end

	CellGood.SetRoleCard(self.UIRootObject, info)
end

function CellGood.SetRoleCard(gRoot, info)
	local gCell = GOUtil.FindChildGameObject(gRoot, "GoCard")

	gCell:SetActive(false)

	local gImg = GOUtil.FindChildGameObject(gRoot, "Image")
	local gNum = GOUtil.FindChildGameObject(gRoot, "Image/TextNum")
	local gIcon = GOUtil.FindChildGameObject(gRoot, "Icon")

	gIcon:SetActive(true)
	gImg:SetActive(true)
	gNum:SetActive(true)

	local itemCount = #info.data.GoodsItemList

	if itemCount <= 1 then
		local id = info.data.GoodsItemList[1][1]
		local num = info.data.GoodsItemList[1][2]
		local infoItem = ItemManager:GetValueItem(id, num)

		if infoItem:GetType() == eItemType.RC_RECEIVE then
			local g = GOUtil.FindChildGameObject(gCell, "CellSelCard")
			local infoRoleCard = RoleCardMgr:GetRoleCard(num)
			local CardIcon = GOUtil.FindChildComponent(g, "Icon/Image", "Image")
			local CardRank = GOUtil.FindChildComponent(g, "bg", "Image")
			local RoleJob = GOUtil.FindChildComponent(g, "ImageJob", "Image")
			local ref = UIUtil.SetImageSprite(CardIcon, infoRoleCard.data.MidIcon)

			CellGood.DealWithRef(ref)

			ref = UIUtil.SetImageSprite(CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_15")

			CellGood.DealWithRef(ref)

			local roleId = RoleCardMgr:GetRoleId(num)
			local infoRole = RoleMgr:GetRole(roleId)

			ref = UIUtil.SetImageSprite(RoleJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S")

			CellGood.DealWithRef(ref)
			gImg:SetActive(false)
			gNum:SetActive(false)
			gIcon:SetActive(false)
			gCell:SetActive(true)
		end
	end
end

function CellGood.SetLock(gLock, info)
	local limitBuyTime = info.data.StoreNumber
	local usedBuyTime = info.pb.myCount
	local isLock = false

	if limitBuyTime ~= -1 and limitBuyTime <= usedBuyTime then
		isLock = true

		local GoSign2 = GOUtil.FindChildGameObject(gLock, "Sign2")

		GoSign2:SetActive(false)
	end

	gLock:SetActive(isLock)
end

local curCount, maxCount

function CellGood.SetLimitBuyTime(gTxt, info)
	local limitBuyTime = info.data.StoreNumber
	local usedBuyTime = limitBuyTime - info.pb.myCount

	if usedBuyTime < 0 then
		usedBuyTime = 0
	end

	if info.data.StoreNumber == -1 then
		gTxt.gameObject:SetActive(false)
	else
		gTxt.gameObject:SetActive(true)

		local TextLimit = GOUtil.FindChildComponent(gTxt.gameObject, "TextLimit", "Text")

		TextLimit.fontSize = 20
		usedBuyTime = info.pb.myCount

		if limitBuyTime <= usedBuyTime then
			usedBuyTime = limitBuyTime
		end

		local str = _("Shop_limit_day")

		if info.data.StoreType == 0 then
			str = _("Shop_limit")
		elseif info.data.StoreType == 2 then
			str = _("Shop_limit_week")
		elseif info.data.StoreType == 3 then
			str = _("Shop_limit_month")
		end

		if info.data.PreGoodsCount > 0 then
			curCount = info.pb.myCount
			maxCount = info.data.PreGoodsCount

			CellGood.CalLimitCount(info)

			limitBuyTime = maxCount
			usedBuyTime = curCount

			if usedBuyTime < 0 then
				usedBuyTime = 0
			end
		end

		if info.isTextLimitWrap then
			TextLimit.text = str .. "\n" .. limitBuyTime - usedBuyTime .. "/" .. limitBuyTime
		else
			TextLimit.text = str .. " " .. limitBuyTime - usedBuyTime .. "/" .. limitBuyTime
		end
	end
end

function CellGood.CalLimitCount(infoGood)
	local PreGoodsID = infoGood.data.PreGoodsID

	if PreGoodsID > 0 then
		local infoPre = ShopManager:GetProduct(PreGoodsID)

		curCount = curCount + infoPre.pb.myCount

		if infoPre.data.PreGoodsID then
			CellGood.CalLimitCount(infoPre)
		end
	end
end

function CellGood.SetCost(GoDisCost, GoNew, ImageCost, TextCost, TextCostNoIcon, ImgCost1, ImgCost2, TextCost1, TextCost2, info)
	local discount = info.data.Discount
	local costValue = info.data.GoodsPrice
	local originValue = info.data.CostValue
	local isNew = false
	local isFree = false

	if info.data.Discount == 100 then
		GoDisCost:SetActive(false)
		TextCost.gameObject:SetActive(true)
		TextCostNoIcon.gameObject:SetActive(false)

		if info.data.CostType == 1 then
			TextCost.gameObject:SetActive(false)
			TextCostNoIcon.gameObject:SetActive(true)

			TextCostNoIcon.text = "¥" .. costValue[1]

			if costValue[1] == 0 then
				isFree = true
				TextCostNoIcon.text = _("Desc_Free")
			end
		else
			ImageCost.gameObject:SetActive(true)

			local infoItem = ItemManager:Get(costValue[1])
			local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

			if pathIcon == "UIDyAtlas/Icon/IC_RES_003" or pathIcon == "UIDyAtlas/Icon/IC_RES_004" then
				pathIcon = pathIcon .. "_02"
			end

			local ref = UIUtil.SetImageOverrideSprite(ImageCost, pathIcon)

			CellGood.DealWithRef(ref)

			TextCost.text = costValue[2]

			if costValue[2] == 0 then
				ImageCost.gameObject:SetActive(false)

				isFree = true

				TextCost.gameObject:SetActive(false)
				TextCostNoIcon.gameObject:SetActive(true)

				TextCostNoIcon.text = _("Desc_Free")
			end
		end
	else
		GoDisCost:SetActive(true)
		TextCost.gameObject:SetActive(false)
		TextCostNoIcon.gameObject:SetActive(false)

		if info.data.CostType == 1 then
			ImgCost1.gameObject:SetActive(false)
			ImgCost2.gameObject:SetActive(false)

			TextCost1.text = "¥" .. costValue[1]
			TextCost2.text = "¥" .. tonumber(originValue[1]) / 100

			if tonumber(math.floor(costValue[1] * (discount / 100))) == 0 then
				isFree = true

				TextCostNoIcon.gameObject:SetActive(true)

				TextCostNoIcon.text = _("Desc_Free")
			end
		else
			TextCost1.text = costValue[2]
			TextCost2.text = originValue[2]

			local infoItem = ItemManager:Get(costValue[1])
			local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

			pathIcon = pathIcon .. "_S"

			local ref = UIUtil.SetImageOverrideSprite(ImgCost1, pathIcon)

			CellGood.DealWithRef(ref)

			ref = UIUtil.SetImageOverrideSprite(ImgCost2, pathIcon)

			CellGood.DealWithRef(ref)

			if tonumber(TextCost2.text) == 0 then
				ImgCost1.gameObject:SetActive(false)
				ImgCost2.gameObject:SetActive(false)

				isFree = true

				TextCostNoIcon.gameObject:SetActive(true)

				TextCostNoIcon.text = _("Desc_Free")
			end
		end
	end

	if GoNew then
		if isFree and info.pb.myCount <= 0 then
			isNew = true
		end

		GoNew:SetActive(isNew)
	end
end

function CellGood.SetItemCount(TextNum, info)
	local itemCount = #info.data.GoodsItemList

	if itemCount > 1 then
		TextNum.text = "x1"
	else
		TextNum.text = "x" .. info.data.GoodsItemList[1][2]
	end
end

function CellGood.SetSign(ImgSign, TextSign, info)
	if info.data.SignName == 0 then
		ImgSign:SetActive(false)
		TextSign.gameObject:SetActive(false)
	else
		ImgSign:SetActive(true)
		TextSign.gameObject:SetActive(true)

		if info.data.SignName == 1000011 then
			local discount = info.data.Discount
			local dis = discount / 10

			TextSign.text = dis .. Lang(info.data.SignName)
		else
			TextSign.text = Lang(info.data.SignName)
		end
	end
end
