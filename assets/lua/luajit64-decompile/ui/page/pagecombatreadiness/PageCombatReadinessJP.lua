-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/PageCombatReadinessJP.lua

PageCombatReadinessJP = class("PageCombatReadinessJP")
PageCombatReadinessJP.clickType = 0
PageCombatReadinessJP.fromType = 0
PageCombatReadinessJP.isBossFullHP = true

function PageCombatReadinessJP:ctor(originalHanlder)
	self.originalHanlder = originalHanlder
	self.fromType = 0
end

function PageCombatReadinessJP:Debug()
	return
end

function PageCombatReadinessJP:InitData(vParam, stage)
	self.vParam = vParam
	self.stage = stage
	self.isRaidBoss = stage.data.ChapterType == ChapterFromType.bossRaid

	if self.isRaidBoss then
		PageCombatReadinessJP.fromType = self.vParam.raidBossInfo.fromType
	end
end

function PageCombatReadinessJP:IsAssit()
	local result = self.isRaidBoss and PageCombatReadinessJP.fromType ~= 0

	if self.originalHanlder.raidBossInfo and self.originalHanlder.raidBossInfo.bossLevel > 19 and PageCombatReadinessJP.isBossFullHP then
		return false
	end

	return result
end

function PageCombatReadinessJP:UpdateBeginPanel()
	if self:IsAssit() then
		self.originalHanlder.BtnSweep:SetActive(true)
		self.originalHanlder.GoChallengeNum:SetActive(false)

		Text = self.originalHanlder:GetChildComponent("Panel/Begin/Group/BtnSweep/Text", "Text")
		Text.text = "救援"
		Text = self.originalHanlder:GetChildComponent("Panel/Begin/Group/BtnSweep/TextSweep", "Text")

		local assistRewardMaxNum = ActivityBossRaidMgr:GetAssistRewardMaxNum()

		Text.text = "本日の救援報酬" .. math.max(assistRewardMaxNum - ActivityBossRaidMgr.assistNum, 0) .. "/" .. assistRewardMaxNum

		local goTemplate = self.originalHanlder:GetChildGameObject("Panel/Begin/Group/BtnSweep/TextSweep")
		local goParent = self.originalHanlder:GetChildGameObject("Panel/Begin/Group/BtnChallenge")

		Text = self:AddText(goTemplate, goParent, 0, 60)
		Text.text = self.originalHanlder:GetChildComponent("Panel/Begin/ChallengeNum/TextNum", "Text").text
		Text = self:AddText(goTemplate, goParent, 0, -93)
		Text.text = self.originalHanlder:GetChildComponent("Panel/Begin/ChallengeNum/TextTotal", "Text").text .. ActivityBossRaidMgr.playNum .. "/" .. ActivityBossRaidMgr:GetPlayMaxNum()
	end
end

function PageCombatReadinessJP:CheckNeedTips(key)
	if PlayerPrefs.HasKey(key) then
		return not TimeIsTodayKc(tonumber(PlayerPrefs.GetString(key, NetData:GetCurServerTime())))
	end

	return true
end

function PageCombatReadinessJP:ShowAssistTip(cb)
	local key, msg

	if self.originalHanlder.raidBossInfo and self.originalHanlder.raidBossInfo.bossLevel > 19 then
		key = "PageCombatReadinessJP_Assit_Hard"
		msg = _("AssistRewardHard")
	else
		key = "PageCombatReadinessJP_Assit_Normal"
		msg = _("AssistRewardNormal")
	end

	if self:CheckNeedTips(key) then
		local function vCallBack(index)
			if index == DlgCommonEvent.ButtonType.OkNoMoreTips then
				PlayerPrefs.SetString(key, NetData:GetCurServerTime())
			end

			if index == DlgCommonEvent.ButtonType.Ok or index == DlgCommonEvent.ButtonType.OkNoMoreTips then
				cb()
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.NotPromptToday, _("Desc_Alert"), msg, vCallBack, nil, nil, nil, true)
	else
		cb()
	end
end

function PageCombatReadinessJP:OnClickedBtnSweepToHelp(fromGo, toGo, left, top)
	PageCombatReadinessJP.clickType = 1

	if self:IsAssit() then
		print("on help")
		self:ShowAssistTip(function()
			self.originalHanlder:OnClickedBtnChallenge({
				clickType = 1
			})
		end)

		return true
	end

	return false
end

function PageCombatReadinessJP:AddText(fromGo, toGo, left, top)
	local head1

	head1 = GOUtil.Instantiate(fromGo, toGo)

	local rect = GOUtil.GetComponent(head1, "RectTransform")

	GOUtil.SetRectTransformAnchoredPosition(head1, left, top)

	local text = GOUtil.GetComponent(head1, "Text")

	text.text = "xxxx"

	return text
end
