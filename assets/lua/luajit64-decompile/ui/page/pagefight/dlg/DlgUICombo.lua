-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUICombo.lua

DlgUICombo = class("DlgUICombo", UIPanel_sync)

function DlgUICombo:ctor()
	DlgUICombo.base.ctor(self, "UI/PageFight/Dlg/DlgUICombo")
end

function DlgUICombo:Cache()
	DlgUICombo.base.Cache(self)
end

function DlgUICombo:Close(tParam)
	DlgUICombo.base.Close(self, tParam)
end

function DlgUICombo:Purge()
	DlgUICombo.base.Purge(self)
	UIMgr:RemoveSafeArea(self)
end

function DlgUICombo:OnRegisterEvent()
	Event.Instance:Add("UpdateCombo", self.OnUpdateCombo, self)
end

function DlgUICombo:OnUnRegisterEvent()
	Event.Instance:Remove("UpdateCombo", self.OnUpdateCombo, self)
end

function DlgUICombo:OnEnter(vParam)
	UIMgr:SetSafeArea(self, self.UIRootObject)

	self.txt_combo = self:GetChildComponent("panel/content/txt_combo", "Text")
	self.obj_animator = self:GetChildGameObject("panel/content")
	self.obj_sessionUp = self:GetChildGameObject("panel/content/sessionUp")
	self.txt_sessionUp = self:GetChildComponent("panel/content/sessionUp/txt_sessionUp", "Text")
	self.needDisplay = false

	GOUtil.SetActive(self.obj_sessionUp, false)
	self:Show(false)
end

function DlgUICombo:OnUpdateCombo(msg)
	local count = msg.count
	local camp = msg.camp
	local ownerUniqueId = msg.ownerUniqueId

	if camp == EnumFight.Camp.ENEMY then
		return
	end

	self.txt_combo.text = tostring(count)

	local str = string.format(_("DlgUIComboTxt") .. "+%d%%", count * 0.05 * 100)

	self.txt_sessionUp.text = str

	self:Show(self.needDisplay)
	GOUtil.SetActive(self.obj_animator, false)
	GOUtil.SetActive(self.obj_animator, true)

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	self.timeId = BattleConfig.Delay(2, function()
		self:Show(false)
	end)
end

function DlgUICombo:Open(callback, camp)
	self:Show(self.needDisplay)
end

function DlgUICombo:SetSessionData(sessionType, roleCount)
	if sessionType ~= nil and roleCount ~= nil and type(roleCount) == "number" and roleCount > 1 then
		local val = GetConfigArgJson("SessionRatio")[roleCount]

		if val == nil then
			return
		end

		GOUtil.SetActive(self.obj_sessionUp, true)

		self.needDisplay = true
	else
		self.txt_sessionUp.text = ""

		GOUtil.SetActive(self.obj_sessionUp, false)

		self.needDisplay = false
	end
end
