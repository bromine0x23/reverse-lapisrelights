-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ActiveUiManage.lua

local ActiveUiManageInfo = {
	ID = {
		type = "integer"
	},
	ActiveID = {
		type = "text"
	},
	GiftBagType = {
		default = "[]",
		type = "array"
	},
	Type = {
		type = "integer"
	},
	Bg = {
		default = "[]",
		type = "array"
	},
	Spine = {
		default = "[]",
		type = "array"
	},
	SpineStatic = {
		default = "[]",
		type = "array"
	},
	Fx = {
		default = "[]",
		type = "array"
	},
	Pic = {
		default = "[]",
		type = "array"
	},
	Text = {
		default = "[]",
		type = "array"
	},
	Video = {
		default = "[]",
		type = "array"
	},
	Vocal = {
		default = "[]",
		type = "array"
	}
}
local ActiveUiManageCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ActiveUiManage = {}

function ActiveUiManage:GetAllSync()
	if ActiveUiManageCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ActiveUiManage", "select * from ActiveUiManage")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveUiManageInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ActiveUiManageCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ActiveUiManageCtrl.hasCached = true
	ActiveUiManage.GetAllSync = nil
	ActiveUiManage.GetAllASync = nil
end

function ActiveUiManage:GetAllASync()
	if ActiveUiManageCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ActiveUiManage", "select * from ActiveUiManage", function()
		local rowsList = SqlLiteSupport.GetCacheData("ActiveUiManage")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveUiManageInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ActiveUiManageCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ActiveUiManageCtrl.hasCached = true
		ActiveUiManage.GetAllSync = nil
		ActiveUiManage.GetAllASync = nil
	end)
end

setmetatable(ActiveUiManage, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ActiveUiManage", SqlLiteTransfer.GenSql("ActiveUiManage", ActiveUiManageCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ActiveUiManageInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ActiveUiManage:GetAllSync()

return ActiveUiManage
