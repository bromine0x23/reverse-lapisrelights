-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/TeamCardAdd.lua

require("UI/Item/UIItemBase")

local InfoTeam = require("Info.InfoTeam")
local lev = require("luaData/LevelConfig")

TeamCardAdd = class("TeamCardAdd", UIItemBase)

function TeamCardAdd:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function TeamCardAdd:Create(vParam)
	TeamCardAdd.base.Create(self, vParam)
end

function TeamCardAdd:OnEnter()
	local g = self.UIRootObject

	self:OnLocalText(g)

	self.DlgLongTip = ResourceMgr.LoadSync("UI/Common/DlgCommon/DlgLongTip")
	self.BtnAttr = GOUtil.FindChildGameObject(g, "Attr")
	self.BtnAddCard = GOUtil.FindChildGameObject(g, "AddCard")
	self.GoAttr = GOUtil.FindChildGameObject(g, "Attr/GoAttr")
	self.GoHide = GOUtil.FindChildGameObject(g, "Attr/GoHide")
	self.GoShow = GOUtil.FindChildGameObject(g, "Attr/GoShow")
	self.GoDance = GOUtil.FindChildGameObject(g, "Attr/GoDance")

	for i = 1, 4 do
		self["TxtType" .. i] = GOUtil.FindChildComponent(g, "Attr/GoAttr/Text" .. i, "Text")
		self["TxtTypeValue" .. i] = GOUtil.FindChildComponent(g, "Attr/GoAttr/Text" .. i .. "/TextValue", "Text")
	end

	self.TxtCost = GOUtil.FindChildComponent(g, "RoleAttr/Text1/Text", "Text")
	self.TxtCombatPower = GOUtil.FindChildComponent(g, "RoleAttr/Text2/Text", "Text")
	self.TxtCombatPower.fontSize = 18

	self:OnRegisterEvent()

	self.GoCardHp = GOUtil.FindChildGameObject(g, "Hp")
	self.ImgCardHpBar = GOUtil.FindChildComponent(g, "Hp/Bar", "Image")
	self.TexCardHpBar = self:GetChildComponent("Hp/Text", "Text")
	self.AnimatorHp = GOUtil.GetComponent(self.GoCardHp, "Animator")
end

function TeamCardAdd:OnLocalText(g)
	local TextAuto

	TextAuto = GOUtil.FindChildComponent(g, "RoleAttr/Text1", "Text")
	TextAuto.text = Lang(5000010)
	TextAuto = GOUtil.FindChildComponent(g, "RoleAttr/Text2", "Text")
	TextAuto.text = _("Desc_Combat_Power")
end

function TeamCardAdd:OnLeave()
	UnloadAllImageSprite(self)

	if self.DlgLongTip then
		ResourceMgr.Unload(self.DlgLongTip)

		self.DlgLongTip = nil
	end

	self:OnUnRegisterEvent()
end

function TeamCardAdd:UpdateData(teamSystemAgent, index)
	self.teamSystemAgent = teamSystemAgent
	self.teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	self.slotAgent = self.teamAgent.slotList[index]
	self.slotIdx = index

	if not self.teamSystemAgent.isPvp then
		local danceNum = InfoTeam:GetTimelineDataDanceNum()

		if danceNum then
			SetActiveFunc(self.GoDance, danceNum[index] == 1)
		end
	end

	local sumAttr, upAttr, addAttr = self.teamAgent.slotList[index]:GetSlotAttr()

	for n = 1, 4 do
		self["TxtType" .. n].text = _("eAttType_" .. n)
		self["TxtTypeValue" .. n].text = math.ceil(sumAttr[n]) .. " <color=red>(+" .. math.ceil(addAttr[n]) .. ")</color>"
	end

	local sumPower, addPower = self.teamAgent.slotList[index]:GetSlotCP()

	self.TxtCombatPower.text = math.ceil(sumPower) .. " <color=red>(+" .. math.ceil(addPower) .. ")</color>"

	local upCost = math.ceil(RoleCardMgr:GetCardCost(self.teamAgent.slotList[index].upInfoRoleCard, self.teamAgent.slotList[index].upInfoRole, 1))
	local addCost = math.ceil(RoleCardMgr:GetCardCost(self.teamAgent.slotList[index].addInfoRoleCard, self.teamAgent.slotList[index].addInfoRole, 2))

	self.TxtCost.text = upCost + addCost .. " <color=red>(+" .. addCost .. ")</color>"

	SetActiveFunc(self.GoCardHp, self.teamSystemAgent.isRaid and self.slotAgent.upInfoRoleCard ~= nil)
	self:UpdateCardHp()
	self:UpdateAddCard(index)
end

