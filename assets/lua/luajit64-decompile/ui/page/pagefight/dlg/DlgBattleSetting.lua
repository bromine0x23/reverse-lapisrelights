-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgBattleSetting.lua

require("UI/Page/PageCombatReadiness/DlgMonsterDes")
require("UI/Dlg/Public/GuideChooseTip")

DlgBattleSetting = class("DlgBattleSetting", UIPanel_sync)

function DlgBattleSetting:ctor()
	DlgBattleSetting.base.ctor(self, "UI/PageFight/Dlg/DlgBattleSetting")
end

function DlgBattleSetting:Cache()
	DlgBattleSetting.base.Cache(self)
end

function DlgBattleSetting:Close()
	DlgBattleSetting.base.Close(self)
end

function DlgBattleSetting:Purge()
	DlgBattleSetting.base.Purge(self)
end

function DlgBattleSetting:OnEnter()
	self.infoStage = ChapterMgr:GetStage(GP.StageId)
	self.LastAutoMode = false
	self.obj_exitBattle = self:GetChildGameObject("panel/btn_exitBattle")
	self.obj_restart = self:GetChildGameObject("panel/btn_restart")

	if GP.GameStartData.pvp ~= EnumFight.Pvp.NONE or GP.GameStartData.playMode == EnumFight.PlayMode.Replay then
		GOUtil.SetActive(self.obj_restart, false)
		GOUtil.SetActive(self:GetChildGameObject("panel/Txt/TxtRestart"), false)
	end

	self.obj_monsterDetail = self:GetChildGameObject("panel/btn_monster")
	self.obj_guide = self:GetChildGameObject("panel/btn_guide")
	self.conditions = self:GetChildGameObject("panel/conditions")
	self.noConditions = self:GetChildGameObject("panel/noConditions")
	self.noConditionTxt = self:GetChildGameObject("panel/Txt/TxtNoConditions")
	self.conditionDoneTxt = self:GetChildGameObject("panel/Txt/TxtConditionsDone")
	self.condtiontable = {}

	for i = 1, 3 do
		self.condtiontable[i] = {
			condtiontext = GOUtil.FindChildComponent(self.UIRootObject, "panel/Txt/TxtCondtion" .. i, "Text"),
			star = GOUtil.FindChildGameObject(self.UIRootObject, "panel/conditions/Star" .. i .. "/Star"),
			done = GOUtil.FindChildGameObject(self.UIRootObject, "panel/Txt/TxtDone" .. i),
			doneImg = GOUtil.FindChildGameObject(self.UIRootObject, "panel/Txt/imgDone" .. i),
			fail = GOUtil.FindChildGameObject(self.UIRootObject, "panel/Txt/TxtFail" .. i),
			failImg = GOUtil.FindChildGameObject(self.UIRootObject, "panel/Txt/imgFail" .. i)
		}
	end

	self:SetConditionVisible()

	self.mainPanel = self:GetChildGameObject("panel")
	self.panelPVP = self:GetChildGameObject("panelPVP")

	GOUtil.SetActive(self.mainPanel, true)
	GOUtil.SetActive(self.panelPVP, false)
	self:Show(false)

	self.TxtExit = self:GetChildGameObject("panel/Txt/TxtExit")
	self.TxtStageName = self:GetChildComponent("panel/Txt/TxtStageName", "Text")
	self.btn_exitBattle = self:GetChildGameObject("panel/btn_exitBattle")
	self.btn_pvpExitBattle = self:GetChildGameObject("panelPVP/btn_exitBattle")
	self.btn_restart = self:GetChildGameObject("panel/btn_restart")
	self.obj_close = self:GetChildGameObject("panel/btn_close")
	self.obj_close2 = self:GetChildGameObject("panel/btn_close2")
	self.obj_close3 = self:GetChildGameObject("panelPVP/btn_close3")
	self.btn_result = self:GetChildGameObject("panel/btn_result")
	self.btn_skip = self:GetChildGameObject("panel/btn_skip")
	self.obj_pvpClose = self:GetChildGameObject("panelPVP/btn_close")
	self.btn_pvpResult = self:GetChildGameObject("panelPVP/btn_result")
	self.btn_pvpSkip = self:GetChildGameObject("panelPVP/btn_skip")
	self.TxtRestart = self:GetChildGameObject("panel/Txt/TxtRestart")
	self.TxtPVPTip = self:GetChildComponent("panelPVP/Txt/TxtTip", "Text")
	self.TxtPVPTip.text = _("Msg_PVPQuitTips")

	local restartBtn = true

	if GP.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		restartBtn = false
	else
		self.img_stagebg = self:GetChildComponent("panel/img_stagebg", "Image")

		local imgpath = SceneMgr.GetCurrentScene().SceneData.BattleUIicon

		UIUtil.SetImageSprite(self.img_stagebg, imgpath)
	end

	if Infogvg:Vaild(self.infoStage.id) then
		restartBtn = false
	end

	if restartBtn == false then
		self.btn_restart:SetActive(false)
		self.TxtRestart:SetActive(false)
		GOUtil.SetRectTransformAnchoredPosition(self.btn_exitBattle, 0, -290)
		GOUtil.SetRectTransformAnchoredPosition(self.TxtExit, 0, -303)
	else
		self.btn_restart:SetActive(true)
		self.TxtRestart:SetActive(true)
		GOUtil.SetRectTransformAnchoredPosition(self.btn_exitBattle, -230, -350)
		GOUtil.SetRectTransformAnchoredPosition(self.TxtExit, -230, -363)
	end
