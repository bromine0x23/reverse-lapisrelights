-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/FavorMgr.lua

eFavorMotionType = {
	levelUp = 4,
	touchHead = 1,
	hello = 6,
	dragSuccess = 2,
	sectionUp = 5,
	touchBody = 3,
	getGift = 7,
	sendGift = 8
}
FavorMgr = class("FavorMgr")

function FavorMgr:ctor()
	self.MaxLimit = GetConfigArgInt("TouchMaxNumber")
	self.RecoverTime = GetConfigArgInt("TouchWaitTime")
	self.LastCalcPowerTime = nil
	self.ShowFavorUnlock = false
end

function FavorMgr:SetPowerTime(lastCalcPowerTime)
	self.LastCalcPowerTime = tonumber(lastCalcPowerTime)

	self:TryRecoverPower()
end

function FavorMgr:IsFull()
	return InfoGameInst.gameInfo.touchCnt == self.MaxLimit
end

function FavorMgr:TryRecoverPower()
	local curPower = InfoGameInst.gameInfo.touchCnt
	local maxPower = self.MaxLimit

	if maxPower <= curPower then
		return
	end

	local serverTime = NetData:GetCurServerTime()

	if serverTime <= self.LastCalcPowerTime then
		return
	end

	local second = (serverTime - self.LastCalcPowerTime) / DateUtil.MillsPerSecond
	local addPowerNum = Mathf.Floor(second / self.RecoverTime)
	local leftTime = self.RecoverTime - Mathf.Floor(second)
	local finalPower = curPower + addPowerNum

	if maxPower <= finalPower then
		InfoGameInst:SetTouchCnt(maxPower)
		Event.Instance:Fire(EventEnum.UpdateFavorTouch)

		self.LastCalcPowerTime = serverTime
	else
		if addPowerNum > 0 then
			InfoGameInst.gameInfo.touchCnt = InfoGameInst.gameInfo.touchCnt + addPowerNum

			Event.Instance:Fire(EventEnum.UpdateFavorTouch)
		end

		self.LastCalcPowerTime = self.LastCalcPowerTime + addPowerNum * self.RecoverTime * DateUtil.MillsPerSecond
	end

	Event.Instance:Fire(EventEnum.UpdateFavorTouchRecoverTime, leftTime)
end

function FavorMgr:Update()
	if self.LastCalcPowerTime == nil then
		return
	end

	self:TryRecoverPower()
end

FavorMgr.Instance = FavorMgr.Instance or FavorMgr()
