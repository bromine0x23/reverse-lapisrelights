-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/PageEquipDevelop.lua

require("UI/Page/PageEquipment/DlgEquipDevelopIntense")
require("UI/Page/PageEquipment/DlgEquipDevelopEnchant")
require("UI/Page/PageEquipment/DlgEquipDevelopSynthetize")

PageEquipDevelop = class("PageEquipDevelop", UIPanel)

local eTagType = {
	Enchant = 2,
	Intense = 1,
	Synthetize = 3
}

eDevelopType = {
	Enchant = 3,
	Level = 1,
	Quality = 2,
	Synthetize = 4
}

function PageEquipDevelop:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/PanelEquipDevelop"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleEquip"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})

	self.DlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.DlgAssetsInfo)
end

function PageEquipDevelop:PreLoad()
	return
end

function PageEquipDevelop:Purge()
	self.base.Purge(self)
	UITweenUtil.RemoveTween(self.Tag)
	UnloadAllImageSprite(self)

	if self.PageItemSyn ~= nil then
		self.PageItemSyn:Close()
	end

	InfoSoundEventMgr:OnBack()
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_PanelEquipEnchant/FX_EquipUpgrade")
end

function PageEquipDevelop:OnBack()
	EquipmentManager.LastDevelopTab = 0

	if UIMgr.GetPrePanel().className == "PageEquip" or UIMgr.GetPrePanel().className == "PagePictureTask" then
		UIMgr.PopPanel()
	else
		UIMgr.PopPanel(self.popData)
	end
end

function PageEquipDevelop:OnRegisterEvent()
	self:AddClick(self.TagIntense, self.OnClickTagIntense)
	self:AddClick(self.TagEnchant, self.OnClickTagEnchant)
	self:AddClick(self.TagSynthetize, self.OnClickTagSynthetize)

	for i = 1, self.slotCnt do
		self:AddClick(self["GoSlot" .. i], self.OnClickGoSlot)
	end

	Event.Instance:Add("UpdateEquipAfterDevelop", self.UpdateEquipAfterDevelop, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Add("OpenPageItemSyn", self.OpenPageItemSyn, self)
end

function PageEquipDevelop:OnUnRegisterEvent()
	self:RemoveClick(self.TagIntense, self.OnClickTagIntense)
	self:RemoveClick(self.TagEnchant, self.OnClickTagEnchant)
	self:RemoveClick(self.TagSynthetize, self.OnClickTagSynthetize)

	for i = 1, self.slotCnt do
		self:RemoveClick(self["GoSlot" .. i], self.OnClickGoSlot)
	end

	Event.Instance:Remove("UpdateEquipAfterDevelop", self.UpdateEquipAfterDevelop, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Remove("OpenPageItemSyn", self.OpenPageItemSyn, self)
end

function PageEquipDevelop:OnEnter(vParam)
	self:DealWithLocalization()

	self.slotCnt = EquipmentManager.EquipSlotCnt
	self.Animator = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.GoEquip = self:GetChildGameObject("Panel/Equip")
	self.GoSlots = self:GetChildGameObject("Panel/Slots")
	self.ImgEquipIcon = self:GetChildComponent("Panel/Equip/Icon", "Image")

	for i = 1, self.slotCnt do
		self["GoSlot" .. i] = self:GetChildGameObject("Panel/Slots/" .. i)

		local g = self["GoSlot" .. i]

		self["ImgSlot" .. i] = GOUtil.GetComponent(g, "Image")
		self["GoLock" .. i] = GOUtil.FindChildGameObject(g, "Lock")
		self["GoUnlock" .. i] = GOUtil.FindChildGameObject(g, "Unlock")
		self["GoSelect" .. i] = GOUtil.FindChildGameObject(g, "Select")
		self["ImgLevel" .. i] = GOUtil.FindChildComponent(g, "Unlock/ImgLevel", "Image")
		self["TxtLevel" .. i] = GOUtil.FindChildComponent(g, "Unlock/TxtLevel", "Text")
		self["TxtLevel" .. i].fontSize = 28
		self["ImgSuit" .. i] = GOUtil.FindChildComponent(g, "Unlock/ImgSuit", "Image")
	end

	self.TagIntense = self:GetChildGameObject("Panel/Tag/1/Button")
	self.SelIntense = self:GetChildGameObject("Panel/Tag/1/Select")
	self.TagEnchant = self:GetChildGameObject("Panel/Tag/2/Button")
	self.SelEnchant = self:GetChildGameObject("Panel/Tag/2/Select")
	self.TagSynthetize = self:GetChildGameObject("Panel/Tag/3/Button")
	self.SelSynthetize = self:GetChildGameObject("Panel/Tag/3/Select")
	self.GoEnchant = self:GetChildGameObject("Panel/Tag/2")

	self:InitData(vParam)

	self.Tag = self:GetChildComponent("Panel/Tag", "Transform")

	UITweenUtil.CommonTweenRight(self.Tag, 40, 0.14)
end

function PageEquipDevelop:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Tag/1/Button/Text", "Text")
	txt.text = Lang(12259)
	txt = self:GetChildComponent("Panel/Tag/1/Select/Text", "Text")
	txt.text = Lang(12259)
	txt = self:GetChildComponent("Panel/Tag/2/Button/Text", "Text")
	txt.text = Lang(490023)
	txt = self:GetChildComponent("Panel/Tag/2/Select/Text", "Text")
	txt.text = Lang(490023)
	txt = self:GetChildComponent("Panel/Tag/3/Button/Text", "Text")
	txt.text = "魔導書合成"
	txt = self:GetChildComponent("Panel/Tag/3/Select/Text", "Text")
	txt.text = "魔導書合成"
end

function PageEquipDevelop:InitData(vParam)
	if not vParam or not vParam.roleId then
		return
	end

	self.popData = vParam
	self.infoRole = RoleMgr:GetRole(vParam.roleId)
	self.curSlotIdx = vParam.slotIdx or 1
	self.preSlotIdx = self.curSlotIdx

	if EquipmentManager.LastRoleId ~= 0 then
		EquipmentManager.LastRoleId = 0
	end

	self:InitPanel()
	self:ShowPageItemSyn()
end

function PageEquipDevelop:InitPanel()
	local intenseOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.EquipLevel)
	local enchantOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Enchant)
	local open = {}

	if intenseOpen then
		table.insert(open, eTagType.Intense)
	end

	if enchantOpen then
		table.insert(open, eTagType.Enchant)
	end

	self.tagIdx = 0

	if #open > 0 then
		local idx = table.getIndex(open, EquipmentManager.LastDevelopTab)

		self.tagIdx = idx == -1 and open[1] or idx
	end

	if self.tagIdx == 0 then
		return
	end

	self:InitSlots()
	self:UpdateTagPanel()
