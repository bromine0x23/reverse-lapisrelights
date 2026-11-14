-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/MyRoleCard.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageTeam/DlgCardDetail")
require("UI/Page/PageRoleCard/Page/PageRoleCard")

MyRoleCard = class("MyRoleCard", UIItemBase)

function MyRoleCard:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.showCost = true
	self.showCounter = true
	self.showRedPoint = true
	self.showPower = true
end

function MyRoleCard:Create(vParam)
	MyRoleCard.base.Create(self, vParam)
end

function MyRoleCard:OnEnter()
	self:OnLocalText()

	self.DlgLongTip = ResourceMgr.LoadSync("UI/Common/DlgCommon/DlgLongTip")
	self.roleIcon = self:GetChildComponent("Panel/Card/Icon", "Image")
	self.cardBg = self:GetChildComponent("Panel/CardRank", "Image")
	self.roleJob = self:GetChildComponent("Panel/RoleJob", "Image")

	if self.showCounter then
		self.imgCounter = self:GetChildComponent("Panel/ImgCounterCon/ImgCounter", "Image")
	end

	self.txtLevel = self:GetChildComponent("Panel/TxtLevel", "Text")
	self.curUpGo = self:GetChildGameObject("Panel/State/CurUp")
	self.curUpImgGo = self:GetChildGameObject("Panel/State/CurUp/Image")
	self.upingGo = self:GetChildGameObject("Panel/State/Uping")
	self.leaderGo = self:GetChildGameObject("Panel/State/Img_Leader")
	self.addingGo = self:GetChildGameObject("Panel/State/Adding")
	self.limitGo = self:GetChildGameObject("Panel/State/Limit")
	self.limitTsGo = self:GetChildGameObject("Panel/State/TsLimit")
	self.curUpPosTxt = self:GetChildComponent("Panel/State/CurUp/Image/Txt1", "Text")
	self.upingPosTxt = self:GetChildComponent("Panel/State/Uping/Image/Txt1", "Text")
	self.addingPosTxt = self:GetChildComponent("Panel/State/Adding/Image/Txt1", "Text")
	self.downBtnGo = self:GetChildGameObject("Panel/State/CurUp/DownBtn")

	for i = 1, 5 do
		self["ImageStarFrame" .. i] = self:GetChildGameObject("Panel/StarLevel/Image" .. i)
		self["ImageStar" .. i] = self:GetChildGameObject("Panel/StarLevel/Star" .. i)
	end

	self.GoFrame = self:GetChildGameObject("Panel/StarLevel/Frame")
	self.GoStar1 = self:GetChildGameObject("Panel/StarLevel/Star1")
	self.GoStar2 = self:GetChildGameObject("Panel/StarLevel/Star2")
	self.GoNew = self:GetChildGameObject("Panel/New")

	for i = 1, 4 do
		self["State" .. i] = self:GetChildGameObject("Panel/Flower/State" .. i)
	end

	if self.showCost then
		self.txtCost = self:GetChildComponent("Panel/Cost/TxtCost", "Text")
	end

	if self.showPower then
		self.txtPower = self:GetChildComponent("Panel/Power/TextPower", "Text")
	end

	if self.showRedPoint then
		self.redPoint = self:GetChildGameObject("Panel/RedPoint")
	end

	self.CardEffect = self:GetChildGameObject("Panel/CardEffect")
	self.IsNeedDealUnload = false
	self.GoZeroHp = self:GetChildGameObject("Panel/State/ZeroHp")
	self.GoHpBar = self:GetChildGameObject("HpBar")
	self.ImgHp = self:GetChildComponent("HpBar/Hp", "Image")
	self.TexHp = self:GetChildComponent("HpBar/tex_hp", "Text")
	self.BG = self:GetChildGameObject("BG")
	self.go_un_card = self:GetChildGameObject("BG/go_un_card")
	self.Panel = self:GetChildGameObject("Panel")
	self.txtLevel.fontSize = 18

	self:OnEnterEx()
	self:OnRegisterEvent()
end

function MyRoleCard:OnLeave()
	ResourceMgr.Unload(self.DlgLongTip)
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)

	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end
end

