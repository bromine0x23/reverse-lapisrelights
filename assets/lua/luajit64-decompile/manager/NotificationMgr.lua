-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/NotificationMgr.lua

eNotificationType = {
	CompleteWork = 3,
	FullPower = 1,
	CanGetPower = 2
}
eNotificationTags = {
	CanGetPower = "CanGetPower"
}

local PushConfig = require("luaData/PushConfig")

NotificationMgr = class("NotificationMgr")
NotificationMgr.Setting = "NotificationSetting.Type"
NotificationMgr.TimeHistory = "NotificationMgrTimeHistory"
NotificationMgr.NumHistory = "NotificationMgrNumHistory"
NotificationMgr.EventWork = "NotificationMgrEventWork"

function NotificationMgr:Init()
	if self.isInit then
		return
	end

	NotificationSender.Init(NotificationMgr.CallBcak)
	NotificationSender.InitPush()

	self.index = 0
	self.lastPower = PlayerInst:GetPower()
	self.notificationList = {}
	self.senderHistory = {}

	for _, type in pairs(eNotificationType) do
		self.notificationList[type] = {}
		self.senderHistory[type] = {}
		self.senderHistory[type].time = PersistentStoreUtil.GetInt(NotificationMgr.TimeHistory .. type)
		self.senderHistory[type].num = PersistentStoreUtil.GetInt(NotificationMgr.NumHistory .. type)

		if self:CheckState(type) then
			self:EditNotification(type)
		end
	end

	self:RegisterEvent()

	self.isInit = true
end

function NotificationMgr:GetPermission()
	return NotificationSender.GetPermission()
end

