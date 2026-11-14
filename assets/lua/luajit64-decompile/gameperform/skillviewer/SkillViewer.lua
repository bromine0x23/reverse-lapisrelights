-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/SkillViewer/SkillViewer.lua

SkillViewer = class("SkillViewer", nil, true)

require("GamePerform.Requires")
require("GamePerform/SkillViewer/Npc")
require("GamePerform/SkillViewer/NpcSkill")

function SkillViewer.TimeScale(scale)
	return
end

function SkillViewer.TimeScaleActive(val)
	return
end

function SkillViewer.FxAlloc(fxId, unitBase)
	if not fxId then
		return
	end

	local _effectCfg = require("luaData/EffectData")

	if fxId == 0 then
		return
	end

	if not _effectCfg[fxId] then
		return EffectMgr:AllocById(fxId)
	end

	local soundBank = _effectCfg[fxId].SoundBank

	if soundBank and soundBank ~= "" then
		SoundMgr.LoadBank(soundBank, false, false)
	end

	local bindSlot = _effectCfg[fxId].BindSlot
	local parent

	if bindSlot and bindSlot ~= "" then
		parent = unitBase:GetBone(bindSlot)
	end

	local isChild = _effectCfg[fxId].IsChild

	if not isChild or isChild == 0 then
		local position, rotation, scale

		if parent then
			position = parent.position
		else
			position = unitBase.ActorRoot.transform.position
		end

		rotation = unitBase.ActorRoot.transform.rotation
		scale = unitBase.ActorSkeletonRoot.transform.localScale.x

		return BattleConfig:AllocAtById(fxId, position, rotation, scale)
	else
		if not parent then
			return EffectMgr:AllocById(fxId, unitBase.ActorSkeletonRoot)
		end

		return EffectMgr:AllocById(fxId, parent)
	end
end

function SkillViewer:ctor()
	self:Reset()

	self.TimeLine = TimeLineUtility(self)
	self.UnitVocal = UnitVocal(self)
	SkillViewer.FxAlloc_temp = BattleConfig.FxAlloc
	SkillViewer.TimeScale_temp = BattleConfig.TimeScale
	SkillViewer.TimeScaleActive_temp = BattleConfig.TimeScaleActive
	BattleConfig.FxAlloc = SkillViewer.FxAlloc
	BattleConfig.TimeScale = SkillViewer.TimeScale
	BattleConfig.TimeScaleActive = SkillViewer.TimeScaleActive
end

function SkillViewer:Reset()
	self.Scene = nil
	self.UI = nil
	self.Npc = nil
	self.TimeLine = nil
	self.UnitVocal = nil
end

function SkillViewer:Purge()
	if self.UnitVocal then
		self.UnitVocal:Purge()
	end

	self:Reset()

	BattleConfig.FxAlloc = SkillViewer.FxAlloc_temp
	BattleConfig.TimeScale = SkillViewer.TimeScale_temp
	BattleConfig.TimeScaleActive = SkillViewer.TimeScaleActive_temp
end

function SkillViewer:ReadyMonster(unitId)
	local npc = Npc()

	npc:CreateModel(unitId, EnumFight.UnitClass.ENEMY)

	if self.Npc then
		self.Npc:Purge()

		self.Npc = nil
	end

	self.Npc = npc

	Event.Instance:Fire("单位-创建", self.Npc)
end

local CharacterCardData = require("luaData/CharacterCard")

function SkillViewer:ReadyModel(cardId)
	local npc = Npc()

	npc:CreateModel(CharacterCardData[cardId].CharacterID, EnumFight.UnitClass.PLAYER, cardId)

	if self.Npc then
		self.Npc:Purge()

		self.Npc = nil
	end

	self.Npc = npc

	Event.Instance:Fire("单位-创建", self.Npc)
end
