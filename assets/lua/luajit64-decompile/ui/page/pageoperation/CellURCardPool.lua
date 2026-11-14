-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellURCardPool.lua

require("UI/Item/UIItemBase")

CellURCardPool = class("CellURCardPool", UIItemBase)

function CellURCardPool:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellURCardPool:OnEnter()
	local g = self.UIRootObject

	self.GoDot = GOUtil.FindChildGameObject(g, "GoDot")
	self.Recved = GOUtil.FindChildGameObject(g, "Recved")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "BtnRecv")
	self.img_recv = GOUtil.FindChildGameObject(g, "img_recv")
	self.BGRecved = GOUtil.FindChildGameObject(g, "BGRecved")
	self.BGUnRecved = GOUtil.FindChildGameObject(g, "BGUnRecved")

	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)

	self.TxtCondition = GOUtil.FindChildComponent(g, "go_time/TxtTime", "Text")
	self.FX_UI_Activity = GOUtil.FindChildGameObject(g, "FX_UI_Activity")
	self.img_Recved = GOUtil.FindChildGameObject(g, "Recved/img_Recved")
	self.Cell = GOUtil.FindChildGameObject(g, "Group/CellItem")

	SetActiveFunc(self.Cell, false)

	local scrollArea = GOUtil.FindChildGameObject(g, "Group")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	self.ScrollView.horizontal = true
end

function CellURCardPool:OnLeave()
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)
	UnloadAllImageSprite(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function CellURCardPool:ClearCell()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
end

function CellURCardPool:UpdateData(info)
	self.info = info

	local canRecv = self.info:IsComplete()
	local isRecv = self.info:IsGetAward()

	self.TxtCondition.text = info:GetDescTitle()

	self:ClearCell()

	local pack = self.info.data.Reward

	self.listItem = {}

	SetActiveFunc(self.Cell, true)

	for i = 1, #pack do
		local award = pack[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2], nil, award[3])
			local gItem = GOUtil.Instantiate(self.Cell, self.ScrollView.content.gameObject)
			local item = CellItem(gItem)

			item:InitItemByRoot(gItem)

			if award[2] == 0 then
				item:UpdateNoNumType(infoItem)
			else
				item:UpdateWithNumType(infoItem)
			end

			table.insert(self.listItem, item)
		end
	end

	SetActiveFunc(self.Cell, false)

	if #pack <= 2 then
		self.ScrollView.horizontal = false
	else
		self.ScrollView.horizontal = true
	end

	SetActiveFunc(self.GoDot, canRecv and not isRecv)
	SetActiveFunc(self.Recved, isRecv)
	SetActiveFunc(self.BtnRecv, canRecv and not isRecv)
	SetActiveFunc(self.BGRecved, canRecv and not isRecv)
	SetActiveFunc(self.BGUnRecved, not canRecv or isRecv)
	SetActiveFunc(self.FX_UI_Activity, canRecv and not isRecv)
	SetActiveFunc(self.img_Recved, isRecv)
end

function CellURCardPool:OnClickedBtnRecv(data)
	Event.Instance:Fire("DealWithCompleteURCardPoolTask", self.info)
end
