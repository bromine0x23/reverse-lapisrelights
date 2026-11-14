-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Page/DlgCardOverviewPanel.lua

require("UI/Page/PageRoleCard/Dlg/DlgCardAttr")
require("UI/Page/PageRoleCard/Dlg/DlgCardLevelUp")

DlgCardOverviewPanel = class("DlgCardOverviewPanel", UIPanel)

function DlgCardOverviewPanel:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/PanelCardOverview"
	self.CardSkillTip = CardSkillTip()

	self:AddChildPanel(self.CardSkillTip)
end

function DlgCardOverviewPanel:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellCardSkill", "PrefabCellCardSkill", GameObject)
end

function DlgCardOverviewPanel:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellCardSkill)
	self:ClearInstance()
end

function DlgCardOverviewPanel:OnRegisterEvent()
	self:AddClick(self.BtnUpLv, self.OnClickedBtnUpLv)
	self:AddClick(self.BtnAttr, self.OnClickedBtnAttr)
	self:AddClick(self.GoHead, self.OnClickedGoHead)
end

function DlgCardOverviewPanel:OnUnRegisterEvent()
	self:RemoveClick(self.BtnUpLv, self.OnClickedBtnUpLv)
	self:RemoveClick(self.BtnAttr, self.OnClickedBtnAttr)
	self:RemoveClick(self.GoHead, self.OnClickedGoHead)
end

function DlgCardOverviewPanel:ClearInstance()
	local function ClearEvent(listCell)
		if listCell then
			for _, v in pairs(listCell) do
				v:OnLeave()
			end

			listCell = nil
		end
	end

	ClearEvent(self.listBCell)
	ClearEvent(self.listCCell)
	ClearEvent(self.listOCell)
end

function DlgCardOverviewPanel:OnEnter(vParam)
	self:SetSafeArea(self.UIRootObject)
	self:DealWithLocalization()

	self.TxtCardLv = self:GetChildComponent("Panel/Card/Level/Level/TxtLevel", "Text")
	self.ImgCardExp = self:GetChildComponent("Panel/Card/Level/Exp/Exp", "Image")
	self.TxtCardExp = self:GetChildComponent("Panel/Card/Level/Exp/Text", "Text")

	for i = 1, ATTRIBUTE_USE_CNT do
		self["TxtAttValue" .. i] = self:GetChildComponent("Panel/Card/Attr/" .. i .. "/TxtValue", "Text")
	end

	self.GoOGroup = self:GetChildGameObject("Panel/Card/Skill/OGroup")
	self.GoCGroup = self:GetChildGameObject("Panel/Card/Skill/CGroup")
	self.GoBGroup = self:GetChildGameObject("Panel/Card/Skill/BGroup")
	self.GoTip = self:GetChildGameObject("Panel/Role/Image")
	self.GoHead = self:GetChildGameObject("Panel/Role/Head")
	self.ImgRoleIcon = self:GetChildComponent("Panel/Role/Head/Icon", "MaskableImage")
	self.ImgRoleJob = self:GetChildComponent("Panel/Role/Info/Job", "Image")
	self.TxtRoleName = self:GetChildComponent("Panel/Role/Info/Name/TxtName", "Text")
	self.TxtRoleCV = self:GetChildComponent("Panel/Role/Info/CV/TxtCV", "Text")

	for i = 1, 8 do
		self["ImgSign" .. i] = self:GetChildComponent("Panel/Card/Sign/Scroll/Content/" .. i, "Image")
	end

	self.BtnUpLv = self:GetChildGameObject("Panel/Card/Level/ButtonLvUp")
	self.ImgBtnUpLv = GOUtil.GetComponent(self.BtnUpLv, "Image")
	self.BtnAttr = self:GetChildGameObject("Panel/Card/Attr/BtnAttr")
	self.AnimBtnAttr = GOUtil.GetComponent(self.BtnAttr, "Animator")

	InstructionMgr:TriggerWait("ShowCardOverview")
	self:InitPanel(vParam)
end

