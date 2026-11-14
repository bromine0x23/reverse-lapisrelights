-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ActiveBuffInfo.lua

local ActiveBuffInfoInfo = {
	ID = {
		type = "integer"
	},
	ActiveID = {
		type = "integer"
	},
	BuffType = {
		default = "[]",
		type = "array"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Icon = {
		type = "text"
	}
}
local ActiveBuffInfoCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ActiveBuffInfo = {}

function ActiveBuffInfo:GetAllSync()
	if ActiveBuffInfoCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ActiveBuffInfo", "select * from ActiveBuffInfo")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveBuffInfoInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ActiveBuffInfoCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ActiveBuffInfoCtrl.hasCached = true
	ActiveBuffInfo.GetAllSync = nil
	ActiveBuffInfo.GetAllASync = nil
end

function ActiveBuffInfo:GetAllASync()
	if ActiveBuffInfoCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ActiveBuffInfo", "select * from ActiveBuffInfo", function()
		local rowsList = SqlLiteSupport.GetCacheData("ActiveBuffInfo")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveBuffInfoInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ActiveBuffInfoCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ActiveBuffInfoCtrl.hasCached = true
		ActiveBuffInfo.GetAllSync = nil
		ActiveBuffInfo.GetAllASync = nil
	end)
end

setmetatable(ActiveBuffInfo, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ActiveBuffInfo", SqlLiteTransfer.GenSql("ActiveBuffInfo", ActiveBuffInfoCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ActiveBuffInfoInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ActiveBuffInfo:GetAllSync()

return ActiveBuffInfo
