-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgOver.lua

local _TIME_FILL = 1
local _ActorData = require("luaData/ActorData")

require("UI/Page/PageActivityBossRaid/CellBossRaidRewardItem")
require("UI/Page/PageFight/Cells/CellExtraAward")

DlgGvgOver = class("DlgGvgOver", UIPanel)

function DlgGvgOver:ctor()
	self.UIPrefabPath = "UI/PageGvg/DlgGvgOver"
end

function DlgGvgOver:Purge()
	DlgGvgOver.base.Purge(self)

	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)
	end

	UITweenUtil.RemoveAllTween()
	ResourceMgr.Unload(self.PrefabCellBossRaidReward)
	ResourceMgr.Unload(self.PrefabCellExtraAward)
end

function DlgGvgOver:PreLoad()
	self:LoadResAsync("UI/PanelActivityBossRaid/CellBossRaidRewarditem", "PrefabCellBossRaidReward")
	self:LoadResAsync("UI/PageFight/Cells/CellExtraAward", "PrefabCellExtraAward")
end

function DlgGvgOver:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose)
end

function DlgGvgOver:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnClose)
end

function DlgGvgOver:OnBtnClose()
	if self.data.gvgChallengeTimes == Infogvg.stage.leftTimes then
		local function wrap_cb(...)
			self:ExitGame()
		end

		UIMgr.ShowDialog(_("Desc_GVG_releasechallengetimes"), wrap_cb)
	else
		self:ExitGame()
	end
end

function DlgGvgOver:ExitGame()
	SceneMgr.GetCurrentScene().GP:ExitGame()
	self:Close()
end

function DlgGvgOver:OnEnter(vParam)
	self.data = vParam
	self.infoStage = vParam.infoStage
	self.btn_close = self:GetChildGameObject("btn_close")
	self.HeadIcon = self:GetChildComponent("PanelDamage/HeadIcon", "Image")
	self.ImageBox = self:GetChildComponent("PanelDamage/HeadIcon/ImageBox", "Image")
	self.TotalDamage = self:GetChildComponent("PanelDamage/TotalDamage/Text", "Text")
	self.MyRank = self:GetChildComponent("PanelDamage/MyRank/Text", "Text")
	self.MyName = self:GetChildComponent("PanelDamage/NameBg/Text", "Text")
	self.HPBg = self:GetChildGameObject("PanelDamage/HPBg")
	self.HPBgWave = self:GetChildGameObject("PanelDamage/progress_step")
	self.HPImage = self:GetChildComponent("PanelDamage/HPBg/HP", "Image")

	local root = self:GetChildGameObject("PanelDamage/progress_step/wave_progress").transform

	self.imgs_fill = {}
	self.objs_fill = {}

	for i = 1, root.childCount do
		local child = root:GetChild(i - 1)
		local imgfill = GOUtil.FindChildComponent(child.gameObject, "img_fill", "Image")

		table.insert(self.imgs_fill, imgfill)
		table.insert(self.objs_fill, child.gameObject)
	end

	self.CellMonster = self:GetChildGameObject("PanelDamage/CellMonster")
	self.Icon = self:GetChildComponent("PanelDamage/CellMonster/Icon", "Image")
	self.DeadMonster = self:GetChildGameObject("PanelDamage/CellMonster/dead")
	self.CellStage = self:GetChildGameObject("PanelDamage/CellStage")
	self.IconStage = self:GetChildComponent("PanelDamage/CellStage/Icon", "Image")
	self.DeadStage = self:GetChildGameObject("PanelDamage/CellStage/dead")
	self.LevelTxt = self:GetChildComponent("PanelDamage/CellMonster/LevelTxt", "Text")
	self.BossHPTxt = self:GetChildComponent("PanelDamage/HPBg/BossHPTxt", "Text")
	self.BaseRewardCount = self:GetChildComponent("PanelReward/RewardList/BaseReward/Count", "Text")
	self.DamageRewardCount = self:GetChildComponent("PanelReward/RewardList/DamageReward/Count", "Text")
	self.FindRewardCount = self:GetChildComponent("PanelReward/RewardList/FindReward/Count", "Text")
	self.BaseRewardImage = self:GetChildComponent("PanelReward/RewardList/BaseReward/Icon", "Image")
	self.DamageRewardImage = self:GetChildComponent("PanelReward/RewardList/DamageReward/Icon", "Image")
	self.FindRewardImage = self:GetChildComponent("PanelReward/RewardList/FindReward/Icon", "Image")
	self.ImageMask = self:GetChildGameObject("ImageMask")

	local _obj = self:GetChildGameObject("PanelReward (1)")

	GOUtil.SetActive(_obj, false)

	local stage = Infogvg.stage:Get(self.infoStage.data.ID)

	if not stage then
		return
	end

	self.stage = stage
	self.stageData, self.waveCount = self:RefreshData()

	self:RefreshStageUI()
	self:RefreshStageProgress()
	self:RefreshDead()
	self:Reward()
	self:RefreshScore()
end

