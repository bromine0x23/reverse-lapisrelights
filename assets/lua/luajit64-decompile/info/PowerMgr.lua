-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/PowerMgr.lua

PowerMgr = class("PowerMgr")

function PowerMgr:ctor()
	self.MaxLimit = GetConfigArgInt("PowerMax")
	self.RecoverTime = GetConfigArgInt("PowerAddTime")
	self.LastCalcPowerTime = nil
	self.LeftTime = 0
end

function PowerMgr:SetPowerTime(lastCalcPowerTime)
	self.LastCalcPowerTime = tonumber(lastCalcPowerTime)

	self:TryRecoverPower()
end

function PowerMgr:GetNextRecoverTimeStr()
	local str = DateUtil.GetMoment00(self.LeftTime)

	return str
end

function PowerMgr:TryRecoverPower()
	local curPower = PlayerInst:GetPower()
	local maxPower = PlayerInst.InfoPlayer.maxPower

	if maxPower <= curPower then
		self.LeftTime = 0

		return
	end

	local serverTime = NetData:GetCurServerTime()

	if serverTime <= self.LastCalcPowerTime then
		return
	end

	local second = (serverTime - self.LastCalcPowerTime) / DateUtil.MillsPerSecond
	local addPowerNum = Mathf.Floor(second / self.RecoverTime)

	self.LeftTime = self.RecoverTime - Mathf.Floor(second)

	local finalPower = curPower + addPowerNum

	if maxPower <= finalPower then
		self.LastCalcPowerTime = serverTime
		addPowerNum = maxPower - curPower
	else
		self.LastCalcPowerTime = self.LastCalcPowerTime + addPowerNum * self.RecoverTime * DateUtil.MillsPerSecond
	end

	if addPowerNum > 0 then
		PlayerInst:ChangePower(addPowerNum)
		Event.Instance:Fire(EventEnum.UpdatePlayerInfo)
	end

	Event.Instance:Fire(EventEnum.UpdatePowerRecoverTime, self.LeftTime)
end

function PowerMgr:GetFullTime()
	local fullTime = 0
	local curPower = PlayerInst:GetPower()
	local maxPower = PlayerInst.InfoPlayer.maxPower

	if maxPower <= curPower then
		fullTime = 0

		return fullTime
	end

	local serverTime = NetData:GetCurServerTime()

	if serverTime <= self.LastCalcPowerTime then
		return fullTime
	end

	local second = (serverTime - self.LastCalcPowerTime) / DateUtil.MillsPerSecond
	local addPowerNum = Mathf.Floor(second / self.RecoverTime)

	fullTime = self.RecoverTime - Mathf.Floor(second) + PowerMgr.Instance.RecoverTime / DateUtil.SecsPerMinute * (maxPower - curPower - 1) * 60
	fullTime = Mathf.Floor(serverTime / 1000 + fullTime)

	return fullTime
end

function PowerMgr:Update()
	if self.LastCalcPowerTime == nil then
		return
	end

	self:TryRecoverPower()
end

PowerMgr.Instance = PowerMgr.Instance or PowerMgr()
