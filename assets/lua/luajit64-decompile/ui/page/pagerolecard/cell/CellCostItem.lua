-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Cell/CellCostItem.lua

require("UI/Item/UIItemBase")

CellCostItem = class("CellCostItem", UIItemBase)

function CellCostItem:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCostItem:Create(vParam)
	CellCostItem.base.Create(self, vParam)
end

function CellCostItem:OnEnter()
	local g = self.UIRootObject
	local gItem = GOUtil.FindChildGameObject(g, "CellItem")

	self.item = CellItem(gItem)

	self.item:InitItemByRoot(gItem)

	self.item.tipData = {
		showNum = true,
		initPanelIndex = 1,
		needFromBtn = true
	}
	self.GoBg = GOUtil.FindChildGameObject(g, "Bg")
	self.GotoAdd = GOUtil.FindChildGameObject(g, "GotoAdd")
	self.GotoGet = GOUtil.FindChildGameObject(g, "GotoGet")
	self.GoNone = GOUtil.FindChildGameObject(g, "None")
	self.GoNoneSign1 = GOUtil.FindChildGameObject(g, "None/Image1")
	self.GoNoneSign2 = GOUtil.FindChildGameObject(g, "None/Image2")
	self.TxtCost = GOUtil.FindChildComponent(g, "TextCost", "Text")
	self.TxtEmojiCost = GOUtil.FindChildComponent(g, "TextEmojiCost", "EmojiText")

	self:AddClick(self.GotoAdd, self.OnClickedGotoAdd)
	self:AddClick(self.GotoGet, self.OnClickedGotoGet)
end

function CellCostItem:OnLeave()
	if self.item and self.item.OnLeave then
		self.item:OnLeave()
	end

	self:RemoveClick(self.GotoAdd, self.OnClickedGotoAdd)
	self:RemoveClick(self.GotoGet, self.OnClickedGotoGet)

	if self.EffPath then
		EffectMgr:UnLoadEffect(self.EffPath)

		self.EffPath = nil
	end

	self.callback = nil
end

function CellCostItem:OnClickedGotoAdd()
	local index = tonumber(self.UIRootObject.name)

	if self.callback then
		self.callback(index)

		return
	end
end

function CellCostItem:OnClickedGotoGet()
	if self.isSynthetize then
		local needItem = {}

		needItem.id = self.infoItem.id
		needItem.needNum = self.needNum

		Event.Instance:Fire("OpenPageItemSyn", self.infoItem, needItem)
	else
		local needItem = {}

		needItem.id = self.infoItem.id
		needItem.needNum = self.needNum

		UIMgr.ShowItemTip(self.infoItem, 2, true, true, nil, needItem)
	end
end

function CellCostItem:UpdateData(data)
	if data == nil or data.info == nil then
		return
	end

	self.infoItem = data.info
	self.holdNum = self.infoItem:GetNum()
	self.needNum = data.needNum or 0
	self.callback = data.callback
	self.showGet = Tenary(data.showGet, false)
	self.showAdd = Tenary(data.showAdd, false)
	self.showPrompt = Tenary(data.showPrompt, false)
	self.hideNeed = Tenary(data.hideNeed, false)
	self.useEmojiNeed = Tenary(data.useEmojiNeed, false)
	self.showBg = Tenary(data.showBg, false)
	self.belong = data.belong
	self.isSynthetize = Tenary(data.isSynthetize, false)
	self.isCanSynthetize = Tenary(data.isCanSynthetize, false)
	self.moveNeedPos = data.needPos

	self:SetItem()
	self:SetNeed()
	self:SetNone()
	GOUtil.SetActive(self.GoBg, self.showBg)
	GOUtil.SetActive(self.GotoGet, self.showGet)
	GOUtil.SetActive(self.GotoAdd, self.showAdd)

	if self.moveNeedPos then
		GOUtil.SetRectTransformAnchoredPosition(self.TxtCost.gameObject, self.moveNeedPos[1], self.moveNeedPos[2])
	end
end

function CellCostItem:SetItem()
	if self.item then
		self.item:UpdateWithNumType(self.infoItem)
		self:UpdateHoldTxtColor(self.needNum <= self.holdNum)

		local isCommon = ItemManager:IsCommonStone(self.infoItem.id)

		if isCommon and self.belong and self.belong ~= 0 then
			local path = self.infoItem:GetIcon() .. "_0" .. self.belong

			self.item:ResetItemIcon(path)
		end
	end
end

function CellCostItem:SetNeed()
	local textComponent

	if self.useEmojiNeed then
		textComponent = self.TxtEmojiCost
		textComponent.text = string.format(_("Desc_EmojiText_Need"), GetEmojiId(self.infoItem.id), self.needNum)
	else
		textComponent = self.TxtCost
		textComponent.text = _("Desc_Need") .. "：" .. self.needNum
	end

	GOUtil.SetActive(textComponent, not self.hideNeed)

	self.isEnough = self.holdNum >= self.needNum

	self:UpdateNeedTxtColor(textComponent, self.holdNum >= self.needNum)
end

function CellCostItem:SetNone()
	if not self.showPrompt then
		return
	end

	local active = false

	if self.showAdd then
		active = self.holdNum == 0
	else
		active = self.holdNum < self.needNum
	end

	GOUtil.SetActive(self.GoNone, active)

	if active then
		if self.isSynthetize then
			GOUtil.SetActive(self.GoNoneSign1, not self.isCanSynthetize)
			GOUtil.SetActive(self.GoNoneSign2, self.isCanSynthetize)
		else
			GOUtil.SetActive(self.GoNoneSign1, true)
		end
	end
end

function CellCostItem:UpdateHoldTxtColor(isEnough)
	local strCol = isEnough and "585E62" or "E22929"

	self.item:UpdateNumColor(strCol)
end

function CellCostItem:UpdateNeedTxtColor(text, isEnough)
	local strCol = isEnough and "585E62" or "E22929"
	local color = sixNumToRGB(strCol)

	UIUtil.SetGraphicColorRGB(text, color.r / 255, color.g / 255, color.b / 255)
end

function CellCostItem:PlayEff()
	if not self.EffPath then
		self.EffPath = "Fx/UI/FX_UI_Glow/FX_Rank_Glow02"
	end

	if self.handle then
		-- block empty
	end

	self.handle = EffectMgr:Alloc(self.EffPath, self.item.UIRootObject, true, 1)
end

function CellCostItem:UpdateNum(num)
	self.holdNum = num or 0

	local isEnough = self.holdNum >= self.needNum

	if not self.hideNeed and self.isEnough ~= isEnough then
		self.isEnough = isEnough

		local textComponent = self.useEmojiNeed and self.TxtEmojiCost or self.TxtCost

		self:UpdateNeedTxtColor(textComponent, isEnough)
	end

	if self.item then
		self.item:UpdateNumOnly(num)
		self:UpdateHoldTxtColor(isEnough)
	end

	self:SetNone()
end
