-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/MotionControllerData.lua

local MotionControllerDataInfo = {
	ID = {
		type = "integer"
	},
	Actor = {
		type = "integer"
	},
	Avatar = {
		default = "[]",
		type = "array"
	},
	Category = {
		type = "text"
	},
	MotionGroup = {
		type = "text"
	},
	AnimationController = {
		type = "text"
	},
	Overrides = {
		default = "[]",
		type = "array"
	}
}
local MotionControllerDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local MotionControllerData = {}

function MotionControllerData:GetAllSync()
	if MotionControllerDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("MotionControllerData", "select * from MotionControllerData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, MotionControllerDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(MotionControllerDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	MotionControllerDataCtrl.hasCached = true
	MotionControllerData.GetAllSync = nil
	MotionControllerData.GetAllASync = nil
end

function MotionControllerData:GetAllASync()
	if MotionControllerDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("MotionControllerData", "select * from MotionControllerData", function()
		local rowsList = SqlLiteSupport.GetCacheData("MotionControllerData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, MotionControllerDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(MotionControllerDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		MotionControllerDataCtrl.hasCached = true
		MotionControllerData.GetAllSync = nil
		MotionControllerData.GetAllASync = nil
	end)
end

setmetatable(MotionControllerData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("MotionControllerData", SqlLiteTransfer.GenSql("MotionControllerData", MotionControllerDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, MotionControllerDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
MotionControllerData:GetAllSync()

return MotionControllerData
