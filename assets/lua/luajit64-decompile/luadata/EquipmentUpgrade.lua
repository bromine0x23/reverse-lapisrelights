-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/EquipmentUpgrade.lua

local EquipmentUpgradeInfo = {
	ID = {
		type = "integer"
	},
	Job = {
		type = "integer"
	},
	Slot = {
		type = "integer"
	},
	Level = {
		type = "integer"
	},
	CostList = {
		default = "[]",
		type = "array"
	}
}
local EquipmentUpgradeCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local EquipmentUpgrade = {}

function EquipmentUpgrade:GetAllSync()
	if EquipmentUpgradeCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("EquipmentUpgrade", "select * from EquipmentUpgrade")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, EquipmentUpgradeInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(EquipmentUpgradeCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	EquipmentUpgradeCtrl.hasCached = true
	EquipmentUpgrade.GetAllSync = nil
	EquipmentUpgrade.GetAllASync = nil
end

function EquipmentUpgrade:GetAllASync()
	if EquipmentUpgradeCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("EquipmentUpgrade", "select * from EquipmentUpgrade", function()
		local rowsList = SqlLiteSupport.GetCacheData("EquipmentUpgrade")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, EquipmentUpgradeInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(EquipmentUpgradeCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		EquipmentUpgradeCtrl.hasCached = true
		EquipmentUpgrade.GetAllSync = nil
		EquipmentUpgrade.GetAllASync = nil
	end)
end

setmetatable(EquipmentUpgrade, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("EquipmentUpgrade", SqlLiteTransfer.GenSql("EquipmentUpgrade", EquipmentUpgradeCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, EquipmentUpgradeInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
EquipmentUpgrade:GetAllSync()

return EquipmentUpgrade
