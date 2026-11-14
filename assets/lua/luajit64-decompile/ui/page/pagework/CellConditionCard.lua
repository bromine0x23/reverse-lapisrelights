-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageWork/CellConditionCard.lua

require("UI/Item/UIItemBase")

CellConditionCard = class("CellConditionCard", UIItemBase)

function CellConditionCard:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellConditionCard:Create(vParam)
	self.base.Create(self, vParam)
end

function CellConditionCard:OnEnter()
	local g = self.UIRootObject

	self:DealWithLocalization()

	self.ImgCardIcon = GOUtil.FindChildComponent(g, "Panel/Card/Icon", "Image")
	self.ImgCardRank = GOUtil.FindChildComponent(g, "Panel/Rank", "Image")
	self.ImgCardJob = GOUtil.FindChildComponent(g, "Panel/Job", "Image")
	self.GoFrame = GOUtil.FindChildGameObject(g, "Panel/Info/Star/Frame")
	self.GoStar1 = GOUtil.FindChildGameObject(g, "Panel/Info/Star/Star1")
	self.GoStar2 = GOUtil.FindChildGameObject(g, "Panel/Info/Star/Star2")
	self.TxtCardLevel = GOUtil.FindChildComponent(g, "Panel/Info/TxtLevel", "Text")
	self.TxtRoleName = GOUtil.FindChildComponent(g, "Panel/Info/TxtRole", "Text")
	self.GoPicked = GOUtil.FindChildGameObject(g, "Panel/GoSelect")
	self.GoPicked1 = GOUtil.FindChildGameObject(g, "Panel/GoSelect/Select1")
	self.GoPicked2 = GOUtil.FindChildGameObject(g, "Panel/GoSelect/Select2")
	self.ImgPickedNum = GOUtil.FindChildComponent(g, "Panel/GoSelect/Select1/Image", "Image")

	for i = 1, 3 do
		self["GoCond" .. i] = GOUtil.FindChildGameObject(g, "Panel/Group/" .. i)
		self["RawImgEff" .. i] = GOUtil.FindChildComponent(self["GoCond" .. i], "Eff", "RawImage")
		self["ImgCondition" .. i] = GOUtil.FindChildComponent(self["GoCond" .. i], "Icon", "Image")
	end

	for i = 1, 4 do
		self["State" .. i] = GOUtil.FindChildGameObject(g, "Panel/Flower/State" .. i)
	end

	self.BtnUnload = GOUtil.FindChildGameObject(g, "Panel/BtnUnload")

	self:AddClick(self.BtnUnload, self.OnClickedBtnUnload)

	self.CardEffect = GOUtil.FindChildGameObject(g, "Panel/CardEffect")
	self.IsNeedDealUnload = false
end

function CellConditionCard:DealWithLocalization()
	local text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/BtnUnload/Text", "Text")

	text.text = _("UI_UnEquip")
end

function CellConditionCard:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.BtnUnload, self.OnClickedBtnUnload)

	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end
end

function CellConditionCard:UpdateData(cardData, data)
	local cardId = cardData.cardId
	local infoRole = RoleCardMgr:GetRole(cardId)
	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)

	self.infoRoleCard = infoRoleCard

	for i = 1, 3 do
		self["RawImgEff" .. i].texture = data.effTex
	end

	UIUtil.SetImageSprite(self.ImgCardIcon, infoRoleCard.data.MidIcon, self)
	UIUtil.SetImageSprite(self.ImgCardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_9", self)
	UIUtil.SetImageSprite(self.ImgCardJob, "UI/PanelWork/AtlasPanelWork/ICO_" .. infoRoleCard.JobStr .. "_01_S", self)
	RoleCardMgr:SetStar(infoRoleCard, self)

	self.TxtCardLevel.text = infoRoleCard.curLevel
	self.TxtRoleName.text = infoRole:GetName()

	if self.preState ~= infoRoleCard.cardRank then
		GOUtil.SetActive(self["State" .. infoRoleCard.cardRank], true)

		if self.preState ~= nil then
			GOUtil.SetActive(self["State" .. self.preState], false)
		end

		self.preState = infoRoleCard.cardRank
	end

	local flower = self["State" .. infoRoleCard.cardRank]
	local maxPetal = infoRoleCard.maxPetal
	local curPetal = infoRoleCard.curPetal

	for i = 1, maxPetal do
		local imgF = GOUtil.FindChildComponent(flower, "" .. i, "Image")
		local gray = TenaryOp(i <= curPetal, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(imgF, gray))
	end

	local queue = cardData.posIdx
	local state = cardData.style

	GOUtil.SetActive(self.BtnUnload, state == 1)
	GOUtil.SetActive(self.GoPicked, state == 1 or state == 2)
	GOUtil.SetActive(self.GoPicked1, state == 2)
	GOUtil.SetActive(self.GoPicked2, state == 3)

	if state == 2 then
		UIUtil.SetImageSprite(self.ImgPickedNum, "UI/PanelWork/AtlasPanelWork/ICO_mis_side_0" .. queue, self)
	end

	local list = infoRoleCard.listAbility or {}

	for i = 1, 3 do
		GOUtil.SetActive(self["GoCond" .. i], i <= #list)

		if i <= #list then
			UIUtil.SetImageSprite(self["ImgCondition" .. i], list[i].Icon, self)
		end
	end

	local isShow = RoleCardMgr.ShowCardEffect(infoRoleCard)

	if not self.IsNeedDealUnload and isShow then
		RoleCardMgr:CreateEffect()

		self.IsNeedDealUnload = true
	end

	GOUtil.SetActive(self.CardEffect, isShow)
end

function CellConditionCard:UpdateCondition(selConditionIds)
	if not self.infoRoleCard then
		return
	end

	local listCardAbility = self.infoRoleCard.listAbility

	for i = 1, #listCardAbility do
		local isFull = table.contains(selConditionIds, listCardAbility[i].ID)

		GOUtil.SetActive(self["RawImgEff" .. i], isFull)
	end
end

function CellConditionCard:OnClickedBtnUnload()
	if self.page then
		self.page.curCardIdx = self.Index

		self.page:UpdatePickedCard()
	end
end
