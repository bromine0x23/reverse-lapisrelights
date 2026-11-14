-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/JobCheckingData.lua

local JobCheckingDataInfo = {
	ID = {
		type = "integer"
	},
	Job = {
		default = "[]",
		type = "array"
	},
	Mul = {
		type = "float"
	},
	PVPMul = {
		type = "float"
	}
}
local JobCheckingDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local JobCheckingData = {}

function JobCheckingData:GetAllSync()
	if JobCheckingDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("JobCheckingData", "select * from JobCheckingData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, JobCheckingDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(JobCheckingDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	JobCheckingDataCtrl.hasCached = true
	JobCheckingData.GetAllSync = nil
	JobCheckingData.GetAllASync = nil
end

function JobCheckingData:GetAllASync()
	if JobCheckingDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("JobCheckingData", "select * from JobCheckingData", function()
		local rowsList = SqlLiteSupport.GetCacheData("JobCheckingData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, JobCheckingDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(JobCheckingDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		JobCheckingDataCtrl.hasCached = true
		JobCheckingData.GetAllSync = nil
		JobCheckingData.GetAllASync = nil
	end)
end

setmetatable(JobCheckingData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("JobCheckingData", SqlLiteTransfer.GenSql("JobCheckingData", JobCheckingDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, JobCheckingDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
JobCheckingData:GetAllSync()

return JobCheckingData