function DlgGvgOver:RefreshData()
	local stage = self.stage
	local temp = {}
	local waveCount = 0

	for i, monster in ipairs(stage.monsters) do
		local hprate = monster:GetHpRate()
		local wave = monster.wave

		if not temp[wave] then
			temp[wave] = {}
			temp[wave].count = 0
			temp[wave].hp = 0
			temp[wave].previousHpRate = 0
			waveCount = waveCount + 1
		end

		temp[wave].count = temp[wave].count + 1
		temp[wave].hp = temp[wave].hp + hprate

		local previousHpRate = 1
		local previousHp = stage.bloodCost[i]

		if previousHp then
			if monster.maxhp <= 0 or previousHp <= 0 then
				previousHpRate = 0
			else
				previousHpRate = math.min(previousHp / monster.maxhp, 1)
			end
		else
			previousHpRate = hprate
		end

		temp[wave].previousHpRate = temp[wave].previousHpRate + previousHpRate
	end

	return temp, waveCount
end

function DlgGvgOver:RefreshStageUI()
	local stage = self.stage
	local waveCount = self.waveCount

	GOUtil.SetActive(self.HPBgWave, waveCount > 1)
	GOUtil.SetActive(self.HPBg, waveCount == 1)

	if waveCount > 1 then
		SetImageSprite(self.IconStage, Infogvg.cfg:StageImage(stage.portalIdx), self)

		self.IconStage.enabled = true
	else
		local monster = stage.monsters[1]

		if monster then
			local actorcfg = _ActorData[monster:GetCfg().ActorID]

			if actorcfg then
				if actorcfg.UiShowIcon ~= "" then
					SetImageSprite(self.Icon, actorcfg.UiShowIcon, self)

					self.Icon.enabled = true
				else
					self.Icon.enabled = false
				end
			end
		end
	end

	GOUtil.SetActive(self.CellStage, waveCount > 1)
	GOUtil.SetActive(self.CellMonster, waveCount == 1)
end

function DlgGvgOver:RefreshStageProgress()
	local stage = self.stage
	local waveCount = self.waveCount

	for wave, data in pairs(self.stageData) do
		waveCount = waveCount + 1

		local average = data.hp / data.count
		local previous = data.previousHpRate / data.count

		if self.imgs_fill[wave] then
			UITweenUtil.FillAmountAnim(self.imgs_fill[wave], previous, average, _TIME_FILL)
		end

		if wave == 1 then
			UITweenUtil.FillAmountAnim(self.HPImage, 1, average, _TIME_FILL)
			UIUtil.SetTextString(self.BossHPTxt, math.ceil(average * 100) .. "%")
		end
	end
end

function DlgGvgOver:RefreshScore()
	local stage = self.stage

	self.TotalDamage.text = stage.previousDamage
	self.MyRank.text = math.ceil(GetConfigArgFloat("GVGContributeRatioPer") * stage.previousDamage)

	UIUtil.SetTextString(self.MyName, PlayerInst:GetNickName())
end

function DlgGvgOver:RefreshDead()
	local stage = self.stage
	local curHp, maxHp = stage:GetMonsterHp()

	GOUtil.SetActive(self.DeadStage, curHp == 0)
	GOUtil.SetActive(self.DeadMonster, curHp == 0)
end

function DlgGvgOver:Reward()
	local setter = SetterData.GetSetterData(self.data.setter)

	setter:Parse()

	local scrollArea = self:GetChildGameObject("PanelReward/ScrollArea")
	local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	scrollView.vertical = true
	scrollView.horizontal = false

	if self.listCellReward then
		for i = 1, #self.listCellReward do
			self.listCellReward[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(scrollView.content.gameObject)

	self.listCellReward = {}
	self.listBoxReward = {}
	self.listBoxRewardSetter = {}

	for i = 1, #setter.list do
		local cell = CellBossRaidRewardItem(self.PrefabCellBossRaidReward, scrollView.content.gameObject, self)
		local data = {}

		data.setter = setter.list[i]

		Infogvg:Log("setter.from:" .. data.setter.from)
		cell:Create(data)

		if data.setter.from == protocol_pb.AF_GVG_STAGE_PASS then
			local imgpath = ""

			if self.stage.stepIdx == 1 then
				imgpath = Infogvg.cfg:GetCellItemIcon("complete_stage_1")
			else
				imgpath = Infogvg.cfg:GetCellItemIcon("complete_stage_23")
			end

			if imgpath then
				cell:SetImgDynamic(imgpath)
			end
		end

		table.insert(self.listCellReward, cell)

		if data.setter.from == protocol_pb.AF_RAID_HARM_DROP then
			cell.UIRootObject:SetActive(false)
			table.insert(self.listBoxReward, cell)
			table.insert(self.listBoxRewardSetter, data.setter)
		end
	end

	if #self.listBoxReward > 0 then
		self.Timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
			self.ImageMask:SetActive(true)

			local item = CellExtraAward(self.PrefabCellExtraAward, self.ImageMask, self)

			item:Create()
			item:UpdateData("", 3)
			GOUtil.FindChildGameObject(item.UIRootObject, "TexBg"):SetActive(false)
		end, {})
		self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, 1.8, function()
			local data = {}

			data.list = self.listBoxRewardSetter
			data.listValue = #self.listBoxRewardSetter

			local function wrap_cb()
				for i = 1, #self.listBoxReward do
					self.listBoxReward[i].UIRootObject:SetActive(true)
				end
			end

			data.callback = wrap_cb

			UIMgr.AddPanel(DlgGetAward(), data)
			self.ImageMask:SetActive(false)
		end, {})
	end
end
