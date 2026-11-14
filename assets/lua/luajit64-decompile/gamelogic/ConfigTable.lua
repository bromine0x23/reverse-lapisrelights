-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/ConfigTable.lua

ConfigTable = ConfigTable or {}

function ConfigTable:load()
	self.Config = self:load_data("Config")
	self.LevelConfig = self:load_data("LevelConfig")
	self.FavorLevel = self:load_data("FavorLevel")
	self.Character = self:load_data("CharacterRole")
	self.CharacterCard = self:load_data("CharacterCard")
	self.Equipment = self:load_data("Equipment")
	self.EquipmentUpgradeProperty = self:load_data("EquipmentUpgradeProperty")
	self.EquipmentQualityPromote = self:load_data("EquipmentQualityPromote")
	self.AllSkills = self:load_data("AllSkills")
	self.AvatarData = self:load_data("AvatarData")
	self.SkillNode = self:load_data("SkillNode")
	self.SkillTree = self:load_data("SkillTree")
	self.CharacterTeam = self:load_data("CharacterTeam")
	self.ClubSkillLevel = self:load_data("ClubSkillLevel")
	self.ItemData = self:load_data("ItemData")
	self.ScrollSetData = self:load_data("ScrollSetData")
	self.StageData = self:load_data("StageData")
	self.BattleStage = self:load_data("BattleStage")
	self.Monster = self:load_data("Monster")
	self.ClubMirror = self:load_data("ClubMirror")
	self.BattleSkillData = self:load_data("BattleSkillData")
	self.BattleBuffData = self:load_data("BattleBuffData")
	self.JobCheckingData = self:load_data("JobCheckingData")
	self.Language = self:load_data("Language")
	self.Localization = self:load_data("Localization")
end

if _G_LAPIS_SERVER then
	local skynet = require("skynet")
	local sharetable = require("skynet/sharetable")

	function ConfigTable:load_data(table_name)
		table_name = "./client/luaData/" .. table_name .. ".lua"

		skynet.error("load data", table_name)

		return sharetable.query(table_name)
	end
else
	function ConfigTable:load_data(table_name)
		return require("luaData/" .. table_name)
	end

	ConfigTable:load()
end

return ConfigTable
