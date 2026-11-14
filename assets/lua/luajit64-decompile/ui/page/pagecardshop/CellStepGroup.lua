-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/CellStepGroup.lua

require("UI/Item/UIItemBase")

CellStepGroup = class("CellStepGroup", UIItemBase)

function CellStepGroup:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellStepGroup:OnEnter(vParam)
	local g = self.UIRootObject
end

function CellStepGroup:UpdateData(stepList, prefabCellItem, stepUpOrder, stepUpTurn)
	self.stepCellList = {}

	local lock = stepUpTurn < stepList[1].data.StepUpTurn

	for i = 1, #stepList do
		local data = stepList[i]
		local item = CellStep(prefabCellItem, self.UIRootObject, self)

		item:Create()
		item:UpdateData(data, stepUpOrder, i, lock)
		table.insert(self.stepCellList, item)
	end
end

function CellStepGroup:OnLeave()
	for i, v in ipairs(self.stepCellList) do
		v:OnLeave()
	end

	self.stepCellList = nil
end
