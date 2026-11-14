-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/CellSkillDetail.lua

require("UI/Item/UIItemBase")

CellSkillDetail = class("CellSkillDetail", UIItemBase)

function CellSkillDetail:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellSkillDetail:OnEnter(vParam)
	local g = self.UIRootObject

	self.icon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.iconGo = self:GetChildGameObject("Icon")
	self.type = GOUtil.FindChildGameObject(g, "Type")
	self.typeC = GOUtil.FindChildGameObject(g, "TypeC")
	self.txtName = GOUtil.FindChildComponent(g, "NameBg/txt_Name", "Text")

	self:OnRegisterEvent()
end

function CellSkillDetail:OnRegisterEvent()
	self:AddListener(self.iconGo, self.OnPointerDown_Buff, EventTriggerType.PointerDown)
end

function CellSkillDetail:OnUnRegisterEvent()
	self:RemoveListener(self.iconGo, self.OnPointerDown_Buff, EventTriggerType.PointerDown)
end

function CellSkillDetail:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end

function CellSkillDetail:OnPointerDown_Buff(data)
	local tipData = SkillTip.GetMonsterData(data.position, self.skillId)

	UIMgr.ShowSkillTip(tipData)
end

function CellSkillDetail:UpdateData(unitId, index)
	local infoSkill = TalentManager:Get(unitId)

	UIUtil.SetImageSprite(self.icon, "UIDyAtlas/Skill/" .. infoSkill.data.Icon, self)

	self.txtName.text = Lang(infoSkill.data.Name)

	self.type:SetActive(infoSkill.data.Type == 2)
	self.typeC:SetActive(infoSkill.data.Type ~= 2)

	self.skillId = infoSkill.id
end
