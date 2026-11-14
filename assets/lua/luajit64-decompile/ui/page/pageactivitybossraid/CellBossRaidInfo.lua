-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/CellBossRaidInfo.lua

CellBossRaidInfo = class("CellBossRaidInfo", UIItemBase)

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

function CellBossRaidInfo:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.Page = page
end

function CellBossRaidInfo:PreLoad()
	return
end

function CellBossRaidInfo:Create(vParam)
	CellBossRaidInfo.base.Create(self, vParam)
end

function CellBossRaidInfo:OnLeave()
	ResourceMgr.Unload(self.PrefabCellItem)
	TimerMgr.RemoveTimer(self.timer)
	Event.Instance:Remove("UpdateBossRaidShard", self.UpdateBossRaidShard, self)
	Event.Instance:Remove("BossDeadCallBack", self.BossDeadCallBack, self)
end

function CellBossRaidInfo:OnEnter(vParam)
	local g = self.UIRootObject

	self.BG = GOUtil.FindChildComponent(g, "BG", "Image")
	self.PlayerName = GOUtil.FindChildComponent(g, "BattlePart/FIndBg/PlayerName", "Text")
	self.CountNum = GOUtil.FindChildComponent(g, "BattlePart/CountNumTxt", "Text")
	self.ShardTip = GOUtil.FindChildComponent(g, "BattlePart/ShardTip", "Text")
	self.BossName = GOUtil.FindChildComponent(g, "BattlePart/BossNameTxt", "Text")
	self.BossHPTxt = GOUtil.FindChildComponent(g, "BattlePart/BossHPTxt", "Text")
	self.LastTime = GOUtil.FindChildComponent(g, "BattlePart/LastTimeTxt", "Text")
	self.MonsterLevel = GOUtil.FindChildComponent(g, "BattlePart/LevelTxt", "Text")
	self.HPBg = GOUtil.FindChildComponent(g, "BattlePart/HPBg", "Slider")
	self.HPImage = self:GetChildComponent("BattlePart/HPBg/HP", "Image")
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
	self.BattlePart = GOUtil.FindChildGameObject(g, "BattlePart")
	self.Empty = GOUtil.FindChildGameObject(g, "Empty")
	self.Win = self:GetChildComponent("FinishPart/Win", "Image")
	self.FinishPart = GOUtil.FindChildGameObject(g, "FinishPart")

	self:Localization()
	Event.Instance:Add("UpdateBossRaidShard", self.UpdateBossRaidShard, self)
	Event.Instance:Add("BossDeadCallBack", self.BossDeadCallBack, self)
end

function CellBossRaidInfo:Localization(...)
	local TextAuto

	TextAuto = self:GetChildComponent("BattlePart/FIndBg/FindPlayerTxt", "Text")
	TextAuto.text = _("RaidBoss_Finder")
	TextAuto = self:GetChildComponent("BattlePart/SelfBattleTxt", "Text")
	TextAuto.text = _("RaidBoss_BattleCount")
	TextAuto = self:GetChildComponent("Empty/Text", "Text")
	TextAuto.text = _("RaidBoss_Empty")
	TextAuto = self:GetChildComponent("OtherBossBox/Other/Text", "Text")
	TextAuto.text = _("BossRaid_FromOther")
end

function CellBossRaidInfo:UpdateData(data, playAnimator, playDead, pos)
	self.info = data.info
	self.type = data.type
	self.movePos = pos
	self.playDead = playDead

	if data.info.isEmpty then
		self.BattlePart:SetActive(false)
		self.BG.gameObject:SetActive(false)
		self.SelfBossBox:SetActive(false)
		self.OtherBossBox:SetActive(false)
		self.Empty:SetActive(true)

		return
	else
		self.BattlePart:SetActive(true)
		self.Empty:SetActive(false)
		self.BG.gameObject:SetActive(true)
	end

	self.infoStage = ChapterMgr:GetStage(self.info.stageId)
	self.fromType = data.info.fromType

	local listEnemy = self.infoStage.listMonster
	local enemyId = listEnemy[1]

	self.infoEnemy = EnemyManager:Get(enemyId)

	SetImageSprite(self.MonstarIcon, self.infoEnemy.data.NameIcon, self)

	self.PlayerName.text = self.info.finder
	self.MonsterLevel.text = string.format(_("Desc_Level"), self.info.bossLevel)

	self:SetBattleData(data)
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

	if playAnimator then
		self.UIRootObject.transform:DOScale(Vector3(1.05, 1.05, 1), 0.5)

		self.timer = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.5, function()
			self.UIRootObject.transform:DOScale(Vector3(1, 1, 1), 0.5)
		end, nil)
	end

	if playDead then
		self.FinishPart:SetActive(true)

		self.Sequence1 = DG.Tweening.DOTween.Sequence()

		self.Sequence1:InsertCallback(0.5, function()
			GOUtil.DOFade(self.Win, 1, 0.2, DG.Tweening.Ease.Linear)
			self.Win.transform:DOScale(Vector3(1, 1, 1), 0.5)
		end)

		self.parentTrans = self.UIRootObject.transform.parent
		self.UIRootObject.transform.parent = self.Page.AnimMask.transform

		self.UIRootObject.transform:SetAsFirstSibling()
	end