end

function DlgBattleSetting:Open()
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)

	self.LastAutoMode = GP.AutoMode

	if GP.AutoMode == true then
		GP:SwitchAutoMode()
	end

	if GP.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		GOUtil.SetActive(self.mainPanel, false)
		GOUtil.SetActive(self.panelPVP, true)
	else
		GOUtil.SetActive(self.mainPanel, true)
		GOUtil.SetActive(self.panelPVP, false)
		self:RefreshChallengeTarget()
	end

	self:Show(true)
end

function DlgBattleSetting:Hide()
	if self.LastAutoMode == true and GP.AutoMode == false then
		GP:SwitchAutoMode()
	end

	self:Show(false)
end

function DlgBattleSetting:OnRegisterEvent()
	self:AddClick(self.obj_exitBattle, self.OnBtnExit)
	self:AddClick(self.btn_pvpExitBattle, self.OnBtnGiveUpYes)
	self:AddClick(self.obj_restart, self.OnBtnRestart)
	self:AddClick(self.obj_close, self.OnBtnClose)
	self:AddClick(self.obj_close2, self.OnBtnClose)
	self:AddClick(self.obj_close3, self.OnBtnClose)
	self:AddClick(self.obj_pvpClose, self.OnBtnClose)
	self:AddClick(self.obj_monsterDetail, self.OnBtnMonsterDetail)
	self:AddClick(self.obj_guide, self.OnBtnGuide)
	self:AddClick(self.btn_pvpResult, self.OnBtnResultClick)
	self:AddClick(self.btn_result, self.OnBtnResultClick)
end

function DlgBattleSetting:OnUnRegisterEvent()
	self:RemoveClick(self.obj_exitBattle, self.OnBtnExit)
	self:RemoveClick(self.btn_pvpExitBattle, self.OnBtnGiveUpYes)
	self:RemoveClick(self.obj_restart, self.OnBtnRestart)
	self:RemoveClick(self.obj_close, self.OnBtnClose)
	self:RemoveClick(self.obj_close2, self.OnBtnClose)
	self:RemoveClick(self.obj_close3, self.OnBtnClose)
	self:RemoveClick(self.obj_pvpClose, self.OnBtnClose)
	self:RemoveClick(self.obj_monsterDetail, self.OnBtnMonsterDetail)
	self:RemoveClick(self.obj_guide, self.OnBtnGuide)
	self:RemoveClick(self.btn_pvpResult, self.OnBtnResultClick)
	self:RemoveClick(self.btn_result, self.OnBtnResultClick)
end

function DlgBattleSetting:OnBtnExit()
	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		local function cb(index)
			if index == DlgCommonEvent.ButtonType.Ok then
				self:Show(false)
				SceneMgr.GetCurrentScene().GP:ExitGame()
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.GameOver, _("Tittle_Affirm"), _("Msg_QuitBattleConfirm"), cb, _("UI_Yes"), _("UI_No"), true)
	else
		GOUtil.SetActive(self.mainPanel, false)
		GOUtil.SetActive(self.panelPVP, true)
	end
end

function DlgBattleSetting:OnBtnRestart()
	local function wrap_cb(index2)
		if index2 == 1 then
			self:Show(false)
			SceneMgr.GetCurrentScene().GP:RestartGame()
		end
	end

	local strTitle = _("Desc_Alert")
	local strOkText = _("UI_OK")
	local strCancelText = _("Quite_Cancel")
	local msg = _("Desc_IsReSet_Change_Stage")

	UIMgr.ShowCommon(DlgCommonEvent.Type.GameOver, strTitle, msg, wrap_cb, strOkText, strCancelText)
