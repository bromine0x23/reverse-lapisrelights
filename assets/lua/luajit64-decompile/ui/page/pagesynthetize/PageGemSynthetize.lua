-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSynthetize/PageGemSynthetize.lua

PageGemSynthetize = class("PageGemSynthetize", UIPanel)

local lineIndexMax = 8

function PageGemSynthetize:ctor()
	PageGemSynthetize.base.ctor(self, "UI/PageSynthetize/PageGemSynthetize")
end

function PageGemSynthetize:Cache()
	PageGemSynthetize.base.Cache(self)
end

function PageGemSynthetize:PreLoad()
	return
end

function PageGemSynthetize:Purge()
	PageGemSynthetize.base.Purge(self)
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_PanelEquipEnchant/Eff_Ui_PanelEquipEnchant/FX_UI_Synthesis/FX_UI_Synthesis_3")
end

function PageGemSynthetize:Close()
	PageGemSynthetize.base.Close(self)
end

function PageGemSynthetize:OnRegisterEvent()
	self:AddClick(self.Button1, self.OnClickedButtonAdjust)
	self:AddClick(self.Button2, self.OnClickedButtonAdjust)
	self:AddClick(self.ButtonUp, self.OnClickedButtonAdjust)
	self:AddClick(self.targetItemObj, self.OnClickTargetItem)
	self:AddClick(self.BtnSyn, self.OnClickedSynthetize)
	self:AddClick(self.BtnClose, self.Close)

	for i = 1, 8 do
		self:AddClick(self.LineItems[i].go, self.OnClickLineItem)
	end
end

function PageGemSynthetize:OnUnRegisterEvent()
	self:RemoveClick(self.Button1, self.OnClickedButtonAdjust)
	self:RemoveClick(self.Button2, self.OnClickedButtonAdjust)
	self:RemoveClick(self.ButtonUp, self.OnClickedButtonAdjust)
	self:RemoveClick(self.targetItemObj, self.OnClickTargetItem)
	self:RemoveClick(self.BtnSyn, self.OnClickedSynthetize)
	self:RemoveClick(self.BtnClose, self.Close)

	for i = 1, 8 do
		self:RemoveClick(self.LineItems[i].go, self.OnClickLineItem)
	end
end

function PageGemSynthetize:OnEnter(vParam)
	self.vParam = vParam
	self.fromItemObj = self:GetChildGameObject("Panel/FromItem/CellItem")
	self.FromItem = CellItem(self.fromItemObj)
	self.FromItem.noClick = true

	self.FromItem:InitItemByRoot(self.fromItemObj)

	self.FromItem.noClick = true
	self.FromItemName = self:GetChildComponent("Panel/FromItem/ItemName", "Text")
	self.FromTxtNeed = self:GetChildComponent("Panel/FromItem/TxtNeed", "Text")
	self.targetItemObj = self:GetChildGameObject("Panel/ToItem/CellItem")
	self.TargetItem = CellItem(self.targetItemObj)
	self.TargetItem.noClick = true

	self.TargetItem:InitItemByRoot(self.targetItemObj)

	self.TargetItem.noClick = true
	self.TargetItemName = self:GetChildComponent("Panel/ToItem/ItemName", "Text")
	self.TargetTxtNeed = self:GetChildComponent("Panel/ToItem/TxtNeed", "Text")
	self.Money = self:GetChildComponent("Panel/Gold/Text", "Text")
	self.BtnSyn = self:GetChildGameObject("Panel/BtnSyn")
	self.InputField = self:GetChildComponent("Panel/Count/InputField", "InputField")
	self.BtnClose = self:GetChildGameObject("Panel/Tital/BtnClose")
	self.EngouhArrow = self:GetChildGameObject("Panel/Arrow/Arrow")
	self.NotEnArrow = self:GetChildGameObject("Panel/Arrow")
	self.EffectRoot = self:GetChildGameObject("Panel")

	local function wrap_cb(str)
		self:OnInputFieldChange(str)
	end

	self.InputField.onValueChanged:AddListener(wrap_cb)

	self.LineItems = {}

	for i = 1, 8 do
		local lineItem = {}

		lineItem.go = self:GetChildGameObject("Panel/ItemLine/" .. i)

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

	self.Button1 = self:GetChildGameObject("Panel/Count/Button1")
	self.Button2 = self:GetChildGameObject("Panel/Count/Button2")
	self.ButtonUp = self:GetChildGameObject("Panel/Count/ButtonUp")
	self.gemList = ItemManager:GetItemListByType("I_GEM")
	self.infoItem = self.vParam.itemInfo
	self.adjustNum = 1
	self.lineItemInfos = {}

	local firstLineItem = self.infoItem
	local notBase = true

	while notBase do
		table.insert(self.lineItemInfos, 1, firstLineItem)

		if firstLineItem:GetRequireItem() == nil then
			notBase = false
		else
			firstLineItem = firstLineItem:GetRequireItem().itemInfo
		end
	end

	self:UpdateItem()
	self:UpdateItemNeedCount()
	self:UpdateLine()
end

function PageGemSynthetize:UILocalText()
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Tital/Text", "Text")
	TextAuto.text = _("Decs_GemSynthetize")
	TextAuto = self:GetChildComponent("Panel/BtnSyn/Text", "Text")
	TextAuto.text = Lang(12008)
end

