-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/InfoGvg.lua

local _stage = require("info.gvg.InfoGvg_Stage")
local _portal = require("info.gvg.InfoGvg_Portal")
local _spell = require("info.gvg.InfoGvg_Spell")
local _net = require("info.gvg.infoGvg_Net")
local _rank = require("info.gvg.InfoGvg_Rank")
local _cfg = require("Info.gvg.InfoGvg_Cfg")
local _union = require("Info.gvg.InfoGvg_Union")
local _persistent = require("Info.gvg.InfoGvg_PersistentData")

require("UI/Page/PageGvg/DlgGvg")

local ACTIVE_TYPE = 5
local mt = {}

Infogvg = mt
Infogvg.cmd = require("Info.gvg.cmd")
Infogvg.cfg = _cfg
Infogvg.net = _net
Infogvg.portal = _portal()
Infogvg.stage = _stage()
Infogvg.spell = _spell()
Infogvg.rank = _rank()
Infogvg.union = _union()
Infogvg.persistent = _persistent()

function mt:Purge()
	if self.stage then
		self.stage:Purge()
	end

	if self.portal then
		self.portal:Purge()
	end

	if self.spell then
		self.spell:Purge()
	end

	if self.rank then
		self.rank:Purge()
	end

	self.net = nil
end

function mt:Refresh(isOpenUI, isSyncLoad)
	local success = self:Init()

	if success == true then
		self.net:RequestGvg(isOpenUI, isSyncLoad)
	else
		self:Error("Infogvg Init Failed !")

		if Infogvg.offline then
			self:Purge()

			self.cfg = _cfg

			self.cfg:Init(207)

			self.net = _net

			self.net:Init()

			self.portal = _portal()
			self.stage = _stage()

			self.stage:Refresh(207)

			self.spell = _spell()

			self.spell:Refresh(207)

			self.rank = _rank()
			self.union = _union()
			self.persistent = _persistent()

			UIMgr.SwitchPanel(DlgGvg())
		end
	end
end

function mt:IsPlayOpen()
	if Infogvg.offline then
		return true
	end

	local infoActives = ActiveMgr:GetActiveByType(ACTIVE_TYPE)

	for i, info in ipairs(infoActives) do
		if info:IsPlayOpen() == true then
			return true
		end
	end

	return false
end

function mt:ClosingActive()
	local infoActives = ActiveMgr:GetActiveByType(ACTIVE_TYPE)

	for i, info in ipairs(infoActives) do
		if info:IsPlayOpen() == false and info:IsShowOpen() == true then
			return info
		end
	end

	return nil
end

function mt:Init()
	local infoActives = ActiveMgr:GetActiveByType(ACTIVE_TYPE)

	for i, info in ipairs(infoActives) do
		local playing = info:IsPlayOpen() == true
		local closing = info:IsPlayOpen() == false and info:IsShowOpen() == true

		if playing or closing then
			if self.stage and self.stage.activeId == info.data.ID then
				return true
			end

			self:Purge()
			self:Log("init gvg , activeId: " .. info.data.ID)

			self.cfg = _cfg

			self.cfg:Init(info.data.ID)

			self.net = _net

			self.net:Init()

			self.portal = _portal()
			self.stage = _stage()

			self.stage:Refresh(info.data.ID)

			self.spell = _spell()

			self.spell:Refresh(info.data.ID)

			self.rank = _rank()
			self.union = _union()
			self.persistent = _persistent()

			return true
		end
	end

	return false
end

function mt:Error(...)
	print("<color=red>ERROR " .. ... .. "</color>")
end

function mt:Log(...)
	print("<color=white>LOG " .. ... .. "</color>")
end

function mt:Text(...)
	print("<color=yellow>Text " .. ... .. "</color>")
end

function mt:JsonStr(t)
	local json = require("GameLogic.Util.json4lua")
	local str = json.encode(t)

	return str
end

function mt:Table(t, label)
	local json = require("GameLogic.Util.json4lua")
	local str = json.encode(t)

	if label then
		self:Log(label .. str)
	else
		self:Log(str)
	end
end

function mt:EnterTeamAgent(stageId)
	local infoStage = InfoStage(stageId)
	local infoTeam = require("Info/InfoTeamGvg")

	infoTeam:EnterStage(infoStage)

	infoTeam.teamSystemAgent.isGvg = true

	UIMgr.SwitchPanel(PageTeam, infoTeam.teamSystemAgent)
end

function mt:SetCardTimes(cardId, val)
	local card = RoleCardMgr:GetRoleCard(cardId)

	if card then
		card:SetGvgTimes(val)
	else
		Infogvg:Error("gvg card times , not found cardid:" .. cardId)
	end
end

function mt:CardVaild(cardId)
	local card = RoleCardMgr:GetRoleCard(cardId)

	if card then
		return card:GvgTimesVaild()
	end

	return false
end

function mt:BattleResult(stageId, blood, cardIds, tab, bloodCost)
	local log = ""

	for i = 1, #cardIds do
		local infoCard = RoleCardMgr:GetRoleCard(cardIds[i])
		local curCardHpPer = 0

		curCardHpPer = math.ceil((tab[i] or infoCard.curGvgHpPer) * 100)

		if curCardHpPer > 0 then
			curCardHpPer = 100
		end

		infoCard:SetGvgHpPer(curCardHpPer / 100, true)

		local str = infoCard:GetName() .. " setHpRate:" .. curCardHpPer / 100 .. "|"

		log = log .. str
	end

	local stage = self.stage:Get(stageId)

	for i, hp in ipairs(blood) do
		local monster = stage.monsters[i]

		if monster then
			monster:SetHp(hp)

			local str = "monster:" .. monster.monsterIdx .. " setHp:" .. hp .. "|"

			log = log .. str
		end
	end

	stage:SetPreviousDamage(bloodCost)
	Infogvg:Log(log)
end

function mt:GetAllReward()
	local steps = {}

	for i, val in ipairs(self.stage.awardStatus) do
		if val ~= 0 then
			table.insert(steps, i)
		end
	end

	local stageIds = {}

	for i, stage in ipairs(self.stage.stages) do
		for j = 1, stage.leftAwardTimes do
			table.insert(stageIds, stage.stageId)
		end
	end

	if #steps > 0 or #stageIds > 0 then
		self:Table(steps, "報酬受け取りsteps:")
		self:Table(stageIds, "報酬受け取りstageIds:")
		self.net:RequestReward(steps, stageIds)
	end
end

function mt:Vaild(stageId)
	if self.stage then
		return self.stage:Get(stageId)
	end

	return nil
end

function mt:SetMaxStep(maxstep)
	self.maxstep = maxstep
end

function mt:CheckStep(stepIdx)
	if stepIdx <= self.maxstep then
		return true
	end

	return nil
end

function mt:CheckPortal(stepIdx, portalIdx)
	if not self:CheckStep(stepIdx) then
		return nil
	end

	local cfg = self.cfg:MaxPortal()

	if cfg[stepIdx] and portalIdx <= cfg[stepIdx] then
		return true
	end

	return nil
end
