-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/WorkRequire.lua

local WorkRequireInfo = {
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
	Type = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	Value = {
		default = "[]",
		type = "array"
	}
}
local WorkRequireCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local WorkRequire = {}

function WorkRequire:GetAllSync()
	if WorkRequireCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("WorkRequire", "select * from WorkRequire")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, WorkRequireInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(WorkRequireCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	WorkRequireCtrl.hasCached = true
	WorkRequire.GetAllSync = nil
	WorkRequire.GetAllASync = nil
end

function WorkRequire:GetAllASync()
	if WorkRequireCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("WorkRequire", "select * from WorkRequire", function()
		local rowsList = SqlLiteSupport.GetCacheData("WorkRequire")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, WorkRequireInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(WorkRequireCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		WorkRequireCtrl.hasCached = true
		WorkRequire.GetAllSync = nil
		WorkRequire.GetAllASync = nil
	end)
end

setmetatable(WorkRequire, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("WorkRequire", SqlLiteTransfer.GenSql("WorkRequire", WorkRequireCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, WorkRequireInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
WorkRequire:GetAllSync()

return WorkRequire