function NotificationMgr:RegisterEvent()
	Event.Instance:Add(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
end

function NotificationMgr:NotifyUpdate()
	if PlayerInst:GetPower() ~= self.lastPower then
		self.lastPower = PlayerInst:GetPower()

		self:ChangeSetting(eNotificationType.FullPower)
	end
end

function NotificationMgr:CheckState(type)
	local permission = self:GetPermission()

	if not permission then
		return false
	end

	local key = NotificationMgr.Setting .. type
	local result = PersistentStoreUtil.GetInt(key)

	if result == 0 then
		return permission
	end

	if result == 1 then
		return true
	else
		return false
	end
end

function NotificationMgr:ChangeSetting(type)
	self:RemoveNotification(type)

	if self:CheckState(type) then
		self:EditNotification(type)
	elseif type == eNotificationType.CanGetPower then
		NotificationSender.DeleteTags({
			eNotificationTags.CanGetPower
		})
	end
end

function NotificationMgr:CheckCondition(info)
	if info.data.MobilePhoneType == 0 then
		-- block empty
	elseif info.data.MobilePhoneType == 1 and Application.platform:ToInt() == RuntimePlatform.Android then
		return false
	elseif info.data.MobilePhoneType == 2 and Application.platform:ToInt() ~= RuntimePlatform.Android then
		return false
	end

	if info.data.PushInterval ~= 0 then
		print("[Push]===============前回送信時間は" .. self.senderHistory[info.type].time)

		if self.senderHistory[info.type].time > 0 and info.time - self.senderHistory[info.type].time < info.data.PushInterval then
			print("[Push]===============最小間隔1を満たしてません")

			return false
		end

		for key, value in pairs(self.notificationList[info.type]) do
			if value ~= nil and info.time - value.time < info.data.PushInterval then
				print("[Push]===============最小間隔2を満たしてません")

				return false
			end
		end
	end

	if info.data.MixPushTime ~= "" and info.data.MaxPushTime ~= "" then
		local min = string.split(info.data.MixPushTime, ":")
		local max = string.split(info.data.MaxPushTime, ":")
		local minTime = tonumber(min[1]) * 100 + tonumber(min[1])
		local maxTime = tonumber(max[1]) * 100 + tonumber(max[1])
		local d, h, m, s = GetTimeFormatBySec(info.time)
		local nowTime = h * 100 + m

		if nowTime < minTime or maxTime < nowTime then
			print("[Push]===============送信時間帯ではありません")

			return false
		end
	end

	if info.data.Daylimit > 0 and self.senderHistory[info.type].time > 0 then
		if not TimeIsNotToday(self.senderHistory[info.type].time * 1000) then
			print("[Push]===============同日")

			if self.senderHistory[info.type].num >= info.data.Daylimit then
				return false
			end
		else
			print("[Push]===============同日ではありません")

			self.senderHistory[info.type].num = 0

			PersistentStoreUtil.SetInt(NotificationMgr.NumHistory .. info.type, 0)
		end
	end

	return true
end

function NotificationMgr:GetDataByType(type)
	if type == eNotificationType.FullPower then
		return PushConfig[3]
	elseif type == eNotificationType.CompleteWork then
		return PushConfig[4]
	end

	return nil
end

function NotificationMgr:EditNotification(type, workIndex)
	self.index = self.index + 1

	local title = ""
	local text = ""
	local time = 0
	local focusShow = false
	local icon = ""
	local data = self:GetDataByType(type)

	if data ~= nil then
		title = Lang(data.Title)
		text = Lang(data.Content)
		focusShow = false
		icon = data.PushIcon
	end

	for key, value in pairs(self.notificationList[type]) do
		if value ~= nil and value.time <= Mathf.Floor(NetData:GetCurServerTime() / 1000) then
			self.notificationList[type][key] = nil
		end
	end

	if type == eNotificationType.CanGetPower then
		NotificationSender.ClearAndAppendTags({
			eNotificationTags.CanGetPower
		})

		return
	elseif type == eNotificationType.FullPower then
		time = PowerMgr.Instance:GetFullTime()

		if #self.notificationList[eNotificationType.FullPower] > 0 and self.notificationList[eNotificationType.FullPower][1].time == time then
			return
		end
	elseif type == eNotificationType.CompleteWork then
		local infoGroup = WorkMgr:GetWorkListByState(eWorkStateType.Picked)
		local dataGroup = {}

		for _, value in pairs(infoGroup) do
			if value.pb.endTime > Mathf.Floor(NetData:GetCurServerTime() / 1000) then
				table.insert(dataGroup, value.pb.endTime)
			end
		end

		table.sort(dataGroup, function(a, b)
			return a < b
		end)

		if workIndex ~= nil and workIndex > 0 then
			time = dataGroup[workIndex]
		else
			for index, value in ipairs(dataGroup) do
				self:EditNotification(eNotificationType.CompleteWork, index)
			end

			return
		end
	end

	if time == 0 then
		return
	end

	local info = {}

	info.data = data
	info.index = self.index
	info.type = type
	info.time = time

	if not self:CheckCondition(info) then
		return
	end

	NotificationSender.SendNotification(self.index, type, title, text, time, focusShow, icon)
	table.insert(self.notificationList[type], info)
end

function NotificationMgr:RemoveNotification(type)
	if not self.notificationList then
		return
	end

	for key, value in pairs(self.notificationList[type]) do
		NotificationSender.RemoveNotification(value.index)
	end

	self.notificationList[type] = {}
end

function NotificationMgr:RemoveAll()
	self.notificationList = {}

	NotificationSender.RemoveAll()
end

function NotificationMgr.CallBcak(index, type, time)
	if index > 0 then
		for key, value in pairs(NotificationMgr.Instance.notificationList[type]) do
			if value.index == index then
				NotificationMgr.Instance.notificationList[type][key] = nil
			end
		end

		local num = NotificationMgr.Instance.senderHistory[type].num

		NotificationMgr.Instance.senderHistory[type].num = num + 1

		PersistentStoreUtil.SetInt(NotificationMgr.NumHistory .. type, num + 1)

		if time > NotificationMgr.Instance.senderHistory[type].time then
			NotificationMgr.Instance.senderHistory[type].time = time
		end

		PersistentStoreUtil.SetInt(NotificationMgr.TimeHistory .. type, time)
	end
end

NotificationMgr.Instance = NotificationMgr.Instance or NotificationMgr()