function DlgCardOverviewPanel:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Card/Level/ButtonLvUp/Text", "Text")
	txt.text = Lang(12061)
	txt = self:GetChildComponent("Panel/Card/Sign/Title/Text", "Text")
	txt.text = Lang(42039)
	txt = self:GetChildComponent("Panel/Role/Info/Name/Text", "Text")
	txt.text = Lang(12018)

	for i = 1, ATTRIBUTE_USE_CNT do
		txt = self:GetChildComponent("Panel/Card/Attr/" .. i .. "/Text", "Text")
		txt.text = _("eAttType_" .. i)
	end
end

function DlgCardOverviewPanel:Show()
	GOUtil.SetActive(self.UIRootObject, true)
end

function DlgCardOverviewPanel:Hide()
	GOUtil.SetActive(self.UIRootObject, false)
end

function DlgCardOverviewPanel:InitPanel(data)
	if not data or not data.infoRoleCard then
		return
	end

	self.onlyShow = data.onlyShow
	self.infoRoleCard = data.infoRoleCard

	if self.onlyShow then
		self.GoTip:SetActive(false)
	else
		RedDotSystemMgr.SetUIRedDot(self.BtnUpLv, "LvUp/" .. self.infoRoleCard.id)
	end

	self:UpdateStaticVal()
	self:UpdateDynamicVal()
end

local function BuildCellInstance(parentGo, listCell, page)
	local cell = CellCardSkill(page.PrefabCellCardSkill, parentGo, page)

	cell:Create()
	table.insert(listCell, cell)
end

local function UpdateCellInstance(listInfo, listCell, infoRoleCard, infoType, onlyShow)
	if not listCell then
		return
	end

	for k, cell in ipairs(listCell) do
		if k <= #listInfo then
			local data = {
				cardOverview = true,
				info = listInfo[k],
				infoRoleCard = infoRoleCard,
				infoType = infoType,
				onlyShow = onlyShow
			}

			cell:UpdateData(data)
		end
	end
end

local function DealNewCell(listInfo, listCell, parentGo, page)
	local newCnt, oldCnt = #listInfo, #listCell

	if oldCnt < newCnt then
		for k in ipairs(listInfo) do
			if oldCnt < k then
				BuildCellInstance(parentGo, listCell, page)
			end
		end
	elseif newCnt <= oldCnt then
		for k, cell in ipairs(listCell) do
			GOUtil.SetActive(cell.UIRootObject, k <= newCnt)
		end
	end
end

