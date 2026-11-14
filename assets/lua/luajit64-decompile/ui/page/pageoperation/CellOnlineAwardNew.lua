-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellOnlineAwardNew.lua

require("UI/Item/UIItemBase")

CellOnlineAwardNew = class("CellOnlineAwardNew", UIItemBase)

function CellOnlineAwardNew:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellOnlineAwardNew:OnEnter()
	local g = self.UIRootObject

	self.img_sel = self:GetChildGameObject("img_sel")

	self:AddClick(self.img_sel, self.OnClickedBtnRecv)

	self.img_recv = self:GetChildGameObject("img_recv")
	self.img_state = self:GetChildComponent("img_state", "Image")
	self.img_time = self:GetChildComponent("img_time", "Image")
	self.tex_Recv = self:GetChildComponent("tex_Recv", "Text")
	self.tex_time = self:GetChildComponent("img_time/tex_time", "Text")

	local gItem = self:GetChildGameObject("CellItem")

	self.CellItem = CellItem(gItem)

	self.CellItem:InitItemByRoot(gItem)
end

function CellOnlineAwardNew:Purge()
	self:OnLeave()
end

function CellOnlineAwardNew:OnLeave()
	UnloadAllImageSprite(self)
	self:ClearCell()
	self.CellItem:OnLeave()
end

function CellOnlineAwardNew:ClearCell()
	self:RemoveClick(self.img_sel, self.OnClickedBtnRecv)
end

function CellOnlineAwardNew:UpdateData(info)
	self.info = info

	if tonumber(info.min) >= tonumber(info.dataTime) then
		UIUtil.SetImageSprite(self.img_state, "UI/PanelOperation/New/AtlasCommon/BG_exer_time_dot_03", self)
		UIUtil.SetImageSprite(self.img_time, "UI/PanelOperation/New/AtlasCommon/BG_exer_time_line_01", self)
	else
		UIUtil.SetImageSprite(self.img_state, "UI/PanelOperation/New/AtlasCommon/BG_exer_time_dot_02", self)
		UIUtil.SetImageSprite(self.img_time, "UI/PanelOperation/New/AtlasCommon/BG_exer_time_line_02", self)
	end

	self.tex_time.text = info.dataTime .. _("Desc_minute")

	SetActiveFunc(self.tex_Recv.gameObject, info.isGeted and tonumber(info.min) >= tonumber(info.dataTime))
	SetActiveFunc(self.img_sel, not info.isGeted and tonumber(info.min) >= tonumber(info.dataTime))
	SetActiveFunc(self.img_recv, info.isGeted and tonumber(info.min) >= tonumber(info.dataTime))
	SetActiveFunc(self.img_time.gameObject, not self.img_recv.activeSelf)

	if info.isGeted then
		UIUtil.SetImageSprite(self.img_state, "UI/PanelOperation/New/AtlasCommon/BG_exer_time_dot_01", self)
	end

	local infoItem = ItemManager:GetValueItem(self.info.data[1][1], self.info.data[1][2])

	self.CellItem:UpdateWithNumType(infoItem)
end

function CellOnlineAwardNew:OnClickedBtnRecv(data)
	Event.Instance:Fire("ReceiveOperationActiveAward", self.info.index)
end
