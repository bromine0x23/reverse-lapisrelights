-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/PagePVPBattlerInfo.lua

PagePVPBattlerInfo = class("PagePVPBattlerInfo", UIPanel)

local InfoPVPData = require("Info/InfoPVP")

function PagePVPBattlerInfo:ctor()
	self.UIPrefabPath = "UI/PanelPVP/PanelBattlerInfo"
end

function PagePVPBattlerInfo:Purge()
	PagePVPBattlerInfo.base.Purge(self)
	UnloadAllImageSprite(self)
end

function PagePVPBattlerInfo:OnRegisterEvent()
	self:AddClick(self.bg, self.OnClickedBtnQuit)
	self:AddClick(self.battleBtn, self.OnBattle)
end

function PagePVPBattlerInfo:OnUnRegisterEvent()
	self:RemoveClick(self.bg, self.OnClickedBtnQuit)
	self:RemoveClick(self.battleBtn, self.OnBattle)
end

function PagePVPBattlerInfo:OnEnter(vParam)
	self.otherplayerdata = vParam
	self.battleBtn = self:GetChildGameObject("BattlerInfo/Button")
	self.level = self:GetChildComponent("PlayerInfo/HeadIcon/Level", "Text")
	self.head = self:GetChildComponent("PlayerInfo/HeadIcon", "MaskableImage")
	self.name = self:GetChildComponent("PlayerInfo/Name/Value", "Text")
	self.gradeIcon = self:GetChildComponent("PlayerInfo/Name/Icon", "Image")
	self.power = self:GetChildComponent("PlayerInfo/Power/Value", "Text")
	self.rank = self:GetChildComponent("PlayerInfo/Rank/Value", "Text")
	self.bg = self:GetChildGameObject("BG1")
	self.cards = {}

	for i = 1, 3 do
		local card = {}
		local go = self:GetChildGameObject("BattlerInfo/Con/" .. i)

		for j = 1, 4 do
			card["State" .. j] = GOUtil.FindChildGameObject(go, "BgFlower/State" .. j)
		end

		card.cardBg = GOUtil.FindChildComponent(go, "Rank", "Image")
		card.cardIcon = GOUtil.FindChildComponent(go, "Card/Icon", "Image")
		card.level = GOUtil.FindChildComponent(go, "BgLevel/Level", "Text")
		card.roleJob = GOUtil.FindChildComponent(go, "RoleJob", "Image")

		for j = 1, 5 do
			card["ImageStarFrame" .. j] = GOUtil.FindChildGameObject(go, "BgStar/Star/Image" .. j)
			card["ImageStar" .. j] = GOUtil.FindChildGameObject(go, "BgStar/Star/Star" .. j)
		end

		card.name = GOUtil.FindChildComponent(go, "Name", "Text")

		table.insert(self.cards, card)
	end

	self:UpdateUI()
end

function PagePVPBattlerInfo:UpdateUI()
	self.level.text = self.otherplayerdata.playerinfo.curLevel

	UIUtil.SetImageSprite(self.head, self.otherplayerdata.playerinfo:GetTitleIcon(1))

	self.name.text = self.otherplayerdata.playerinfo.name
	self.power.text = InfoPVPData:GetAddRoleCard(self.otherplayerdata)
	self.rank.text = self.otherplayerdata.subSeasonRankingNo

	for i = 1, 3 do
		local card = self.cards[i]
		local infoRoleCard = InfoPVPData:GetotherRolecard(i)
		local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

		UIUtil.SetImageSprite(card.cardIcon, infoRoleCard.data.MidIcon)

		local path = "UIDyAtlas/RoleCardRank/ui_hd_card_back_" .. infoRoleCard.rank .. "_7"

		UIUtil.SetImageSprite(card.cardBg, path)
		UIUtil.SetImageSprite(card.roleJob, "UI/PanelBattleTeam/AtlasBattleCard/ICO_" .. infoRole.data.Job .. "_01")

		card.level.text = infoRoleCard.curLevel
		card.name.text = infoRoleCard:GetName()

		RoleCardMgr:SetStarPanel(infoRoleCard, card, self)

		local cardRank = infoRoleCard.cardRank

		for i = 1, 4 do
			card["State" .. i]:SetActive(i == cardRank)
		end

		local flower = card["State" .. cardRank]
		local count = infoRoleCard.maxPetal
		local curNum = infoRoleCard.curPetal

		for i = 1, count do
			local imgF = GOUtil.FindChildComponent(flower, "" .. i, "Image")
			local isOk = i <= curNum
			local gray = TenaryOp(isOk, 0, 1)

			UIUtil.SetImageGray(imgF, gray)
		end
	end
end

function PagePVPBattlerInfo:OnBattle()
	InfoPVPData:SetTeamType(1)

	local teamdata = InfoPVPData:CreateAgent(2)

	UIMgr.SwitchPanel(PageTeam, teamdata)
	self:Close()
end

function PagePVPBattlerInfo:OnClickedBtnQuit()
	self:Close()
end
