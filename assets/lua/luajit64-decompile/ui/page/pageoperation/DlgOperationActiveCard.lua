-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveCard.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellModelType1")

DlgOperationActiveCard = class("DlgOperationActiveCard", UIItemBase)

function DlgOperationActiveCard:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveCard:Purge()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgOperationActiveCard:OnRegisterEvent()
	return
end

function DlgOperationActiveCard:OnUnRegisterEvent()
	return
end

function DlgOperationActiveCard:OnEnter(vParam)
	self.PrefabCell = ResourceMgr.LoadSync("UI/PanelOperation/New/ModelDlg/CellModelType1")

	local g = self.UIRootObject

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
end

function DlgOperationActiveCard:Init(infoActive)
	self.listCardAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	local count = #self.listCardAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local data = self.listCardAward[index]

		item:UpdateData(data, infoActive, 2)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellModelType1, self, true, addCallback, updateCallback)
	self:SignCardAward(infoActive)
end

function DlgOperationActiveCard:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.listCardAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	self.UIScrollTool:UpdateListDataKeepPos(self.listCardAward)
end

function DlgOperationActiveCard:SignCardAward(listOpenActive)
	local isHave, index = OperationActiveMgr:Get(listOpenActive.id):IsHaveCanRec()

	if not isHave then
		return
	end

	local width = GOUtil.GetRectTransformSizeDeltaWidth(self.content.gameObject)

	width = width - #self.listCardAward * 260

	self.UIScrollTool:SetContentPosImmediate(Vector2(width > (1 - index) * 260 and width or (1 - index) * 260, 0), self.listCardAward)
end
