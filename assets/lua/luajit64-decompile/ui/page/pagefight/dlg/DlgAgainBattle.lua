-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgAgainBattle.lua

DlgAgainBattle = class("DlgAgainBattle", UIPanel_sync)

function DlgAgainBattle:ctor()
	DlgAgainBattle.base.ctor(self, "UI/PageFight/Dlg/DlgAgainBattle")
end

function DlgAgainBattle:Cache()
	DlgAgainBattle.base.Cache(self)
end

function DlgAgainBattle:PreLoad()
	return
end

function DlgAgainBattle:Close()
	DlgAgainBattle.base.Close(self)
end

function DlgAgainBattle:OnRegisterEvent()
	self:AddClick(self.btn_enter, self.OnBtnEnterClick)
	self:AddClick(self.btn_close, self.OnBtnCloseClick)
end

function DlgAgainBattle:OnUnRegisterEvent()
	self:RemoveClick(self.btn_enter, self.OnBtnEnterClick)
	self:RemoveClick(self.btn_close, self.OnBtnCloseClick)
end

function DlgAgainBattle:OnEnter(vParam)
	self.needlife = vParam.needlife
	self.havelife = vParam.havelife
	self.callback = vParam.callback
	self.btn_enter = self:GetChildGameObject("Panel/btn_enter")
	self.tex_havelife = self:GetChildComponent("Panel/BG/Image/tex_havelife", "Text")
	self.tex_havelife.text = self.havelife .. ""
	self.tex_needlife = self:GetChildComponent("Panel/BG/tex_needlife", "Text")
	self.tex_needlife.text = self.needlife .. ""
	self.btn_close = self:GetChildGameObject("Panel/btn_close")

	self:DealWithLocalization()
	self:Init()
end

function DlgAgainBattle:DealWithLocalization(vParam)
	return
end

function DlgAgainBattle:Init(vParam)
	return
end

function DlgAgainBattle:OnBtnEnterClick()
	self.callback()
end

function DlgAgainBattle:OnBtnCloseClick()
	self:Close()
end
