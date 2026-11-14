-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellLevelAward.lua

require("UI/Item/UIItemBase")

CellLevelAward = class("CellLevelAward", UIItemBase)

function CellLevelAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellLevelAward:OnEnter()
	local g = self.UIRootObject

	self.Cell = GOUtil.FindChildGameObject(g, "CellItem")

	local scrollArea = GOUtil.FindChildGameObject(g, "ScrollArea")

	self.scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	self.scrollView.horizontal = true
	self.TxtLevel = GOUtil.FindChildComponent(g, "Target/TextInfo", "Text")
	self.TxtRate = GOUtil.FindChildComponent(g, "Bar/Text", "Text")
	self.GoRate = GOUtil.FindChildGameObject(g, "Bar/Image")
	self.GoGeted = GOUtil.FindChildGameObject(g, "GoGeted")
	self.BtnRecv = GOUtil.FindChildGameObject(g, "BtnRecv")

	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)

	self.ImgBtnRecv = GOUtil.GetComponent(self.BtnRecv, "Image")
	self.TxtBtnRecv = GOUtil.FindChildComponent(self.BtnRecv, "Text", "Text")
end

function CellLevelAward:OnLeave()
	self:DestroyCell()
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)
end

function CellLevelAward:DestroyCell()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(self.scrollView.content.gameObject)
end

function CellLevelAward:UpdateData(data, listOpenActive)
	self.data = data

	local curLevel, targetLevel = PlayerInst:GetCurLv(), data.index

	self.TxtLevel.text = string.format(_("Desc_LevelFinish"), targetLevel)
	curLevel = TenaryOp(targetLevel < curLevel, targetLevel, curLevel)
	self.TxtRate.text = curLevel .. "/" .. targetLevel

	local rate = TenaryOp(math.abs(curLevel / targetLevel) > 1, 1, math.abs(curLevel / targetLevel))

	self.GoRate.transform.localScale = Vector3(rate, 1, 1)

	self:DestroyCell()

	local listAward = data.award

	self.listItem = {}

	SetActiveFunc(self.Cell, true)

	for i = 1, #listAward do
		local award = listAward[i]

		if award then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])
			local gItem = GOUtil.Instantiate(self.Cell, self.scrollView.content.gameObject)
			local item = CellItem(gItem)

			item:InitItemByRoot(gItem)
			item:UpdateWithNumType(infoItem)
			GOUtil.SetTransformLocalScale(item.UIRootObject, 0.9)
			table.insert(self.listItem, item)
		end
	end

	SetActiveFunc(self.Cell, false)

	local infoOperationActive = listOpenActive
	local isGeted = infoOperationActive:IsGetIndexAward(data.index)
	local isCanRec = targetLevel <= curLevel

	SetActiveFunc(self.BtnRecv, not isGeted)
	SetActiveFunc(self.GoGeted, isGeted)

	local gray = TenaryOp(not isCanRec, 1, 0)

	UIUtil.SetImageGray(self.ImgBtnRecv, gray)

	self.TxtBtnRecv.text = _("Desc_Get")
end

function CellLevelAward:OnClickedBtnRecv()
	local targetLevel = self.data.index
	local isCanRec = targetLevel <= PlayerInst:GetCurLv()

	if not isCanRec then
		UIMgr.ShowMsg(_("Desc_CantGet"))

		return
	end

	Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index)
end
