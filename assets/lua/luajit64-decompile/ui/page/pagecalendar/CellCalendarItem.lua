-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCalendar/CellCalendarItem.lua

local ActiveManage = require("luaData/ActiveManage")
local ActiveBuffInfo = require("luaData/ActiveBuffInfo")
local Config = require("luaData/Config")
local GoodsMonthPrivilege = require("luaData/GoodsMonthPrivilege")

require("UI/Item/UIItemBase")

CellCalendarItem = class("CellCalendarItem", UIItemBase)

function CellCalendarItem:ctor(itemPrefabCache, parent, ownerUI)
	self.CurStage = ChapterMgr:GetCurStage()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCalendarItem:OnLeave()
	UnloadAllImageSprite(self)
	self.CellItem:OnLeave()
	self:RemoveClick(self.ButtonGo, self.OnClickedGo)
	self:RemoveClick(self.img_condition1, self.onClickAdd)
	self:RemoveClick(self.MonthBuff, self.onClickMonthBuff)
	self:RemoveClick(self.ActiveBuff, self.onClickActiveBuff)
	self:RemoveClick(self.Img_icon.gameObject, self.onClickItem)
end

function CellCalendarItem:OnEnter()
	self.ButtonGo = self:GetChildGameObject("main/ButtonGo")
	self.img_complete = self:GetChildGameObject("main/img_complete")
	self.img_gift = self:GetChildGameObject("main/img_gift")
	self.lock = self:GetChildGameObject("main/lock")
	self.endtime = self:GetChildGameObject("main/tex_endtime")
	self.grop_condition1 = self:GetChildGameObject("main/group/grop_condition1")
	self.grop_condition2 = self:GetChildGameObject("main/group/grop_condition2")
	self.img_condition1 = self:GetChildGameObject("main/group/grop_condition1/img_condition1")
	self.img_condition2 = self:GetChildGameObject("main/group/grop_condition2/img_condition2")
	self.MonthBuff = self:GetChildGameObject("main/buff_group/img_month")
	self.ActiveBuff = self:GetChildGameObject("main/buff_group/img_active")
	self.tex_condition1 = self:GetChildComponent("main/group/grop_condition1/tex_condition1", "Text")
	self.tex_condition2 = self:GetChildComponent("main/group/grop_condition2/tex_condition2", "Text")
	self.Img_icon = self:GetChildComponent("main/Img_icon", "Image")
	self.img_month = self:GetChildComponent("main/buff_group/img_month", "Image")
	self.img_active = self:GetChildComponent("main/buff_group/img_active", "Image")
	self.tex_lock = self:GetChildComponent("main/lock/tex_lock", "Text")
	self.tex_title = self:GetChildComponent("main/tex_title", "Text")
	self.tex_endtime = self:GetChildComponent("main/tex_endtime", "Text")
	self.tex_reward = self:GetChildComponent("main/tex_reward", "Text")
	self.tex_go = self:GetChildComponent("main/ButtonGo/Text", "Text")

	local gItem = self:GetChildGameObject("main/cell/CellItem")

	self.cell = self:GetChildGameObject("main/cell")
	self.CellItem = CellItem(gItem)

	self.CellItem:InitItemByRoot(gItem)
	self:AddClick(self.ButtonGo, self.OnClickedGo)
	self:AddClick(self.img_condition1, self.onClickAdd)
	self:AddClick(self.MonthBuff, self.onClickMonthBuff)
	self:AddClick(self.ActiveBuff, self.onClickActiveBuff)
	self:AddClick(self.Img_icon.gameObject, self.onClickItem)
end

function CellCalendarItem:onClickItem()
	local data = ItemManager:Get(self.info.NavigationItem)

	UIMgr.ShowItemTip(data)
end

function CellCalendarItem:onClickMonthBuff()
	local x = self.MonthBuff.transform.position.x
	local y = self.MonthBuff.transform.position.y
	local z = self.MonthBuff.transform.position.z

	UIMgr.AddPanel(PageBuff(), {
		type = 1,
		data = self.monthData,
		x = x,
		y = y,
		z = z
	}, UIMgr.UIPopupObject)
end

function CellCalendarItem:onClickActiveBuff()
	local x = self.ActiveBuff.transform.position.x
	local y = self.ActiveBuff.transform.position.y
	local z = self.ActiveBuff.transform.position.z

	UIMgr.AddPanel(PageBuff(), {
		type = 1,
		data = self.activeData,
		x = x,
		y = y,
		z = z
	}, UIMgr.UIPopupObject)
end

function CellCalendarItem:onClickAdd()
	if self.info.ID == ePageType.PageBossRaid then
		if GetConfigArgInt("RailBossActiveDailyNumBuyCost") > 0 and ActivityBossRaidMgr.buyNum == GetConfigArgInt("RailBossActiveDailyNumBuyCost") then
			UIMgr.ShowMsg(_("Buy_Battle_Count_Limit"))

			return
		end

		ActivityBossRaidMgr.isAdd = true

		self:OnClickedGo()
	end
end

function CellCalendarItem:OnClickedGo()
	if #self.info.FromWhere > 0 then
		OperationActiveMgr.BattlePassTag = "Tab2"

		local function fun()
			Event.Instance:Fire("ClosePageCalendar")
		end

		DlgItemTip.GoToFrom(self.info.FromWhere[1], nil, fun)
	end
