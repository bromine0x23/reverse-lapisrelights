-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ClubJob.lua

local ClubJobInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	}
}
local ClubJobCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ClubJob = {}

function ClubJob:GetAllSync()
	if ClubJobCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ClubJob", "select * from ClubJob")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubJobInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ClubJobCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ClubJobCtrl.hasCached = true
	ClubJob.GetAllSync = nil
	ClubJob.GetAllASync = nil
end

function ClubJob:GetAllASync()
	if ClubJobCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ClubJob", "select * from ClubJob", function()
		local rowsList = SqlLiteSupport.GetCacheData("ClubJob")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubJobInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ClubJobCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ClubJobCtrl.hasCached = true
		ClubJob.GetAllSync = nil
		ClubJob.GetAllASync = nil
	end)
end

setmetatable(ClubJob, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ClubJob", SqlLiteTransfer.GenSql("ClubJob", ClubJobCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ClubJobInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ClubJob:GetAllSync()

return ClubJob
