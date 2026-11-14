-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Cell/CellUseItem.lua

require("UI/Item/UIItemBase")

CellUseItem = class("CellUseItem", UIItemBase)

function CellUseItem:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellUseItem:Create(vParam)
	CellUseItem.base.Create(self, vParam)
end

function CellUseItem:OnEnter()
	local g = self.UIRootObject
	local gItem = GOUtil.FindChildGameObject(g, "Cell")

	self.item = CellItem(gItem)

	self.item:InitItemByRoot(gItem)

	self.GoAdd = GOUtil.FindChildGameObject(g, "Add")
	self.Goto = GOUtil.FindChildGameObject(g, "Goto")
	self.GoSub = GOUtil.FindChildGameObject(g, "Sub")
	self.TxtUse = GOUtil.FindChildComponent(g, "TxtUse", "Text")

	self:AddListener(self.GoAdd, self.OnPointerDownAddItem, EventTriggerType.PointerDown)
	self:AddListener(self.GoAdd, self.OnPointerUpAddItem, EventTriggerType.PointerUp)
	self:AddListener(self.GoAdd, self.OnPointerRepeatAddItem, EventTriggerType.PointerRepeat)
	self:AddListener(self.GoSub, self.OnPointerDownSubItem, EventTriggerType.PointerDown)
	self:AddListener(self.GoSub, self.OnPointerUpSubItem, EventTriggerType.PointerUp)
	self:AddListener(self.GoSub, self.OnPointerRepeatSubItem, EventTriggerType.PointerRepeat)
	self:AddClick(self.Goto, self.OnClickedGoto)
end

function CellUseItem:OnLeave()
	if self.item and self.item.OnLeave then
		self.item:OnLeave()
	end

	self:RemoveListener(self.GoAdd, self.OnPointerDownAddItem, EventTriggerType.PointerDown)
	self:RemoveListener(self.GoAdd, self.OnPointerUpAddItem, EventTriggerType.PointerUp)
	self:RemoveListener(self.GoAdd, self.OnPointerRepeatAddItem, EventTriggerType.PointerRepeat)
	self:RemoveListener(self.GoSub, self.OnPointerDownSubItem, EventTriggerType.PointerDown)
	self:RemoveListener(self.GoSub, self.OnPointerUpSubItem, EventTriggerType.PointerUp)
	self:RemoveListener(self.GoSub, self.OnPointerRepeatSubItem, EventTriggerType.PointerRepeat)
	self:RemoveClick(self.Goto, self.OnClickedGoto)
end

function CellUseItem:UpdateData(info, extra)
	if info == nil then
		return
	end

	self.info = info
	self.extra = extra

	local hold = info:GetNum()

	if hold > 0 then
		self.item:UpdateWithNumType(info)
	else
		self.item:UpdateNoNumType(info)

		if self.extra and self.extra ~= 0 then
			local path = self.info:GetIcon() .. "_0" .. self.extra

			self.item:ResetItemIcon(path)
		end
	end

	self.Goto:SetActive(hold <= 0)

	self.index = tonumber(self.UIRootObject.name)
end

function CellUseItem:UpdateSelData(num)
	self.IsUsed = num > 0

	SetActiveWithState(self, "GoSub", num > 0)
	SetActiveWithState(self, "TxtUse", num > 0, true)

	local hold = self.info:GetNum()

	if hold < num then
		self.TxtUse.text = "<color=red>" .. _("UI_Use") .. "：" .. num .. "</color>"
	else
		self.TxtUse.text = "<color=#3C3C3C>" .. _("UI_Use") .. "：" .. num .. "</color>"
	end

	self.item:UpdateNumOnly(hold - num)
end

function CellUseItem:OnPointerDownAddItem(data)
	self.isRepeatAdd = false
end

function CellUseItem:OnPointerRepeatAddItem(data)
	self.isRepeatAdd = true

	if self.page then
		self.page:DealWithAdd(self.index)
	end
end

function CellUseItem:OnPointerUpAddItem(data)
	if not self.page then
		return
	end

	if not self.isRepeatAdd and data.dragging then
		return
	end

	if not self.isRepeatAdd then
		self.page:DealWithAdd(self.index)
	end

	self.page:DealWithEndAdd()
end

function CellUseItem:OnPointerDownSubItem(data)
	self.isRepeatSub = false
end

function CellUseItem:OnPointerRepeatSubItem(data)
	self.isRepeatSub = true

	if self.page then
		self.page:DealWithSub(self.index)
	end

	if not self.IsUsed then
		self:OnPointerUpSubItem()
	end
end

function CellUseItem:OnPointerUpSubItem(data)
	if not self.page then
		return
	end

	if not self.isRepeatSub and data.dragging then
		return
	end

	if not self.isRepeatSub then
		self.page:DealWithSub(self.index)
	end

	self.page:DealWithEndSub()
end

function CellUseItem:OnClickedGoto()
	Event.Instance:Fire("DealWithGotoGet")
end
