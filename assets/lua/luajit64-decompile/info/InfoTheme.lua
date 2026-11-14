-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTheme.lua

local ThemeData = require("luaData/ThemeData")

InfoTheme = class("InfoTheme", InfoBase)

function InfoTheme:ctor(id)
	self.data = ThemeData[id]
	self.pb = {}
	self.pb.id = id
	self.pb.seats = {}
	self.geted = false
	self.tempSeats = {}
	self.startTime = 0
end

function InfoTheme:SetData(pb)
	self.pb.id = pb.id
	self.pb.seats = pb.seats
	self.pb.surplus = pb.surplus
	self.geted = true
	self.dataTime = Mathf.Floor(NetData:GetCurServerTime() / DateUtil.MillsPerSecond)
	self.startSurplus = pb.surplus
	self.tempSeats = {}

	for i = 1, #pb.seats do
		table.insert(self.tempSeats, pb.seats[i])
	end

	if self:IsFullSeat() then
		ThemeManager:Start(self.id)
	end
end

function InfoTheme:GetSeatInNum()
	local n = 0

	for i = 1, #self.tempSeats do
		local v = self.tempSeats[i]

		if v > 0 then
			n = n + 1
		end
	end

	return n
end

function InfoTheme:IsUnlocked()
	local UnlockLevel = self.data.UnlockLevel
	local UnlockStage = self.data.UnlockStage

	if UnlockLevel <= PlayerInst:GetCurLv() then
		if UnlockStage == 0 then
			return true
		else
			local infoStage = ChapterMgr:GetStage(UnlockStage)

			if infoStage.pb.isPass then
				return true
			end
		end
	end

	return false
end

function InfoTheme:IsFullSeat()
	local seatInNum = self:GetSeatInNum()
	local maxSeatNum = self.data.SeatCount

	return seatInNum == maxSeatNum
end

ThemeManager = {}
ThemeManager.dict = ThemeManager.dict or Record()
ThemeManager.list = nil
ThemeManager.TypeID = 1
ThemeManager.SceneTypeID = 0
ThemeManager.SelectedID = 0
ThemeManager.SelectedIsSave = 0
ThemeManager.isFirstEnterGame = 1
ThemeManager.isShowDetails = false
ThemeManager.surplus = {
	0,
	0,
	0
}

function ThemeManager:Get(id)
	local ret = self.dict:GetValue(id)

	if not ret then
		ret = InfoTheme(id)

		self.dict:Set(id, ret)
	end

	if ret.data == nil then
		print("请检查ThemeData表!!!!!!!!" .. id)
	end

	return ret
end

function ThemeManager:GetAll()
	if self.list then
		return self.list
	end

	self.list = {}

	for i = 1, #ThemeData do
		local info = self:Get(ThemeData[i].ID)

		if ThemeManager.TypeID == 2 and ThemeData[i].ID == ThemeManager.SceneTypeID then
			table.insert(self.list, 1, info)
		elseif ThemeManager.TypeID == 1 and ThemeData[i].ID == PersistentStoreUtil.GetInt(ePSKey.SceneId) then
			table.insert(self.list, 1, info)
		else
			table.insert(self.list, info)
		end
	end

	return self.list
end

function ThemeManager:ClearAll()
	self.list = nil
end

function ThemeManager:GetRoleInSeatList(info)
	local listInSeat = {}
	local listTheme = self:GetAll()

	for i = 1, #listTheme do
		local infoTheme = listTheme[i]
		local listSeat = infoTheme.tempSeats

		for n = 1, #listSeat do
			local seatRoleId = listSeat[n]

			if seatRoleId > 0 then
				table.insert(listInSeat, seatRoleId)
			end
		end
	end

	return listInSeat
end

function ThemeManager:GetInThemeSeat()
	local listInSeat = {}
	local listTheme = self:GetAll()
	local sumCountSeat = 0

	for i = 1, #listTheme do
		local infoTheme = listTheme[i]
		local listSeat = infoTheme.tempSeats

		if infoTheme.geted then
			sumCountSeat = sumCountSeat + #listSeat
		end
	end

	return sumCountSeat
end

function ThemeManager:ProcessRealPos()
	local listTheme = self:GetAll()

	for i = 1, #listTheme do
		local infoTheme = listTheme[i]

		infoTheme.pb.seats = infoTheme.tempSeats
	end
end

function ThemeManager:ClearSeat(roleId)
	local listTheme = self:GetAll()

	for i = 1, #listTheme do
		local listSeat = listTheme[i].tempSeats

		for n = 1, #listSeat do
			if listSeat[n] == roleId then
				listSeat[n] = 0
			end
		end
	end
end

function ThemeManager:GetSceneSelectId()
	local value = PersistentStoreUtil.GetInt(PersistentStoreUtil.KEY_SCENE_SELECT_ID)

	if value == 0 then
		value = 1

		return value
	else
		return value
	end
end

function ThemeManager:SetSceneSelectId(id)
	PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_SCENE_SELECT_ID, id)
end

function ThemeManager:IsDefaultScene(infotheme)
	return infotheme.id == InfoGameInst:GetCurrentTheme()
end

