-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUISongName.lua

DlgUISongName = class("DlgUISongName", UIPanel_sync)

function DlgUISongName:ctor()
	DlgUISongName.base.ctor(self, "UI/PageFight/Dlg/DlgUISongName")
end

function DlgUISongName:Cache()
	DlgUISongName.base.Cache(self)
end

function DlgUISongName:Close()
	DlgUISongName.base.Close(self)
end

function DlgUISongName:OnEnter()
	self:Show(false)
end

function DlgUISongName:Purge()
	DlgUISongName.base.Purge(self)
end

function DlgUISongName:Open()
	self:Show(true)
	BattleConfig.Delay(5, function()
		self:Show(false)
	end)
end

function DlgUISongName:OnRegisterEvent()
	return
end

function DlgUISongName:OnUnRegisterEvent()
	return
end
