-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveHour.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellHourAward")

DlgOperationActiveHour = class("DlgOperationActiveHour", UIItemBase)

function DlgOperationActiveHour:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveHour:Purge()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self.infoActive:ClearOperationSpine()
	UnloadAllImageSprite(self)
end

function DlgOperationActiveHour:UnloadRef()
	return
end

function DlgOperationActiveHour:OnRegisterEvent()
	return
end

function DlgOperationActiveHour:OnUnRegisterEvent()
	return
end

function DlgOperationActiveHour:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell

	local g = self.UIRootObject

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
end

function DlgOperationActiveHour:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject, true)
end

function DlgOperationActiveHour:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:DealWithLocalization(self.ActiveID)

	self.listHourAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	local count = #self.listHourAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local data = self.listHourAward[index]

		item:UpdateData(data, infoActive)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellHourAward, self, true, addCallback, updateCallback)

	self.UIScrollTool.ScrollView.horizontal = false
end

function DlgOperationActiveHour:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.listHourAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	self.UIScrollTool:UpdateListDataKeepPos(self.listHourAward)
end
