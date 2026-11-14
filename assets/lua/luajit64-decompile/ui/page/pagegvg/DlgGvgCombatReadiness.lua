-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgCombatReadiness.lua

local _ActorData = require("luaData/ActorData")

DlgGvgCombatReadiness = class("DlgGvgCombatReadiness", UIPanel)

local cellskill = class("DlgGvgCombatReadiness_skill", UIItemBase)

function DlgGvgCombatReadiness:ctor()
	self.UIPrefabPath = "UI/PageGvg/DlgGvgCombatReadiness"
end

function DlgGvgCombatReadiness:Purge()
	self.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	self.skills:Purge()

	for i = #self.monsterSkills, 1, -1 do
		local cell = table.remove(self.monsterSkills, i)

		cell:Purge()
	end

	ResourceMgr.Unload(self.PrefabCellItem)
	UnloadAllImageSprite(self)
	Event.Instance:Fire("UI_DlgGvgCombatReadiness", false)
end

function DlgGvgCombatReadiness:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose)
	self:AddClick(self.btn_challenge, self.OnBtnChallenge)
	self:AddClick(self.btn_detail, self.OnBtnDetail)
end

function DlgGvgCombatReadiness:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnClose)
	self:RemoveClick(self.btn_challenge, self.OnBtnChallenge)
	self:RemoveClick(self.btn_detail, self.OnBtnDetail)
end

function DlgGvgCombatReadiness:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")

	self.PrefabCell = ResourceMgr.LoadSync("UI/PageGvg/CellGvgSkill")
end

function DlgGvgCombatReadiness:OnEnter(vParam)
	self.monsterSkills = {}
	self.txt_title = self:GetChildComponent("panel/main/title/txt_title", "Text")
	self.buffitemT = self:GetChildGameObject("panel/main/buffs/grid/itemT")

	GOUtil.SetActive(self.buffitemT, false)

	self.obj_bufftip = self:GetChildGameObject("panel/main/buffs/obj_bufftip")
	self.txt_bufftip = self:GetChildComponent("panel/main/buffs/obj_bufftip/txt", "Text")
	self.btn_close = self:GetChildGameObject("panel/main/btn_close/obj_click")
	self.img_close = self:GetChildGameObject("panel/main/btn_close")
	self.btn_challenge = self:GetChildGameObject("panel/main/btn_challenge/obj_click")
	self.img_challenge = self:GetChildComponent("panel/main/btn_challenge", "Image")
	self.btn_detail = self:GetChildGameObject("panel/main/btn_detail/obj_click")
	self.obj_progress_step = self:GetChildGameObject("panel/main/progress_step")
	self.obj_progress_single = self:GetChildGameObject("panel/main/progress_single")

	local root = self:GetChildGameObject("panel/main/progress_step/wave_progress").transform

	self.imgs_fill = {}
	self.objs_fill = {}

	for i = 1, root.childCount do
		local child = root:GetChild(i - 1)
		local imgfill = GOUtil.FindChildComponent(child.gameObject, "img_fill", "Image")

		table.insert(self.imgs_fill, imgfill)
		table.insert(self.objs_fill, child.gameObject)
	end

	self.img_fill_single = self:GetChildComponent("panel/main/progress_single/img_progress/img_fill", "Image")
	self.txt_hp_single = self:GetChildComponent("panel/main/progress_single/img_progress/txt_hp", "Text")
	self.obj_tagIconT = self:GetChildGameObject("panel/main/progress_single/tags/iconT")
	self.obj_tagIconT_root = self:GetChildGameObject("panel/main/progress_single/tags/")

	GOUtil.SetActive(self.obj_tagIconT, false)

	self.img_icon_monster = self:GetChildComponent("panel/main/monser/img_icon", "Image")
	self.img_icon_stage = self:GetChildComponent("panel/main/stage/img_icon", "Image")
	self.obj_stage = self:GetChildGameObject("panel/main/stage")
	self.obj_monster = self:GetChildGameObject("panel/main/monser")
	self.txt_challengeTimes = self:GetChildComponent("panel/main/rewards/challengeTimes/txt_challengeTimes", "Text")

	self:Refresh()

	local component = require("UI/Page/PageGvg/Skills")

	self.skills = component()

	self.skills:Init(self:GetChildGameObject("panel/main/skills"), self.PrefabCell)
	Event.Instance:Fire("UI_DlgGvgCombatReadiness", true)
end

function DlgGvgCombatReadiness:Refresh()
	local stage = Infogvg.stage:Get()

	if not stage then
		Infogvg:Error("Cur Stage Error")
		self:Close()

		return
	end

	self:RefreshProgress()
	self:RefreshReward()
	self:RefreshMonsterSkills()
	self:RefreshCardTag()
