-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/CellFetter.lua

require("UI/Item/UIItemBase")

CellFetter = class("CellFetter", UIItemBase)

function CellFetter:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellFetter:Create(vParam)
	CellFetter.base.Create(self, vParam)
end

function CellFetter:OnEnter()
	local g = self.UIRootObject

	self.FetterName = GOUtil.FindChildComponent(g, "Type/TxtName", "Text")
	self.ImgFetterType1 = GOUtil.FindChildComponent(g, "Type", "Image")
	self.ImgFetterType2 = GOUtil.FindChildComponent(g, "Type/Icon", "Image")
	self.ImgFetterType3 = GOUtil.FindChildComponent(g, "Type/Image", "Image")

	for i = 1, 4 do
		self["Attr" .. i] = GOUtil.FindChildGameObject(g, "Attr/Group/" .. i)
		self["ImgAttr" .. i] = GOUtil.FindChildComponent(g, "Attr/Group/" .. i .. "/ImgAttr", "Image")
		self["TxtAttrValue" .. i] = GOUtil.FindChildComponent(g, "Attr/Group/" .. i .. "/TxtValue", "Text")
	end

	self.MainCardIcon = GOUtil.FindChildComponent(g, "MainCard/Icon", "Image")
	self.MainCardRank = GOUtil.FindChildComponent(g, "MainCard/Rank", "Image")
	self.MainCardJob = GOUtil.FindChildComponent(g, "MainCard/Job", "Image")

	for i = 1, 3 do
		self["Card" .. i] = GOUtil.FindChildGameObject(g, "ViceCard/Card" .. i)
		self["CardIcon" .. i] = GOUtil.FindChildComponent(g, "ViceCard/Card" .. i .. "/Icon", "Image")
		self["CardRank" .. i] = GOUtil.FindChildComponent(g, "ViceCard/Card" .. i .. "/Rank", "Image")
		self["CardJob" .. i] = GOUtil.FindChildComponent(g, "ViceCard/Card" .. i .. "/Job", "Image")
	end

	self.GoNotAct = GOUtil.FindChildGameObject(g, "NotAct")
end

function CellFetter:UpdateData(info)
	self.info = info
	self.FetterName.text = Lang(info.data.Name)

	local _type = info.data.JoinType

	UIUtil.SetImageSprite(self.ImgFetterType1, "UI/PanelRole/AtlasPanelRole/BG_entanglement_0" .. _type .. "a")
	UIUtil.SetImageSprite(self.ImgFetterType2, "UI/PanelRole/AtlasPanelRole/BG_entanglement_0" .. _type .. "b")
	UIUtil.SetImageSprite(self.ImgFetterType3, "UI/PanelRole/AtlasPanelRole/BG_entanglement_0" .. _type)

	local listCard = info.data.CardList
	local mainCardId = listCard[1][1]

	if mainCardId then
		self:SetCardInfo(mainCardId, self.MainCardIcon, self.MainCardRank, self.MainCardJob, 1)
	end

	for i = 1, 3 do
		if i <= #listCard - 1 then
			self["Card" .. i]:SetActive(true)

			local cardId = listCard[i + 1][1]

			if cardId then
				self:SetCardInfo(cardId, self["CardIcon" .. i], self["CardRank" .. i], self["CardJob" .. i], i + 1)
			end
		else
			self["Card" .. i]:SetActive(false)
		end
	end

	for i = 1, 4 do
		local attr = info:GetAtt(i)

		if attr > 0 then
			self["Attr" .. i]:SetActive(true)
			UIUtil.SetImageSprite(self["ImgAttr" .. i], "UI/PanelRole/AtlasPanelRole/ICO_nature_0" .. i)

			self["TxtAttrValue" .. i].text = "+" .. attr
		else
			self["Attr" .. i]:SetActive(false)
		end
	end

	local isAct = info:IsHold()

	self.GoNotAct:SetActive(not isAct)

	local num = TenaryOp(isAct, 0, 1)

	UIUtil.SetImageGray(self.ImgFetterType1, num)
	UIUtil.SetImageGray(self.ImgFetterType2, num)
	UIUtil.SetImageGray(self.ImgFetterType3, num)
end

function CellFetter:SetCardInfo(cardId, icon, rank, job, index)
	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

	UIUtil.SetImageSprite(icon, infoRoleCard.data.HeadIcon)
	UIUtil.SetImageSprite(rank, "UI/PanelRole/AtlasPanelRole/ui_hd_card_back_" .. infoRoleCard.rank .. "_11")
	UIUtil.SetImageSprite(job, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S")

	local flag = self.info:OneOfAllIsHold(index)
	local num = TenaryOp(flag, 0, 1)

	UIUtil.SetImageGray(icon, num)
	UIUtil.SetImageGray(rank, num)
	UIUtil.SetImageGray(job, num)
end
