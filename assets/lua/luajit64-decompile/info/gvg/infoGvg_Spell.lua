-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/infoGvg_Spell.lua

local spell = class("infoGvg_Spell")
local item = class("infoGvg_Spell_item")
local GVGActiveShop = require("luaData/GVGActiveShop")
local shopMap = {}

for k, v in pairs(GVGActiveShop) do
	shopMap[tostring(v.ActiveID)] = v
end

function spell:ctor()
	self.map = {}
	self.items = {}
end

function spell:Purge()
	for i = #self.items, 1, -1 do
		local item = table.remove(self.items, i)

		item:Purge()
	end

	self.map = {}
	self.items = {}
end

function spell:Ipairs()
	return ipairs(self.items)
end

function spell:Get(uid)
	local item

	if not uid then
		item = self.map[self.curuid]
	else
		if type(uid) == "number" then
			uid = tostring(uid)
		end

		item = self.map[uid]
	end

	return item
end

function spell:Refresh(activeId)
	self.items = {}
	self.map = {}

	local cfg = shopMap[tostring(activeId)]

	if not cfg then
		Infogvg:Error("config error , GVGActiveShop is nil , activeId: " .. activeId)

		return
	end

	local uid = 0

	for i, goodsId in ipairs(cfg.GoodsID) do
		local infoProduct = ShopManager:GetProduct(goodsId)

		if infoProduct and infoProduct.data then
			for _, itemData in ipairs(infoProduct.data.GoodsItemList) do
				local itemId = itemData[1]
				local allSkillId = itemData[2]
				local _item = item()

				_item:Init(goodsId, itemId, allSkillId)
				table.insert(self.items, _item)

				uid = uid + 1
				_item.uid = tostring(uid)
				self.map[tostring(uid)] = _item
			end
		else
			Infogvg:Error("ShopManager:GetProduct() is nil ,goodsId: " .. goodsId .. " activeId:" .. activeId)
		end
	end
end

function spell:Hint()
	local val = false

	for i, spell in ipairs(self.items) do
		local infoProduct = spell:GetProduct()
		local costItemId = infoProduct.data.CostValue[1]
		local coin = ItemManager:GetItemCount(costItemId)
		local cost = infoProduct.data.CostValue[2]

		if Infogvg.union:IsLord() == true and cost <= coin and spell.owned == false then
			val = true

			break
		end
	end

	return val
end

function item:ctor()
	self.goodsId = 0
	self.itemId = 0
	self.allSkillId = 0
	self.owned = false
	self.endTime = nil
end

function item:Purge()
	return
end

function item:Init(goodsId, itemId, allSkillId)
	self.goodsId = goodsId
	self.itemId = itemId
	self.allSkillId = allSkillId
end

function item:Owned()
	return self.owned
end

function item:SetOwned(val)
	self.owned = val
end

function item:SetEndTime(val)
	self.endTime = val

	local owned = not string.isNullOrEmpty(self.endTime)

	self:SetOwned(owned)
end

function item:GetProduct()
	local out = ShopManager:GetProduct(self.goodsId)

	if not out then
		Infogvg.Error("GoodsData can not found !  , goodsId:" .. self.goodsId)
	end

	return out
end

function item:GetItem()
	local out = ItemManager:Get(self.itemId)

	if not out then
		Infogvg.Error("itemData can not found !  , goodsId:" .. self.itemId)
	end

	return out
end

return spell
