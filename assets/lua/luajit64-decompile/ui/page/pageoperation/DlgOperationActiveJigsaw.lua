-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveJigsaw.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellJigsaw")
require("UI/Page/PageOperation/CellJigsawReward")

local RewardData = require("luaData/RewardPack")

DlgOperationActiveJigsaw = class("DlgOperationActiveJigsaw", UIItemBase)

function DlgOperationActiveJigsaw:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveJigsaw:Purge()
	DlgOperationActiveJigsaw.base.Purge(self)
	UnloadAllImageSprite(self)
	self:OnUnRegisterEvent()

	for _, value in pairs(self.JiasawGroup) do
		value:OnLeave()
	end

	for _, value in pairs(self.RewardGroup) do
		value:OnLeave()
	end

	self:ClearTimer()
	UIMgr.RemoveUpdatePanel(self)
	self.infoActive:ClearOperationSpine()
end

function DlgOperationActiveJigsaw:ClearTimer()
	if self.timer1 ~= nil then
		TimerMgr.RemoveTimer(self.timer1)

		self.timer1 = nil
	end
end

function DlgOperationActiveJigsaw:OnRegisterEvent()
	self:AddClick(self.ObjState2, self.GetBigReward)
	self:AddClick(self.BtnJum, self.JumpBigReward)
	self:AddClick(self.ObjBigReward, self.ClickBigReward)
	Event.Instance:Add("CellJigaswSelect", self.SelectJigasw, self)
	Event.Instance:Add("GetJigsawReward", self.GetJigsawReward, self)
end

function DlgOperationActiveJigsaw:OnUnRegisterEvent()
	self:RemoveClick(self.ObjState2, self.GetBigReward)
	self:RemoveClick(self.BtnJum, self.JumpBigReward)
	self:RemoveClick(self.ObjBigReward, self.ClickBigReward)
	Event.Instance:Remove("CellJigaswSelect", self.SelectJigasw, self)
	Event.Instance:Remove("GetJigsawReward", self.GetJigsawReward, self)
end

function DlgOperationActiveJigsaw:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell
	self.isShowClose = vParam.isShowClose
	self.PrefabDlg = vParam.PrefabDlg
	self.TaskSign = {
		{
			1,
			2,
			3
		},
		{
			4,
			5,
			6
		},
		{
			7,
			8,
			9
		},
		{
			1,
			4,
			7
		},
		{
			2,
			5,
			8
		},
		{
			3,
			6,
			9
		},
		{
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		}
	}
	self.JigsawAnimGroup = {}
	self.JiasawGroup = {}
	self.JiasawData = {}
	self.RewardGroup = {}
	self.RewardData = {}

	local g = self.UIRootObject

	self.LineGroup = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/LineGroup")
	self.FX = GOUtil.FindChildGameObject(g, "Panel/Model/Fx/FX")
	self.TexTips = GOUtil.FindChildComponent(g, "Panel/Model/Pic/RewardGroup/Tips/TexTips", "Text")
	self.ObjBigReward = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/RewardGroup/BigReward")
	self.ImgBigReward = GOUtil.FindChildComponent(g, "Panel/Model/Pic/RewardGroup/BigReward", "Image")
	self.TexRewardNum = GOUtil.FindChildComponent(g, "Panel/Model/Pic/RewardGroup/Text", "Text")
	self.BtnJum = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/RewardGroup/State3/Button")
	self.TextGet = GOUtil.FindChildComponent(g, "Panel/Model/Pic/RewardGroup/State2/Text", "Text")
	self.TextIsGet = GOUtil.FindChildComponent(g, "Panel/Model/Pic/RewardGroup/State3/Text", "Text")
	self.TextLook = GOUtil.FindChildComponent(g, "Panel/Model/Pic/RewardGroup/State3/Button/Text", "Text")
	self.TextGet.text = _("Desc_Get")
	self.TextIsGet.text = _("Desc_Has_Get")
	self.TextLook.text = _("DlgAdvancedCard_TextBtnCheck")

	for i = 1, 3 do
		self["ObjState" .. i] = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/RewardGroup/State" .. i)
	end

	for i = 1, 9 do
		local cell = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/JigsawGroup/CellJigsaw" .. i)
		local CellJigsaw = CellJigsaw(cell)

		CellJigsaw:InitItemByRoot(cell)
		table.insert(self.JiasawGroup, CellJigsaw)
	end

	for i = 1, 6 do
		local reward = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/RewardGroup/CellReward" .. i)
		local CellJigsawReward = CellJigsawReward(reward)

		CellJigsawReward:InitItemByRoot(reward)
		table.insert(self.RewardGroup, CellJigsawReward)
	end

	for i = 1, 9 do
		local texConfident = GOUtil.FindChildComponent(g, "Panel/Model/Pic/JigsawGroup/CellJigsaw" .. i .. "/Panel/Main/TexConfident", "Text")

		texConfident.fontSize = 24
	end

	self:OnRegisterEvent()
	UIMgr.SetUpdatePanel(self)
