-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSynthetize/PageItemSynthetize.lua

local InfoTeam = require("Info.InfoTeam")

eSynthetizeType = {
	From = 2,
	Synthetize = 1
}
PageItemSynthetize = class("PageItemSynthetize", UIPanel)

local lineIndexMax = 5
local effectPath

function PageItemSynthetize:ctor()
	PageItemSynthetize.base.ctor(self, "UI/PageSynthetize/PageItemSynthetize")
end

function PageItemSynthetize:Cache()
	PageItemSynthetize.base.Cache(self)
end

function PageItemSynthetize:PreLoad()
	self.PrefabCellAccess = ResourceMgr.LoadSync("UI/PageSynthetize/CellFrom")
end

function PageItemSynthetize:Purge()
	PageItemSynthetize.base.Purge(self)

	if self.UIScrollToolPanel then
		self.UIScrollToolPanel:Purge()

		self.UIScrollToolPanel = nil
	end

	Event.Instance:Fire(EventEnum.UpdateItemDataNotify)
end

function PageItemSynthetize:Close()
	PageItemSynthetize.base.Close(self)
end

function PageItemSynthetize:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickClose)
	self:AddListener(self.BtnSyn, self.OnPointDown, EventTriggerType.PointerDown)
	self:AddListener(self.BtnSyn, self.OnPointUp, EventTriggerType.PointerUp)
	self:AddListener(self.BtnSyn, self.OnPointerLongPress, EventTriggerType.PointerRepeat)
	self:AddClick(self.BtnChange, self.OnClickChange)

	for i = 1, 3 do
		self:AddClick(self.TreeItems[i].go, self.OnClickBaseItem)
	end

	for i = 1, 5 do
		self:AddClick(self.LineItems[i].go, self.OnClickLineItem)
	end

	Event.Instance:Add(EventEnum.EnterStage, self.DealWithEnterStage, self)
end

function PageItemSynthetize:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickClose)
	self:RemoveListener(self.BtnSyn, self.OnPointDown, EventTriggerType.PointerDown)
	self:RemoveListener(self.BtnSyn, self.OnPointUp, EventTriggerType.PointerUp)
	self:RemoveListener(self.BtnSyn, self.OnPointerLongPress, EventTriggerType.PointerRepeat)
	self:RemoveClick(self.BtnChange, self.OnClickChange)

	for i = 1, 3 do
		self:RemoveClick(self.TreeItems[i].go, self.OnClickBaseItem)
	end

	for i = 1, 5 do
		self:RemoveClick(self.LineItems[i].go, self.OnClickLineItem)
	end

	Event.Instance:Remove(EventEnum.EnterStage, self.DealWithEnterStage, self)
end

