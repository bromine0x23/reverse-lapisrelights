-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActivePlayerBirthday.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellPlayerBirthday")

DlgOperationActivePlayerBirthday = class("DlgOperationActivePlayerBirthday", UIItemBase)

function DlgOperationActivePlayerBirthday:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActivePlayerBirthday:Purge()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	UIMgr.RemoveUpdatePanel(self)
	self.infoActive:ClearOperationSpine()
	UnloadAllImageSprite(self)

	if self.isShowClose then
		self:RemoveClick(self.btn_close, self.OnClickClose)
	end
end

function DlgOperationActivePlayerBirthday:OnClickClose()
	self:Purge()
	DlgOperationActivePlayerBirthday.base.Purge(self)

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	if self.PrefabDlg then
		ResourceMgr.Unload(self.PrefabDlg)

		self.PrefabDlg = nil
	end
end

function DlgOperationActivePlayerBirthday:OnRegisterEvent()
	return
end

function DlgOperationActivePlayerBirthday:OnUnRegisterEvent()
	return
end

function DlgOperationActivePlayerBirthday:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell
	self.isShowClose = vParam.isShowClose
	self.PrefabDlg = vParam.PrefabDlg
	OperationActiveMgr.PlayerBirthdayEnterPace = true

	local g = self.UIRootObject

	UIMgr.SetUpdatePanel(self)

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")

	if self.isShowClose then
		self.btn_close = GOUtil.FindChildGameObject(g, "btn_close")

		self:AddClick(self.btn_close, self.OnClickClose)
	end
end

function DlgOperationActivePlayerBirthday:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActivePlayerBirthday:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:DealWithLocalization(self.ActiveID)
	OperationActiveMgr:SetPlayerBirthdayState(time, 0)

	self.listPlayerBirthdayAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	local listComb = CombinationMgr:GetAllCombination()

	for i = #listComb + 1, #self.listPlayerBirthdayAward do
		table.remove(self.listPlayerBirthdayAward, i)
	end

	local count = #self.listPlayerBirthdayAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local data = self.listPlayerBirthdayAward[index]

		if self.PrefabDlg then
			local function callback(...)
				self:OnClickClose()
			end

			item:UpdateData(data, infoActive, callback)
		else
			item:UpdateData(data, infoActive)
		end
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellPlayerBirthday, self, true, addCallback, updateCallback)
end

function DlgOperationActivePlayerBirthday:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:DealWithLocalization(self.ActiveID)

	self.listPlayerBirthdayAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	local listComb = CombinationMgr:GetAllCombination()

	for i = #listComb + 1, #self.listPlayerBirthdayAward do
		table.remove(self.listPlayerBirthdayAward, i)
	end

	self.UIScrollTool:UpdateListDataKeepPos(self.listPlayerBirthdayAward)
	OperationActiveMgr:SetPlayerBirthdayState(time, 0)
end
