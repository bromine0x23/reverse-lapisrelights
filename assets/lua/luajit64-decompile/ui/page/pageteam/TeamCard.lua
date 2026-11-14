-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/TeamCard.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageRoleCard/Cell/CellCardSkill")

local CharacterTeam = require("luaData.CharacterTeam")
local lev = require("luaData/LevelConfig")
local jobBottomFramePaths = {
	"BG_card_back_limit_05",
	"BG_card_back_limit_01",
	"BG_card_back_limit_03",
	"BG_card_back_limit_04",
	"BG_card_back_limit_02"
}

TeamCard = class("TeamCard", UIItemBase)

function TeamCard:ctor(itemPrefabCache, parent, owerPage)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = owerPage
end

function TeamCard:Create(vParam)
	TeamCard.base.Create(self, vParam)
end

function TeamCard:OnEnter()
	local g = self.UIRootObject

	self.GoNoneCard = GOUtil.FindChildGameObject(g, "BG")
	self.ImgNoneCardBg = GOUtil.FindChildComponent(g, "BG", "Image")
	self.GoCardInfo = GOUtil.FindChildGameObject(g, "CardInfo")
	self.ImgCardBg = GOUtil.FindChildComponent(g, "CardInfo/Card/Bg", "RawImage")
	self.ImgCardIcon = GOUtil.FindChildComponent(g, "CardInfo/Card/Icon", "RawImage")
	self.ImgCardRank = GOUtil.FindChildComponent(g, "CardInfo/ImgRank", "Image")
	self.ImgCardJob = GOUtil.FindChildComponent(g, "CardInfo/ImgJob", "Image")
	self.TxtCardLevel = GOUtil.FindChildComponent(g, "CardInfo/BgInfo/TxtLevel", "Text")
	self.GoFrame = GOUtil.FindChildGameObject(g, "CardInfo/BgInfo/StarLevel/Frame")
	self.GoStar1 = GOUtil.FindChildGameObject(g, "CardInfo/BgInfo/StarLevel/Star1")
	self.GoStar2 = GOUtil.FindChildGameObject(g, "CardInfo/BgInfo/StarLevel/Star2")

	for i = 1, 4 do
		self["State" .. i] = GOUtil.FindChildGameObject(g, "CardInfo/GoPetal/State" .. i)
	end

	self.GoHelpAward = GOUtil.FindChildGameObject(g, "CardInfo/GoHelpAward")
	self.TxtHelpAwardNum = GOUtil.FindChildComponent(self.GoHelpAward, "TextValue", "Text")
	self.GoMyAward = GOUtil.FindChildGameObject(g, "CardInfo/GoMyAward")
	self.img_helper = GOUtil.FindChildGameObject(g, "BG/img_helper")
	self.GoCounter = GOUtil.FindChildGameObject(g, "CardInfo/GoCounter")
	self.ImgCounter = GOUtil.FindChildComponent(self.GoCounter, "ImgCounter", "Image")
	self.GoLeader = GOUtil.FindChildGameObject(g, "CardInfo/GoLeader")
	self.GoSkill = GOUtil.FindChildGameObject(g, "CardInfo/GoSkill")
	self.GoCSkill = GOUtil.FindChildGameObject(g, "CardInfo/GoCSkill")
	self.GoDisabled = GOUtil.FindChildGameObject(g, "CardInfo/Disabled")

	SetActiveFunc(self.GoDisabled, false)

	self.GoLimitOpen = GOUtil.FindChildGameObject(g, "LimitOpen")
	self.GoLimitOpenJob = GOUtil.FindChildGameObject(g, "LimitOpen/Job")
	self.GoLimitOpenTeam = GOUtil.FindChildGameObject(g, "LimitOpen/Team")
	self.GoLimitOpenRole = GOUtil.FindChildGameObject(g, "LimitOpen/Role")
	self.GoLimitOpenCard = GOUtil.FindChildGameObject(g, "LimitOpen/Card")
	self.ImgLimitOpenJob = GOUtil.FindChildComponent(g, "LimitOpen/Job/Icon", "Image")
	self.ImgLimitOpenTeam = GOUtil.FindChildComponent(g, "LimitOpen/Team/Icon", "Image")
	self.ImgLimitOpenRole = GOUtil.FindChildComponent(g, "LimitOpen/Role/Image/Icon", "Image")
	self.GoLimitNone = GOUtil.FindChildGameObject(g, "LimitNone")
	self.GoLimitNoneCard = GOUtil.FindChildGameObject(g, "LimitNone/Card")
	self.ImgLimitNoneRole = GOUtil.FindChildComponent(g, "LimitNone/Role", "Image")
	self.ImgLimitNoneTeam = GOUtil.FindChildComponent(g, "LimitNone/Team", "Image")
	self.TxtLimitNoneCradName = GOUtil.FindChildComponent(g, "LimitNone/Card/None/Image/CradName", "Text")
	self.GoLimitTs = GOUtil.FindChildGameObject(g, "LimitTimeSpace")
	self.GoCardRayCheck = GOUtil.FindChildGameObject(g, "CardRayCheck")

	self:RayCheck(false)

	self.GoCardHp = GOUtil.FindChildGameObject(g, "Hp")
	self.ImgCardHpBar = GOUtil.FindChildComponent(g, "Hp/Bar", "Image")
	self.CardEffect = GOUtil.FindChildGameObject(g, "CardInfo/CardEffect")
	self.IsNeedDealUnload = false
