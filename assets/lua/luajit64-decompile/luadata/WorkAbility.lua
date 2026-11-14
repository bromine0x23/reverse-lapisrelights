-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/WorkAbility.lua

local WorkAbilityInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	Npc = {
		type = "text"
	}
}
local WorkAbilityCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local WorkAbility = {}

function WorkAbility:GetAllSync()
	if WorkAbilityCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("WorkAbility", "select * from WorkAbility")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, WorkAbilityInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(WorkAbilityCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	WorkAbilityCtrl.hasCached = true
	WorkAbility.GetAllSync = nil
	WorkAbility.GetAllASync = nil
end

function WorkAbility:GetAllASync()
	if WorkAbilityCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("WorkAbility", "select * from WorkAbility", function()
		local rowsList = SqlLiteSupport.GetCacheData("WorkAbility")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, WorkAbilityInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(WorkAbilityCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		WorkAbilityCtrl.hasCached = true
		WorkAbility.GetAllSync = nil
		WorkAbility.GetAllASync = nil
	end)
end

setmetatable(WorkAbility, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("WorkAbility", SqlLiteTransfer.GenSql("WorkAbility", WorkAbilityCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, WorkAbilityInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
WorkAbility:GetAllSync()

return WorkAbility
