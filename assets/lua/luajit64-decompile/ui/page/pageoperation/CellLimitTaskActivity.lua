-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellLimitTaskActivity.lua

require("UI/Item/UIItemBase")

CellLimitTaskActivity = class("CellLimitTaskActivity", UIItemBase)

function CellLimitTaskActivity:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellLimitTaskActivity:OnEnter()
	local g = self.UIRootObject
	local text = GOUtil.FindChildComponent(g, "BtnRecv/Text", "Text")

	text.text = _("Desc_Get")
	text = GOUtil.FindChildComponent(g, "BtnGo/Text", "Text")
	text.text = _("UI_Go")
	text = GOUtil.FindChildComponent(g, "GoGeted", "Text")
	text.text = "- " .. _("Desc_TaskFinish") .. " -"
	self.listItem = {}

	for i = 1, 4 do
		self["CellItem" .. i] = GOUtil.FindChildGameObject(g, "Award/Group/" .. i)

		local gItem = self["CellItem" .. i]
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.TxtLimit = GOUtil.FindChildComponent(g, "TxtTitle", "Text")
	self.TxtRate = GOUtil.FindChildComponent(g, "Bar/Text", "Text")
	self.ImgBar = GOUtil.FindChildComponent(g, "Bar/Image", "Image")
	self.GoGeted = GOUtil.FindChildGameObject(g, "GoGeted")
	self.GoRecommend = GOUtil.FindChildGameObject(g, "GoRecommend")
	self.BtnGo = GOUtil.FindChildGameObject(g, "BtnGo")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "BtnRecv")

	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)
	self:AddClick(self.BtnGo, self.OnClickedBtnGo)

	self.mask = self:GetChildGameObject("mask")
end

function CellLimitTaskActivity:OnLeave()
	for i = 1, #self.listItem do
		self.listItem[i]:OnLeave()
	end

	self:RemoveClick(self.BtnGo, self.OnClickedBtnGo)
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)
end

function CellLimitTaskActivity:UpdateData(taskId, index)
	self.info = TaskManager:Get(taskId)
	self.TxtLimit.text = self.info:GetDescTitle()

	local curNum = self.info:GetCurNum()
	local needNum = self.info:GetNeedNum()

	if needNum <= curNum then
		curNum = needNum
	end

	self.TxtRate.text = curNum .. "/" .. needNum

	local rate = curNum / needNum

	if rate > 1 then
		rate = 1
	end

	self.ImgBar.fillAmount = rate

	local isComple = self.info:IsComplete()

	SetActiveFunc(self.BtnGo, not isComple and not isGeted)

	local isGeted = self.info:IsGetAward()

	SetActiveFunc(self.GoGeted, isGeted)
	SetActiveFunc(self.BtnRecv, isComple and not isGeted)

	if #self.info.data.FromWhere <= 0 then
		SetActiveFunc(self.BtnGo, false)
	end

	local listAward = self.info.data.Reward

	self.listAward = listAward

	for i = 1, 4 do
		local goItem = self["CellItem" .. i]
		local item = self.listItem[i]
		local award = listAward[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			item:UpdateWithNumType(infoItem)
			item:SetGeted(isGeted)
			SetActiveFunc(goItem, true)
		else
			SetActiveFunc(goItem, false)
		end
	end

	if self.taskListData == nil then
		self.taskListData = OperationActiveMgr:GetLimitActivityList()
	end

	GOUtil.SetActive(self.GoRecommend, table.contains(self.taskListData.RecommendTask, taskId))
end

function CellLimitTaskActivity:OnClickedBtnRecv()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			Event.Instance:Fire("UpdateTaskAndAward")
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	table.insert(TaskManager.integralList, self.listAward[1])
	NetManager:RequestTaskChange({
		self.info.pb.id
	}, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function CellLimitTaskActivity:OnClickedBtnGo()
	if self.info and #self.info.data.FromWhere > 0 then
		DlgItemTip.GoToFrom(self.info.data.FromWhere[1])
	end
end