function MyRoleCard:OnRegisterEvent()
	self:AddClick(self.UIRootObject, self.OnClickedCell)
	self:AddClick(self.downBtnGo, self.OnClickedDownButton)
	self:AddListener(self.UIRootObject, self.OnPointerDown, EventTriggerType.PointerLongPress)
end

function MyRoleCard:OnUnRegisterEvent()
	self:RemoveClick(self.UIRootObject, self.OnClickedCell)
	self:RemoveClick(self.downBtnGo, self.OnClickedDownButton)
	self:RemoveListener(self.UIRootObject, self.OnPointerDown, EventTriggerType.PointerLongPress)
end

function MyRoleCard:OnPointerDown(data)
	if type(self.teamSystemAgent) == "number" then
		return
	end

	local pid = self.infoRoleCard.pb.playerId

	if pid ~= PlayerInst.InfoPlayer.pid then
		return
	end

	if data.clickCount == 1 then
		if not self.GoDlgLongTip then
			self.GoDlgLongTip = GOUtil.InstantiatePrefab(self.DlgLongTip, self.UIRootObject)

			self.GoDlgLongTip.transform:SetAsLastSibling()
		end

		self.breakLongState = false
		self.LongPressState = true
		GOUtil.FindChildComponent(self.GoDlgLongTip, "BG/Bar", "UIDlgLongTip").onEndTween = function()
			local function func(...)
				self.LongPressState = false
			end

			if self.breakLongState then
				if not IsNil(self.GoDlgLongTip) then
					self.GoDlgLongTip:Destroy()
				end

				self.GoDlgLongTip = nil

				func()

				return
			end

			local param = {}

			param.cardId = self.infoRoleCard.id
			param.callback = func

			if self.parentScroll then
				local posY = self.parentScroll.ScrollView.content.anchoredPosition.y

				CardExtraMgr:SetCardViewPosY(posY)
			end

			UIMgr.SwitchPanel(PageRoleCard, param)
		end
	else
		self.breakLongState = true
	end
end

