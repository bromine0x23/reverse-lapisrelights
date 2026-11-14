-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SessionData.lua

local SessionDataInfo = {
	ID = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	SpecialIcon = {
		type = "text"
	},
	BigIcon = {
		type = "text"
	},
	BGIcon = {
		type = "text"
	},
	PoseStateName = {
		type = "text"
	},
	PoseStateHitTime = {
		type = "float"
	},
	PoseStateWaitTime = {
		type = "float"
	},
	SkillId = {
		type = "text"
	},
	PoseFx = {
		type = "text"
	},
	AnimState = {
		type = "text"
	},
	UIMoveFx = {
		type = "text"
	},
	WaitTime = {
		type = "float"
	},
	Session1P = {
		default = "[]",
		type = "array"
	},
	Session2P = {
		default = "[]",
		type = "array"
	},
	Session3P = {
		default = "[]",
		type = "array"
	},
	Session4P = {
		default = "[]",
		type = "array"
	},
	Session1PFx = {
		default = "[]",
		type = "array"
	},
	Session2PFx = {
		default = "[]",
		type = "array"
	},
	Session3PFx = {
		default = "[]",
		type = "array"
	},
	Session4PFx = {
		default = "[]",
		type = "array"
	}
}
local SessionDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SessionData = {}

function SessionData:GetAllSync()
	if SessionDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SessionData", "select * from SessionData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SessionDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SessionDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SessionDataCtrl.hasCached = true
	SessionData.GetAllSync = nil
	SessionData.GetAllASync = nil
end

function SessionData:GetAllASync()
	if SessionDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SessionData", "select * from SessionData", function()
		local rowsList = SqlLiteSupport.GetCacheData("SessionData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SessionDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SessionDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SessionDataCtrl.hasCached = true
		SessionData.GetAllSync = nil
		SessionData.GetAllASync = nil
	end)
end

setmetatable(SessionData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SessionData", SqlLiteTransfer.GenSql("SessionData", SessionDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SessionDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SessionData:GetAllSync()

return SessionData
