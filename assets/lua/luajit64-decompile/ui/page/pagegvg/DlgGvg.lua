-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvg.lua

local CMD_PANEL = false

require("UI/Item/UIItemBase")
require("UI/Dlg/Public/DlgExit")
require("UI/Dlg/Public/DlgAssetsInfo")
require("UI/Page/PageGvg/DlgGvgCombatReadiness")
require("UI/Page/PageGvg/DlgGvgSpellStore")
require("UI/Page/PageGvg/DlgGvgRank")
require("UI/Page/PageGvg/DlgGvgScore")
require("UI/Page/PageGvg/DlgGvgAnim")
require("UI/Page/PageGvg/DlgGvgRewardPreview")
require("UI/Page/PageGvg/DlgGvgChallenge")

DlgGvg = class("DlgGvg", UIPanel)

function DlgGvg:ctor()
	self.UIPrefabPath = "UI/PageGvg/DlgGvg"

	self:AddChildPanel(DlgExit(), {
		title = _("Item_From_19_5"),
		helpCallback = self.OnClickedBtnGuide,
		callback = self.OnBack
	})
end

function DlgGvg:OnBack()
	if Infogvg.offline then
		local sceneName = "SkillViewer"

		SceneMgr.LoadScene(sceneName, nil)

		return
	end

	UIMgr.PopPanel({
		isShowBank = true,
		needRequestUnion = true
	})
end

function DlgGvg:OnClickedBtnGuide()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Gvg)
end

function DlgGvg:Purge()
	self.base.Purge(self)

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	self.switchStep:Purge()
	self.steps:Purge()
	self.skills:Purge()

	if self.cmd then
		self.cmd:Purge()
	end

	if self.handle then
		TimerMgr.RemoveTimer(self.handle)
	end

	UnloadAllImageSprite(self)
end

function DlgGvg:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PageGvg/CellGvgSkill")
end

function DlgGvg:OnRegisterEvent()
	Event.Instance:Add("EVENT_GVG_REFRESH", self.OnEventGvgRefresh, self)
	Event.Instance:Add("EVENT_GVG_UI_SWITCHSTEP", self.OnEventGvgSwitchStep, self)
	Event.Instance:Add("EVENT_GVG_REWARD_STAGE", self.OnEventGvgReward, self)
	self:AddClick(self.btn_rank, self.OnBtnRank)
	self:AddClick(self.btn_score, self.OnBtnScore)
	self:AddClick(self.btn_rewardview, self.OnBtnRewardView)
	self:AddClick(self.btn_checkMembers, self.OnBtnCheckMembers)
	self:AddClick(self.btn_store, self.OnBtnSpellStore)
	self:AddClick(self.btn_shop, self.OnBtnShop)
end

function DlgGvg:OnUnRegisterEvent()
	Event.Instance:Remove("EVENT_GVG_REFRESH", self.OnEventGvgRefresh, self)
	Event.Instance:Remove("EVENT_GVG_UI_SWITCHSTEP", self.OnEventGvgSwitchStep, self)
	Event.Instance:Remove("EVENT_GVG_REWARD_STAGE", self.OnEventGvgReward, self)
	self:RemoveClick(self.btn_rank, self.OnBtnRank)
	self:RemoveClick(self.btn_score, self.OnBtnScore)
	self:RemoveClick(self.btn_rewardview, self.OnBtnRewardView)
	self:RemoveClick(self.btn_checkMembers, self.OnBtnCheckMembers)
	self:RemoveClick(self.btn_store, self.OnBtnSpellStore)
	self:RemoveClick(self.btn_shop, self.OnBtnShop)
end