end

function TeamCard:OnLocalText(g)
	local TextAuto

	TextAuto = GOUtil.FindChildComponent(g, "CardInfo/RoleAttr/Text1/", "Text")
	TextAuto.text = Lang(5000010)
	TextAuto = GOUtil.FindChildComponent(g, "CardInfo/RoleAttr/Text2/", "Text")
	TextAuto.text = _("Desc_Combat_Power")
	TextAuto = self:GetChildComponent("CardInfo/RoleAttr/Text3/", "Text")
	TextAuto.text = Lang(5000038)
	TextAuto = self:GetChildComponent("CardInfo/Cost/TextCost/", "Text")
	TextAuto.text = Lang(5000010)
	TextAuto = self:GetChildComponent("CardInfo/HelpBattle/Text/", "Text")
	TextAuto.text = Lang(5000039)
	TextAuto = self:GetChildComponent("LimitOpen/Job/Text/", "Text")
	TextAuto.text = Lang(5000040)
	TextAuto = self:GetChildComponent("LimitOpen/Card/Img/Text/", "Text")
	TextAuto.text = Lang(5000041)
	TextAuto = self:GetChildComponent("LimitNone/Card/None/Image/Text/", "Text")
	TextAuto.text = Lang(5000042)
end

function TeamCard:OnLeave()
	if self.listCellSkill then
		for i, v in ipairs(self.listCellSkill) do
			v:OnLeave()
		end

		self.listCellSkill = nil
	end

	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end

	UnloadAllImageSprite(self)
end

function TeamCard:RayCheck(show)
	SetActiveFunc(self.GoCardRayCheck, show)
end

function TeamCard:UpdateData(teamSystemAgent, posIdx)
	self.teamSystemAgent = teamSystemAgent
	self.teamAgent = teamSystemAgent.teamList[teamSystemAgent.teamIndex]
	self.slotAgent = self.teamAgent.slotList[posIdx]
	self.posIdx = posIdx

	self:ShowEffect(RoleCardMgr.ShowCardEffect(self.slotAgent.upInfoRoleCard))
	self:CheckLimitUI()
	self:UpdateLimitUI(self.slotAgent.upInfoRoleCard ~= nil)
	SetActiveFunc(self.GoCardInfo, self.slotAgent.upInfoRoleCard ~= nil)
	SetActiveFunc(self.GoLeader, self.slotAgent.upInfoRole ~= nil and self.slotAgent.upInfoRole.data.Leader == 1)

	if self.slotAgent.upInfoRoleCard ~= nil then
		self:UpdateCardInfo(self.slotAgent.upInfoRoleCard, true)
	end

	SetActiveFunc(self.GoCardHp, false)
	self:UpdateCardHp()
