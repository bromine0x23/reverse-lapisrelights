-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgEquipDevelopIntense.lua

require("UI/Page/PageRoleCard/Cell/CellCostItem")
require("UI/Page/PageEquipment/DlgEquipBreakDetail")

DlgEquipDevelopIntense = class("DlgEquipDevelopIntense", UIPanel)

function DlgEquipDevelopIntense:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/PanelEquipDevelopIntense"
end

function DlgEquipDevelopIntense:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellCostItem", "PrefabCell", GameObject)
end

function DlgEquipDevelopIntense:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)

	if self.listCellCost then
		for _, v in ipairs(self.listCellCost) do
			if v.OnLeave then
				v:OnLeave()
			end
		end

		self.listCellCost = nil
	end

	self.listCostInfo = nil

	InfoSoundEventMgr:OnBack()
end

function DlgEquipDevelopIntense:OnRegisterEvent()
	self:AddListener(self.BtnDevelop, self.OnPointDownDevelop, EventTriggerType.PointerDown)
	self:AddListener(self.BtnDevelop, self.OnPointUpDevelop, EventTriggerType.PointerUp)
	self:AddListener(self.BtnDevelop, self.OnPointerLongPressDevelop, EventTriggerType.PointerRepeat)
	self:AddClick(self.BtnBDetail, self.OnCLickBtnBDetail)
end

function DlgEquipDevelopIntense:OnUnRegisterEvent()
	self:RemoveListener(self.BtnDevelop, self.OnPointDownDevelop, EventTriggerType.PointerDown)
	self:RemoveListener(self.BtnDevelop, self.OnPointUpDevelop, EventTriggerType.PointerUp)
	self:RemoveListener(self.BtnDevelop, self.OnPointerLongPressDevelop, EventTriggerType.PointerRepeat)
	self:RemoveClick(self.BtnBDetail, self.OnCLickBtnBDetail)

	if self.initUnlockCond then
		self:RemoveClick(self.GoUnlockAvatar, self.OnClickUnlockAvatar)
	end
end

function DlgEquipDevelopIntense:OnEnter(vParam)
	self.attCnt = ATTRIBUTE_USE_CNT

	self:DealWithLocalization()

	self.TxtEquipType = self:GetChildComponent("Panel/Name/TxtType", "Text")
	self.TxtEquipName = self:GetChildComponent("Panel/Name/TxtName", "Text")
	self.TxtEquipLevel = self:GetChildComponent("Panel/Name/TxtLevel", "Text")
	self.ImgRoleIcon = self:GetChildComponent("Panel/Name/Role/Icon", "Image")

	for i = 1, self.attCnt do
		self["GoAtt" .. i] = self:GetChildGameObject("Panel/Attr/" .. i)
		self["TxtCurrAtt" .. i] = GOUtil.FindChildComponent(self["GoAtt" .. i], "TxtCurr", "Text")
		self["TxtNextAtt" .. i] = GOUtil.FindChildComponent(self["GoAtt" .. i], "TxtNext", "Text")
	end

	self.ImgCostCoinIcon = self:GetChildComponent("Panel/Develop/BtnDevelop/Coin/Icon", "Image")
	self.TxtCostCoinNum = self:GetChildComponent("Panel/Develop/BtnDevelop/Coin/Text", "Text")
	self.GoCost = self:GetChildGameObject("Panel/Develop/GoCost")
	self.GoPerfect = self:GetChildGameObject("Panel/Develop/GoPerfect")
	self.BtnDevelop = self:GetChildGameObject("Panel/Develop/BtnDevelop")
	self.BtnBDetail = self:GetChildGameObject("Panel/Develop/BtnBDetail")
	self.GoDevelopDot = self:GetChildGameObject("Panel/Develop/BtnDevelop/Dot")
	self.TxtDevelop = self:GetChildComponent("Panel/Develop/BtnDevelop/Text1", "Text")
	self.TxtAssetLess = self:GetChildComponent("Panel/Develop/BtnDevelop/Text2", "Text")
	self.TxtLock = self:GetChildComponent("Panel/Develop/GoLock", "Text")
	self.GoUnlockAvatar = self:GetChildGameObject("Panel/UnlockAvatar")

	local scroll = self:GetChildGameObject("Panel/Develop/GoCost/Scroll")

	self.ScrollView = GOUtil.AddMissingComponent(scroll, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scroll, "Content", "Transform")
	self.listCellCost = {}

	self:InitData(vParam)
