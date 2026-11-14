-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/RollingNotice.lua

local NoticeData = require("luaData/Notice")

RollingNotice = class("RollingNotice", UIPanel)

local moveSpeed = 90
local eNoticeType = {
	URCard = 1,
	System = 3,
	GM = 2,
	Tower = 4
}

function RollingNotice:ctor()
	self.UIPrefabPath = "UI/CommonTip/RollingNotice/RollingNotice"
	self.list = {}
	self.listTime = {}
	self.curRolling = false
	self.textWidth = 0
	self.inPageMain = false
	self.isShow = true
end

function RollingNotice:OnEnter(vParam)
	self:SetShowOrHide(false)

	self.maskGo = self:GetChildGameObject("Panel/Mask")
	self.text = self:GetChildComponent("Panel/Mask/Text", "Text")
	self.startPosGo = self:GetChildGameObject("Panel/Mask/StartPos")
	self.endPosGo = self:GetChildGameObject("Panel/Mask/EndPos")
	self.startPosX, self.startPosY = GOUtil.GetTransformLocalPosition(self.startPosGo, x, y, z)
	self.endPosX, self.endPosY = GOUtil.GetTransformLocalPosition(self.endPosGo, x, y, z)
end

function RollingNotice:OnRegisterEvent()
	Event.Instance:Add(EventEnum.AddRollingNotice, self.OnAddRollingNotice, self)
	Event.Instance:Add(EventEnum.InPageMain, self.InPageMain, self)
	Event.Instance:Add(EventEnum.AddRollingNoticeTime, self.OnAddRollingNoticeTime, self)
end

function RollingNotice:OnUnRegisterEvent()
	Event.Instance:Remove(EventEnum.AddRollingNotice, self.OnAddRollingNotice, self)
	Event.Instance:Remove(EventEnum.InPageMain, self.InPageMain, self)
	Event.Instance:Remove(EventEnum.AddRollingNoticeTime, self.OnAddRollingNoticeTime, self)
end

function RollingNotice:OnAddRollingNotice(id, param)
	local text = self:CreateText(id, param)

	if string.isNullOrEmpty(text) then
		return
	end

	local notice = NoticeData[id]
	local data = {
		text = text,
		times = notice.Times,
		noticeData = notice
	}
	local index = #self.list + 1

	for i, v in ipairs(self.list) do
		if data.noticeData.Level < v.noticeData.Level then
			index = i

			break
		end
	end

	table.insert(self.list, index, data)
	self:TryRolling()
end

function RollingNotice:OnAddRollingNoticeTime(pbNotice)
	table.insert(self.listTime, pbNotice)
end

function RollingNotice:InPageMain(into)
	self.inPageMain = into

	if into then
		self.curPanel = UIMgr.GetCurPanel()
	else
		self.curPanel = nil
	end
end

function RollingNotice:CreateText(id, param)
	local notice = NoticeData[id]

	if not notice then
		return ""
	end

	local temp = Lang(notice.Notice)

	for i, v in ipairs(param) do
		local word = v

		if notice.ShowWord[i] == 1 then
			word = Lang(tonumber(word))
		end

		temp = string.gsub(temp, "{" .. i - 1 .. "}", word)
	end

	return temp
end

function RollingNotice:TryRolling()
	if not self.curRolling then
		if not self.inPageMain then
			for i = #self.list, 1, -1 do
				local data = self.list[i]

				if data.noticeData.TypeEnum == eNoticeType.URCard or data.noticeData.TypeEnum == eNoticeType.Tower then
					table.remove(self.list, i)
				end
			end
		end

		if #self.list > 0 then
			local data = self.list[1]
			local text = data.text

			data.times = data.times - 1

			if data.times == 0 then
				table.remove(self.list, 1)
			end

			self:PlayRollint(text)
		end
	end
end

function RollingNotice:PlayRollint(text)
	if not self:CanShowOrNot() then
		return
	end

	self.curRolling = true

	self:SetShowOrHide(true)

	self.text.text = text

	UIUtil.ForceRebuildLayoutImmediate(self.text.gameObject)

	self.textWidth = GOUtil.GetRectTransformWidth(self.text.gameObject)
	self.textEndPosX = self.endPosX - self.textWidth
	self.curX = self.startPosX

	GOUtil.SetTransformLocalPosition(self.text.gameObject, self.startPosX, self.startPosY, 0)
end

function RollingNotice:Update()
	if self.curRolling then
		if not self:CanShowOrNot() then
			self:SetShowOrHide(false)
		else
			self:SetShowOrHide(true)
		end

		if self.textWidth < 1 then
			return
		end

		self.curX = self.curX - moveSpeed * Time.deltaTime

		GOUtil.SetTransformLocalPosition(self.text.gameObject, self.curX, self.endPosY, 0)

		if self.curX <= self.textEndPosX then
			self.curRolling = false

			self:SetShowOrHide(false)
			self:TryRolling()
		end
	end
end

function RollingNotice:UpdateSecond()
	local serverTime = NetData:GetCurServerTime()

	if #self.listTime == 0 then
		return
	end

	for i = #self.listTime, 1, -1 do
		local pbNotice = self.listTime[i]

		if serverTime >= tonumber(pbNotice.endTime) then
			table.remove(self.listTime, i)
		else
			local timeDiff = serverTime - tonumber(pbNotice.beginTime)

			if timeDiff >= 0 then
				local x = math.floor(timeDiff / DateUtil.MillsPerSecond) % pbNotice.interval

				if x == 0 then
					self:OnAddRollingNotice(pbNotice.Id, pbNotice.params)
				end
			end
		end
	end
end

function RollingNotice:CanShowOrNot()
	if not self.inPageMain then
		return false
	end

	if not self.curPanel or self.curPanel.hideUI then
		return false
	end

	return true
end

function RollingNotice:SetShowOrHide(show)
	if self.isShow == show then
		return
	end

	self.isShow = show

	self:Show(show)
end
