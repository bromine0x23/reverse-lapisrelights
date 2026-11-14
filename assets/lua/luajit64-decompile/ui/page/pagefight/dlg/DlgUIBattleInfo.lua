-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIBattleInfo.lua

DlgUIBattleInfo = class("DlgUIBattleInfo", UIPanel_sync)

require("UI/Page/PageFight/Cells/CellHpBar")
require("UI/Page/PageFight/Dlg/DlgUIEnemyInfo")
require("UI/Page/PageFight/Dlg/DlgUIEnemyBossInfo")
require("UI/Dlg/Common/SkillTip")

local _BuffData = require("luaData/BattleBuffData")
local _effectCfg = require("luaData/EffectData")
local MAX_ENEMY_COUNT = 5

function DlgUIBattleInfo:ctor()
	DlgUIBattleInfo.base.ctor(self, "UI/PageFight/Dlg/DlgUIBattleInfo")
	GP.PrewarmUtil:SpritePath("UI/PageFight/AtlasBattleInfo/ui_hd_button_cn_skip_0002")
	GP.PrewarmUtil:SpritePath("UI/PageFight/AtlasBattleInfo/ui_hd_button_cn_skip_0001")
	GP.PrewarmUtil:SpritePath("UI/PageFight/AtlasBattleInfo/ui_hd_button_cn_skip_0000")

	if GP.GameStartData.bondage ~= nil and GP.GameStartData.bondage.combinationId ~= nil then
		local combinationId = GP.GameStartData.bondage.combinationId
		local teamIconPath = "UIDyAtlas/Team/IC_SKI_jb_0" .. combinationId

		GP.PrewarmUtil:SpritePath(teamIconPath)
	end

	self.hpFxPath = "Fx/UI/Eff_Ui_Battle_HPSubtract/Eff_Ui_Battle_HPSubtract"
	self.mpFxPath = "Fx/UI/Eff_Ui_Battle_MPRecover/Eff_Ui_Battle_MPRecover"
	self.shieldFxPath = "Fx/UI/FX_UI_Battle_Shield/FX_UI_Shield_hit"
	self.shieldFxBreakPath = "Fx/UI/FX_UI_Battle_Shield/FX_UI_Shield_break"
	self.shieldFxFullPath = "Fx/UI/FX_UI_Battle_Shield/FX_UI_Shield_full"
	self.shieldFxRepairPath = "Fx/UI/FX_UI_Battle_Shield/FX_UI_Shield_repair"
	self.shieldFxBreakPath_pvp = "Fx/UI/FX_UI_Battle_Shield/FX_UI_Shield_break_top"
	self.shieldFxRepairPath_pvp = "Fx/UI/FX_UI_Battle_Shield/FX_UI_Shield_repair_top"
	self.DlgUIEnemyInfoList = {}

	for i = 1, MAX_ENEMY_COUNT do
		local item = DlgUIEnemyInfo()
		local vParam = {}

		vParam.index = i

		self:AddChildPanel(item, vParam)
		table.insert(self.DlgUIEnemyInfoList, item)
	end

	self.DlgUIEnemyBossInfo = DlgUIEnemyBossInfo()

	local vParam = {}

	vParam.index = 1

	self:AddChildPanel(self.DlgUIEnemyBossInfo, vParam)

	self.CellBuffIcons = CellBuffIcons()

	self:AddChildPanel(self.CellBuffIcons)

	self.CellAutoBtn = CellAutoBtn()

	self:AddChildPanel(self.CellAutoBtn)

	self.CellBtnSkip = CellBtnSkip()

	self:AddChildPanel(self.CellBtnSkip)
end

