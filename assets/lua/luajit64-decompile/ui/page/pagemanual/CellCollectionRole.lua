-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/CellCollectionRole.lua

require("UI/Item/UIItemBase")

CellCollectionRole = class("CellCollectionRole", UIItemBase)

function CellCollectionRole:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellCollectionRole:OnLeave()
	self.page = nil
end

function CellCollectionRole:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageIcon = GOUtil.FindChildComponent(g, "Head/HeadIcon", "Image")
	self.TextName = GOUtil.FindChildComponent(g, "Name", "Text")
	self.TextCount = GOUtil.FindChildComponent(g, "Count", "Text")
	self.ImgFill = GOUtil.FindChildComponent(g, "ImageBG/ImgFill", "Image")
	self.CollectText = self:GetChildComponent("Text", "Text")
	self.SelectBg = GOUtil.FindChildGameObject(g, "SelectBg")
	self.UnSelectBg = GOUtil.FindChildGameObject(g, "UnSelectBg")

	local text = GOUtil.FindChildComponent(g, "Text", "Text")

	text.text = _("Collection_Progress")
end

function CellCollectionRole:UpdateData(infoRole, isSelect, type, dotActive)
	self.infoRole = infoRole

	UIUtil.SetImageSprite(self.ImageIcon, self.infoRole.actorData.CharacterIcon, self.page, false)

	self.TextName.text = self.infoRole:GetName()

	self:SetSelectImage(isSelect)

	local totalCount = 0
	local curCount = 0

	if type == 1 then
		local listAll = RoleCardMgr:GetRoleAllCard(self.infoRole.id)

		totalCount = #listAll
		curCount = 0

		for i, v in ipairs(listAll) do
			if v:IsHold() then
				curCount = curCount + 1
			end
		end

		RedDotSystemMgr.SetUIRedDot(self.UIRootObject, string.format("Arrow/Manual/Video/%d/Nirvana/%d", self.infoRole.data.Team, self.infoRole.id))
	else
		self.illustrationDataList = CollectionManager:GetIllustrationInfo(self.infoRole.id)

		for k, v in pairs(self.illustrationDataList) do
			local isUnlock = table.contains(self.infoRole.pb.pictures, v.ID)

			if isUnlock then
				curCount = curCount + 1
			end

			totalCount = totalCount + 1
		end

		RedDotSystemMgr.SetUIRedDot(self.UIRootObject, string.format("Arrow/Manual/Video/%d/Illustration/%d", self.infoRole.data.Team, self.infoRole.id))
	end

	self.TextCount.text = curCount .. "/" .. totalCount
	self.ImgFill.fillAmount = curCount / totalCount
end

function CellCollectionRole:SetSelectImage(isSelect)
	self.TextName.color = TenaryOp(isSelect, Color.white, getColorFromString("585e62"))
	self.CollectText.color = TenaryOp(isSelect, Color.white, getColorFromString("7a8185"))
	self.TextCount.color = TenaryOp(isSelect, Color.white, getColorFromString("7a8185"))

	self.SelectBg:SetActive(isSelect)
	self.UnSelectBg:SetActive(not isSelect)
end
