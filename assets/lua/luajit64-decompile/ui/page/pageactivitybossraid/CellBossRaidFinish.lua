-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/CellBossRaidFinish.lua

CellBossRaidFinish = class("CellBossRaidFinish", UIItemBase)

local bgImagePath = {
	"UI/PanelActivityBossRaid/AtlasActivityBossRaid/BG_skybossattack_line_08",
	"UI/PanelActivityBossRaid/AtlasActivityBossRaid/BG_skybossattack_line_06",
	"UI/PanelActivityBossRaid/AtlasActivityBossRaid/BG_skybossattack_line_09"
}
local lineImagePath = {
	"UI/PanelActivityBossRaid/AtlasActivityBossRaid/BG_skybossattack_line_01b",
	"UI/PanelActivityBossRaid/AtlasActivityBossRaid/BG_skybossattack_line_01",
	"UI/PanelActivityBossRaid/AtlasActivityBossRaid/bg_skybossattack_line_01c"
}
local BoxPath = {
	"UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_01",
	"UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_02",
	"UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_03"
}
local BoxOpenPath = {
	"UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_01_on",
	"UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_02_on",
	"UI/PanelActivityBossRaid/AtlasBossPreview/Ic_Bossraidbox_03_on"
}

function CellBossRaidFinish:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBossRaidFinish:PreLoad()
	return
end

function CellBossRaidFinish:Create(vParam)
	CellBossRaidFinish.base.Create(self, vParam)
end

function CellBossRaidFinish:OnLeave()
	ResourceMgr.Unload(self.PrefabCellItem)
end

function CellBossRaidFinish:OnEnter(vParam)
	local g = self.UIRootObject

	self.BG = GOUtil.FindChildComponent(g, "BG", "Image")
	self.PlayerName = GOUtil.FindChildComponent(g, "BattlePart/FIndBg/PlayerName", "Text")
	self.CountNum = GOUtil.FindChildComponent(g, "BattlePart/CountNumTxt", "Text")
	self.BossName = GOUtil.FindChildComponent(g, "BattlePart/BossNameTxt", "Text")
	self.BossHPTxt = GOUtil.FindChildComponent(g, "BattlePart/BossHPTxt", "Text")
	self.Rank = GOUtil.FindChildComponent(g, "BattlePart/Rank", "Text")
	self.MonsterLevel = GOUtil.FindChildComponent(g, "BattlePart/Level", "Text")
	self.HPBg = GOUtil.FindChildComponent(g, "BattlePart/HPBg", "Slider")
	self.HPImage = self:GetChildComponent("BattlePart/HPBg/HP", "Image")
	self.Win = GOUtil.FindChildGameObject(g, "FinishPart/Win")
	self.Lose = GOUtil.FindChildComponent(g, "FinishPart/Lose", "Image")
	self.Box = GOUtil.FindChildComponent(g, "FinishPart/Box", "Image")
	self.BoxOpen = GOUtil.FindChildComponent(g, "FinishPart/Open", "Image")
	self.BoxTxt = GOUtil.FindChildComponent(g, "FinishPart/Text", "Text")
	self.SelfBossBox = GOUtil.FindChildGameObject(g, "SelfBossBox")
	self.SelfBossShard = GOUtil.FindChildComponent(g, "SelfBossBox/Shard", "Image")
	self.SelfBossNotShard = GOUtil.FindChildComponent(g, "SelfBossBox/Self", "Image")
	self.OtherBossBox = GOUtil.FindChildGameObject(g, "OtherBossBox")
	self.FriendBossShard = GOUtil.FindChildComponent(g, "OtherBossBox/Friend", "Image")
	self.FriendBossShardText = GOUtil.FindChildComponent(g, "OtherBossBox/Friend/Text", "Text")
	self.OtherBossShard = GOUtil.FindChildComponent(g, "OtherBossBox/Other", "Image")
	self.FIndBg = self:GetChildComponent("BattlePart/FIndBg", "Image")
	self.MonstarIcon = GOUtil.FindChildComponent(g, "BattlePart/CellMonster/Icon", "Image")
	self.SelfBattleNum = GOUtil.FindChildComponent(g, "BattlePart/SelfBattleNum", "Text")
	self.SelfBattleBg = self:GetChildComponent("BattlePart/SelfBattleBg", "Image")
	self.GetRewardBtn = GOUtil.FindChildGameObject(g, "FinishPart/GetBox")

	self:Localization()
end

function CellBossRaidFinish:Localization(...)
	local TextAuto

	TextAuto = self:GetChildComponent("BattlePart/FIndBg/FindPlayerTxt", "Text")
	TextAuto.text = _("RaidBoss_Finder")
	TextAuto = self:GetChildComponent("BattlePart/SelfBattleTxt", "Text")
	TextAuto.text = _("RaidBoss_BattleCount")
	TextAuto = self:GetChildComponent("OtherBossBox/Other/Text", "Text")
	TextAuto.text = _("BossRaid_FromOther")
end

