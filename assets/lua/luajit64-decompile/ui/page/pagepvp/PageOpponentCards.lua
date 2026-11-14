-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/PageOpponentCards.lua

local InfoPVPData = require("Info/InfoPVP")
local item_card = class("PageOpponentCards_item")

function item_card:ctor(go, idx)
	self.idx = idx
	self.gameObject = go

	for j = 1, 4 do
		self["State" .. j] = GOUtil.FindChildGameObject(go, "BgFlower/State" .. j)
	end

	self.cardBg = GOUtil.FindChildComponent(go, "Rank", "Image")
	self.cardIcon = GOUtil.FindChildComponent(go, "Card/Icon", "Image")
	self.level = GOUtil.FindChildComponent(go, "BgLevel/Level", "Text")
	self.roleJob = GOUtil.FindChildComponent(go, "RoleJob", "Image")
	self.GoFrame = GOUtil.FindChildGameObject(go, "BgStar/Frame")
	self.GoStar1 = GOUtil.FindChildGameObject(go, "BgStar/Star1")
	self.GoStar2 = GOUtil.FindChildGameObject(go, "BgStar/Star2")
	self.name = GOUtil.FindChildComponent(go, "Name", "Text")
	self.CardEffect = GOUtil.FindChildGameObject(go, "CardEffect")
	self.IsNeedDealUnload = false
end

function item_card:Refresh()
	local infoRoleCard = InfoPVPData:GetotherRolecard(self.idx)

	if not infoRoleCard then
		GOUtil.SetActive(self.gameObject, false)

		return
	end

	GOUtil.SetActive(self.gameObject, true)

	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

	UIUtil.SetImageSprite(self.cardIcon, infoRoleCard.data.MidIcon)

	local path = "UIDyAtlas/RoleCardRank/ui_hd_card_back_" .. infoRoleCard.rank .. "_7"

	UIUtil.SetImageSprite(self.cardBg, path)
	UIUtil.SetImageSprite(self.roleJob, "UI/PanelBattleTeam/AtlasTeamCard/ICO_" .. infoRole.data.Job .. "_01")

	self.level.text = infoRoleCard.curLevel
	self.name.text = infoRoleCard:GetName()

	RoleCardMgr:SetStar(infoRoleCard, self)
	self:ShowEffect(RoleCardMgr.ShowCardEffect(infoRoleCard))

	local cardRank = infoRoleCard.cardRank

	for i = 1, 4 do
		self["State" .. i]:SetActive(i == cardRank)
	end

	local flower = self["State" .. cardRank]
	local count = infoRoleCard.maxPetal
	local curNum = infoRoleCard.curPetal

	for i = 1, count do
		local imgF = GOUtil.FindChildComponent(flower, "" .. i, "Image")
		local isOk = i <= curNum
		local gray = TenaryOp(isOk, 0, 1)

		UIUtil.SetImageGray(imgF, gray)
	end
end

function item_card:ShowEffect(isShow)
	if not self.IsNeedDealUnload and isShow then
		RoleCardMgr:CreateEffect()

		self.IsNeedDealUnload = true
	end

	SetActiveFunc(self.CardEffect, isShow)
end

function item_card:Purge()
	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end
end

PageOpponentCards = class("PageOpponentCards", UIPanel)

function PageOpponentCards:ctor()
	self.UIPrefabPath = "UI/PanelPVP/PanelOpponentCards"
	self.items = {}
end

function PageOpponentCards:Purge()
	PageOpponentCards.base.Purge(self)

	for i, item in ipairs(self.items) do
		item:Purge()
	end
end

function PageOpponentCards:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose)
end

function PageOpponentCards:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnClose)
end

function PageOpponentCards:OnBtnClose()
	self:Close()
end

function PageOpponentCards:OnEnter(vParam)
	self.btn_close = self:GetChildGameObject("btn_close")

	local content = self:GetChildGameObject("content")

	for i = 1, content.transform.childCount do
		local go = content.transform:GetChild(i - 1).gameObject

		table.insert(self.items, item_card(go, i))
	end

	for i, item in ipairs(self.items) do
		item:Refresh()
	end
end
