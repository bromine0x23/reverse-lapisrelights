-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/CellAssetStage.lua

require("UI/Item/UIItemBase")

CellAssetStage = class("CellAssetStage", UIItemBase)

function CellAssetStage:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellAssetStage:Create(vParam)
	CellAssetStage.base.Create(self, vParam)
end

function CellAssetStage:OnEnter()
	local g = self.UIRootObject

	self.PanelCard = GOUtil.FindChildGameObject(g, "PanelCard")
	self.PanelAsset = GOUtil.FindChildGameObject(g, "PanelAsset")
	self.TxtTitle = GOUtil.FindChildComponent(g, "Common/Title/Text", "Text")
	self.TxtCost = GOUtil.FindChildComponent(g, "Common/TxtCost", "Text")
	self.TxtType = GOUtil.FindChildComponent(g, "Common/TxtType", "Text")
	self.listItem = {}

	for i = 1, 3 do
		self["GoFrame" .. i] = GOUtil.FindChildGameObject(g, "PanelAsset/Star/Image" .. i)
		self["GoStar" .. i] = GOUtil.FindChildGameObject(g, "PanelAsset/Star/Star" .. i)
		self["CellItem" .. i] = GOUtil.FindChildGameObject(g, "Common/Award/" .. i .. "/CellItem")
		self["GoTxtDrop" .. i] = GOUtil.FindChildComponent(g, "Common/Award/" .. i .. "/Text")

		local gItem = self["CellItem" .. i]
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.GoLock = GOUtil.FindChildGameObject(g, "Lock")
	self.GoNew = GOUtil.FindChildGameObject(g, "New")
	self.Button = GOUtil.FindChildGameObject(g, "Common/Button")

	self:AddClick(self.Button, self.OnClickedBtnInfo)
end

function CellAssetStage:OnLeave()
	self:RemoveClick(self.Button, self.OnClickedBtnInfo)
end

function CellAssetStage:UpdateData(infoStage)
	local infoStage = data.infoStage
	local stageIdx = data.index
	local isUnLock = infoStage:IsOpen()
	local isNew = infoStage:IsNew()
	local stageType = infoStage.data.Type

	for i = 1, 3 do
		SetActiveFunc(self["Stage" .. i], i == stageType)
	end

	local str = infoStage:GetName()

	if infoStage.data.ChapterType == 5 then
		str = string.format(Lang(5000005), SafeLevel)
	end

	self.TxtTitle.text = str
	self.TxtCost.text = infoStage.data.Stamina

	SetActiveFunc(self.GoNew, isNew)
	SetActiveFunc(self.GoLock, not isUnLock)

	if stageType == 2 then
		SetActiveFunc(self.ImgStory.gameObject, true)
	else
		local starCount = infoStage:GetStar()

		if isUnLock then
			SetActiveFunc(self.StarGroup, true)
			self:SetStar(starCount)
		end

		if starCount >= 3 then
			SetActiveFunc(self.BtnSweep, true)
		end
	end

	local listItem = {}

	if isNew or not isUnLock then
		self.TxtAwardType.text = Lang(5000007)
		listItem = infoStage.data.FirstAward
	elseif stageType ~= 2 then
		self.TxtAwardType.text = _("Desc_Drop_May")
		listItem = infoStage.data.ItemList
	else
		self.TxtAwardType.text = Lang(5000007)
		listItem = infoStage.data.FirstAward

		for i = 1, #listItem do
			SetActiveFunc(self["GoGeted" .. i], true)
		end
	end

	for i = 1, 3 do
		local isOk = i <= #listItem and listItem[i][1] ~= nil

		SetActiveFunc(self["CellItem" .. i], isOk)

		if isOk then
			local id = listItem[i][1]
			local infoItem = ItemManager:Get(id)
			local itemIcon = GOUtil.FindChildComponent(self["CellItem" .. i], "Icon", "Image")
			local itemValue = GOUtil.FindChildComponent(self["CellItem" .. i], "BgValue/Text", "Text")

			itemValue.text = listItem[i][2]

			UIUtil.SetImageSprite(itemIcon, "UIDyAtlas/Item/" .. infoItem.data.Icon)
		end
	end
end

function CellAssetStage:SetStar(starCount)
	for i = 1, 3 do
		SetActiveFunc(self["GoFrame" .. i], starCount < i)
		SetActiveFunc(self["GoStar" .. i], i <= starCount)
	end
end

function CellAssetStage:OnClickedBtnInfo()
	return
end

function CellAssetStage:OnClickedBtnEnter()
	Event.Instance:Fire("EnterStage", {
		stype = 1,
		index = self.Index
	})
end

function CellAssetStage:OnClickedBtnSweep()
	Event.Instance:Fire("EnterStage", {
		stype = 2,
		index = self.Index
	})
end
