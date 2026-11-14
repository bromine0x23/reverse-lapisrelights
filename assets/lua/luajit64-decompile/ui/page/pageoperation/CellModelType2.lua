-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellModelType2.lua

require("UI/Item/UIItemBase")

CellModelType2 = class("CellModelType2", UIItemBase)

function CellModelType2:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellModelType2:OnEnter()
	local g = self.UIRootObject

	self.GoDot = GOUtil.FindChildGameObject(g, "GoDot")
	self.Recved = GOUtil.FindChildGameObject(g, "Recved")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "BtnRecv")
	self.img_recv = GOUtil.FindChildGameObject(g, "img_recv")
	self.BGRecved = GOUtil.FindChildGameObject(g, "BGRecved")
	self.BGUnRecved = GOUtil.FindChildGameObject(g, "BGUnRecved")

	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)

	self.TxtTime = GOUtil.FindChildComponent(g, "go_time/TxtTime", "Text")
	self.FX_UI_Activity = GOUtil.FindChildGameObject(g, "FX_UI_Activity")
	self.img_extra = GOUtil.FindChildComponent(g, "img_extra", "Image")
	self.img_Recved = GOUtil.FindChildGameObject(g, "Recved/img_Recved")
	self.tex_Recved = GOUtil.FindChildComponent(g, "Recved/tex_Recved", "Text")
	self.img_No_Recved = self:GetChildGameObject("Recved/img_No_Recved")
	self.Cell = GOUtil.FindChildGameObject(g, "Group/CellItem")

	SetActiveFunc(self.Cell, false)

	local scrollArea = GOUtil.FindChildGameObject(g, "Group")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	self.ScrollView.horizontal = true
end

function CellModelType2:OnLeave()
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)
	UnloadAllImageSprite(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function CellModelType2:ClearCell()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
end

function CellModelType2:UpdateData(data, listOpenActive)
	local day = data.index

	self.data = data
	self.infoActive = listOpenActive
	self.curindex = listOpenActive.id
	self.Day = OperationActiveMgr:GetBirthdayDay(self.infoActive)

	local canRecv = self.Day == self.data.index
	local isTimeOut = self.Day > self.data.index
	local isRecv = self.infoActive:IsGetIndexAward(self.data.index)
	local colorTime = string.format("<color=#585e62>%s</color>", OperationActiveMgr:GetBirthdayDayTime(self.infoActive, self.data.index))

	if not canRecv then
		colorTime = string.format("<color=#585e62>%s</color>", OperationActiveMgr:GetBirthdayDayTime(self.infoActive, self.data.index))
	end

	self.TxtTime.text = colorTime

	self:ClearCell()

	local pack = self.data.award

	self.listItem = {}

	SetActiveFunc(self.Cell, true)

	for i = 1, #pack do
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

	SetActiveFunc(self.GoDot, canRecv and not isRecv)
	SetActiveFunc(self.Recved, isTimeOut or isRecv)
	SetActiveFunc(self.BtnRecv, canRecv and not isRecv)
	SetActiveFunc(self.BGRecved, canRecv and not isRecv)
	SetActiveFunc(self.BGUnRecved, not canRecv or isRecv)
	SetActiveFunc(self.FX_UI_Activity, canRecv and not isRecv)
	SetActiveFunc(self.img_extra.gameObject, self.data.isExtra == 1)
	SetActiveFunc(self.tex_Recved.gameObject, not canRecv and not isRecv)
	SetActiveFunc(self.img_No_Recved, not canRecv and not isRecv)

	self.tex_Recved.text = _("Desc_StaleDated")

	SetActiveFunc(self.img_Recved, isRecv)

	local gray = TenaryOp(not isRecv, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.img_extra, gray))
end

function CellModelType2:OnClickedBtnRecv(data)
	local infoOperationActive = OperationActiveMgr:Get(self.curindex)
	local canRecv = self.Day >= self.data.index
	local isRecv = infoOperationActive:IsGetIndexAward(self.data.index)

	if not isRecv and not canRecv then
		UIMgr.ShowMsg(_("Desc_Waiting"))

		return
	end

	Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index)
end
