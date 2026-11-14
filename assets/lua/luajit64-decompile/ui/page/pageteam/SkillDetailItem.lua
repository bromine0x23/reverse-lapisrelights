-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/SkillDetailItem.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageRoleCard/Cell/CellCardSkill")

SkillDetailItem = class("SkillDetailItem", UIItemBase)

function SkillDetailItem:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function SkillDetailItem:Create(vParam)
	SkillDetailItem.base.Create(self, vParam)
end

function SkillDetailItem:OnEnter()
	self.skillCon = self:GetChildGameObject("skillIcon")
	self.nameTxt = self:GetChildComponent("txt_skillName", "Text")
	self.descTxt = self:GetChildComponent("txt_skillDesc", "Text")
end

function SkillDetailItem:UpdateData(infoRoleCard, infoSkill, prefabCellCardSkill)
	local desc = SkillTip.GetDesc(infoSkill.id, infoSkill.pb.level, 0)

	self.descTxt.text = desc
	self.nameTxt.text = Lang(infoSkill.data.Name)

	GOUtil.DestroyAllChildren(self.skillCon)

	self.skill = CellCardSkill(prefabCellCardSkill, self.skillCon, self)

	self.skill:Create()
	self.skill:UpdateData({
		infoRoleCard = infoRoleCard,
		info = infoSkill
	})
end

function SkillDetailItem:OnLeave()
	if self.skill then
		self.skill:OnLeave()
	end
end
