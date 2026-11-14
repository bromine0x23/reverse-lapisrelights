-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ClubMirrorEvent.lua

local ClubMirrorEventInfo = {
	ID = {
		type = "integer"
	},
	MirrorId = {
		type = "integer"
	},
	MaxCount = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	TypeValue = {
		default = "[]",
		type = "array"
	},
	AddPoint = {
		default = "[]",
		type = "array"
	},
	Contribution = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Prompt = {
		default = "[]",
		type = "array"
	}
}
local ClubMirrorEventCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ClubMirrorEvent = {}

function ClubMirrorEvent:GetAllSync()
	if ClubMirrorEventCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ClubMirrorEvent", "select * from ClubMirrorEvent")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubMirrorEventInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ClubMirrorEventCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ClubMirrorEventCtrl.hasCached = true
	ClubMirrorEvent.GetAllSync = nil
	ClubMirrorEvent.GetAllASync = nil
end

function ClubMirrorEvent:GetAllASync()
	if ClubMirrorEventCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ClubMirrorEvent", "select * from ClubMirrorEvent", function()
		local rowsList = SqlLiteSupport.GetCacheData("ClubMirrorEvent")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubMirrorEventInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ClubMirrorEventCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ClubMirrorEventCtrl.hasCached = true
		ClubMirrorEvent.GetAllSync = nil
		ClubMirrorEvent.GetAllASync = nil
	end)
end

setmetatable(ClubMirrorEvent, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ClubMirrorEvent", SqlLiteTransfer.GenSql("ClubMirrorEvent", ClubMirrorEventCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ClubMirrorEventInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ClubMirrorEvent:GetAllSync()

return ClubMirrorEvent