function TeamCardAdd:UpdateAddCard(i)
	local g = self.BtnAddCard
	local imgFist = GOUtil.FindChildComponent(g, "Card/Fist", "Image")

	SetActiveFunc(imgFist.gameObject, false)

	local goCard = GOUtil.FindChildGameObject(g, "Card")
	local goNotUseCard = GOUtil.FindChildGameObject(g, "NoCard")

	if self.teamSystemAgent.noSupCard == nil then
		self.teamSystemAgent.noSupCard = false
	end

	SetActiveFunc(goNotUseCard, self.teamSystemAgent.noSupCard)

	local goLock = GOUtil.FindChildGameObject(g, "Lock")
	local teampos = lev[PlayerInst:GetCurLv()].TeamPosition[1]
	local num = i + 5

	if teampos < num and not self.teamSystemAgent.noLevelUnlockSup and not self.teamSystemAgent.noSupCard then
		SetActiveFunc(goLock, true)
	else
		SetActiveFunc(goLock, false)
	end

	local addInfoRoleCard = self.teamAgent.slotList[i].addInfoRoleCard

	SetActiveFunc(goCard, addInfoRoleCard ~= nil)

	if addInfoRoleCard ~= nil then
		local imgIcon = GOUtil.FindChildComponent(g, "Card", "Image")
		local imgLevel = GOUtil.FindChildComponent(g, "Card/Level", "Image")
		local txtLevel = GOUtil.FindChildComponent(g, "Card/Level/TxtLevel", "Text")
		local imgRank1 = GOUtil.FindChildComponent(g, "Card/Rank", "Image")
		local imgRank2 = GOUtil.FindChildComponent(g, "Rank", "Image")

		UIUtil.SetImageSprite(imgIcon, addInfoRoleCard.data.SupportIcon, self)

		txtLevel.text = addInfoRoleCard.curLevel

		UIUtil.SetImageSprite(imgLevel, "UI/PanelBattleTeam/AtlasTeamCard/BG_card_back_" .. addInfoRoleCard.rank .. "_8s", self)
		UIUtil.SetImageSprite(imgRank1, "UI/PanelBattleTeam/AtlasTeamCard/BG_card_icon_" .. addInfoRoleCard.rank, self)
		UIUtil.SetImageSprite(imgRank2, "UI/PanelBattleTeam/AtlasTeamCard/BG_card_back_" .. addInfoRoleCard.rank .. "_8_line", self)

		txtLevel.fontSize = 18
	end
end

function TeamCardAdd:OnRegisterEvent()
	self:AddClick(self.BtnAttr, self.OnClickedAttr)
	self:AddClick(self.BtnAddCard, self.OnClickedAddCard)
	self:AddListener(self.BtnAddCard, self.OnPointerLongPressCard, EventTriggerType.PointerLongPress)
end

function TeamCardAdd:OnUnRegisterEvent()
	self:RemoveClick(self.BtnAttr, self.OnClickedBtnAttr)
	self:RemoveClick(self.BtnAddCard, self.OnClickedBtnAddCard)
	self:RemoveListener(self.BtnAddCard, self.OnPointerLongPressCard, EventTriggerType.PointerLongPress)
end

function TeamCardAdd:OnClickedAttr(data)
	local flag = not self.GoAttr.activeSelf

	SetActiveFunc(self.GoAttr, flag)
	SetActiveFunc(self.GoHide, flag)
	SetActiveFunc(self.GoShow, not flag)
end

function TeamCardAdd:OnPointerLongPressCard(data)
	if self.teamSystemAgent.noSupCard then
		UIMgr.ShowMsg(_("Msg_Support_Card_Use_Unable"))

		return
	end

	local teampos = lev[PlayerInst:GetCurLv()].TeamPosition[1]
	local lv = GetConfigArgJson("TeamPositionMessage")
	local index = 5
	local num = self.slotIdx + 5

	for i = 1, #lv do
		if num == lv[i][1] then
			index = lv[i][2]
		end
	end

	if teampos < num and not self.teamSystemAgent.noLevelUnlockSup then
		UIMgr.ShowMsg(string.format(Lang(12964), tostring(index)))

		return
	end

	if data.clickCount == 1 then
		local roleCard = self.teamAgent.slotList[self.slotIdx]

		if not roleCard.addInfoRoleCard then
			return
		end

		if not self.GoDlgLongTip then
			self.GoDlgLongTip = GOUtil.InstantiatePrefab(self.DlgLongTip, self.BtnAddCard)
		end

		self.breakLongState = false
		self.LongPressState = true
		GOUtil.FindChildComponent(self.GoDlgLongTip, "BG/Bar", "UIDlgLongTip").onEndTween = function()
			require("UI/Page/PageRoleCard/Page/PageRoleCard")

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

			local list = {}

			for _, v in ipairs(self.teamAgent.slotList) do
				if v.upInfoRoleCard then
					table.insert(list, v.addInfoRoleCard)
				end
			end

			CardSwitchMgr:ResetCardIdsByBattle(list)
			UIMgr.SwitchPanel(PageRoleCard, {
				cardId = roleCard.addInfoRoleCard.id,
				callback = func
			})
		end
	else
		self.breakLongState = true

		if self.LongPressState then
			self.LongPressState = false

			return
		elseif not IsNil(self.GoDlgLongTip) then
			return
		end

		local param = {}

		param.clickSlot = self.teamAgent.slotList[self.slotIdx]
		param.teamSystemAgent = self.teamSystemAgent

		require("UI/Page/PageTeam/PageChooseAddCard")
		UIMgr.SwitchPanel(PageChooseAddCard, param)
	end
end

function TeamCardAdd:UpdateCardHp()
	if self.teamSystemAgent.isRaid and self.slotAgent.upInfoRoleCard ~= nil then
		local infoCard = self.slotAgent.upInfoRoleCard
		local maxHpPer = infoCard.maxRaidHpPer
		local curHpPer = infoCard.curCommRaidHpPer
		local attrType1 = RoleMgr:IndexToAttrType(1)
		local roleAttr = RoleCardMgr:GetRole(infoCard.id):GetAttWithCard(attrType1, infoCard)

		self.ImgCardHpBar.fillAmount = curHpPer / maxHpPer
		self.TexCardHpBar.text = math.ceil(curHpPer * roleAttr) .. "/" .. math.ceil(maxHpPer * roleAttr)
	end
end

function TeamCardAdd:OnClickedAddCard(data)
	return
end

function TeamCardAdd:PlayEmptyHpAnim()
	self.AnimatorHp:Play("Team_CardAdd_Hp_Shake")
end
