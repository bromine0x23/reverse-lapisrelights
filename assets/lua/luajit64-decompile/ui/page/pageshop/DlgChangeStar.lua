-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/DlgChangeStar.lua

DlgChangeStar = class("DlgChangeStar", UIPanel)

function DlgChangeStar:ctor()
	self.UIPrefabPath = "UI/PageShop/DlgChangeStar"
end

function DlgChangeStar:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function DlgChangeStar:Purge()
	DlgChangeStar.base.Purge(self)

	if self.UIScrollToolStore then
		self.UIScrollToolStore:Purge()
	end

	if self.UIScrollToolUsed then
		self.UIScrollToolUsed:Purge()
	end
end

function DlgChangeStar:OnRegisterEvent()
	self:AddClick(self.ButtonExit, self.OnClickedButtonQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonExchange, self.OnClickedButtonExchange)
	self:AddClick(self.Button1, self.OnClickedButtonAdjust)
	self:AddClick(self.Button2, self.OnClickedButtonAdjust)
	self:AddClick(self.ButtonUp, self.OnClickedButtonAdjust)
	self:AddClick(self.ButtonAutoAdd, self.OnClickedButtonAutoAdd)
end

function DlgChangeStar:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonExit, self.OnClickedButtonQuit)
	self:RemoveClick(self.ButtonExchange, self.OnClickedButtonExchange)
	self:RemoveClick(self.Button1, self.OnClickedButtonAdjust)
	self:RemoveClick(self.Button2, self.OnClickedButtonAdjust)
	self:RemoveClick(self.ButtonUp, self.OnClickedButtonAdjust)
	self:RemoveClick(self.ButtonAutoAdd, self.OnClickedButtonAutoAdd)
end

function DlgChangeStar:OnEnter(vParam)
	self.infoProduct = vParam
	self.ButtonExit = self:GetChildGameObject("Main/ButtonExit")
	self.ButtonExchange = self:GetChildGameObject("Main/Button")
	self.ButtonAutoAdd = self:GetChildGameObject("Main/ButtonAutonAdd")
	self.ImgExchange = self:GetChildComponent("Main/Button", "Image")
	self.ImgAutoAdd = self:GetChildComponent("Main/ButtonAutonAdd", "Image")
	self.Button1 = self:GetChildGameObject("Main/PanelAjust/Button1")
	self.Button2 = self:GetChildGameObject("Main/PanelAjust/Button2")
	self.ButtonUp = self:GetChildGameObject("Main/PanelAjust/ButtonUp")
	self.InputField = self:GetChildComponent("Main/PanelAjust/InputField", "InputField")
	self.ImageBar = self:GetChildComponent("Main/PanelAjust/Bar/Image", "Image")
	self.TextBar = self:GetChildComponent("Main/PanelAjust/Bar/Text", "Text")

	local info = self.infoProduct
	local infoItem = ItemManager:Get(info.data.CostValue[1])
	local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

	UIUtil.SetImageOverrideSprite(self.ImageBar, pathIcon, self)

	local TextName = self:GetChildComponent("Main/bg_title/Text", "Text")

	TextName.text = Lang(info.data.Name)
	self.TextLimit = self:GetChildGameObject("Main/ImageLimit")

	CellGood.SetLimitBuyTime(self.TextLimit, info)

	self.TextNum = self:GetChildComponent("Main/PanelAjust/TextNum", "Text")

	CellGood.SetItemCount(self.TextNum, info)

	self.Icon = self:GetChildComponent("Main/PanelAjust/Icon", "Image")

	UIUtil.SetImageOverrideSprite(self.Icon, info.data.Icon, self)

	local ImgRank1 = self:GetChildComponent("Main/PanelAjust/Rank1", "Image")
	local ImgRank2 = self:GetChildComponent("Main/PanelAjust/Rank2", "Image")

	if #info.data.GoodsItemList == 1 then
		local id = info.data.GoodsItemList[1][1]

		if id then
			GOUtil.SetActive(ImgRank1, info.data.ShowRank == 1)
			GOUtil.SetActive(ImgRank2, info.data.ShowRank == 1)

			local infoItem = ItemManager:Get(id)

			if info.data.ShowRank == 1 then
				ItemManager:SetItemRank(infoItem, ImgRank1, ImgRank2, self)
			end
		else
			GOUtil.SetActive(ImgRank1, false)
			GOUtil.SetActive(ImgRank2, false)
		end
	end

	self.ImgSign = self:GetChildGameObject("Main/PanelAjust/Sign")
	self.TextSign = self:GetChildComponent("Main/PanelAjust/Sign/Text", "Text")

	CellGood.SetSign(self.ImgSign, self.TextSign, info)

	local Text1 = self:GetChildComponent("Main/PanelAjust/Text1", "Text")
	local Text2 = self:GetChildComponent("Main/PanelAjust/Text2", "Text")

	Text1.text = Lang(info.data.Name)
	Text2.text = Lang(info.data.Info)

	local Text_num = self:GetChildComponent("Main/PanelAjust/Text_num/Text", "Text")
	local Text = self:GetChildComponent("Main/Button/Text", "Text")

	Text.text = _("Desc_ec")
	self:GetChildComponent("Main/bg_title/Text (1)", "Text").text = _("Desc_DealDetail")
	self:GetChildComponent("Main/PanelAjust/Text_num", "Text").text = _("Desc_OwnNum")
	self:GetChildComponent("Main/PanelAjust/Image2/Image/Text", "Text").text = _("Desc_DealNum") .. "1/1"
	self:GetChildComponent("Main/Info/Text", "Text").text = _("Desc_ClickOnAddItem")
	self:GetChildComponent("Main/Button/Text", "Text").text = _("Desc_ec")
	self.infoText = self:GetChildGameObject("Main/Info/Text")
	self.buyNum = 1
	self.adjustNum = self.buyNum

	local level = infoItem.data.Level

	self.listStar = {}

	local listAll = ItemManager:GetStarList(level)

	for i = 1, #listAll do
		local info = listAll[i]
		local infoItem = ItemManager:GetValueItem(info.id, info:GetCurResNum())

		table.insert(self.listStar, infoItem)
	end

	Text_num.text = #self.listStar .. ""
	self.listUsed = {}

	self:UpdateCost(self.buyNum)
	self:InitScrollViewStore()
	self:InitScrollViewUsed()
