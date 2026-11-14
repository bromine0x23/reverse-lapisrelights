-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIAuto.lua

DlgUIAuto = class("DlgUIAuto", UIPanel_sync)

function DlgUIAuto:ctor()
	DlgUIAuto.base.ctor(self, "UI/PageFight/Dlg/DlgUIAuto")
end

function DlgUIAuto:Cache()
	DlgUIAuto.base.Cache(self)
end

function DlgUIAuto:Close(tParam)
	DlgUIAuto.base.Close(self, tParam)
end

function DlgUIAuto:Purge()
	DlgUIAuto.base.Purge(self)
end

function DlgUIAuto:OnRegisterEvent()
	DlgUIAuto.base.OnRegisterEvent(self)
	self:AddClick(self.btn_shouUI, self.OnBtnShowUI)
end

function DlgUIAuto:OnUnRegisterEvent()
	DlgUIAuto.base.OnUnRegisterEvent(self)
	self:RemoveClick(self.btn_shouUI, self.OnBtnShowUI)
end

function DlgUIAuto:OnEnter(vParam)
	DlgUIAuto.base.OnEnter(self, vParam)

	self.ani_panel = self:GetChildComponent("panel", "Animator")
	self.btn_shouUI = self:GetChildGameObject("panel/top/btn_shouUI")

	self.btn_shouUI:SetActive(false)
	self:Hide()
end

function DlgUIAuto:Open()
	self.ani_panel:Play("PageBattle_panel")
end

function DlgUIAuto:Hide()
	self.ani_panel:Play("PageBattle_panel_close")
end

function DlgUIAuto:OnBtnShowUI()
	if not GP then
		return
	end

	if GP.FightMode ~= EnumFight.BattleType.BOSS then
		return
	end

	if GP.AutoMode == true then
		UIMgr.ShowMsg(_("BossLive_AutoWarn"))

		return
	end

	if GP.GameStage ~= EnumFight.GameState.OPERATOR_WAIT then
		return
	end

	if self.IsShowUI == nil then
		self.IsShowUI = true
	end

	local val = not self.IsShowUI

	self.IsShowUI = val

	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", val)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", val)

	if GP.Live then
		GP.Live:MuteLyricTrack(self.IsShowUI)
	end

	self.btn_shouUI:SetActive(not val)
	GP.UI.DlgUIBattleInfo:MenuActive(val)
end
