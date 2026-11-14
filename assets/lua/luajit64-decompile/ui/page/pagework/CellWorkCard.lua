-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageWork/CellWorkCard.lua

require("UI/Item/UIItemBase")

CellWorkCard = class("CellWorkCard", UIItemBase)

function CellWorkCard:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = ownerUI
end

function CellWorkCard:Create(vParam)
	CellWorkCard.base.Create(self, vParam)
end

function CellWorkCard:OnEnter()
	local g = self.UIRootObject

	self.GoBe = GOUtil.FindChildGameObject(g, "GoBeing")
	self.GoNo = GOUtil.FindChildGameObject(g, "GoNone")
	self.TxtName = GOUtil.FindChildComponent(g, "GoBeing/BgName/TxtName", "Text")
	self.TxtLevel = GOUtil.FindChildComponent(g, "GoBeing/BgName/TxtLevel", "Text")
	self.TxtStar = GOUtil.FindChildComponent(g, "GoBeing/Star/TxtStar", "Text")
	self.ImgIcon = GOUtil.FindChildComponent(g, "GoBeing/Icon/Image", "Image")
	self.ImgRank = GOUtil.FindChildComponent(g, "GoBeing/Rank", "Image")
	self.ImgJob = GOUtil.FindChildComponent(g, "GoBeing/Job", "Image")
	self.ImgNum = GOUtil.FindChildComponent(g, "ImgNum", "Image")
	self.TxtLevel.fontSize = 20

	GOUtil.SetRectTransformAnchoredPosition(self.TxtLevel.gameObject, -88, -13)
	self:AddClick(self.UIRootObject, self.OnClickedRoleCard)
end

function CellWorkCard:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.UIRootObject, self.OnClickedRoleCard)
end

function CellWorkCard:UpdateData(infoWork, index)
	self.infoWork = infoWork
	self.index = index or 1

	local cardId = infoWork.tempData.cardIds[self.index] or 0
	local haveCard = cardId ~= 0

	GOUtil.SetActive(self.GoBe, haveCard)
	GOUtil.SetActive(self.GoNo, not haveCard)
	SetImageSprite(self.ImgNum, "UI/PanelWork/AtlasPanelWork/ICO_mis_side_0" .. self.index, self)

	if haveCard then
		local infoRole = RoleCardMgr:GetRole(cardId)
		local infoCard = RoleCardMgr:GetRoleCard(cardId)

		self.TxtName.text = infoRole:GetName()
		self.TxtLevel.text = infoCard.curLevel
		self.TxtStar.text = infoCard.curStarLevel

		SetImageSprite(self.ImgIcon, infoCard.data.MidIcon, self)
		SetImageSprite(self.ImgRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoCard.rank .. "_15", self)
		SetImageSprite(self.ImgJob, "UI/PanelWork/AtlasPanelWork/ICO_" .. infoRole.data.Job .. "_01_S", self)

		local list = infoCard.listAbility

		for j = 1, 3 do
			local imgCon = GOUtil.FindChildComponent(self.GoBe, "Con/" .. j, "Image")

			GOUtil.SetActive(imgCon.gameObject, j <= #list)

			if j <= #list then
				SetImageSprite(imgCon, list[j].Icon, self)
			end
		end
	end
end

function CellWorkCard:OnClickedRoleCard()
	if self.page then
		self.page.notResetTempData = true
		WorkMgr.WorkIdx = self.page.workIdx or 0
	end

	UIMgr.SwitchPanel(PageConditionCard, {
		infoWork = self.infoWork,
		slotIndex = self.index
	})
end
