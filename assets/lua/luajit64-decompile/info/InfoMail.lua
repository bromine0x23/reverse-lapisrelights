-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoMail.lua

InfoMail = class("InfoMail", InfoBase)

local MailSendType = {
	system = 1,
	idol = 2,
	maintain = 3,
	overflow = 4
}

function InfoMail:ctor(pb)
	self.id = tonumber(pb.id)
	self.pb = {}
	self.assets = {}

	self:SetData(pb)
end

function InfoMail:SetData(pbMail)
	self.pb.title = pbMail.title
	self.pb.content = pbMail.content
	self.pb.type = pbMail.type
	self.pb.sender = pbMail.sender
	self.pb.sendType = pbMail.sendType
	self.pb.sendTime = tonumber(pbMail.sendTime)
	self.pb.endTime = tonumber(pbMail.endTime)
	self.pb.status = pbMail.status
	self.pb.awards = pbMail.allAwards
	self.pb.leftAwards = pbMail.leftAwards

	self:SetAssetData()
end

function InfoMail:SetAssetData()
	self.assets = {}

	local temp = {}
	local dirty = {}
	local id = 0
	local num = 0

	for i = 1, #self.pb.awards do
		temp = {}
		temp.state = 1
		id = self.pb.awards[i].awards[1] or 0
		num = self.pb.awards[i].awards[2] or 0

		for j = 1, #self.pb.leftAwards do
			if id == self.pb.leftAwards[j].awards[1] and num >= (self.pb.leftAwards[j].awards[2] or 0) and not table.contains(dirty, j) then
				num = self.pb.leftAwards[j].awards[2] or 0
				temp.state = 0

				table.insert(dirty, j)

				break
			end
		end

		local infoItem = ItemManager:GetValueItem(id, num)

		if infoItem ~= nil then
			temp.infoItem = infoItem

			table.insert(self.assets, temp)
		end
	end
end

function InfoMail:ResetData(pbLeftAwards)
	if not pbLeftAwards or #pbLeftAwards == 0 then
		self.pb.leftAwards = {}
	else
		self.pb.leftAwards = pbLeftAwards
	end

	self:SetAssetData()
end

function InfoMail:IsExpired()
	local curServerTime = NetData:GetCurServerTime()
	local endTime = self.pb.endTime

	if endTime ~= 0 and endTime < curServerTime then
		return true
	end

	return false
end

function InfoMail:HaveAnnex()
	return #self.pb.awards > 0
end

function InfoMail:IsReceived()
	return #self.pb.leftAwards == 0
end

function InfoMail:IsOverflow()
	return self.pb.sendType == MailSendType.overflow
end

function InfoMail:IsReaded()
	local list = MailMgr:GetReadedMailIds()

	return table.contains(list, self.id)
end

function InfoMail:IsLocked()
	local list = MailMgr:GetLockMailIds()

	return table.contains(list, self.id)
end

MailMgr = {}

local listMail = {}
local maxCount = GetConfigArgInt("MailNumMax")

MailMgr.Requested = false

function MailMgr:GetMail(mailId)
	for _, v in pairs(listMail) do
		if v.id == mailId then
			return v
		end
	end

	return nil
end

function MailMgr:AddMails(pbMails)
	for i = 1, #pbMails do
		local pbMail = pbMails[i]

		self:AddOneMail(pbMail)
	end

	MailRDL.DealMail()
	Event.Instance:Fire("RefreshMailList")
end

function MailMgr:AddOneMail(pbMail)
	local temp = self:GetMail(tonumber(pbMail.id))

	if temp ~= nil then
		return
	end

	local infoMail = InfoMail(pbMail)

	table.insert(listMail, infoMail)
end

function MailMgr:GetListMail()
	self:SortMailByTime(listMail, true)
	self:RefreshListMail()

	local t = {}

	for _, v in ipairs(listMail) do
		table.insert(t, v)
	end

	return t
end

function MailMgr:RefreshListMail()
	self:DeleteExpiredMails()
	self:DeleteEarlyMails()
end

function MailMgr:DeleteExpiredMails()
	local listStay = {}

	for _, v in pairs(listMail) do
		if not v:IsExpired() then
			table.insert(listStay, v)
		else
			self:RemoveMailFromRead(v)
			self:RemoveMailFromLock(v)
		end
	end

	listMail = listStay
end

function MailMgr:DeleteEarlyMails()
	if #listMail <= maxCount then
		return
	end

	local listStay = {}

	for k, v in pairs(listMail) do
		if k <= maxCount then
			table.insert(listStay, v)
		else
			self:RemoveMailFromRead(v)
			self:RemoveMailFromLock(v)
		end
	end

	listMail = listStay
end

