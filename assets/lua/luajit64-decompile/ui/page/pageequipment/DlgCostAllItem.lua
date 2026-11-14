-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgCostAllItem.lua

DlgCostAllItem = class("DlgCostAllItem", UIPanel)

function DlgCostAllItem:ctor()
	DlgCostAllItem.base.ctor(self, "UI/PanelEquipment/DlgCostAllItem")
end

function DlgCostAllItem:Purge()
	self.base.Purge(self)
end

function DlgCostAllItem:PreLoad()
	self.PrefabCellItem = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function DlgCostAllItem:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.Close)
end

function DlgCostAllItem:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.Close)
end

function DlgCostAllItem:OnEnter(vParam)
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")

	self:InitData(vParam)
end

function DlgCostAllItem:DealWithLocalization()
	return
end

function DlgCostAllItem:InitData(data)
	self.costlist = data.costlist
	self.costItemInfos = {}

	for k, v in pairs(self.costlist) do
		local info = ItemManager:GetValueItem(k, v)

		table.insert(self.costItemInfos, info)
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.costItemInfos

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellItem, CellItem, self, false)
end

function DlgCostAllItem:AddCellClick(item)
	return
end

function DlgCostAllItem:UpdateCell(item, index)
	item:UpdateWithNumType(self.costItemInfos[index])
end
