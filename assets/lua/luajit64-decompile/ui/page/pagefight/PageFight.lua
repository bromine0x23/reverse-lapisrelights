-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/PageFight.lua

require("UI/UIPanel_sync")
require("UI/Page/PageFight/Dlg/DlgUIBossAppear")
require("UI/Page/PageFight/Dlg/DlgUIMsgBoxs")
require("UI/Page/PageFight/Dlg/DlgUIResult")
require("UI/Page/PageFight/Dlg/PageCMD")
require("UI/Page/PageFight/Dlg/DlgSkillChange")
require("UI/Page/PageFight/Dlg/DlgUISongName")
require("UI/Page/PageFight/Dlg/DlgUICenterSkill")
require("UI/Page/PageFight/Dlg/DlgUICombinationSkill")
require("UI/Page/PageFight/Dlg/DlgUIBattleInfo")
require("UI/Page/PageFight/Dlg/DlgUIRoundTip")
require("UI/Page/PageFight/Dlg/DlgHeadTip")
require("UI/Page/PageFight/Dlg/DlgUIOperator")
require("UI/Page/PageFight/Dlg/DlgUISessionTip")
require("UI/Page/PageFight/Dlg/DlgUICutInSession")
require("UI.Page.PageFight.Dlg.DlgUICutInNSession")
require("UI/Page/PageFight/Dlg/DlgUICombo")
require("UI/Page/PageFight/Dlg/DlgUISkipTimeline")
require("UI/Page/PageFight/Dlg/DlgUICardCutIn")
require("UI.Page.PageFight.Dlg.DlgUIPVPCardSkill")
require("UI.Page.PageFight.Dlg.DlgUIPVPSession")
require("UI/Page/PageFight/Dlg/DlgBattleSetting")
require("UI/Page/PageFight/Dlg/DlgUIVictory")
require("UI/Page/PageFight/Dlg/DlgUIResultAddUp")
require("UI/Page/PageFight/Dlg/DlgUIAuto")
require("UI/Page/PageFight/Dlg/DlgUIFirstHand")
require("UI/Page/PageFight/Dlg/DlgUIFirstHandTip")
require("UI/Page/PageFight/Cells/CellBuffIcons")
require("UI/Page/PageFight/Cells/CellHeadTipOnIcon")
require("UI/Page/PageFight/Cells/CellAutoBtn")
require("UI/Page/PageFight/Cells/CellBtnSkip")

PageFight = class("PageFight", UIPanel_sync)

function PageFight:RegisterDlg(ele)
	self:AddChildPanel(ele)

	self.DlgTable[ele.className] = ele
end

function PageFight:ctor()
	PageFight.base.ctor(self, "UI/PageFight/PageFight")

	self.SpineDic = {}
	self.HeadItem = nil
	self.HeadItemRoot = nil
	self.DlgTable = {}
	self.DlgUIFirstHand = DlgUIFirstHand()

	self:RegisterDlg(self.DlgUIFirstHand)

	self.DlgUIFirstHandTip = DlgUIFirstHandTip()

	self:RegisterDlg(self.DlgUIFirstHandTip)

	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		self.DlgUIBossAppear = DlgUIBossAppear()

		self:RegisterDlg(self.DlgUIBossAppear)
	end

	self.DlgSkillChange = DlgSkillChange()

	self:RegisterDlg(self.DlgSkillChange)

	self.DlgUISongName = DlgUISongName()

	self:RegisterDlg(self.DlgUISongName)

	self.DlgUIMsgBoxs = DlgUIMsgBoxs()

	self:RegisterDlg(self.DlgUIMsgBoxs)

	self.DlgUICenterSkill = DlgUICenterSkill()

	self:RegisterDlg(self.DlgUICenterSkill)

	self.DlgUICombinationSkill = DlgUICombinationSkill()

	self:RegisterDlg(self.DlgUICombinationSkill)

	self.DlgUIBattleInfo = DlgUIBattleInfo()

	self:RegisterDlg(self.DlgUIBattleInfo)

	self.DlgUIOperator = DlgUIOperator()

	self:RegisterDlg(self.DlgUIOperator)

	self.DlgHeadTip = DlgHeadTip()

	self:RegisterDlg(self.DlgHeadTip)

	self.DlgUIAuto = DlgUIAuto()

	self:RegisterDlg(self.DlgUIAuto)

	self.DlgUICutInSession = DlgUICutInSession()

	self:RegisterDlg(self.DlgUICutInSession)

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS then
		self.DlgUICutInNSession = DlgUICutInNSession()

		self:RegisterDlg(self.DlgUICutInNSession)
	end

	self.DlgUICardCutIn = DlgUICardCutIn()

	self:RegisterDlg(self.DlgUICardCutIn)

	self.DlgUIPVPCardSkill = DlgUIPVPCardSkill()

	self:RegisterDlg(self.DlgUIPVPCardSkill)

	self.DlgUIPVPSession = DlgUIPVPSession()

	self:RegisterDlg(self.DlgUIPVPSession)

	self.DlgUISessionTip = DlgUISessionTip()

	self:RegisterDlg(self.DlgUISessionTip)

	self.DlgUICombo = DlgUICombo()

	self:RegisterDlg(self.DlgUICombo)

	self.DlgUIRoundTip = DlgUIRoundTip()

	self:RegisterDlg(self.DlgUIRoundTip)

	self.DlgUISkipTimeline = DlgUISkipTimeline()

	self:RegisterDlg(self.DlgUISkipTimeline)

	self.DlgUIResult = DlgUIResult()

	self:RegisterDlg(self.DlgUIResult)

	self.DlgUIVictory = DlgUIVictory()

	self:RegisterDlg(self.DlgUIVictory)

	if Application.isEditor == true then
		self.PageCMD = PageCMD()

		self:RegisterDlg(self.PageCMD)
	end

	self.DlgUIResultAddUp = DlgUIResultAddUp()

	self:RegisterDlg(self.DlgUIResultAddUp)

	self.DlgBattleSetting = DlgBattleSetting()

	self:RegisterDlg(self.DlgBattleSetting)
