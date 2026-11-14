-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/AddCard.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageRoleCard/Page/PageRoleCard")

AddCard = class("AddCard", MyRoleCard)

function AddCard:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.showCounter = false
end

function AddCard:Create(vParam)
	AddCard.base.Create(self, vParam)
end

function AddCard:OnLocalText()
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Cost/Text/", "Text")
	TextAuto.text = Lang(5000010)
	TextAuto = self:GetChildComponent("Panel/State/CurUp/Image/Txt2/", "Text")
	TextAuto.text = Lang(5000011)
	TextAuto.verticalOverflow = UnityEngine.VerticalWrapMode.Overflow
	TextAuto = self:GetChildComponent("Panel/State/CurUp/DownBtn/Txt/", "Text")
	TextAuto.text = Lang(5000012)
	TextAuto = self:GetChildComponent("Panel/State/Uping/Image/Txt2/", "Text")
	TextAuto.text = Lang(5000013)
	TextAuto.verticalOverflow = UnityEngine.VerticalWrapMode.Overflow
	TextAuto = self:GetChildComponent("Panel/State/Adding/Image/Txt2/", "Text")
	TextAuto.text = Lang(5000014)
	TextAuto.verticalOverflow = UnityEngine.VerticalWrapMode.Overflow
end

function AddCard:OnEnterEx()
	self.fistIcon = self:GetChildComponent("Panel/Fist", "Image")
end

function AddCard:UpdateDataEx()
	local path = ""

	if self.clickSlot.upInfoRoleCard then
		local upCardId = self.clickSlot.upInfoRoleCard.id
		local type = TeamSystemAgent.GetAddCardType(upCardId, self.infoRoleCard.id)

		self.fistIcon.enabled = true

		if type == 1 then
			UIUtil.SetImageSprite(self.fistIcon, "UI/PanelChooseCard/AtlasCard/IC_support_lv_01b", self)
		elseif type == 2 then
			UIUtil.SetImageSprite(self.fistIcon, "UI/PanelChooseCard/AtlasCard/IC_support_lv_02b", self)
		else
			UIUtil.SetImageSprite(self.fistIcon, "UI/PanelChooseCard/AtlasCard/IC_support_lv_03b", self)
		end
	end

	local infoRole = RoleMgr:GetRole(self.infoRoleCard.data.CharacterID)

	self.txtCost.text = RoleCardMgr:GetCardCost(self.infoRoleCard, infoRole, 2)
end

function AddCard:UpdateState()
	local clickAddCard = self.clickSlot.addInfoRoleCard
	local clickCardId = clickAddCard and clickAddCard.id or 0

	SetActiveFunc(self.curUpGo, false)
	SetActiveFunc(self.upingGo, false)
	SetActiveFunc(self.addingGo, false)

	self.upCardListIds = {}

	for i = 1, #self.teamAgent.slotList do
		if self.teamAgent.slotList[i].upInfoRoleCard then
			local upCardId = self.teamAgent.slotList[i].upInfoRoleCard.id
			local upRoleId = RoleCardMgr:GetRoleId(upCardId)

			self.upCardListIds[i] = {}
			self.upCardListIds[i].upCardId = upCardId
			self.upCardListIds[i].upRoleId = upRoleId
		end
	end

	for i, slot in ipairs(self.teamAgent.slotList) do
		if slot.isHelperCard and slot.upInfoRoleCard.id == self.infoRoleCard.id then
			return
		end
	end

	self:GetChildComponent("Panel/Power/TextPower", "Text").text = RoleCardMgr:GetCardFightValue(self.infoRoleCard)

	local isUp = self.teamAgent:GetUpCardIdx(self.infoRoleCard.id) ~= -1
	local isAdd = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id) ~= -1

	if isAdd then
		if clickCardId == self.infoRoleCard.id then
			SetActiveFunc(self.curUpGo, true)
			SetActiveFunc(self.curUpImgGo, false)

			self.curUpPosTxt.text = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id)
		else
			SetActiveFunc(self.addingGo, true)

			self.addingPosTxt.text = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id)
		end
	elseif not isUp then
		local isemploy = false

		for i = 1, 5 do
			if self.upCardListIds[i] and RoleCardMgr:GetRole(self.infoRoleCard.id).data.ID == self.upCardListIds[i].upRoleId then
				isemploy = true
			end
		end

		SetActiveFunc(self:GetChildGameObject("Panel/img_employ"), false)
	elseif isUp then
		SetActiveFunc(self.upingGo, true)

		self.upingPosTxt.text = self.teamAgent:GetUpCardIdx(self.infoRoleCard.id)

		SetActiveFunc(self:GetChildGameObject("Panel/img_employ"), false)
	end
end

function AddCard:OnClickedCell(data)
	local clickAddCard = self.clickSlot.addInfoRoleCard
	local clickCardId = clickAddCard and clickAddCard.id or 0

	CardRDL.NewRDL.SubNewCardPlayerPrefs(self.infoRoleCard)

	if self.GoNew then
		GOUtil.SetActive(self.GoNew, false)
	end

	if self.infoRoleCard.id == clickCardId then
		self.clickSlot:ReplaceAddCard()
		self:OnBack()
	else
		local function addFunc(...)
			local addIdx = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id)
			local upIdx = self.teamAgent:GetUpCardIdx(self.infoRoleCard.id)

			if addIdx ~= -1 then
				UIMgr.ShowDialog(_("DlgCommon_RoleCardExists"), function(index)
					if index == 1 then
						local conflictSlot = self.teamAgent.slotList[addIdx]

						conflictSlot:ReplaceAddCard()
						self.clickSlot:ReplaceAddCard(self.infoRoleCard, RoleCardMgr:GetRole(self.infoRoleCard.id))
						self:OnBack()
					end
				end)
			elseif upIdx ~= -1 then
				UIMgr.ShowDialog(_("DlgCommon_RoleCardExists"), function(index)
					if index == 1 then
						local conflictSlot = self.teamAgent.slotList[upIdx]

						conflictSlot:ReplaceUpCard()
						self.clickSlot:ReplaceAddCard(self.infoRoleCard, RoleCardMgr:GetRole(self.infoRoleCard.id))
						self:OnBack()
					end
				end)
			else
				self.clickSlot:ReplaceAddCard(self.infoRoleCard, RoleCardMgr:GetRole(self.infoRoleCard.id))
				self:OnBack()
			end
		end

		if self.clickSlot.upInfoRoleCard then
			local cardId = self.clickSlot.upInfoRoleCard.id

			if TeamSystemAgent.SameRole(self.infoRoleCard.id, cardId) then
				UIMgr.ShowDialog(_("DlgCommon_SameRoleCantAdd"))
			else
				addFunc()
			end
		else
			addFunc()
		end
	end
end

function AddCard:OnClickedDownButton(data)
	self.clickSlot:ReplaceAddCard()
	self:OnBack()
end

function AddCard:OnPointerDown(data)
	if data.clickCount == 1 then
		-- block empty
	end
end
