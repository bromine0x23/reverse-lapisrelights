-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgUseItemSelect.lua

require("UI/Page/PageRoleCard/Cell/CellUseItem")

DlgUseItemSelect = class("DlgUseItemSelect", UIPanel)

function DlgUseItemSelect:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/DlgUseItemSelect"
end

function DlgUseItemSelect:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellUseItem", "PrefabCell", GameObject)
end

function DlgUseItemSelect:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgUseItemSelect:OnLeave()
	if self.listCellItem then
		for i = 1, #self.listCellItem do
			self.listCellItem[i]:OnLeave()
		end

		if self.ScrollView then
			GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
		end
	end

	ResourceMgr.Unload(self.PrefabCell)
end

function DlgUseItemSelect:OnRegisterEvent()
	self:AddClick(self.BtnSure, self.OnClickedBtnSure)
	self:AddClick(self.BtnBatch, self.OnClickedBtnBatch)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
	Event.Instance:Add("DealWithClickAdd", self.DealWithClickAdd, self)
	Event.Instance:Add("DealWithRepeatAdd", self.DealWithRepeatAdd, self)
	Event.Instance:Add("DealWithUpAdd", self.DealWithUpAdd, self)
	Event.Instance:Add("DealWithClickSub", self.DealWithClickSub, self)
	Event.Instance:Add("DealWithRepeatSub", self.DealWithRepeatSub, self)
	Event.Instance:Add("DealWithGotoGet", self.DealWithGotoGet, self)
end

function DlgUseItemSelect:OnUnRegisterEvent()
	self:RemoveClick(self.BtnSure, self.OnClickedBtnSure)
	self:RemoveClick(self.BtnBatch, self.OnClickedBtnBatch)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	Event.Instance:Remove("DealWithClickAdd", self.DealWithClickAdd, self)
	Event.Instance:Remove("DealWithRepeatAdd", self.DealWithRepeatAdd, self)
	Event.Instance:Remove("DealWithUpAdd", self.DealWithUpAdd, self)
	Event.Instance:Remove("DealWithClickSub", self.DealWithClickSub, self)
	Event.Instance:Remove("DealWithRepeatSub", self.DealWithRepeatSub, self)
	Event.Instance:Remove("DealWithGotoGet", self.DealWithGotoGet, self)
end

function DlgUseItemSelect:OnEnter(vParam)
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = _("Desc_AddItemList")
	Text = self:GetChildComponent("Panel/BtnSure/Text", "Text")
	Text.text = Lang(12249)
	Text = self:GetChildComponent("Panel/BtnBatch/Text", "Text")
	Text.text = _("Desc_BatchAdd")
	self.TxtNeed = self:GetChildComponent("Panel/TxtNeed", "Text")
	self.BtnSure = self:GetChildGameObject("Panel/BtnSure")
	self.BtnBatch = self:GetChildGameObject("Panel/BtnBatch")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")

	self:Init(vParam)
end

function DlgUseItemSelect:Init(data)
	self.commonId = data.commonId
	self.needNum = data.needNum
	self.index = data.index
	self.listItem = ItemManager:GetListByCommonStone(self.commonId)
	self.listSelectItem = {}
	self.listPreSelectItem = {}

	if data.selList and #data.selList > 0 then
		for k, v in pairs(data.selList) do
			local tab = {}

			tab.id = v.id
			tab.num = v.num

			table.insert(self.listSelectItem, tab)
			table.insert(self.listPreSelectItem, tab)
		end
	else
		for _, v in pairs(self.listItem) do
			local temp = {
				num = 0,
				id = v.id
			}

			table.insert(self.listSelectItem, temp)
			table.insert(self.listPreSelectItem, temp)
		end
	end

	local infoItem = ItemManager:GetValueItem(self.commonId, 0)

	table.insert(self.listItem, infoItem)

	self.curIndex = 0

	self:UpdatePanel()
end

function DlgUseItemSelect:UpdatePanel()
	local scrollArea = self:GetChildGameObject("Panel/BgScroll/ScrollArea")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "Transform")
	self.ScrollView.vertical = true
	self.listCellItem = {}

	for i = 1, #self.listItem do
		local item = CellUseItem(self.PrefabCell, self.ScrollView.content.gameObject, self)

		item:Create()

		item.UIRootObject.name = i

		item:UpdateData(self.listItem[i])
		table.insert(self.listCellItem, item)

		local tab = self.listSelectItem[i]

		if tab and tab.num > 0 then
			self:UpdateSel(i)
		end
	end

	self:UpdateSumSelect()
