-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/EffectData.lua

local EffectDataInfo = {
	ID = {
		type = "integer"
	},
	Prefab = {
		type = "text"
	},
	SoundEvent = {
		type = "text"
	},
	SoundBank = {
		type = "text"
	},
	Life = {
		default = "1",
		type = "float"
	},
	DelayFree = {
		default = "0",
		type = "float"
	},
	IsChild = {
		type = "integer"
	},
	BindSlot = {
		type = "text"
	},
	BindSlot_Boss = {
		type = "text"
	}
}
local EffectDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local EffectData = {}

function EffectData:GetAllSync()
	if EffectDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("EffectData", "select * from EffectData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, EffectDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(EffectDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	EffectDataCtrl.hasCached = true
	EffectData.GetAllSync = nil
	EffectData.GetAllASync = nil
end

function EffectData:GetAllASync()
	if EffectDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("EffectData", "select * from EffectData", function()
		local rowsList = SqlLiteSupport.GetCacheData("EffectData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, EffectDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(EffectDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		EffectDataCtrl.hasCached = true
		EffectData.GetAllSync = nil
		EffectData.GetAllASync = nil
	end)
end

setmetatable(EffectData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("EffectData", SqlLiteTransfer.GenSql("EffectData", EffectDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, EffectDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
EffectData:GetAllASync()

return EffectData