end

function DlgOperationActiveJigsaw:CompareTaskState()
	return
end

function DlgOperationActiveJigsaw:SelectJigasw(index)
	for key, value in pairs(self.JiasawData) do
		if key == index then
			value.select = true
		else
			value.select = false
		end
	end

	self:UpdateJigsaw()
end

function DlgOperationActiveJigsaw:UpdateJigsaw(index)
	if index ~= nil and self.JiasawGroup[index] ~= nil then
		local cell = self.JiasawGroup[index]

		cell:UpdateData(self.JiasawData[index])

		return
	end

	for key, value in pairs(self.JiasawGroup) do
		value:UpdateData(self.JiasawData[key])
	end
end

function DlgOperationActiveJigsaw:UpdateReward(index)
	if index == #self.RewardData then
		self:UpdateBigReward()

		return
	end

	if index ~= nil and self.RewardGroup[index] ~= nil then
		local cell = self.RewardGroup[index]

		cell:UpdateData(self.RewardData[index])

		return
	end

	for key, value in pairs(self.RewardGroup) do
		value:UpdateData(self.RewardData[key])
	end

	self:UpdateBigReward()
end

function DlgOperationActiveJigsaw:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationBg(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveJigsaw:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw

	self:UpdateData(infoActive)
end

function DlgOperationActiveJigsaw:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:SetData()

	self.infoItem = ItemManager:GetValueItem(self.RewardData[#self.RewardData].itemList[1][1], self.RewardData[#self.RewardData].itemList[1][2])

	local path = self.infoItem:GetIcon()

	UIUtil.SetImageSprite(self.ImgBigReward, path, self)
	self:UpdateJigsaw()
	self:UpdateReward()
	self:DealWithLocalization(self.ActiveID)
	self.FX:SetActive(false)

	for key, value in pairs(self.JiasawGroup) do
		value:StopFX()
	end

	if #self.JigsawAnimGroup ~= 0 then
		for key, value in pairs(self.JigsawAnimGroup) do
			if self.JiasawGroup[value] ~= nil then
				self.JiasawGroup[value]:PlayFX()
			end
		end

		self.JigsawAnimGroup = {}

		if self:CheckComplete() then
			self:ClearTimer()

			self.timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 1.5, function()
				self.timer1 = nil

				self.FX:SetActive(true)
				self.LineGroup:SetActive(false)
			end, nil)
		end
	elseif self:CheckComplete() then
		self.LineGroup:SetActive(false)
	end
end

function DlgOperationActiveJigsaw:SetData()
	self.JiasawData = {}
	self.RewardData = {}

	local uiInfo = InfoOperationActive:GetOperationUIInfo(self.ActiveID)
	local list = TaskManager:GetTaskListDataByID(self.infoActive.data.DailyTime[1][1])

	for key, value in pairs(list.List) do
		local info = {}
		local task = TaskManager:Get(value)

		info.index = key
		info.img = uiInfo.Pic[key][1]
		info.title = task:GetName()
		info.des = task:GetDescTitle()
		info.condition = task:GetCurNum() .. "/" .. task:GetNeedNum()
		info.complete = task:IsComplete()

		if info.complete and not TaskManager.jigsawCompleteList[key] then
			TaskManager.jigsawCompleteList[key] = task

			table.insert(self.JigsawAnimGroup, key)
		end

		info.FromWhere = task.data.FromWhere
		info.select = false

		table.insert(self.JiasawData, info)
	end

	for key, value in pairs(self.infoActive.data.Params) do
		local info = {}

		info.index = key
		info.itemList = RewardData[value[1]].ItemList
		info.state = 1

		local num, target = self:GetRewardProgress(key)

		info.progress = _("PageChpater_rate") .. num .. "/" .. target

		if num == target then
			if self:CheckIsGeted(key) then
				info.state = 3
			else
				info.state = 2
			end
		end

		table.insert(self.RewardData, info)
	end
end

function DlgOperationActiveJigsaw:GetRewardProgress(index)
	local num = 0
	local target = #self.TaskSign[index]

	for key, value in pairs(self.TaskSign[index]) do
		if self.JiasawData[value].complete then
			num = num + 1
		end
	end

	return num, target
end

function DlgOperationActiveJigsaw:GetJigsawReward(index)
	self:UpdateReward(index)

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.RewardData[index].state = 3

			table.insert(self.infoActive.pb.awardRecords, index - 1)
			self:UpdateReward(index)
			Event.Instance:Fire("UpdateTapDot")
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestOperationActiveAward(self.infoActive.data.ID, index, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgOperationActiveJigsaw:CheckIsGeted(index)
	for _, value in pairs(self.infoActive.pb.awardRecords) do
		if value == index - 1 then
			return true
		end
	end

	return false
end

function DlgOperationActiveJigsaw:ClickBigReward()
	UIMgr.ShowItemTip(self.infoItem)
end

function DlgOperationActiveJigsaw:UpdateBigReward()
	local name = self.infoItem:GetNameAndDesc()
	local info = self.RewardData[#self.RewardData]

	self.TexRewardNum.text = "×" .. self.RewardData[#self.RewardData].itemList[1][2]
	self.TexTips.text = "すべてのパネル解放で<color=#E12C5A>コンプリート報酬 " .. name .. "</color>を獲得できます" .. "    " .. OperationActiveMgr:GetOpenTime(self.infoActive.data.ShowEndTime)

	for i = 1, 3 do
		if i == info.state then
			self["ObjState" .. i]:SetActive(true)
		else
			self["ObjState" .. i]:SetActive(false)
		end
	end
end

function DlgOperationActiveJigsaw:GetBigReward()
	self:GetJigsawReward(#self.RewardData)
end

function DlgOperationActiveJigsaw:JumpBigReward()
	if self.infoActive.data.BuffType[1] then
		OperationActiveMgr.Tag = eOperationActive.Jigsaw

		DlgItemTip.GoToFrom(self.infoActive.data.BuffType[1], nil)
	end
end

function DlgOperationActiveJigsaw:CheckComplete()
	for _, value in pairs(self.JiasawData) do
		if not value.complete then
			return false
		end
	end

	return true
end

function DlgOperationActiveJigsaw:OnUpdateSecond()
	if self.infoActive then
		local name = self.infoItem:GetNameAndDesc()

		self.TexTips.text = "全てのパネル解放で、<color=#E12C5A>コンプリートボーナス" .. name .. "</color>" .. "がもらえます！    " .. OperationActiveMgr:GetOpenTime(self.infoActive.data.ShowEndTime)
	end
end
