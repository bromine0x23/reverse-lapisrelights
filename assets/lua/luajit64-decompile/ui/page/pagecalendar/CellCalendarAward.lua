-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCalendar/CellCalendarAward.lua

require("UI/Item/UIItemBase")

CellCalendarAward = class("CellCalendarAward", UIItemBase)

function CellCalendarAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCalendarAward:OnEnter()
	local g = self.UIRootObject

	self.img_sel = self:GetChildGameObject("img_sel")

	self:AddClick(self.img_sel, self.OnClickedBtnRecv)

	self.img_recv = self:GetChildGameObject("img_recv")
	self.img_state = self:GetChildGameObject("img_state")
	self.img_time = self:GetChildGameObject("img_time")
	self.timeObj = self:GetChildGameObject("tex_time")
	self.tex_time = self:GetChildComponent("tex_time", "Text")

	local gItem = self:GetChildGameObject("CellItem")

	self.CellItem = CellItem(gItem)

	self.CellItem:InitItemByRoot(gItem)
end

function CellCalendarAward:OnLeave()
	UnloadAllImageSprite(self)
	self:ClearCell()
	self.CellItem:OnLeave()
end

function CellCalendarAward:ClearCell()
	self:RemoveClick(self.img_sel, self.OnClickedBtnRecv)
end

function CellCalendarAward:UpdateData(info)
	self.info = info

	if not info.isGeted and tonumber(info.min) >= tonumber(info.dataTime) then
		GOUtil.SetImageColor(self.img_time, 222, 145, 174)
		GOUtil.SetImageColor(self.img_state, 255, 255, 255)
		GOUtil.SetTextColor(self.timeObj, 255, 255, 255)
	else
		GOUtil.SetImageColor(self.img_state, 121, 121, 121)
		GOUtil.SetImageColor(self.img_time, 255, 255, 255)
		GOUtil.SetTextColor(self.timeObj, 122, 129, 133)
	end

	self.tex_time.text = info.dataTime .. _("Desc_minute")

	self.img_sel:SetActive(not info.isGeted and tonumber(info.min) >= tonumber(info.dataTime))
	self.img_recv:SetActive(info.isGeted and tonumber(info.min) >= tonumber(info.dataTime))

	local infoItem = ItemManager:GetValueItem(self.info.data[1][1], self.info.data[1][2])

	self.CellItem:UpdateWithNumType(infoItem)
end

function CellCalendarAward:OnClickedBtnRecv(data)
	if not self.info.isGeted then
		Event.Instance:Fire("GetCalendarAward", self.info.index)
	end
end
