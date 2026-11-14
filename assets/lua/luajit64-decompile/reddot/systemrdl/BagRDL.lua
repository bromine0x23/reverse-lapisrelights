-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/BagRDL.lua

BagRDL = {}

local RD_Bag_Branch_Path = {
	Bag = "Bag/%d"
}
local KEY_RD_BAG = "KEY_RD_BAG"
local All_NEW_BAG_ITEM = {}

function BagRDL.Init()
	for i = 1, 5 do
		local t = PersistentStoreUtil.GetList(KEY_RD_BAG .. i)

		All_NEW_BAG_ITEM[i] = t
	end

	BagRDL.InitRD()
end

function BagRDL.InitRD()
	for k, v in pairs(All_NEW_BAG_ITEM) do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Bag_Branch_Path.Bag, #v, k)
	end
end

function BagRDL.Add(_id)
	local item = ItemManager:Get(_id)
	local _idx = item.data.BagPage

	if not All_NEW_BAG_ITEM[_idx] then
		return
	end

	if table.contains(All_NEW_BAG_ITEM[_idx], tostring(_id)) then
		return
	end

	table.insert(All_NEW_BAG_ITEM[_idx], tostring(_id))
	PersistentStoreUtil.AddList(KEY_RD_BAG .. _idx, _id)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Bag_Branch_Path.Bag, 1, _idx)
end

function BagRDL.Remove(_id, _idx)
	All_NEW_BAG_ITEM[_idx] = All_NEW_BAG_ITEM[_idx] or {}

	local value = 0

	if _id then
		if table.contains(All_NEW_BAG_ITEM[_idx], tostring(_id)) then
			table.removeByValue(All_NEW_BAG_ITEM[_idx], tostring(_id))

			value = 1
		end
	else
		value = #All_NEW_BAG_ITEM[_idx]
		All_NEW_BAG_ITEM[_idx] = {}
	end

	PersistentStoreUtil.SetList(KEY_RD_BAG .. _idx, All_NEW_BAG_ITEM[_idx])
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Bag_Branch_Path.Bag, -value, _idx)
end

function BagRDL.IsExist(_id)
	local item = ItemManager:Get(_id)
	local _idx = item.data.BagPage

	if not All_NEW_BAG_ITEM[_idx] then
		return false
	end

	return table.contains(All_NEW_BAG_ITEM[_idx], tostring(_id))
end

return BagRDL
