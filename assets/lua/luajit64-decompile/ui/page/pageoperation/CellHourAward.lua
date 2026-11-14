-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellHourAward.lua

require("UI/Item/UIItemBase")

CellHourAward = class("CellHourAward", UIItemBase)

function CellHourAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellHourAward:OnEnter()
	local g = self.UIRootObject
	local text = GOUtil.FindChildComponent(g, "btn_get/Text", "Text")

	text.text = _("Desc_Get")
	self.listItem = {}

	for i = 1, 2 do
		self["CellItem" .. i] = GOUtil.FindChildGameObject(g, "Group/Content/CellItem" .. i)

		local gItem = self["CellItem" .. i]
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.TxtTime = GOUtil.FindChildComponent(g, "tex_time", "Text")
	self.TxtGeted = GOUtil.FindChildComponent(g, "tex_tips", "Text")
	self.TxtGeted.text = _("Desc_OutOfTime")
	self.BGRecved = self:GetChildGameObject("BGRecved")
	self.BGUnRecved = self:GetChildGameObject("BGUnRecved")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "btn_get")
	self.go_Recv = self:GetChildGameObject("go_Recv")

	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)
end

function CellHourAward:OnLeave()
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)
	UnloadAllImageSprite(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function CellHourAward:UpdateData(data, listOpenActive)
	self.data = data

	for i = 1, 2 do
		local item = self.listItem[i]
		local award = self.data.award[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			item:UpdateWithNumType(infoItem)
		end

		SetActiveFunc(self["CellItem" .. i], award ~= nil)
	end

	local startHour = self.data.hour[1]
	local endHour = self.data.hour[2]

	self.TxtTime.text = startHour .. ":00" .. " ~ " .. endHour .. ":00"

	local infoOperationActive = listOpenActive
	local isGeted = infoOperationActive:IsGetIndexAward(self.data.index)
	local isTime = OperationActiveMgr:IsInTheTime(startHour, endHour)

	GOUtil.SetActive(self.TxtGeted, not isGeted and not isTime)
	SetActiveFunc(self.go_Recv, isGeted)

	local isCanRec = not isGeted and isTime
	local isNotCanRec = not isGeted and not isTime
	local imgBtnRecv = GOUtil.GetComponent(self.BtnRecv, "Image")

	SetActiveFunc(self.BtnRecv, isCanRec)
	SetActiveFunc(self.BGRecved, isCanRec)
	SetActiveFunc(self.BGUnRecved, not isCanRec)

	if isCanRec then
		DealWithListRef(self, UIUtil.SetImageGray(imgBtnRecv, 0))
	elseif isNotCanRec then
		DealWithListRef(self, UIUtil.SetImageGray(imgBtnRecv, 1))
	end
end

function CellHourAward:OnClickedBtnRecv(data)
	local infoOperationActive = OperationActiveMgr:Get(eOperationActive.Hour)
	local isGeted = infoOperationActive:IsGetIndexAward(self.data.index)
	local isTime = OperationActiveMgr:IsInTheTime(self.data.hour[1], self.data.hour[2])

	if not isTime then
		UIMgr.ShowMsg(_("Desc_GetInTime"))

		return
	end

	Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index)
end
