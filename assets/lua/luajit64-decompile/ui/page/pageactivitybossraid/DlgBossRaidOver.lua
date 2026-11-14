-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/DlgBossRaidOver.lua

require("UI/Page/PageActivityBossRaid/CellBossRaidDamage")
require("UI/Page/PageActivityBossRaid/CellBossRaidRewardItem")
require("UI/Page/PageFight/Cells/CellExtraAward")

DlgBossRaidOver = class("DlgBossRaidOver", UIPanel)

function DlgBossRaidOver:ctor()
	self.UIPrefabPath = "UI/PanelActivityBossRaid/PageBossRaidOver"
end

function DlgBossRaidOver:Purge()
	DlgBossRaidOver.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellBossRaidDamage)
	ResourceMgr.Unload(self.PrefabCellBossRaidReward)
	ResourceMgr.Unload(self.PrefabCellExtraAward)
end

function DlgBossRaidOver:PreLoad()
	self:LoadResAsync("UI/PanelActivityBossRaid/CellBossRaidDamage", "PrefabCellBossRaidDamage")
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
	self:LoadResAsync("UI/PanelActivityBossRaid/CelBoxAwaed", "PrefabCellExtraAward")
end

function DlgBossRaidOver:OnLeave()
	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)
	end

	if self.listBoxReward and #self.listBoxReward > 0 then
		for i = 1, #self.listBoxReward do
			self.listBoxReward[i]:OnLeave()
		end
	end

	if self.listCellReward and #self.listCellReward > 0 then
		for i = 1, #self.listCellReward do
			self.listCellReward[i]:OnLeave()
		end
	end

	UITweenUtil.RemoveAllTween()
end

function DlgBossRaidOver:OnRegisterEvent()
	if self.isBattleOver then
		self:AddClick(self.OKBtn, self.OnClickedBtnQuit)
		self:AddClick(self.SharedBtn, self.OnClickedSharedBtn)
	else
		self:AddClick(self.Bg.gameObject, self.OnClickedBtnQuit)
	end

	self:AddClick(self.RewardBtn, self.OnClickedRewardBtn)
	self:AddClick(self.DamageBtn, self.OnClickedDamageBtn)
end

function DlgBossRaidOver:OnUnRegisterEvent()
	if self.isBattleOver then
		self:RemoveClick(self.OKBtn, self.OnClickedBtnQuit)
		self:RemoveClick(self.SharedBtn, self.OnClickedSharedBtn)
	else
		self:RemoveClick(self.UIRootObject, self.OnClickedBtnQuit)
	end

	self:RemoveClick(self.RewardBtn, self.OnClickedRewardBtn)
	self:RemoveClick(self.DamageBtn, self.OnClickedDamageBtn)
end

