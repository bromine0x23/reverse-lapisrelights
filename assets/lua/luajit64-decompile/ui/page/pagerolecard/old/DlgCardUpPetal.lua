-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Old/DlgCardUpPetal.lua

DlgCardUpPetal = class("DlgCardUpPetal", UIPanel)

function DlgCardUpPetal:ctor()
	DlgCardUpPetal.base.ctor(self, "UI/PanelRoleCard/DlgCardUpPetal")

	self.callback = nil
end

function DlgCardUpPetal:Close(tParam)
	DlgCardUpPetal.base.Close(self, tParam)
end

function DlgCardUpPetal:Purge()
	DlgCardUpPetal.base.Purge(self)
	self:OnLeave()
end

function DlgCardUpPetal:OnLeave()
	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)

		self.Timer1 = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end
end

function DlgCardUpPetal:OnRegisterEvent()
	self:AddClick(self.GoQuit, self.OnClickQuit, PATH_SFX_UI_CANCEL)
end

function DlgCardUpPetal:OnUnRegisterEvent()
	self:RemoveClick(self.GoQuit, self.OnClickQuit)
end

function DlgCardUpPetal:OnEnter(vParam)
	self.GoQuit = self:GetChildGameObject("Bg")
	self.infoRoleCard = vParam.infoRoleCard

	if vParam.callback then
		self.callback = vParam.callback
	end

	self:InitData()
end

function DlgCardUpPetal:InitData()
	self.prePetal = self.infoRoleCard.curPetal - 1
	self.curPetal = self.infoRoleCard.curPetal

	self:UpdatePetal()
end

function DlgCardUpPetal:UpdatePetal()
	local cardRank = self.infoRoleCard.cardRank
	local maxPetal = self.infoRoleCard.maxPetal

	for i = 1, 4 do
		self["PreState" .. i] = self:GetChildGameObject("Panel/Petal/1/State" .. i)
		self["CurState" .. i] = self:GetChildGameObject("Panel/Petal/2/State" .. i)

		self["PreState" .. i]:SetActive(i == cardRank)
		self["CurState" .. i]:SetActive(i == cardRank)
	end

	for i = 1, maxPetal do
		local imgPetal1 = GOUtil.FindChildComponent(self["PreState" .. cardRank], "" .. i, "Image")
		local imgPetal2 = GOUtil.FindChildComponent(self["CurState" .. cardRank], "" .. i, "Image")
		local gray1 = i > self.prePetal
		local gray2 = i > self.curPetal
		local num1 = TenaryOp(gray1, 1, 0)
		local num2 = TenaryOp(gray2, 1, 0)

		UIUtil.SetImageGray(imgPetal1, num1)
		UIUtil.SetImageGray(imgPetal2, num2)
	end
end

function DlgCardUpPetal:OnClickQuit()
	self:Close()

	if self.callback then
		self.callback()

		self.callback = nil
	end
end
