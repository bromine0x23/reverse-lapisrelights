-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Terms.lua

local TermsInfo = {
	ID = {
		type = "integer"
	},
	Key = {
		type = "text"
	},
	Value = {
		type = "text"
	}
}
local TermsCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Terms = {}

function Terms:GetAllSync()
	if TermsCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Terms", "select * from Terms")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, TermsInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(TermsCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	TermsCtrl.hasCached = true
	Terms.GetAllSync = nil
	Terms.GetAllASync = nil
end

function Terms:GetAllASync()
	if TermsCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Terms", "select * from Terms", function()
		local rowsList = SqlLiteSupport.GetCacheData("Terms")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, TermsInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(TermsCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		TermsCtrl.hasCached = true
		Terms.GetAllSync = nil
		Terms.GetAllASync = nil
	end)
end

setmetatable(Terms, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Terms", SqlLiteTransfer.GenSql("Terms", TermsCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, TermsInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Terms:GetAllSync()

return Terms
