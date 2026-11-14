-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgHeadTip.lua

require("UI/Page/PageFight/Cells/CellHeadTip")

DlgHeadTip = class("DlgHeadTip", UIPanel_sync)

function DlgHeadTip:ctor()
	DlgHeadTip.base.ctor(self, "UI/PageFight/Dlg/DlgHeadTip")

	self.HeadTipList = {}

	for i = 1, 18 do
		local item = CellHeadTip()

		self:AddChildPanel(item)
		table.insert(self.HeadTipList, item)
	end
end

function DlgHeadTip:Cache()
	DlgHeadTip.base.Cache(self)
end

function DlgHeadTip:Close(tParam)
	DlgHeadTip.base.Close(self, tParam)
end

function DlgHeadTip:Purge()
	DlgHeadTip.base.Purge(self)

	self.HeadTipList = {}
end

function DlgHeadTip:OnRegisterEvent()
	DlgHeadTip.base.OnRegisterEvent(self)
	Event.Instance:Add("UnitCreate", self.OnUnitCreate, self)
	Event.Instance:Add("UnitDestroy", self.OnUnitDestroy, self)
end

function DlgHeadTip:OnUnRegisterEvent()
	DlgHeadTip.base.OnUnRegisterEvent(self)
	Event.Instance:Remove("UnitCreate", self.OnUnitCreate, self)
	Event.Instance:Remove("UnitDestroy", self.OnUnitDestroy, self)
end

function DlgHeadTip:OnEnter(vParam)
	DlgHeadTip.base.OnEnter(self, vParam)

	self.TipRoot = self:GetChildGameObject("panel")
end

function DlgHeadTip:OnUnitCreate(msg)
	local vaildCell

	for i, item in ipairs(self.HeadTipList) do
		if item.UniqueId == nil then
			vaildCell = item

			break
		end
	end

	if not vaildCell then
		print("ERROR , DlgHeadTip  OnUnitCreate")

		return
	end

	local unit = UnitActor.FindUnitById(msg.uniqueId)

	vaildCell:BindUnit(msg)
end

function DlgHeadTip:OnUnitDestroy(msg)
	for i, item in ipairs(self.HeadTipList) do
		if item.UniqueId == msg.uniqueId then
			item:ClearData()

			break
		end
	end
end