function DlgBossRaidOver:OnEnter(vParam)
	self.isBattleOver = vParam.isBattleOver
	self.boxLevel = vParam.boxLevel
	self.Tital = self:GetChildGameObject("Tital")
	self.RewardImage = self:GetChildGameObject("Tital/RewardImage")
	self.DamageImage = self:GetChildGameObject("Tital/DamageImage")

	local img = self:GetChildComponent("Tital/RewardImage", "Image")

	img:SetNativeSize()

	img = self:GetChildComponent("Tital/DamageImage", "Image")

	img:SetNativeSize()

	self.PanelDamage = self:GetChildGameObject("PanelDamage")
	self.HeadIcon = self:GetChildComponent("PanelDamage/HeadIcon", "Image")
	self.ImageBox = self:GetChildComponent("PanelDamage/HeadIcon/ImageBox", "Image")
	self.TotalDamage = self:GetChildComponent("PanelDamage/TotalDamage/Text", "Text")
	self.MyRank = self:GetChildComponent("PanelDamage/MyRank/Text", "Text")
	self.MyName = self:GetChildComponent("PanelDamage/NameBg/Text", "Text")
	self.RewardBtn = self:GetChildGameObject("PanelDamage/RewardBtn")
	self.Dead = self:GetChildGameObject("PanelDamage/Dead")
	self.HPBg = self:GetChildGameObject("PanelDamage/HPBg")
	self.HPImage = self:GetChildComponent("PanelDamage/HPBg/HP", "Image")
	self.CellMonster = self:GetChildGameObject("PanelDamage/CellMonster")
	self.Icon = self:GetChildComponent("PanelDamage/CellMonster/Icon", "Image")
	self.LevelTxt = self:GetChildComponent("PanelDamage/CellMonster/LevelTxt", "Text")
	self.BossHPTxt = self:GetChildComponent("PanelDamage/HPBg/BossHPTxt", "Text")
	self.PanelReward = self:GetChildGameObject("PanelReward")
	self.RankNum = self:GetChildComponent("PanelReward/RankNum", "Text")
	self.RankImage = self:GetChildGameObject("PanelReward/Image")
	self.DamageBtn = self:GetChildGameObject("PanelReward/DamageBtn")
	self.Bg = self:GetChildComponent("Bg", "Image")
	self.OKBtn = self:GetChildGameObject("PanelDamage/ButtonGroup/Button")
	self.SharedBtn = self:GetChildGameObject("PanelDamage/ButtonGroup/SharedBtn")
	self.SharedText = self:GetChildComponent("PanelDamage/ButtonGroup/SharedBtn/Text", "Text")
	self.SharedText.text = _("Desc_Shared")
	self.BoxAward = self:GetChildGameObject("PanelReward/BoxAward")
	self.Effect = self:GetChildGameObject("Effect")

	if vParam.isBattleOver == true then
		self.harms = vParam.harms
		self.stageId = vParam.stageId
		self.closecallback = vParam.callBack

		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)
		self.PanelReward:SetActive(false)
		self.PanelDamage:SetActive(true)
		self.DamageImage:SetActive(true)
		self.RewardBtn:SetActive(false)

		local infoBossRaid = ActivityBossRaidMgr:Get(ActivityBossRaidMgr.curBossRaidId)

		if infoBossRaid.selfShared == 1 or infoBossRaid.fromType ~= 0 then
			self.SharedBtn:SetActive(false)
		end

		self:UpdatePanelDamage()
	else
		self.setter = vParam.setter

		if vParam.stageId then
			self.harms = vParam.harms
			self.stageId = vParam.stageId
			self.closecallback = vParam.callBack

			self.OKBtn:SetActive(false)
			self.SharedBtn:SetActive(false)
			self.PanelReward:SetActive(true)
			self.PanelDamage:SetActive(false)
			self.RewardImage:SetActive(true)
			self.DamageBtn:SetActive(false)
			self:UpdatePanelReward()
			self:UpdatePanelDamage()
		else
			self.closecallback = vParam.callBack

			self.OKBtn:SetActive(false)
			self.SharedBtn:SetActive(false)
			self.SharedBtn:SetActive(false)
			self.PanelReward:SetActive(true)
			self.PanelDamage:SetActive(false)
			self.RewardImage:SetActive(true)
			self.DamageBtn:SetActive(false)
			self.RankNum.gameObject:SetActive(false)
			self.RankImage:SetActive(false)
			self:UpdatePanelReward()
		end
	end
end

function DlgBossRaidOver:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("PanelReward/KillAward/RewardTital", "Text")
	TextAuto.text = _("Desc_CombatReadiness_KillReward")
	TextAuto = self:GetChildComponent("PanelReward/BoxAward/RewardTital", "Text")
	TextAuto.text = _("Desc_BoxReward")
	TextAuto = self:GetChildComponent("PanelReward/Text", "Text")
	TextAuto.text = _("Desc_ClickClose")
	TextAuto = self:GetChildComponent("PanelReward/DamageBtn/Text", "Text")
	TextAuto.text = _("Desc_DamageRank")
	TextAuto = self:GetChildComponent("PanelDamage/RewardBtn/Text", "Text")
	TextAuto.text = _("Desc_BossRaidAward")
	TextAuto = self:GetChildComponent("PanelDamage/MyRank/Text (1)", "Text")
	TextAuto.text = _("Desc_DamageRank")
	TextAuto = self:GetChildComponent("PanelDamage/TotalDamage/Text", "Text")
	TextAuto.text = _("Desc_TotalDamage")
end