function DlgUIBattleInfo:Cache()
	DlgUIBattleInfo.base.Cache(self)
	EffectMgr:Cache("Fx/UI/Eff_Ui_Battle_MPRecover/Eff_Ui_Battle_MPRecover", 1)
	EffectMgr:Cache("Fx/UI/Eff_Ui_Battle_HPSubtract/Eff_Ui_Battle_HPSubtract", 1)
	EffectMgr:Cache(self.hpFxPath, 1)
	EffectMgr:Cache(self.mpFxPath, 1)
	EffectMgr:Cache(self.shieldFxPath, 1)
	EffectMgr:Cache(self.shieldFxBreakPath, 1)
	EffectMgr:Cache(self.shieldFxFullPath, 1)
	EffectMgr:Cache(self.shieldFxRepairPath, 1)
	EffectMgr:Cache(self.shieldFxBreakPath_pvp, 1)
	EffectMgr:Cache(self.shieldFxRepairPath_pvp, 1)
end

function DlgUIBattleInfo:Close(tParam)
	DlgUIBattleInfo.base.Close(self, tParam)
end

function DlgUIBattleInfo:Purge()
	self.mpbar_player:Reset()
	self.shieldbar_player:Reset()
	self.mpbar_pvp:Reset()
	self.shieldbar_pvp:Reset()
	DlgUIBattleInfo.base.Purge(self)

	self.btn_menu = nil
	self.txt_time = nil
	self.txt_round = nil
	self.txt_wave = nil
	self.btn_speed = nil
	self.img_btnSpeed = nil
	self.obj_operatorRoot = nil
	self.ani_panel = nil
	self.mpbar_player = nil
	self.shieldbar_player = nil
	self.isShieldBreak = false
	self.isShieldBreak_pvp = false
	self.mpbar_pvp = nil
	self.shieldbar_pvp = nil
	self.hpFxPath = ""
	self.mpFxPath = ""
	self.shieldFxPath = ""
	self.shieldBreakImg = nil
	self.shieldImg = nil
	self.OpenAnimCallback = nil

	UIMgr:RemoveSafeArea(self)
end

function DlgUIBattleInfo:OnRegisterEvent()
	self:AddClick(self.btn_menu, self.OnBtnMenuClick)
	self:AddClick(self.btn_speed, self.OnBtnSpeedClick)
	self:AddClick(self.btn_suggest, self.OnBtnSuggestClick)
	self:AddClick(self.btn_hideUI, self.OnBtnHideUIClick)
	self:AddClick(self.btn_exitReplay, self.OnBtnExitReplayClick)
	Event.Instance:Add("SetGameSpeedMode", self.OnSetGameSpeedMode, self)
	Event.Instance:Add("TeamUpdateAttri", self.OnTeamUpdateAttri, self)
	Event.Instance:Add("WhippedCorpseAwards", self.OnWhippedCorpseAwards, self)
	self:AddListener(self.skillTipsArea, self.OnPointerDownSkill, EventTriggerType.PointerLongPress)
	self:AddListener(self.linkSkillTipsArea, self.OnPointerDownLinkSkill, EventTriggerType.PointerLongPress)
	self:AddClick(self.btn_whippedCorpseAward.gameObject, self.OnPointerDownAwardsTotal)
	self:AddClick(self.btn_close_whippedCorpseAward.gameObject, self.OnCloseWhipAwardDlg)
	Event.Instance:Add("SetGuideBtn", self.OnSetGuideBtn, self)
end

function DlgUIBattleInfo:OnUnRegisterEvent()
	self:RemoveClick(self.btn_menu, self.OnBtnMenuClick)
	self:RemoveClick(self.btn_speed, self.OnBtnSpeedClick)
	self:RemoveClick(self.btn_suggest, self.OnBtnSuggestClick)
	self:RemoveClick(self.btn_hideUI, self.OnBtnHideUIClick)
	self:RemoveClick(self.btn_exitReplay, self.OnBtnExitReplayClick)
	Event.Instance:Remove("SetGameSpeedMode", self.OnSetGameSpeedMode, self)
	Event.Instance:Remove("TeamUpdateAttri", self.OnTeamUpdateAttri, self)
	Event.Instance:Remove("WhippedCorpseAwards", self.OnWhippedCorpseAwards, self)
	self:RemoveListener(self.skillTipsArea, self.OnPointerDownSkill, EventTriggerType.PointerLongPress)
	self:RemoveListener(self.linkSkillTipsArea, self.OnPointerDownLinkSkill, EventTriggerType.PointerLongPress)
	self:RemoveClick(self.btn_whippedCorpseAward.gameObject, self.OnPointerDownAwardsTotal)
	self:RemoveClick(self.btn_close_whippedCorpseAward.gameObject, self.OnCloseWhipAwardDlg)
	Event.Instance:Remove("SetGuideBtn", self.OnSetGuideBtn, self)