function MailMgr:SortMailByTime(list, priorityNew)
	local function fun(a, b)
		if priorityNew then
			return a.pb.sendTime > b.pb.sendTime
		else
			return a.pb.sendTime < b.pb.sendTime
		end
	end

	table.sort(list, fun)
end

function MailMgr:HaveNotReadMail()
	local list = self:GetListMail()

	if #list > 0 then
		for i = 1, #list do
			local infoMail = list[i]

			if not infoMail:IsReaded() then
				return true
			end
		end
	end

	return false
end

function MailMgr:GetMailsBySendType(sendType)
	local list = {}

	for _, v in pairs(listMail) do
		if sendType == v.pb.sendType then
			table.insert(list, v)
		end
	end

	return list
end

function MailMgr:GetMailsByTimeType(timeType)
	local list = {}

	for _, v in pairs(listMail) do
		if timeType == 0 then
			table.insert(list, v)
		elseif timeType == 1 then
			if v.pb.endTime ~= 0 then
				table.insert(list, v)
			end
		elseif timeType == 2 and v.pb.endTime == 0 then
			table.insert(list, v)
		end
	end

	return list
end

function MailMgr:ReadMail(infoMail)
	if not infoMail:IsReaded() then
		local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. "HaveReadMails", "")

		PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. "HaveReadMails", str .. "#" .. infoMail.id)
		MailRDL.DealMail()
	end
end

function MailMgr:GetReadedMailIds()
	local readedMails = {}
	local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. "HaveReadMails", "")
	local tables = SplitByParam(str, "#")

	for _, strMailId in ipairs(tables) do
		table.insert(readedMails, tonumber(strMailId))
	end

	return readedMails
end

function MailMgr:RemoveMailFromRead(infoMail)
	if not infoMail:IsReaded() then
		return
	end

	local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. "HaveReadMails", "")

	str = string.gsub(str, "#" .. infoMail.id, "")

	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. "HaveReadMails", str)
end

function MailMgr:RemoveReadedMails()
	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. "HaveReadMails", "")
end

function MailMgr:LockMail(infoMail)
	if not infoMail:IsLocked() then
		local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. "HaveLockMails", "")

		PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. "HaveLockMails", str .. "#" .. infoMail.id)
	end
end

function MailMgr:GetLockMailIds()
	local lockMails = {}
	local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. "HaveLockMails", "")
	local tables = SplitByParam(str, "#")

	for _, strMailId in ipairs(tables) do
		table.insert(lockMails, tonumber(strMailId))
	end

	return lockMails
end

function MailMgr:RemoveMailFromLock(infoMail)
	if not infoMail:IsLocked() then
		return
	end

	local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. "HaveLockMails", "")

	str = string.gsub(str, "#" .. infoMail.id, "")

	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. "HaveLockMails", str)
end

function MailMgr:RemoveOneFromAllMail(mailId)
	if #listMail <= 0 then
		return
	end

	local index

	for i = 1, #listMail do
		local infoMail = listMail[i]

		if infoMail.id == mailId then
			index = i

			break
		end
	end

	if index ~= nil then
		table.remove(listMail, index)
	end
end

function MailMgr:RemoveSomeFromAllMail(listId)
	if #listMail <= 0 or #listId <= 0 then
		return
	end

	local list = {}

	for i = 1, #listMail do
		local infoMail = listMail[i]
		local isSame = false

		for j = 1, #listId do
			if infoMail.id == listId[j] then
				isSame = true

				break
			end
		end

		if not isSame then
			table.insert(list, infoMail)
		end
	end

	listMail = list
end

function MailMgr:GetReadUnlockMailIds()
	local readedMails = self:GetReadedMailIds()
	local list = {}

	for i = 1, #readedMails do
		local infoMail = self:GetMail(readedMails[i])

		if infoMail and not infoMail:IsLocked() then
			table.insert(list, readedMails[i])
		end
	end

	return list
end

function MailMgr:GetOneKeyReceiveMailIds()
	local listAnnex = {}

	for i = 1, #listMail do
		local infoMail = listMail[i]

		if infoMail:HaveAnnex() and not infoMail:IsExpired() and not infoMail:IsReceived() then
			table.insert(listAnnex, infoMail.id)
		end
	end

	return listAnnex
end

function MailMgr:GetReadUnlockReceiveMailIds()
	local freeMails = self:GetReadUnlockMailIds()
	local list = {}

	for i = 1, #freeMails do
		local infoMail = self:GetMail(freeMails[i])
		local flag = false

		if infoMail:HaveAnnex() and not infoMail:IsReceived() and not infoMail:IsExpired() then
			flag = true
		end

		if not flag then
			table.insert(list, infoMail.id)
		end
	end

	return list
end
