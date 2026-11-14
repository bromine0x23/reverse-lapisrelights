-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageAccumulatedRecharge/PageAccumulatedRecharge.lua

local RewardData = require("luaData/RewardPack")

require("UI/Page/PageAccumulatedRecharge/CellRechargeAward")

PageAccumulatedRecharge = class("PageAccumulatedRecharge", UIPanel)

function PageAccumulatedRecharge:ctor()
	self.UIPrefabPath = "UI/PanelAccumulatedRecharge/PageAccumulatedRecharge"
end

function PageAccumulatedRecharge:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickBtnClose)
	self:AddClick(self.BtnRest, self.OnClickRest)
	Event.Instance:Add("GetRechargeAward", self.ReceiveOperationActiveAward, self)
	Event.Instance:Add("CloseRecharge", self.OnClickBtnClose, self)
end

function PageAccumulatedRecharge:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickBtnClose)
	self:RemoveClick(self.BtnRest, self.OnClickRest)
	Event.Instance:Remove("GetRechargeAward", self.ReceiveOperationActiveAward, self)
	Event.Instance:Remove("CloseRecharge", self.OnClickBtnClose, self)
end

function PageAccumulatedRecharge:OnClickBtnClose()
	ShopRDL.RunAccRD()
	self:Close()
end

function PageAccumulatedRecharge:PreLoad(vParam)
	self:LoadResAsync("UI/PanelAccumulatedRecharge/CellRechargeAward", "rewardPrefab")
end

function PageAccumulatedRecharge:Purge()
	PageAccumulatedRecharge.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	ResourceMgr.Unload(self.rewardPrefab)
end

function PageAccumulatedRecharge:OnEnter(vParam)
	self.AllRecharge = Mathf.Floor(vParam.pb.record / 100)
	self.RestNum = vParam.pb.resetTimes
	self.GetList = vParam.pb.awardRecords
	self.data = vParam.data
	self.NowRecharge = self.AllRecharge

	for i = self.RestNum, 1, -1 do
		self.NowRecharge = self.NowRecharge - self.data.Params[self.RestNum][#self.data.Params[self.RestNum]]
	end

	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.Tips = self:GetChildGameObject("Panel/Tips")
	self.ObjRest = self:GetChildGameObject("Panel/Main/Rest")
	self.RestDot = self:GetChildGameObject("Panel/Main/Rest/Dot")
	self.BtnRest = self:GetChildGameObject("Panel/Main/Rest/Button")
	self.ImgRest = self:GetChildComponent("Panel/Main/Rest/Button", "Image")
	self.TexTipRest = self:GetChildComponent("Panel/Main/Rest/TexTips", "Text")
	self.TexRemain = self:GetChildComponent("Panel/Main/Rest/TexRemain", "Text")
	self.TexTitle = self:GetChildComponent("Panel/title/TexTitle", "Text")
	self.TexActiveTime = self:GetChildComponent("Panel/TexActiveTime", "Text")
	self.TexActiveTimeValue = self:GetChildComponent("Panel/TexActiveTimeValue", "Text")
	self.TexHistroy = self:GetChildComponent("Panel/TexHistroy", "Text")
	self.TexHistroyValue = self:GetChildComponent("Panel/TexHistroyValue", "Text")
	self.TexRecharge = self:GetChildComponent("Panel/Tips/TexRecharge", "Text")
	self.TexRechargeValue = self:GetChildComponent("Panel/Tips/TexRechargeValue", "Text")
	self.ImgProgress = self:GetChildComponent("Panel/ImgProgress", "Image")
	self.MainAnim = self:GetChildComponent("Panel/Main", "Animator")
	self.giftList = {}

	for i = 1, 6 do
		self.giftList[i] = self:GetChildComponent("Panel/GiftGroup/ImgGift" .. i, "Image")
	end

	self:Init()
	self:InitScrollViewPanel()
end

function PageAccumulatedRecharge:Init()
	self.TexRecharge.text = _("Desc_TopUpNow")
	self.TexTitle.text = _("Desc_TopUpReset")
	self.TexTitle.text = _("Desc_TopUpReward")
	self.NowGear = self.data.Params[self.RestNum + 1]
	self.TexActiveTimeValue.text = OperationActiveMgr:GetDayHourTime(self.data.EndTime)
	self.TexHistroy.text = _("Desc_TopUpHistory")
	self.TexHistroyValue.text = string.format(_("Desc_TopUpPopUp"), tostring(self.AllRecharge))
	self.TexRechargeValue.text = string.format(_("Desc_TopUpPopUp"), tostring(self.NowRecharge))

	self:UpdateProgress()

	if self:CheckAllReward() then
		self:SetRestView()
		self.ObjRest:SetActive(true)
	else
		self.ObjRest:SetActive(false)
	end
end

function PageAccumulatedRecharge:SetRestView()
	if ShopManager.needAccDot then
		self.RestDot:SetActive(true)
	else
		self.RestDot:SetActive(false)
	end

	ShopManager.needAccDot = false
	self.TexTipRest.text = _("Desc_TopUpInfo")
	self.TexRemain.text = _("Desc_RemainingTime") .. " " .. #self.data.Params - 1 - self.RestNum .. "/" .. #self.data.Params - 1

	if #self.data.Params - 1 - self.RestNum == 0 then
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgRest, 1))
		self.RestDot:SetActive(false)
	end
end