function CellBossRaidFinish:UpdateData(data)
	self.info = data.info

	self.BG.gameObject:SetActive(true)

	self.infoStage = ChapterMgr:GetStage(self.info.stageId)
	self.fromType = data.info.fromType

	local listEnemy = self.infoStage.listMonster
	local enemyId = listEnemy[1]

	self.infoEnemy = EnemyManager:Get(enemyId)

	SetImageSprite(self.MonstarIcon, self.infoEnemy.data.NameIcon, self)

	self.PlayerName.text = self.info.finder
	self.MonsterLevel.text = string.format(_("Desc_Level"), self.info.bossLevel)

	self:SetBattleData(data)

	if data.info:IsFinished() then
		self:SetFinshData(data)
	end

	self.SelfBossBox:SetActive(self.fromType == 0)
	self.OtherBossBox:SetActive(self.fromType ~= 0)

	if self.fromType ~= 0 then
		SetImageSprite(self.BG, TenaryOp(self.info.bossLevel >= GetConfigArgInt("RailBossActiveHardUnlockLevel"), bgImagePath[3], bgImagePath[2]), self)
		SetImageSprite(self.FIndBg, TenaryOp(self.info.bossLevel >= GetConfigArgInt("RailBossActiveHardUnlockLevel"), lineImagePath[3], lineImagePath[2]), self)
		SetImageSprite(self.SelfBattleBg, TenaryOp(self.info.bossLevel >= GetConfigArgInt("RailBossActiveHardUnlockLevel"), lineImagePath[3], lineImagePath[2]), self)
	else
		SetImageSprite(self.BG, bgImagePath[1], self)
		SetImageSprite(self.FIndBg, lineImagePath[1], self)
		SetImageSprite(self.SelfBattleBg, lineImagePath[1], self)
	end
end

function CellBossRaidFinish:SetBattleData(data)
	self.SelfBossShard.gameObject:SetActive(self.info.selfShared ~= 0 and self.info.fromType == 0)
	self.SelfBossNotShard.gameObject:SetActive(self.info.selfShared == 0 and self.info.fromType == 0)
	self.FriendBossShard.gameObject:SetActive(self.info.fromType == 1 or self.info.fromType == 2)

	self.FriendBossShardText.text = TenaryOp(self.info.fromType == 1, _("BossRaid_FromFriend"), _("BossRaid_FromUnion"))

	self.OtherBossShard.gameObject:SetActive(self.info.fromType == 4)

	local listEnemy = self.infoStage.listMonster
	local enemyId = listEnemy[1]
	local infoEnemy = EnemyManager:Get(enemyId)

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

	local attri = AttributeUtil.GetMonsterAttri(1, self.infoStage.id)

	self.BossHPTxt.text = math.ceil(data.info.curProgress) .. "/" .. attri.maxHp
	self.HPBg.value = data.info.curProgress / attri.maxHp
	self.BossName.text = Lang(infoEnemy.data.Name)
	self.CountNum.text = _("RaidBoss_Num") .. data.info.member .. "/" .. GetConfigArgInt("RailBossPlayerNum")
	self.Rank.text = string.format(_("Desc_Damage_Rank"), data.info.rank)
	self.SelfBattleNum.text = TenaryOp(self.fromType == 0, GetConfigArgInt("RailBossActiveFinderNum") - data.info.selfPlayNum .. "/" .. GetConfigArgInt("RailBossActiveFinderNum"), GetConfigArgInt("RailBossActivePartnerNum") - data.info.selfPlayNum .. "/" .. GetConfigArgInt("RailBossActivePartnerNum"))
end

function CellBossRaidFinish:SetFinshData(data)
	local gray = 0

	if data.info.curProgress ~= 0 then
		self.Win:SetActive(false)
		self.Lose.gameObject:SetActive(true)
		self.Box.gameObject:SetActive(false)
		self.BoxOpen.gameObject:SetActive(false)
		self.BoxTxt.gameObject:SetActive(true)

		gray = 0
	else
		self.Win:SetActive(true)
		self.Lose.gameObject:SetActive(false)
		self.Box.gameObject:SetActive(self.info.selfStatus == 0)
		self.BoxOpen.gameObject:SetActive(self.info.selfStatus == 1)
		self.BoxTxt.gameObject:SetActive(false)

		gray = 1
		self.BoxIndex = 1

		for i, v in ipairs(self.info.raidBossData.FinishReward) do
			if self.info.randomAward == v[1] then
				self.BoxIndex = i

				break
			end
		end

		SetImageSprite(self.Box, BoxPath[self.BoxIndex], self)
		SetImageSprite(self.BoxOpen, BoxOpenPath[self.BoxIndex], self)
	end

	UIUtil.SetImageGray(self.MonstarIcon, gray)
	UIUtil.SetImageGray(self.BG, gray)
	UIUtil.SetImageGray(self.FIndBg, gray)
	UIUtil.SetImageGray(self.SelfBattleBg, gray)
	UIUtil.SetImageGray(self.HPImage, gray)
	UIUtil.SetImageGray(self.BoxOpen, 1)
	UIUtil.SetImageGray(self.Lose, 1)
end
