-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/AvatarData.lua

local AvatarDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Description = {
		type = "integer"
	},
	Slot = {
		default = "[]",
		type = "array"
	},
	AvatarPath = {
		type = "text"
	},
	Icon = {
		type = "text"
	},
	StableModelPath = {
		type = "text"
	},
	WeaponAnimController = {
		type = "text"
	},
	WeaponSit = {
		default = "[]",
		type = "array"
	},
	Cost = {
		default = "[]",
		type = "array"
	},
	Lock = {
		type = "integer"
	},
	Publish_At = {
		type = "text"
	},
	FromWhere = {
		type = "integer"
	},
	FromRoleCardID = {
		type = "integer"
	},
	Active = {
		type = "integer"
	},
	SkinAttList = {
		default = "[]",
		type = "array"
	},
	SkinAttListPer = {
		default = "[]",
		type = "array"
	},
	Argus1 = {
		default = "[]",
		type = "array"
	},
	Argus2 = {
		default = "[]",
		type = "array"
	},
	AvatarType = {
		type = "integer"
	},
	AvatarFrom = {
		type = "integer"
	},
	AvatarTabType = {
		type = "text"
	},
	StartTime = {
		type = "text"
	},
	EndTime = {
		type = "text"
	}
}
local AvatarDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local AvatarData = {}

function AvatarData:GetAllSync()
	if AvatarDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("AvatarData", "select * from AvatarData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, AvatarDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(AvatarDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	AvatarDataCtrl.hasCached = true
	AvatarData.GetAllSync = nil
	AvatarData.GetAllASync = nil
end

function AvatarData:GetAllASync()
	if AvatarDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("AvatarData", "select * from AvatarData", function()
		local rowsList = SqlLiteSupport.GetCacheData("AvatarData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, AvatarDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(AvatarDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		AvatarDataCtrl.hasCached = true
		AvatarData.GetAllSync = nil
		AvatarData.GetAllASync = nil
	end)
end

setmetatable(AvatarData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("AvatarData", SqlLiteTransfer.GenSql("AvatarData", AvatarDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, AvatarDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
AvatarData:GetAllSync()

return AvatarData