end

function TeamCard:UpdateCardInfo(infoRoleCard, isOpen)
	local infoRole = InfoRole(infoRoleCard.data.CharacterID)

	GOUtil.DestroyAllChildren(self.ImgCardIcon.gameObject)
	self.ImgCardBg.gameObject:SetActive(false)
	RoleCardMgr:SetCardLocation(infoRoleCard, self.ImgCardIcon.gameObject, 1)

	self.TxtCardLevel.text = infoRoleCard.curLevel

	UIUtil.SetImageSprite(self.ImgCardJob, "UI/PanelBattleTeam/AtlasTeamCard/ICO_" .. infoRole.data.Job .. "_01_S", self)
	RoleCardMgr:SetStar(infoRoleCard, self)

	for i = 1, 4 do
		SetActiveFunc(self["State" .. i], i == infoRoleCard.cardRank)
	end

	for i = 1, infoRoleCard.maxPetal do
		local imgF = GOUtil.FindChildComponent(self["State" .. infoRoleCard.cardRank], "" .. i, "Image")
		local gray = TenaryOp(i <= infoRoleCard.curPetal, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(imgF, gray))
	end

	self:UpdateSkill(infoRoleCard)

	if self.slotAgent.isHelperCard == nil then
		self.slotAgent.isHelperCard = false
	end

	if self.slotAgent.isHelperCard then
		local award = GetConfigArgJson("FriendHelpCoinAdd")
	end

	SetActiveFunc(self.GoCounter, isOpen and self.teamSystemAgent.monsterJob ~= nil)

	if isOpen and self.teamSystemAgent.monsterJob then
		JobCheckingUtil.Init()

		local num = JobCheckingUtil.GetMul(infoRole.data.Job, self.teamSystemAgent.monsterJob)

		if num > 1 then
			UIUtil.SetImageSprite(self.ImgCounter, "UI/PanelBattleTeam/AtlasTeamCard/ui_hd_icon_up_02", self)
		elseif num < 1 then
			UIUtil.SetImageSprite(self.ImgCounter, "UI/PanelBattleTeam/AtlasTeamCard/ui_hd_icon_down_02", self)
		else
			SetActiveFunc(self.GoCounter, false)
		end
	end
end

