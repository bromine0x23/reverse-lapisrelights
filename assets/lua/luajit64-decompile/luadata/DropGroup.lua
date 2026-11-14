-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/DropGroup.lua

local DropGroupInfo = {
	ID = {
		type = "integer"
	},
	GroupID = {
		type = "integer"
	},
	Weight = {
		type = "integer"
	},
	ItemID = {
		type = "integer"
	},
	NumMin = {
		type = "integer"
	},
	NumMax = {
		type = "integer"
	}
}
local DropGroupCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local DropGroup = {}

function DropGroup:GetAllSync()
	if DropGroupCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("DropGroup", "select * from DropGroup")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, DropGroupInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(DropGroupCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	DropGroupCtrl.hasCached = true
	DropGroup.GetAllSync = nil
	DropGroup.GetAllASync = nil
end

function DropGroup:GetAllASync()
	if DropGroupCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("DropGroup", "select * from DropGroup", function()
		local rowsList = SqlLiteSupport.GetCacheData("DropGroup")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, DropGroupInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(DropGroupCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		DropGroupCtrl.hasCached = true
		DropGroup.GetAllSync = nil
		DropGroup.GetAllASync = nil
	end)
end

setmetatable(DropGroup, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("DropGroup", SqlLiteTransfer.GenSql("DropGroup", DropGroupCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, DropGroupInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
DropGroup:GetAllSync()

return DropGroup
