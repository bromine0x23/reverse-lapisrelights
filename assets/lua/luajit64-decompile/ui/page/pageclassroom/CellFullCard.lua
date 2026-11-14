-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageClassroom/CellFullCard.lua

require("UI/Item/UIItemBase")

CellFullCard = class("CellFullCard", UIItemBase)

function CellFullCard:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellFullCard:Create(vParam)
	CellFullCard.base.Create(self, vParam)
end

function CellFullCard:OnEnter()
	local g = self.UIRootObject

	self.Card = GOUtil.FindChildComponent(g, "Card", "Image")
end

function CellFullCard:OnLeave()
	return
end

function CellFullCard:UpdateData(infoRoleCard)
	GOUtil.DestroyAllChildren(self.Card.gameObject)

	if infoRoleCard.data.SpineData ~= "" then
		self.Card.enabled = false

		local cardSpine = ResourceMgr.LoadSync(infoRoleCard.data.SpineData .. "_Anim")

		if cardSpine then
			GOUtil.InstantiateUIPrefab(cardSpine, self.Card.gameObject)
			GOUtil.SetTransformLocalScale(self.Card.gameObject, 1.1)
		else
			self.Card.enabled = true

			RoleCardMgr:SetInfoPanel(infoRoleCard, self.Card)
			GOUtil.SetTransformLocalScale(self.Card.gameObject, 1)
		end
	else
		self.Card.enabled = true

		RoleCardMgr:SetInfoPanel(infoRoleCard, self.Card)
		GOUtil.SetTransformLocalScale(self.Card.gameObject, 1)
	end
end
