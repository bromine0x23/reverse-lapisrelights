-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgPlayerLevelupResult.lua

require("UI/Dlg/DlgBase")

DlgPlayerLevelupResult = class("DlgPlayerLevelupResult", DlgBase)

function DlgPlayerLevelupResult:Cache()
	self:SubmitUIPrefabCacheLua("UI/Common/DlgLevelup")
end

function DlgPlayerLevelupResult:OnEnter(vParam)
	self.SetterData = vParam
	self.ImageBg = self:GetChildGameObject("ImageBg")
	self.Bar1 = self:GetChildGameObject("Panel/Bar1")
	self.Bar2 = self:GetChildGameObject("Panel/Bar2")
	self.Bar3 = self:GetChildGameObject("Panel/Bar3")
	self.Bar4 = self:GetChildGameObject("Panel/Bar4")
	self.Bar5 = self:GetChildGameObject("Panel/Bar5")

	local text1 = GOUtil.FindChildComponent(self.Bar1, "Text", "Text")
	local text2 = GOUtil.FindChildComponent(self.Bar2, "Text", "Text")
	local text3 = GOUtil.FindChildComponent(self.Bar3, "Text", "Text")
	local text4 = GOUtil.FindChildComponent(self.Bar4, "Text", "Text")
	local text5 = GOUtil.FindChildComponent(self.Bar5, "Text", "Text")

	text1.text = Localization.Get("DESC_LVUP_TXT1")
	text2.text = Localization.Get("DESC_LVUP_TXT2")
	text3.text = Localization.Get("DESC_LVUP_TXT3")
	text4.text = Localization.Get("DESC_LVUP_TXT4")
	text5.text = Localization.Get("DESC_LVUP_TXT5")

	self.Bar1:SetActive(false)
	self.Bar2:SetActive(false)
	self.Bar3:SetActive(false)
	self.Bar4:SetActive(false)
	self.Bar5:SetActive(false)
	self:SetData()
	self:ShowAni(self.Bar1)

	self.timer1 = TimerMgr.AddTimer(0.3, function()
		self:ShowAni(self.Bar2)
	end)
	self.timer2 = TimerMgr.AddTimer(0.6, function()
		self:ShowAni(self.Bar3)
	end)
	self.timer3 = TimerMgr.AddTimer(0.8999999999999999, function()
		self:ShowAni(self.Bar4)
	end)
	self.timer4 = TimerMgr.AddTimer(0.8999999999999999, function()
		self:ShowAni(self.Bar5)
	end)
end

function DlgPlayerLevelupResult:SetData()
	local preLv = self.SetterData.beforeLevel
	local nextLv = self.SetterData.afterLevel
	local preMaxPower = self.SetterData.beforeMaxPower
	local nextMaxPower = self.SetterData.afterMaxPower
	local preLimitLv = self.SetterData.beforeLimitLevel
	local nextLimitLv = self.SetterData.afterLimitLevel
	local preFansNum = 5
	local infoLevel = LevelManager:Get(preLv)

	if infoLevel == nil or infoLevel.data == nil then
		-- block empty
	else
		preFansNum = infoLevel.data.FansNumber
	end

	local nextFansNum = 5
	local infoLevel2 = LevelManager:Get(nextLv)

	if infoLevel2 == nil or infoLevel2.data == nil then
		-- block empty
	else
		nextFansNum = infoLevel2.data.FansNumber
	end

	local curPower = PlayerInst:GetPower()
	local addPower = infoLevel.data.PlayerStamina

	self:SetBar(self.Bar1, preLv, nextLv)
	self:SetBar(self.Bar2, 0, "+" .. nextMaxPower - preMaxPower)
	self:SetBar(self.Bar3, curPower - addPower, curPower)
	self:SetBar(self.Bar4, preLimitLv, nextLimitLv)
	self:SetBar(self.Bar5, preFansNum, nextFansNum)
end

function DlgPlayerLevelupResult:ShowAni(g, delayTime)
	if g == nil then
		return
	end

	g:SetActive(true)

	local Bar1Trans = GOUtil.GetComponent(g, "Transform")
	local p = Bar1Trans.localPosition

	UIUtility.SetTransLocalPos(Bar1Trans, Vector3(p.x + 200, p.y, p.z))

	local tweener = DG.Tweening.ShortcutExtensions.DOLocalMoveX(Bar1Trans, 0, 0.4, false)
end

function DlgPlayerLevelupResult:SetBar(g, t1, t2)
	local text1 = GOUtil.FindChildComponent(g, "Text1", "Text")
	local text2 = GOUtil.FindChildComponent(g, "Text2", "Text")

	text1.text = t1
	text2.text = t2

	local Image2 = GOUtil.FindChildGameObject(g, "Image2")

	Image2:SetActive(t1 ~= t2)
end

function DlgPlayerLevelupResult:OnLeave()
	return
end

function DlgPlayerLevelupResult:OnRegisterEventForInstruction()
	self:OnRegisterEvent()
end

function DlgPlayerLevelupResult:OnRegisterEvent()
	self:AutoRegistClick(self.ImageBg, self.OnNext)
end

function DlgPlayerLevelupResult:OnUnRegisterEvent()
	return
end

function DlgPlayerLevelupResult:OnNext(...)
	InLevelup = false

	self:Close()

	local dlg = DlgPlayerLevelup.GetInstance()

	ClearDlgMemory(dlg, false)

	DlgPlayerLevelup.Instance = nil

	if self.timer1 then
		TimerMgr.RemoveTimer(self.timer1)
	end

	if self.timer2 then
		TimerMgr.RemoveTimer(self.timer2)
	end

	if self.timer3 then
		TimerMgr.RemoveTimer(self.timer3)
	end

	if self.timer4 then
		TimerMgr.RemoveTimer(self.timer4)
	end

	InstructionMgr:ShowMaskWithoutArg()
end