function PageGemSynthetize:UpdateItem()
	self.TargetItemInfo = self:GetTargetItem(self.infoItem.id)

	local strName = self.infoItem:GetNameAndDesc()

	self.FromItemName.text = strName

	local strName = self.TargetItemInfo:GetNameAndDesc()

	self.TargetItemName.text = strName
end

function PageGemSynthetize:UpdateItemNeedCount()
	self.FromItem:UpdateWithNumType(self.infoItem)
	self.TargetItem:UpdateWithNumType(self.TargetItemInfo)

	local synCount = tonumber(self.InputField.text)
	local item, item2, money = self.TargetItemInfo:GetRequireItem()

	self.EngouhArrow:SetActive(true)

	if item.count * synCount <= self.infoItem:GetCurResNum() then
		self.FromTxtNeed.text = string.format(_("Desc_Need") .. "：" .. "%d", item.count * synCount)
	else
		self.FromTxtNeed.text = string.format(_("Desc_Need") .. "：" .. "<color=red>%d</color>", item.count * synCount)

		self.EngouhArrow:SetActive(false)
	end

	self.TargetTxtNeed.text = string.format(_("PageTalentTree_Get") .. "：%d", synCount)

	if PlayerInst:GetGold() < money * synCount then
		self.Money.text = string.format("<color=red>%d</color>", money * synCount)

		self.EngouhArrow:SetActive(false)
	else
		self.Money.text = money * synCount
	end
end

function PageGemSynthetize:GetTargetItem(Id)
	for i, v in ipairs(self.gemList) do
		if ItemManager:Get(v.ID):IsTargetItem(Id) then
			return ItemManager:Get(v.ID)
		end
	end

	return nil
end

function PageGemSynthetize:OnClickedButtonAdjust(data)
	local go = data.pointerPress
	local item1, item2, money = self.TargetItemInfo:GetRequireItem()
	local itemMax = math.floor(self.infoItem:GetCurResNum() / item1.count)
	local moneyMax = math.floor(PlayerInst:GetGold() / money)
	local maxNum = TenaryOp(moneyMax < itemMax, moneyMax, itemMax)

	if maxNum == 0 then
		maxNum = 1
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

	self.InputField.text = self.adjustNum

	self:UpdateItemNeedCount()
end

function PageGemSynthetize:UpdateLine()
	local firstIndex = 0

	if #self.lineItemInfos > lineIndexMax then
		firstIndex = #self.lineItemInfos - lineIndexMax
	end

	for i = 1, 8 do
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

function PageGemSynthetize:OnClickTargetItem()
	local info = self:GetTargetItem(self.TargetItemInfo.id)

	if info == nil then
		return
	end

	self.TargetItemInfo = info

	local item1 = info:GetRequireItem()

	self.infoItem = item1.itemInfo

	table.insert(self.lineItemInfos, self.infoItem)

	self.InputField.text = "1"

	self:UpdateItem()
	self:UpdateItemNeedCount()
	self:UpdateLine()
end

function PageGemSynthetize:OnClickLineItem(data)
	local index = data.pointerPress.gameObject.name

	if #self.lineItemInfos > lineIndexMax then
		index = #self.lineItemInfos - (lineIndexMax - tonumber(index))
	else
		index = tonumber(index)
	end

	if index == #self.lineItemInfos or index == lineIndexMax then
		return
	end

	self.infoItem = self.lineItemInfos[index]
	self.TargetItemInfo = self:GetTargetItem(self.lineItemInfos[index].id)

	local lineListCount = #self.lineItemInfos

	for i = index + 1, lineListCount do
		table.remove(self.lineItemInfos)
	end

	self:UpdateItem()
	self:UpdateItemNeedCount()
	self:UpdateLine()
end

function PageGemSynthetize:OnInputFieldChange(str)
	local item1, item2, money = self.TargetItemInfo:GetRequireItem()
	local itemMax = math.floor(self.infoItem:GetCurResNum() / item1.count)
	local moneyMax = math.floor(PlayerInst:GetGold() / money)
	local maxNum = TenaryOp(moneyMax < itemMax, moneyMax, itemMax)
	local inputNum = tonumber(TenaryOp(str == "", 0, str))

	if maxNum == 0 then
		maxNum = 1
	end

	if inputNum < 1 then
		inputNum = 1
	end

	if maxNum < inputNum then
		inputNum = maxNum
	end

	self.InputField.text = inputNum
	self.adjustNum = inputNum

	self:UpdateItemNeedCount()
end

function PageGemSynthetize:OnClickedSynthetize()
	local item1, item2, money = self.TargetItemInfo:GetRequireItem()

	local function callback(vMsg)
		if vMsg.result.code == NetManager.Result_Sucess then
			self.InputField.text = 1
			self.adjustNum = 1

			self:UpdateItemNeedCount()
			self:UpdateItemNeedCount()
			Event.Instance:Fire("UpdateBag")
			EffectMgr:Alloc("Fx/UI/Eff_Ui_PanelEquipEnchant/Eff_Ui_PanelEquipEnchant/FX_UI_Synthesis/FX_UI_Synthesis_3", self.EffectRoot, true, 2)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end

		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	if item1.itemInfo:GetCurResNum() >= item1.count * self.adjustNum and PlayerInst:GetGold() >= money * self.adjustNum then
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSynthetize(self.TargetItemInfo.id, self.adjustNum, callback)
	elseif PlayerInst:GetGold() < money * self.adjustNum then
		UIMgr.ShowMsg(Lang(12196))
	else
		UIMgr.ShowMsg(Lang(42180))
	end
end
