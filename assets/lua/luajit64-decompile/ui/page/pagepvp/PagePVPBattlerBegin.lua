-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/PagePVPBattlerBegin.lua

PagePVPBattlerBegin = class("PagePVPBattlerBegin", UIPanel)

local InfoPVPData = require("Info/InfoPVP")

function PagePVPBattlerBegin:ctor()
	self.UIPrefabPath = "UI/PanelPVP/PanelBattleBegin"
end

function PagePVPBattlerBegin:Purge()
	PagePVPBattlerBegin.base.Purge(self)
end

function PagePVPBattlerBegin:OnRegisterEvent()
	return
end

function PagePVPBattlerBegin:OnUnRegisterEvent()
	return
end

function PagePVPBattlerBegin:OnEnter(vParam)
	self.otherplayerdata = vParam
	self.name1 = self:GetChildComponent("Palyer1/Name", "Text")
	self.name2 = self:GetChildComponent("Palyer2/Name", "Text")
	self.power1 = self:GetChildComponent("Palyer1/Power", "Text")
	self.power2 = self:GetChildComponent("Palyer2/Power", "Text")
	self.icon1 = self:GetChildComponent("Palyer1/Icon", "Image")
	self.icon2 = self:GetChildComponent("Palyer2/Icon", "Image")

	self:UpdateUI()
end

function PagePVPBattlerBegin:UpdateUI()
	local playerC, enemyC

	for i, unit in ipairs(GP.Team.PlayerTeam) do
		if unit.IsCenter == true then
			playerC = unit

			break
		end
	end

	for i, unit in ipairs(GP.Team.EnemyTeam) do
		if unit.IsCenter == true then
			enemyC = unit

			break
		end
	end

	UIUtil.SetRawImageTexture(self.icon1, playerC.UnitData.data.FightNSessionCutInPath)
	UIUtil.SetRawImageTexture(self.icon2, enemyC.UnitData.data.FightNSessionCutInPath)

	self.power1.text = GP.GameStartData.myPower
	self.power2.text = GP.GameStartData.otherPower
end

function PagePVPBattlerBegin:OnClickedBtnQuit()
	if self.otherplayerdata then
		self.otherplayerdata()
	end

	self:Show(false)
end
