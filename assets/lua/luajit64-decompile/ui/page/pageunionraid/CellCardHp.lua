-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/CellCardHp.lua

require("UI/Item/UIItemBase")

CellCardHp = class("CellCardHp", UIItemBase)

function CellCardHp:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCardHp:OnEnter(vParam)
	local g = self.UIRootObject
	local txt = GOUtil.FindChildComponent(g, "GoUnused/Text", "Text")

	txt.text = _("Desc_Battle_Unable")
	txt = GOUtil.FindChildComponent(g, "Info/Text", "Text")
	txt.text = Lang(5000010)
	self.CardIcon = GOUtil.FindChildComponent(g, "Card/Icon", "Image")
	self.CardRank = GOUtil.FindChildComponent(g, "Card/Rank", "Image")
	self.RoleJob = GOUtil.FindChildComponent(g, "Info/Job", "Image")
	self.TxtLevel = GOUtil.FindChildComponent(g, "Info/TxtLevel", "Text")
	self.GoFrame = GOUtil.FindChildGameObject(g, "Info/Star/Frame")
	self.GoStar1 = GOUtil.FindChildGameObject(g, "Info/Star/Star1")
	self.GoStar2 = GOUtil.FindChildGameObject(g, "Info/Star/Star2")

	for i = 1, eRankType.UR + 2 do
		self["GoPetal" .. i] = GOUtil.FindChildGameObject(g, "Info/Petal/" .. i)
	end

	self.TxtCost = GOUtil.FindChildComponent(g, "Info/TxtCost", "Text")
	self.ImgHpBar = GOUtil.FindChildComponent(g, "Info/Hp/HpBar", "Image")
	self.TxtCurHp = GOUtil.FindChildComponent(g, "Info/Hp/TxtCurHp", "Text")
	self.TxtMaxHp = GOUtil.FindChildComponent(g, "Info/Hp/TxtMaxHp", "Text")
	self.GoUnused = GOUtil.FindChildGameObject(g, "GoUnused")
	self.GoSelect = GOUtil.FindChildGameObject(g, "GoSelect")
	self.TxtSelect = GOUtil.FindChildComponent(g, "GoSelect/Text", "Text")
	self.CardEffect = GOUtil.FindChildGameObject(g, "CardEffect")
	self.isShowed = false
	self.IsNeedDealUnload = false
end

function CellCardHp:OnLeave()
	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end

	UnloadAllImageSprite(self)
end

function CellCardHp:UpdateData(infoRoleCard, noState, isSelect, isShow)
	if not infoRoleCard or not infoRoleCard:IsHold() then
		return
	end

	self.infoRoleCard = infoRoleCard

	SetImageSprite(self.CardIcon, infoRoleCard.data.MidIcon, self)
	SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_9", self)
	SetImageSprite(self.RoleJob, "UIDyAtlas/RoleJob/ICO_" .. infoRoleCard.JobStr .. "_01_S", self)

	self.TxtLevel.text = infoRoleCard.curLevel

	RoleCardMgr:SetStar(infoRoleCard, self)
	RoleCardMgr.SetPetalInfo(infoRoleCard, self)

	local infoRole = RoleCardMgr:GetRole(infoRoleCard.id)

	self.TxtCost.text = RoleCardMgr:GetCardCost(infoRoleCard, infoRole, 1)
	self.ImgHpBar.fillAmount = infoRoleCard.curCommRaidHpPer / infoRoleCard.maxRaidHpPer

	self.GoUnused:SetActive(infoRoleCard.curCommRaidHpPer == 0 and not noState)

	local attrType1 = RoleMgr:IndexToAttrType(1)
	local roleAttr = RoleCardMgr:GetRole(infoRoleCard.id):GetAttWithCard(attrType1, infoRoleCard)

	self.TxtCurHp.text = math.ceil(infoRoleCard.curCommRaidHpPer * roleAttr)
	self.TxtMaxHp.text = "/" .. math.ceil(infoRoleCard.maxRaidHpPer * roleAttr)

	self:UpdateSelect(isSelect)
	self:UpdateShowCardEffect(isShow)
end

function CellCardHp:UpdateHpPercent(changeValue, callback)
	if not self.infoRoleCard then
		return
	end

	local attrType1 = RoleMgr:IndexToAttrType(1)
	local roleAttr = RoleCardMgr:GetRole(self.infoRoleCard.id):GetAttWithCard(attrType1, self.infoRoleCard)
	local curHpPercent = self.infoRoleCard.curCommRaidHpPer + changeValue / 100
	local tweener = GOUtil.DOFillAmount(self.ImgHpBar, curHpPercent, 0.6)

	GOUtil.DoFloat(self.TxtCurHp, curHpPercent * roleAttr, 0.6)

	if callback then
		GOUtil.SetTweenerCallback(tweener, callback)
	end
end

function CellCardHp:UpdateSelect(flag)
	if flag == nil then
		flag = false
	end

	GOUtil.SetActive(self.GoSelect, flag)

	if flag then
		local color

		if self.infoRoleCard.curCommRaidHpPer == 0 then
			color = getColorFromString("FFF5B4")
			self.TxtSelect.text = _("Desc_Card_HP_Revive")
		elseif self.infoRoleCard.curCommRaidHpPer ~= 1 then
			color = getColorFromString("9AFEA6")
			self.TxtSelect.text = _("Desc_Card_HP_Reply")
		end

		if color then
			UIUtil.SetGraphicColorRGB(self.TxtSelect, color.r, color.g, color.b)
		end
	end
end

function CellCardHp:UpdateShowCardEffect(isShow)
	if not self.IsNeedDealUnload and isShow then
		RoleCardMgr:CreateEffect()

		self.IsNeedDealUnload = true
	end

	local flag = Tenary(isShow, false)

	if self.isShowed ~= flag then
		GOUtil.SetActive(self.CardEffect, flag)

		self.isShowed = flag
	end
end