end

function PageEquipDevelop:UpdateTagPanel()
	GOUtil.SetActive(self.TagIntense, self.tagIdx ~= eTagType.Intense)
	GOUtil.SetActive(self.SelIntense, self.tagIdx == eTagType.Intense)
	GOUtil.SetActive(self.TagEnchant, self.tagIdx ~= eTagType.Enchant)
	GOUtil.SetActive(self.SelEnchant, self.tagIdx == eTagType.Enchant)
	GOUtil.SetActive(self.TagSynthetize, self.tagIdx ~= eTagType.Synthetize)
	GOUtil.SetActive(self.SelSynthetize, self.tagIdx == eTagType.Synthetize)

	if self.tagIdx == eTagType.Intense then
		self.needPlayHideAnim = true

		self.Animator:Play("PanelEquipDevelop_show")

		if self.DlgIntense then
			self.DlgIntense:Show()
		end

		if self.DlgEnchant then
			self.DlgEnchant:Hide()
		end

		if self.DlgSynthetize then
			self.DlgSynthetize:Hide()
		end
	elseif self.tagIdx == eTagType.Enchant then
		if self.needPlayHideAnim then
			self.Animator:Play("PanelEquipDevelop_hide")
		end

		if self.DlgIntense then
			self.DlgIntense:Hide()
		end

		if self.DlgEnchant then
			self.DlgEnchant:Show()
		end

		if self.DlgSynthetize then
			self.DlgSynthetize:Hide()
		end
	elseif self.tagIdx == eTagType.Synthetize then
		if self.needPlayHideAnim then
			self.Animator:Play("PanelEquipDevelop_hide")
		end

		if self.DlgIntense then
			self.DlgIntense:Hide()
		end

		if self.DlgEnchant then
			self.DlgEnchant:Hide()
		end

		if self.DlgSynthetize then
			self.DlgSynthetize:Show()
		end
	end

	self:UpdateDataPanel()
