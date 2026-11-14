-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/EquipmentQualityPromote.lua

local EquipmentQualityPromoteInfo = {
	ID = {
		type = "integer"
	},
	Job = {
		type = "integer"
	},
	PresentQuality = {
		type = "integer"
	},
	QualityGrade = {
		type = "integer"
	},
	Slot = {
		type = "integer"
	},
	CostList = {
		default = "[]",
		type = "array"
	},
	PromoteProperty = {
		default = "[]",
		type = "array"
	}
}
local EquipmentQualityPromoteCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local EquipmentQualityPromote = {}

function EquipmentQualityPromote:GetAllSync()
	if EquipmentQualityPromoteCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("EquipmentQualityPromote", "select * from EquipmentQualityPromote")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, EquipmentQualityPromoteInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(EquipmentQualityPromoteCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	EquipmentQualityPromoteCtrl.hasCached = true
	EquipmentQualityPromote.GetAllSync = nil
	EquipmentQualityPromote.GetAllASync = nil
end

function EquipmentQualityPromote:GetAllASync()
	if EquipmentQualityPromoteCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("EquipmentQualityPromote", "select * from EquipmentQualityPromote", function()
		local rowsList = SqlLiteSupport.GetCacheData("EquipmentQualityPromote")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, EquipmentQualityPromoteInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(EquipmentQualityPromoteCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		EquipmentQualityPromoteCtrl.hasCached = true
		EquipmentQualityPromote.GetAllSync = nil
		EquipmentQualityPromote.GetAllASync = nil
	end)
end

setmetatable(EquipmentQualityPromote, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("EquipmentQualityPromote", SqlLiteTransfer.GenSql("EquipmentQualityPromote", EquipmentQualityPromoteCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, EquipmentQualityPromoteInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
EquipmentQualityPromote:GetAllSync()

return EquipmentQualityPromote
