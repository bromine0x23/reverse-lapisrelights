-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellRegisterAward.lua

require("UI/Item/UIItemBase")

CellRegisterAward = class("CellRegisterAward", UIItemBase)

function CellRegisterAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellRegisterAward:OnEnter()
	local g = self.UIRootObject
	local Text = GOUtil.FindChildComponent(g, "BtnGet/Text", "Text")

	Text.text = Lang(12178)
	self.TxtTime = GOUtil.FindChildComponent(g, "TxtTime", "Text")
	self.TxtUnget = GOUtil.FindChildComponent(g, "GoUnget/Text", "Text")
	self.GoDot = GOUtil.FindChildGameObject(g, "GoDot")
	self.BtnGet = GOUtil.FindChildGameObject(g, "BtnGet")
	self.GoGeted = GOUtil.FindChildGameObject(g, "GoGeted")
	self.GoUnget = GOUtil.FindChildGameObject(g, "GoUnget")
	self.Cell = GOUtil.FindChildGameObject(g, "Group/CellItem")

	SetActiveFunc(self.Cell, false)

	local scrollArea = GOUtil.FindChildGameObject(g, "Group")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	self.ScrollView.horizontal = true
end

function CellRegisterAward:OnLeave()
	UnloadAllImageSprite(self)
	self:ClearCell()
end

function CellRegisterAward:ClearCell()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
end

function CellRegisterAward:UpdateData(data, curindex)
	local day = data.index

	self.infoActive = OperationActiveMgr:Get(curindex)
	self.TxtTime.text = string.format(_("Desc_TheNumDay"), self.Index)

	local canRecv = OperationActiveMgr:GetRegisterDay() >= self.Index
	local isRecv = self.infoActive:IsGetIndexAward(self.Index)

	SetActiveFunc(self.GoDot, canRecv and not isRecv)
	SetActiveFunc(self.BtnGet, canRecv and not isRecv)
	SetActiveFunc(self.GoGeted, canRecv and isRecv)
	SetActiveFunc(self.GoUnget, not canRecv)

	self.TxtUnget.text = string.format(_("Desc_CumulativeNumberDays"), self.Index)

	self:ClearCell()

	local pack = OperationActiveMgr:GetRewardPackData(self.infoActive.data.TypeReward[self.Index]).PackItem

	self.listItem = {}

	SetActiveFunc(self.Cell, true)

	for i = 1, #pack do
		local award = pack[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])
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
end
