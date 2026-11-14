-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/CellTouchAward.lua

require("UI/Item/UIItemBase")

CellTouchAward = class("CellTouchAward", UIItemBase)

function CellTouchAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTouchAward:OnEnter()
	local g = self.UIRootObject

	self.TextTitle = GOUtil.FindChildComponent(g, "Text", "Text")
	self.TextGeted = GOUtil.FindChildComponent(g, "Geted", "Text")

	for i = 1, 3 do
		self["item" .. i] = self:GetChildGameObject("Group/" .. i)
	end

	self.TextGeted.text = _("Desc_Has_Get")
end

function CellTouchAward:UpdateData(info, index)
	self.TextTitle.text = string.format(_("Desc_UpdateTime"), _("ecNum_" .. index))

	local pack = OperationActiveMgr:GetRewardPackData(info).PackItem

	for i = 1, 3 do
		SetActiveFunc(self["item" .. i], false)
	end

	for i = 1, #pack do
		local award = pack[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			SetActiveFunc(self["item" .. i], true)

			local gItem = self["item" .. i]
			local item = CellItem(gItem)

			item:InitItemByRoot(gItem)

			if award[2] == 0 then
				item:UpdateNoNumType(infoItem)
			else
				item:UpdateWithNumType(infoItem)
			end
		end
	end

	SetActiveFunc(self.TextGeted.gameObject, false)

	if index <= InfoGameInst.gameInfo.touchDailyNum then
		SetActiveFunc(self.TextGeted.gameObject, true)
	end
end
