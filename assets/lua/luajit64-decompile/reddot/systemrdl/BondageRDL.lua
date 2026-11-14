-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/BondageRDL.lua

BondageRDL = {}

local RD_Bondage_Branch_Path = {
	Unlock = "Arrow/Bondage/Unlock/%d"
}
local KEY_RD_BONDAGE_UNLOCK = "KEY_RD_BONDAGE_UNLOCK"
local ALL_BONDAGE_COMB = {}
local ALL_UNLOCK_BONDAGE = {}
local PRE_DOT_VALUE = {}

function BondageRDL.Init()
	ALL_BONDAGE_COMB = CombinationMgr.GetAllBondageCombination()

	for _, v in pairs(ALL_BONDAGE_COMB) do
		local t = PersistentStoreUtil.GetList(KEY_RD_BONDAGE_UNLOCK .. v.id)

		ALL_UNLOCK_BONDAGE[v.id] = ALL_UNLOCK_BONDAGE[v.id] or {}

		for i = 1, #t do
			if not table.contains(ALL_UNLOCK_BONDAGE[v.id], tonumber(t[i])) then
				table.insert(ALL_UNLOCK_BONDAGE[v.id], tonumber(t[i]))
			end
		end
	end

	BondageRDL.InitRD()
end

function BondageRDL.InitRD()
	for k, v in pairs(ALL_UNLOCK_BONDAGE) do
		local value = 0

		if #v > 0 then
			value = 1
		end

		PRE_DOT_VALUE[k] = value

		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Bondage_Branch_Path.Unlock, value, k)
	end
end

function BondageRDL.AddBondageUnlock(_id, _bondageid)
	if not ALL_UNLOCK_BONDAGE[_id] then
		ALL_UNLOCK_BONDAGE[_id] = {}
	end

	table.insert(ALL_UNLOCK_BONDAGE[_id], _bondageid)
	PersistentStoreUtil.AddList(KEY_RD_BONDAGE_UNLOCK .. _id, _bondageid)

	if PRE_DOT_VALUE[_id] == nil or PRE_DOT_VALUE[_id] <= 0 then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Bondage_Branch_Path.Unlock, 1, _id)
	end
end

function BondageRDL.RemoveBondageUnlock(_id)
	PRE_DOT_VALUE[_id] = 0

	if #ALL_UNLOCK_BONDAGE[_id] == 0 then
		return
	end

	ALL_UNLOCK_BONDAGE[_id] = {}

	PersistentStoreUtil.SetList(KEY_RD_BONDAGE_UNLOCK .. _id, ALL_UNLOCK_BONDAGE[_id])
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Bondage_Branch_Path.Unlock, 0, _id)
end

function BondageRDL.RemoveAllBondageUnlock()
	for id in pairs(ALL_UNLOCK_BONDAGE) do
		BondageRDL.RemoveBondageUnlock(id)
	end
end

function BondageRDL.GetUnlockBondage(_id)
	return ALL_UNLOCK_BONDAGE[_id] or {}
end

return BondageRDL