end

function PageEquipDevelop:UpdateDataPanel()
	local data = {
		slotIdx = self.curSlotIdx,
		infoRole = self.infoRole
	}

	for i = 1, self.slotCnt do
		self["GoSlot" .. i]:SetActive(self.tagIdx ~= eTagType.Synthetize)
	end

	if self.tagIdx == eTagType.Intense then
		if self.DlgIntense then
			if not self.update1 then
				self.update1 = true

				self.DlgIntense:InitData(data)
			end
		else
			self.DlgIntense = DlgEquipDevelopIntense()

			self.DlgIntense:Create(self.UIRootObject, data)
			self:AddChildPanel(self.DlgIntense)

			self.DlgIntense.parentPanel = self
			self.update1 = true
		end
	elseif self.tagIdx == eTagType.Enchant then
		if self.DlgEnchant then
			if not self.update2 then
				self.update2 = true

				self.DlgEnchant:InitData(data)
			end
		else
			self.DlgEnchant = DlgEquipDevelopEnchant()

			self.DlgEnchant:Create(self.UIRootObject, data)
			self:AddChildPanel(self.DlgEnchant)

			self.DlgEnchant.parentPanel = self
			self.update2 = true
		end

		self.update3 = false
	elseif self.tagIdx == eTagType.Synthetize then
		if self.DlgSynthetize then
			if not self.update3 then
				self.update3 = true

				self.DlgSynthetize:InitData(data)
			end
		else
			self.DlgSynthetize = DlgEquipDevelopSynthetize()

			self.DlgSynthetize:Create(self.UIRootObject, data)
			self:AddChildPanel(self.DlgSynthetize)

			self.DlgSynthetize.parentPanel = self
			self.update3 = true
		end
	end
end

function PageEquipDevelop:InitSlots()
	self.listEquip = {}

	for i = 1, self.slotCnt do
		local isUnlock = self.infoRole:IsEquipSlotUnlocked(i)
		local infoSlot = self.infoRole:GetEquipSlot(i)
		local infoEquip = EquipmentManager:GetEquip(self.infoRole:GetEquipId(i))

		table.insert(self.listEquip, infoEquip)

		local imgIcon = GOUtil.FindChildComponent(self["GoSlot" .. i], "ImgIcon", "Image")
		local path = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, infoEquip, infoSlot.quality, infoSlot.grade)

		SetImageSprite(imgIcon, path, self)

		if isUnlock then
			self:UpdateDynamicSlotData(i)
			GOUtil.SetActive(self["GoUnlock" .. i], true)
		else
			GOUtil.SetActive(self["GoLock" .. i], true)

			local txtUnlockCon = GOUtil.FindChildComponent(self["GoSlot" .. i], "Lock/Text", "Text")

			txtUnlockCon.text = string.format(Lang(12054), GetConfigArgJson("EquipmentUnlock")[i] .. "\n")
			imgIcon.color = Color.New(0.6980392156862745, 0.6980392156862745, 0.6980392156862745, 0.9254901960784314)
			self["ImgSlot" .. i].color = Color.New(0.7843137254901961, 0.7843137254901961, 0.7843137254901961, 0.9254901960784314)
		end

		RedDotSystemMgr.SetUIRedDot(self["GoSlot" .. i], "Equip/Enchant/" .. self.infoRole.id .. "/" .. i)
	end

	self:UpdateEquipsSuit()
	self:UpdateSelectSlot()
end

