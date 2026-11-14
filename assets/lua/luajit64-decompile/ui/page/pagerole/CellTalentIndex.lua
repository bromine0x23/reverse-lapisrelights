-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/CellTalentIndex.lua

require("UI/Item/UIItemBase")

CellTalentIndex = class("CellTalentIndex", UIItemBase)

function CellTalentIndex:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTalentIndex:Create(vParam)
	CellTalentIndex.base.Create(self, vParam)
end

function CellTalentIndex:OnEnter()
	local g = self.UIRootObject

	self.panel1 = GOUtil.FindChildGameObject(g, "Button")
	self.panel2 = GOUtil.FindChildGameObject(g, "Select")
	self.GoDot1 = GOUtil.FindChildGameObject(g, "Button/Dot")
	self.GoDot2 = GOUtil.FindChildGameObject(g, "Select/Dot")
	self.txt1 = GOUtil.FindChildComponent(g, "Button/Text", "Text")
	self.txt2 = GOUtil.FindChildComponent(g, "Select/Text", "Text")
end

function CellTalentIndex:UpdateData(index, infoRole)
	self.infoRole = infoRole
	self.txt1.text = self.Index .. _("Desc_Step")
	self.txt2.text = self.Index .. _("Desc_Step")

	self:UpdateDot()
	self:UpdateSelectState(index == self.Index)
end

function CellTalentIndex:UpdateDot()
	if not self.infoRole then
		return
	end

	local hasDot = SkillManager:GetPageTalentTreeAllTrunkDot(self.infoRole, self.Index)

	self.GoDot1:SetActive(hasDot)
	self.GoDot2:SetActive(hasDot)
end

function CellTalentIndex:UpdateSelectState(state)
	self.panel1:SetActive(not state)
	self.panel2:SetActive(state)
end
