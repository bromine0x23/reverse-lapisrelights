-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageWork/CellCondition.lua

require("UI/Item/UIItemBase")

CellCondition = class("CellCondition", UIItemBase)

function CellCondition:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCondition:Create(vParam)
	CellCondition.base.Create(self, vParam)
end

function CellCondition:OnEnter()
	local g = self.UIRootObject

	self.Panel = GOUtil.FindChildGameObject(g, "Panel")
	self.Icon = GOUtil.FindChildComponent(g, "Panel/Icon", "Image")
	self.TxtNum = GOUtil.FindChildComponent(g, "Panel/Num/Text", "Text")

	UIUtil.SetTextAlignment(self.TxtNum, 7)

	self.GoSelect = GOUtil.FindChildGameObject(g, "Panel/Select")
	self.Animator = GOUtil.GetComponent(g, "Animator")
	self.RawImgEffect = self:GetChildComponent("Panel/Effect", "RawImage")
end

function CellCondition:OnLeave()
	UnloadAllImageSprite(self)
end

function CellCondition:UpdateData(data)
	local infoWork = data.infoWork
	local info = data.info
	local flag, num = WorkMgr:GetConditionIsMet(info.info, infoWork.tempData.cardIds)

	UIUtil.SetImageSprite(self.Icon, info.info.Icon, self)

	self.RawImgEffect.texture = data.effTex

	if flag then
		self.TxtNum.text = info.need .. "/" .. info.need
		self.TxtNum.color = Color.black
	else
		self.TxtNum.text = num .. "/" .. info.need
		self.TxtNum.color = Color.red
	end

	GOUtil.SetActive(self.RawImgEffect.gameObject, flag)
end

function CellCondition:UpdatePos(indexList)
	local isSelect = table.contains(indexList, tonumber(self.UIRootObject.name))

	GOUtil.SetActive(self.GoSelect, isSelect)

	if isSelect then
		self.Animator.enabled = true

		GOUtil.SetTransformLocalPosition(self.Panel, 0, 20, 0)
	else
		self.Animator.enabled = false

		GOUtil.SetTransformLocalPosition(self.Panel, 0, 0, 0)
	end
end