end

function DlgBattleSetting:OnBtnClose()
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgBattleSetting", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo")
end

function DlgBattleSetting:OnBtnMonsterDetail()
	if self.infoStage then
		UIMgr.AddPanel(DlgMonsterDes(), {
			index = 1,
			listMonster = self.infoStage.listMonster
		}, UIMgr.UIOverLayObject)
	end
end

function DlgBattleSetting:OnBtnGuide()
	if self.infoStage then
		UIMgr.AddPanel(GuideChooseTip(), {
			guideType = "FightGuide"
		})
	end
end

function DlgBattleSetting:SetConditionVisible()
	local hasCondition = self.infoStage ~= nil
	local done = true

	for i = 1, 3 do
		if self.infoStage.pb.stars[i] then
			done = done and self.infoStage.pb.stars[i] > 0
		end
	end

	self.showCondition = hasCondition and not done

	self.conditions:SetActive(true)
	self.noConditions:SetActive(false)
	self.noConditionTxt:SetActive(false)
	self.conditionDoneTxt:SetActive(false)

	for i = 1, 3 do
		self.condtiontable[i].condtiontext.gameObject:SetActive(true)
		self.condtiontable[i].done:SetActive(true)
		self.condtiontable[i].fail:SetActive(true)
		self.condtiontable[i].doneImg:SetActive(true)
		self.condtiontable[i].failImg:SetActive(true)
	end

	if #self.infoStage.data.Star1Award == 0 and self.infoStage.data.Type ~= StageFromType.timespace then
		self.conditions:SetActive(false)
		self.noConditions:SetActive(true)
		self.noConditionTxt:SetActive(true)
	end
end

function DlgBattleSetting:RefreshChallengeTarget()
	if self.infoStage then
		if self.infoStage.data.ChapterType == ChapterFromType.main then
			local chapNum = ChapterMgr:GetChapterIdx(self.infoStage.data.ChapterID)

			self.TxtStageName.text = chapNum .. "-" .. ChapterMgr:GetStageIndex(self.infoStage.id) .. " " .. self.infoStage:GetName()
		elseif self.infoStage.data.ChapterType == ChapterFromType.towerhard or self.infoStage.data.ChapterType == ChapterFromType.tower then
			local infoChapter = ChapterMgr:GetChapter(self.infoStage.data.ChapterID)

			self.TxtStageName.text = Lang(infoChapter.data.Name) .. "." .. Lang(self.infoStage.data.Name)
		elseif self.infoStage.data.ChapterType == ChapterFromType.timespace then
			local infoChapter = ChapterMgr:GetChapter(self.infoStage.data.ChapterID)

			self.TxtStageName.text = Lang(infoChapter.data.Name) .. "　" .. Lang(self.infoStage.data.Name)
		else
			self.TxtStageName.text = self.infoStage:GetName()
		end

		for i = 1, 3 do
			local TxtAch = self.condtiontable[i].condtiontext
			local curGrade = self.infoStage.data.Grade[i]

			if not curGrade then
				TxtAch.text = ""

				self.condtiontable[i].star:SetActive(false)
				self.condtiontable[i].done:SetActive(false)
				self.condtiontable[i].fail:SetActive(false)
				self.condtiontable[i].doneImg:SetActive(false)
				self.condtiontable[i].failImg:SetActive(false)
			else
				local InfoStageCondition = require("Info.InfoStageCondition")

				InfoStageCondition.GradeText(TxtAch, curGrade)

				local done = false

				if GP.GameResultAddUpData.Grade then
					done = self.infoStage.pb.stars[i] > 0
				end

				self.condtiontable[i].star:SetActive(done)
				self.condtiontable[i].done:SetActive(done)
				self.condtiontable[i].doneImg:SetActive(done)
				self.condtiontable[i].fail:SetActive(not done)
				self.condtiontable[i].failImg:SetActive(not done)
			end
		end
	end
end

function DlgBattleSetting:OnBtnResultClick()
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgBattleSetting", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIResultAddUp")
end

function DlgBattleSetting:OnBtnGiveUpYes()
	local function cb(index)
		if index == DlgCommonEvent.ButtonType.Ok then
			self:OnBtnClose()
			Event.Instance:Fire("GiveUpGame")
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.GameOver, _("Tittle_Affirm"), _("Msg_QuitBattleConfirm"), cb, _("UI_Yes"), _("UI_No"), true)
end

function DlgBattleSetting:OnBtnGiveUpNo()
	self:OnBtnClose()
end
