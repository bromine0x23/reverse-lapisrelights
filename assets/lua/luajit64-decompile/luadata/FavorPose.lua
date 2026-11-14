-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/FavorPose.lua

local FavorPoseInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	Character = {
		type = "integer"
	},
	FavorLevel = {
		type = "integer"
	},
	Pose = {
		type = "text"
	}
}
local FavorPoseCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local FavorPose = {}

function FavorPose:GetAllSync()
	if FavorPoseCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("FavorPose", "select * from FavorPose")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, FavorPoseInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(FavorPoseCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	FavorPoseCtrl.hasCached = true
	FavorPose.GetAllSync = nil
	FavorPose.GetAllASync = nil
end

function FavorPose:GetAllASync()
	if FavorPoseCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("FavorPose", "select * from FavorPose", function()
		local rowsList = SqlLiteSupport.GetCacheData("FavorPose")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, FavorPoseInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(FavorPoseCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		FavorPoseCtrl.hasCached = true
		FavorPose.GetAllSync = nil
		FavorPose.GetAllASync = nil
	end)
end

setmetatable(FavorPose, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("FavorPose", SqlLiteTransfer.GenSql("FavorPose", FavorPoseCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, FavorPoseInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
FavorPose:GetAllSync()

return FavorPose