end

function DlgEquipDevelopIntense:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Develop/Title/Text", "Text")
	txt.text = Lang(42331)
	txt = self:GetChildComponent("Panel/Develop/BtnBDetail/Text", "Text")
	txt.text = Lang(42325)
	txt = self:GetChildComponent("Panel/Develop/GoPerfect", "Text")
	txt.text = Lang(42322)

	for i = 1, self.attCnt do
		txt = self:GetChildComponent("Panel/Attr/" .. i .. "/TxtAttr", "Text")
		txt.text = _("eAttType_" .. i)
	end
end

function DlgEquipDevelopIntense:Show()
	GOUtil.SetActive(self.UIRootObject, true)
end

function DlgEquipDevelopIntense:Hide()
	GOUtil.SetActive(self.UIRootObject, false)
end

function DlgEquipDevelopIntense:InitData(vParam)
	if not vParam.slotIdx or not vParam.infoRole then
		return
	end

	self.slotIdx = vParam.slotIdx or 1
	self.infoRole = vParam.infoRole
	self.infoSlot = self.infoRole:GetEquipSlot(self.slotIdx)
	self.equipId = self.infoRole:GetEquipId(self.slotIdx)
	self.infoEquip = EquipmentManager:GetEquip(self.equipId)
	self.simLevel = self.infoSlot.level

	self:UpdatePanel()
end

function DlgEquipDevelopIntense:UpdatePanel()
	self.level = self.simLevel
	self.quality = self.infoSlot.quality
	self.grade = self.infoSlot.grade
	self.qualityIdx = EquipmentManager:GetQualityIndex(self.quality, self.grade)
	self.curLimitLv = EquipmentManager.listMaxQualityLevel[self.qualityIdx]
	self.isMaxLv = self.level >= EquipmentManager.listMaxQualityLevel[#EquipmentManager.listMaxQualityLevel]
	self.isMaxQua = EquipmentManager:IsEquipHighestQuality(self.infoSlot)
	self.developType = nil

	if not self.isMaxLv and self.level == self.curLimitLv then
		self.developType = eDevelopType.Quality
		self.TxtDevelop.text = _("UI_Level_Bt")
	else
		self.developType = eDevelopType.Level
		self.TxtDevelop.text = _("UI_Level_Up")
	end

	if self.isMaxLv and self.isMaxQua then
		GOUtil.SetActive(self.GoPerfect, true)
		GOUtil.SetActive(self.BtnDevelop, false)
		GOUtil.SetActive(self.GoCost, false)
		GOUtil.SetActive(self.TxtLock, false)
		GOUtil.SetActive(self.BtnBDetail, false)
	else
		GOUtil.SetActive(self.GoPerfect, false)
		GOUtil.SetActive(self.GoCost, true)
		GOUtil.SetActive(self.BtnBDetail, self.developType == eDevelopType.Quality)
	end

	self:UpdateInfo()
	self:UpdateAttr()
	self:UpdateCost()
	self:UpdateUnlockAvatar()
end

function DlgEquipDevelopIntense:UpdateInfo()
	UIUtil.SetImageSprite(self.ImgRoleIcon, self.infoRole.actorData.CharacterIcon, self)

	if self.infoEquip.data.Weapon ~= "" then
		self.TxtEquipType.text = _("Desc_Weapon")
	else
		self.TxtEquipType.text = ""
	end

	local _, name = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, self.infoEquip, self.quality, self.grade)

	self.TxtEquipName.text = name
	self.TxtEquipLevel.text = Lang(12004) .. "  <size=33>" .. self.level .. "/" .. self.curLimitLv .. "</size>"
