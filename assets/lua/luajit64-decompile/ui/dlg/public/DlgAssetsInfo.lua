-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgAssetsInfo.lua

local CalenderData = require("luaData/Newbie")
local ActiveManage = require("luaData/ActiveManage")
local ActiveBuffInfo = require("luaData/ActiveBuffInfo")
local GoodsMonthPrivilege = require("luaData/GoodsMonthPrivilege")

require("Info/InfoResourceBanner")
require("UI/Page/PageBuff/PageBuff")

DlgAssetsInfo = class("DlgAssetsInfo", UIPanel)

function DlgAssetsInfo:ctor()
	self.UIPrefabPath = "UI/Public/DlgAssetsInfo"
	self.maxBannerCnt = 4
end

function DlgAssetsInfo:Purge()
	DlgAssetsInfo.base.Purge(self)
	UIMgr.RemoveUpdatePanel(self)
end

function DlgAssetsInfo:Close(tParam)
	DlgAssetsInfo.base.Close(self, tParam)
	self:OnLeave()
end

function DlgAssetsInfo:OnLeave()
	UnloadAllImageSprite(self)
end

function DlgAssetsInfo:OnRegisterEvent()
	self:AddClick(self.ActiveBuff, self.onClickActiveBuff)
	self:AddClick(self.MonthBuff, self.onClickMonthBuff)
	Event.Instance:Add(EventEnum.UpdatePowerRecoverTime, self.NotifyPowerRecoverTime, self)
	Event.Instance:Add(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
	Event.Instance:Add("ChangePageBuff", self.CheckBuffState, self)
	EventListenerMgr.AddFingerListener(self.OnFingerTap, self, eFingerEventType.Down)
end

function DlgAssetsInfo:OnUnRegisterEvent()
	self:RemoveClick(self.ActiveBuff, self.onClickActiveBuff)
	self:RemoveClick(self.MonthBuff, self.onClickMonthBuff)

	if self.listEventIdx then
		for i = 1, #self.listEventIdx do
			self:RemoveClick(self["Go" .. self.listEventIdx[i]], self.OnClickShow)
		end
	end

	if self.listAddEventIdx then
		for i = 1, #self.listAddEventIdx do
			self:RemoveClick(self["BtnAdd" .. self.listAddEventIdx[i]], self.OnClickGo)
		end
	end

	Event.Instance:Remove(EventEnum.UpdatePowerRecoverTime, self.NotifyPowerRecoverTime, self)
	Event.Instance:Remove(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
	Event.Instance:Remove("ChangePageBuff", self.CheckBuffState, self)
	EventListenerMgr.RemoveFingerListener(self.OnFingerTap, self, eFingerEventType.Down)
end

function DlgAssetsInfo:OnEnter(vParam)
	local UIPointerDiscover = GOUtil.GetComponent(self.UIRootObject, "UIPointDiscover")

	if not IsNil(UIPointerDiscover) then
		function UIPointerDiscover.onDiscover()
			self:OnFingerTap()
		end
	end

	self:SetSafeArea(self.UIRootObject)

	self.MonthBuff = self:GetChildGameObject("BuffGroup/MonthBuff")
	self.ActiveBuff = self:GetChildGameObject("BuffGroup/ActiveBuff")
	self.img_month = self:GetChildComponent("BuffGroup/MonthBuff/img_month", "Image")
	self.img_active = self:GetChildComponent("BuffGroup/ActiveBuff/img_active", "Image")
	self.tex_month = self:GetChildComponent("BuffGroup/MonthBuff/tex_month", "Text")
	self.tex_active = self:GetChildComponent("BuffGroup/ActiveBuff/tex_active", "Text")

	for i = 1, self.maxBannerCnt do
		self["Go" .. i] = self:GetChildGameObject("Assets/" .. i)
		self["Text" .. i] = self:GetChildComponent("Assets/" .. i .. "/Text", "Text")
		self["Text" .. i].fontSize = 24
		self["ImgIcon" .. i] = self:GetChildComponent("Assets/" .. i .. "/Icon", "Image")
		self["BtnAdd" .. i] = self:GetChildGameObject("Assets/" .. i .. "/Add")
	end

	self.AssetInfos = {
		503,
		502,
		501
	}
	self.AddShow = {
		1,
		1,
		1
	}

	self:ResetByConfig()
	self:CheckBuffState()
	UIMgr.SetUpdatePanel(self)
end

function DlgAssetsInfo:ResetBannerPosition(x, y)
	x = x or 20
	y = y or 0

	if IsNil(self.GoAssets) then
		self.GoAssets = self:GetChildGameObject("Assets")
	end

	GOUtil.SetRectTransformAnchoredPosition(self.GoAssets, x, y)
end

function DlgAssetsInfo:ResetByConfig()
	local infoResourceBanner

	if self.parentPanel then
		infoResourceBanner = ResourceBannerMgr:GetBannerByPage(self.parentPanel.className)
	end

	if infoResourceBanner then
		self.AssetInfos = infoResourceBanner.data.Banner or {}

		self:SetAddShow()
	end

	self:UpdateAssetsInfo()
end

function DlgAssetsInfo:ResetByBannerId(bannerId)
	local infoResourceBanner = ResourceBannerMgr:Get(bannerId)

	if infoResourceBanner then
		self.AssetInfos = infoResourceBanner.data.Banner or {}

		self:SetAddShow()
	end

	self:UpdateAssetsInfo()
end

function DlgAssetsInfo:ResetByList(list)
	self.AssetInfos = list or {}

	self:SetAddShow()
	self:UpdateAssetsInfo()
end

function DlgAssetsInfo:SetAddShow()
	self.AddShow = {}

	for k, id in ipairs(self.AssetInfos) do
		local info = ItemManager:Get(id)

		if info:GetType() ~= eItemType.P_POWER and #info.data.FromWhere == 0 then
			self.AddShow[k] = 0
		else
			self.AddShow[k] = 1
		end
	end
end

function DlgAssetsInfo:UpdateAssetsInfo()
	for i = 1, self.maxBannerCnt do
		if i <= #self.AssetInfos then
			self["Go" .. i]:SetActive(true)

			local id = self.AssetInfos[i]
			local path = ItemManager:GetIcon(id)

			UIUtil.SetImageOverrideSprite(self["ImgIcon" .. i], path, self)

			if self.AddShow[i] == 0 then
				GOUtil.SetActive(self["BtnAdd" .. i], false)
			else
				GOUtil.SetActive(self["BtnAdd" .. i], true)
			end
		else
			self["Go" .. i]:SetActive(false)
		end
	end

	self:NotifyUpdate()

	self.IsSet1 = false
	self.IsSet2 = false

	self:InitClickEvent()
end

function DlgAssetsInfo:NotifyUpdate()
	for i = 1, self.maxBannerCnt do
		if i <= #self.AssetInfos then
			local id = self.AssetInfos[i]
			local infoItem = ItemManager:Get(id)

			if infoItem:GetType() == eItemType.P_POWER then
				self["Text" .. i].text = string.format("%d/%d", NumMillionMagnitudeConversion(PlayerInst:GetPower(), 1), NumMillionMagnitudeConversion(PlayerInst.InfoPlayer.maxPower, 1))
			elseif infoItem:GetType() == eItemType.P_DIAMOND and not table.contains(self.AssetInfos, 513) then
				self["Text" .. i].text = NumMillionMagnitudeConversion(PlayerInst:GetDiamondAll(), 1)
			else
				self["Text" .. i].text = NumMillionMagnitudeConversion(infoItem:GetCurResNum(), 1)
			end
		end
	end
end

function DlgAssetsInfo:UpdatePowerTip()
	if IsNil(self.obj_PowerTip) then
		return
	end

	local RctimeStr = "<color=red>(" .. PowerMgr.Instance:GetNextRecoverTimeStr() .. ")</color>"

	if IsNil(self.txt_PowerTip) then
		self.txt_PowerTip = GOUtil.FindChildComponent(self.obj_PowerTip, "Text", "Text")
	end

	self.txt_PowerTip.text = string.format(_("PowerRcoverTip"), PowerMgr.Instance.RecoverTime / DateUtil.SecsPerMinute) .. RctimeStr
end

function DlgAssetsInfo:NotifyPowerRecoverTime(leftTime)
	self:UpdatePowerTip()
end

function DlgAssetsInfo:UpdateDiamondTip()
	if IsNil(self.obj_DiamondTip) then
		return
	end

	if IsNil(self.txt_Diamond1) or IsNil(self.txt_Diamond2) then
		self.txt_Diamond1 = GOUtil.FindChildComponent(self.obj_DiamondTip, "Text1", "Text")
		self.txt_Diamond2 = GOUtil.FindChildComponent(self.obj_DiamondTip, "Text2", "Text")
	end

	self.txt_Diamond1.text = NumMillionMagnitudeConversion(PlayerInst:GetDiamond(), 1)
	self.txt_Diamond2.text = NumMillionMagnitudeConversion(PlayerInst:GetDiamondPay(), 1)
end

function DlgAssetsInfo:InitClickEvent()
	self.listEventIdx = self.listEventIdx or {}
	self.listAddEventIdx = self.listAddEventIdx or {}

	for i = 1, self.maxBannerCnt do
		if self.AssetInfos[i] then
			local _type = ItemManager:GetType(self.AssetInfos[i])

			if (_type == eItemType.P_POWER or _type == eItemType.P_DIAMOND) and not table.contains(self.listEventIdx, i) then
				self:AddClick(self["Go" .. i], self.OnClickShow)
				table.insert(self.listEventIdx, i)
			end
		end

		if self.AddShow[i] and self.AddShow[i] == 1 and not table.contains(self.listAddEventIdx, i) then
			self:AddClick(self["BtnAdd" .. i], self.OnClickGo)
			table.insert(self.listAddEventIdx, i)
		end
	end
end

function DlgAssetsInfo:OnClickShow(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)

	if self.AssetInfos[index] then
		local _type = ItemManager:GetType(self.AssetInfos[index])

		if _type == eItemType.P_POWER then
			if IsNil(self.obj_PowerTip) then
				self.obj_PowerTip = self:GetChildGameObject("Assets/PowerTip")
			end

			if not self.IsPowerShow then
				self.obj_PowerTip:SetActive(true)

				self.IsPowerShow = true

				self:UpdatePowerTip()
				self:SetObjTipPos(self.obj_PowerTip, index, 1)
			else
				self.obj_PowerTip:SetActive(false)

				self.IsPowerShow = false
			end
		elseif _type == eItemType.P_DIAMOND then
			if IsNil(self.obj_DiamondTip) then
				self.obj_DiamondTip = self:GetChildGameObject("Assets/DiamondTip")
			end

			if not self.IsDiamondShow then
				self.obj_DiamondTip:SetActive(true)

				self.IsDiamondShow = true
			end

			self:UpdateDiamondTip()
			self:SetObjTipPos(self.obj_DiamondTip, index, 2)
		end
	end
end

function DlgAssetsInfo:SetObjTipPos(obj, index, _type)
	if not self["IsSet" .. _type] then
		GOUtil.AttachGameObject(obj, self["Go" .. index])

		local x = GOUtil.GetScreenPosX(self["Go" .. index])
		local y = GOUtil.GetScreenPosY(self["Go" .. index])
		local pos

		if _type == 1 then
			pos = UIUtil.GetTipsPos(self["Go" .. index], Vector2(x, y), self.obj_PowerTip, 0)
		else
			pos = UIUtil.GetTipsPos(self["Go" .. index], Vector2(x, y), self.obj_DiamondTip, 0)
		end

		GOUtil.SetRectTransformAnchoredPosition(obj, pos.x, pos.y - 64)

		self["IsSet" .. _type] = true
	end
end

function DlgAssetsInfo:OnFingerTap()
	if self.IsPowerShow and not IsNil(self.obj_PowerTip) then
		self.obj_PowerTip:SetActive(false)

		self.IsPowerShow = false
	end

	if self.IsDiamondShow and not IsNil(self.obj_DiamondTip) then
		self.obj_DiamondTip:SetActive(false)

		self.IsDiamondShow = false
	end
end

function DlgAssetsInfo:OnClickGo(data)
	local go = data.pointerPress.gameObject.transform.parent
	local i = tonumber(go.name)
	local id = self.AssetInfos[i]
	local infoItem = ItemManager:Get(id)

	if GetItemType(infoItem.data.Type) == eItemType.P_POWER then
		require("UI/Dlg/Common/DlgPowerBuy")
		UIMgr.AddPanel(DlgPowerBuy())
	else
		local fromWhere = infoItem.data.FromWhere

		if fromWhere and next(fromWhere) ~= nil then
			local fromType = fromWhere[1][1]
			local fromExtra1 = fromWhere[1][2]
			local fromExtra2 = fromWhere[1][3]

			if fromType then
				if fromType == eItemFromType.Shop then
					local PredeployObj = GameObject.Find("PageShop(Clone)")

					require("UI/Page/PageShop/PageShop")

					if IsNil(PredeployObj) then
						PageShop.InitNetData({
							tabMainIndex = fromExtra1,
							tagIndex = fromExtra2
						})
					else
						Event.Instance:Fire("UpdateShopTab", {
							tabMainIndex = fromExtra1,
							tagIndex = fromExtra2
						})
					end
				elseif fromType == eItemFromType.BossActive then
					if fromExtra1 then
						local prePanel = UIMgr.GetPrePanel()
						local curPanel = UIMgr.GetCurPanel()

						if fromExtra1 == 1 then
							if prePanel.className == "PageBossActivityBG" then
								UIMgr.PopPanel()
							else
								ChapterMgr.BossActivityStageType = nil

								PageBossActivityBG.OpenActivity()
							end
						elseif fromExtra1 == 2 then
							if prePanel.className == "PageBossActivityBG" then
								UIMgr.PopPanel({
									stageType == StageFromType.activeCommon
								})
							elseif curPanel.className == "PageBossActivityBG" then
								local pageStage = UIMgr.GetPanel("PageBossActivityStory")

								if pageStage then
									pageStage:OnClickedBtnStage()()
								end

								local pageStage = UIMgr.GetPanel("PageBossActivity")

								if pageStage then
									pageStage:Close()
									UIMgr.AddPanel(PageBossActivityStage())
								end
							else
								ChapterMgr.BossActivityStageType = StageFromType.activeCommon

								PageBossActivityBG.OpenActivity()
							end
						end
					end
				else
					UIMgr.PopChildByName("PageShop")
					DlgItemTip.GoToFrom(fromWhere[1])
				end
			end
		end
	end
end

function DlgAssetsInfo:CheckBuffState()
	self.monthData = {}
	self.activeData = {}

	local PageType = UIMgr.GetPageType()

	for _, value in pairs(CalenderData) do
		repeat
			if value.ID == PageType then
				for _, buff in pairs(value.NavigationBuff) do
					if buff[1] == 1 then
						self:DealWithMonthData(buff[2])
					elseif buff[1] == 2 then
						self:DealWithActiveData(buff[2])
					end
				end
			end

			break
		until true
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

function DlgAssetsInfo:DealWithMonthData(id)
	self.minTime_Month = ShopManager:GetMonthCardMinTime() / DateUtil.MillsPerSecond

	for _, value in pairs(GoodsMonthPrivilege) do
		if value.ID == id then
			local data = {}

			data.Name = value.Name
			data.Info = value.BuffInfo
			data.IntValue = value.IntShow
			data.Icon = value.BuffIcon
			data.endTime = self.minTime_Month

			table.insert(self.monthData, data)

			break
		end
	end

	local path = GetConfigArgJson("ActiveBuffIconShow")[1][1]

	if path ~= nil then
		UIUtil.SetImageSprite(self.img_month, path, self)
	end

	self.tex_month.text = OperationActiveMgr:GetRemainTimeNew(self.minTime_Month)
end

function DlgAssetsInfo:DealWithActiveData(id)
	local minTime = 0

	for _, value in pairs(ActiveBuffInfo) do
		if value.ID == id then
			for _, active in pairs(ActiveManage) do
				if active.ID == value.ActiveID then
					local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
					local startTime = GetTimeTampByString(active.StartTime)
					local endTime = GetTimeTampByString(active.EndTime)

					if startTime <= curServerTime and curServerTime < endTime then
						local data = {}

						if minTime == 0 then
							minTime = endTime
						end

						if endTime < minTime then
							minTime = endTime
						end

						data.endTime = endTime
						data.Name = value.Name
						data.Info = value.Info
						data.Icon = value.Icon
						data.BuffType = value.BuffType
						data.SkillID = active.BuffSkillID[1]

						table.insert(self.activeData, data)
					end

					break
				end
			end

			break
		end
	end

	if minTime ~= 0 then
		self.minTime_Active = minTime
		self.tex_active.text = OperationActiveMgr:GetRemainTimeNew(self.minTime_Active)
	end

	local path = GetConfigArgJson("ActiveBuffIconShow")[2][1]

	if path ~= nil then
		UIUtil.SetImageSprite(self.img_active, path, self)
	end
end

function DlgAssetsInfo:onClickMonthBuff()
	local x = self.MonthBuff.transform.position.x
	local y = self.MonthBuff.transform.position.y
	local z = self.MonthBuff.transform.position.z

	UIMgr.AddPanel(PageBuff(), {
		type = 2,
		data = self.monthData,
		x = x,
		y = y,
		z = z
	})
end

function DlgAssetsInfo:onClickActiveBuff()
	local x = self.ActiveBuff.transform.position.x
	local y = self.ActiveBuff.transform.position.y
	local z = self.ActiveBuff.transform.position.z

	UIMgr.AddPanel(PageBuff(), {
		type = 2,
		data = self.activeData,
		x = x,
		y = y,
		z = z
	})
end

function DlgAssetsInfo:UpdateAssetShowNum(id, showNum)
	for k, v in ipairs(self.AssetInfos) do
		if v == id then
			self["Text" .. k].text = NumMillionMagnitudeConversion(showNum, 1)

			break
		end
	end
end

function DlgAssetsInfo:IsAddBtnShow(assetType)
	if assetType == nil then
		return false
	end

	local isAddBtnShow = assetType == eItemType.P_POWER or assetType == eItemType.P_DIAMOND

	return isAddBtnShow
end

function DlgAssetsInfo:OnUpdateSecond()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if self.MonthBuff and self.minTime_Month and self.MonthBuff.activeSelf then
		if curServerTime <= self.minTime_Month then
			self.tex_month.text = OperationActiveMgr:GetRemainTimeNew(self.minTime_Month)
		else
			SetActiveFunc(self.MonthBuff, false)
		end
	end

	if self.ActiveBuff and self.minTime_Active and self.ActiveBuff.activeSelf then
		if curServerTime <= self.minTime_Active then
			self.tex_active.text = OperationActiveMgr:GetRemainTimeNew(self.minTime_Active)
		else
			SetActiveFunc(self.ActiveBuff, false)
		end
	end
end