end

function DlgChangeStar:OnClickedButtonQuit()
	self:Close()
end

function DlgChangeStar:OnClickedButtonAdjust(data)
	local go = data.pointerPress
	local info = self.infoProduct
	local discount = info.data.Discount
	local costValue = info.data.CostValue
	local infoItem = ItemManager:Get(costValue[1])
	local valueDiscount = math.floor(costValue[2] * (discount / 100))
	local curRes = infoItem:GetCurResNum()
	local maxNum = math.floor(curRes / valueDiscount)
	local limitBuyTime = info.data.StoreNumber
	local config = GetConfigArgInt("GoodsLimitBuyCount")

	if limitBuyTime == -1 or config < limitBuyTime then
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

function DlgChangeStar:UpdateCost(num)
	local info = self.infoProduct
	local discount = info.data.Discount
	local costValue = info.data.CostValue
	local valueOrigin = costValue[2] * num
	local valueDiscount = math.floor(costValue[2] * (discount / 100)) * num
	local count = 0

	for i = 1, #self.listUsed do
		local infoItem = self.listUsed[i]

		count = count + infoItem.pb.num
	end

	self.TextBar.text = count .. "/" .. valueDiscount

	local gray = TenaryOp(count == valueDiscount, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgExchange, gray))

	gray = TenaryOp(#self.listStar ~= 0, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgAutoAdd, gray))
end

function DlgChangeStar:GetAlreadyAddCount()
	local num = self.buyNum
	local info = self.infoProduct
	local discount = info.data.Discount
	local costValue = info.data.CostValue
	local valueOrigin = costValue[2] * num
	local valueDiscount = math.floor(costValue[2] * (discount / 100)) * num
	local count = 0

	for i = 1, #self.listUsed do
		local infoItem = self.listUsed[i]

		count = count + infoItem.pb.num
	end

	return count, valueDiscount
end

function DlgChangeStar:CheckLimit()
	local count, valueDiscount = self:GetAlreadyAddCount()

	if valueDiscount < count + 1 then
		return true
	end

	return false
end

function DlgChangeStar:InitScrollViewStore()
	local scrollArea = self:GetChildGameObject("Main/ScrollAreaStore")
	local content = self:GetChildComponent("Main/ScrollAreaStore/Content", "Transform")
	local count = #self.listStar

	self.UIScrollToolStore = UIScrollTool()

	self.UIScrollToolStore:InitList(scrollArea, content, count, self.PrefabCell, CellItem, self, false)
end

function DlgChangeStar:UpdateCell(item, index)
	local info = self.listStar[index]

	item.Index = index
	item.noClick = true

	GOUtil.SetTransformLocalScale(item.UIRootObject, 1.2)
	item:UpdateWithNumType(info, false)
end

function DlgChangeStar:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function DlgChangeStar:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollToolStore.ItemRoot2ItemDict:GetValue(go)
	local type = 1

	if info == nil then
		info = self.UIScrollToolUsed.ItemRoot2ItemDict:GetValue(go)
		type = 2
	end

	local index = info.Item.Index

	if type == 1 then
		if self:CheckLimit() then
			UIMgr.ShowMsg(_("Desc_ExchangeGood_Limit"))
		else
			self:AdjustSoul(self.listStar, self.listUsed, index)
		end
	else
		self:AdjustSoul(self.listUsed, self.listStar, index)
	end

	self.UIScrollToolStore:UpdateListDataKeepPos(self.listStar)
	self.UIScrollToolUsed:UpdateListDataKeepPos(self.listUsed)
	self:UpdateCost(self.buyNum)
	SetActiveFunc(self.infoText, #self.listUsed == 0)
end

function DlgChangeStar:AdjustSoul(list1, list2, index)
	local infoSrc = list1[index]

	if infoSrc.pb.num - 1 <= 0 then
		table.remove(list1, index)
	else
		infoSrc.pb.num = infoSrc.pb.num - 1
	end

	local hasItem = false

	for i = 1, #list2 do
		local infoTemp = list2[i]

		if infoTemp.id == infoSrc.id then
			hasItem = true
			infoTemp.pb.num = infoTemp.pb.num + 1
		end
	end

	if not hasItem then
		local infoItem = ItemManager:GetValueItem(infoSrc.id, 1)

		table.insert(list2, infoItem)
	end
end

function DlgChangeStar:InitScrollViewUsed()
	local scrollArea = self:GetChildGameObject("Main/ScrollAreaUsed")
	local content = self:GetChildComponent("Main/ScrollAreaUsed/Content", "Transform")
	local count = #self.listUsed

	local function UpdateCell(item, index)
		local info = self.listUsed[index]

		item.noClick = true
		item.Index = index

		GOUtil.SetTransformLocalScale(item.UIRootObject, 0.8)
		item:UpdateWithNumType(info, false)
	end

	local function AddCellClick(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	self.UIScrollToolUsed = UIScrollTool()

	self.UIScrollToolUsed:InitList(scrollArea, content, count, self.PrefabCell, CellItem, self, true, AddCellClick, UpdateCell)
	SetActiveFunc(self.infoText, #self.listUsed == 0)
end

function DlgChangeStar:OnClickedButtonExchange()
	local info = self.infoProduct
	local extra = ""

	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			SoundMgr.Play(PATH_SFX_UI_SHOP_BUYSUCCESS)
			self:Close()
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	local listData = {}

	for i = 1, #self.listUsed do
		local info = self.listUsed[i]
		local id = info.data.Value
		local num = info:GetNum()

		table.insert(listData, id)
		table.insert(listData, num)
	end

	NetEncapManager:RequestPurchasePruduct(info.id, self.buyNum, extra, listData, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgChangeStar:OnClickedButtonAutoAdd()
	if #self.listStar == 0 then
		UIMgr.ShowMsg(_("P31_Response_8"))

		return
	end

	local count, valueDiscount = self:GetAlreadyAddCount()

	for i = 1, #self.listStar do
		if self.listStar[i].pb.num < valueDiscount - count then
			count = count + self.listStar[i].pb.num

			local hasItem = false

			for j = 1, #self.listUsed do
				local infoTemp = self.listUsed[j]

				if infoTemp.id == self.listStar[i].id then
					hasItem = true
					infoTemp.pb.num = infoTemp.pb.num + self.listStar[i].pb.num
				end
			end

			if not hasItem then
				local infoItem = ItemManager:GetValueItem(self.listStar[i].id, self.listStar[i].pb.num)

				table.insert(self.listUsed, infoItem)
			end

			self.listStar[i].pb.num = 0
		else
			local hasItem = false

			for j = 1, #self.listUsed do
				local infoTemp = self.listUsed[j]

				if infoTemp.id == self.listStar[i].id then
					hasItem = true
					infoTemp.pb.num = infoTemp.pb.num + (valueDiscount - count)
				end
			end

			if not hasItem then
				local infoItem = ItemManager:GetValueItem(self.listStar[i].id, valueDiscount - count)

				table.insert(self.listUsed, infoItem)
			end

			self.listStar[i].pb.num = self.listStar[i].pb.num - (valueDiscount - count)
			count = valueDiscount

			break
		end
	end

	SetActiveFunc(self.infoText, #self.listUsed == 0)

	for i = #self.listUsed, 1, -1 do
		if self.listUsed[i].pb.num == 0 then
			table.remove(self.listUsed, i)
		end
	end

	for i = #self.listStar, 1, -1 do
		if self.listStar[i].pb.num == 0 then
			table.remove(self.listStar, i)
		end
	end

	self.UIScrollToolStore:UpdateListData(self.listStar)
	self.UIScrollToolUsed:UpdateListData(self.listUsed)
	self:UpdateCost(self.buyNum)
end