end

function CellCalendarItem:UpdateData(info)
	self.info = info.data

	if self.info.ID == ePageType.PageDifficult then
		self.tex_title.text = Lang(8111002)
	else
		self.tex_title.text = Lang(self.info.Name)
	end

	self.tex_title.text = "<size=24>" .. self.tex_title.text .. "</size>"
	self.tex_reward.text = _("Desc_MainReward")
	self.tex_go.text = _("UI_Go")

	if info.MainRewardShow ~= nil then
		local item = ItemManager:GetValueItem(info.MainRewardShow[1], info.MainRewardShow[2])

		self.CellItem:UpdateNoNumType(item)
		self.cell:SetActive(true)
		self.Img_icon.gameObject:SetActive(false)
	else
		self.Img_icon.gameObject:SetActive(true)
		self.cell:SetActive(false)
		UIUtil.SetImageSprite(self.Img_icon, self.info.NavigationBar[1][2], self)
	end

	if self.info.Stage >= self.CurStage.id then
		local _, i, j = ChapterMgr:GetChapterByStageID(self.info.Stage)

		self.tex_lock.text = "<size=20>メインストーリー" .. i .. "-" .. j .. "開放</size>"

		self.ButtonGo:SetActive(false)
		self.lock:SetActive(true)
	else
		self.ButtonGo:SetActive(true)
		self.lock:SetActive(false)
	end

	if info.isComplete == 1 then
		self.img_complete:SetActive(true)
	else
		self.img_complete:SetActive(false)
	end

	self.img_gift:SetActive(info.isGift)

	local condition1 = self:GetBarDataByID(2)

	if condition1 then
		self.grop_condition1:SetActive(true)

		if info.Max1 then
			self.tex_condition1.text = Lang(condition1[3]) .. info.Condition1 .. "/" .. info.Max1
		end

		if condition1[4] then
			self.img_condition1:SetActive(true)
		else
			self.img_condition1:SetActive(false)
		end
	else
		self.grop_condition1:SetActive(false)
	end

	local condition2 = self:GetBarDataByID(3)

	if condition2 then
		self.grop_condition2:SetActive(true)

		if info.Max2 then
			self.tex_condition2.text = Lang(condition2[3]) .. info.Condition2 .. "/" .. info.Max2
		end

		if condition2[4] then
			self.img_condition2:SetActive(true)
		else
			self.img_condition2:SetActive(false)
		end
	else
		self.grop_condition2:SetActive(false)
	end

	if info.EndText and self.info.Stage <= self.CurStage.id then
		self.endtime:SetActive(true)

		self.tex_endtime.text = info.EndText
	else
		self.endtime:SetActive(false)
	end

	self.monthData = {}
	self.activeData = {}

	for _, buff in pairs(self.info.NavigationBuff) do
		if buff[1] == 1 then
			self:DealWithMonthData(buff[2])
		elseif buff[1] == 2 then
			self:DealWithActiveData(buff[2])
		end
	end

	if ShopManager:CheckMonthBuff() and #self.monthData > 0 then
		self.MonthBuff:SetActive(true)
	else
		self.MonthBuff:SetActive(false)
	end

	if #self.activeData > 0 then
		self.ActiveBuff:SetActive(true)
	else
		self.ActiveBuff:SetActive(false)
	end
end

function CellCalendarItem:DealWithMonthData(id)
	local minTime = ShopManager:GetMonthCardMinTime() / DateUtil.MillsPerSecond

	for _, value in pairs(GoodsMonthPrivilege) do
		if value.ID == id then
			local data = {}

			data.Name = value.Name
			data.Info = value.BuffInfo
			data.IntValue = value.IntShow
			data.Icon = value.BuffIcon
			data.endTime = minTime

			table.insert(self.monthData, data)
		end
	end

	local path = GetConfigArgJson("ActiveBuffIconShow")[1][1]

	if path ~= nil then
		UIUtil.SetImageSprite(self.img_month, path, self)
	end
end

function CellCalendarItem:DealWithActiveData(id)
	for _, value in pairs(ActiveBuffInfo) do
		if value.ID == id then
			for _, active in pairs(ActiveManage) do
				if active.ID == value.ActiveID then
					local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
					local startTime = GetTimeTampByString(active.StartTime)
					local endTime = GetTimeTampByString(active.EndTime)

					if startTime <= curServerTime and curServerTime < endTime then
						local data = {}

						data.endTime = endTime
						data.Name = value.Name
						data.Info = value.Info
						data.Icon = value.Icon
						data.BuffType = value.BuffType
						data.SkillID = active.BuffSkillID[1]

						table.insert(self.activeData, data)
					end
				end
			end
		end
	end

	local path = GetConfigArgJson("ActiveBuffIconShow")[2][1]

	if path ~= nil then
		UIUtil.SetImageSprite(self.img_active, path, self)
	end
end

function CellCalendarItem:GetBarDataByID(id)
	for _, value in pairs(self.info.NavigationBar) do
		if value[1] == id then
			return value
		end
	end

	return nil
end