function MyRoleCard:OnClickedCell(data)
	if type(self.teamSystemAgent) == "number" then
		return
	end

	if self.LongPressState then
		self.LongPressState = false

		return
	end

	if self.teamSystemAgent.isRaid then
		local curHpPer = self.infoRoleCard.curCommRaidHpPer

		if curHpPer == 0 then
			UIMgr.ShowMsg(_("Msg_NoHp"))

			return
		end
	end

	if self.teamSystemAgent.isGvg and Infogvg:CardVaild(self.infoRoleCard.id) == false then
		UIMgr.ShowMsg(_("Msg_GvgCardTimesLimit"))

		return
	end

	if self.teamSystemAgent.isTimespace and self.infoRoleCard.tsLimit then
		UIMgr.ShowMsg(_("Msg_TimeSpaceLimit"))

		return
	end

	if self.isLimit then
		UIMgr.ShowDialog(_("DlgCommon_CardLimit"))

		return
	end

	CardRDL.NewRDL.SubNewCardPlayerPrefs(self.infoRoleCard)

	if self.GoNew then
		GOUtil.SetActive(self.GoNew, false)
	end

	if self.curIsUp then
		self.clickSlot:ReplaceUpCard()
		self:OnBack()
	else
		local cardIdx = self.teamAgent:FindSameRoleCard(self.infoRoleCard.id)

		if cardIdx ~= -1 and cardIdx ~= self.clickSlot.index then
			UIMgr.ShowDialog(_("DlgCommon_RoleCardExists"), function(index)
				if index == 1 then
					self:OpenDetails(function(index)
						if index == 1 then
							local info = self.clickSlot:GetCardInfo()
							local conflictSlot = self.teamAgent.slotList[cardIdx]

							conflictSlot:ReplaceUpCard()
							self.clickSlot:ReplaceUpCard(self.infoRoleCard, RoleCardMgr:GetRole(self.infoRoleCard.id))

							if conflictSlot:LimitCheck(info.upInfoRoleCard) and (not info.isHelperCard or conflictSlot.isHelperSlot) then
								conflictSlot:ReplaceUpCard(info.upInfoRoleCard, info.upInfoRole, info.isHelperCard)
							end

							self.clickSlot:ReplaceUpCard(self.infoRoleCard, RoleCardMgr:GetRole(self.infoRoleCard.id))

							if self.isAdd then
								local idx = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id)
								local slot = self.teamAgent.slotList[idx]

								slot:ReplaceAddCard()
							end

							local addCard = self.clickSlot.addInfoRoleCard
							local addCardId = addCard and addCard.id or 0
							local sameRole = TeamSystemAgent.SameRole(addCardId, self.infoRoleCard.id)

							if sameRole then
								self.clickSlot.addInfoRoleCard = nil

								UIMgr.ShowMsg(_("DlgCommon_SameRoleCantAdd"))
							end

							self:OnBack()
						end
					end)
				end
			end)
		else
			local addCard = self.clickSlot.addInfoRoleCard
			local addCardId = addCard and addCard.id or 0
			local sameRole = TeamSystemAgent.SameRole(addCardId, self.infoRoleCard.id)

			if sameRole then
				UIMgr.ShowDialog(_("DlgCommon_SameRoleCardExists"), function(index)
					if index == 1 then
						self:OpenDetails(function(index)
							if index == 1 then
								self.clickSlot:ReplaceUpCard(self.infoRoleCard, RoleCardMgr:GetRole(self.infoRoleCard.id))

								local cardIdx = self.teamAgent:FindSameRoleCard(self.infoRoleCard.id)

								if cardIdx ~= -1 then
									local slot = self.teamAgent.slotList[cardIdx]

									slot:ReplaceAddCard()
								end

								self:OnBack()
							end
						end)
					end
				end)
			elseif self.isAdd then
				UIMgr.ShowDialog(_("DlgCommon_RoleCardExists"), function(index)
					if index == 1 then
						self:OpenDetails(function(index)
							if index == 1 then
								self.clickSlot:ReplaceUpCard(self.infoRoleCard, RoleCardMgr:GetRole(self.infoRoleCard.id))

								local idx = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id)
								local slot = self.teamAgent.slotList[idx]

								slot:ReplaceAddCard()
								self:OnBack()
							end
						end)
					end
				end)
			else
				self:OpenDetails(function(index)
					if index == 1 then
						self.clickSlot:ReplaceUpCard(self.infoRoleCard, RoleCardMgr:GetRole(self.infoRoleCard.id))
						self:OnBack()
					end
				end)
			end
		end
	end
end

function MyRoleCard:OpenDetails(call)
	if CardExtraMgr.detailsLookInfo then
		local param = {}

		param.call = call
		param.infoRoleCard = self.infoRoleCard

		UIMgr.AddPanel(DlgCardDetail(), param)
	else
		call(1)
	end
end

function MyRoleCard:OnClickedDownButton(data)
	if type(self.teamSystemAgent) == "number" then
		return
	end

	self.clickSlot:ReplaceUpCard()
	self:OnBack()
end

function MyRoleCard:OnBack()
	if self.teamSystemAgent.teamChangeCall ~= nil then
		for i = 1, 5 do
			if self.teamAgent.slotList[i].upInfoRoleCard then
				local cardId = self.teamAgent.slotList[i].upInfoRoleCard.id

				for n = 1, 5 do
					if self.teamAgent.slotList[n].addInfoRoleCard and self.teamAgent.slotList[n].addInfoRoleCard.id == cardId then
						self.teamAgent.slotList[n].addInfoRoleCard = nil
					end
				end

				if self.teamAgent.slotList[i].addInfoRoleCard and TeamSystemAgent.SameRole(self.teamAgent.slotList[i].addInfoRoleCard.id, cardId) then
					self.teamAgent.slotList[i].addInfoRoleCard = nil
				end
			end
		end

		local function cb(...)
			UIMgr.PopPanel()
		end

		self.teamSystemAgent.teamChangeCall(cb)
	else
		UIMgr.PopPanel()
	end
end