end

function DlgUIBattleInfo:OnPointerDownSkill(data)
	local haloSkillUnit = self:GetHaloSkillUnit()

	if haloSkillUnit == nil then
		return
	end

	if data.clickCount == 1 then
		local tipData = SkillTip.GetHeroData(data.position, haloSkillUnit.AllSkillId, haloSkillUnit.Level, 0)

		UIMgr.ShowSkillTip(tipData)
	else
		UIMgr.HideSkillTip()
	end
end

function DlgUIBattleInfo:OnPointerDownLinkSkill(data)
	local linkSkills = self:GetLinkSkillUnit()

	if #linkSkills == 0 then
		return
	end

	if data.clickCount == 1 then
		local datas = {}

		for i, skill in ipairs(linkSkills) do
			table.insert(datas, SkillTip.GetHeroData(data.position, skill.AllSkillId, skill.AllSkillLv, 0))
		end

		UIMgr.ShowSkillTips(datas, data.position)
	else
		UIMgr.HideSkillTips()
	end
end

function DlgUIBattleInfo:OnEnter(vParam)
	UIMgr:SetSafeArea(self, self:GetChildGameObject("panel/top"))
	UIMgr:SetSafeArea(self, self:GetChildGameObject("panel/bottom/obj_operatorParent"))
	self:DealWithLocalization()

	self.isInit = false
	self.btn_menu = self:GetChildGameObject("panel/top/btn_menu")
	self.img_btnMenu = self:GetChildComponent("panel/top/btn_menu", "Image")
	self.txt_time = self:GetChildComponent("panel/top/txt_time", "Text")
	self.txt_round = self:GetChildComponent("panel/top/txt_round", "Text")

	UIUtil.SetTextString(self.txt_round, string.format("%d/%d", 1, GP.StageData:GetData().MaxRound))

	self.txt_wave = self:GetChildComponent("panel/top/txt_wave", "Text")
	self.btn_exitReplay = self:GetChildGameObject("panel/top/btn_exitReplay")
	self.btn_speed = self:GetChildGameObject("panel/top/btn_speed")
	self.btn_suggest = self:GetChildGameObject("panel/top/btn_suggest")
	self.btn_hideUI = self:GetChildGameObject("panel/top/btn_hideUI")

	if GP.FightMode ~= EnumFight.BattleType.BOSS then
		GOUtil.SetActive(self.btn_hideUI, false)
	end

	self.img_btnSpeed = self:GetChildComponent("panel/top/btn_speed", "Image")
	self.obj_operatorRoot = self:GetChildGameObject("panel/bottom/obj_operatorParent")
	self.ani_panel = self:GetChildComponent("panel", "Animator")
	self.img_replayTip = self:GetChildGameObject("panel/top/img_replayTip")
	self.btn_whippedCorpseAward = self:GetChildGameObject("panel/top/whippedCorpseAwards")
	self.btn_close_whippedCorpseAward = self:GetChildGameObject("panel/top/CorpseAwardsGroup")
	self.whippedCorpseAwardsBg = self:GetChildGameObject("panel/top/CorpseAwardsGroup")
	self.obj_roundEff = self:GetChildGameObject("panel/top/FX_Image")

	GOUtil.SetActive(self.obj_roundEff, false)
	self.CellAutoBtn:SetParent(self:GetChildGameObject("panel/top/obj_autoBtnRoot"))
	self.CellBtnSkip:SetParent(self:GetChildGameObject("panel/top/obj_skipBtnRoot"))

	self.whippedCorpseAwardsCount = {}
	self.whippedCorpseAwardsPos = {}

	for i = 1, 3 do
		self.whippedCorpseAwardsCount[i] = self:GetChildComponent("panel/top/CorpseAwardsGroup/content/whippedCorpseAwards" .. i .. "/txt_count", "Text")
		self.whippedCorpseAwardsCount[i].text = "0"
	end

	self.whippedCorpseAwardsTotal = self:GetChildComponent("panel/top/whippedCorpseAwards/txt_count", "Text")
	self.whippedCorpseAwardsTotal.text = "0"
	self.whippedCorpseAwardsTotalPos = self:GetChildGameObject("panel/top/whippedCorpseAwardsTotalPos/Pos")
	self.mpbar_player = CellHpBar(self:GetChildGameObject("panel/bottom/obj_operatorParent/player_attributes/mpBar"))
	self.shieldbar_player = CellHpBar(self:GetChildGameObject("panel/bottom/obj_operatorParent/player_attributes/shieldBar"))
	self.isShieldBreak = false
	self.isShieldBreak_pvp = false

	if GP.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		local go = self:GetChildGameObject("panel/top/pvp_attributes")

		GOUtil.SetActive(go, true)
		GOUtil.SetActive(self.btn_whippedCorpseAward, false)
	end

	self.mpbar_pvp = CellHpBar(self:GetChildGameObject("panel/top/pvp_attributes/mpBar"))
	self.shieldbar_pvp = CellHpBar(self:GetChildGameObject("panel/top/pvp_attributes/shieldBar"))

	if GP.StageData:GetData().OverDropPR == 0 then
		GOUtil.SetActive(self.btn_whippedCorpseAward, false)
	end

	self.shieldBreakImg = self:GetChildGameObject("panel/bottom/obj_operatorParent/player_attributes/shieldBar/smallImg/bg_dp_break")
	self.shieldImg = self:GetChildGameObject("panel/bottom/obj_operatorParent/player_attributes/shieldBar/smallImg/bg_dp")
	self.shieldBreakImg_pvp = self:GetChildGameObject("panel/top/pvp_attributes/shieldBar/smallImg/bg_dp_break")
	self.shieldImg_pvp = self:GetChildGameObject("panel/top/pvp_attributes/shieldBar/smallImg/bg_dp")

	local enemyInfoItem = self:GetChildGameObject("panel/top/enemyInfoRoot")

	self.enemyHPCons = {}

	for i, item in ipairs(self.DlgUIEnemyInfoList) do
		local con = self:GetChildGameObject("panel/top/enemyInfoRoot/" .. "con" .. i)

		table.insert(self.enemyHPCons, con)
		item:SetParent(con)
	end

	local bossInfoRoot = self:GetChildGameObject("panel/top/bossInfoRoot")

	self.DlgUIEnemyBossInfo:SetParent(bossInfoRoot)

	self.haloSkillIcon = self:GetChildComponent("panel/bottom/obj_operatorParent/player_attributes/haloSkill", "Image")
	self.linkSkillIcon = self:GetChildComponent("panel/bottom/obj_operatorParent/player_attributes/linkSkill", "Image")
	self.skillTipsArea = self:GetChildGameObject("panel/bottom/obj_operatorParent/player_attributes/skillTipsArea")
	self.linkSkillTipsArea = self:GetChildGameObject("panel/bottom/obj_operatorParent/player_attributes/linkSkillTipsArea")
	self.obj_buffsRoot = self:GetChildGameObject("panel/bottom/obj_operatorParent/player_attributes/obj_buffsRoot")

	local isReplay = GP.GameStartData.playMode == EnumFight.PlayMode.Replay

	GOUtil.SetActive(self.btn_exitReplay, isReplay)
	GOUtil.SetActive(self.img_replayTip, isReplay)
	GOUtil.SetActive(self.btn_menu, not isReplay)

	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.SpeedFight)
	local gray = TenaryOp(isOpen, 0, 1)

	UIUtil.SetImageGray(self.img_btnSpeed, gray)

	isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Option)
	gray = TenaryOp(isOpen, 0, 1)

	UIUtil.SetImageGray(self.img_btnMenu, gray)
	self:Show(false)

	if InstructionMgr:IsInGuide() then
		GOUtil.SetActive(self.btn_menu, InstructionMgr.showAutoBtn)
	end