function DlgCardOverviewPanel:UpdateStaticVal()
	local listSign = self.infoRoleCard.listSign

	for i = 1, 8 do
		if i <= #listSign then
			UIUtil.SetGraphicAlpha(self["ImgSign" .. i], 1)
			UIUtil.SetImageSprite(self["ImgSign" .. i], listSign[i].Icon, self)
		else
			UIUtil.SetGraphicAlpha(self["ImgSign" .. i], 0)
		end
	end

	local infoRole = RoleCardMgr:GetRole(self.infoRoleCard.id)

	if infoRole then
		SetImageSprite(self.ImgRoleIcon, infoRole.actorData.CharacterIcon, self)
		SetImageSprite(self.ImgRoleJob, "UI/PanelRoleCard/AtlasPanelCard/ICO_" .. infoRole.data.Job .. "_01_S", self)

		self.TxtRoleName.text = infoRole:GetName()
		self.TxtRoleCV.text = infoRole:GetCVName()
	end

	self:GetCardSkill()
	GOUtil.SetActive(self.GoOGroup, #self.listO > 0)

	if #self.listO > 0 then
		self.listOCell = Tenary(self.listOCell, {})

		DealNewCell(self.listO, self.listOCell, self.GoOGroup, self)
	end

	GOUtil.SetActive(self.GoCGroup, #self.listC > 0)

	if #self.listC > 0 then
		self.listCCell = Tenary(self.listCCell, {})

		DealNewCell(self.listC, self.listCCell, self.GoCGroup, self)
	end

	GOUtil.SetActive(self.GoBGroup, #self.listB > 0)

	if #self.listB > 0 then
		self.listBCell = Tenary(self.listBCell, {})

		DealNewCell(self.listB, self.listBCell, self.GoBGroup, self)
	end

	local cw = GOUtil.GetRectTransformSizeDeltaWidth(self.PrefabCellCardSkill)
	local gspace = 30
	local startx = 20
	local ospace = GOUtil.GetComponent(self.GoOGroup, "HorizontalLayoutGroup").spacing
	local ogw = cw * #self.listO + ospace * (#self.listO - 1)

	GOUtil.SetRectTransformAnchoredPosition(self.GoOGroup, startx, 0)

	local num = #self.listO
	local cgx = startx + cw * num + (num - 1) * ospace + TenaryOp(#self.listC > 0, gspace, 0)

	GOUtil.SetRectTransformAnchoredPosition(self.GoCGroup, cgx, 0)

	local cgw = TenaryOp(#self.listC > 0, GOUtil.GetRectTransformSizeDeltaWidth(self.GoCGroup), 0)
	local bgx = cgx + cgw + gspace

	GOUtil.SetRectTransformAnchoredPosition(self.GoBGroup, bgx, 0)
end

function DlgCardOverviewPanel:GetCardSkill()
	self.listSkill = {}

	if self.onlyShow then
		self.listSkill = self.infoRoleCard.listAllSkill
	else
		self.listSkill = self.infoRoleCard.listAllSkill
	end

	self.listO = {}
	self.listC = {}
	self.listB = {}

	for _, v in ipairs(self.listSkill) do
		if v.data.BattleSkillType == eBattleTalentType.Center then
			table.insert(self.listC, v)
		elseif v.data.BattleSkillType == eBattleTalentType.SpecialBall then
			table.insert(self.listB, v)
		else
			table.insert(self.listO, v)
		end
	end
end

function DlgCardOverviewPanel:UpdateDynamicVal()
	self:UpdateCardLevel()
	self:UpdateCardAttr()
	self:UpdateCardSkill()
end

function DlgCardOverviewPanel:UpdateCardLevel()
	local maxLevel = self.infoRoleCard.maxLevel
	local curLevel = self.infoRoleCard.curLevel

	self.TxtCardLv.text = string.format(_("Desc_Level_Common1"), curLevel)

	if curLevel < maxLevel then
		local curExp = self.infoRoleCard.curExp or 0
		local nextExp = self.infoRoleCard.nextExp or 0

		if nextExp < curExp then
			curExp = nextExp
		end

		self.ImgCardExp.fillAmount = curExp / nextExp
		self.TxtCardExp.text = curExp .. "/" .. nextExp
	else
		self.ImgCardExp.fillAmount = 1
		self.TxtCardExp.text = Lang(12923)
	end

	if self.onlyShow then
		GOUtil.SetActive(self.BtnUpLv, false)
	end

	self:UpdateUpLvState()
end

function DlgCardOverviewPanel:UpdateUpLvState()
	if self.onlyShow then
		return
	end

	local gray = 0
	local curLevel = self.infoRoleCard.curLevel

	if curLevel >= self.infoRoleCard.maxLevel or curLevel >= self.infoRoleCard.curLimitLevel then
		gray = 1
	end

	if gray == 0 then
		if PlayerInst:GetGold() == 0 then
			gray = 1
		else
			local info

			for _, v in pairs(ItemManager.listExpId) do
				local temp = ItemManager:Get(v)

				if temp:GetCurResNum() > 0 and (not info or info.data.Value > temp.data.Value) then
					info = temp
				end
			end

			if not info or PlayerInst:GetGold() < info.data.Value * GetConfigArgInt("GoldPerExp") then
				gray = 1
			end
		end
	end

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnUpLv, gray))
end

function DlgCardOverviewPanel:UpdateCardAttr()
	for i = 1, ATTRIBUTE_USE_CNT do
		self["TxtAttValue" .. i].text = math.floor(self.infoRoleCard.attrs:Get(i) + 0.5)
	end
end

function DlgCardOverviewPanel:UpdateCardSkill()
	UpdateCellInstance(self.listO, self.listOCell, self.infoRoleCard, CELL_CARD_SKILL_TYPE.Skill, self.onlyShow)
	UpdateCellInstance(self.listC, self.listCCell, self.infoRoleCard, CELL_CARD_SKILL_TYPE.Skill, self.onlyShow)
	UpdateCellInstance(self.listB, self.listBCell, self.infoRoleCard, CELL_CARD_SKILL_TYPE.Ball, self.onlyShow)
end

function DlgCardOverviewPanel:UpdateCardSkillUp(_type)
	local function IsUnlock(id)
		local tbl = self.infoRoleCard.data.StarTalent[self.infoRoleCard.curStarLevel + 1]

		return table.contains(tbl, id)
	end

	local function IsUpLv(id)
		local tbl = self.infoRoleCard.data.FlowerSkill[self.infoRoleCard.curPetal]

		return tbl[1] == id
	end

	if self.listOCell then
		for k, v in ipairs(self.listOCell) do
			if k <= #self.listO then
				if _type == 1 then
					if IsUnlock(self.listO[k].id) then
						v:UpdateSkillUnlock()
						v:UpdateSkillLevel()
					end
				elseif IsUpLv(self.listO[k].id) then
					v:UpdateSkillLevel()
				end
			end
		end
	end

	if self.listCCell then
		for _, v in ipairs(self.listCCell) do
			if k <= #self.listC then
				if _type == 1 then
					if IsUnlock(self.listC[k].id) then
						v:UpdateSkillUnlock()
						v:UpdateSkillLevel()
					end
				elseif IsUpLv(self.listC[k].id) then
					v:UpdateSkillLevel()
				end
			end
		end
	end

	if self.listBCell then
		for k, v in ipairs(self.listBCell) do
			if k <= #self.listB and _type == 1 then
				v:UpdateBallUnlock()
			end
		end
	end
end

function DlgCardOverviewPanel:OnClickedBtnUpLv()
	if not GuideMgr:IsGuided(GuideFunctionType.CardLevel) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.CardLevel)
	end

	local curLevel = self.infoRoleCard.curLevel
	local limitLv = self.infoRoleCard.curLimitLevel

	if limitLv <= curLevel then
		if limitLv >= self.infoRoleCard.maxLevel then
			UIMgr.ShowMsg(_("Msg_CardLevelMax"))
		else
			UIMgr.ShowMsg(RoleCardMgr:GetCardNextLevelLimitInfo(self.infoRoleCard))
		end

		return
	end

	local data = {}

	data.roleCardId = self.infoRoleCard.id

	UIMgr.AddPanel(DlgCardLevelUp(), data)
end

function DlgCardOverviewPanel:UpdatePanelData(_type)
	if _type == eTabType.OverV then
		self:UpdateCardLevel()
	elseif _type == eTabType.Break or _type == eTabType.Bloom then
		if _type == eTabType.Break then
			self:UpdateCardSkillUp(1)
			self:UpdateCardLevel()
		else
			self:UpdateCardSkillUp(2)
		end
	end

	self:UpdateCardAttr()
end

function DlgCardOverviewPanel:OnClickedBtnAttr()
	self.AnimBtnAttr:Play("Anim_OverView_BtnAttr_Open", 0, 0)
	self:OnShowCardAttr()
end

function DlgCardOverviewPanel:OnShowCardAttr()
	local data = {
		onlyShow = self.onlyShow,
		infoRoleCard = self.infoRoleCard,
		cb = function()
			self.AnimBtnAttr:Play("Anim_OverView_BtnAttr_Close", 0, 0)
		end
	}

	UIMgr.AddPanel(DlgCardAttr(), data)
end

function DlgCardOverviewPanel:OnClickedGoHead()
	if self.onlyShow then
		return
	end

	local panel = UIMgr.GetPrePanel()

	if panel.className == "PageRole" then
		self.parentPanel:OnBack()
	else
		require("UI/Page/PageRole/PageRole")

		self.parentPanel.needResetStackData = true

		UIMgr.SwitchPanel(PageRole, {
			roleId = self.infoRoleCard.data.CharacterID
		})
	end
end