function MyRoleCard:UpdateData(teamSystemAgent, clickSlot, infoRoleCard, upCardListIds, isGrade, parentScroll)
	self.teamSystemAgent = teamSystemAgent
	self.parentScroll = parentScroll

	if type(teamSystemAgent) == "number" then
		SetActiveFunc(self.Panel, false)

		if self.BG then
			SetActiveFunc(self.BG, true)
		end

		SetActiveFunc(self.go_un_card, teamSystemAgent % 2 == 1)
		SetActiveFunc(self.GoHpBar, false)

		return
	end

	SetActiveFunc(self.Panel, true)

	if self.BG then
		SetActiveFunc(self.BG, false)
	end

	local isNew = CardRDL.NewRDL.IsNewCard(infoRoleCard.id)

	if self.GoNew then
		GOUtil.SetActive(self.GoNew, isNew)
	end

	self.clickSlot = clickSlot
	self.teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	self.infoRoleCard = infoRoleCard
	self.upCardListIds = upCardListIds

	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

	UIUtil.SetImageSprite(self.roleIcon, infoRoleCard.data.MidIcon, self)

	local path = "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_9"

	UIUtil.SetImageSprite(self.cardBg, path, self)
	UIUtil.SetImageSprite(self.roleJob, "UI/PanelChooseCard/AtlasCard/ICO_" .. infoRole.data.Job .. "_01_S", self)

	if self.showCounter and self.teamSystemAgent.monsterJob then
		SetActiveFunc(self.imgCounter.gameObject, true)
		JobCheckingUtil.Init()

		local num = JobCheckingUtil.GetMul(infoRole.data.Job, self.teamSystemAgent.monsterJob)

		if num > 1 then
			UIUtil.SetImageSprite(self.imgCounter, "UI/PanelChooseCard/AtlasCard/ui_hd_icon_up_02", self)
		elseif num < 1 then
			UIUtil.SetImageSprite(self.imgCounter, "UI/PanelChooseCard/AtlasCard/ui_hd_icon_down_02", self)
		else
			SetActiveFunc(self.imgCounter.gameObject, false)
		end
	elseif self.imgCounter then
		SetActiveFunc(self.imgCounter.gameObject, false)
	end

	local pickCardId = RoleCardMgr:GetRole(infoRoleCard.id):GetRoleCardId()

	self.txtLevel.text = infoRoleCard.curLevel

	RoleCardMgr:SetStar(infoRoleCard, self)

	local cardRank = infoRoleCard.cardRank

	for i = 1, 4 do
		SetActiveFunc(self["State" .. i], i == cardRank)
	end

	local flower = self["State" .. cardRank]
	local count = infoRoleCard.maxPetal
	local curNum = infoRoleCard.curPetal

	for i = 1, count do
		local imgF = GOUtil.FindChildComponent(flower, "" .. i, "Image")
		local isOk = i <= curNum
		local gray = TenaryOp(isOk, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(imgF, gray))
	end

	if self.showCost then
		self.txtCost.text = math.ceil(RoleCardMgr:GetCardCost(infoRoleCard, infoRole, 1))
	end

	if self.showPower then
		self.txtPower.text = math.ceil(RoleCardMgr:GetFightValue(infoRole, infoRoleCard))

		if isGrade then
			self:GetChildComponent("Panel/Power/Text", "Text").text = _("Desc_Combat_Role_Score")
		else
			self:GetChildComponent("Panel/Power/Text", "Text").text = _("Desc_Combat_Score")
			self.txtPower.text = RoleCardMgr:GetCardFightValue(infoRoleCard)
		end
	end

	if self.showRedPoint then
		SetActiveFunc(self.redPoint, false)
	end

	if self.GoZeroHp then
		SetActiveFunc(self.GoZeroHp, false)
		SetActiveFunc(self.GoHpBar, false)

		if self.teamSystemAgent.isRaid then
			local isZeroHp = infoRoleCard.curCommRaidHpPer == 0

			SetActiveFunc(self.GoZeroHp, isZeroHp)
			SetActiveFunc(self.GoHpBar, true)

			local maxHpPer = infoRoleCard.maxRaidHpPer
			local curHpPer = infoRoleCard.curCommRaidHpPer
			local attrType1 = RoleMgr:IndexToAttrType(1)
			local roleAttr = RoleCardMgr:GetRole(infoRoleCard.id):GetAttWithCard(attrType1, infoRoleCard)

			self.TexHp.text = math.ceil(curHpPer * roleAttr) .. "/" .. math.ceil(maxHpPer * roleAttr)
			self.ImgHp.fillAmount = curHpPer / maxHpPer
		end

		if self.teamSystemAgent.isGvg then
			local isZeroHp = not Infogvg:CardVaild(infoRoleCard.id)

			SetActiveFunc(self.GoZeroHp, isZeroHp)
		end
	end

	local isShow = RoleCardMgr.ShowCardEffect(self.infoRoleCard)

	if not self.IsNeedDealUnload and isShow then
		RoleCardMgr:CreateEffect()

		self.IsNeedDealUnload = true
	end

	if not IsNil(self.CardEffect) then
		GOUtil.SetActive(self.CardEffect, isShow)
	end

	self:UpdateState()
	self:UpdateDataEx()
