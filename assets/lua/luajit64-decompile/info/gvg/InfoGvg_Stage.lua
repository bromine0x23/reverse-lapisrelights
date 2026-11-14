-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/InfoGvg_Stage.lua

local MonsterData = require("luaData/Monster")

require("GameLogic/Util/AttributeUtil")

local stage = class("InfoGvg_Stage")
local item = class("InfoGvg_Stage_Item")
local monster = class("InfoGvg_Stage_Item_Monster")
local _filter = require("Util.EasyFilter")

function stage:ctor()
	self.activeId = -1
	self.stages = {}
	self.filter = _filter(self.stages)
	self.map = {}
	self.curuid = 1
	self.curStep = 1
	self.leftTimes = 0
	self.phaseTimes = 0
	self.awardStatus = {}
	self.resetTimes = {}
	self.score = 0
	self.contribution = 0
	self.skills = {}

	self:SetFilter()
end

function stage:Purge()
	if self.filter then
		self.filter:Purge()

		self.filter = nil
	end

	for i = #self.stages, 1, -1 do
		local item = table.remove(self.stages, i)

		item:Purge()
	end

	self.stages = {}
	self.map = {}
end

function stage:Refresh(activeId)
	local activeOrder = 0

	self.activeId = activeId

	local infoactive = ActiveMgr:GetActive(activeId)

	Infogvg:SetMaxStep(#infoactive.data.TypeValue)

	for stepIdx, chapterIds in ipairs(infoactive.data.TypeValue) do
		self.awardStatus[stepIdx] = 0
		self.resetTimes[stepIdx] = 0

		for chapterIdx, chapterId in ipairs(chapterIds) do
			local infochapter = ChapterMgr:GetChapter(chapterId)

			for stageIdx, stageId in ipairs(infochapter.data.StageID) do
				local s = item()

				s.activeId = infoactive.data.ID
				s.chapterId = chapterId
				s.stageId = stageId
				s.stepIdx = stepIdx
				activeOrder = activeOrder + 1
				s.activeOrder = activeOrder

				s:Init()
				table.insert(self.stages, s)

				s.uid = tostring(stageId)
				self.map[s.uid] = s

				local ooo = Infogvg.portal
				local portal = ooo:InitPortalItem(stepIdx, stageIdx)

				portal:AddStageUid(s.uid)

				s.portalIdx = portal.portalIdx
			end
		end
	end
end

function stage:SetFilter()
	function self.filter:IsStep(idx)
		return self:AddFilter(function(dest)
			return dest.stepIdx == idx
		end)
	end

	function self.filter:IsPortal(idx)
		return self:AddFilter(function(dest)
			return dest.portalIdx == idx
		end)
	end
end

function stage:SelectStage(uid)
	self.curuid = uid

	local item = self:Get()

	Infogvg:Log("選択stage：" .. item:str())
end

function stage:Get(uid)
	local item

	if not uid then
		item = self.map[self.curuid]
	else
		if type(uid) == "number" then
			uid = tostring(uid)
		end

		item = self.map[uid]
	end

	return item
end

function stage:GetByOrder(activeOrder)
	return self.stages[activeOrder]
end

function stage:Filter()
	return self.filter:Reset()
end

function stage:SetPb(pb)
	self.curStep = pb.phase
	self.leftTimes = pb.leftTimes
	self.phaseTimes = pb.phaseTimes
	self.score = pb.score
	self.contribution = pb.contribution
	self.skills = {}

	for i, PBSkillNode in ipairs(pb.skills) do
		local data = {}

		data.id = PBSkillNode.id
		data.level = PBSkillNode.level
		data.endTime = PBSkillNode.endTime

		table.insert(self.skills, data)
		Infogvg:Table(data, "skill:")
	end

	for i, spell in Infogvg.spell:Ipairs() do
		spell:SetEndTime(nil)

		for _, skill in ipairs(self.skills) do
			if spell.allSkillId == skill.id then
				spell:SetEndTime(skill.endTime)
			end
		end
	end

	local function _logFun()
		local str = "SetBP ,"

		str = str .. " curStep:" .. tostring(self.curStep)
		str = str .. " leftTimes:" .. tostring(self.leftTimes)
		str = str .. " phaseTimes:" .. tostring(self.phaseTimes)
		str = str .. " score:" .. tostring(self.score)
		str = str .. " contribution:" .. tostring(self.contribution)
		str = str .. " skills:" .. Infogvg:JsonStr(self.skills)

		Infogvg:Log(str)
	end

	_logFun()

	for i, PBClubGVGStage in ipairs(pb.clubBoss) do
		local function _logFun()
			local str = ""

			str = str .. "----> phase:" .. tostring(PBClubGVGStage.phase)
			str = str .. " awardStatus:" .. tostring(PBClubGVGStage.awardStatus)
			str = str .. " resetTimes:" .. tostring(PBClubGVGStage.resetTimes)

			Infogvg:Log(str)
		end

		_logFun()

		local stepIdx = PBClubGVGStage.phase

		self.awardStatus[stepIdx] = PBClubGVGStage.awardStatus
		self.resetTimes[stepIdx] = PBClubGVGStage.resetTimes

		for j, PBProgress in ipairs(PBClubGVGStage.bossInfo) do
			local item = self:Get(PBProgress.stageId)

			if item then
				item.progress = tonumber(PBProgress.progress)

				local bloodCost = {}

				for i, val in ipairs(PBProgress.monsterBlood) do
					table.insert(bloodCost, tonumber(val))
				end

				local maxbloodCost = {}

				for i, val in ipairs(PBProgress.monsterTotalBlood) do
					table.insert(maxbloodCost, tonumber(val))
				end

				item:SetBloodCost(bloodCost)
				item:SetMaxBloodCost(maxbloodCost)

				item.refreshTimes = PBProgress.refreshTimes
				item.leftAwardTimes = PBProgress.leftAwardTimes
				item.skills = {}

				for _, PBSkillNode in ipairs(PBProgress.deBuffSkills) do
					table.insert(item.skills, {
						id = PBSkillNode.id,
						level = PBSkillNode.level
					})
				end

				local function _logFun()
					local str = PBProgress.stageId

					str = str .. " refreshTimes:" .. PBProgress.refreshTimes
					str = str .. " leftAwardTimes:" .. PBProgress.leftAwardTimes
					str = str .. " progress:" .. PBProgress.progress
					str = str .. " bloodCost:" .. Infogvg:JsonStr(bloodCost)
					str = str .. " maxbloodCost:" .. Infogvg:JsonStr(maxbloodCost)
					str = str .. " skills:" .. Infogvg:JsonStr(item.skills)

					Infogvg:Log(str)
				end

				_logFun()
			end
		end
	end
end

function item:ctor()
	self.activeOrder = 0
	self.activeId = 0
	self.chapterId = 0
	self.stepIdx = 0
	self.uid = 0
	self.monsters = {}
	self.maxWave = 0
	self.stageId = 0
	self.progress = 0
	self.bloodCost = {}
	self.maxbloodCost = {}
	self.refreshTimes = 0
	self.leftAwardTimes = 0
	self.portalIdx = 0
	self.skills = {}
	self.previousDamage = 0
	self.previousWin = false
end

function item:str()
	local cur, max = self:GetMonsterHp()
	local hp = cur .. "/" .. max
	local str = string.format("<color=yellow>%d-%d</color> stage:%d,chapter:%d,progress:%s,hp:%s,deskills:%s", self.stepIdx, self.portalIdx, self.stageId, self.chapterId, self.progress, hp, Infogvg:JsonStr(self.skills))

	return str
end

function item:Purge()
	for i, monster in ipairs(self.monsters) do
		monster:Purge()
	end

	self.monsters = nil
end

function item:Init()
	local infoStage = InfoStage(self.stageId)
	local monsterIdx = 0

	for wave, enemys in ipairs(infoStage.BattleData.Enemy) do
		for order, monsterId in ipairs(enemys) do
			local m = monster()

			monsterIdx = monsterIdx + 1

			m:Init(monsterId, wave, order, monsterIdx)
			table.insert(self.monsters, m)

			local lv = infoStage.BattleData.MonsterLv[monsterIdx]
			local maxhp = AttributeUtil.GetMonsterAttri(monsterIdx, self.stageId).maxHp

			self.progress = self.progress + maxhp

			m:SetLevel(lv)
			m:SetMaxHp(maxhp)
			m:SetHp(self.bloodCost[monsterIdx])
		end
	end

	self.maxWave = #infoStage.BattleData.Enemy
end

function item:SetBloodCost(bloodCost)
	self.bloodCost = bloodCost

	for i, monster in ipairs(self.monsters) do
		monster:SetHp(self.bloodCost[monster.monsterIdx])
	end
end

function item:SetMaxBloodCost(bloodCost)
	self.maxbloodCost = bloodCost

	for i, monster in ipairs(self.monsters) do
		monster:SetMaxHp(self.maxbloodCost[monster.monsterIdx])
	end
end

function item:SetPreviousDamage(dmgs)
	self.previousDamage = 0

	for i, dmg in ipairs(dmgs) do
		self.previousDamage = self.previousDamage + dmg
	end

	local hp = self:GetMonsterHp()

	self.previousWin = hp <= 0
end

function item:GetMonsterHp()
	local hp, maxHp = 0, 0

	for i, monster in ipairs(self.monsters) do
		hp = hp + monster.hp
		maxHp = maxHp + monster.maxhp
	end

	return hp, maxHp
end

function item:IsLock()
	return self.stepIdx > Infogvg.stage.curStep
end

function item:IsPass()
	return Infogvg.stage.curStep > self.stepIdx
end

function item:IsComplete()
	return self.progress <= 0
end

function monster:ctor()
	return
end

function monster:Init(monsterId, wave, order, monsterIdx)
	self.monsterId = monsterId
	self.wave = wave
	self.order = order
	self.monsterIdx = monsterIdx
	self.hp = 0
	self.maxhp = 0
	self.lv = 1
end

function monster:Purge()
	return
end

function monster:GetCfg()
	return MonsterData[self.monsterId]
end

function monster:SetLevel(lv)
	self.lv = lv
end

function monster:SetMaxHp(maxhp)
	if maxhp then
		self.maxhp = maxhp
	end
end

function monster:SetHp(hp)
	if hp then
		self.hp = hp
	else
		self.hp = self.maxhp
	end
end

function monster:GetHpRate()
	if self.maxhp <= 0 or self.hp <= 0 then
		return 0
	end

	return math.min(self.hp / self.maxhp, 1)
end

return stage
