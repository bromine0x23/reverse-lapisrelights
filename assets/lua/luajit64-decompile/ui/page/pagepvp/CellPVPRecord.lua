-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/CellPVPRecord.lua

CellPVPRecord = class("CellPVPRecord", UIItemBase)

function CellPVPRecord:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellPVPRecord:Create(vParam)
	CellPVPRecord.base.Create(self, vParam)
end

function CellPVPRecord:OnEnter()
	self.UIRootObject:SetActive(true)

	self.victoryGo = self:GetChildGameObject("Victory")
	self.failGo = self:GetChildGameObject("Fail")
	self.DownImage = self:GetChildGameObject("DownImage")
	self.UpImage = self:GetChildGameObject("UpImage")
	self.score = self:GetChildComponent("Score", "Text")
	self.rank = self:GetChildComponent("Rank", "Text")
	self.name = self:GetChildComponent("Name", "Text")
	self.time = self:GetChildComponent("Time", "Text")
end

function CellPVPRecord:UpdateData(data)
	local battleinfo = data.battleinfo

	if battleinfo.battleResult == 0 then
		battleinfo.battleEndTime = battleinfo.battleBeginTime
	end

	if data.type == 1 then
		print(battleinfo.battleResult)

		if battleinfo.battleResult == 1 then
			self.victoryGo:SetActive(true)
			self.failGo:SetActive(false)
		else
			self.victoryGo:SetActive(false)
			self.failGo:SetActive(true)
		end

		local rank = battleinfo.atkPlayerBeforeRankingNo - battleinfo.atkPlayerAfterRankingNo

		self.DownImage:SetActive(rank < 0)
		self.UpImage:SetActive(rank > 0)

		local score = battleinfo.atkPlayerAfterScore - battleinfo.atkPlayerBeforeScore

		self.rank.text = math.abs(rank)
		self.score.text = math.abs(score)

		local infopvp = InfoPvPPlayer()

		infopvp:SetData(battleinfo.defensivePlayer, 1)

		self.name.text = infopvp.playerinfo.name

		local time = NetData:GetCurServerTime() / DateUtil.MillsPerSecond - battleinfo.battleBeginTime

		self.time.text = self:GetStrDisTime(time)
	else
		if battleinfo.battleResult == 1 then
			self.victoryGo:SetActive(false)
			self.failGo:SetActive(true)
		else
			self.victoryGo:SetActive(true)
			self.failGo:SetActive(false)
		end

		local rank = battleinfo.defPlayerAfterRankingNo - battleinfo.defPlayerBeforeRankingNo

		self.DownImage:SetActive(rank < 0)
		self.UpImage:SetActive(rank > 0)

		local score = battleinfo.defPlayerAfterScore - battleinfo.defPlayerBeforeScore

		self.rank.text = math.abs(rank)
		self.score.text = math.abs(score)

		local infopvp = InfoPvPPlayer()

		infopvp:SetData(battleinfo.attackingPlayer, 1)

		self.name.text = infopvp.playerinfo.name

		local time = NetData:GetCurServerTime() / DateUtil.MillsPerSecond - battleinfo.battleBeginTime

		self.time.text = self:GetStrDisTime(time)
	end
end

function CellPVPRecord:OnLeave()
	return
end

function CellPVPRecord:GetStrDisTime(second)
	local d, h, m, s = GetTimeFormatBySec(second)

	print(m)

	if d >= 1 then
		strTime = string.format(_("Desc_Days_Ago"), d)
	elseif d < 1 and h >= 1 then
		strTime = string.format(_("Desc_Hours_Ago"), h)
	elseif h < 1 and m >= 1 then
		strTime = string.format(_("Desc_Minutes_Ago"), m)
	elseif m < 1 and s >= 1 then
		strTime = string.format(_("Desc_Seconds_Ago"), s)
	else
		strTime = _("Desc_Just_Ago")
	end

	return strTime
end
