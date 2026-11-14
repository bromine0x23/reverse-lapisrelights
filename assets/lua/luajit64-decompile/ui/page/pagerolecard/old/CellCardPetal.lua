-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Old/CellCardPetal.lua

require("UI/Item/UIItemBase")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

CellCardPetal = class("CellCardPetal", UIItemBase)

function CellCardPetal:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCardPetal:Create(vParam)
	CellCardPetal.base.Create(self, vParam)
end

function CellCardPetal:OnEnter()
	local g = self.UIRootObject

	self.GoImage = GOUtil.FindChildGameObject(g, "Image")
	self.SkillIcon = GOUtil.FindChildComponent(g, "Panel/Icon", "Image")
	self.TxtName = GOUtil.FindChildComponent(g, "Panel/TxtName", "Text")
	self.TxtLevel = GOUtil.FindChildComponent(g, "Panel/TxtLevel", "Text")
	self.TxtDesc = GOUtil.FindChildComponent(g, "Panel/TxtDesc", "Text")
	self.TxtPetal = GOUtil.FindChildComponent(g, "Panel/Text", "Text")
end

function CellCardPetal:UpdateData(data)
	local index = data.index
	local infoRoleCard = data.infoRoleCard
	local flag = data.flag
	local curPetal = infoRoleCard.curPetal

	self.TxtPetal.text = _("Desc_Quality") .. _("ecNum_" .. index)

	if index <= curPetal then
		self.TxtPetal.color = Color.New(0, 0.9803921568627451, 0.9803921568627451, 1)
	end

	local listSkill = infoRoleCard.data.FlowerSkill
	local skillId = listSkill[index][1]

	if skillId == nil then
		return
	end

	local infoSkill = TalentManager:Get(skillId)
	local upLevel = listSkill[index][2]

	self.TxtLevel.text = _("Player_Level") .. upLevel

	UIUtil.SetImageSprite(self.SkillIcon, "UIDyAtlas/Skill/" .. infoSkill.data.Icon)

	self.TxtName.text = Lang(infoSkill.data.Name)
	self.TxtDesc.text = skillTip.GetDesc(infoSkill.id, upLevel, 0)

	self.GoImage:SetActive(not flag)
end
