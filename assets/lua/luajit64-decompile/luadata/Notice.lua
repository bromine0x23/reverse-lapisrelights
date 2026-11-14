-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Notice.lua

local NoticeInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	TypeEnum = {
		type = "integer"
	},
	Level = {
		type = "integer"
	},
	Times = {
		type = "integer"
	},
	Notice = {
		type = "integer"
	},
	ShowWord = {
		default = "[]",
		type = "array"
	}
}
local NoticeCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Notice = {}

function Notice:GetAllSync()
	if NoticeCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Notice", "select * from Notice")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, NoticeInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(NoticeCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	NoticeCtrl.hasCached = true
	Notice.GetAllSync = nil
	Notice.GetAllASync = nil
end

function Notice:GetAllASync()
	if NoticeCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Notice", "select * from Notice", function()
		local rowsList = SqlLiteSupport.GetCacheData("Notice")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, NoticeInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(NoticeCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		NoticeCtrl.hasCached = true
		Notice.GetAllSync = nil
		Notice.GetAllASync = nil
	end)
end

setmetatable(Notice, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Notice", SqlLiteTransfer.GenSql("Notice", NoticeCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, NoticeInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Notice:GetAllSync()

return Notice
