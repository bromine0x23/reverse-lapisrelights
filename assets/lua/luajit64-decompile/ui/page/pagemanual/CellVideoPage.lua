-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/CellVideoPage.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageManual/CellVideoItem")

CellVideoPage = class("CellVideoPage", UIItemBase)

function CellVideoPage:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.Page = page
end

function CellVideoPage:OnEnter(vParam)
	local g = self.UIRootObject
end

function CellVideoPage:OnLeave()
	if self.cells then
		for i, v in ipairs(self.cells) do
			v:OnLeave()
		end

		self.cells = nil
	end

	self.data = nil
	self.Page = nil
end

function CellVideoPage:UpdateData(data)
	self.data = data

	if not self.cells then
		self.PrefabCellItem = data.PrefabCellItem
		self.cells = {}

		for i = 1, 6 do
			local item = CellVideoItem(self.PrefabCellItem, self.UIRootObject, self, self.Page)

			item:Create()
			table.insert(self.cells, item)
		end
	end

	for i = 1, 6 do
		if i <= #data then
			self.cells[i]:UpdateData(self.data[i], function()
				self:UpdateData(self.data)
			end)
		else
			self.cells[i]:HideSelf()
		end
	end
end
