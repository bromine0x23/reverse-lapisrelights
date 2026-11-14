-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellCommon1.lua

require("UI/Item/UIItemBase")

CellCommon1 = class("CellCommon1", UIItemBase)

function CellCommon1:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCommon1:OnEnter()
	local g = self.UIRootObject

	self.BGRecved = GOUtil.FindChildGameObject(g, "type/BGRecved")
	self.BGUnRecved = GOUtil.FindChildGameObject(g, "type/BGUnRecved")
	self.GoDot = GOUtil.FindChildGameObject(g, "type/GoDot")
	self.Recved = GOUtil.FindChildGameObject(g, "type/Recved")
	self.img_recved = GOUtil.FindChildGameObject(g, "type/Recved/img_recved")
	self.img_unrecved = GOUtil.FindChildGameObject(g, "type/Recved/img_unrecved")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "type/BtnRecv")

	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)

	self.TxtTime = GOUtil.FindChildComponent(g, "type/go_time/TxtTime", "Text")
	self.FX_UI_Activity = GOUtil.FindChildGameObject(g, "type/FX_UI_Activity")
	self.Fx_recved = GOUtil.FindChildGameObject(g, "type/Recved/img_recved/Particle System")
	self.ani_recved = self:GetChildComponent("type/Recved/img_recved/Image", "Animator")
	self.Cell = GOUtil.FindChildGameObject(g, "type/Group/CellItem")

	SetActiveFunc(self.Cell, false)

	local scrollArea = GOUtil.FindChildGameObject(g, "type/Group")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	self.ScrollView.horizontal = true
end

function CellCommon1:OnLeave()
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)
	UnloadAllImageSprite(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end
end

function CellCommon1:ClearCell()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
end

function CellCommon1:UpdateData(data, listOpenActive, indexDay, count, recvGetAwardList)
	local day = data.index

	self.data = data
	self.infoActive = listOpenActive
	self.curindex = listOpenActive.id
	self.Day = self.infoActive.pb.record

	local isTimeOut = 0

	if indexDay then
		self.Day = indexDay
		isTimeOut = TenaryOp(self.Day > self.data.index, 2, 1)
	end

	local canRecv = self.Day >= self.data.index
	local isRecv = self.infoActive:IsGetIndexAward(self.data.index)

	if self.infoActive.data.UIType == eOperationActive.CommonThree or self.infoActive.data.UIType == eOperationActive.CommonFour then
		local colorTime = string.format("<color=#585e62>%s</color>", self.data.index)

		if self.Day >= self.data.index and not isRecv and (isTimeOut == 1 or isTimeOut == 0) then
			colorTime = string.format("<color=#ffffff>%s</color>", self.data.index)
		end

		self.TxtTime.text = colorTime
	else
		local colorTime = string.format("<color=#585e62>%s日目</color>", self.data.index)

		if self.Day >= self.data.index and not isRecv and (isTimeOut == 1 or isTimeOut == 0) then
			colorTime = string.format("<color=#ffffff>%s日目</color>", self.data.index)
		end

		self.TxtTime.text = colorTime
	end

	self:ClearCell()

	local pack

	if self.data.award then
		pack = self.data.award
	else
		pack = OperationActiveMgr:GetRewardPackData(self.infoActive.data.TypeReward[self.data.index]).PackItem
	end

	self.listItem = {}

	SetActiveFunc(self.Cell, true)

	for i = 1, 1 do
		local award = pack[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2], nil, award[3])
			local gItem = GOUtil.Instantiate(self.Cell, self.ScrollView.content.gameObject)
			local item = CellItem(gItem)

			item:InitItemByRoot(gItem)

			if award[2] == 0 then
				item:UpdateNoNumType(infoItem)
			else
				item:UpdateWithNumType(infoItem)
			end

			table.insert(self.listItem, item)
		end
	end

	SetActiveFunc(self.Cell, false)

	if #pack <= 2 then
		self.ScrollView.horizontal = false
	else
		self.ScrollView.horizontal = true
	end

	if recvGetAwardList then
		for i = 1, #recvGetAwardList do
			SetActiveFunc(self.Fx_recved, recvGetAwardList[i] == self.data.index)

			self.ani_recved.enabled = recvGetAwardList[i] == self.data.index
		end

		if #recvGetAwardList == 0 then
			SetActiveFunc(self.Fx_recved, false)

			self.ani_recved.enabled = false
		end

		recvGetAwardList = {}
	else
		SetActiveFunc(self.Fx_recved, false)

		self.ani_recved.enabled = false
	end

	SetActiveFunc(self.GoDot, (isTimeOut == 1 or isTimeOut == 0) and canRecv and not isRecv)
	SetActiveFunc(self.BtnRecv, (isTimeOut == 1 or isTimeOut == 0) and not isRecv)
	SetActiveFunc(self.Recved, isTimeOut == 2 or isRecv)
	SetActiveFunc(self.BGRecved, (isTimeOut == 1 or isTimeOut == 0) and canRecv and not isRecv)
	SetActiveFunc(self.BGUnRecved, isTimeOut == 2 or not canRecv or isRecv)
	SetActiveFunc(self.FX_UI_Activity, (isTimeOut == 1 or isTimeOut == 0) and canRecv and not isRecv)
	SetActiveFunc(self.img_recved, isRecv)
	SetActiveFunc(self.img_unrecved, not isRecv)

	if OperationActiveMgr.PageOperationActiveType == 1 then
		if listOpenActive.data.UIType == eOperationActive.CommonThree then
			self.UIRootObject.transform.localScale = Vector3(1.1, 1.1, 1.1)
		elseif listOpenActive.data.UIType == eOperationActive.CommonOne then
			if count == 5 then
				GOUtil.SetRectTransformSizeDelta(self.listItem[1].UIRootObject, 161, 161)
				GOUtil.SetRectTransformSizeDelta(self.UIRootObject, 214, 318)
			elseif count == 6 then
				GOUtil.SetRectTransformSizeDelta(self.listItem[1].UIRootObject, 161, 161)
				GOUtil.SetRectTransformSizeDelta(self.UIRootObject, 214, 318)
			elseif count == 7 then
				GOUtil.SetRectTransformSizeDelta(self.listItem[1].UIRootObject, 152, 152)
				GOUtil.SetRectTransformSizeDelta(self.UIRootObject, 185, 272)
			end
		end
	end
end

function CellCommon1:OnClickedBtnRecv(data)
	local infoOperationActive = OperationActiveMgr:Get(self.curindex)
	local canRecv = self.Day >= self.data.index
	local isRecv = infoOperationActive:IsGetIndexAward(self.data.index)

	if not isRecv and not canRecv then
		UIMgr.ShowMsg(_("Desc_Waiting"))

		return
	end

	TaskManager.commonAwardTomorrowList = {}

	if self.infoActive.data.TypeReward[self.data.index + 1] then
		local pack = OperationActiveMgr:GetRewardPackData(self.infoActive.data.TypeReward[self.data.index + 1]).PackItem

		for i = 1, 1 do
			local award = pack[i]

			if award then
				table.insert(TaskManager.commonAwardTomorrowList, award)
			end
		end
	end

	self.recvGetAwardList = {}

	table.insert(self.recvGetAwardList, self.data.index)

	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0, function()
		OperationActiveMgr.IsActiveCommon = true

		Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index)
	end, nil)
end