function DlgGvg:OnEnter(defaultStep)
	self.btn_rank = self:GetChildGameObject("safeArea/btns/btn_rank/obj_click")
	self.btn_score = self:GetChildGameObject("safeArea/progressInfo/btn_score/obj_click")
	self.btn_store = self:GetChildGameObject("safeArea/btns/btn_store/obj_click")
	self.img_store_hint = self:GetChildComponent("safeArea/btns/btn_store/img_hint", "Image")
	self.img_store_hint.enabled = false
	self.btn_shop = self:GetChildGameObject("safeArea/btns/btn_shop/obj_click")
	self.btn_rewardview = self:GetChildGameObject("safeArea/progressInfo/btn_reward/obj_click")
	self.btn_checkMembers = self:GetChildGameObject("safeArea/challenge/img_checkMembers/obj_click")
	self.txt_challenge = self:GetChildComponent("safeArea/challenge/txt_challenge", "Text")
	self.obj_challengeLabel = self:GetChildGameObject("safeArea/challenge/txt_challengeLabel")
	self.txt_timeLimit = self:GetChildComponent("safeArea/challenge/txt_timeLimit", "Text")

	self:SetTimeLimitText()

	local component = require("UI/Page/PageGvg/Steps")

	self.steps = component()

	self.steps:Init(self.UIRootObject)

	component = require("UI/Page/PageGvg/SwitchStep")
	self.switchStep = component()

	self.switchStep:Init(self.UIRootObject)

	component = require("UI/Page/PageGvg/Skills")
	self.skills = component()

	self.skills:Init(self:GetChildGameObject("safeArea/skills"), self.PrefabCell)

	if CMD_PANEL then
		component = require("UI/Page/PageGvg/DlgGvgCmd")
		self.cmd = component(self:GetChildGameObject("cmd"))

		GOUtil.SetActive(self:GetChildGameObject("cmd"), true)
	else
		GOUtil.SetActive(self:GetChildGameObject("cmd"), false)
	end

	local step = Infogvg.stage.curStep

	if defaultStep then
		step = defaultStep
	end

	self:Refresh(step)
	self:StoreHint()
	Infogvg.persistent:Refresh()

	local delay = 0

	if Infogvg.persistent.animPanel == true then
		UIMgr.AddPanel(DlgGvgAnim())

		delay = 1.5
	end

	self.handle = TimerMgr.AddTimer(eTimerType.ScaleTime, delay, function()
		Infogvg.net:RequestStageReward()
	end, {})
end

function DlgGvg:OnEventGvgReward()
	Infogvg.net:RequestStepReward()
end

function DlgGvg:Refresh(step)
	self.step = step

	self.steps:Refresh(step)
	self.switchStep:SwitchTo(step)

	if not Infogvg:ClosingActive() then
		local max = GetConfigArgInt("GVGDailyTimes")

		UIUtil.SetTextString(self.txt_challenge, tostring(Infogvg.stage.leftTimes) .. "/" .. max)
		GOUtil.SetActive(self.obj_challengeLabel, true)
	else
		UIUtil.SetTextString(self.txt_challenge, "")
		GOUtil.SetActive(self.obj_challengeLabel, false)
	end
end

function DlgGvg:OnEventGvgSwitchStep(step)
	self:Refresh(step)
end

function DlgGvg:OnEventGvgRefresh()
	self:Refresh(self.step)
	self:StoreHint()
end

function DlgGvg:OnBtnRank()
	if not Infogvg:IsPlayOpen() then
		UIMgr.ShowMsg(_("Msg_Active_Over"))

		return
	end

	UIMgr.SwitchPanel(DlgGvgRank(), self.step)
end

function DlgGvg:OnBtnScore()
	if not Infogvg:IsPlayOpen() then
		UIMgr.ShowMsg(_("Msg_Active_Over"))

		return
	end

	UIMgr.AddPanel(DlgGvgScore())
end

function DlgGvg:OnBtnSpellStore()
	if not Infogvg:IsPlayOpen() then
		UIMgr.ShowMsg(_("Msg_Active_Over"))

		return
	end

	UIMgr.AddPanel(DlgGvgSpellStore())
end

function DlgGvg:OnBtnShop()
	require("UI/Page/PageShop/PageShop")

	local data = {
		tagIndex = 7,
		tabMainIndex = tabMainType.exchange
	}

	PageShop.InitNetData(data)
end

function DlgGvg:OnBtnRewardView()
	UIMgr.AddPanel(DlgGvgRewardPreview(), self.step)
end

function DlgGvg:OnBtnCheckMembers()
	if not Infogvg:IsPlayOpen() then
		UIMgr.ShowMsg(_("Msg_Active_Over"))

		return
	end

	UIMgr.AddPanel(DlgGvgChallenge())
end

function DlgGvg:StoreHint()
	local val = Infogvg.spell:Hint()

	self.img_store_hint.enabled = val
end

function DlgGvg:SetTimeLimitText()
	local function fun(strTime)
		local y, m, d, h, min = 0, 0, 0, "00", "00"
		local a = string.split(strTime, " ")

		if #a > 0 then
			local date = string.split(a[1], "-")

			y, m, d = tonumber(date[1]), tonumber(date[2]), tonumber(date[3])

			local time = string.split(a[2], ":")

			h, min = time[1], time[2]
		end

		return y, m, d, h, min
	end

	local infoactive = ActiveMgr:GetActive(Infogvg.stage.activeId)
	local y1, m1, d1, h1, min1 = fun(infoactive.data.StartTime)
	local y2, m2, d2, h2, min2 = fun(infoactive.data.EndTime)
	local key = _("DESC_GVG_TIMEFORMAT_NO_YEAR")
	local str = string.format(key, m1, d1, h1, min1, m2, d2, h2, min2)

	UIUtil.SetTextString(self.txt_timeLimit, str)
end