end

function DlgUIBattleInfo:MenuActive(val)
	GOUtil.SetActive(self.btn_menu, val)

	if InstructionMgr:IsInGuide() then
		GOUtil.SetActive(self.btn_menu, InstructionMgr.showAutoBtn)
	end
end

function DlgUIBattleInfo:OnSetGuideBtn(isShow)
	if isShow == false then
		local iconPath = "UI/PageFight/SkillChange/ui_hd_button_pause_04"

		GP.SpriteUtil:SetSprite(self.img_btnMenu, iconPath)
	else
		GOUtil.SetActive(self.btn_menu, isShow)
	end
end

function DlgUIBattleInfo:DealWithLocalization()
	local txt_round_bg = self:GetChildComponent("panel/top/txt_round_bg", "Text")

	txt_round_bg.text = _("PageFight_Round")

	local txt_wave_bg = self:GetChildComponent("panel/top/txt_wave_bg", "Text")

	txt_wave_bg.text = _("PageFight_Wave")
end

function DlgUIBattleInfo:OnBtnMenuClick()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Option) then
		return
	end

	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgBattleSetting")
end

function DlgUIBattleInfo:OnBtnSuggestClick()
	Event.Instance:Fire("ReqSuggestSession")
end

function DlgUIBattleInfo:OnBtnHideUIClick()
	GP.UI.DlgUIAuto:OnBtnShowUI()