end

function DlgUseItemSelect:SetIndex(index)
	if self.curIndex ~= index then
		self.curIndex = index
	end
end

function DlgUseItemSelect:DealWithClickAdd(index)
	self:SetIndex(index)

	if not self:CheckCondition() then
		self.isNotFull = true

		return
	end

	self:UpdateSelItem(1)
end

function DlgUseItemSelect:DealWithRepeatAdd(index)
	self:SetIndex(index)

	if self.isNotFull then
		return
	end

	if not self:CheckCondition() then
		self.isNotFull = true

		return
	end

	self:UpdateSelItem(1)
end

function DlgUseItemSelect:DealWithUpAdd(index)
	if self.isNotFull then
		self.isNotFull = nil
	end
end

function DlgUseItemSelect:DealWithClickSub(index)
	self:SetIndex(index)
	self:UpdateSelItem(2)
end

function DlgUseItemSelect:DealWithRepeatSub(index)
	self:SetIndex(index)
	self:UpdateSelItem(2)
end

function DlgUseItemSelect:UpdateSelItem(_type)
	local selNum = 1

	if _type == 1 then
		self.listSelectItem[self.curIndex].num = self.listSelectItem[self.curIndex].num + selNum
	else
		self.listSelectItem[self.curIndex].num = Mathf.Max(self.listSelectItem[self.curIndex].num - selNum, 0)
	end

	self:UpdateSumSelect()
	self:UpdateSel(self.curIndex)
end

function DlgUseItemSelect:UpdateSumSelect()
	local num = 0

	for _, v in pairs(self.listSelectItem) do
		num = num + v.num
	end

	self.TxtNeed.text = _("Desc_Need") .. "：<color=#ED5081>" .. num .. "</color>/" .. self.needNum
end

function DlgUseItemSelect:UpdateSel(index)
	local item = self.listCellItem[index]
	local num = self.listSelectItem[index].num

	item:UpdateSelData(num)
end

function DlgUseItemSelect:CheckCondition()
	if self.curIndex == 0 then
		return false
	end

	local infoItem = self.listItem[self.curIndex]
	local holdNum = ItemManager:GetItemCount(infoItem.id)
	local selNum = self.listSelectItem[self.curIndex].num

	if holdNum <= selNum then
		UIMgr.ShowMsg(_("Desc_NoMoreItem"))

		return false
	end

	local num = 0

	for _, v in pairs(self.listSelectItem) do
		num = num + v.num
	end

	if num >= self.needNum then
		UIMgr.ShowMsg(_("Desc_AlreadyAddNeedCount"))

		return false
	end

	return true
end

function DlgUseItemSelect:DealWithGotoGet()
	ItemManager:SetSweepItem({
		self.commonId,
		self.needNum
	})

	local function wrap_cb()
		self:Close()
	end

	local info = ItemManager:GetValueItem(self.commonId, 0)

	UIMgr.ShowItemTip(info, 2, true, false, wrap_cb)
end

function DlgUseItemSelect:OnClickedBtnBatch()
	local list = ItemManager:GetListByCommonStone(self.commonId)

	for k, v in pairs(self.listSelectItem) do
		v.num = 0

		self.listCellItem[k]:UpdateSelData(0)
	end

	if #list == 0 then
		UIMgr.ShowMsg(_("Desc_NoCommonStone"))

		return
	end

	local sum, need, hold = 0, 0, 0

	for k, v in pairs(list) do
		need = self.needNum - sum
		hold = v:GetCurResNum()

		if need < hold then
			self.listSelectItem[k].num = need

			self.listCellItem[k]:UpdateSelData(need)

			sum = sum + need

			break
		else
			self.listSelectItem[k].num = hold

			self.listCellItem[k]:UpdateSelData(hold)

			sum = sum + hold
		end
	end

	sum = TenaryOp(sum > self.needNum, self.needNum, sum)
	self.TxtNeed.text = _("Desc_Need") .. "：<color=#ED5081>" .. sum .. "</color>/" .. self.needNum
end

function DlgUseItemSelect:OnClickedBtnSure()
	for k, v in pairs(self.listSelectItem) do
		self.listPreSelectItem[k].num = v.num
	end

	Event.Instance:Fire("DealWithSpecialCostItem", {
		index = self.index,
		selList = self.listPreSelectItem
	})
	self:Close()
end

function DlgUseItemSelect:OnClickedBtnClose()
	self:Close()
end
