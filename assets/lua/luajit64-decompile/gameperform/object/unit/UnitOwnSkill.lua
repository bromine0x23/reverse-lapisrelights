-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/Object/Unit/UnitOwnSkill.lua

require("UI/Dlg/Common/SkillTip")

local _BattleSkillData = require("GamePerform.Object.InfoBattleSkillData")

UnitOwnSkill = class("UnitOwnSkill", GameHelper)
UnitOwnSkill.Map = {}

function UnitOwnSkill.Get(battleSkillId)
	return UnitOwnSkill.Map[battleSkillId]
end

function UnitOwnSkill.GetName(battleSkillId)
	return UnitOwnSkill.Map[battleSkillId].Name
end

function UnitOwnSkill.Clear()
	UnitOwnSkill.Map = {}
end

UnitOwnSkill.enSkillType = {
	CENTER = 3,
	PASSIVE = 2,
	ACTIVE = 1
}
UnitOwnSkill.enPassiveSkillType = {
	UNDEFINE = 0,
	JOB = 1
}

function UnitOwnSkill:ctor(unit, skillId, level)
	self.GP = unit.GP
	self.Owner = unit
	self.Level = 1
	self.AllSkillLv = level

	local allSkillId = skillId
	local infoSkill = _BattleSkillData:GetAllSkillData(allSkillId)

	if not infoSkill then
		print("AllSkill 没有配置！skillId = " .. tostring(allSkillId))

		return
	end

	local battleSkillId = infoSkill.BattleSkillID[self.AllSkillLv]
	local infoBattleSkill = _BattleSkillData:GetData(battleSkillId)

	if not infoBattleSkill then
		print("BattleSkillData 没有配置！skillId = " .. tostring(battleSkillId))

		return
	end

	self.infoBattleSkill = infoBattleSkill
	self.infoSkill = infoSkill
	self.Name = Lang(infoSkill.Name)
	self.Description = Lang(infoSkill.Description[self.Level])

	if infoSkill.Icon ~= "" then
		self.IconPath = BattleConfig.SkillPath .. infoSkill.Icon
	else
		self.IconPath = ""
	end

	self.Type = infoSkill.Type
	self.BattleSkillType = infoSkill.BattleSkillType
	self.PassiveType = infoSkill.PassiveType
	self.BattleSkillId = battleSkillId
	self.Id = self.BattleSkillId
	self.AllSkillId = infoSkill.ID
	UnitOwnSkill.Map[self.BattleSkillId] = self
	self.YellowBallStack = 0
	self.Cost = infoBattleSkill.Cost

	self.GP.PrewarmUtil:AddSkill(self)
	self:InitTimeLine()
end

function UnitOwnSkill:Create()
	if self.BattleSkillType == EnumFight.SkillType.Active then
		local lipPath = self.infoBattleSkill.SkillLips

		if self.Owner.ActorLipSync and lipPath ~= "" then
			self.Owner.ActorLipSync:AddByPath(lipPath)
		end
	end
end

function UnitOwnSkill:Cache()
	return
end

function UnitOwnSkill:CreateImmediately()
	local infoSkill = _BattleSkillData:GetData(self.BattleSkillId)
	local timeLineId = infoSkill.TimeLineID

	if timeLineId and timeLineId ~= 0 then
		self.GP.TimeLine:CreateImmediately(timeLineId)
	end
end

function UnitOwnSkill:Purge()
	local infoSkill = _BattleSkillData:GetData(self.BattleSkillId)
	local timeLineId = infoSkill.TimeLineID

	if timeLineId and timeLineId ~= 0 then
		self.GP.TimeLine:DeleteTimeLine(timeLineId)
	end

	self.Owner = nil
	self.Level = 1
end

function UnitOwnSkill:_SetImage(img, path)
	GP.SpriteUtil:SetSprite(img, path)
end

function UnitOwnSkill:SetIcon(img)
	local path = self.IconPath

	self:_SetImage(img, path)
end

function UnitOwnSkill:SetDescIcon(img)
	local vaild, path = false, ""
	local idx = self.infoBattleSkill.DescIconIdx

	if idx and idx ~= 0 then
		path = BattleConfig.CardSkillDescIconPaths[idx]

		if path then
			vaild = true
		end
	end

	if vaild == true then
		self:_SetImage(img, path)

		img.enabled = true
	else
		img.enabled = false
	end
end

function UnitOwnSkill:SetName(txt)
	UIUtil.SetTextString(txt, self.Name)
end

function UnitOwnSkill:SetDesc(txt)
	local desc = SkillTip.GetDesc(self.AllSkillId, self.AllSkillLv, self.YellowBallStack)

	UIUtil.SetTextString(txt, desc)
end

function UnitOwnSkill:InitTimeLine()
	local infoSkill = _BattleSkillData:GetData(self.BattleSkillId)
	local timeLineId = infoSkill.TimeLineID

	if timeLineId and timeLineId ~= 0 then
		self.GP.TimeLine:Register(timeLineId)
	end

	if self.GP.FightMode == EnumFight.BattleType.NORMAL then
		timeLineId = infoSkill.TimeLine_BOSS_Cam

		if timeLineId and timeLineId ~= 0 then
			self.GP.TimeLine:Register(timeLineId)
		end
	end
end

function UnitOwnSkill:StackPower(stack)
	self.YellowBallStack = stack
end