end

function DlgUIBattleInfo:OnBtnExitReplayClick()
	local function _cb(index)
		if index == 1 then
			GP:ExitGame()
		end
	end

	local _title = _("eFight_ExitReplayConfirm_Title")
	local _msg = _("eFight_ExitReplayConfirm_Body")
	local _ok = _("eFight_ExitReplayConfirm_OK")
	local _cancel = _("eFight_ExitReplayConfirm_Cancel")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _title, _msg, _cb, _ok, _cancel, false)
end

function DlgUIBattleInfo:OnBtnSpeedClick()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.SpeedFight) then
		return
	end

	local speedModeCfg = {
		EnumFight.SpeedMode.Default,
		EnumFight.SpeedMode.Fast,
		EnumFight.SpeedMode.Extreme
	}

	for i, mode in ipairs(speedModeCfg) do
		if mode == GP.SpeedMode then
			if i == #speedModeCfg then
				GP:SetGameSpeedMode(speedModeCfg[1])

				break
			end

			GP:SetGameSpeedMode(speedModeCfg[i + 1])

			break
		end
	end
end

function DlgUIBattleInfo:OnSetGameSpeedMode(speedMode)
	local imgPath = {
		"UI/PageFight/AtlasBattleInfo/ui_hd_button_cn_skip_0002",
		"UI/PageFight/AtlasBattleInfo/ui_hd_button_cn_skip_0001",
		"UI/PageFight/AtlasBattleInfo/ui_hd_button_cn_skip_0000"
	}

	if not TutorialMgr:IsOpenTut(TutorialFunctionType.SpeedFight) then
		return
	end

	local iconPath = imgPath[speedMode]

	if iconPath then
		GP.SpriteUtil:SetSprite(self.img_btnSpeed, iconPath)
	end
