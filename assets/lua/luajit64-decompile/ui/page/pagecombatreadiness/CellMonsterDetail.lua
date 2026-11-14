-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/CellMonsterDetail.lua

require("UI/Item/UIItemBase")

CellMonsterDetail = class("CellMonsterDetail", UIItemBase)

function CellMonsterDetail:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellMonsterDetail:OnEnter(vParam)
	local g = self.UIRootObject

	self.icon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.type = GOUtil.FindChildComponent(g, "Type", "Image")
	self.txtName = GOUtil.FindChildComponent(g, "NameBg/txt_Name", "Text")
	self.select = GOUtil.FindChildGameObject(g, "Select")
	self.selectBg = GOUtil.FindChildGameObject(g, "NameBg/SelectBg")
	self.isBoss = GOUtil.FindChildGameObject(g, "title")
	self.txtLevel = GOUtil.FindChildComponent(g, "tex_level", "Text")

	self:AddClick(g, self.OnClicked)
end

function CellMonsterDetail:OnLeave()
	self:RemoveClick(g, self.OnClicked)
	UnloadAllImageSprite(self)
end

function CellMonsterDetail:OnClicked()
	if self.clickCallBack then
		self.clickCallBack(self.index)
	end
end

function CellMonsterDetail:UpdateData(unitId, index, selected, clickCallBack)
	self.index = index
	self.clickCallBack = clickCallBack

	self.select:SetActive(selected)
	self.selectBg:SetActive(selected)

	local enemyInfo = EnemyManager:Get(unitId)

	UIUtil.SetImageSprite(self.icon, enemyInfo.data.CombatReadinessHeadIcon, self)

	self.txtName.text = enemyInfo:GetName()

	UIUtil.SetImageSprite(self.type, "UIDyAtlas/RoleJob/ICO_" .. enemyInfo.data.Job .. "_01", self)

	local enemy = EnemyManager:Get(unitId).data

	self.txtLevel.text = Lang(5000025) .. enemy.Level

	self.isBoss:SetActive(enemy.Boss ~= 0)
end