function ThemeManager:IsDefaultSceneNotRole(infotheme)
	return infotheme.id == InfoGameInst:GetCurrentTheme() and self:GetSceneRoleCount(infotheme) == 0
end

function ThemeManager:GetSceneRoleCount(infotheme)
	local SeatIndex = 0

	for i = 1, infotheme.data.SeatCount do
		local id = infotheme.tempSeats[i]

		if id ~= 0 then
			SeatIndex = SeatIndex + 1
		end
	end

	return SeatIndex
end

function ThemeManager:GetSceneIsChange(infotheme)
	local ischange = false
	local count = 0

	for i = 1, 3 do
		for n = 1, 3 do
			if tonumber(infotheme.pb.seats[i]) == tonumber(infotheme.tempSeats[n]) and i == n then
				count = count + 1
			end
		end
	end

	return count ~= 3
end

function ThemeManager:QuitSceneChange(infotheme)
	infotheme.tempSeats = {}

	for i = 1, 3 do
		table.insert(infotheme.tempSeats, infotheme.pb.seats[i])
	end
end

function ThemeManager:GetHaveSceneList(info)
	local count = 0
	local list = {}
	local curIndex = 1

	for i = 1, 3 do
		local infotheme = self:Get(i)

		if infotheme.pb.seats[1] then
			count = count + 1

			if infotheme.id == InfoGameInst:GetCurrentTheme() then
				-- block empty
			end

			table.insert(list, infotheme)
		end
	end

	table.sort(list, function(a, b)
		return a.id < b.id
	end)

	for i = 1, #list do
		if list[i].id == info.id then
			curIndex = i
		end
	end

	return list, count, curIndex
end

function ThemeManager:SetReplaceSceneRoles(info)
	for i = 1, 3 do
		local infotheme = self:Get(i)

		if infotheme.pb.seats[1] and infotheme.id ~= info.id then
			for n = 1, 3 do
				for m = 1, 3 do
					if info.tempSeats[n] == infotheme.tempSeats[m] then
						infotheme.tempSeats[m] = 0
					end
				end
			end
		end
	end
end

function ThemeManager:GetMaxInfoThemeSec(infoTheme)
	local maxSec = infoTheme.data.Minutes[2] * 60

	return maxSec
end

function ThemeManager:GetInfoThemeCount(infoTheme)
	if infoTheme.pb.surplus then
		local listAwardCount = infoTheme.data.BaseReward[1][2]
		local maxItemCount = math.floor(infoTheme.pb.surplus / (infoTheme.data.Minutes[1] * 60)) * listAwardCount

		return maxItemCount
	else
		return 0
	end
end

function ThemeManager:Start(id)
	local infoTheme = self:Get(id)
end

function ThemeManager:UpdateSecond()
	local listTheme = self:GetAll()

	for i = 1, #listTheme do
		local infoTheme = listTheme[i]

		if infoTheme.pb.surplus then
			if infoTheme:IsFullSeat() and infoTheme.pb.surplus < ThemeManager:GetMaxInfoThemeSec(infoTheme) then
				local curTime = Mathf.Floor(NetData:GetCurServerTime() / DateUtil.MillsPerSecond)

				infoTheme.pb.surplus = infoTheme.startSurplus + (curTime - infoTheme.dataTime)

				if infoTheme.pb.surplus >= ThemeManager:GetMaxInfoThemeSec(infoTheme) then
					infoTheme.pb.surplus = ThemeManager:GetMaxInfoThemeSec(infoTheme)
				end
			elseif infoTheme:IsFullSeat() and infoTheme.pb.surplus == ThemeManager:GetMaxInfoThemeSec(infoTheme) and ThemeManager.surplus[i] == 0 then
				ThemeManager.surplus[i] = infoTheme.pb.surplus

				ThemeRDL.AddThemeAward(infoTheme.id)
			end
		end
	end
end

function ThemeManager:SetDlgThemeOpenState()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_DLGTHEME_OPEN_STATE, curServerTime)

	self.DlgThemeOpenState = curServerTime
end

function ThemeManager:GetDlgThemeOpenState()
	if not self.DlgThemeOpenState then
		self.DlgThemeOpenState = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_DLGTHEME_OPEN_STATE)
	end

	if self.DlgThemeOpenState == "" then
		local listTheme = self:GetAll()

		for i = 1, #listTheme do
			local infoTheme = listTheme[i]

			for n = 1, #infoTheme.pb.seats do
				if infoTheme.pb.seats[n] == 0 then
					return true
				end
			end
		end

		return false
	else
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local spaceSeat = false
		local listTheme = self:GetAll()

		for i = 1, #listTheme do
			local infoTheme = listTheme[i]

			for n = 1, #infoTheme.pb.seats do
				if infoTheme.pb.seats[n] == 0 then
					spaceSeat = true
				end
			end
		end

		return curServerTime - tonumber(self.DlgThemeOpenState) > GetConfigArgInt("MainThemeRedPointCD") * 3600 and spaceSeat
	end
end

function ThemeManager:GetDlgThemeOpen()
	if not self.DlgThemeOpenState or self.DlgThemeOpenState == "" then
		return true
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	return curServerTime - tonumber(self.DlgThemeOpenState) > GetConfigArgInt("MainThemeRedPointCD") * 3600
end