function DlgBossRaidOver:UpdatePanelDamage()
	table.sort(self.harms, function(a, b)
		return a.harm > b.harm
	end)

	local allHarm = 0

	for i = 1, #self.harms do
		allHarm = allHarm + self.harms[i].harm

		if PlayerInst.InfoPlayer.pid == self.harms[i].playerId then
			self.TotalDamage.text = self.harms[i].harm
			self.MyRank.text = i
			self.RankNum.text = i
			self.MyName.text = self.harms[i].nickname

			local infoItem = ItemManager:Get(self.harms[i].headId)

			UIUtil.SetImageSprite(self.HeadIcon, infoItem:GetIcon(), self)

			local infoItem = ItemManager:Get(self.harms[i].headFrame)

			UIUtil.SetImageSprite(self.ImageBox, infoItem:GetIcon(), self)
		end
	end

	self.infoStage = ChapterMgr:GetStage(self.stageId)

	local listEnemy = self.infoStage.listMonster
	local enemyId = listEnemy[1]

	self.infoEnemy = EnemyManager:Get(enemyId)

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
	local curHp = math.max(bossHp - allHarm, 0)

	self.LevelTxt.text = string.format(_("Desc_ShowLevel"), level)
	self.BossHPTxt.text = curHp .. "/" .. bossHp

	local percent = curHp / bossHp

	UITweenUtil.FillAmountAnim(self.HPImage, 0, percent, percent)
	SetImageSprite(self.Icon, self.infoEnemy.data.NameIcon, self)

	if bossHp <= allHarm then
		self.SharedBtn:SetActive(false)
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestBossRaidRecord(function(pb)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if pb.result.code == NetManager.Result_Sucess then
				-- block empty
			end
		end)
		self.Dead:SetActive(true)
		self.HPBg.gameObject:SetActive(false)
		self.CellMonster:SetActive(false)

		local infoBossRaid = ActivityBossRaidMgr:Get(ActivityBossRaidMgr.curBossRaidId)

		if infoBossRaid and infoBossRaid.fromType == 0 then
			ActivityBossRaidMgr.selfBossEndTime = 0
		end
	else
		self.Dead:SetActive(false)
	end

	local scrollArea = self:GetChildGameObject("PanelDamage/ScrollArea")
	local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	scrollView.vertical = true
	scrollView.horizontal = false

	if self.listCellDamage then
		for i = 1, #self.listCellDamage do
			self.listCellDamage[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(scrollView.content.gameObject)

	self.listCellDamage = {}

	for i = 1, #self.harms do
		local cell = CellBossRaidDamage(self.PrefabCellBossRaidDamage, scrollView.content.gameObject, self)
		local data = {}

		data.damage = self.harms[i]
		data.rank = i
		data.type = 2
		data.stageId = self.stageId
		data.bossHp = bossHp

		cell:Create(data)
		table.insert(self.listCellDamage, cell)
	end

	UITweenUtil.BossRaidOverAnimation(scrollView.content, 300, 0.3)
end

function DlgBossRaidOver:UpdatePanelReward()
	local setter = SetterData.GetSetterData(self.setter)

	setter:Parse()

	local KillAwardScrollArea = self:GetChildGameObject("PanelReward/KillAward/ScrollArea")
	local KillAwardScrollView = GOUtil.AddMissingComponent(KillAwardScrollArea, "UIScrollView")

	KillAwardScrollView.content = GOUtil.FindChildComponent(KillAwardScrollArea, "Content", "RectTransform")
	KillAwardScrollView.vertical = true
	KillAwardScrollView.horizontal = false

	local BoxAwardScrollArea = self:GetChildGameObject("PanelReward/BoxAward/ScrollArea")
	local BoxAwardScrollView = GOUtil.AddMissingComponent(BoxAwardScrollArea, "UIScrollView")

	BoxAwardScrollView.content = GOUtil.FindChildComponent(BoxAwardScrollArea, "Content", "RectTransform")
	BoxAwardScrollView.vertical = true
	BoxAwardScrollView.horizontal = false
	self.Bg.raycastTarget = false
	self.listCellReward = {}
	self.listBoxReward = {}
	self.listBoxRewardSetter = {}

	local startValue = 0

	for i = 1, #setter.list do
		if setter.list[i].from ~= protocol_pb.AF_RAID_RANDOM then
			local infoItem = SetterData.GetItemFromAsset(setter.list[i])
			local item = CellItem(self.PrefabCellItem, KillAwardScrollView.content.gameObject, self)

			item:Create()
			item:UpdateData(startValue, infoItem, true)

			startValue = startValue + 1

			table.insert(self.listCellReward, item)
		else
			table.insert(self.listBoxRewardSetter, setter.list[i])
		end
	end

	SetActiveFunc(self.BoxAward, false)

	self.Timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
		local item = CellExtraAward(self.PrefabCellExtraAward, self.Effect, self)

		item:Create()
		item:UpdateDataRaidBoss("", self.boxLevel)
		GOUtil.FindChildGameObject(item.UIRootObject, "TexBg"):SetActive(false)
	end, {})
	self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, 2, function()
		SetActiveFunc(self.BoxAward, true)
		SetActiveFunc(self.Effect, false)

		for i = 1, #self.listBoxRewardSetter do
			local infoItem = SetterData.GetItemFromAsset(self.listBoxRewardSetter[i])
			local item = CellItem(self.PrefabCellItem, BoxAwardScrollView.content.gameObject, self)

			item:Create()
			item:UpdateData(i, infoItem, true)
			table.insert(self.listBoxReward, item)
		end

		if self.stageId then
			self.DamageBtn:SetActive(true)
		end

		self.Bg.raycastTarget = true
	end, {})
end

function DlgBossRaidOver:OnClickedBtnQuit()
	self:Close()
	self:OnLeave()
	self.closecallback(data)
end

function DlgBossRaidOver:OnClickedSharedBtn()
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBossRaidShared(tonumber(ActivityBossRaidMgr.curBossRaidId), function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self.SharedBtn:SetActive(false)
			UIMgr.ShowMsg(_("Desc_Shared_Sucess"))
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end

function DlgBossRaidOver:OnClickedDamageBtn()
	self.PanelReward:SetActive(false)
	self.PanelDamage:SetActive(true)
end

function DlgBossRaidOver:OnClickedRewardBtn()
	self.PanelReward:SetActive(true)
	self.PanelDamage:SetActive(false)
end

function DlgBossRaidOver:OnBackAndroid()
	self:OnClickedBtnQuit()
end