end

function DlgEquipDevelopIntense:UpdateAttr()
	local listCurLv = EquipmentManager:GetProp(self.level, self.infoRole.job, self.slotIdx, self.equipId)
	local listCurQua = EquipmentManager:GetQualityProp(self.infoRole.job, self.quality, self.grade, self.slotIdx)

	for i = 1, self.attCnt do
		self["TxtCurrAtt" .. i].text = listCurLv[i] + listCurQua[i]

		if self.isMaxLv and self.isMaxQua then
			self["TxtNextAtt" .. i].text = listCurLv[i] + listCurQua[i]
		elseif self.developType == eDevelopType.Level then
			local listNextLv = EquipmentManager:GetProp(self.level + 1, self.infoRole.job, self.slotIdx, self.equipId)

			self["TxtNextAtt" .. i].text = listNextLv[i] + listCurQua[i]
		else
			local nextQ, nextG = EquipmentManager:GetNextQuality(self.quality, self.grade)
			local listNextQua = EquipmentManager:GetQualityProp(self.infoRole.job, nextQ, nextG, self.slotIdx)

			self["TxtNextAtt" .. i].text = listCurLv[i] + listNextQua[i]
		end
	end
end

function DlgEquipDevelopIntense:UpdateUnlockAvatar()
	if self.infoEquip.data.Weapon == "" then
		SetActiveWithState(self, "GoUnlockAvatar", false)

		return
	elseif self.IsAvatarUnlocked then
		return
	end

	local unlockCond = self.infoRole.data.AvatarUnlock

	if unlockCond == nil or #unlockCond == 0 then
		SetActiveWithState(self, "GoUnlockAvatar", false)

		return
	end

	if not self.IsAvatarUnlocked and self.simLevel >= unlockCond[1] and EquipmentManager:GetQualityIndex(self.infoSlot.quality, self.infoSlot.grade) >= unlockCond[2] + 1 then
		self.IsAvatarUnlocked = true

		SetActiveWithState(self, "GoUnlockAvatar", false)

		return
	end

	if not self.initUnlockCond then
		self.initUnlockCond = true

		local imgIcon = GOUtil.FindChildComponent(self.GoUnlockAvatar, "Icon", "Image")

		self.infoAvatar = AvatarManager:GetAvatar(ItemManager.GetRewardPackData(unlockCond[3]).PackItem[1][2])

		SetImageSprite(imgIcon, self.infoAvatar.data.Icon, self)

		local txtPrompt = GOUtil.FindChildComponent(self.GoUnlockAvatar, "Prompt/Text", "Text")

		txtPrompt.text = string.format(_("Desc_Can_Get_Develop"), unlockCond[1])

		self:AddClick(self.GoUnlockAvatar, self.OnClickUnlockAvatar)
	end

	SetActiveWithState(self, "GoUnlockAvatar", true)
end

function DlgEquipDevelopIntense:UpdateCost()
	if not self.isMaxLv then
		self.listCostItem = {}
		self.listCostCoin = {}

		if self.level == self.curLimitLv then
			if not self.isMaxQua then
				self:UpdateBreakthCost()
			end
		else
			self:UpdateUpgradeCost()
		end
	end
end

function DlgEquipDevelopIntense:UpdateUpgradeCost()
	local listCost = EquipmentManager:GetCostList(self.level, self.infoEquip.jobType, self.slotIdx)

	self:UpdateCostPanel(listCost)
end

function DlgEquipDevelopIntense:UpdateBreakthCost()
	local listCost = EquipmentManager:GetQualityCostList(self.infoEquip.jobType, self.quality, self.grade, self.slotIdx)

	self:UpdateCostPanel(listCost)
end