function PageEquipDevelop:UpdateDynamicSlotData(slotIdx, devType, simlevel)
	if not slotIdx then
		return
	end

	local infoSlot = self.infoRole:GetEquipSlot(slotIdx)

	local function FunUpdateQuality()
		local quaIdx = EquipmentManager:GetQualityIndex(infoSlot.quality, infoSlot.grade)

		self["ImgLevel" .. slotIdx].color = getColorFromString(GetConfigArgJson("EquipQualityColor")[quaIdx].Color)
	end

	local function FunUpdateLevel()
		self["TxtLevel" .. slotIdx].text = simlevel or infoSlot.level
	end

	local function FunUpdateSuit()
		if infoSlot.scroll ~= 0 then
			GOUtil.SetActive(self["ImgSuit" .. slotIdx], true)
		end

		if infoSlot.scroll ~= 0 then
			local infoReel = ItemManager:Get(infoSlot.scroll)

			SetImageSprite(self["ImgSuit" .. slotIdx], EquipmentManager.GetSuitIconByScrollType(tonumber(infoReel.data.SubType)) .. "_s", self)
		end
	end

	if not devType then
		FunUpdateLevel()
		FunUpdateQuality()
		FunUpdateSuit()

		return
	end

	if devType == eDevelopType.Level then
		FunUpdateLevel()
	elseif devType == eDevelopType.Quality then
		FunUpdateQuality()
	elseif devType == eDevelopType.Enchant then
		FunUpdateSuit()
	elseif devType == eDevelopType.Synthetize then
		FunUpdateSuit()
	end
end

function PageEquipDevelop:UpdateEquipsSuit()
	for i = 1, self.slotCnt do
		if self.infoRole:IsEquipSlotUnlocked(i) then
			local infoSlot = self.infoRole:GetEquipSlot(i)

			if infoSlot.scroll ~= 0 then
				local infoReel = ItemManager:Get(infoSlot.scroll)
				local cnt = self.infoRole:GetActiveSameSuitSubTypeNum(infoSlot.scroll, i, true)
				local listSuit = EquipmentManager.GetSuitByScrollType(tonumber(infoReel.data.SubType))
				local index = 0

				for k, v in ipairs(listSuit) do
					if cnt >= v.Number then
						index = k
					end
				end

				if self["handle" .. i] then
					EffectMgr:Free(self["handle" .. i])

					self["handle" .. i] = nil
				end

				if index ~= 0 then
					self["handle" .. i] = EffectMgr:Alloc("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Trail0" .. index, self["ImgSuit" .. i].gameObject, true)
				end
			end
		end
	end
end

function PageEquipDevelop:UpdateSelectSlot()
	local infoSlot = self.infoRole:GetEquipSlot(self.curSlotIdx)
	local infoEquip = self.listEquip[self.curSlotIdx]

	if infoSlot == nil or infoEquip == nil then
		return
	end

	local icon = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, infoEquip, infoSlot.quality, infoSlot.grade)

	SetImageSprite(self.ImgEquipIcon, icon .. "_1", self)

	if self.curSlotIdx ~= self.preSlotIdx then
		GOUtil.SetActive(self["GoSelect" .. self.preSlotIdx], false)
	end

	GOUtil.SetActive(self["GoSelect" .. self.curSlotIdx], true)
	RedDotSystemMgr.SetUIRedDot(self.GoEnchant, string.format("Equip/Enchant/%d/%d", self.infoRole.id, self.curSlotIdx))
end

function PageEquipDevelop:OnClickGoSlot(data)
	local index = tonumber(data.pointerPress.gameObject.name)

	if not self.infoRole:IsEquipSlotUnlocked(index) then
		local needLevel = GetConfigArgJson("EquipmentUnlock")[index]

		UIMgr.ShowMsg(string.format(Lang(8111000), needLevel))

		return
	end

	if self.curSlotIdx == index then
		return
	end

	self.preSlotIdx = self.curSlotIdx
	self.curSlotIdx = index
	self.update1 = false
	self.update2 = false
	self.update3 = false

	self:UpdateSelectSlot()
	self:UpdateDataPanel()
	RoleRDL.EquipRDL.SubUnlockEquipSlot(self.infoRole, index)
end

function PageEquipDevelop:OnClickTagIntense()
	local elv = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.EquipLevel)
	local equ = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.EquipQuality)

	if not elv and not equ then
		local data1 = TutorialMgr:Get(TutorialFunctionType.EquipLevel)
		local data2 = TutorialMgr:Get(TutorialFunctionType.EquipQuality)
		local desc = elv.desc

		if data1.data.Stage > data1.data.Stage then
			desc = equ.desc
		end

		UIMgr.ShowMsg(desc)

		return
	end

	if not GuideMgr:IsGuided(GuideFunctionType.EquipIntense) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipIntense)
	end

	self.tagIdx = eTagType.Intense
	EquipmentManager.LastDevelopTab = eTagType.Intense

	self:UpdateTagPanel()
