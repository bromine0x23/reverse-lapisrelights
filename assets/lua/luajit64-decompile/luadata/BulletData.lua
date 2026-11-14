-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/BulletData.lua

local BulletDataInfo = {
	ID = {
		type = "integer"
	},
	Speed = {
		type = "integer"
	},
	Fx = {
		type = "integer"
	},
	OffsetX = {
		type = "float"
	},
	OffsetY = {
		type = "float"
	},
	OffsetZ = {
		type = "float"
	},
	Track = {
		default = "None",
		type = "text"
	},
	TrackParams = {
		default = "[]",
		type = "array"
	},
	TargetSlot = {
		type = "text"
	}
}
local BulletDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local BulletData = {}

function BulletData:GetAllSync()
	if BulletDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("BulletData", "select * from BulletData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, BulletDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(BulletDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	BulletDataCtrl.hasCached = true
	BulletData.GetAllSync = nil
	BulletData.GetAllASync = nil
end

function BulletData:GetAllASync()
	if BulletDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("BulletData", "select * from BulletData", function()
		local rowsList = SqlLiteSupport.GetCacheData("BulletData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, BulletDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(BulletDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		BulletDataCtrl.hasCached = true
		BulletData.GetAllSync = nil
		BulletData.GetAllASync = nil
	end)
end

setmetatable(BulletData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("BulletData", SqlLiteTransfer.GenSql("BulletData", BulletDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, BulletDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
BulletData:GetAllSync()

return BulletData