end

function DlgGvgCombatReadiness:RefreshProgress()
	local stage = Infogvg.stage:Get()
	local temp = {}

	for i, monster in ipairs(stage.monsters) do
		local hp = monster:GetHpRate()
		local wave = monster.wave

		if not temp[wave] then
			temp[wave] = {}
			temp[wave].count = 0
			temp[wave].hp = 0
		end

		temp[wave].count = temp[wave].count + 1
		temp[wave].hp = temp[wave].hp + hp
	end

	local waveCount = 0

	for wave, data in pairs(temp) do
		waveCount = waveCount + 1

		local average = data.hp / data.count

		if self.imgs_fill[wave] then
			self.imgs_fill[wave].fillAmount = average
		end

		if wave == 1 then
			self.img_fill_single.fillAmount = average

			UIUtil.SetTextString(self.txt_hp_single, math.ceil(average * 100) .. "%")
		end
	end

	GOUtil.SetActive(self.obj_progress_step, waveCount > 1)
	GOUtil.SetActive(self.obj_progress_single, waveCount == 1)
	GOUtil.SetActive(self.obj_stage, waveCount > 1)
	GOUtil.SetActive(self.obj_monster, waveCount == 1)

	local infoStage = InfoStage(stage.stageId)
	local max = GetConfigArgInt("GVGDailyTimes")

	UIUtil.SetTextString(self.txt_challengeTimes, _("Desc_GVG_challengetimes") .. tostring(Infogvg.stage.leftTimes) .. "/" .. max)

	if Infogvg.stage.leftTimes > 0 then
		UIUtil.SetImageGray(self.img_challenge, 0)
	else
		UIUtil.SetImageGray(self.img_challenge, 1)

		self.txt_challengeTimes.color = Color.red
	end

	local monster = stage.monsters[1]

	if monster then
		local titleStr = string.format(_("Desc_GVG_Step"), stage.stepIdx)

		if waveCount > 1 then
			UIUtil.SetTextString(self.txt_title, titleStr .. Lang(infoStage.data.Name))
			SetImageSprite(self.img_icon_stage, Infogvg.cfg:StageImage(stage.portalIdx), self)
		else
			UIUtil.SetTextString(self.txt_title, titleStr .. Lang(monster:GetCfg().Name))

			local actorcfg = _ActorData[monster:GetCfg().ActorID]

			if actorcfg then
				if actorcfg.UiShowIcon ~= "" then
					SetImageSprite(self.img_icon_monster, actorcfg.UiShowIcon, self, true)

					self.img_icon_monster.enabled = true
				else
					self.img_icon_monster.enabled = false
				end
			end
		end
	end
end

function DlgGvgCombatReadiness:RefreshReward()
	local stage = Infogvg.stage:Get()
	local infoStage = InfoStage(stage.stageId)
	local listAward = {}

	for _, v in pairs(infoStage.data.ItemList) do
		if v[1] and v[2] then
			local infoItem = ItemManager:GetValueItem(v[1], v[2])

			if v[3] then
				infoItem = ItemManager:GetValueItem(v[1], v[2], v[3])
			end

			table.insert(listAward, {
				isFirst = false,
				info = infoItem
			})
		end
	end

	local scrollArea = self:GetChildGameObject("panel/main/rewards/reward")
	local content = self:GetChildComponent("panel/main/rewards/reward/content", "RectTransform")
	local count = #listAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local killReward = {}

	for i, data in ipairs(infoStage.data.GroupStagePassReward) do
		killReward[data[1]] = true
	end

	local function updateCallback(item, index)
		local infoItem = listAward[index].info
		local isFirst = listAward[index].isFirst

		if isFirst then
			item:UpdateNoNumType(infoItem)
		elseif infoItem.randomNum then
			item:UpdateWithNumType(infoItem, nil, infoItem.randomNum)
		else
			item:UpdateNoNumType(infoItem)
		end

		if killReward[infoItem.id] then
			local imgpath = ""

			if stage.stepIdx == 1 then
				imgpath = Infogvg.cfg:GetCellItemIcon("complete_stage_1")
			else
				imgpath = Infogvg.cfg:GetCellItemIcon("complete_stage_23")
			end

			if imgpath then
				item:SetImgDynamic(imgpath)
			end
		end
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellItem, CellItem, self, false, addCallback, updateCallback)
end

