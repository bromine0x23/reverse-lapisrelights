-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_platform_achievement.lua

local m_platform_achievementInfo = {
	id = {
		type = "integer"
	},
	key = {
		type = "text"
	},
	category = {
		type = "text"
	},
	score = {
		type = "integer"
	}
}
local m_platform_achievementCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_platform_achievement = {}

function m_platform_achievement:GetAllSync()
	if m_platform_achievementCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_platform_achievement", "select * from m_platform_achievement")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_platform_achievementInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_platform_achievementCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_platform_achievementCtrl.hasCached = true
	m_platform_achievement.GetAllSync = nil
	m_platform_achievement.GetAllASync = nil
end

function m_platform_achievement:GetAllASync()
	if m_platform_achievementCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_platform_achievement", "select * from m_platform_achievement", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_platform_achievement")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_platform_achievementInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_platform_achievementCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_platform_achievementCtrl.hasCached = true
		m_platform_achievement.GetAllSync = nil
		m_platform_achievement.GetAllASync = nil
	end)
end

setmetatable(m_platform_achievement, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_platform_achievement", SqlLiteTransfer.GenSql("m_platform_achievement", m_platform_achievementCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_platform_achievementInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_platform_achievement:GetAllSync()

return m_platform_achievement