function PageItemSynthetize:OnEnter(vParam)
	self.vParam = vParam
	self.curInfo = vParam.itemInfo
	self.needItem = vParam.needItem
	self.synItemCount = 0
	self.Type = eSynthetizeType.Synthetize
	self.PanelSynthetize = self:GetChildGameObject("Panel/Synthetize/PanelSynthetize")
	self.PanelFrom = self:GetChildGameObject("Panel/Synthetize/PanelFrom")
	self.ItemName = self:GetChildComponent("Panel/Describe/ItemNameBg/ItemName", "Text")
	self.ItemDes = self:GetChildComponent("Panel/Describe/ItemDes/Text", "Text")
	self.BtnSyn = self:GetChildGameObject("Panel/Synthetize/PanelSynthetize/BtnSyn")
	self.Money = self:GetChildComponent("Panel/Synthetize/PanelSynthetize/Gold/Text", "Text")
	self.BtnClose = self:GetChildGameObject("Panel/Tital/BtnClose")
	self.NoFromTip = self:GetChildGameObject("Panel/Synthetize/PanelFrom/Text1")
	self.EffectRoot = self:GetChildGameObject("Panel")
	self.BtnChange = self:GetChildGameObject("Panel/Describe/Button")
	self.BtnChangeText = self:GetChildComponent("Panel/Describe/Button/Text", "Text")
	self.LineItems = {}

	for i = 1, 5 do
		local lineItem = {}

		lineItem.go = self:GetChildGameObject("Panel/Synthetize/ItemLine/" .. i)

		local gItem = GOUtil.FindChildGameObject(lineItem.go, "ToItem")
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)

		item.noClick = true
		lineItem.item = item
		lineItem.Arrow = GOUtil.FindChildGameObject(lineItem.go, "Arrow")
		lineItem.ArrowNext = GOUtil.FindChildGameObject(lineItem.go, "ArrowNext")
		lineItem.Select = GOUtil.FindChildGameObject(lineItem.go, "CurBox")

		table.insert(self.LineItems, lineItem)
	end

	self.TreeItems = {}

	for i = 1, 3 do
		local treeItem = {}

		treeItem.go = self:GetChildGameObject("Panel/Synthetize/PanelSynthetize/FromItem" .. i)

		local gItem = GOUtil.FindChildGameObject(treeItem.go, "CellItem")
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)

		item.noClick = true
		treeItem.item = item
		treeItem.Add = GOUtil.FindChildGameObject(treeItem.go, "Add")
		treeItem.BgNeed = GOUtil.FindChildComponent(treeItem.go, "TxtNeed", "Text")
		treeItem.notLine = self:GetChildGameObject("Panel/Synthetize/PanelSynthetize/Line" .. i)
		treeItem.Line = self:GetChildGameObject("Panel/Synthetize/PanelSynthetize/Line" .. i .. "/Image")

		table.insert(self.TreeItems, treeItem)
	end

	local CurItemRightObj = self:GetChildGameObject("Panel/Synthetize/PanelSynthetize/ToItem")

	self.CurItemRight = CellItem(CurItemRightObj)
	self.CurItemRight.noClick = true

	self.CurItemRight:InitItemByRoot(CurItemRightObj)

	local CurItemLeftObj = self:GetChildGameObject("Panel/Describe/CellItem")

	self.CurItemLeft = CellItem(CurItemLeftObj)
	self.CurItemLeft.noClick = true

	self.CurItemLeft:InitItemByRoot(CurItemLeftObj)
	self:UILocalText()

	self.lineItemInfos = {}

	if ItemManager.synLineItems then
		for i, v in ipairs(ItemManager.synLineItems) do
			table.insert(self.lineItemInfos, ItemManager:Get(v))
		end

		ItemManager.synLineItems = nil
	else
		table.insert(self.lineItemInfos, self.curInfo)
	end

	GOUtil.SetFont(self.ItemDes, UIMgr.JPFonts.W5)
	self:InitScrollView()
	self:UpdateDes(self.curInfo)
	self:UpdateLine()
end

function PageItemSynthetize:UILocalText()
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Synthetize/PanelSynthetize/BtnSyn/Text", "Text")
	TextAuto.text = Lang(12008)
	TextAuto = self:GetChildComponent("Panel/Tital/Text", "Text")
	TextAuto.text = _("Desc_ItemSynthetize")
	TextAuto = self:GetChildComponent("Panel/Synthetize/PanelSynthetize/Tip", "Text")
	TextAuto.text = _("Desc_SynLongPressTip")
	TextAuto = self:GetChildComponent("Panel/Synthetize/PanelFrom/Bg/Text", "Text")
	TextAuto.text = _("Desc_ItemFrom")
	TextAuto = self:GetChildComponent("Panel/Synthetize/PanelFrom/Text1", "Text")
	TextAuto.text = _("Desc_ItemNoFrom")
end

