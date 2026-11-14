-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPDrop.lua

local PVPDropInfo = {
	ID = {
		type = "integer"
	},
	DropId = {
		type = "integer"
	},
	FromScore = {
		type = "integer"
	},
	ToScore = {
		type = "integer"
	},
	DropGroupId = {
		default = "[]",
		type = "array"
	}
}
local PVPDropCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPDrop = {}

function PVPDrop:GetAllSync()
	if PVPDropCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPDrop", "select * from PVPDrop")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPDropInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPDropCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPDropCtrl.hasCached = true
	PVPDrop.GetAllSync = nil
	PVPDrop.GetAllASync = nil
end

function PVPDrop:GetAllASync()
	if PVPDropCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPDrop", "select * from PVPDrop", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPDrop")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPDropInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPDropCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPDropCtrl.hasCached = true
		PVPDrop.GetAllSync = nil
		PVPDrop.GetAllASync = nil
	end)
end

setmetatable(PVPDrop, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPDrop", SqlLiteTransfer.GenSql("PVPDrop", PVPDropCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPDropInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPDrop:GetAllSync()

return PVPDrop
