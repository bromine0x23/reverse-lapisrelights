-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/CellMonster.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageCombatReadiness/DlgMonsterDes")

CellMonster = class("CellMonster", UIItemBase)

function CellMonster:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellMonster:OnEnter(vParam)
	local g = self.UIRootObject

	self.icon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.isBoss = GOUtil.FindChildGameObject(g, "title")
	self.type = GOUtil.FindChildComponent(g, "Type", "Image")

	self:AddClick(g, self.OnClicked)
end

function CellMonster:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.UIRootObject, self.OnClicked)
end

function CellMonster:OnClicked()
	UIMgr.AddPanel(DlgMonsterDes(), {
		listMonster = self.infoStage.listMonster,
		index = self.index
	}, UIMgr.UIOverLayObject)
end

function CellMonster:UpdateData(unitId, index, infoStage)
	self.index = index
	self.infoStage = infoStage

	local enemy = EnemyManager:Get(unitId).data

	UIUtil.SetImageSprite(self.icon, enemy.CombatReadinessHeadIcon, self)
	self.isBoss:SetActive(enemy.Boss ~= 0)

	local enemyInfo = EnemyManager:Get(unitId)

	UIUtil.SetImageSprite(self.type, "UIDyAtlas/RoleJob/ICO_" .. enemyInfo.data.Job .. "_01", self)
end
