-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/OtherRoleCard.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageTeam/DlgCardDetail")

OtherRoleCard = class("OtherRoleCard", MyRoleCard)

function OtherRoleCard:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.showRedPoint = false
	self.showPower = false
end

function OtherRoleCard:Create(vParam)
	OtherRoleCard.base.Create(self, vParam)
end

function OtherRoleCard:OnLocalText()
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

function OtherRoleCard:OnEnterEx()
	self.addInfoName = self:GetChildComponent("Panel/AddInfo/Name", "Text")
	self.addInfoLevel = self:GetChildComponent("Panel/AddInfo/Level", "Text")
	self.addInfoCoin = self:GetChildComponent("Panel/AddInfo/Coin", "Text")
end

function OtherRoleCard:UpdateData(teamSystemAgent, clickSlot, infoRoleCard, infoRole)
	self.infoRole = infoRole

	OtherRoleCard.base.UpdateData(self, teamSystemAgent, clickSlot, infoRoleCard)
end

function OtherRoleCard:UpdateDataEx()
	local path = "UIDyAtlas/RoleCardRank/BG_card_back_" .. self.infoRoleCard.rank .. "_9b"

	UIUtil.SetImageSprite(self.cardBg, path, self)

	self.addInfoName.text = self.infoRoleCard.pbPlayer.nickname
	self.addInfoLevel.text = _("Player_Level") .. LevelManager:GetPlayerLevel(self.infoRoleCard.pbPlayer.levelExp)

	local coins = GetConfigArgJson("FriendHelpCoinAdd")
	local coin = self.infoRoleCard.pbPlayer.isBuddy and coins[2] or coins[1]

	self.addInfoCoin.text = coin

	local infoRole = self.infoRole

	self.txtCost.text = math.ceil(RoleCardMgr:GetCardCost(self.infoRoleCard, infoRole, 1))
	self.txtPower = self:GetChildComponent("Panel/Power/TextPower", "Text")
	self.txtPower.text = math.ceil(RoleCardMgr:GetFightValue(infoRole, self.infoRoleCard))
end

function OtherRoleCard:OnClickedCell(data)
	CardRDL.NewRDL.SubNewCardPlayerPrefs(self.infoRoleCard)

	if self.GoNew then
		GOUtil.SetActive(self.GoNew, false)
	end

	if self.teamSystemAgent.isGvg then
		local val, ret = self.infoRoleCard:GvgHelpVaild()

		if val == false then
			if ret == 3 then
				UIMgr.ShowMsg(_("Msg_GvgHelpCardLevelLimit"))
			elseif ret == 2 then
				UIMgr.ShowMsg(_("Msg_GvgHelpCardTimesLimit"))
			elseif ret == 1 then
				UIMgr.ShowMsg(_("Msg_GvgHelpCardTimesLimit"))
			end

			return
		end
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
							local conflictSlot = self.teamAgent.slotList[cardIdx]

							conflictSlot:ReplaceUpCard()
							self.clickSlot:ReplaceUpCard(self.infoRoleCard, self.infoRole, true)
							self:OnBack()
						end
					end)
				end
			end)
		else
			local addCard = self.clickSlot.addInfoRoleCard
			local addCardId = addCard and addCard.id or 0
			local sameRole = TeamSystemAgent.SameRole(addCardId, self.infoRoleCard.id)
			local isAdd = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id) ~= -1

			if sameRole then
				UIMgr.ShowDialog(_("DlgCommon_SameRoleCardExists"), function(index)
					if index == 1 then
						self:OpenDetails(function(index)
							if index == 1 then
								self.clickSlot:ReplaceUpCard(self.infoRoleCard, self.infoRole, true)

								if isAdd then
									local idx = self.teamAgent:GetAddCardIdx(self.infoRoleCard.id)
									local slot = self.teamAgent.slotList[idx]

									slot:ReplaceAddCard()
								end

								self:OnBack()
							end
						end)
					end
				end)
			elseif isAdd then
				UIMgr.ShowDialog(_("DlgCommon_RoleCardExists"), function(index)
					if index == 1 then
						self:OpenDetails(function(index)
							if index == 1 then
								self.clickSlot:ReplaceUpCard(self.infoRoleCard, self.infoRole, true)

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
						self.clickSlot:ReplaceUpCard(self.infoRoleCard, self.infoRole, true)
						self:OnBack()
					end
				end)
			end
		end
	end
end

function OtherRoleCard:UpdateState()
	SetActiveFunc(self.curUpGo, false)
	SetActiveFunc(self.upingGo, false)
	SetActiveFunc(self.addingGo, false)

	local go1 = self:GetChildGameObject("Panel/State/LvLocking")

	SetActiveFunc(go1, false)

	local go2 = self:GetChildGameObject("Panel/State/TimesLocking")

	SetActiveFunc(go2, false)

	if self.teamSystemAgent.isGvg then
		local val, ret = self.infoRoleCard:GvgHelpVaild()

		if not val then
			if ret == 3 then
				local go1 = self:GetChildGameObject("Panel/State/LvLocking")

				SetActiveFunc(go1, true)
			else
				local go2 = self:GetChildGameObject("Panel/State/TimesLocking")

				SetActiveFunc(go2, true)
			end
		end
	end

	self.curIsUp = false

	for i, slot in ipairs(self.teamAgent.slotList) do
		if slot.isHelperCard and slot.upInfoRoleCard.pbPlayer.playerId == self.infoRoleCard.pbPlayer.playerId then
			SetActiveFunc(self.curUpGo, true)

			self.curUpPosTxt.text = self.teamAgent:GetUpCardIdx(self.infoRoleCard.id)
			self.curIsUp = true

			return
		end
	end
end

function OtherRoleCard:OpenDetails(call)
	if CardExtraMgr.detailsLookInfo then
		local param = {}

		param.call = call
		param.infoRoleCard = self.infoRoleCard

		UIMgr.AddPanel(DlgCardDetail(), param)
	else
		call(1)
	end
end
