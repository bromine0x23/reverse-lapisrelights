-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Cell/CellCard.lua

require("UI/Item/UIItemBase")

CellCard = class("CellCard", UIItemBase)

function CellCard:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCard:Create(vParam)
	CellCard.base.Create(self, vParam)
end

function CellCard:OnEnter()
	local g = self.UIRootObject
	local Text = GOUtil.FindChildComponent(g, "GO/GoPower/Text", "Text")

	Text.text = _("Desc_Combat_Power")
	Text = GOUtil.FindChildComponent(g, "GO/GoShow/Text", "Text")
	Text.text = Lang(12436)
	self.ImgIcon = GOUtil.FindChildComponent(g, "GO/Card/Icon", "Image")
	self.RawImage = GOUtil.FindChildComponent(g, "GO/Card/rawIcon", "RawImage")
	self.ImgRank = GOUtil.FindChildComponent(g, "GO/ImgRank", "Image")
	self.TxtName = GOUtil.FindChildComponent(g, "GO/TxtName", "Text")
	self.TxtLevel = GOUtil.FindChildComponent(g, "GO/GoStar/TxtLevel", "Text")
	self.GoFrame = GOUtil.FindChildGameObject(g, "GO/GoStar/Star/Frame")
	self.GoStar1 = GOUtil.FindChildGameObject(g, "GO/GoStar/Star/Star1")
	self.GoStar2 = GOUtil.FindChildGameObject(g, "GO/GoStar/Star/Star2")

	for i = 1, table.getCount(eRankType) do
		self["GoPetal" .. i] = GOUtil.FindChildGameObject(g, "GO/GoFlower/State" .. i)
		self["GoPetal2" .. i] = GOUtil.FindChildGameObject(g, "GO/GoFlower2/Flower/State" .. i)
	end

	self.TxtBattleNum = GOUtil.FindChildComponent(g, "GO/GoUping/TxtNum", "Text")
	self.TxtBattleType = GOUtil.FindChildComponent(g, "GO/GoUping/Text", "Text")
	self.TxtPower = GOUtil.FindChildComponent(g, "GO/GoPower/TextPower", "Text")
	self.TxtChallenge = GOUtil.FindChildComponent(g, "GO/GoLeftNum/Text", "Text")
	self.GoDot = GOUtil.FindChildGameObject(g, "GO/Dot")

	GOUtil.SetActive(self.GoDot, false)

	self.GoNew = GOUtil.FindChildGameObject(g, "GO/New")

	GOUtil.SetActive(self.GoNew, false)

	self.GoShow = GOUtil.FindChildGameObject(g, "GO/GoShow")
	self.GoStar = GOUtil.FindChildGameObject(g, "GO/GoStar")
	self.GoFlower = GOUtil.FindChildGameObject(g, "GO/GoFlower")
	self.GoUping = GOUtil.FindChildGameObject(g, "GO/GoUping")
	self.GoPower = GOUtil.FindChildGameObject(g, "GO/GoPower")
	self.GoLeftNum = GOUtil.FindChildGameObject(g, "GO/GoLeftNum")
	self.GoSelect = GOUtil.FindChildGameObject(g, "GO/GoSelect")
	self.GoCompose = GOUtil.FindChildGameObject(g, "GO/GoCompose")
	self.ComposeComplete = GOUtil.FindChildGameObject(g, "GO/GoCompose/Complete")
	self.Preview = GOUtil.FindChildGameObject(g, "GO/GoCompose/Preview")

	self:AddClick(self.Preview, self.OnPreview)

	self.ComposeProgress = GOUtil.FindChildComponent(g, "GO/GoCompose/Progress", "Image")
	self.ComposeText = GOUtil.FindChildComponent(g, "GO/GoCompose/Text", "Text")
	self.SoulIcon = GOUtil.FindChildComponent(g, "GO/GoCompose/Icon", "Image")
	self.BG = GOUtil.FindChildGameObject(g, "BG")
	self.go_un_card = GOUtil.FindChildGameObject(g, "BG/go_un_card")
	self.GO = GOUtil.FindChildGameObject(g, "GO")
	self.GOAnimation = self:GetChildComponent("GO", "Animation")
	self.GOAnimation.enabled = false
	self.GoFlower2 = GOUtil.FindChildGameObject(g, "GO/GoFlower2")
	self.TxtStoneNum = GOUtil.FindChildComponent(g, "GO/GoFlower2/Stone/Text", "Text")
	self.ImgStoneFillAmount = GOUtil.FindChildComponent(g, "GO/GoFlower2/Stone/Image", "Image")
	self.CardEffect = GOUtil.FindChildGameObject(g, "GO/CardEffect")
	self.IsNeedDealUnload = false
	self.TxtLevel.fontSize = 24
