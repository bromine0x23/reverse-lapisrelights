-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTitle.lua

local ItemData = require("luaData.ItemData")
local CharacterData = require("luaData.CharacterRole")
local InfoTitle = {}

function InfoTitle:SetData(headList, headFrameList, medals)
	self.headList = headList
	self.headFrameList = headFrameList
	self.medals = medals
	self.titleDataList = {}
	self.headFrameDataList = {}
	self.headDataList = {}

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k, v in pairsByKeys(ItemData) do
		local isShow = true

		if v.ItemShowTime ~= "" then
			local overTime = GetTimeTampByString(v.ItemShowTime)

			if curServerTime < overTime then
				isShow = false
			end
		end

		if isShow then
			if v.Type == "P_MEDAL" then
				table.insert(self.titleDataList, v)
			elseif v.Type == "P_HEAD_FRAME" then
				table.insert(self.headFrameDataList, v)
			elseif v.Type == "P_HEAD" then
				table.insert(self.headDataList, v)
			end
		end
	end

	local function sortFun(a, b)
		return a.Priority < b.Priority
	end

	table.sort(self.titleDataList, sortFun)
	table.sort(self.headFrameDataList, sortFun)
	table.sort(self.headDataList, sortFun)
end

function InfoTitle:GetHeadData()
	local list = {}

	local function listSort(a, b)
		return a.lockState < b.lockState
	end

	for i, v in ipairs(self.headDataList) do
		local data = {}

		data.cfg = v
		data.lockState = IndexOf(InfoTitle.headList, v.ID) ~= nil and 1 or 2

		table.insert(list, data)
	end

	table.sort(list, listSort)

	return list
end

function InfoTitle:GetHeadFrameData()
	local list = {}

	local function listSort(a, b)
		return a.lockState < b.lockState
	end

	for i, v in ipairs(self.headFrameDataList) do
		local data = {}

		data.cfg = v
		data.lockState = IndexOf(InfoTitle.headFrameList, v.ID) ~= nil and 1 or 2

		table.insert(list, data)
	end

	table.sort(list, listSort)

	return list
end

function InfoTitle:GetTitleData()
	local list = {}

	local function listSort(a, b)
		return a.lockState < b.lockState
	end

	for i, v in ipairs(self.titleDataList) do
		local data = {}

		data.cfg = v

		local medalKey = IndexAndKeyOf(InfoTitle.medals, "id", v.ID)

		if medalKey then
			data.lockState = 1
			data.endTime = InfoTitle.medals[medalKey].endTime
		else
			data.lockState = 2
		end

		table.insert(list, data)
	end

	table.sort(list, listSort)

	return list
end

function InfoTitle:GetMedalsProgress()
	local curCount = #self.medals
	local totalCount = #self.titleDataList
	local progress = TenaryOp(curCount / totalCount > 1, 1, curCount / totalCount)

	return progress
end

function InfoTitle:AddTitle(s)
	local key = IndexAndKeyOf(self.medals, "id", s.id)

	if key == nil then
		local data = {
			id = s.id,
			endTime = s.extra[1]
		}

		table.insert(self.medals, data)
		TitleRDL.AddPlayerPrefs(PLAYER_TITLE_TYPE.Medal)
	else
		local data = self.medals[key]

		data.endTime = s.extra[1]
	end
end

function InfoTitle:AddHeadFrame(s)
	table.insert(self.headFrameList, s.id)
	TitleRDL.AddPlayerPrefs(PLAYER_TITLE_TYPE.Frame)
end

function InfoTitle:AddHead(s)
	table.insert(self.headList, s.id)
	TitleRDL.AddPlayerPrefs(PLAYER_TITLE_TYPE.Head)
end

function InfoTitle:TitleIsHaveTime(id)
	local key = IndexAndKeyOf(self.medals, "id", id)

	if key ~= nil then
		local data = self.medals[key]

		if data.endTime == 0 then
			return true
		else
			local time = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			if time < data.endTime then
				return true
			end
		end
	end

	return false
end

function InfoTitle:TitleIsUnlock(id)
	local key = IndexAndKeyOf(self.medals, "id", id)

	if key ~= nil then
		local data = self.medals[key]

		if data.lockState == 1 then
			return true
		end
	end

	return false
end

function InfoTitle:UpdateItemLock()
	self.titleDataList = {}
	self.headFrameDataList = {}
	self.headDataList = {}

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k, v in pairsByKeys(ItemData) do
		local isShow = true

		if v.ItemShowTime ~= "" then
			local overTime = GetTimeTampByString(v.ItemShowTime)

			if curServerTime < overTime then
				isShow = false
			end
		end

		if isShow then
			if v.Type == "P_MEDAL" then
				table.insert(self.titleDataList, v)
			elseif v.Type == "P_HEAD_FRAME" then
				table.insert(self.headFrameDataList, v)
			elseif v.Type == "P_HEAD" then
				table.insert(self.headDataList, v)
			end
		end
	end

	local function sortFun(a, b)
		return a.Priority < b.Priority
	end

	table.sort(self.titleDataList, sortFun)
	table.sort(self.headFrameDataList, sortFun)
	table.sort(self.headDataList, sortFun)
end

return InfoTitle