function PageItemSynthetize:UpdateDes(info)
	local item1, item2 = info:GetRequireItem()
	local strName, strDesc = info:GetNameAndDesc()

	self.ItemName.text = strName
	self.ItemDes.text = strDesc

	self.CurItemLeft:UpdateNoNumType(info)

	if item1 == nil and item2 == nil or self.Type == eSynthetizeType.From and #self.curInfo.data.FromWhere ~= 0 then
		self.Type = eSynthetizeType.From

		self.PanelFrom:SetActive(true)
		self.PanelSynthetize:SetActive(false)
		self:UpdateScrollView()
	else
		self.Type = eSynthetizeType.Synthetize

		self.PanelFrom:SetActive(false)
		self.PanelSynthetize:SetActive(true)
		self:UpdateTree()
	end

	SetActiveFunc(self.BtnChange, self.Type == eSynthetizeType.From and (item1 ~= nil or item2 ~= nil) or self.Type == eSynthetizeType.Synthetize and #self.curInfo.data.FromWhere ~= 0)
end

function PageItemSynthetize:UpdateTree()
	self.BtnChangeText.text = Lang(5000056)

	local item1, item2, money = self.curInfo:GetRequireItem()

	local function SetItemData(itemInfo, itemObj, needCount)
		if itemInfo:GetCurResNum() >= needCount + needCount * self.synItemCount then
			itemObj.notLine:SetActive(true)
			itemObj.Line:SetActive(true)
			itemObj.Add:SetActive(false)
			itemObj.item:UpdateWithNumType(itemInfo)

			local holdNum = itemInfo:GetCurResNum()
			local usedNum = needCount * self.synItemCount

			itemObj.item:UpdateNumOnly(holdNum - usedNum, true)

			itemObj.BgNeed.text = string.format(_("Desc_Need") .. "：" .. "%d", needCount)
		else
			itemObj.notLine:SetActive(true)
			itemObj.Line:SetActive(false)
			itemObj.Add:SetActive(true)
			itemObj.item:UpdateWithNumType(itemInfo)

			local holdNum = itemInfo:GetCurResNum()
			local usedNum = needCount * self.synItemCount

			itemObj.item:UpdateNumOnly(holdNum - usedNum, true)

			itemObj.BgNeed.text = string.format(_("Desc_Need") .. "：" .. "<color=red>%d</color>", needCount)
		end
	end

	self.CurItemRight:UpdateWithNumType(self.curInfo)
	self.CurItemRight:UpdateNumOnly(self.curInfo:GetCurResNum() + self.synItemCount, true)

	if item2 == nil then
		self.TreeItems[1].go:SetActive(false)
		self.TreeItems[1].notLine:SetActive(false)
		self.TreeItems[2].go:SetActive(false)
		self.TreeItems[2].notLine:SetActive(false)
		self.TreeItems[3].go:SetActive(true)
		SetItemData(item1.itemInfo, self.TreeItems[3], item1.count)

		effectPath = "Fx/UI/Eff_Ui_PanelEquipEnchant/Eff_Ui_PanelEquipEnchant/FX_UI_Synthesis/FX_UI_Synthesis_1"
	else
		self.TreeItems[1].go:SetActive(true)
		SetItemData(item1.itemInfo, self.TreeItems[1], item1.count)
		self.TreeItems[2].go:SetActive(true)
		SetItemData(item2.itemInfo, self.TreeItems[2], item2.count)
		self.TreeItems[3].go:SetActive(false)
		self.TreeItems[3].notLine:SetActive(false)

		effectPath = "Fx/UI/Eff_Ui_PanelEquipEnchant/Eff_Ui_PanelEquipEnchant/FX_UI_Synthesis/FX_UI_Synthesis_2"
	end

	self.Money.text = money
end

function PageItemSynthetize:UpdateLine()
	local firstIndex = 0

	if #self.lineItemInfos > lineIndexMax then
		firstIndex = #self.lineItemInfos - lineIndexMax
	end

	for i = 1, 5 do
		if self.lineItemInfos[firstIndex + i] ~= nil then
			self.LineItems[i].go:SetActive(true)
			self.LineItems[i].item:UpdateNoNumType(self.lineItemInfos[firstIndex + i])

			if firstIndex + i ~= #self.lineItemInfos and i ~= lineIndexMax then
				self.LineItems[i].Arrow:SetActive(false)
				self.LineItems[i].ArrowNext:SetActive(true)
				self.LineItems[i].Select:SetActive(false)
			else
				self.LineItems[i].Arrow:SetActive(true)
				self.LineItems[i].ArrowNext:SetActive(false)
				self.LineItems[i].Select:SetActive(true)
			end
		else
			self.LineItems[i].go:SetActive(false)
		end
	end
end

function PageItemSynthetize:OnClickBaseItem(data)
	local index = string.gsub(data.pointerPress.gameObject.name, "FromItem", "")
	local item1, item2 = self.curInfo:GetRequireItem()

	if tonumber(index) == 2 then
		self.curInfo = item2.itemInfo
		self.curItemNeedCount = item2.count
	else
		self.curInfo = item1.itemInfo
		self.curItemNeedCount = item1.count
	end

	table.insert(self.lineItemInfos, self.curInfo)
	self:UpdateDes(self.curInfo)
	self:UpdateLine()
end

function PageItemSynthetize:OnClickLineItem(data)
	local index = data.pointerPress.gameObject.name

	if #self.lineItemInfos > lineIndexMax then
		index = #self.lineItemInfos - (lineIndexMax - tonumber(index))
	else
		index = tonumber(index)
	end

	if index == #self.lineItemInfos or index == lineIndexMax then
		return
	end

	self.curInfo = self.lineItemInfos[index]

	local lineListCount = #self.lineItemInfos

	for i = index + 1, lineListCount do
		table.remove(self.lineItemInfos)
	end

	self:UpdateDes(self.curInfo)
	self:UpdateLine()
end

function PageItemSynthetize:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/Synthetize/PanelFrom/ScrollArea")

	self.ScrollArea = ScrollArea
	self.content = self:GetChildComponent("Panel/Synthetize/PanelFrom/ScrollArea/Content", "Transform")
	self.UIScrollToolPanel = UIScrollTool()
end

function PageItemSynthetize:UpdateScrollView()
	self.listFromWhere = self.curInfo.data.FromWhere
	self.BtnChangeText.text = _("Item_Synthetize")

	if #self.listFromWhere == 0 then
		self.NoFromTip:SetActive(true)
	else
		self.NoFromTip:SetActive(false)
	end

	local function AddClick(item)
		self:AddCellClick(item)
	end

	local function CellUpdate(item, index)
		item:Create()

		item.UIRootObject.name = index

		self:UpdateCell(item, index)
	end

	self.UIScrollToolPanel:InitList(self.ScrollArea, self.content, #self.listFromWhere, self.PrefabCellAccess, CellAccess, self, false, AddClick, CellUpdate)
	self:SetScrollViewAnchoredPosition()
end

function PageItemSynthetize:SetScrollViewAnchoredPosition()
	local index = 1

	for i = 1, #self.listFromWhere do
		local data = self.listFromWhere[i]
		local isOpen = DlgItemTip.IsOpen(data)

		if not isOpen then
			index = i - 2

			break
		elseif isOpen and i == #self.listFromWhere then
			index = i - 2

			break
		end
	end

	if index < 0 then
		index = 0
	end

	local pos = Vector2(0, index * 123)

	self.UIScrollToolPanel:SetContentPosImmediate(pos or Vector2.zero, self.listFromWhere)
end

function PageItemSynthetize:UpdateCell(item, index)
	item.Index = index

	local data = self.listFromWhere[index]
	local fromType = data[1]
	local fromIndex = 1
	local fromIndex2

	if data[2] and data[2] > 0 then
		fromIndex = data[2]

		if fromIndex == 0 then
			fromIndex = 1
		end
	end

	if fromType == 11 or fromType == 16 then
		fromIndex = 1
	end

	if fromType == 18 then
		if data[3] then
			fromIndex = 1
		else
			fromIndex = 0
		end
	elseif data[3] and data[3] > 0 and fromType ~= 10 then
		fromIndex2 = data[3]
	end

	local txtAccess = item.Text

	txtAccess.text = _("Item_From_" .. fromType .. "_" .. fromIndex)

	if fromIndex2 then
		txtAccess.text = _("Item_From_" .. fromType .. "_" .. fromIndex .. "_" .. fromIndex2)
	end

	if (fromType == 8 or fromType == 22) and fromIndex > 1 then
		local id = data[3]
		local infoStage = ChapterMgr:GetStage(id)

		if infoStage and infoStage.data then
			local _, cIdx, sIdx = ChapterMgr:GetChapterByStageID(id)

			txtAccess.text = cIdx .. "-" .. sIdx .. " " .. infoStage:GetName()
		end

		local star = infoStage.pb.stars

		for i = 1, 3 do
			item["Star" .. i]:SetActive(star[i] == 1)
		end

		item.goStar:SetActive(true)
		item.img_type.gameObject:SetActive(true)
		item.img_line.gameObject:SetActive(true)

		item.Text.fontSize = 28

		GOUtil.SetTransformLocalPosition(item.Text.gameObject, -320, 23, 0)

		if infoStage.data.ActType == 15 then
			UIUtil.SetImageSprite(item.img_type, "UI/Common/DlgItemAccess/AtlasItemAccess/BG_diff_line_02")

			item.tex_type.text = _("Synthetize_Hard")
		else
			UIUtil.SetImageSprite(item.img_type, "UI/Common/DlgItemAccess/AtlasItemAccess/BG_diff_line_01")

			item.tex_type.text = _("Synthetize_Normal")
		end
	else
		item.goStar:SetActive(false)
		item.img_type.gameObject:SetActive(false)
		item.img_line.gameObject:SetActive(false)
		GOUtil.SetTransformLocalPosition(item.Text.gameObject, -320, 0, 0)

		item.Text.fontSize = 36
	end

	local isOpen = DlgItemTip.IsOpen(data)

	item.GoGray:SetActive(not isOpen)
	item.Button:SetActive(isOpen)

	if not isOpen then
		UIUtil.SetImageSprite(item.BG, "UI/Common/DlgItemAccess/AtlasItemAccess/BG_shortcut_frame_02", self)
		UIUtil.SetImageSprite(item.img_line, "UI/Common/DlgItemAccess/AtlasItemAccess/BG_shortcut_line_02", self)
	else
		UIUtil.SetImageSprite(item.BG, "UI/Common/DlgItemAccess/AtlasItemAccess/BG_shortcut_frame_01", self)
		UIUtil.SetImageSprite(item.img_line, "UI/Common/DlgItemAccess/AtlasItemAccess/BG_shortcut_line_01", self)
	end
end

function PageItemSynthetize:AddCellClick(item)
	self:AddClick(item.Button, self.OnClickedCell)
	self:AddClick(item.GoGray, self.OnClickedCellGoGray)
end

function PageItemSynthetize:OnClickedCellGoGray()
	UIMgr.ShowMsg(_("Desc_Not_Open"))
end

function PageItemSynthetize:OnClickedCell(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)
	local fromWhere = self.listFromWhere[index]

	if fromWhere[1] ~= 8 then
		ItemManager.synLineItems = nil
	end

	local needItem

	if self.needItem and self.curInfo.id == self.needItem.id then
		needItem = self.needItem
	else
		needItem = {
			id = self.curInfo.id,
			needNum = self.curItemNeedCount
		}
	end

	DlgItemTip.GoToFrom(fromWhere, true, nil, needItem)
end

function PageItemSynthetize:DealWithEnterStage()
	ItemManager.synLineItems = {}

	for i, v in ipairs(self.lineItemInfos) do
		table.insert(ItemManager.synLineItems, v.id)
	end

	ItemManager.itemSynReturnData = {
		roleId = UIMgr.GetCurPanel().infoRole.id,
		slotIdx = UIMgr.GetCurPanel().slotIdx,
		openTag = UIMgr.GetCurPanel().openTag
	}

	if self.needItem and self.curInfo.id == self.needItem.id then
		ItemManager.needItem = self.needItem
	else
		ItemManager.needItem = {}
		ItemManager.needItem.id = self.curInfo.id
		ItemManager.needItem.needNum = self.curItemNeedCount
	end
end

function PageItemSynthetize:OnClickClose()
	ItemManager.synLineItems = nil
	ItemManager.needItem = nil

	self:Close()
end

function PageItemSynthetize:OnPointDown()
	self.listSimCost = {}
	self.IsLongPress = false
	self.longPressDisable = false
end

function PageItemSynthetize:OnPointUp()
	if not self.IsLongPress then
		local item1, item2, money = self.curInfo:GetRequireItem()

		if item1.itemInfo:GetCurResNum() >= item1.count and money <= PlayerInst:GetGold() and (item2 == nil or item2.itemInfo:GetCurResNum() >= item2.count) then
			self.synItemCount = 1

			EffectMgr:Alloc(effectPath, self.EffectRoot, true, 2)
		else
			if money > PlayerInst:GetGold() then
				UIMgr.ShowMsg(Lang(12196))
			else
				UIMgr.ShowMsg(Lang(42180))
			end

			return
		end

		self:OnClickedSynthetize()
	elseif self.synItemCount ~= 0 then
		if not self.isPlayEff then
			EffectMgr:Alloc(effectPath, self.EffectRoot, true, 2)
		end

		self:OnClickedSynthetize()
	end

	self.isPlayEff = false
end

function PageItemSynthetize:OnPointerLongPress(data)
	if self.longPressDisable then
		return
	end

	self.IsLongPress = true

	self:SimulateCostItem()
end

function PageItemSynthetize:SimulateCostItem()
	local item1, item2, money = self.curInfo:GetRequireItem()

	if item1.itemInfo:GetCurResNum() >= item1.count * (self.synItemCount + 1) and PlayerInst:GetGold() >= money * (self.synItemCount + 1) and (item2 == nil or item2.itemInfo:GetCurResNum() >= item2.count * (self.synItemCount + 1)) then
		self.synItemCount = self.synItemCount + 1
	else
		if self.synItemCount > 0 then
			self.isPlayEff = true

			EffectMgr:Alloc(effectPath, self.EffectRoot, true, 2)
		end

		self.longPressDisable = true

		return
	end

	EffectMgr:Alloc(effectPath .. "a", self.EffectRoot, true, 2)
	self:UpdateTree()
	self:UpdateAssetInfo()
end

function PageItemSynthetize:UpdateAssetInfo()
	local item1, item2, money = self.curInfo:GetRequireItem()
	local holdNum = PlayerInst:GetGold()
	local usedNum = money * self.synItemCount
	local leftNum = holdNum - usedNum
	local panel = UIMgr.GetCurPanel()

	if panel ~= nil and panel.DlgAssetsInfo ~= nil then
		panel.DlgAssetsInfo:UpdateAssetShowNum(501, leftNum)
	end
end

function PageItemSynthetize:OnClickedSynthetize()
	local function callback(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		self.synItemCount = 0

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdateTree()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			self:UpdateTree()
			Event.Instance:Fire(EventEnum.UpdatePlayerInfo)
		end

		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	NetManager:RequestSynthetize(self.curInfo.id, self.synItemCount, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageItemSynthetize:OnClickChange()
	local item1, item2 = self.curInfo:GetRequireItem()

	if self.Type == eSynthetizeType.From then
		self.Type = eSynthetizeType.Synthetize
	else
		self.Type = eSynthetizeType.From
	end

	if item1 == nil and item2 == nil or self.Type == eSynthetizeType.From and #self.curInfo.data.FromWhere ~= 0 then
		self.Type = eSynthetizeType.From

		self.PanelFrom:SetActive(true)
		self.PanelSynthetize:SetActive(false)
		self:UpdateScrollView()
	else
		self.Type = eSynthetizeType.Synthetize

		self.PanelFrom:SetActive(false)
		self.PanelSynthetize:SetActive(true)
		self:UpdateTree()
	end

	SetActiveFunc(self.BtnChange, self.Type == eSynthetizeType.From and (item1 ~= nil or item2 ~= nil) or self.Type == eSynthetizeType.Synthetize and #self.curInfo.data.FromWhere ~= 0)
end