end

function PageEquipDevelop:OnClickTagEnchant()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Enchant)

	if not isOpen then
		return
	end

	if not self.infoRole:IsEquipSlotUnlocked(self.curSlotIdx) then
		UIMgr.ShowMsg(_("Desc_Equip_Lock"))

		return
	end

	if not GuideMgr:IsGuided(GuideFunctionType.EquipEnchant) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipEnchant)
	end

	self.tagIdx = eTagType.Enchant
	EquipmentManager.LastDevelopTab = eTagType.Enchant

	self:UpdateTagPanel()
end

function PageEquipDevelop:OnClickTagSynthetize()
	if not GuideMgr:IsGuided(GuideFunctionType.EquipSynthetize) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipSynthetize)
	end

	self.tagIdx = eTagType.Synthetize
	EquipmentManager.LastDevelopTab = eTagType.Synthetize

	self:UpdateTagPanel()
end

function PageEquipDevelop:ShowPageItemSyn()
	if ItemManager.synLineItems ~= nil then
		require("UI/Page/PageSynthetize/PageItemSynthetize")

		self.PageItemSyn = PageItemSynthetize()

		UIMgr.AddPanel(self.PageItemSyn, {
			itemInfo = ItemManager:Get(ItemManager.synLineItems[#ItemManager.synLineItems]),
			needItem = ItemManager.needItem
		})
	end
end

function PageEquipDevelop:OpenPageItemSyn(item, needItem)
	require("UI/Page/PageSynthetize/PageItemSynthetize")

	self.PageItemSyn = PageItemSynthetize()

	UIMgr.AddPanel(self.PageItemSyn, {
		itemInfo = item,
		needItem = needItem
	})
end

function PageEquipDevelop:UpdateEquipAfterDevelop(data)
	local devType = data.type
	local simLv = data.level
	local hideEff = data.hideEff

	self:UpdateDynamicSlotData(self.curSlotIdx, devType, simLv)
	self:UpdateEquipsSuit()

	if (devType == eDevelopType.Level or devType == eDevelopType.Quality) and devType == eDevelopType.Level then
		if self.DlgEnchant and self.update2 then
			self.DlgEnchant:UpdateEquipLevel()
		end

		if not hideEff then
			EffectMgr:Alloc("Fx/UI/Eff_Ui_PanelEquipEnchant/FX_EquipUpgrade", self.ImgEquipIcon.gameObject, true, 1.5)
		end
	end
end

function PageEquipDevelop:UpdateItemDataNotify()
	if self.DlgIntense and self.update1 then
		self.DlgIntense:UpdataCostItemCount()
	end

	if self.DlgEnchant and self.update2 then
		self.DlgEnchant:UpdateReelList()
	end
end

function PageEquipDevelop:UpdateDot()
	return
end

function PageEquipDevelop:UpdateNetData()
	if self.DlgIntense and self.update1 then
		self.DlgIntense:UpdateNetData()
	end

	if self.DlgEnchant and self.update2 then
		self.DlgEnchant:UpdateNetData()
	end

	if self.DlgSynthetize and self.update3 then
		self.DlgSynthetize:UpdateNetData()
	end

	self:UpdateDynamicSlotData(self.curSlotIdx)
	self:UpdateEquipsSuit()
end

function PageEquipDevelop.IsUnlock(tag, withMsg)
	if withMsg == nil then
		withMsg = false
	end

	if tag == 1 then
		if TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.EquipLevel, withMsg) or TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.EquipQuality, withMsg) then
			return true
		end
	elseif tag == 2 then
		if TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.Enchant, withMsg) then
			return true
		end
	elseif tag == 3 then
		return true
	end

	return false
end

function PageEquipDevelop:OnClickedGuideBtn()
	if self.tagIdx == eTagType.Intense then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipIntense)
	elseif self.tagIdx == eTagType.Enchant then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipEnchant)
	elseif self.tagIdx == eTagType.Synthetize then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EquipSynthetize)
	end
end