function PageAccumulatedRecharge:InitScrollViewPanel()
	local ScrollArea = self:GetChildGameObject("Panel/Main/ScrollArea")
	local content = self:GetChildComponent("Panel/Main/ScrollArea/Content", "Transform")
	local count = #self.NowGear

	self.RewardData = {}

	local posIndex

	for k, v in pairs(self.data.DailyTime[self.RestNum + 1]) do
		local data = {}

		data.index = self.RestNum * #self.NowGear + k
		data.isGet = self:IsGetReward(self.RestNum * #self.NowGear + k)
		data.NowRecharge = self.NowRecharge
		data.Aim = self.NowGear[k]
		data.ItemList = RewardData[v].PackItem

		if posIndex == nil and not data.isGet and self.NowRecharge >= data.Aim then
			posIndex = k
		end

		table.insert(self.RewardData, data)
	end

	local function AddClick(item)
		return
	end

	local function CellUpdate(item, index)
		item:UpdateData(self.RewardData[index])
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.rewardPrefab, CellRechargeAward, self, true, AddClick, CellUpdate)

	if posIndex == nil then
		posIndex = 1

		if #self.GetList ~= 0 then
			posIndex = self.GetList[#self.GetList] + 1 - #self.NowGear * self.RestNum
		end
	end

	local pos = GetContentPos(self.UIScrollTool.ScrollView, count, posIndex, true)

	if posIndex == #self.NowGear then
		pos = pos + 6
	end

	self.UIScrollTool:SetInitPos(Vector3(pos, 0, 0))
end

function PageAccumulatedRecharge:UpdateScrollViewPanel()
	self.MainAnim:Play("OnReset_Anim", 0, 0)

	self.RewardData = {}

	for k, v in pairs(self.data.DailyTime[self.RestNum + 1]) do
		local data = {}

		data.index = self.RestNum * #self.NowGear + k
		data.isGet = self:IsGetReward(self.RestNum * #self.NowGear + k)
		data.NowRecharge = self.NowRecharge
		data.Aim = self.NowGear[k]
		data.ItemList = RewardData[v].ItemList

		table.insert(self.RewardData, data)
	end

	self.UIScrollTool:UpdateListData(self.RewardData)
end

function PageAccumulatedRecharge:UpdateProgress()
	local ProgressValue = {
		150,
		316,
		481,
		650,
		815,
		980
	}
	local distance = 0
	local index = 0

	if self.NowRecharge >= self.NowGear[#self.NowGear] then
		distance = ProgressValue[#ProgressValue]
	else
		for key, value in ipairs(self.NowGear) do
			if value <= self.NowRecharge and self.NowRecharge < self.NowGear[key + 1] then
				index = key
				distance = ProgressValue[index]

				break
			end
		end
	end

	if self.NowRecharge < self.NowGear[#self.NowGear] then
		if index == 0 then
			distance = self.NowRecharge / self.NowGear[index + 1] * ProgressValue[index + 1]
		else
			distance = distance + (self.NowRecharge - self.NowGear[index]) / (self.NowGear[index + 1] - self.NowGear[index]) * (ProgressValue[index + 1] - distance)
		end
	end

	self.ImgProgress.transform.sizeDelta = Vector2(distance, self.ImgProgress.transform.sizeDelta.y)
	self.Tips.transform.localPosition = Vector3(self.ImgProgress.transform.localPosition.x + distance, self.Tips.transform.localPosition.y, self.Tips.transform.localPosition.z)

	local GiftState = {
		"UI/PanelAccumulatedRecharge/AtlasAccumulatedRecharge/BG_shop_totalbuy_line_04",
		"UI/PanelAccumulatedRecharge/AtlasAccumulatedRecharge/BG_shop_totalbuy_line_05",
		"UI/PanelAccumulatedRecharge/AtlasAccumulatedRecharge/BG_shop_totalbuy_mask_03"
	}

	for key, value in ipairs(self.giftList) do
		if self.NowRecharge < self.data.Params[self.RestNum + 1][key] then
			UIUtil.SetImageSprite(value, GiftState[1], self)
		elseif self:IsGetReward(self.RestNum * #self.NowGear + key) then
			UIUtil.SetImageSprite(value, GiftState[3], self)
		else
			UIUtil.SetImageSprite(value, GiftState[2], self)
		end
	end
end

function PageAccumulatedRecharge:IsGetReward(index)
	for key, value in pairs(self.GetList) do
		if value == index - 1 then
			return true
		end
	end

	return false
end

function PageAccumulatedRecharge:CheckAllReward()
	for i = 1, #self.NowGear do
		if not self:IsGetReward(self.RestNum * #self.NowGear + i) then
			return false
		end
	end

	return true
end

function PageAccumulatedRecharge:ReceiveOperationActiveAward(index)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			table.insert(self.GetList, index - 1)
			self:Init()

			self.RewardData[index - self.RestNum * #self.NowGear].isGet = true

			self.UIScrollTool:UpdateListDataKeepPos(self.RewardData)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestOperationActiveAward(self.data.ID, index, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageAccumulatedRecharge:OnClickRest()
	if self.RestNum >= #self.data.Params - 1 then
		UIMgr.ShowMsg("已无重置次数")

		return
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			ShopManager.needAccDot = true
			self.RestNum = self.RestNum + 1
			self.GetList = {}
			self.NowRecharge = self.NowRecharge - self.data.Params[self.RestNum][#self.data.Params[self.RestNum]]

			self:Init()
			self:UpdateScrollViewPanel()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestOnRestRecharge(self.data.ID, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end
