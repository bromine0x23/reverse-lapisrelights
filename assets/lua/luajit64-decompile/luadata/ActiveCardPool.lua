-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ActiveCardPool.lua

local ActiveCardPoolInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		default = "0",
		type = "integer"
	},
	Info = {
		default = "0",
		type = "integer"
	},
	PoolIndex = {
		type = "integer"
	},
	NoLimit = {
		type = "integer"
	},
	ActiveID = {
		type = "integer"
	},
	ItemList = {
		default = "[]",
		type = "array"
	},
	OneCost = {
		default = "[]",
		type = "array"
	},
	TenCost = {
		default = "[]",
		type = "array"
	}
}
local ActiveCardPoolCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ActiveCardPool = {}

function ActiveCardPool:GetAllSync()
	if ActiveCardPoolCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ActiveCardPool", "select * from ActiveCardPool")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveCardPoolInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ActiveCardPoolCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ActiveCardPoolCtrl.hasCached = true
	ActiveCardPool.GetAllSync = nil
	ActiveCardPool.GetAllASync = nil
end

function ActiveCardPool:GetAllASync()
	if ActiveCardPoolCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ActiveCardPool", "select * from ActiveCardPool", function()
		local rowsList = SqlLiteSupport.GetCacheData("ActiveCardPool")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveCardPoolInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ActiveCardPoolCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ActiveCardPoolCtrl.hasCached = true
		ActiveCardPool.GetAllSync = nil
		ActiveCardPool.GetAllASync = nil
	end)
end

setmetatable(ActiveCardPool, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ActiveCardPool", SqlLiteTransfer.GenSql("ActiveCardPool", ActiveCardPoolCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ActiveCardPoolInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ActiveCardPool:GetAllSync()

return ActiveCardPool
