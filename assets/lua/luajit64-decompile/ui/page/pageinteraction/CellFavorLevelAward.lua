-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/CellFavorLevelAward.lua

require("UI/Item/UIItemBase")

CellFavorLevelAward = class("CellFavorLevelAward", UIItemBase)

function CellFavorLevelAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellFavorLevelAward:Create(vParam)
	CellFavorLevelAward.base.Create(self, vParam)
end

function CellFavorLevelAward:OnEnter()
	local g = self.UIRootObject

	Text = GOUtil.FindChildComponent(g, "Button/Text", "Text")
	Text.text = Lang(12178)
	self.TxtTitle = GOUtil.FindChildComponent(g, "Text", "Text")
	self.listItem = {}

	for i = 1, 3 do
		self["Cell" .. i] = GOUtil.FindChildGameObject(g, "Group/" .. i)

		local gItem = self["Cell" .. i]
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.GoAttr = GOUtil.FindChildGameObject(g, "Attr")

	for i = 1, 4 do
		self["TxtValue" .. i] = self:GetChildComponent("Attr/" .. i .. "/TxtValue", "Text")
	end

	for i = 1, 4 do
		self:GetChildComponent("Attr/" .. i .. "/Text", "Text").text = _("eAttType_" .. i)
	end

	self.GoGeted = self:GetChildGameObject("Geted")
	self.BtnRec = GOUtil.FindChildGameObject(g, "Button")

	SetActiveFunc(self.BtnRec, false)
end

function CellFavorLevelAward:OnLeave()
	if self.listItem then
		for i = 1, 3 do
			self.listItem[i]:OnLeave()
		end

		self.listItem = nil
	end
end

function CellFavorLevelAward:UpdateData(listAward, curFavorRecord, skillAttr)
	local awards = listAward.LevelAward

	for i = 1, 3 do
		local gItem = self["Cell" .. i]

		if i <= #awards then
			SetActiveFunc(gItem, true)

			local infoItem = ItemManager:GetValueItem(awards[i][1], awards[i][2])

			self.listItem[i]:UpdateWithNumType(infoItem)
		else
			SetActiveFunc(gItem, false)
		end
	end

	local index = 1

	for k, v in ipairs(GetConfigArgJson("FavorSection")) do
		if v >= listAward.ID then
			index = k

			break
		end
	end

	if skillAttr then
		GOUtil.SetActive(self.GoAttr, true)

		for i = 1, 4 do
			self["TxtValue" .. i].text = skillAttr[i]
		end
	else
		GOUtil.SetActive(self.GoAttr, false)
	end

	self.TxtTitle.text = _("Desc_Favor_Impress") .. Lang(GetConfigArgJson("FavorRankName")[index])

	local isRec = curFavorRecord >= listAward.ID

	SetActiveFunc(self.GoGeted, isRec)
end
