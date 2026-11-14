-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIFirstHand.lua

DlgUIFirstHand = class("DlgUIFirstHand", UIPanel_sync)

function DlgUIFirstHand:ctor()
	DlgUIFirstHand.base.ctor(self, "UI/PageFight/Dlg/DlgUIFirstHand")
end

function DlgUIFirstHand:Cache()
	DlgUIFirstHand.base.Cache(self)
end

function DlgUIFirstHand:Close()
	DlgUIFirstHand.base.Close(self)
end

function DlgUIFirstHand:Purge()
	DlgUIFirstHand.base.Purge(self)
end

function DlgUIFirstHand:OnEnter()
	self.callback = nil

	self:Show(false)
end

function DlgUIFirstHand:Open(callback)
	self.callback = callback

	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		self:Hide()

		return
	end

	local firstHand = GP.Team.Speeds[1] >= GP.Team.Speeds[2]
	local headName = ""

	if firstHand == true then
		headName = "camp1/"

		SoundMgr.PostEvent("Play_SE_020_0051", UIMgr.UICamera.gameObject)
	else
		headName = "camp2/"

		SoundMgr.PostEvent("Play_SE_020_0052", UIMgr.UICamera.gameObject)
	end

	self.panel = self:GetChildGameObject(headName)

	GOUtil.SetActive(self.panel, true)

	self.name1 = self:GetChildComponent(headName .. "Palyer1/Name", "Text")
	self.name2 = self:GetChildComponent(headName .. "Palyer2/Name", "Text")
	self.power1 = self:GetChildComponent(headName .. "Palyer1/Power", "Text")
	self.power2 = self:GetChildComponent(headName .. "Palyer2/Power", "Text")
	self.icon1 = self:GetChildComponent(headName .. "Palyer1/Icon", "RawImage")
	self.icon2 = self:GetChildComponent(headName .. "Palyer2/Icon (1)", "RawImage")

	self:UpdateUI()
	self:Show(true)
	BattleConfig.Delay(3, function()
		self:Hide()
	end)
end

function DlgUIFirstHand:Hide()
	self:Show(false)

	if self.callback then
		self.callback()
	end
end

function DlgUIFirstHand:OnRegisterEvent()
	return
end

function DlgUIFirstHand:OnUnRegisterEvent()
	return
end

function DlgUIFirstHand:UpdateUI()
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
	GOUtil.DoFloat(self.power1, GP.Team.Speeds[1], 1)
	GOUtil.DoFloat(self.power2, GP.Team.Speeds[2], 1)

	self.name1.text = GP.GameStartData.myName
	self.name2.text = GP.GameStartData.otherName
end
