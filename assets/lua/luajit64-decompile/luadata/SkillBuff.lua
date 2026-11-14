-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SkillBuff.lua

local SkillBuffInfo = {
	ID = {
		type = "integer"
	},
	ShowType = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Description = {
		type = "integer"
	},
	Type = {
		default = "[]",
		type = "array"
	},
	BeginTime = {
		type = "text"
	},
	EndTime = {
		type = "text"
	},
	SkillID = {
		type = "integer"
	},
	Params = {
		default = "[]",
		type = "array"
	}
}
local SkillBuffCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SkillBuff = {}

function SkillBuff:GetAllSync()
	if SkillBuffCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SkillBuff", "select * from SkillBuff")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SkillBuffInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SkillBuffCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SkillBuffCtrl.hasCached = true
	SkillBuff.GetAllSync = nil
	SkillBuff.GetAllASync = nil
end

function SkillBuff:GetAllASync()
	if SkillBuffCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SkillBuff", "select * from SkillBuff", function()
		local rowsList = SqlLiteSupport.GetCacheData("SkillBuff")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SkillBuffInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SkillBuffCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SkillBuffCtrl.hasCached = true
		SkillBuff.GetAllSync = nil
		SkillBuff.GetAllASync = nil
	end)
end

setmetatable(SkillBuff, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SkillBuff", SqlLiteTransfer.GenSql("SkillBuff", SkillBuffCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SkillBuffInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SkillBuff:GetAllSync()

return SkillBuff
