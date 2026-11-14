-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/PageBossRaidBattleEnd.lua

require("UI.Item.CellItem")

PageBossRaidBattleEnd = class("PageBossRaidBattleEnd", UIPanel)

function PageBossRaidBattleEnd:ctor()
	self.UIPrefabPath = "UI/PanelActivityBossRaid/PageBossRaidBattleEnd"
end

function PageBossRaidBattleEnd:Purge()
	PageBossRaidBattleEnd.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellItem)
end

function PageBossRaidBattleEnd:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function PageBossRaidBattleEnd:OnLeave()
	if self.listCellReward and #self.listCellReward > 0 then
		for i = 1, #self.listCellReward do
			self.listCellReward[i]:OnLeave()
		end
	end

	UITweenUtil.RemoveAllTween()
end

function PageBossRaidBattleEnd:OnRegisterEvent()
	self:AddClick(self.Bg.gameObject, self.OnClickedBtnQuit)
end

function PageBossRaidBattleEnd:OnUnRegisterEvent()
	self:RemoveClick(self.UIRootObject, self.OnClickedBtnQuit)
end

function PageBossRaidBattleEnd:OnEnter(vParam)
	self.data = vParam
	self.Bg = self:GetChildGameObject("Bg")
	self.BossIcon = self:GetChildComponent("PanelReward/Mask/BossIcon", "Image")
	self.HPImage = self:GetChildComponent("PanelReward/HPBg/HP", "Image")
	self.BossHPTxt = self:GetChildComponent("PanelReward/HPBg/BossHPTxt", "Text")
	self.BossHPTxt.fontSize = 22
	self:GetChildComponent("PanelReward/KillAward/RewardTital", "Text").text = PageCombatReadinessJP.clickType == 0 and _("Desc_CombatReadiness_KillReward") or "救援報酬"
	self.Damge = self:GetChildComponent("PanelReward/Line/Damge", "Text")
	self.KillAward = self:GetChildGameObject("PanelReward/KillAward")
	self.harms = vParam.harms
	self.stageId = vParam.stageId
	self.closecallback = vParam.callBack

	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)
	self:UpdatePanelDamage()
	self:UpdatePanelReward()
end

function PageBossRaidBattleEnd:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("PanelReward/KillAward/RewardTital", "Text")
	TextAuto.text = _("Desc_CombatReadiness_KillReward")
	TextAuto = self:GetChildComponent("PanelReward/Text", "Text")
	TextAuto.text = _("Desc_ClickClose")
	TextAuto = self:GetChildComponent("PanelReward/Line/Text", "Text")
	TextAuto.text = _("Desc_TotalDamage")
end

function PageBossRaidBattleEnd:UpdatePanelDamage()
	self.infoStage = ChapterMgr:GetStage(self.stageId)

	local listEnemy = self.infoStage.listMonster
	local enemyId = listEnemy[1]

	self.infoEnemy = EnemyManager:Get(enemyId)

	local path = self.infoEnemy.actorData.UiShowIcon

	UIUtil.SetImageSprite(self.BossIcon, path, self, true)
	require("GameLogic/Util/AttributeUtil")

	local level = 1
	local monsterIdx = 0
	local monsterLvList = self.infoStage.BattleData.MonsterLv
	local mosters = self.infoStage.BattleData.Enemy

	for _, waveEnemys in ipairs(mosters) do
		for i, UnitId in ipairs(waveEnemys) do
			monsterIdx = monsterIdx + 1
			level = monsterLvList[monsterIdx]

			if not level or type(level) ~= "number" then
				level = 1
			end
		end
	end

	local bossHp = AttributeUtil.GetMonsterAttri(1, self.stageId).maxHp
	local allHarm = 0

	if self.harms then
		for i = 1, #self.harms do
			allHarm = allHarm + self.harms[i].harm
		end

		self.Damge.text = self.data.bloodCost[1]
	else
		self.Damge.text = bossHp - self.data.curHp
	end

	local curHp = TenaryOp(self.data.curHp, self.data.curHp, math.max(bossHp - allHarm, 0))

	self.BossHPTxt.text = curHp .. "/" .. bossHp

	local percent = curHp / bossHp

	UITweenUtil.FillAmountAnim(self.HPImage, 0, percent, percent)
end

function PageBossRaidBattleEnd:UpdatePanelReward()
	local setter = SetterData.GetSetterData(self.data.setter)

	setter:Parse()

	local KillAwardScrollArea = self:GetChildGameObject("PanelReward/KillAward/ScrollArea")
	local KillAwardScrollView = GOUtil.AddMissingComponent(KillAwardScrollArea, "UIScrollView")

	KillAwardScrollView.content = GOUtil.FindChildComponent(KillAwardScrollArea, "Content", "RectTransform")
	KillAwardScrollView.vertical = true
	KillAwardScrollView.horizontal = false
	self.listCellReward = {}

	for i = 1, #setter.list do
		local infoItem = SetterData.GetItemFromAsset(setter.list[i])

		if infoItem:GetNum() > 0 then
			local item = CellItem(self.PrefabCellItem, KillAwardScrollView.content.gameObject, self)

			item:Create()
			item:UpdateData(i, infoItem, true)

			if setter.list[i].from == protocol_pb.AF_STAGE_HIGH_AWARD then
				item:SetHigh(true)
			elseif setter.list[i].from == protocol_pb.AF_STAGE_FIRST then
				item:SetFirstPass(true)
			elseif setter.list[i].from == protocol_pb.AF_EXTRA_AWARD then
				item:SetExtra(true)
			end

			table.insert(self.listCellReward, item)
		end
	end

	SetActiveFunc(self.KillAward, #self.listCellReward > 0)
end

function PageBossRaidBattleEnd:OnClickedBtnQuit()
	self:Close()
	self:OnLeave()

	if self.infoStage.data.ActType == 20 then
		self.closecallback()
	else
		require("UI/Page/PageActivityBossRaid/DlgBossRaidOver")
		UIMgr.AddPanel(DlgBossRaidOver(), self.data, self.Parent)
	end
end

function PageBossRaidBattleEnd:OnBackAndroid()
	self:OnClickedBtnQuit()
end