local function CheckRequestCondition(costCoin, costItem, noMsg)
	local function fun(costs)
		if not costs then
			return false
		end

		for i = 1, #costs do
			local cost = costs[i]

			return ItemManager:IsItemHoldEnough(cost[1], cost[2], noMsg), cost[1]
		end
	end

	local isItemEnough, itemId = fun(costItem)
	local isCoinEnough, coinId = fun(costCoin)

	if not isItemEnough then
		return false
	elseif not isCoinEnough then
		return false, coinId
	end

	return true
end

function DlgEquipDevelopIntense:UpdateCostPanel(listCost)
	self.listCostInfo = {}

	for _, v in ipairs(listCost) do
		local info = ItemManager:Get(v[1])

		if info.data.Type ~= "P_GOLD" then
			table.insert(self.listCostItem, v)
			table.insert(self.listCostInfo, info)
		elseif info.data.Type == "P_GOLD" then
			table.insert(self.listCostCoin, v)
		end
	end

	local function FunUpdate(index, cell)
		local cost = self.listCostItem[index]

		if cost then
			local data = {
				showPrompt = true,
				showGet = true,
				isSynthetize = true,
				info = ItemManager:Get(cost[1]),
				needNum = cost[2]
			}
			local t = {}

			if data.needNum > data.info:GetCurResNum() then
				local slot = {
					level = self.infoSlot.level,
					infoSlot = self.infoSlot,
					infoEquip = self.infoEquip
				}

				if self.developType == eDevelopType.Level then
					t = EquipmentManager:GetDevelopNeedItem({
						slot
					}, nil, {})
				else
					t = EquipmentManager:GetBreakNeedItem({
						slot
					}, nil, {})
				end

				data.isCanSynthetize = #t > 0
			end

			cell:UpdateData(data)
		end
	end

	local function FunCreate(index)
		local cell = CellCostItem(self.PrefabCell, self.ScrollView.content.gameObject, self)

		cell:Create()

		cell.UIRootObject.name = index

		FunUpdate(index, cell)
		table.insert(self.listCellCost, cell)
	end

	if #self.listCellCost > #self.listCostItem then
		for k, v in ipairs(self.listCellCost) do
			if k <= #self.listCostItem then
				FunUpdate(k, v)
				GOUtil.SetActive(v.UIRootObject, true)
			else
				GOUtil.SetActive(v.UIRootObject, false)
			end
		end
	else
		for i = 1, #self.listCostItem do
			if i > #self.listCellCost then
				FunCreate(i)
			else
				local cell = self.listCellCost[i]

				FunUpdate(i, cell)
				GOUtil.SetActive(cell.UIRootObject, true)
			end
		end
	end

	if #self.listCellCost > 1 then
		self.ScrollView.horizontal = true
	else
		self.ScrollView.horizontal = false
	end

	local info = ItemManager:Get(self.listCostCoin[1] and self.listCostCoin[1][1] or 501)

	SetImageSprite(self.ImgCostCoinIcon, info:GetIcon(), self)

	self.TxtCostCoinNum.text = self.listCostCoin[1] and self.listCostCoin[1][2] or 0

	if self.infoRole:IsEquipSlotUnlocked(self.slotIdx) then
		GOUtil.SetActive(self.BtnDevelop, true)
		GOUtil.SetActive(self.TxtLock, false)

		local isEnough, lessId = CheckRequestCondition(self.listCostCoin, self.listCostItem, true)

		GOUtil.SetActive(self.TxtAssetLess, not isEnough)

		if not isEnough then
			if lessId then
				self.TxtAssetLess.text = string.format(_("Develop_Cost_Not_Enough"), ItemManager:Get(lessId):GetName())
			else
				self.TxtAssetLess.text = Lang(42180)
			end
		end
	else
		GOUtil.SetActive(self.BtnDevelop, false)
		GOUtil.SetActive(self.TxtLock, true)

		self.TxtLock.text = string.format(Lang(12054), GetConfigArgJson("EquipmentUnlock")[self.slotIdx])
	end
end