end

function DlgUIBattleInfo:RefreshWave(cur, max)
	UIUtil.SetTextString(self.txt_wave, string.format("%d/%d", cur, max))
	self:RefreshEnemyHpCons()
end

function DlgUIBattleInfo:RefreshEnemyHpCons()
	for _, con in ipairs(self.enemyHPCons) do
		con:SetActive(false)
	end
end

local DEST_ROUND = 3

function DlgUIBattleInfo:RefreshRound(cur, max)
	UIUtil.SetTextString(self.txt_round, string.format("%d/%d", cur, max))
	GOUtil.SetActive(self.obj_roundEff, cur >= max - DEST_ROUND)
end

function DlgUIBattleInfo:OnTeamUpdateAttri(msg)
	if msg.camp == EnumFight.Camp.PLAYER then
		if msg.attriName == "魔力" then
			self.mpbar_player:SetCur(msg.cur)
			self.mpbar_player:PlayEffect(self.mpFxPath)
		elseif msg.attriName == "最大魔力" then
			self.mpbar_player:SetMax(msg.cur)
		elseif msg.attriName == "护盾" then
			self.shieldbar_player:SetCur(msg.cur)

			if msg.cur == 0 then
				self.isShieldBreak = true

				InstructionMgr:TriggerWait("ShieldBreak")
				self.shieldbar_player:PlayEffect(self.shieldFxBreakPath)
			elseif msg.cur == GP.Team.PlayerMaxShield then
				self.shieldbar_player:PlayEffect(self.shieldFxFullPath)
			elseif self.isShieldBreak == true and msg.cur ~= 0 then
				self.isShieldBreak = false

				self.shieldbar_player:PlayEffect(self.shieldFxRepairPath)
			else
				self.shieldbar_player:PlayEffect(self.shieldFxPath)
			end

			GOUtil.SetActive(self.shieldBreakImg, msg.cur == 0)
			GOUtil.SetActive(self.shieldImg, msg.cur ~= 0)
		elseif msg.attriName == "最大护盾" then
			self.shieldbar_player:SetMax(msg.cur)
		end
	end

	if GP.GameStartData.pvp ~= EnumFight.Pvp.NONE and msg.camp == EnumFight.Camp.ENEMY then
		if msg.attriName == "魔力" then
			self.mpbar_pvp:SetCur(msg.cur)
			self.mpbar_pvp:PlayEffect(self.mpFxPath)
		elseif msg.attriName == "最大魔力" then
			self.mpbar_pvp:SetMax(msg.cur)
		elseif msg.attriName == "护盾" then
			self.shieldbar_pvp:SetCur(msg.cur)

			if msg.cur == 0 then
				self.isShieldBreak_pvp = true

				self.shieldbar_pvp:PlayEffect(self.shieldFxBreakPath_pvp)
			elseif self.isShieldBreak_pvp == true and msg.cur ~= 0 then
				self.isShieldBreak_pvp = false

				self.shieldbar_pvp:PlayEffect(self.shieldFxRepairPath_pvp)
			end

			GOUtil.SetActive(self.shieldBreakImg_pvp, msg.cur == 0)
			GOUtil.SetActive(self.shieldImg_pvp, msg.cur ~= 0)
		elseif msg.attriName == "最大护盾" then
			self.shieldbar_pvp:SetMax(msg.cur)
		end
	end
end

