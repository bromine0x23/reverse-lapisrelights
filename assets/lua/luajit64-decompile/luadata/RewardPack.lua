-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/RewardPack.lua

local RewardPackInfo = {
	ID = {
		type = "integer"
	},
	PackItem = {
		default = "[]",
		type = "array"
	},
	ItemList = {
		default = "[]",
		type = "array"
	},
	DropGroupList = {
		default = "[[]]",
		type = "array"
	},
	ExtraReward = {
		type = "integer"
	}
}
local RewardPackCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local RewardPack = {}

function RewardPack:GetAllSync()
	if RewardPackCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("RewardPack", "select * from RewardPack")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, RewardPackInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(RewardPackCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	RewardPackCtrl.hasCached = true
	RewardPack.GetAllSync = nil
	RewardPack.GetAllASync = nil
end

function RewardPack:GetAllASync()
	if RewardPackCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("RewardPack", "select * from RewardPack", function()
		local rowsList = SqlLiteSupport.GetCacheData("RewardPack")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, RewardPackInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(RewardPackCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		RewardPackCtrl.hasCached = true
		RewardPack.GetAllSync = nil
		RewardPack.GetAllASync = nil
	end)
end

setmetatable(RewardPack, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("RewardPack", SqlLiteTransfer.GenSql("RewardPack", RewardPackCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, RewardPackInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
RewardPack:GetAllSync()

return RewardPack
