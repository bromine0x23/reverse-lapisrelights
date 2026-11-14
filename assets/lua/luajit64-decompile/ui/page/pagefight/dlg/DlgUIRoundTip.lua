-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIRoundTip.lua

DlgUIRoundTip = class("DlgUIRoundTip", UIPanel_sync)

function DlgUIRoundTip:ctor()
	DlgUIRoundTip.base.ctor(self, "UI/PageFight/Dlg/DlgUIRoundTip")
end

function DlgUIRoundTip:Cache()
	DlgUIRoundTip.base.Cache(self)
end

function DlgUIRoundTip:Close(tParam)
	DlgUIRoundTip.base.Close(self, tParam)
end

function DlgUIRoundTip:Purge()
	DlgUIRoundTip.base.Purge(self)
end

function DlgUIRoundTip:OnRegisterEvent()
	return
end

function DlgUIRoundTip:OnUnRegisterEvent()
	return
end

function DlgUIRoundTip:OnEnter(vParam)
	self.enemyPanel = self:GetChildGameObject("enemyPanel")
	self.playerPanel = self:GetChildGameObject("playerPanel")

	self:Show(false)
end

function DlgUIRoundTip:Open(callback, camp)
	self:Show(true)

	local isPlayer = camp == EnumFight.UnitClass.PLAYER

	GOUtil.SetActive(self.playerPanel, isPlayer)
	GOUtil.SetActive(self.enemyPanel, not isPlayer)
	BattleConfig.Delay(2, function()
		self:Show(false)

		if callback then
			callback()
		end
	end)
end
