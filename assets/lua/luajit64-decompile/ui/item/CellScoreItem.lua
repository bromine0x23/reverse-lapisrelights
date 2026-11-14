-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Item/CellScoreItem.lua

require("UI/Item/UIItemBase")

CellScoreItem = class("CellScoreItem", UIItemBase)

function CellScoreItem:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellScoreItem:OnEnter()
	local g = self.UIRootObject
	local go = GOUtil.FindChildGameObject(g, "CellItem")

	self.Item = CellItem()

	self.Item:InitItemByRoot(go)

	self.TxtScore = GOUtil.FindChildComponent(g, "BgValue/Text", "Text")
	self.GoRaycast = GOUtil.FindChildGameObject(g, "Raycast")

	self:AddClick(self.GoRaycast, self.OnClickRayCast)
end

function CellScoreItem:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.GoRaycast, self.OnClickRayCast)

	if self.Item and self.Item.OnLeave then
		self.Item:OnLeave()
	end
end

function CellScoreItem:UpdateData(data)
	if not data or not data.infoItem then
		return
	end

	self.Index = data.index
	self.TxtScore.text = data.strValue or ""

	if self.Item and data.infoItem then
		self.Item:UpdateWithNumType(data.infoItem)
	end

	RedDotSystemMgr.SetUIRedDot(self.UIRootObject, data.path)
end

function CellScoreItem:UpdateState(isReced, canRece)
	if isReced == nil then
		isReced = false
	end

	if canRece == nil then
		canRece = false
	end

	if self.Item then
		self.Item:SetGeted(isReced)
		self.Item:SetIconGray(not isReced and not canRece)
	end

	GOUtil.SetActive(self.GoRaycast, not isReced and canRece)
end

function CellScoreItem:OnClickRayCast()
	local function cb()
		self:UpdateState(true)
	end

	local data = {
		index = self.Index,
		callback = cb
	}

	if self.page then
		self.page:RequestScoreAward(data)
	else
		Event.Instance:Fire("RequestScoreAward", data)
	end
end
