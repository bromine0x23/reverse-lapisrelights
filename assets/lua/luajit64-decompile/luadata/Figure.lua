-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Figure.lua

local FigureInfo = {
	ID = {
		type = "integer"
	},
	figureId = {
		default = "[]",
		type = "array"
	},
	condition = {
		default = "[]",
		type = "array"
	},
	PageIndex = {
		type = "integer"
	},
	ItemNeed = {
		default = "[]",
		type = "array"
	},
	Reward = {
		default = "[]",
		type = "array"
	},
	type = {
		type = "integer"
	},
	roleId = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Desc = {
		type = "integer"
	},
	IconPath = {
		type = "text"
	},
	IconPos = {
		default = "[]",
		type = "array"
	}
}
local FigureCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Figure = {}

function Figure:GetAllSync()
	if FigureCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Figure", "select * from Figure")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, FigureInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(FigureCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	FigureCtrl.hasCached = true
	Figure.GetAllSync = nil
	Figure.GetAllASync = nil
end

function Figure:GetAllASync()
	if FigureCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Figure", "select * from Figure", function()
		local rowsList = SqlLiteSupport.GetCacheData("Figure")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, FigureInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(FigureCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		FigureCtrl.hasCached = true
		Figure.GetAllSync = nil
		Figure.GetAllASync = nil
	end)
end

setmetatable(Figure, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Figure", SqlLiteTransfer.GenSql("Figure", FigureCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, FigureInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Figure:GetAllSync()

return Figure
