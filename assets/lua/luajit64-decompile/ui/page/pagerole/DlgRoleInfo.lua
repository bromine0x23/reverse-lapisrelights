-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/DlgRoleInfo.lua

require("UI/Page/PageRoleCard/Cell/CellCardSkill")
require("UI/Page/PageRole/DlgChooseCard")
require("UI/Page/PageRole/DlgAttrDetail")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

DlgRoleInfo = class("DlgRoleInfo", UIPanel)

local enumType = {
	[1] = "Role",
	[2] = "Equip"
}

function DlgRoleInfo:ctor(typeNum)
	self.UIPrefabPath = "UI/PanelRole/DlgRoleInfo"
end

function DlgRoleInfo:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellCardSkill", "PrefabCellCardSkill", GameObject)
	self:LoadResAsync("UI/Common/DlgCommon/DlgLongTip", "DlgLongTip", GameObject)
end

function DlgRoleInfo:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellCardSkill)

	if self.DlgLongTip then
		ResourceMgr.Unload(self.DlgLongTip)

		self.DlgLongTip = nil
	end

	if self.DlgChooseCard and not self.DlgChooseCard.closed then
		self.DlgChooseCard:Close()

		self.DlgChooseCard = nil
	end

	UnloadAllImageSprite(self)
	self:OnLeave()
end

function DlgRoleInfo:OnLeave()
	if self.listCellSkill then
		for _, cell in ipairs(self.listCellSkill) do
			if cell.OnLeave ~= nil then
				cell:OnLeave()
			end
		end

		self.listCellSkill = nil
	end

	if self.listCellAbility then
		for _, cell in ipairs(self.listCellAbility) do
			if cell.OnLeave ~= nil then
				cell:OnLeave()
			end
		end

		self.listCellAbility = nil
	end

	if self.spineHandle then
		ResourceMgr.Cancel(self.spineHandle)

		self.spineHandle = nil
	end

	self.listSpineRef = nil
end

