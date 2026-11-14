-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/DlgNewRoleUnlock.lua

DlgNewRoleUnlock = class("DlgNewRoleUnlock", UIPanel)

function DlgNewRoleUnlock:ctor()
	self.UIPrefabPath = "UI/PageCardShop/DlgNewRoleUnlock"
end

function DlgNewRoleUnlock:Purge()
	DlgNewRoleUnlock.base.Purge(self)
	SoundMgr.Stop(self.infoRole.data.VocalGetChara)
	InfoSoundEventMgr:UnloadBank(self.infoRole.data.VocalBank)
	TimerMgr.RemoveTimer(self.Timer)
end

function DlgNewRoleUnlock:PreLoad()
	return
end

function DlgNewRoleUnlock:OnEnter(vParam)
	self.infoRole = vParam.infoRole
	self.callback = vParam.callback
	self.endback = vParam.endback
	self.GoNextClick = self:GetChildGameObject("BG")
	self.CardJob = self:GetChildComponent("Panel/RolePart/CardJobBg/CardJob", "Image")
	self.RoleIcon = self:GetChildComponent("Panel/RolePart/RoleIcon", "Image")
	self.Text = self:GetChildComponent("Panel/RolePart/Text", "Text")
	self.NameIcon = self:GetChildComponent("Panel/RolePart/Name", "Image")
	self.Animator = self:GetChildComponent("Panel", "Animator")

	self:InitData()
	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
	SoundMgr.Play(self.infoRole.data.VocalGetChara)
end

function DlgNewRoleUnlock:InitData()
	UIUtil.SetImageSprite(self.CardJob, "UIDyAtlas/RoleJob/ICO_" .. self.infoRole.data.Job .. "_01", self)
	UIUtil.SetImageSprite(self.RoleIcon, self.infoRole.data.UnlockPic[1], self)
	UIUtil.SetImageSprite(self.NameIcon, self.infoRole.data.UnlockPic[2], self)

	self.Text.text = Lang(self.infoRole.data.UnlockInfo)
	self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 4.5, function()
		self:OnButtonGoNextClick()
	end, {})
end

function DlgNewRoleUnlock:OnRegisterEvent()
	self:AddClick(self.GoNextClick, self.OnButtonSkip)
	Event.Instance:Add("CloseNewRoleUnlock", self.OnButtonGoNextClick, self)
	EventListenerMgr.AddAnimListener(self.Animator.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
end

function DlgNewRoleUnlock:OnUnRegisterEvent()
	self:RemoveClick(self.GoNextClick, self.OnButtonSkip)
	Event.Instance:Remove("CloseNewRoleUnlock", self.OnButtonGoNextClick, self)
	EventListenerMgr.RemoveAnimListener(self.Animator.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
end

function DlgNewRoleUnlock:OnButtonSkip()
	if not self.isFinish then
		self.Animator:Update(5)
	else
		self:OnButtonGoNextClick()
	end
end

function DlgNewRoleUnlock:OnButtonGoNextClick()
	if self.endback then
		self.endback()

		self.endback = nil

		return
	end

	if self.callback then
		self.callback()

		self.callback = nil
	end

	self:Close()
end

function DlgNewRoleUnlock:EventAnim()
	self.isFinish = true
end

function DlgNewRoleUnlock:OnBackAndroid()
	self:OnButtonSkip()

	return true
end