function DlgEquipDevelopIntense:OnClickBtnDevelop(devtype)
	devtype = devtype or self.developType

	local preUnlockAvtarState = self.IsAvatarUnlocked

	local function cb(setter)
		if self.infoEquip.data.Weapon ~= "" and preUnlockAvtarState ~= self.IsAvatarUnlocked then
			local list = SetterData.ConvertSettersToPbItems(setter)

			UIMgr.AddPanel(DlgGetAward.GetInstance(), {
				list = list
			})
		end
	end

	if devtype == eDevelopType.Level then
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				self.simLevel = self.infoSlot.level

				self:UpdatePanel()

				local hideEff = false

				if not self.IsSimUpLevel then
					UIMgr.ShowMsg(_("Desc_LevelUpSuccess"))
					SoundMgr.Play(PATH_SFX_UI_CARD_SKILLUP)
				else
					hideEff = true
				end

				Event.Instance:Fire("UpdateEquipAfterDevelop", {
					type = eDevelopType.Level,
					hideEff = hideEff
				})
				cb(vMsg.setter)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)

				self.simLevel = self.infoSlot.level

				self:UpdatePanel()
				Event.Instance:Fire("UpdateEquipAfterDevelop", {
					hideEff = true,
					type = eDevelopType.Level
				})
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestEquipIntense(2, self.infoRole.id, self.slotIdx, self.simLevel, wrap_cb)
	else
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				local preUnlockAvtarState = self.IsAvatarUnlocked

				self:UpdatePanel()
				Event.Instance:Fire("UpdateEquipAfterDevelop", {
					type = eDevelopType.Quality
				})

				local function panelCb()
					cb(vMsg.setter)
				end

				require("UI/Page/PageRoleCard/Dlg/DlgCardUpResult")
				UIMgr.AddPanel(DlgCardUpResult(), {
					type = 3,
					infoRole = self.infoRole,
					slotIdx = self.slotIdx,
					callback = panelCb
				})
				InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
				InfoSoundEventMgr:Play("VocalCommon6", self.infoRole.data.VocalCommon6)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestEquipIntense(1, self.infoRole.id, self.slotIdx, 0, wrap_cb)
	end
end

function DlgEquipDevelopIntense:SimulateRequestEquipUpLevel()
	if self.developType == eDevelopType.Quality then
		self.longPressDisable = true

		UIMgr.ShowMsg(_("Msg_UpLevel_After_UpQuality"))

		return
	end

	local listCoin = {}
	local listItem = {}

	local function ResetCost(costType, cost)
		if costType == 1 then
			table.insert(listCoin, cost)
		else
			table.insert(listItem, cost)
		end
	end

	local function DealCost(list, costType)
		for k, v in pairs(list) do
			local has = false

			for k1, v1 in ipairs(self.listSimCost) do
				if v[1] == v1[1] then
					has = true

					ResetCost(costType, {
						v1[1],
						v1[2] + v[2]
					})
				end
			end

			if not has then
				ResetCost(costType, {
					v[1],
					v[2]
				})
			end
		end
	end

	DealCost(self.listCostCoin, 1)
	DealCost(self.listCostItem, 2)

	if not CheckRequestCondition(listCoin, listItem) then
		self.longPressDisable = true

		return
	end

	local function DealNewCost(list)
		for k, v in ipairs(list) do
			local has = false

			for k1, v1 in ipairs(self.listSimCost) do
				if v[1] == v1[1] then
					v1[2] = v[2]
					has = true
				end
			end

			if not has then
				table.insert(self.listSimCost, v)
			end
		end
	end

	DealNewCost(listItem)
	DealNewCost(listCoin)

	self.simLevel = self.simLevel + 1

	local preUnlockAvtarState = self.IsAvatarUnlocked

	self:UpdatePanel()
	UIMgr.ShowMsg(_("Desc_LevelUpSuccess"))
	Event.Instance:Fire("UpdateEquipAfterDevelop", {
		type = eDevelopType.Level,
		level = self.simLevel
	})
	SoundMgr.Play(PATH_SFX_UI_CARD_SKILLUP)

	local hasUnlockAvatar = self.infoEquip.data.Weapon ~= "" and preUnlockAvtarState ~= self.IsAvatarUnlocked

	if self.isMaxLv or hasUnlockAvatar then
		self.longPressDisable = true

		self:OnPointUpDevelop()
	else
		local function GetUsedItemNum(id)
			for _, v in ipairs(self.listSimCost) do
				if v[1] == id then
					return v[2]
				end
			end

			return 0
		end

		local isEnough = true

		if self.listCellCost then
			for k, cell in ipairs(self.listCellCost) do
				local cost = self.listCostItem[k]
				local holdNum = ItemManager:GetItemCount(cost[1])
				local usedNum = GetUsedItemNum(cost[1])

				if usedNum ~= 0 then
					cell:UpdateNum(holdNum - usedNum, true)
				end

				if holdNum - usedNum < cost[2] then
					isEnough = false
					self.TxtAssetLess.text = Lang(42180)
				end
			end
		end

		if isEnough then
			for k, cost in ipairs(self.listCostCoin) do
				local holdNum = ItemManager:GetItemCount(cost[1])
				local usedNum = GetUsedItemNum(cost[1])
				local leftNum = holdNum - usedNum

				if self.parentPanel ~= nil and self.parentPanel.DlgAssetsInfo ~= nil then
					self.parentPanel.DlgAssetsInfo:UpdateAssetShowNum(cost[1], leftNum)
				end

				if leftNum < cost[2] then
					isEnough = false
					self.TxtAssetLess.text = string.format(_("Develop_Cost_Not_Enough"), ItemManager:Get(cost[1]):GetName())
				end
			end
		end

		GOUtil.SetActive(self.TxtAssetLess, not isEnough)
	end