end

function MyRoleCard:UpdateState()
	SetActiveFunc(self.curUpGo, false)
	SetActiveFunc(self.upingGo, false)
	SetActiveFunc(self.leaderGo, false)
	SetActiveFunc(self.addingGo, false)
	SetActiveFunc(self.limitGo, false)
	SetActiveFunc(self.limitTsGo, false)

	self.curIsUp = false
	self.isLimit = false
	self.isAdd = false

	if self.clickSlot:LimitCheck(self.infoRoleCard) then
		for i, slot in ipairs(self.teamAgent.slotList) do
			if slot.isHelperCard and slot.upInfoRoleCard.id == self.infoRoleCard.id then
				return
			end
		end

		local isUp = self.teamAgent:GetUpCardIdx(self.infoRoleCard.id) ~= -1

		self.isAdd = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id) ~= -1

		local clickUpCard = self.clickSlot.upInfoRoleCard
		local clickCardId = clickUpCard and clickUpCard.id or 0

		if self.teamSystemAgent.isTimespace and self.infoRoleCard.tsLimit then
			SetActiveFunc(self.limitTsGo, true)
		end

		if isUp then
			if clickCardId == self.infoRoleCard.id then
				SetActiveFunc(self.curUpGo, true)
				SetActiveFunc(self.curUpImgGo, false)

				self.curUpPosTxt.text = self.teamAgent:GetUpCardIdx(self.infoRoleCard.id)
				self.curIsUp = true
			else
				SetActiveFunc(self.upingGo, true)

				self.upingPosTxt.text = self.teamAgent:GetUpCardIdx(self.infoRoleCard.id)
			end

			if self.teamSystemAgent.isRaid then
				SetActiveFunc(self.GoZeroHp, false)
			end

			SetActiveFunc(self:GetChildGameObject("Panel/img_employ"), false)
		elseif not isUp then
			local isemploy = false

			for i = 1, 5 do
				if self.upCardListIds[i] and RoleCardMgr:GetRole(self.infoRoleCard.id).data.ID == self.upCardListIds[i].upRoleId then
					isemploy = true
				end
			end

			SetActiveFunc(self:GetChildGameObject("Panel/img_employ"), isemploy)
		end

		if self.isAdd then
			SetActiveFunc(self.addingGo, true)
			SetActiveFunc(self.upingGo, false)

			self.addingPosTxt.text = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id)

			if self.teamSystemAgent.isGvg then
				local isZeroHp = not Infogvg:CardVaild(self.infoRoleCard.id)

				if isZeroHp then
					SetActiveFunc(self.addingGo, false)
				end
			end
		end
	else
		self.isLimit = true

		SetActiveFunc(self.limitGo, true)
	end
end

function MyRoleCard:OnLocalText()
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Cost/Text/", "Text")
	TextAuto.text = Lang(5000010)
	TextAuto = self:GetChildComponent("Panel/State/CurUp/Image/Txt2/", "Text")
	TextAuto.text = Lang(5000015)
	TextAuto = self:GetChildComponent("Panel/State/CurUp/DownBtn/Txt/", "Text")
	TextAuto.text = Lang(5000012)
	TextAuto = self:GetChildComponent("Panel/State/Uping/Image/Txt2/", "Text")
	TextAuto.text = Lang(5000013)
	TextAuto = self:GetChildComponent("Panel/State/Adding/Image/Txt2/", "Text")
	TextAuto.text = Lang(5000014)
end

function MyRoleCard:OnEnterEx()
	return
end

function MyRoleCard:UpdateDataEx()
	return
end