end

function CellCard:OnLeave()
	self:RemoveClick(self.Preview, self.OnPreview)
	UnloadAllImageSprite(self)

	if self.spineGroupHandle then
		ResourceMgr.Cancel(self.spineGroupHandle)

		self.spineGroupHandle = nil
	end

	if self.spineGroupHandle2 then
		ResourceMgr.Cancel(self.spineGroupHandle2)

		self.spineGroupHandle2 = nil
	end

	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end
end

function CellCard:UpdateData(cardData, noExtra, noDot, noNew, noFlower, noPower, noShow)
	if not cardData then
		return
	end

	if not cardData.cardId then
		SetActiveFunc(self.GO, false)
		SetActiveFunc(self.BG, true)
		SetActiveFunc(self.go_un_card, false)

		return
	end

	SetActiveFunc(self.GO, true)
	SetActiveFunc(self.BG, false)
	SetActiveFunc(self.UIRootObject, false)

	local cardId = cardData.cardId

	self.cardId = cardId

	local infoRoleCard

	if cardData.data then
		infoRoleCard = InfoRoleCard(cardData.data.id)

		infoRoleCard:SetPBPlayer(cardData.pbPlayer)
		infoRoleCard:SetData(cardData.data)
	else
		infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
	end

	self:UpdateDot(infoRoleCard, noExtra, noDot)

	self.TxtName.text = infoRoleCard:GetName()
	self.TxtLevel.text = infoRoleCard.curLevel

	RoleCardMgr:SetStar(infoRoleCard, self)

	if self.spineGroupHandle then
		ResourceMgr.Cancel(self.spineGroupHandle)

		self.spineGroupHandle = nil
	end

	if self.spineGroupHandle2 then
		ResourceMgr.Cancel(self.spineGroupHandle2)

		self.spineGroupHandle2 = nil
	end

	self.spineGroupHandle = ResourceMgr.BeginSubmit(function()
		if not IsNil(self.ImgIcon) and self.Icon then
			self.GOAnimation.enabled = true

			UIUtil.SetImageSprite(self.ImgIcon, self.Icon, self)
			DealWithListRef(self, self.Icon)

			self.spineGroupHandle2 = ResourceMgr.BeginSubmit(function()
				if not IsNil(self.ImgRank) and self.Icon2 then
					UIUtil.SetImageSprite(self.ImgRank, self.Icon2, self)
					DealWithListRef(self, self.Icon2)
					SetActiveFunc(self.UIRootObject, true)
				end
			end)

			ResourceMgr.SubmitCache("UIDyAtlas/RoleCardRank/ui_hd_card_back_" .. infoRoleCard.rank .. "_7", self, "Icon2", Sprite)
			ResourceMgr.EndSubmit()
		end
	end)

	ResourceMgr.SubmitCache(infoRoleCard.data.MidIcon, self, "Icon", Sprite)
	ResourceMgr.EndSubmit()
	RoleCardMgr:SetPetal(infoRoleCard, self)
	self:ShowEffect(RoleCardMgr.ShowCardEffect(infoRoleCard))

	if noExtra == eEnterType.cardCompose then
		local now = cardData.now
		local aim = cardData.aim

		if cardData.complete then
			GOUtil.SetImageAlpha(self.GoCompose, 0)
		else
			GOUtil.SetImageAlpha(self.GoCompose, 255)
		end

		local soulID = tonumber("2" .. cardData.cardId)

		UIUtil.SetImageSprite(self.SoulIcon, ItemManager:GetIcon(soulID), self)

		self.ComposeText.text = now .. "/" .. aim
		self.ComposeProgress.fillAmount = now / aim

		SetActiveFunc(self.ComposeComplete, cardData.complete)
		SetActiveFunc(self.GoPower, false)
		SetActiveFunc(self.GoCompose, true)

		return
	end

	local slotIdx = 0

	if cardData.team then
		for k = 1, #cardData.team do
			local v = cardData.team[k]

			if k <= 5 and v == cardId then
				slotIdx = k
				self.TxtBattleType.text = Lang(5000013)

				break
			elseif k > 5 and v == cardId then
				slotIdx = k
				self.TxtBattleType.text = Lang(5000014)

				break
			end
		end

		self.TxtBattleNum.text = slotIdx
	end

	SetActiveFunc(self.GoUping, CardExtraMgr.enterType == eEnterType.cardMain and slotIdx ~= 0 and not noExtra)

	local isShow = false

	for _, v in pairs(PlayerInst.InfoPlayer.roleCards) do
		if v == cardId then
			isShow = true
		end
	end

	SetActiveFunc(self.GoShow, CardExtraMgr.enterType == eEnterType.cardShow and isShow and not noExtra and not noShow)
	SetActiveFunc(self.GoPower, false)

	if not noExtra and CardExtraMgr.enterType ~= eEnterType.cardShow then
		SetActiveFunc(self.GoPower, not noPower)

		local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

		self.TxtPower.text = RoleCardMgr:GetCardFightValue(infoRoleCard)
	end

	if cardData and cardData.isGrade then
		local TextPower = self:GetChildComponent("GO/GoPower/Text", "Text")

		TextPower.text = _("Desc_Combat_Score")
	else
		local TextPower = self:GetChildComponent("GO/GoPower/Text", "Text")

		TextPower.text = _("Desc_Combat_Score")
		self.TxtPower.text = RoleCardMgr:GetCardFightValue(infoRoleCard)
	end

	SetActiveFunc(self.GoLeftNum, false)
	SetActiveFunc(self.GoFlower2, CardExtraMgr.enterType == eEnterType.cardPass)

	if CardExtraMgr.enterType == eEnterType.cardPass then
		if infoRoleCard.curPetal == infoRoleCard.maxPetal then
			self.TxtStoneNum.text = infoRoleCard.pb.soul
			self.ImgStoneFillAmount.fillAmount = 1
		else
			local listCost = RoleCardMgr:GetNextUpCost(infoRoleCard, 2)
			local info, need

			for _, v in ipairs(listCost) do
				local id = v[1]
				local infoStone = ItemManager:Get(v[1])

				if infoStone and infoStone.data.Type == "I_SOUL" then
					info = infoStone
					need = v[2] or 0

					break
				end
			end

			if info then
				local hold = info:GetCurResNum()

				self.TxtStoneNum.text = hold .. "/" .. need

				if hold == 0 then
					self.ImgStoneFillAmount.fillAmount = 0
				else
					self.ImgStoneFillAmount.fillAmount = hold / need
				end
			end
		end

		for i = 1, table.getCount(eRankType) do
			SetActiveFunc(self["GoPetal2" .. i], infoRoleCard.cardRank == i)
		end

		for i = 1, infoRoleCard.cardRank + 2 do
			local image = GOUtil.FindChildComponent(self["GoPetal2" .. infoRoleCard.cardRank], "" .. i, "Image")

			if i == infoRoleCard.curPetal + 1 then
				UIUtil.SetImageSprite(image, "UI/Common/CellCard/AtlasCellCard/ICO_diamond_03b", self)
			else
				UIUtil.SetImageSprite(image, "UI/Common/CellCard/AtlasCellCard/ICO_diamond_03", self)

				local gray = i <= infoRoleCard.curPetal and 0 or 1

				DealWithListRef(self, UIUtil.SetImageGray(image, gray))
			end
		end
	end

	if noFlower then
		SetActiveFunc(self.GoFlower2, false)
	end

	SetActiveFunc(self.GoStar, not noExtra)
	SetActiveFunc(self.GoFlower, not noExtra and CardExtraMgr.enterType ~= eEnterType.cardPass)

	if cardData.selIdx then
		self:UpdateSlectState(cardData.selIdx)
	else
		SetActiveFunc(self.GoSelect, false)
	end
end

function CellCard:UpdateSlectState(selIdx)
	SetActiveFunc(self.GoSelect, CardExtraMgr.enterType == eEnterType.cardPass and selIdx == self.Index)
end

function CellCard:OnPreview()
	local data = {
		onlyShow = true,
		cardId = self.cardId
	}

	UIMgr.SwitchPanel(PageRoleCard, data)
end

function CellCard:UpdateDot(card, noExtra, noDot)
	if not noDot then
		if noExtra == eEnterType.cardCompose then
			local canCompose = CardRDL.ComposeRDL.IsCanCompose(card.id)

			GOUtil.SetActive(self.GoDot, canCompose)
		else
			local isNew = CardRDL.NewRDL.IsNewCard(card.id)

			GOUtil.SetActive(self.GoNew, isNew)
		end
	end
end

function CellCard:ShowEffect(isShow)
	if not self.IsNeedDealUnload and isShow then
		RoleCardMgr:CreateEffect()

		self.IsNeedDealUnload = true
	end

	SetActiveFunc(self.CardEffect, isShow)
end
