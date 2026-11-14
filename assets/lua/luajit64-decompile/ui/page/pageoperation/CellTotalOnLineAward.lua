-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellTotalOnLineAward.lua

require("UI/Item/UIItemBase")

CellTotalOnLineAward = class("CellTotalOnLineAward", UIItemBase)

function CellTotalOnLineAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTotalOnLineAward:OnEnter()
	local g = self.UIRootObject
	local text = GOUtil.FindChildComponent(g, "BtnRecv/Text", "Text")

	text.text = _("Desc_Get")
	self.listItem = {}

	for i = 1, 3 do
		self["CellItem" .. i] = GOUtil.FindChildGameObject(g, "Group/" .. i)

		local gItem = self["CellItem" .. i]
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.TxtTime = GOUtil.FindChildComponent(g, "TxtTime", "Text")
	self.TxtGeted = GOUtil.FindChildComponent(g, "TxtGeted", "Text")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "BtnRecv")

	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)
end

function CellTotalOnLineAward:OnLeave()
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)
end

function CellTotalOnLineAward:UpdateData(data, curindex)
	self.data = data

	for i = 1, 3 do
		local item = self.listItem[i]
		local award = self.data.award[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			item:UpdateWithNumType(infoItem)
		end

		SetActiveFunc(self["CellItem" .. i], award ~= nil)
	end

	local online = self.data.online

	self.TxtTime.text = _("Desc_OnLine") .. online .. _("Desc_minute")
	self.curindex = curindex

	local infoOperationActive = OperationActiveMgr:Get(self.curindex)
	local isGeted = infoOperationActive:IsGetIndexAward(self.data.index)
	local isTime = OperationActiveMgr:IsGoAssignTotalOnlineSec(self.data.online)

	SetActiveFunc(self.TxtGeted.gameObject, isGeted)
	SetActiveFunc(self.BtnRecv, not isGeted)

	if isGeted then
		return
	end

	local isCanRec = not isGeted and isTime
	local isNotCanRec = not isGeted and not isTime
	local imgBtnRecv = GOUtil.GetComponent(self.BtnRecv, "Image")

	if isCanRec then
		UIUtil.SetImageGray(imgBtnRecv, 0)
	elseif isNotCanRec then
		UIUtil.SetImageGray(imgBtnRecv, 1)
	end
end

function CellTotalOnLineAward:OnClickedBtnRecv(data)
	local infoOperationActive = OperationActiveMgr:Get(self.curindex)
	local isGeted = infoOperationActive:IsGetIndexAward(self.data.index)
	local isTime = OperationActiveMgr:IsGoAssignTotalOnlineSec(self.data.online)

	if not isTime then
		UIMgr.ShowMsg(_("Desc_GetInTime"))

		return
	end

	Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index)
end