end

function DlgEquipDevelopIntense:OnPointDownDevelop()
	self.simLevel = self.infoSlot.level
	self.listSimCost = {}
	self.IsSimUpLevel = false
	self.longPressDisable = false

	if self.developType == eDevelopType.Quality then
		self.longPressDisable = true
	end
end

function DlgEquipDevelopIntense:OnPointUpDevelop()
	if not self.IsSimUpLevel then
		if not CheckRequestCondition(self.listCostCoin, self.listCostItem) then
			return
		end

		if self.developType == eDevelopType.Level then
			self.simLevel = self.infoSlot.level + 1
		end

		self:OnClickBtnDevelop()
	elseif self.simLevel ~= self.infoSlot.level then
		self:OnClickBtnDevelop(eDevelopType.Level)
	end
end

function DlgEquipDevelopIntense:OnPointerLongPressDevelop(data)
	if self.longPressDisable then
		return
	end

	self.IsSimUpLevel = true

	self:SimulateRequestEquipUpLevel()
end

function DlgEquipDevelopIntense:OnCLickBtnBDetail()
	UIMgr.AddPanel(DlgEquipBreakDetail(), {
		infoRole = self.infoRole,
		slotIdx = self.slotIdx
	})
end

function DlgEquipDevelopIntense:UpdataCostItemCount()
	if self.isMaxLv and self.isMaxQua then
		return
	end

	if self.listCellCost then
		for i = 1, #self.listCellCost do
			local info = self.listCostInfo[i]

			self.listCellCost[i]:UpdateNum(info:GetCurResNum())
		end
	end

	if self.infoRole:IsEquipSlotUnlocked(self.slotIdx) then
		GOUtil.SetActive(self.TxtAssetLess, not CheckRequestCondition(self.listCostCoin, self.listCostItem, true))
	end
end

function DlgEquipDevelopIntense:UpdateNetData()
	self.simLevel = self.infoSlot.level

	self:UpdatePanel()
end

function DlgEquipDevelopIntense:OnClickUnlockAvatar()
	if not self.infoAvatar then
		return
	end

	local itemInfo = ItemManager:GetValueItem(571, self.infoAvatar.id)

	if self.infoAvatar:IsBPAvatar() then
		itemInfo = ItemManager:GetValueItem(573, self.infoAvatar.id)
	end

	UIMgr.ShowItemTip(itemInfo)
end