function DlgGvgCombatReadiness:RefreshMonsterSkills()
	for i = #self.monsterSkills, 1, -1 do
		local cell = table.remove(self.monsterSkills, i)

		cell:Purge()
	end

	local stage = Infogvg.stage:Get()

	if stage then
		local count = #stage.skills

		GOUtil.SetActive(self.obj_bufftip, count == 0)

		for i, skill in ipairs(stage.skills) do
			local cell = cellskill()

			cell:Init(self.buffitemT, skill)
			table.insert(self.monsterSkills, cell)
		end
	end

	if stage.stepIdx == 1 then
		UIUtil.SetTextString(self.txt_bufftip, _("Desc_GVG_tips_empty_skill_step1"))
	else
		local cfg = Infogvg.cfg:MaxPortal()
		local maxPortal = cfg[stage.stepIdx]

		if maxPortal > stage.portalIdx then
			UIUtil.SetTextString(self.txt_bufftip, _("Desc_GVG_tips_empty_skill_2"))
		else
			UIUtil.SetTextString(self.txt_bufftip, _("Desc_GVG_tips_empty_skill"))
		end
	end
end

function DlgGvgCombatReadiness:RefreshCardTag()
	local itemT = self.obj_tagIconT
	local root = self.obj_tagIconT_root
	local stage = Infogvg.stage:Get()

	if not stage then
		return
	end

	local ids = Infogvg.cfg:PortalCardTags(stage.stepIdx, stage.portalIdx)
	local cfg_CardTag = require("luaData/CardTag")

	for i, id in ipairs(ids) do
		local data = cfg_CardTag[id]

		if data then
			local go = GOUtil.Instantiate(itemT, root)
			local img = GOUtil.GetComponent(go, "Image")

			UIUtil.SetImageSprite(img, data.Icon, self)
			GOUtil.SetActive(go, true)
		end
	end
end

function DlgGvgCombatReadiness:OnBtnClose()
	self:Close()
end

function DlgGvgCombatReadiness:OnBtnDetail()
	local stage = Infogvg.stage:Get()
	local info = InfoStage(stage.stageId)

	UIMgr.AddPanel(DlgMonsterDes(), {
		index = 1,
		listMonster = info.listMonster
	}, UIMgr.UIOverLayObject)
end

function DlgGvgCombatReadiness:OnBtnChallenge()
	local stage = Infogvg.stage:Get()
	local info = InfoStage(stage.stageId)

	if Infogvg.offline then
		Infogvg:EnterTeamAgent(stage.stageId)
		self:Close()

		return
	end

	if PlayerInst:GetCurLv() < info.data.LevelUnlock then
		UIMgr.ShowMsg(string.format(_("Msg_UnlockTeamPosition"), info.data.LevelUnlock))

		return
	end

	local infoActive = ActiveMgr:GetActive(stage.activeId)
	local isCanPlay, msg = infoActive:IsPlayOpen()

	if not isCanPlay then
		UIMgr.ShowMsg(msg)

		return
	end

	if Infogvg.stage.leftTimes <= 0 then
		UIMgr.ShowMsg(_("Desc_GVG_LeftTimes"))

		return
	end

	if Infogvg.god then
		Infogvg.cmd:Fight(stage.stageId)
	else
		Infogvg:EnterTeamAgent(stage.stageId)
	end

	self:Close()
end

function cellskill:Init(obj, skill)
	local root = obj.transform.parent.gameObject
	local go = GOUtil.Instantiate(obj, root)

	self.UIRootObject = go

	local icon = self:GetChildComponent("img_icon", "Image")

	self.obj_click = self:GetChildGameObject("obj_click")
	self.id = skill.id

	local talent = TalentManager:Get(skill.id)

	if talent then
		UIUtil.SetImageSprite(icon, talent:GetIconPath(), self)
		GOUtil.SetActive(self.UIRootObject, true)
	end

	self:OnRegisterEvent()
end

function cellskill:OnRegisterEvent()
	self:AddListener(self.obj_click, self.OnPointerDown, EventTriggerType.PointerClick)
end

function cellskill:OnUnRegisterEvent()
	self:RemoveListener(self.obj_click, self.OnPointerDown, EventTriggerType.PointerClick)
end

function cellskill:Purge()
	UnloadAllImageSprite(self)
	self:OnUnRegisterEvent()
	Object.Destroy(self.UIRootObject)
end

function cellskill:OnPointerDown(data)
	if data.clickCount == 1 then
		local tipData = SkillTip.GetMonsterData(data.position, self.id)

		UIMgr.ShowSkillTip(tipData)
	else
		UIMgr.HideSkillTip()
	end
end
