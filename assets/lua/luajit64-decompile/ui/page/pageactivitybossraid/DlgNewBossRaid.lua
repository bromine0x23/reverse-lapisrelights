-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/DlgNewBossRaid.lua

DlgNewBossRaid = class("DlgNewBossRaid", UIPanel)

function DlgNewBossRaid:ctor()
	self.UIPrefabPath = "UI/PanelActivityBossRaid/DlgNewBossRaid"
end

function DlgNewBossRaid:OnBack()
	UIMgr.PopPanel()
end

function DlgNewBossRaid:PreLoad()
	return
end

function DlgNewBossRaid:Purge()
	DlgNewBossRaid.base.Purge(self)
	UnloadAllImageSprite(self)
end

function DlgNewBossRaid:OnRegisterEvent()
	self:AddClick(self.Cancel, self.Close)
	self:AddClick(self.Battle, self.OnBattleClick)
end

function DlgNewBossRaid:OnUnRegisterEvent()
	self:RemoveClick(self.Cancel, self.Close)
	self:RemoveClick(self.Battle, self.OnBattleClick)
end

function DlgNewBossRaid:OnEnter(vParam)
	self.callback = vParam.callback
	self.Battle = self:GetChildGameObject("Battle")
	self.Cancel = self:GetChildGameObject("Cancel")

	local RaidBoss = require("luaData.RaidBoss")
	local data = RaidBoss[vParam.dropRaidBossId]

	self.Text = self:GetChildComponent("Panel/Level/Text", "Text")
	self.Boss = self:GetChildComponent("Panel/Boss", "Image")
	self.Text.text = "lv" .. data.Level

	local text = self:GetChildComponent("Panel/Award/Text", "Text")

	text.text = _("Desc_BossRaidWinTip")
	self.infostage = ChapterMgr:GetStage(tonumber(vParam.dropRaidBossStageId))

	local listEnemy = self.infostage.listMonster
	local enemyId = listEnemy[1]
	local infoEnemy = EnemyManager:Get(enemyId)
	local path = infoEnemy.actorData.UiShowIcon

	UIUtil.SetImageSprite(self.Boss, path, self, true)

	text = self:GetChildComponent("Cancel/Text", "Text")
	text.text = _("RaidBoss_CancelText")
	text = self:GetChildComponent("Battle/Text", "Text")
	text.text = _("RaidBoss_BattleText")
end

function DlgNewBossRaid:OnBattleClick()
	if self.callback then
		self.callback()
	end

	self:Close()
end

function DlgNewBossRaid:OnBackAndroid()
	self:Close()
end
