-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/PageFightDebug.lua

require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeMonster")
require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgMonsterSkill")
require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeScene")
require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeSession")

PageFightDebug = class("PageFightDebug", UIPanel_sync)

function PageFightDebug:ctor()
	PageFightDebug.base.ctor(self, "UI/PageFight/Dlg/PageFightDebug")
end

function PageFightDebug:Cache()
	PageFightDebug.base.Cache(self)
end

function PageFightDebug:Close(tParam)
	PageFightDebug.base.Close(self, tParam)
end

function PageFightDebug:Purge()
	PageFightDebug.base.Purge(self)
end

function PageFightDebug:OnRegisterEvent()
	self:AddClick(self.btn_ChangeMonster, self.OnBtnChangeMonster)
	self:AddClick(self.btn_ChangeSession, self.OnChangeSession)
	self:AddClick(self.btn_MonsterSkill, self.OnBtnMonsterSkill)
	self:AddClick(self.btn_Scene, self.OnBtnScene)
	self:AddClick(self.btn_Round, self.OnBtnRound)
	self:AddClick(self.btn_timeScale, self.TimeScale)
	self:AddClick(self.btn_CheckMsg, self.CheckMsg)
	self:AddClick(self.btn_CmdPanel, self.CmdPanel)
	self:AddClick(self.btn_cmdConfirm, self.OnBtnCMDConfirm)
	self:AddClick(self.btn_UI, self.OnBtnUI)
	self:AddClick(self.btn_Win, self.OnBtnWin)
	self:AddClick(self.btn_SkillViewer, self.OnBtnSkillView)
end

function PageFightDebug:OnUnRegisterEvent()
	self:RemoveClick(self.btn_ChangeMonster, self.OnBtnChangeMonster)
	self:RemoveClick(self.btn_ChangeSession, self.OnChangeSession)
	self:RemoveClick(self.btn_MonsterSkill, self.OnBtnMonsterSkill)
	self:RemoveClick(self.btn_Scene, self.OnBtnScene)
	self:RemoveClick(self.btn_Round, self.OnBtnRound)
	self:RemoveClick(self.btn_timeScale, self.TimeScale)
	self:RemoveClick(self.btn_CheckMsg, self.CheckMsg)
	self:RemoveClick(self.btn_CmdPanel, self.CmdPanel)
	self:RemoveClick(self.btn_cmdConfirm, self.OnBtnCMDConfirm)
	self:RemoveClick(self.btn_UI, self.OnBtnUI)
	self:RemoveClick(self.btn_Win, self.OnBtnWin)
	self:RemoveClick(self.btn_SkillViewer, self.OnBtnSkillView)
end

function PageFightDebug:OnEnter(vParam)
	self.IsShowUI = true
	self.btn_UI = self:GetChildGameObject("panel/btn_UI")
	self.btn_Win = self:GetChildGameObject("panel/btn_Win")
	self.btn_SkillViewer = self:GetChildGameObject("panel/btn_SkillViewer")
	self.btn_MonsterSkill = self:GetChildGameObject("panel/btn_MonsterSkill")
	self.btn_ChangeSession = self:GetChildGameObject("panel/btn_ChangeSession")
	self.btn_ChangeMonster = self:GetChildGameObject("panel/btn_ChangeMonster")
	self.btn_Scene = self:GetChildGameObject("panel/btn_Scene")
	self.btn_Round = self:GetChildGameObject("panel/btn_Round")
	self.btn_CheckMsg = self:GetChildGameObject("panel/btn_CheckMsg")
	self.obj_CheckMsg = self:GetChildGameObject("panel/ScrollMsgs")

	GOUtil.SetActive(self.obj_CheckMsg, false)

	self.btn_CmdPanel = self:GetChildGameObject("panel/btn_CmdPanel")
	self.obj_CmdPanel = self:GetChildGameObject("panel/ScrollCMDs")

	GOUtil.SetActive(self.obj_CmdPanel, false)

	self.txt_CheckMsgText = self:GetChildComponent("panel/ScrollMsgs/Viewport/Content/Text", "Text")
	self.btn_timeScale = self:GetChildGameObject("panel/btn_TimeScale")
	self.txt_timeScale = self:GetChildComponent("panel/btn_TimeScale/Text", "Text")
	self.btn_cmdConfirm = self:GetChildGameObject("panel/CmdPanel/btn_cmdConfirm")
	self.input_cmd = self:GetChildComponent("panel/CmdPanel/InputField", "InputField")
