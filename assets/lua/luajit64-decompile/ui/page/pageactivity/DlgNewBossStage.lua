-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/DlgNewBossStage.lua

DlgNewBossStage = class("DlgNewBossStage", UIPanel)

function DlgNewBossStage:ctor()
	self.UIPrefabPath = "UI/PanelActivity/DlgNewBossStage"
end

function DlgNewBossStage:PreLoad()
	return
end

function DlgNewBossStage:Purge()
	DlgNewBossStage.base.Purge(self)
	self:OnLeave()
end

function DlgNewBossStage:OnLeave()
	if self.timer then
		TimerMgr.RemoveTimer(self.timer)
	end
end

function DlgNewBossStage:OnRegisterEvent()
	return
end

function DlgNewBossStage:OnUnRegisterEvent()
	return
end

function DlgNewBossStage:OnEnter(vParam)
	self.CloseBtn = self:GetChildGameObject("BG")
	ActiveMgr.NewOpenBossStage = nil
	self.callback = vParam.callback3
	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 1.5, function()
		self:OnClickedBtnClose()
	end, {})
end

function DlgNewBossStage:OnClickedBtnClose()
	self:Close()

	if self.callback then
		self.callback()

		self.callback = nil
	end
end