function DlgUIBattleInfo:Open(callback)
	self.ani_panel:Play("PageBattle_panel")
	self:Show(true)

	if callback then
		BattleConfig.Delay(0, function()
			callback()
		end)
	end

	if self.isInit == true then
		return
	end

	self.isInit = true

	local center = GP.Team.CenterUnit

	self.CellBuffIcons:Bind(center.UniqueId, self.obj_buffsRoot, EnumFight.ShowIcon.Team)

	local haloSkillUnit = self:GetHaloSkillUnit()

	if haloSkillUnit ~= nil then
		self.haloSkillIcon.enabled = true

		haloSkillUnit:SetIcon(self.haloSkillIcon)
	else
		self.haloSkillIcon.enabled = false
	end

	local vaild = false

	if GP.GameStartData.bondage then
		for k, skill in pairs(GP.GameStartData.bondage.skills) do
			if skill.canUse then
				vaild = true

				break
			end
		end
	end

	if vaild == true then
		local combinationId = GP.GameStartData.bondage.combinationId
		local teamIconPath = "UIDyAtlas/Team/IC_SKI_jb_0" .. combinationId

		self.linkSkillIcon.enabled = true

		GP.SpriteUtil:SetSprite(self.linkSkillIcon, teamIconPath)
	else
		self.linkSkillIcon.enabled = false
	end
end

function DlgUIBattleInfo:GetHaloSkillUnit()
	local center = GP.Team.CenterUnit

	for _, ownSkill in ipairs(center.OwnSkills) do
		if ownSkill.BattleSkillType == EnumFight.SkillType.Center then
			return ownSkill
		end
	end
end

function DlgUIBattleInfo:GetLinkSkillUnit()
	local skills = {}
	local center = GP.Team.CenterUnit

	for _, ownSkill in ipairs(center.OwnSkills) do
		if ownSkill.BattleSkillType == EnumFight.SkillType.Link then
			table.insert(skills, ownSkill)
		end
	end

	return skills
end

function DlgUIBattleInfo:Hide()
	self.ani_panel:Play("PageBattle_panel_close")
end

function DlgUIBattleInfo:OnWhippedCorpseAwards(uid, type)
	local camera = SceneMgr.GetCurrentScene().camera
	local canvas = UIMgr.RootCanvas
	local unit = UnitActor.FindUnitById(uid)
	local uiPos = GOUtil.GetUIPosForCameraMode(camera, canvas, unit.ActorRoot.transform.position)
	local awardGo = GOUtil.NewGameObjectUI("award", self.UIRootObject)
	local offset = 0

	if unit.UnitData.data.Boss == 1 then
		offset = 315
	end

	GOUtil.SetTransformLocalPosition(awardGo, uiPos.x, uiPos.y + offset, 0)

	local effId1 = BattleConst.whippedCorpseUI1[type]
	local effCfg1 = _effectCfg[effId1]

	EffectMgr:AllocById(effId1, awardGo)
	BattleConfig.Delay(effCfg1.Life, function()
		local effId2 = BattleConst.whippedCorpseUI2[type]
		local effCfg2 = _effectCfg[effId2]

		EffectMgr:AllocById(effId2, awardGo)

		local targetPos = self.whippedCorpseAwardsTotalPos.transform.position

		awardGo.transform:DOMove(targetPos, 1, false)
		BattleConfig.Delay(1, function()
			local countText = self.whippedCorpseAwardsCount[type]
			local totalCount = tonumber(countText.text)

			totalCount = totalCount + 1
			countText.text = totalCount
			countText = self.whippedCorpseAwardsTotal
			totalCount = tonumber(countText.text)
			totalCount = totalCount + 1
			countText.text = totalCount
		end)
		BattleConfig.Delay(effCfg2.Life + 0.5, function()
			GameObject.Destroy(awardGo)
		end)
	end)
end

function DlgUIBattleInfo:OnPointerDownAwardsTotal(data)
	local val = GOUtil.IsActiveSelf(self.whippedCorpseAwardsBg)

	self.whippedCorpseAwardsBg:SetActive(not val)
end

function DlgUIBattleInfo:OnCloseWhipAwardDlg()
	self.whippedCorpseAwardsBg:SetActive(false)
end

function DlgUIBattleInfo:OnBackAndroid()
	if not GOUtil.IsActiveSelf(self.btn_menu) then
		self:OnBtnHideUIClick()

		return true
	end

	return false
end
