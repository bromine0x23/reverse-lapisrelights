-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Builder/SkillBuilder.lua

SkillBuilder = BClass("SkillBuilder")

function SkillBuilder:ctor(pbSkill)
	self.skillId = pbSkill.id
	self.skillLevel = pbSkill.level
	self.data = ConfigTable.AllSkills[self.skillId]
	self.attrs = {}

	self:UpdateAttr()
end

function SkillBuilder:UpdateAttr()
	Attribute:Init()

	local tab1, tab2, tab3 = self.data.Argus[self.skillLevel], self.data.Argus2[self.skillLevel], self.data.Argus3[self.skillLevel]

	for k, v in pairs(GetMapTab({
		tab1,
		tab2,
		tab3
	})) do
		Attribute:ModifyPerValue(k, v)
	end

	self.attrs = Attribute.attPerTab
end