end

local characterCfg = require("luaData/CharacterRole")

function PageFight:Cache()
	PageFight.base.Cache(self)

	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		for i, id in ipairs(GP.PlayerUnitIds) do
			local path = characterCfg[id].FightSpine

			ResourceMgr.SubmitCache(path, self, "spine_role" .. id)
		end
	end
end

function PageFight:Close(tParam)
	PageFight.base.Close(self, tParam)
end

function PageFight:Purge()
	self.SpineDic = nil

	if self.DlgUIDebug then
		self.DlgUIDebug:Close()

		self.DlgUIDebug = nil
	end

	for k, v in pairs(self.DlgTable) do
		v = nil
	end

	self.DlgTable = {}

	PageFight.base.Purge(self)
end

function PageFight:OnRegisterEvent()
	Event.Instance:Add("PlaySpine", self.PlaySpine, self)
	Event.Instance:Add("HideAllSpines", self.HideAllSpines, self)
end

function PageFight:OnUnRegisterEvent()
	Event.Instance:Remove("PlaySpine", self.PlaySpine, self)
	Event.Instance:Remove("HideAllSpines", self.HideAllSpines, self)
end

function PageFight:OnEnter(vParam)
	self.SpineDic = {}

	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		for _, unitId in ipairs(SceneMgr.GetCurrentScene().GP.PlayerUnitIds) do
			self.SpineDic[unitId] = GOUtil.InstantiateUIPrefab(self["spine_role" .. unitId], nil)

			GOUtil.SetActive(self.SpineDic[unitId].gameObject, false)
		end
	end

	self:OnLoaded()
end

function PageFight:ShowPanel(callback)
	return
end

function PageFight:HidePanel(callback)
	return
end

function PageFight:OpenDlg(dlgName, val, ...)
	local dlg = self.DlgTable[dlgName]

	if not dlg then
		print("OpenDlg failed !!! dlgName is null or not register!  dlgName = " .. dlgName)

		return
	end

	if val ~= nil and val == false then
		local hideFun = self.DlgTable[dlgName].Hide

		if hideFun then
			hideFun(self.DlgTable[dlgName])

			return
		end

		self.DlgTable[dlgName]:Show(false)

		return
	end

	local openFun = self.DlgTable[dlgName].Open

	if openFun then
		openFun(self.DlgTable[dlgName], ...)

		return
	end

	print("OpenDlg failed !!! have not define Open function = " .. dlgName)
	self.DlgTable[dlgName]:Show(true)
end

function PageFight:PlaySpine(uniqueId, root)
	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		local unitId = UnitActor.FindUnitById(uniqueId).UnitId
		local obj = self.SpineDic[unitId]

		obj = obj or self.SpineDic[101]

		GOUtil.AttachGameObject(obj, root)
		GOUtil.SetActive(obj, true)
		GOUtil.ResetTransform(obj)
		UIUtil.PlaySpineAni(obj)
	end
end

function PageFight:HideAllSpines()
	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		if self.SpineDic == nil then
			return
		end

		for k, v in pairs(self.SpineDic) do
			GOUtil.SetActive(v, false)
		end
	end
end

function PageFight:OnBackAndroid()
	if self.DlgUIResultAddUp ~= nil and self.DlgUIResultAddUp:IsShow() then
		self.DlgUIResultAddUp:OnBackAndroid()

		return
	end

	if self.DlgUIVictory ~= nil and self.DlgUIVictory:IsShow() then
		self.DlgUIVictory:OnClickedBtnEnter()

		return
	end

	if self.DlgUIResult ~= nil and self.DlgUIResult:IsShow() then
		self.DlgUIResult:OnClickArea()

		return
	end

	if self.DlgUISkipTimeline ~= nil and self.DlgUISkipTimeline:IsShow() then
		self.DlgUISkipTimeline:OnBtnSkip()

		return
	end

	if GP.GameStartData.playMode == EnumFight.PlayMode.Replay then
		if self.DlgUIBattleInfo ~= nil then
			self.DlgUIBattleInfo:OnBtnExitReplayClick()
		end
	else
		if self.DlgUIOperator:OnBackAndroid() then
			return
		end

		if self.DlgUIBattleInfo:OnBackAndroid() then
			return
		end

		if self.DlgBattleSetting ~= nil and self.DlgBattleSetting:IsShow() then
			self.DlgBattleSetting:OnBtnClose()
		elseif self.DlgUIBattleInfo ~= nil and self.DlgUIBattleInfo:IsShow() then
			self.DlgUIBattleInfo:OnBtnMenuClick()
		end
	end
end