end

function CellBossRaidInfo:BossDeadCallBack()
	if not self.playDead then
		return
	end

	self.playDead = false
	self.Sequence = DG.Tweening.DOTween.Sequence()

	self.Sequence:InsertCallback(0.5, function()
		self.BattlePart:SetActive(false)
		self.SelfBossBox:SetActive(false)
		self.OtherBossBox:SetActive(false)
		self.BG.gameObject:SetActive(false)
		self.FinishPart:SetActive(false)
		EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_Change_Start", self.UIRootObject, true, 2)
	end)
	self.Sequence:Insert(1.35, self.UIRootObject.transform:DOMove(self.movePos, 0.3))
	self.Sequence:InsertCallback(1.35, function()
		EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_Change_Anim", self.UIRootObject, true, 0.3)
	end)
	self.Sequence:InsertCallback(1.7, function()
		EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_Change_End", self.UIRootObject, true, 1)
	end)
	self.Sequence:InsertCallback(2.2, function()
		self.UIRootObject:SetActive(false)
		self.BG.gameObject:SetActive(true)

		self.UIRootObject.transform.parent = self.parentTrans
		self.UIRootObject.transform.localPosition = Vector3(0, 0, 0)
		self.UIRootObject.transform.localScale = Vector3(1, 1, 1)
	end)
end

function CellBossRaidInfo:SetBattleData(data)
	self.ShardTip.gameObject:SetActive(self.info.selfShared == 0 and self.info.fromType == 0)

	local msg = self.info.bossLevel < GetConfigArgInt("RailBossActiveHardUnlockLevel") and _("BossRaid_CanNotShared") or _("BossRaid_CanNotShared_Hard")

	self.ShardTip.text = TenaryOp(self.info.selfPlayNum > 0, _("BossRaid_CanShared"), msg)

	self.CountNum.gameObject:SetActive(self.info.selfShared ~= 0 or self.info.fromType ~= 0)
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

	local attri = AttributeUtil.GetMonsterAttri(1, self.info.stageId)

	self.BossHPTxt.text = math.ceil(data.info.curProgress) .. "/" .. attri.maxHp
	self.HPBg.value = data.info.curProgress / attri.maxHp
	self.BossName.text = Lang(infoEnemy.data.Name)
	self.CountNum.text = _("Desc_BossRaid_Count") .. "<color=#FDCF00>" .. data.info.member .. "</color>/" .. GetConfigArgInt("RailBossPlayerNum")
	self.SelfBattleNum.text = TenaryOp(self.fromType == 0, "<color=#FDCF00>" .. GetConfigArgInt("RailBossActiveFinderNum") - data.info.selfPlayNum .. "</color>/" .. GetConfigArgInt("RailBossActiveFinderNum"), "<color=#FDCF00>" .. GetConfigArgInt("RailBossActivePartnerNum") - data.info.selfPlayNum .. "</color>/" .. GetConfigArgInt("RailBossActivePartnerNum"))

	local time = self.info.overTime * DateUtil.MillsPerSecond - NetData:GetCurServerTime()

	self.LastTime.text = DateUtil.GetMomentHour00(time / DateUtil.MillsPerSecond)
end

function CellBossRaidInfo:UpdateTime()
	if not self.UIRootObject or self.UIRootObject and not self.UIRootObject.activeSelf or self.info.isEmpty then
		return
	end

	local time = self.info.overTime * DateUtil.MillsPerSecond - NetData:GetCurServerTime()

	if time > 0 then
		self.LastTime.text = DateUtil.GetMomentHour00(time / DateUtil.MillsPerSecond)
	else
		Event.Instance:Fire("RefreshBossRaidDate")
	end
end

function CellBossRaidInfo:UpdateBossRaidShard(bossRaidId)
	if not self.info.isEmpty and self.info.id == bossRaidId then
		self.ShardTip.gameObject:SetActive(false)
		self.CountNum.gameObject:SetActive(true)
		self.SelfBossShard.gameObject:SetActive(true)
		self.SelfBossNotShard.gameObject:SetActive(false)
	end
end
