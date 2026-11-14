-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/EquipmentUpgradeProperty.lua

local EquipmentUpgradePropertyInfo = {
	ID = {
		type = "integer"
	},
	Artifice2 = {
		default = "[]",
		type = "array"
	},
	Artifice3 = {
		default = "[]",
		type = "array"
	},
	Artifice4 = {
		default = "[]",
		type = "array"
	},
	Artifice5 = {
		default = "[]",
		type = "array"
	},
	Artifice6 = {
		default = "[]",
		type = "array"
	},
	Assistance2 = {
		default = "[]",
		type = "array"
	},
	Assistance3 = {
		default = "[]",
		type = "array"
	},
	Assistance4 = {
		default = "[]",
		type = "array"
	},
	Assistance5 = {
		default = "[]",
		type = "array"
	},
	Assistance6 = {
		default = "[]",
		type = "array"
	},
	Intelligence2 = {
		default = "[]",
		type = "array"
	},
	Intelligence3 = {
		default = "[]",
		type = "array"
	},
	Intelligence4 = {
		default = "[]",
		type = "array"
	},
	Intelligence5 = {
		default = "[]",
		type = "array"
	},
	Intelligence6 = {
		default = "[]",
		type = "array"
	},
	Speed2 = {
		default = "[]",
		type = "array"
	},
	Speed3 = {
		default = "[]",
		type = "array"
	},
	Speed4 = {
		default = "[]",
		type = "array"
	},
	Speed5 = {
		default = "[]",
		type = "array"
	},
	Speed6 = {
		default = "[]",
		type = "array"
	},
	Strength2 = {
		default = "[]",
		type = "array"
	},
	Strength3 = {
		default = "[]",
		type = "array"
	},
	Strength4 = {
		default = "[]",
		type = "array"
	},
	Strength5 = {
		default = "[]",
		type = "array"
	},
	Strength6 = {
		default = "[]",
		type = "array"
	},
	Weapon = {
		default = "[]",
		type = "array"
	}
}
local EquipmentUpgradePropertyCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local EquipmentUpgradeProperty = {}

function EquipmentUpgradeProperty:GetAllSync()
	if EquipmentUpgradePropertyCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("EquipmentUpgradeProperty", "select * from EquipmentUpgradeProperty")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, EquipmentUpgradePropertyInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(EquipmentUpgradePropertyCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	EquipmentUpgradePropertyCtrl.hasCached = true
	EquipmentUpgradeProperty.GetAllSync = nil
	EquipmentUpgradeProperty.GetAllASync = nil
end

function EquipmentUpgradeProperty:GetAllASync()
	if EquipmentUpgradePropertyCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("EquipmentUpgradeProperty", "select * from EquipmentUpgradeProperty", function()
		local rowsList = SqlLiteSupport.GetCacheData("EquipmentUpgradeProperty")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, EquipmentUpgradePropertyInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(EquipmentUpgradePropertyCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		EquipmentUpgradePropertyCtrl.hasCached = true
		EquipmentUpgradeProperty.GetAllSync = nil
		EquipmentUpgradeProperty.GetAllASync = nil
	end)
end

setmetatable(EquipmentUpgradeProperty, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("EquipmentUpgradeProperty", SqlLiteTransfer.GenSql("EquipmentUpgradeProperty", EquipmentUpgradePropertyCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, EquipmentUpgradePropertyInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
EquipmentUpgradeProperty:GetAllSync()

return EquipmentUpgradeProperty
