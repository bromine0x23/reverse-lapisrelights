-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Newbie.lua

local NewbieInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		default = "0",
		type = "integer"
	},
	Function = {
		type = "integer"
	},
	ShowTips = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	Level = {
		default = "0",
		type = "integer"
	},
	Stage = {
		default = "0",
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	NavigationType = {
		type = "integer"
	},
	NavigationPriority = {
		type = "integer"
	},
	NavigationBar = {
		default = "[]",
		type = "array"
	},
	NavigationFinish = {
		default = "[]",
		type = "array"
	},
	NavigationGift = {
		type = "integer"
	},
	NavigationBuff = {
		default = "[]",
		type = "array"
	},
	NavigationItem = {
		type = "integer"
	},
	FromWhere = {
		default = "[]",
		type = "array"
	}
}
local NewbieCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Newbie = {}

function Newbie:GetAllSync()
	if NewbieCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Newbie", "select * from Newbie")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, NewbieInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(NewbieCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	NewbieCtrl.hasCached = true
	Newbie.GetAllSync = nil
	Newbie.GetAllASync = nil
end

function Newbie:GetAllASync()
	if NewbieCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Newbie", "select * from Newbie", function()
		local rowsList = SqlLiteSupport.GetCacheData("Newbie")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, NewbieInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(NewbieCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		NewbieCtrl.hasCached = true
		Newbie.GetAllSync = nil
		Newbie.GetAllASync = nil
	end)
end

setmetatable(Newbie, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Newbie", SqlLiteTransfer.GenSql("Newbie", NewbieCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, NewbieInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Newbie:GetAllSync()

return Newbie