function DlgRoleInfo:OnRegisterEvent()
	self:AddClick(self.BtnAttDetail, self.OnClickBtnAttDetail)
	Event.Instance:Add("UpdateRoleEquipedCard", self.UpdateEquipedCard, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
end

function DlgRoleInfo:OnUnRegisterEvent()
	self:RemoveClick(self.BtnAttDetail, self.OnClickBtnAttDetail)

	if self.initedPageRole then
		self:RemoveClick(self.BtnInteract, self.OnClickBtnInteract)
		self:RemoveListener(self.GoCard, self.OnPointDownCard, EventTriggerType.PointerDown)
		self:RemoveListener(self.GoCard, self.OnPointUpCard, EventTriggerType.PointerUp)
		self:RemoveListener(self.GoCard, self.OnPointerLongPressCard, EventTriggerType.PointerLongPress)
		self:RemoveListener(self.GoCard, self.OnBeginDragCard, EventTriggerType.BeginDrag)
		self:RemoveListener(self.GoCard, self.OnDragCard, EventTriggerType.Drag)
		self:RemoveListener(self.GoCard, self.OnEndDragCard, EventTriggerType.EndDrag)
	end

	if self.initedPageEquip then
		self:RemoveClick(self.BtnEnchantDetail, self.OnClickedBtnEnchantDetail)
		self:RemoveClick(self.BtnGotoEnchant, self.OnClickedBtnGotoEnchant)
	end

	Event.Instance:Remove("UpdateRoleEquipedCard", self.UpdateEquipedCard, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
end

function DlgRoleInfo:OnEnter(vParam)
	self:DealWithLocalization()

	self.TxtName = self:GetChildComponent("Panel/Info/Role/Info/TxtName", "Text")
	self.TxtCVName = self:GetChildComponent("Panel/Info/Role/TxtCVName", "Text")
	self.TxtCombat = self:GetChildComponent("Panel/Info/Role/Score/TxtScore", "Text")
	self.img_job = self:GetChildComponent("Panel/Info/Role/Info/img_job", "Image")

	for i = 1, ATTRIBUTE_USE_CNT do
		self["TxtAttValue" .. i] = self:GetChildComponent("Panel/Info/Attr/" .. i .. "/TxtValue", "Text")
	end

	self.BtnAttDetail = self:GetChildGameObject("Panel/Info/Attr/BtnAttr")
	self.AnimBtnAttr = GOUtil.GetComponent(self.BtnAttDetail, "Animator")
	self.GoBg1 = self:GetChildGameObject("Panel/Bg/Bg1")
	self.GoBg2 = self:GetChildGameObject("Panel/Bg/Bg2")
	self.GoCardModule = self:GetChildGameObject("Panel/Info/Card")
	self.GoFavorModule = self:GetChildGameObject("Panel/Info/Favor")
	self.GoEnchantModule = self:GetChildGameObject("Panel/Info/Enchant")

	self:UpdateShowModule()

	self.listSpineRef = {}
	self.listCellAbility = {}
	self.listCellSkill = {}
end

function DlgRoleInfo:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/Info/Role/Score/Text", "Text")

	txt.text = _("Desc_Score_Total")

	for i = 1, ATTRIBUTE_USE_CNT do
		txt = self:GetChildComponent("Panel/Info/Attr/" .. i .. "/Text", "Text")
		txt.text = _("eAttType_" .. i)
	end
end

function DlgRoleInfo:Show()
	xpcall(function()
		GOUtil.SetActive(self.UIRootObject, 1)
	end, function(err)
		print(err)
	end)
end

function DlgRoleInfo:Hide()
	xpcall(function()
		GOUtil.SetActive(self.UIRootObject, 0)
	end, function(err)
		print(err)
	end)
end

function DlgRoleInfo:UpdateRole(role)
	if not role or not role.hold then
		return
	end

	if self.infoRole and self.infoRole.id == role.id then
		-- block empty
	else
		self.IsChangeRole = false

		if self.infoRole then
			self.IsChangeRole = true

			UnloadAllImageSprite(self)
		end

		self.infoRole = role
		self.infoRoleCard = RoleCardMgr:GetRoleCard(self.infoRole.pb.roleCardId)
		self.TxtName.text = self.infoRole:GetName()
		self.TxtCVName.text = "CV." .. self.infoRole:GetCVName()

		SetImageSprite(self.img_job, "UIDyAtlas/RoleJob/ICO_" .. self.infoRole.data.Job .. "_01_S", self)

		self.updatedRoleData = false
		self.updatedEquipData = false

		RoleRDL.NewRDL.SubNewRolePlayerPrefs(role)
		RoleRDL.AddViewed(role.id)
	end

	if UIMgr.PreviewActor.systemType == eActorSystemType.ROLE then
		self:InitByPageRole()
	elseif UIMgr.PreviewActor.systemType == eActorSystemType.EQUIP then
		self:InitByPageEquip()
	end
end

function DlgRoleInfo:UpdateShowModule()
	if UIMgr.PreviewActor.systemType ~= eActorSystemType.AVATAR then
		self:Show()
	else
		self:Hide()

		return
	end

	local roleV = TenaryOp(UIMgr.PreviewActor.systemType == eActorSystemType.ROLE, 1, 0)
	local equipV = TenaryOp(UIMgr.PreviewActor.systemType == eActorSystemType.EQUIP, 1, 0)

	GOUtil.SetActive(self.GoCardModule, roleV)
	GOUtil.SetActive(self.GoFavorModule, roleV)
	GOUtil.SetActive(self.GoEnchantModule, equipV)
	GOUtil.SetActive(self.GoBg1, roleV)
	GOUtil.SetActive(self.GoBg2, equipV)
end

function DlgRoleInfo:InitByPageEquip()
	local result = TutorialMgr:IsOpen(TutorialFunctionType.Equipment)

	if not self.initedPageEquip then
		self.initedPageEquip = true
		self.GoEnchantLock = GOUtil.FindChildGameObject(self.GoEnchantModule, "Lock")
		self.GoEnchantSlot = GOUtil.FindChildGameObject(self.GoEnchantModule, "Slot")
		self.GoEnchantSuit = GOUtil.FindChildGameObject(self.GoEnchantModule, "Suit")

		GOUtil.SetActive(self.GoEnchantLock, TenaryOp(result.open, 0, 1))

		local vBool = TenaryOp(result.open, 1, 0)

		GOUtil.SetActive(self.GoEnchantSlot, vBool)
		GOUtil.SetActive(self.GoEnchantSuit, vBool)

		local txt = GOUtil.FindChildComponent(self.GoEnchantModule, "Title/Text", "Text")

		if result.open then
			txt.text = _("Desc_Equip_Enchant_View")
			txt = GOUtil.FindChildComponent(self.GoEnchantSuit, "Title/Text", "Text")
			txt.text = _("Desc_Equip_Enchant_Suit")
			txt = GOUtil.FindChildComponent(self.GoEnchantSuit, "GoNone/Text", "Text")
			txt.text = _("Desc_Equip_Enchant_Suit_None")
			txt = GOUtil.FindChildComponent(self.GoEnchantSuit, "BtnGotoEnchant/Text", "Text")
			txt.text = _("UI_Goto_Equip_Enchant")

			for i = 1, EquipmentManager.EquipSlotCnt do
				self["SlotIcon" .. i] = GOUtil.FindChildComponent(self.GoEnchantSlot, i .. "/Icon", "Image")
				self["GoSlotLock" .. i] = GOUtil.FindChildGameObject(self.GoEnchantSlot, i .. "/Lock")

				for j = 1, EquipmentManager.EquipEnchantCnt do
					self["SlotEnchantRank" .. i .. j] = GOUtil.FindChildComponent(self.GoEnchantSlot, i .. "/" .. j, "Image")
				end
			end

			self.GoNone = GOUtil.FindChildGameObject(self.GoEnchantSuit, "GoNone")
			self.GoSuit = GOUtil.FindChildGameObject(self.GoEnchantSuit, "GoSuit")

			for i = 1, EquipmentManager.EquipEnchantSuitCnt do
				self["GoSuit" .. i] = GOUtil.FindChildGameObject(self.GoSuit, "" .. i)
				self["SuitValue" .. i] = GOUtil.FindChildComponent(self.GoSuit, i .. "/TextValue", "Text")
				self["SuitIcon" .. i] = GOUtil.FindChildComponent(self.GoSuit, i .. "/Icon", "Image")
				self["SuitDesc" .. i] = GOUtil.FindChildComponent(self.GoSuit, i .. "/TextDesc", "Text")
			end

			self.BtnEnchantDetail = GOUtil.FindChildGameObject(self.GoEnchantSlot, "BtnEnchantDetail")
			self.BtnGotoEnchant = GOUtil.FindChildGameObject(self.GoEnchantSuit, "BtnGotoEnchant")

			self:AddClick(self.BtnEnchantDetail, self.OnClickedBtnEnchantDetail)
			self:AddClick(self.BtnGotoEnchant, self.OnClickedBtnGotoEnchant)
		else
			txt.text = _("Desc_Equip_Enchant")
			txt = GOUtil.FindChildComponent(self.GoEnchantLock, "Text", "Text")

			local infoTutorial = TutorialMgr:Get(TutorialFunctionType.Enchant)

			if result.plevel then
				txt.text = string.format(_("Desc_Sytem_Open_Player_Level_Limit"), result.plevel, infoTutorial:GetName())
			elseif result.chapterIdx and result.stageIdx then
				txt.text = string.format(_("Desc_System_Open_Stage_Limit"), "<color=#E22929>" .. result.chapterIdx .. "-" .. result.stageIdx .. "</color>", infoTutorial:GetName())
			end
		end
	end

	if result.open and not self.updatedEquipData then
		self.updatedEquipData = true

		self:UpdateEquipEnchant()
		self:UpdateCombatPowerAndAtt()
		RedDotSystemMgr.SetUIRedDot(self.BtnGotoEnchant, "Equip/Enchant/" .. self.infoRole.id)
	end
end

function DlgRoleInfo:UpdateEquipWeaponIcon()
	if not self.initedPageEquip then
		return
	end

	local slot = self.infoRole:GetEquipSlot(1)
	local equip = EquipmentManager:GetEquip(self.infoRole:GetEquipId(1))
	local icon = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, equip, slot.quality, slot.grade)

	SetImageSprite(self.SlotIcon1, icon, self)
end

function DlgRoleInfo:UpdateEquipEnchant()
	for i = 1, EquipmentManager.EquipSlotCnt do
		local slot = self.infoRole:GetEquipSlot(i)
		local equip = EquipmentManager:GetEquip(self.infoRole:GetEquipId(i))
		local isLock = not self.infoRole:IsEquipSlotUnlocked(i)

		DealWithListRef(self, UIUtil.SetImageGray(self["SlotIcon" .. i], isLock and 1 or 0))

		local icon = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, equip, slot.quality, slot.grade)

		SetImageSprite(self["SlotIcon" .. i], icon, self)
		GOUtil.SetActive(self["GoSlotLock" .. i], TenaryOp(isLock, 1, 0))

		for j = 1, EquipmentManager.EquipEnchantCnt do
			if isLock or slot.attributes[j] == nil then
				SetImageSprite(self["SlotEnchantRank" .. i .. j], "UI/PanelRole/AtlasPanelRole/bg_itemup_frame_203b", self)
			else
				local _, rank = EquipmentManager.GetEnchantRank(i, slot.scroll, slot.attributes[j])

				SetImageSprite(self["SlotEnchantRank" .. i .. j], "UI/PanelRole/AtlasPanelRole/ic_itemup_word_0" .. rank, self)
			end
		end
	end

	local listResonance = EquipmentManager.GetEquipResonanceByRole(self.infoRole)

	GOUtil.SetActive(self.GoNone, #listResonance == 0)
	GOUtil.SetActive(self.GoSuit, #listResonance ~= 0)

	for i = 1, EquipmentManager.EquipEnchantSuitCnt do
		GOUtil.SetActive(self["GoSuit" .. i], TenaryOp(i <= #listResonance, 1, 0))

		if i <= #listResonance then
			local scrollSetData = listResonance[i]

			self["SuitValue" .. i].text = scrollSetData.Number .. "組"
			self["SuitDesc" .. i].text = Lang(scrollSetData.Info)

			SetImageSprite(self["SuitIcon" .. i], scrollSetData.Img, self)
		end
	end
end

function DlgRoleInfo:OnClickedBtnEnchantDetail()
	require("UI/Page/PageRole/DlgRoleEnchantDetail")
	UIMgr.AddPanel(DlgRoleEnchantDetail(), self.infoRole)
end

function DlgRoleInfo:OnClickedBtnGotoEnchant()
	EquipmentManager.LastDevelopTab = 2

	require("UI/Page/PageEquipment/PageEquipDevelop")
	UIMgr.SwitchPanel(PageEquipDevelop, {
		roleId = self.infoRole.id
	})
end

function DlgRoleInfo:InitByPageRole()
	if not self.initedPageRole then
		self.initedPageRole = true

		local txt = GOUtil.FindChildComponent(self.GoCardModule, "Title/Text", "Text")

		txt.text = Lang(5000016)
		txt = GOUtil.FindChildComponent(self.GoCardModule, "Skill/Title/Text", "Text")
		txt.text = Lang(2011)
		txt = GOUtil.FindChildComponent(self.GoCardModule, "Ability/Title/Text", "Text")
		txt.text = Lang(7001030)
		txt = GOUtil.FindChildComponent(self.GoFavorModule, "BtnInteract/Text", "Text")
		txt.text = Lang(7001033)
		self.GoCard = GOUtil.FindChildGameObject(self.GoCardModule, "Card")
		self.AnimCard = GOUtil.GetComponent(self.GoCard, "Animator")
		self.CardRIBg = GOUtil.FindChildComponent(self.GoCard, "Icon/Bg", "RawImage")
		self.CardRIIcon = GOUtil.FindChildComponent(self.GoCard, "Icon/Icon", "RawImage")
		self.TxtCardName = GOUtil.FindChildComponent(self.GoCard, "TxtName", "Text")
		self.TxtCardLv = GOUtil.FindChildComponent(self.GoCard, "Info/TxtLv", "Text")
		self.TxtCardLv.fontSize = 24
		self.ImgCardRank = GOUtil.FindChildComponent(self.GoCard, "Rank", "Image")
		self.GoFrame = GOUtil.FindChildGameObject(self.GoCard, "Info/Star/Frame")
		self.GoStar1 = GOUtil.FindChildGameObject(self.GoCard, "Info/Star/Star1")
		self.GoStar2 = GOUtil.FindChildGameObject(self.GoCard, "Info/Star/Star2")

		for i = 1, table.getCount(eRankType) do
			self["GoPetal" .. i] = GOUtil.FindChildGameObject(self.GoCard, "Petal/State" .. i)
		end

		self.GoSkillGroup = GOUtil.FindChildGameObject(self.GoCardModule, "Skill/Group")
		self.GoAbilityGroup = GOUtil.FindChildGameObject(self.GoCardModule, "Ability/Group")
		self.GoIdx = GOUtil.FindChildGameObject(self.GoCardModule, "IdxGroup/Idx")
		self.GoIdxGroup = GOUtil.FindChildGameObject(self.GoCardModule, "IdxGroup/Group")
		self.TxtFavorLevel = GOUtil.FindChildComponent(self.GoFavorModule, "TxtFavor", "Text")
		self.TxtFavorExp = GOUtil.FindChildComponent(self.GoFavorModule, "Exp/Text", "Text")
		self.ImgFavorExpBar = GOUtil.FindChildComponent(self.GoFavorModule, "Exp/Bar", "Image")
		self.BtnInteract = GOUtil.FindChildGameObject(self.GoFavorModule, "BtnInteract")
		self.TxtFavorExp.fontSize = 21

		GOUtil.SetRectTransformAnchoredPosition(self.TxtFavorExp.gameObject, 104, 0)

		self.GoRayCardEffect = self:GetChildGameObject("Panel/Info/Card/Card/Rank/Ray_Effect")

		self:AddClick(self.BtnInteract, self.OnClickBtnInteract)
		self:AddListener(self.GoCard, self.OnPointerLongPressCard, EventTriggerType.PointerLongPress)
		self:AddListener(self.GoCard, self.OnPointDownCard, EventTriggerType.PointerDown)
		self:AddListener(self.GoCard, self.OnPointUpCard, EventTriggerType.PointerUp)
		self:AddListener(self.GoCard, self.OnBeginDragCard, EventTriggerType.BeginDrag)
		self:AddListener(self.GoCard, self.OnDragCard, EventTriggerType.Drag)
		self:AddListener(self.GoCard, self.OnEndDragCard, EventTriggerType.EndDrag)
	end

	if not self.updatedRoleData then
		self.updatedRoleData = true
		self.listRoleCard = RoleCardMgr:GetRoleHoldCard(self.infoRole.id)

		CardSortMgr.CardOtherSort(CardSortMgr.SORT_TYPES.LEVEL, CardSortMgr.SORT_TYPES.RANK, self.listRoleCard)
		self:UpdateCardGroupIdxs()
		self:UpdateEquipedCard()
		self:UpdateRoleFavor()
		RedDotSystemMgr.SetUIRedDot(self.BtnInteract, "Role/" .. self.infoRole.id .. "/Interact")
	end
end

function DlgRoleInfo:UpdateRoleFavor()
	local config = GetConfigArgJson("FavorSection")
	local lv = self.infoRole.curFavorLevel
	local maxLv = config[#config]
	local curExp = self.infoRole.curFavorExp
	local nextExp = self.infoRole.curFavorNextExp
	local index = 1

	for k, v in ipairs(config) do
		if lv <= v then
			index = k

			break
		end
	end

	self.TxtFavorLevel.text = Lang(GetConfigArgJson("FavorRankName")[index]) .. "：" .. Lang(12004) .. lv

	local rate = 0

	if lv ~= maxLv then
		rate = curExp / nextExp > 1 and 1 or curExp / nextExp
		self.TxtFavorExp.text = "<color=#118094>" .. curExp .. "</color>/" .. nextExp
	else
		rate = 1
		self.TxtFavorExp.text = "MAX"
	end

	self.ImgFavorExpBar.gameObject.transform.localScale = Vector3(rate, 1, 1)
end

function DlgRoleInfo:UpdateCardGroupIdxs()
	self.listGoIdx = self.listGoIdx or {}

	local function CreateGoIdx(num)
		GOUtil.SetActive(self.GoIdx, 1)

		for i = 1, num do
			local go = GOUtil.Instantiate(self.GoIdx, self.GoIdxGroup)

			go.name = #self.listGoIdx + 1

			table.insert(self.listGoIdx, go)
		end

		GOUtil.SetActive(self.GoIdx, 0)
	end

	for _, v in ipairs(self.listGoIdx) do
		GOUtil.SetActive(v, 1)
	end

	if #self.listRoleCard > #self.listGoIdx then
		CreateGoIdx(#self.listRoleCard - #self.listGoIdx)
	else
		for k, v in ipairs(self.listGoIdx) do
			if k > #self.listRoleCard then
				GOUtil.SetActive(v, 0)
			end
		end
	end
end

function DlgRoleInfo:UpdateEquipedCard()
	if not self.infoRole.pb.roleCardId or self.infoRole.pb.roleCardId == 0 then
		return
	end

	self.cardIdx = 1

	for k, card in ipairs(self.listRoleCard) do
		if card.id == self.infoRole.pb.roleCardId then
			self.cardIdx = k

			break
		end
	end

	self:UpdateCard()
end

function DlgRoleInfo:UpdateCard()
	self.infoRoleCard = self.listRoleCard[self.cardIdx]

	if not self.infoRoleCard then
		return
	end

	self:UpdateCardInfo()
	self:UpdateSkillAndAbility()
	self:UpdateCombatPowerAndAtt()

	for k, v in ipairs(self.listGoIdx) do
		local sel = GOUtil.FindChildGameObject(v, "Image")

		if k == self.cardIdx then
			GOUtil.SetActive(sel, 1)
		else
			GOUtil.SetActive(sel, 0)
		end
	end
end

local function DealWithSpineRef(self)
	if not self.spineRef then
		return
	end

	self.listSpineRef = self.listSpineRef or {}

	if table.getn(self.listSpineRef) + 1 > 10 then
		ResourceMgr.Unload(self.listSpineRef[1])
		table.remove(self.listSpineRef, 1)
	end

	table.insert(self.listSpineRef, self.spineRef)
end

function DlgRoleInfo:UpdateCardInfo()
	self.AnimCard:Play("Anim_DlgRoleInfo_Card_Hide", 0, 0)

	local bool = string.isNullOrEmpty(self.infoRoleCard.data.SpineData)

	self.CardRIIcon.enabled = bool

	GOUtil.SetActive(self.CardRIBg, TenaryOp(bool, 1, 0))

	if self.spineHandle then
		ResourceMgr.Cancel(self.spineHandle)

		self.spineHandle = nil
	end

	if not IsNil(self.GoSpine) then
		Object.Destroy(self.GoSpine)
	end

	local function cb()
		RoleCardMgr:SetCardLocation(self.infoRoleCard, self.CardRIIcon.gameObject, 3)
		SetImageSprite(self.ImgCardRank, "UIDyAtlas/RoleCardRank/ui_hd_card_back_" .. self.infoRoleCard.rank .. "_7", self)

		self.TxtCardName.text = self.infoRoleCard:GetName()
		self.TxtCardLv.text = self.infoRoleCard.curLevel

		RoleCardMgr:SetStar(self.infoRoleCard, self)
		RoleCardMgr:SetPetal(self.infoRoleCard, self)
	end

	cb()

	if self.infoRoleCard.data.SpineData ~= "" then
		local function wrap_cb(value)
			if self.spineRef then
				self.GoSpine = GOUtil.InstantiateUIPrefab(self.spineRef, self.CardRIIcon.gameObject)

				GOUtil.UpdateSpineSkeleton(self.CardRIIcon.gameObject)

				if GOUtil.GetComponent(self.GoSpine, "SpineAspectRatioFitter") then
					GOUtil.GetComponent(self.GoSpine, "SpineAspectRatioFitter").enabled = false
				end

				DealWithSpineRef(self)

				self.spineRef = nil
				self.spineHandle = nil
			end

			LoadingMgr.Hide(eLoadingType.Repeat)
			self.AnimCard:Play("Anim_DlgRoleInfo_Card_Show", 0, 0)
		end

		LoadingMgr.Show(eLoadingType.Repeat)

		self.spineHandle = ResourceMgr.BeginSubmit(wrap_cb, self.infoRoleCard.id)

		ResourceMgr.SubmitCache(self.infoRoleCard.data.SpineData .. "_Anim", self, "spineRef", GameObject)
		ResourceMgr.EndSubmit()
	else
		RoleCardMgr:SetInfoPanel(self.infoRoleCard, self.CardRIIcon, self.CardRIBg, self)
		self.AnimCard:Play("Anim_DlgRoleInfo_Card_Show", 0, 0)
	end

	GOUtil.SetActive(self.GoRayCardEffect, RoleCardMgr.ShowCardEffect(self.infoRoleCard))
end

function DlgRoleInfo:UpdateCombatPowerAndAtt()
	if not self.infoRole then
		return
	end

	local att = self.infoRole:UpdateAttWithCard(self.infoRoleCard)

	for i = 1, ATTRIBUTE_USE_CNT do
		self["TxtAttValue" .. i].text = math.floor(att:Get(i) + 0.5)
	end

	self.TxtCombat.text = RoleCardMgr:GetFightValue(self.infoRole, self.infoRoleCard)
end

local function DealNewCell(listCell, listInfo, funBuild, funUpdate)
	local oldCnt = table.getn(listCell)
	local newCnt = table.getn(listInfo)

	if oldCnt ~= 0 then
		if oldCnt < newCnt then
			for k, v in ipairs(listInfo) do
				if oldCnt < k then
					funBuild(k, v)
				else
					local go = type(listCell[k]) == "table" and listCell[k].UIRootObject or listCell[k]

					GOUtil.SetActive(go, 1)
					funUpdate(k, v)
				end
			end
		else
			for k, v in ipairs(listCell) do
				local go = type(v) == "table" and v.UIRootObject or v

				GOUtil.SetActive(go, TenaryOp(k <= newCnt, 1, 0))

				if k <= newCnt then
					funUpdate(k, listInfo[k])
				end
			end
		end
	else
		for k, v in ipairs(listInfo) do
			funBuild(k, v)
		end
	end
end

function DlgRoleInfo:UpdateSkillAndAbility()
	local listSkill = self.infoRoleCard.listSkill

	local function CreateCell(index, infoSkill)
		local cell = CellCardSkill(self.PrefabCellCardSkill, self.GoSkillGroup, self)

		cell:Create()
		cell:UpdateData({
			info = infoSkill,
			infoRoleCard = self.infoRoleCard
		})
		table.insert(self.listCellSkill, cell)
	end

	local function UpdateCell(index, infoSkill)
		self.listCellSkill[index]:UpdateData({
			info = infoSkill,
			infoRoleCard = self.infoRoleCard
		})
	end

	DealNewCell(self.listCellSkill, listSkill, CreateCell, UpdateCell)

	self.listAbility = self.infoRoleCard.listAbility or {}

	function CreateCell(index, info)
		local cell = CellCardSkill(self.PrefabCellCardSkill, self.GoAbilityGroup, self)

		cell:Create()
		cell:UpdateData({
			infoType = 3,
			info = info
		})
		table.insert(self.listCellAbility, cell)
	end

	function UpdateCell(index, info)
		self.listCellAbility[index]:UpdateData({
			infoType = 3,
			info = info
		})
	end

	DealNewCell(self.listCellAbility, self.listAbility, CreateCell, UpdateCell)
end

function DlgRoleInfo:OnPointDownCard()
	self.IsDragging = false
	self.IsLongPress = false
end

function DlgRoleInfo:OnPointUpCard()
	if self.IsDragging or self.IsLongPress then
		return
	end

	local function wrap_cb()
		if UIMgr.PreviewActor.systemType == eActorSystemType.ROLE then
			GOUtil.SetActive(self.GoCard, 1)
		end
	end

	local function panel_cb()
		if UIMgr.PreviewActor.systemType == eActorSystemType.ROLE then
			GOUtil.SetActive(self.GoCard, 0)
		end
	end

	self.DlgChooseCard = DlgChooseCard()

	UIMgr.AddPanel(self.DlgChooseCard, {
		infoRole = self.infoRole,
		callback = wrap_cb,
		panelCb = panel_cb
	}, self.UIRootObject)

	self.DlgChooseCard.parentPanel = self
end

function DlgRoleInfo:OnPointerLongPressCard(data)
	if not self.IsDragging and data.clickCount == 1 then
		self.IsLongPress = true

		if not self.GoDlgLongTip then
			self.GoDlgLongTip = GOUtil.InstantiatePrefab(self.DlgLongTip, UIMgr.UIPopupObject)
			self.GoBar = GOUtil.FindChildGameObject(self.GoDlgLongTip, "BG")

			local pos = UIUtil.ScreenPointToLocalPoint(self.GoDlgLongTip, data.position)

			GOUtil.SetTransformLocalPosition(self.GoBar, pos.x, pos.y, 0)
		end

		GOUtil.FindChildComponent(self.GoDlgLongTip, "BG/Bar", "UIDlgLongTip").onEndTween = function()
			local panel = UIMgr.GetPrePanel()

			if panel.className == "PageRoleCard" then
				if self.IsChangeRole then
					CardSwitchMgr:ResetCardIdsByRole(self.infoRole.id)

					self.IsChangeRole = false
				end

				UIMgr.PreviewActor.parentPanel:OnBack({
					cardId = self.infoRoleCard.id
				})
			else
				require("UI/Page/PageRoleCard/Page/PageRoleCard")
				CardSwitchMgr:ResetCardIdsByRole(self.infoRole.id)
				UIMgr.SwitchPanel(PageRoleCard, {
					cardId = self.infoRoleCard.id
				})
			end

			Object.Destroy(self.GoDlgLongTip)
		end
	end
end

function DlgRoleInfo:OnBeginDragCard(data)
	self.beginPos = data.position
end

function DlgRoleInfo:OnDragCard(data)
	if not self.IsDragging and not self.IsLongPress then
		local disX = data.position.x - self.beginPos.x

		if Mathf.Abs(disX) > 0 then
			self.IsDragging = true
		end
	end
end

function DlgRoleInfo:OnEndDragCard(data)
	if not self.IsLongPress then
		local disX = data.position.x - self.beginPos.x

		if Mathf.Abs(disX) > 10 then
			if disX > 0 then
				self:OnNext(false)
			else
				self:OnNext(true)
			end
		end
	end
end

function DlgRoleInfo:OnNext(isR)
	local preCardIdx = self.cardIdx

	if isR then
		self.cardIdx = self.cardIdx + 1 > #self.listRoleCard and 1 or self.cardIdx + 1
	else
		self.cardIdx = self.cardIdx - 1 < 1 and #self.listRoleCard or self.cardIdx - 1
	end

	if preCardIdx == self.cardIdx then
		return
	end

	self:UpdateCard()
end

function DlgRoleInfo:OnClickBtnAttDetail()
	local data = {
		infoRole = self.infoRole,
		infoRoleCard = self.infoRoleCard
	}

	function data.cb()
		if UIMgr.PreviewActor.systemType == eActorSystemType.ROLE then
			GOUtil.SetActive(self.GoCard, 1)
		end
	end

	function data.panelCb()
		if UIMgr.PreviewActor.systemType == eActorSystemType.ROLE then
			GOUtil.SetActive(self.GoCard, 0)
		end
	end

	UIMgr.AddPanel(DlgAttrDetail(), data)
end

function DlgRoleInfo:OnClickBtnInteract()
	local panel = UIMgr.GetPrePanel()

	if panel.className == "PageInteraction" then
		UIMgr.PopPanel()
	else
		SceneMainStage.Instance:OnEnterInteractionByRoleId(self.infoRole.id)
	end
end

function DlgRoleInfo:ShowOpenAni()
	return
end

function DlgRoleInfo:UpdateNetData()
	self:UpdateCombatPowerAndAtt()
end
