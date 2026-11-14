-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Guideshow.lua

local GuideshowInfo = {
	ID = {
		type = "integer"
	},
	Pic = {
		default = "[]",
		type = "array"
	},
	Popup = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	UnlockShow = {
		default = "[]",
		type = "array"
	},
	NewBieId = {
		type = "integer"
	},
	HelpOrder = {
		type = "integer"
	},
	UnlockHelpShow = {
		type = "integer"
	},
	HomeTitle = {
		type = "integer"
	}
}
local GuideshowCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Guideshow = {}

function Guideshow:GetAllSync()
	if GuideshowCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Guideshow", "select * from Guideshow")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, GuideshowInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(GuideshowCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	GuideshowCtrl.hasCached = true
	Guideshow.GetAllSync = nil
	Guideshow.GetAllASync = nil
end

function Guideshow:GetAllASync()
	if GuideshowCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Guideshow", "select * from Guideshow", function()
		local rowsList = SqlLiteSupport.GetCacheData("Guideshow")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, GuideshowInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(GuideshowCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		GuideshowCtrl.hasCached = true
		Guideshow.GetAllSync = nil
		Guideshow.GetAllASync = nil
	end)
end

setmetatable(Guideshow, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Guideshow", SqlLiteTransfer.GenSql("Guideshow", GuideshowCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, GuideshowInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Guideshow:GetAllSync()

return Guideshow