end

function PageFightDebug:Open(callback, camp)
	self:Show(true)
end

function PageFightDebug:OnBtnCMDConfirm()
	local cmdStr = self.input_cmd.text

	if cmdStr == "" then
		return
	end

	if cmdStr == "ag" then
		GP:RestartGame()

		return
	end

	if cmdStr == "ex" then
		GP:ExitGame()

		return
	end

	if cmdStr == "hide" then
		self:Show(false)

		return
	end

	if cmdStr == "ExcuteEnd" then
		GP.GameMsg:ExcuteEnd()

		return
	end

	if cmdStr == "infobuff" then
		local str = ""

		for i, unit in ipairs(GP.Team.PlayerTeam) do
			str = unit.UnitTitle .. " buff:"

			for buffIdx, buff in ipairs(unit.Buffs) do
				str = str .. " ," .. buff.Name .. buff.BuffId
			end

			print(str)
		end
	end

	Event.Instance:Fire("CMD_Message", cmdStr)
end

function PageFightDebug:OnBtnChangeMonster()
	local str = self.input_cmd.text

	if str ~= "" then
		Event.Instance:Fire("CMD_Message", "changeMonster" .. str)
	else
		UIMgr.AddPanel(GMDlgChangeMonster())
	end
end

function PageFightDebug:OnChangeSession()
	local str = self.input_cmd.text

	if str ~= "" then
		Event.Instance:Fire("CMD_Message", "changesession " .. str)
	else
		UIMgr.AddPanel(GMDlgChangeSession())
	end
end

function PageFightDebug:OnBtnMonsterSkill()
	UIMgr.AddPanel(GMDlgMonsterSkill())
end

function PageFightDebug:OnBtnScene()
	local str = self.input_cmd.text

	if str ~= "" then
		SceneMgr.GetCurrentScene():ChangeMainScene(tonumber(self.input_cmd.text))
	else
		UIMgr.AddPanel(GMDlgChangeScene())
	end
end

function PageFightDebug:OnBtnRound(callback, camp)
	Event.Instance:Fire("CMD_Message", "round")
end

local timeScaleCfg = {
	EnumFight.SpeedMode.Default,
	EnumFight.SpeedMode.Fast,
	EnumFight.SpeedMode.Extreme
}
local showStr = {
	"加速",
	"高速",
	"超高速"
}

function PageFightDebug:TimeScale()
	local timeScaleIndex = GP.SpeedMode

	timeScaleIndex = timeScaleIndex + 1

	if timeScaleIndex > #timeScaleCfg then
		timeScaleIndex = 1
	end

	self.txt_timeScale.text = tostring(showStr[timeScaleIndex])

	GP:SetGameSpeedMode(timeScaleCfg[timeScaleIndex])
end

function PageFightDebug:CheckMsg()
	GOUtil.SetActive(self.obj_CheckMsg, not self.obj_CheckMsg.gameObject.activeSelf)

	local str = SceneMgr.GetCurrentScene().GP.GameMsg:DebugRecording()
	local recordingList = SceneMgr.GetCurrentScene().GP.GameMsg:GetRecordingList()

	self.txt_CheckMsgText.text = " 現在：" .. EnumFight.GameStageStr(GP.GameStage) .. "  " .. "\n" .. str
end

function PageFightDebug:OnBtnUI()
	local val = not self.IsShowUI

	self.IsShowUI = val

	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", val)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", val)

	if GP.Live then
		GP.Live:MuteLyricTrack(self.IsShowUI)
	end
end

function PageFightDebug:OnBtnWin()
	Event.Instance:Fire("CMD_Message", "win")
end

function PageFightDebug:OnBtnSkillView()
	SceneMgr.GetCurrentScene().GP:PurgeAll()

	local sceneName = "SkillViewer"

	SceneMgr.LoadScene(sceneName, nil)
end

function PageFightDebug:CmdPanel()
	GOUtil.SetActive(self.obj_CmdPanel, not self.obj_CmdPanel.gameObject.activeSelf)
end
