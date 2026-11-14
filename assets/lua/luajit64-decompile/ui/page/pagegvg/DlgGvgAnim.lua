-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgAnim.lua

DlgGvgAnim = class("DlgGvgAnim", UIPanel)

function DlgGvgAnim:ctor()
	self.UIPrefabPath = "UI/PageGvg/DlgGvgAnim"
end

function DlgGvgAnim:Purge()
	DlgGvgAnim.base.Purge(self)

	if self.handle then
		TimerMgr.RemoveTimer(self.handle)
	end
end

function DlgGvgAnim:PreLoad()
	return
end

function DlgGvgAnim:OnRegisterEvent()
	return
end

function DlgGvgAnim:OnUnRegisterEvent()
	return
end

function DlgGvgAnim:OnEnter(vParam)
	self.btn_close = self:GetChildGameObject("panel/btn_close")
	self.handle = TimerMgr.AddTimer(eTimerType.ScaleTime, 1.5, function()
		self:Close()
	end, {})
end

function DlgGvgAnim:ReqReward()
	return
end

function DlgGvgAnim:OnBtnClose()
	self:Close()
end
