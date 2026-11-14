-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Illustration.lua

local IllustrationInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	IconPath = {
		type = "text"
	},
	ImagePath = {
		type = "text"
	},
	LittleIcon = {
		type = "text"
	},
	Desc = {
		type = "integer"
	},
	RoleId = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	Award = {
		default = "[]",
		type = "array"
	}
}
local IllustrationCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Illustration = {}

function Illustration:GetAllSync()
	if IllustrationCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Illustration", "select * from Illustration")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, IllustrationInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(IllustrationCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	IllustrationCtrl.hasCached = true
	Illustration.GetAllSync = nil
	Illustration.GetAllASync = nil
end

function Illustration:GetAllASync()
	if IllustrationCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Illustration", "select * from Illustration", function()
		local rowsList = SqlLiteSupport.GetCacheData("Illustration")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, IllustrationInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(IllustrationCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		IllustrationCtrl.hasCached = true
		Illustration.GetAllSync = nil
		Illustration.GetAllASync = nil
	end)
end

setmetatable(Illustration, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Illustration", SqlLiteTransfer.GenSql("Illustration", IllustrationCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, IllustrationInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Illustration:GetAllSync()

return Illustration
