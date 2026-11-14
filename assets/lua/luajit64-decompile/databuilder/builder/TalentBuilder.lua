-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Builder/TalentBuilder.lua

TalentBuilder = BClass("TalentBuilder")

function TalentBuilder:ctor(pbNode)
	self.id = pbNode.id
	self.data = ConfigTable.SkillNode[self.id]
	self.level = pbNode.level
end