function TeamCard:UpdateSkill(infoRoleCard)
	GOUtil.DestroyAllChildren(self.GoSkill)
	GOUtil.DestroyAllChildren(self.GoCSkill)
	self:GetSkill(infoRoleCard)

	if not self.listCellSkill then
		self.listCellSkill = {}
	end

	local function fun(infoSkill, GoParent, index, showTipsDown)
		local skill = CellCardSkill(self.page.PrefabCellCardSkill, GoParent, self, showTipsDown)

		skill:Create()

		skill.UIRootObject.name = index

		skill:UpdateData({
			showNameOrLevel = false,
			infoRoleCard = infoRoleCard,
			info = infoSkill
		})
		table.insert(self.listCellSkill, skill)
	end

	for i = 1, #self.listSkill do
		local infoSkill = self.listSkill[i]

		if infoSkill.data.BattleSkillType ~= 3 then
			fun(infoSkill, self.GoSkill, i)
		elseif self.posIdx == math.floor(#self.teamAgent.slotList / 2) + 1 then
			fun(infoSkill, self.GoCSkill, i, true)
		end
	end
end

function TeamCard:GetSkill(infoRoleCard)
	self.listSkill = {}
	self.listC = {}

	local list = infoRoleCard.listSkill

	for i = 1, #list do
		local infoSkill = list[i]

		if infoRoleCard:TalentIsUnLock(infoSkill.id) then
			local skillType = infoSkill.data.BattleSkillType

			if skillType == 1 then
				if #self.listSkill ~= 0 then
					table.insert(self.listSkill, 1, infoSkill)
				else
					table.insert(self.listSkill, infoSkill)
				end
			elseif skillType == 2 then
				table.insert(self.listSkill, infoSkill)
			elseif skillType == 3 then
				table.insert(self.listC, infoSkill)
			end
		end
	end

	if #self.listC > 0 then
		for i = 1, #self.listC do
			table.insert(self.listSkill, self.listC[i])
		end
	end
end

function TeamCard:CheckLimitUI()
	if self.slotAgent.limit ~= nil then
		self.limitType = self.slotAgent.limit[1]
		self.limitId = self.slotAgent.limit[2]
	else
		self.limitType = -1
		self.limitId = -1
	end
end

function TeamCard:UpdateLimitUI(open)
	SetActiveFunc(self.GoLimitTs, false)
	SetActiveFunc(self.GoLimitOpen, false)
	SetActiveFunc(self.GoLimitNone, false)

	self.ImgNoneCardBg.enabled = false
	self.ImgCardRank.enabled = false

	SetActiveFunc(self.img_helper, self.slotAgent.isHelperSlot and type(self.slotAgent.upInfoRoleCard) ~= "table")
	SetActiveFunc(self.GoHelpAward, self.slotAgent.isHelperSlot and self.slotAgent.isHelperCard)
	SetActiveFunc(self.GoMyAward, self.slotAgent.isHelperSlot and not self.slotAgent.isHelperCard)

	if self.teamSystemAgent.isGvg and self.slotAgent.isHelperSlot then
		if self.slotAgent.isHelperCard then
			local img = GOUtil.GetComponent(self.GoHelpAward, "Image")
			local path = "UI/PanelBattleTeam/AtlasTeamCard/bg_card_back_helper_04b"

			UIUtil.SetImageSprite(img, path, true)

			local child = GOUtil.FindChildGameObject(self.GoHelpAward, "Image")

			img = GOUtil.GetComponent(child, "Image")
			path = "UI/PanelBattleTeam/AtlasTeamCard/bg_card_helper_word_02"

			UIUtil.SetImageSprite(img, path, true)
		else
			local img = GOUtil.GetComponent(self.GoMyAward, "Image")
			local path = "UI/PanelBattleTeam/AtlasTeamCard/bg_card_back_helper_03b"

			UIUtil.SetImageSprite(img, path, true)

			local child = GOUtil.FindChildGameObject(self.GoMyAward, "Image")

			img = GOUtil.GetComponent(child, "Image")
			path = "UI/PanelBattleTeam/AtlasTeamCard/bg_card_helper_word_01"

			UIUtil.SetImageSprite(img, path, true)
		end
	end

	local cardBgPath = ""

	if open then
		self.ImgCardRank.enabled = true
		cardBgPath = "UIDyAtlas/RoleCardRank/BG_card_back_" .. self.slotAgent.upInfoRoleCard.rank .. "_8"

		if self.limitType ~= -1 then
			SetActiveFunc(self.GoLimitOpen, true)
			SetActiveFunc(self.GoLimitOpenJob, false)
			SetActiveFunc(self.GoLimitOpenTeam, false)
			SetActiveFunc(self.GoLimitOpenRole, false)
			SetActiveFunc(self.GoLimitOpenCard, false)

			if self.limitType == 1 then
				SetActiveFunc(self.GoLimitOpenRole, true)

				local infoRole = RoleMgr:GetRole(self.limitId)

				UIUtil.SetImageSprite(self.ImgLimitOpenRole, infoRole.actorData.CharacterIcon, self)
			elseif self.limitType == 2 then
				SetActiveFunc(self.GoLimitOpenCard, true)
			elseif self.limitType == 3 then
				SetActiveFunc(self.GoLimitOpenJob, true)
				UIUtil.SetImageSprite(self.ImgLimitOpenJob, "UI/PanelBattleTeam/AtlasTeamCard/ICO_" .. GetConfigArgJson("JobNumber")[self.limitId] .. "_01", self)
			elseif self.limitType == 4 then
				SetActiveFunc(self.GoLimitOpenTeam, true)

				local teamCfg = CharacterTeam[self.limitId]

				UIUtil.SetImageSprite(self.ImgLimitOpenTeam, "UIDyAtlas/Team/" .. teamCfg.Icon, self)
			end
		end

		if self.teamSystemAgent.isTimespace then
			if self.slotAgent.upInfoRoleCard.tsLimit then
				SetActiveFunc(self.GoLimitTs, true)
			else
				SetActiveFunc(self.GoLimitTs, false)
			end
		end

		UIUtil.SetImageSprite(self.ImgCardRank, cardBgPath, self)
	else
		self.ImgNoneCardBg.enabled = true

		if self.limitType ~= -1 then
			SetActiveFunc(self.GoLimitNone, true)

			self.ImgLimitNoneTeam.enabled = false

			SetActiveFunc(self.GoLimitNoneCard, false)

			self.ImgLimitNoneRole.enabled = false

			if self.limitType == 1 then
				cardBgPath = "UIDyAtlas/RoleCardRank/BG_card_back_limit_08"
				self.ImgLimitNoneRole.enabled = true

				local infoRole = RoleMgr:GetRole(self.limitId)

				UIUtil.SetImageSprite(self.ImgLimitNoneRole, infoRole.actorData.CharacterIcon, self)
			elseif self.limitType == 2 then
				SetActiveFunc(self.GoLimitNoneCard, true)

				local infoRoleCard = RoleCardMgr:GetRoleCard(self.limitId)

				cardBgPath = "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_8"
				self.TxtLimitNoneCradName.text = Lang(infoRoleCard.data.Name)

				SetActiveFunc(self.GoCardInfo, true)

				self.ImgNoneCardBg.enabled = false
				self.ImgCardRank.enabled = true

				if not infoRoleCard then
					return
				end

				self:UpdateCardInfo(infoRoleCard, false)
			elseif self.limitType == 3 then
				cardBgPath = "UIDyAtlas/RoleCardRank/" .. jobBottomFramePaths[self.limitId]
			elseif self.limitType == 4 then
				cardBgPath = "UIDyAtlas/RoleCardRank/BG_card_back_limit_07"
				self.ImgLimitNoneTeam.enabled = true

				local teamCfg = CharacterTeam[self.limitId]

				UIUtil.SetImageSprite(self.ImgLimitNoneTeam, "UIDyAtlas/Team/" .. teamCfg.Icon, self)
			end
		else
			if self.teamSystemAgent.recommendJob then
				-- block empty
			end

			if self.slotAgent.isHelperSlot then
				cardBgPath = "UIDyAtlas/RoleCardRank/BG_card_back_limit_06"

				if self.teamSystemAgent.isGvg then
					cardBgPath = "UIDyAtlas/RoleCardRank/BG_card_back_limit_10"
				end

				SetActiveFunc(self.img_helper, false)
			else
				cardBgPath = "UIDyAtlas/RoleCardRank/BG_card_back_limit_09"
			end
		end

		UIUtil.SetImageSprite(self.ImgNoneCardBg, cardBgPath, self)
	end
end

function TeamCard:UpdateCardHp()
	if self.teamSystemAgent.isRaid and self.slotAgent.upInfoRoleCard ~= nil then
		local infoCard = self.slotAgent.upInfoRoleCard
		local curHpPer = infoCard.curCommRaidHpPer or 0

		self.ImgCardHpBar.fillAmount = curHpPer / infoCard.maxRaidHpPer

		SetActiveFunc(self.GoDisabled, curHpPer == 0)
	end
end

function TeamCard:ShowEffect(isShow)
	if not self.IsNeedDealUnload and isShow then
		RoleCardMgr:CreateEffect()

		self.IsNeedDealUnload = true
	end

	GOUtil.SetActive(self.CardEffect, isShow)
end
