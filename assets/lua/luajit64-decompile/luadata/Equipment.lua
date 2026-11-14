-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Equipment.lua

local EquipmentInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Description = {
		type = "integer"
	},
	Quality = {
		type = "integer"
	},
	QualityLevel = {
		type = "integer"
	},
	JobType = {
		type = "text"
	},
	Slot = {
		type = "integer"
	},
	Weapon = {
		type = "text"
	},
	AtkDistance = {
		type = "integer"
	},
	WeaponAttackSkillID = {
		type = "integer"
	},
	WeaponThumpSkillID = {
		type = "integer"
	},
	Avatar = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	FromStage = {
		default = "[]",
		type = "array"
	},
	FightValue = {
		type = "integer"
	},
	AttriList = {
		default = "[]",
		type = "array"
	}
}
local EquipmentCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Equipment = {}

function Equipment:GetAllSync()
	if EquipmentCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Equipment", "select * from Equipment")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, EquipmentInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(EquipmentCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	EquipmentCtrl.hasCached = true
	Equipment.GetAllSync = nil
	Equipment.GetAllASync = nil
end

function Equipment:GetAllASync()
	if EquipmentCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Equipment", "select * from Equipment", function()
		local rowsList = SqlLiteSupport.GetCacheData("Equipment")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, EquipmentInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(EquipmentCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		EquipmentCtrl.hasCached = true
		Equipment.GetAllSync = nil
		Equipment.GetAllASync = nil
	end)
end

setmetatable(Equipment, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Equipment", SqlLiteTransfer.GenSql("Equipment", EquipmentCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, EquipmentInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Equipment:GetAllSync()

return Equipment
