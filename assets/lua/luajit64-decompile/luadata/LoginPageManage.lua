-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/LoginPageManage.lua

local LoginPageManageInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	RelevanceActive = {
		default = "[]",
		type = "array"
	},
	StartTime = {
		type = "text"
	},
	EndTime = {
		type = "text"
	},
	TimePos = {
		default = "[]",
		type = "array"
	},
	Resource = {
		type = "text"
	}
}
local LoginPageManageCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local LoginPageManage = {}

function LoginPageManage:GetAllSync()
	if LoginPageManageCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("LoginPageManage", "select * from LoginPageManage")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, LoginPageManageInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(LoginPageManageCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	LoginPageManageCtrl.hasCached = true
	LoginPageManage.GetAllSync = nil
	LoginPageManage.GetAllASync = nil
end

function LoginPageManage:GetAllASync()
	if LoginPageManageCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("LoginPageManage", "select * from LoginPageManage", function()
		local rowsList = SqlLiteSupport.GetCacheData("LoginPageManage")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, LoginPageManageInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(LoginPageManageCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		LoginPageManageCtrl.hasCached = true
		LoginPageManage.GetAllSync = nil
		LoginPageManage.GetAllASync = nil
	end)
end

setmetatable(LoginPageManage, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("LoginPageManage", SqlLiteTransfer.GenSql("LoginPageManage", LoginPageManageCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, LoginPageManageInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
LoginPageManage:GetAllSync()

return LoginPageManage
