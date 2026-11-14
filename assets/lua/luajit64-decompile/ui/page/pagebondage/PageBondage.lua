-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBondage/PageBondage.lua

require("UI/Page/PageBondage/CellBondageSkill")
require("UI/Page/PageBondage/DlgBondageSkillUpgrade")
require("UI/Page/PageBondage/DlgBondageSkillTip")

PageBondage = class("PageBondage", UIPanel, true)

function PageBondage:ctor()
	self.UIPrefabPath = "UI/PanelBondage/PanelBondage"

	self:AddChildPanel(DlgExit(), {
		title = _("PageRole_Fetter"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
end

function PageBondage:PreLoad()
	self:LoadResAsync("UI/PanelBondage/CellBondageSkill", "PrefabCell", GameObject)

	self.UnlockEffPath = "Fx/UI/FX_UI_003/FX_UI_003"
	self.RankChangeEffPath = "Fx/UI/FX_UI_Glow/FX_Rank_Glow01"
	self.LevelUpEffPath = "Fx/UI/FX_UI_Welfare/FX_CellBondageSkill"
end

function PageBondage:OnBack()
	UIMgr.PopPanel()
end

function PageBondage:Purge()
	self.base.Purge(self)
	self:OnLeave()

	if self.timer1 then
		TimerMgr.RemoveTimer(self.timer1)

		self.timer1 = nil
	end

	if self.timer2 then
		TimerMgr.RemoveTimer(self.timer2)

		self.timer2 = nil
	end

	if self.timer3 then
		TimerMgr.RemoveTimer(self.timer3)

		self.timer3 = nil
	end

	ResourceMgr.Unload(self.PrefabCell)
	InfoSoundEventMgr:OnBack()
end

function PageBondage:OnLeave()
	if self.listCellSkill then
		for k, v in pairs(self.listCellSkill) do
			if self["UnlockEffHandle" .. k] then
				EffectMgr:Free(self["UnlockEffHandle" .. k])
			end

			v:OnLeave()
		end

		self.listCellSkill = nil
	end

	if self.listCellCombination then
		for k, v in pairs(self.listCellCombination) do
			if self["EffHandle" .. k] then
				EffectMgr:Free(self["EffHandle" .. k])
			end

			self:RemoveClick(v, self.OnClickedCombination)
		end

		self.listCellCombination = nil
	end

	if self.rankEffHandle then
		EffectMgr:Free(self.rankEffHandle)
	end

	EffectMgr:UnLoadEffect(self.UnlockEffPath)
	EffectMgr:UnLoadEffect(self.LevelUpEffPath)
	EffectMgr:UnLoadEffect(self.RankChangeEffPath)
end

function PageBondage:OnRegisterEvent()
	Event.Instance:Add("UpdateBondageAfterUpgrade", self.UpdateAfterUpgrade, self)
	Event.Instance:Add("ShowUpgradePanel", self.ShowUpgradePanel, self)
end

function PageBondage:OnUnRegisterEvent()
	Event.Instance:Remove("UpdateBondageAfterUpgrade", self.UpdateAfterUpgrade, self)
	Event.Instance:Remove("ShowUpgradePanel", self.ShowUpgradePanel, self)
end

function PageBondage:OnEnter(vParam)
	if not GuideMgr:IsGuided(GuideFunctionType.Bondage) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.Bondage)
	end

	self.ImgCombBg = self:GetChildComponent("Bg/BgTeam/TeamBg", "RawImage")

	for i = 1, 4 do
		self["ImgCorner" .. i] = self:GetChildComponent("Bg/BgLine/Corner" .. i, "Image")
		self["ImgLine" .. i] = self:GetChildComponent("Bg/BgLine/Line" .. i, "Image")

		if i <= 2 then
			self["ImgSkillLine" .. i] = self:GetChildComponent("Panel/BgSkill/Image" .. i, "Image")
		end
	end

	self.ImgCombBgList = self:GetChildComponent("Panel/TeamList/BgList", "Image")
	self.GoRate = self:GetChildGameObject("Panel/Rank/Rank/Rate")
	self.GoMax = self:GetChildGameObject("Panel/Rank/Rank/Max")
	self.ImgBondageRank = self:GetChildComponent("Panel/Rank/Rank", "Image")
	self.ImgBondageRate = self:GetChildComponent("Panel/Rank/Rank/Rate/Bar", "Image")
	self.AnimRank = self:GetChildComponent("Panel/Rank/Rank", "Animator")
	self.GoCombContent = self:GetChildGameObject("Panel/TeamList/ScrollArea/Content")
	self.GoSkillContent = self:GetChildGameObject("Panel/BgSkill/ScrollArea/Content")
	self.BlockRaycast = self:GetChildGameObject("BlockRaycast")
	self.listComb = CombinationMgr.GetAllBondageCombination()
	self.CombVersionCnt = #self.listComb

	for i = 1, self.CombVersionCnt do
		self["GoComb" .. i] = self:GetChildGameObject("Bg/Team/" .. i)
	end

	self:Init()
end

function PageBondage:Init()
	table.sort(self.listComb, function(a, b)
		return a.data.TeamOrder < b.data.TeamOrder
	end)

	self.listCombId = {}

	for _, v in ipairs(self.listComb) do
		table.insert(self.listCombId, v.id)
	end

	self.preCombIdx = 1
	self.curCombIdx = 1

	self:UpdateCombination()
	self:InitCombinationList()
end

function PageBondage:UpdateCombination()
	local preCombId = self.listCombId[self.preCombIdx]
	local curCombId = self.listCombId[self.curCombIdx]

	self.infoCombination = self.listComb[self.curCombIdx]

	if not self.infoCombination then
		return
	end

	self.listSkill = self.infoCombination.listSkill

	if not IsNil(self["GoComb" .. preCombId]) then
		GOUtil.SetActive(self["GoComb" .. preCombId], false)
	end

	if not IsNil(self["GoComb" .. curCombId]) then
		GOUtil.SetActive(self["GoComb" .. curCombId], true)
	else
		return
	end

	for _, role in ipairs(self.infoCombination.listRole) do
		local roleGo = GOUtil.FindChildGameObject(self["GoComb" .. curCombId], tostring(role.id))

		if roleGo then
			GOUtil.SetActive(roleGo, true)

			local img = GOUtil.GetComponent(roleGo, "GradientImage")
			local goGray = GOUtil.FindChildGameObject(roleGo, "Image")

			GOUtil.SetActive(goGray, not role.hold)
		end
	end

	SetRawImageTexture(self.ImgCombBg, "Texture/PanelBondage/ART_UI_001_0" .. curCombId .. "_back", self)
	SetImageSprite(self.ImgCombBgList, "UI/PanelBondage/AtlasPanelBondage/BG_teamback_0" .. curCombId, self)

	local color = getColorFromString(self.infoCombination.data.Color)

	for i = 1, 4 do
		SetImageSprite(self["ImgCorner" .. i], "UI/PanelBondage/AtlasPanelBondage/BG_fetter_frame_0" .. curCombId .. "a", self)

		if i % 2 ~= 0 then
			SetImageSprite(self["ImgLine" .. i], "UI/PanelBondage/AtlasPanelBondage/BG_fetter_frame_0" .. curCombId .. "b", self)
		else
			SetImageSprite(self["ImgLine" .. i], "UI/PanelBondage/AtlasPanelBondage/BG_fetter_frame_0" .. curCombId .. "c", self)
		end

		if i <= 2 then
			UIUtil.SetGraphicColorRGB(self["ImgSkillLine" .. i], color.r, color.g, color.b)
		end
	end

	if not self.listCellSkill then
		self:InitBondageSkill()
	else
		self:UpdateBondageSkill()
	end
end

function PageBondage:InitBondageSkill()
	self.listCellSkill = {}

	for i = 1, #self.listSkill do
		local cell = CellBondageSkill(self.PrefabCell, self.GoSkillContent, self)

		cell:Create()
		table.insert(self.listCellSkill, cell)
	end

	self:UpdateBondageSkill()
end

local function GetBondageRate(lv)
	local rank = CombBondageMgr:GetBondageRankBySumLv(lv)
	local targLv = CombBondageMgr:GetBondageRankInfo(rank)
	local expRank = rank

	if expRank > #GetConfigArgJson("FetterLevelNeedExp") then
		expRank = rank - 1
	end

	local needLv = GetConfigArgJson("FetterLevelNeedExp")[expRank]
	local leftLv = targLv - lv

	return 1 - leftLv / needLv
end

function PageBondage:UpdateBondageSkill()
	for k, v in pairs(self.listCellSkill) do
		if k <= #self.listSkill then
			v:UpdateData(self.listSkill[k], self.infoCombination)
		end

		if #self.listSkill ~= #self.listCellSkill then
			GOUtil.SetActive(v.UIRootObject, k <= #self.listSkill)
		end
	end

	local function SetBondageRank(level)
		local rank = CombBondageMgr:GetBondageRankBySumLv(level)

		UIUtil.SetImageSprite(self.ImgBondageRank, "UI/PanelBondage/AtlasPanelBondage/IC_fetter_crown_0" .. rank, self)
		self:UpdateCombinationList()

		if level >= CombBondageMgr.MaxLevel then
			GOUtil.SetActive(self.GoRate, false)
			GOUtil.SetActive(self.GoMax, true)
		else
			GOUtil.SetActive(self.GoRate, true)
			GOUtil.SetActive(self.GoMax, false)

			local rate = GetBondageRate(level)

			self.ImgBondageRate.fillAmount = rate
		end
	end

	local unlocks = CombBondageMgr.GetJustUnlockSkillIds(self.infoCombination.id)

	if unlocks and #unlocks > 0 then
		SetBondageRank(self.infoCombination.preBondageLv)
	else
		SetBondageRank(self.infoCombination.curBondageLv)
	end

	self:DealWithBondageSkillUnlock()
end

function PageBondage:InitCombinationList()
	local cellCombination = self:GetChildGameObject("Panel/TeamList/CellTeam")

	self.listCellCombination = {}

	for i = 1, self.CombVersionCnt do
		local combId = self.listCombId[i]
		local go = GOUtil.Instantiate(cellCombination, self.GoCombContent)

		go.name = i

		local icon = GOUtil.FindChildComponent(go, "Info/Icon", "Image")

		SetImageSprite(icon, "UI/PanelBondage/Team/AtlasTeam" .. combId .. "/BG_fetter_frame_0" .. combId, self)
		self:AddClick(go, self.OnClickedCombination)
		table.insert(self.listCellCombination, go)
		RedDotSystemMgr.SetUIRedDot(go, "Arrow/Bondage/Unlock/" .. combId)
	end

	self:UpdateCombinationList()
end

function PageBondage:OnClickedCombination(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)

	if self.curCombIdx == index then
		return
	end

	self.preCombIdx = self.curCombIdx
	self.curCombIdx = index

	self:UpdateCombinationCell(self.preCombIdx)
	self:UpdateCombinationCell(self.curCombIdx)
	self:UpdateCombination()
end

function PageBondage:UpdateCombinationList()
	if not self.listCellCombination then
		return
	end

	for idx in ipairs(self.listCellCombination) do
		self:UpdateCombinationInfo(idx)
		self:UpdateCombinationCell(idx)
	end
end

function PageBondage:UpdateCombinationInfo(index)
	if IsNil(self["ImgCellRank" .. index]) then
		self["ImgCellRank" .. index] = GOUtil.FindChildComponent(self.listCellCombination[index], "Info/Rank", "Image")
	end

	local rank = CombBondageMgr:GetBondageRank(self.listCombId[index])

	SetImageSprite(self["ImgCellRank" .. index], "UI/PanelBondage/AtlasPanelBondage/IC_fetter_crown_0" .. rank .. "a", self)
end

function PageBondage:UpdateCombinationCell(index)
	local alpha = TenaryOp(self.curCombIdx == index, 1, 0.65)

	if IsNil(self["CanvasGroup" .. index]) then
		self["CanvasGroup" .. index] = GOUtil.FindChildComponent(self.listCellCombination[index], "Info", "CanvasGroup")
	end

	self["CanvasGroup" .. index].alpha = alpha
end

function PageBondage:UpdateCombinationBondageLevelRank(preLevel)
	preLevel = preLevel or self.infoCombination.preBondageLv

	local preRank = CombBondageMgr:GetBondageRankBySumLv(preLevel)
	local curRank = CombBondageMgr:GetBondageRankBySumLv(self.infoCombination.curBondageLv)

	if curRank ~= preRank then
		self:PlayRankChange()
	else
		self:PlayRankNoChange()
	end
end

function PageBondage:DealWithBondageSkillUnlock()
	if not self.listCellSkill then
		return
	end

	local unlocks = CombBondageMgr.GetJustUnlockSkillIds(self.infoCombination.id) or {}

	if #unlocks > 0 then
		CombBondageMgr.ResetJustUnlockSkills(self.infoCombination.id)
	end

	local idxs = {}

	for _, v in ipairs(unlocks) do
		for k, n in ipairs(self.infoCombination.listSkill) do
			if v == n.id then
				table.insert(idxs, k)
			end
		end
	end

	for k, v in ipairs(self.listCellSkill) do
		if self["UnlockEffHandle" .. k] then
			EffectMgr:Free(self["UnlockEffHandle" .. k])

			self["UnlockEffHandle" .. k] = nil
		end

		if table.contains(idxs, k) then
			self["UnlockEffHandle" .. k] = EffectMgr:Alloc(self.UnlockEffPath, v.GoLock)

			SoundMgr.Play(PATH_SFX_UI_CHAPTER_UNLOCK)
		end
	end

	if #unlocks > 0 then
		self.timer1 = TimerMgr.AddTimer(eTimerType.ScaleTime, 1, function()
			for _, v in ipairs(idxs) do
				if self.listCellSkill[v] then
					self.listCellSkill[v]:UpdateState()
				end
			end

			local preLv = self.infoCombination.curBondageLv - #unlocks

			self:UpdateCombinationBondageLevelRank(preLv)

			self.timer1 = nil
		end, nil)
	end
end

function PageBondage:PlayRankNoChange()
	local rate = GetBondageRate(self.infoCombination.curBondageLv)

	GOUtil.DOFillAmount(self.ImgBondageRate, rate, 0.3)

	if self.infoCombination:GetBondageLevel() >= CombBondageMgr.MaxLevel then
		GOUtil.SetActive(self.GoRate, false)
		GOUtil.SetActive(self.GoMax, true)
	end
end

function PageBondage:PlayRankChange()
	if self.rankEffHandle then
		EffectMgr:Free(self.rankEffHandle)

		self.rankEffHandle = nil
	end

	local rate = GetBondageRate(self.infoCombination.curBondageLv)
	local tweener1 = GOUtil.DOFillAmount(self.ImgBondageRate, 1, 0.2)

	GOUtil.SetTweenerCallback(tweener1, DG.Tweening.TweenCallback(function()
		self.rankEffHandle = EffectMgr:Alloc(self.RankChangeEffPath, self.ImgBondageRank.gameObject)

		self.AnimRank:Play("PanelBondage_RankOpen")

		local function fun()
			local curRank = CombBondageMgr:GetBondageRank(self.infoCombination.id)

			UIUtil.SetImageSprite(self.ImgBondageRank, "UI/PanelBondage/AtlasPanelBondage/IC_fetter_crown_0" .. curRank, self)
			self:UpdateCombinationList()

			if self.infoCombination:GetBondageLevel() >= CombBondageMgr.MaxLevel then
				-- block empty
			else
				GOUtil.DOFillAmount(self.ImgBondageRate, 0, 0.3)
			end

			self:AfterCellPlayAnim()

			self.timer2 = nil
		end

		self.timer2 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.5, fun, nil)
	end))
end

function PageBondage:AfterCellPlayAnim()
	self:UpdateCombinationInfo(self.curCombIdx)
end

function PageBondage:ShowUpgradePanel(data)
	self.OpSkill = data.skill

	UIMgr.AddPanel(DlgBondageSkillUpgrade(), data, self.UIRootObject)
end

function PageBondage:UpdateAfterUpgrade()
	GOUtil.SetActive(self.BlockRaycast, true)

	local list = self.infoCombination.listSkill

	for k, v in ipairs(self.listCellSkill) do
		if self["EffHandle" .. k] then
			EffectMgr:Free(self["EffHandle" .. k])

			self["EffHandle" .. k] = nil
		end

		if self.OpSkill.id == list[k].id then
			self["EffHandle" .. k] = EffectMgr:Alloc(self.LevelUpEffPath, v.ImgSkillIcon.gameObject)

			local function fun()
				v:UpdateData(list[k], self.infoCombination)
				self:UpdateCombinationBondageLevelRank()
				GOUtil.SetActive(self.BlockRaycast, false)

				self.timer3 = nil
			end

			self.timer3 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.6, fun, {})
		end
	end
end

function PageBondage:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Bondage)
end
