-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/SqlLiteTransfer.lua

SqlLiteTransfer = {}

function SqlLiteTransfer.TransferFromJson(jsonStr, dataStruct)
	local contentArr = string.splitEx(jsonStr, ",,,")
	local luaObj = {}

	for i = 1, #contentArr, 2 do
		local key = contentArr[i]
		local v = contentArr[i + 1]
		local tp = dataStruct[key].type

		if tp == "text" or tp == "base64" then
			luaObj[key] = tostring(v)
		elseif tp == "integer" or tp == "float" or tp == "long" then
			luaObj[key] = tonumber(v)
		elseif not v or v == "" then
			luaObj[key] = {}
		else
			local result = pcall(function()
				luaObj[key] = loadstring("return" .. v)()
			end)

			if not result then
				print("<color=red>[ErrorKey In Sqlite]</color>" .. key .. ":" .. v)

				luaObj[key] = {}
			end
		end
	end

	return luaObj
end

function SqlLiteTransfer.GetKeyWord(ctrl, data)
	local keyWord = ""

	for i = 1, ctrl.keyWordNum do
		local real_keyword = ""

		if i <= 1 then
			real_keyword = data[ctrl.keyWord]
			keyWord = real_keyword
		else
			real_keyword = data[ctrl["keyWord" .. i]]
			keyWord = keyWord .. "+" .. real_keyword
		end
	end

	return keyWord
end

function SqlLiteTransfer.GenSql(tbName, ctrl, vals)
	if ctrl.keyWordNum <= 1 then
		return "select * from " .. tbName .. " where " .. ctrl.keyWord .. " = " .. vals
	else
		local retSql = "select * from " .. tbName .. " where "
		local valArr = string.split(vals, "+")

		for i = 1, ctrl.keyWordNum do
			if i == 1 then
				retSql = retSql .. ctrl.keyWord .. " = " .. valArr[i]
			else
				retSql = retSql .. " and " .. ctrl["keyWord" .. i] .. " = " .. valArr[i]
			end
		end

		return retSql
	end
end
