-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellResultAddUp_detail.lua

CellResultAddUp_detail = class("CellResultAddUp_detail", UIPanel_sync)

function CellResultAddUp_detail:ctor(camp)
	CellResultAddUp_detail.base.ctor(self, "UI/PageFight/Cells/CellResultAddUp_detail")
end

function CellResultAddUp_detail:Cache()
	CellResultAddUp_detail.base.Cache(self)
end

function CellResultAddUp_detail:Close()
	CellResultAddUp_detail.base.Close(self)
end

function CellResultAddUp_detail:Purge()
	CellResultAddUp_detail.base.Purge(self)
end

function CellResultAddUp_detail:OnRegisterEvent()
	return
end

function CellResultAddUp_detail:OnUnRegisterEvent()
	return
end

function CellResultAddUp_detail:SetParent(root)
	GOUtil.AttachGameObject(self.UIRootObject, root, true)
end

local allCfg = require("luaData/AllSkills")
local battleSkillData = require("luaData/BattleSkillData")
local buffCfg = require("luaData/BattleBuffData")

function CellResultAddUp_detail:OnEnter()
	self.txt_skill = self:GetChildComponent("txt_skill", "Text")
	self.txt_count = self:GetChildComponent("txt_count", "Text")
	self.txt_count = self:GetChildComponent("txt_count", "Text")
	self.txt_dmg = self:GetChildComponent("txt_dmg", "Text")
	self.txt_percent = self:GetChildComponent("txt_percent", "Text")
end

function CellResultAddUp_detail:RefreshSkill(info)
	self:Show(true)

	local allSkillId = battleSkillData[info.skillId].AllSkillID

	self.txt_skill.text = Lang(allCfg[allSkillId].Name)
	self.txt_count.text = info.count
	self.txt_dmg.text = ""
	self.txt_percent.text = ""
end

function CellResultAddUp_detail:RefreshDamage(info, sunDamage)
	self:Show(true)

	if info.skillId then
		local allSkillId = battleSkillData[info.skillId].AllSkillID

		self.txt_skill.text = Lang(allCfg[allSkillId].Name)
	elseif info.buffId then
		self.txt_skill.text = Lang(buffCfg[info.buffId].Description)
	end

	self.txt_count.text = tostring(info.count)
	self.txt_dmg.text = tostring(math.ceil(info.sum))

	local r = info.sum / sunDamage

	if tostring(r) == "nan" then
		r = 0
	end

	self.txt_percent.text = string.format("%.1f%%", r * 100)
end
