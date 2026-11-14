-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CallData.lua

local CallDataInfo = {
	ID = {
		type = "integer"
	},
	RoleId = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Path = {
		type = "text"
	},
	LanguragePath = {
		type = "text"
	},
	Award = {
		default = "[]",
		type = "array"
	},
	StageID = {
		type = "integer"
	},
	FavorUnlockLevel = {
		type = "integer"
	}
}
local CallDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CallData = {}

function CallData:GetAllSync()
	if CallDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CallData", "select * from CallData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CallDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CallDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CallDataCtrl.hasCached = true
	CallData.GetAllSync = nil
	CallData.GetAllASync = nil
end

function CallData:GetAllASync()
	if CallDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CallData", "select * from CallData", function()
		local rowsList = SqlLiteSupport.GetCacheData("CallData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CallDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CallDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CallDataCtrl.hasCached = true
		CallData.GetAllSync = nil
		CallData.GetAllASync = nil
	end)
end

setmetatable(CallData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CallData", SqlLiteTransfer.GenSql("CallData", CallDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CallDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CallData:GetAllSync()

return CallData
