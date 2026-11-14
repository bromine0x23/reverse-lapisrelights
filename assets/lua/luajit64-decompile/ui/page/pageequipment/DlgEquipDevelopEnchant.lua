-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgEquipDevelopEnchant.lua

require("UI/Page/PageEquipment/CellReel")
require("UI/Page/PageEquipment/DlgEnchant")

DlgEquipDevelopEnchant = class("DlgEquipDevelopEnchant", UIPanel)

function DlgEquipDevelopEnchant:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/PanelEquipDevelopEnchant"
end

function DlgEquipDevelopEnchant:PreLoad()
	self:LoadResAsync("UI/PanelEquipment/CellReel", "PrefabCellReel", GameObject)
end

function DlgEquipDevelopEnchant:Purge()
	self.base.Purge(self)
	self:OnLeave()
	RoleRDL.EquipRDL.SubEquipNewEnchant()
end

function DlgEquipDevelopEnchant:OnLeave()
	ResourceMgr.Unload(self.PrefabCellReel)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.item and self.item.OnLeave then
		self.item:OnLeave()

		self.item = nil
	end

	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)

		self.Timer1 = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end

	if self.Timer3 then
		TimerMgr.RemoveTimer(self.Timer3)

		self.Timer3 = nil
	end

	if self.Timer4 then
		TimerMgr.RemoveTimer(self.Timer4)

		self.Timer4 = nil
	end

	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_WC")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_SW")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Glow01")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Glow01_B")
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_Welfare/FX_UI_PanelEnchant")
end

function DlgEquipDevelopEnchant:OnRegisterEvent()
	self:AddClick(self.BtnGetReel, self.OnClickedBtnGetReel)
	self:AddClick(self.BtnEnchant, self.OnClickedBtnEnchant)
	self:AddClick(self.GoAdd, self.OnClickedGoAdd)
	Event.Instance:Add("UpdateEnchantPanel", self.UpdateEnchantPanel, self)
end

function DlgEquipDevelopEnchant:OnUnRegisterEvent()
	self:RemoveClick(self.BtnGetReel, self.OnClickedBtnGetReel)
	self:RemoveClick(self.BtnEnchant, self.OnClickedBtnEnchant)
	self:RemoveClick(self.GoAdd, self.OnClickedGoAdd)
	Event.Instance:Remove("UpdateEnchantPanel", self.UpdateEnchantPanel, self)
end

function DlgEquipDevelopEnchant:OnEnter(vParam)
	self:DealWithLocalization()

	self.ImgEquipIcon = self:GetChildComponent("Enchant/Equip/BgIcon/Icon", "Image")
	self.TxtEquipName = self:GetChildComponent("Enchant/Equip/TxtName", "Text")
	self.TxtEquipLevel = self:GetChildComponent("Enchant/Equip/TxtLevel", "Text")

	for i = 1, 3 do
		self["GoAtt" .. i] = self:GetChildGameObject("Enchant/Attr/" .. i)
		self["ImgRank" .. i] = GOUtil.FindChildComponent(self["GoAtt" .. i], "Rank", "Image")
		self["TxtAtt" .. i] = GOUtil.FindChildComponent(self["GoAtt" .. i], "TxtAtt", "Text")
		self["TxtAdd" .. i] = GOUtil.FindChildComponent(self["GoAtt" .. i], "TxtAdd", "Text")

		if i <= 2 then
			self["ImgUseSuit" .. i] = self:GetChildComponent("Enchant/Suit/UseSuit/" .. i .. "/Bg", "Image")
			self["TxtUseSuit" .. i] = self:GetChildComponent("Enchant/Suit/UseSuit/" .. i .. "/ScrollView/Text", "Text")
			self["ImgSelSuit" .. i] = self:GetChildComponent("Enchant/Suit/SelSuit/" .. i .. "/Bg", "Image")
			self["TxtSelSuit" .. i] = self:GetChildComponent("Enchant/Suit/SelSuit/" .. i .. "/ScrollView/Text", "Text")
			self["GoSelEffPoint" .. i] = self:GetChildGameObject("Enchant/Suit/SelSuit/" .. i .. "/Bg")
		end
	end

	self.ImgUseSuitIcon = self:GetChildComponent("Enchant/Suit/UseSuit/Info/SuitIcon", "Image")
	self.TxtUseSuitName = self:GetChildComponent("Enchant/Suit/UseSuit/Info/SuitName", "Text")
	self.ImgSelSuitIcon = self:GetChildComponent("Enchant/Suit/SelSuit/Info/SuitIcon", "Image")
	self.TxtSelSuitName = self:GetChildComponent("Enchant/Suit/SelSuit/Info/SuitName", "Text")
	self.GoAdd = self:GetChildGameObject("Enchant/Cost/Info/Reel/Add")
	self.GoSelReel = self:GetChildGameObject("Enchant/Cost/Info/Sel")
	self.GoNoSelReel = self:GetChildGameObject("Enchant/Cost/Info/NoSel")

	local goItem = self:GetChildGameObject("Enchant/Cost/Info/Reel/CellItem")

	self.item = CellItem(goItem)

	self.item:InitItemByRoot(goItem)

	self.item.tipData = {
		showNum = true,
		initPanelIndex = 1,
		needFromBtn = true
	}
	self.TxtReelName = self:GetChildComponent("Enchant/Cost/Info/Sel/Image/TxtReel", "Text")
	self.TxtReelInfo = self:GetChildComponent("Enchant/Cost/Info/Sel/TxtScroll/TxtInfo", "Text")
	self.TxtCostReel = self:GetChildComponent("Enchant/Cost/Info/Reel/BgNeed/TxtNeed", "Text")
	self.ImgCostCoin = self:GetChildComponent("Enchant/BtnEnchant/Coin/Icon", "Image")
	self.TxtCostCoin = self:GetChildComponent("Enchant/BtnEnchant/Coin/Text", "Text")
	self.BtnGetReel = self:GetChildGameObject("ReelList/GoGetReel")
	self.BtnEnchant = self:GetChildGameObject("Enchant/BtnEnchant")
	self.GoUseSuit = self:GetChildGameObject("Enchant/Suit/UseSuit")
	self.GoNoUseSuit = self:GetChildGameObject("Enchant/Suit/NoUseSuit")
	self.GoSelSuit = self:GetChildGameObject("Enchant/Suit/SelSuit")
	self.GoNoSelSuit = self:GetChildGameObject("Enchant/Suit/NoSelSuit")
	self.GoNoSuit = self:GetChildGameObject("Enchant/Suit/NoneSuit")
	self.GoReelList = self:GetChildGameObject("ReelList")
	self.TxtLock = self:GetChildComponent("Enchant/GoLock", "Text")

	GOUtil.SetFont(self.TxtReelInfo, UIMgr.JPFonts.W5)
	self:InitReelList()
	self:InitData(vParam)
	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon9", self.infoRole.data.VocalCommon9)
end

function DlgEquipDevelopEnchant:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("ReelList/Text", "Text")
	txt.text = _("Desc_ReelList")
	txt = self:GetChildComponent("ReelList/GoGetReel/Text1", "Text")
	txt.text = _("Desc_NoReel")
	txt = self:GetChildComponent("ReelList/GoGetReel/Text2", "Text")
	txt.text = _("Desc_GoGetReel")
	txt = self:GetChildComponent("Enchant/Suit/NoUseSuit/Text", "Text")
	txt.text = _("Desc_EquipEnchant_None")
	txt = self:GetChildComponent("Enchant/Suit/NoSelSuit/Text", "Text")
	txt.text = _("Desc_EquipEnchant_None")
	txt = self:GetChildComponent("Enchant/Suit/NoneSuit/Text", "Text")
	txt.text = _("Desc_EquipEnchant_None")
	txt = self:GetChildComponent("Enchant/Cost/Title/Text", "Text")
	txt.text = _("Desc_NeedItem_1")
	txt = self:GetChildComponent("Enchant/Cost/Info/NoSel/Text", "Text")
	txt.text = _("Desc_SetReel")
	txt = self:GetChildComponent("Enchant/BtnEnchant/Text", "Text")
	txt.text = _("DlgEnchant_Execute")

	for i = 1, 3 do
		txt = self:GetChildComponent("Enchant/Attr/" .. i .. "/TxtAtt", "Text")
		txt.text = _("PageRole_TagAttr")
		txt = self:GetChildComponent("Enchant/Attr/" .. i .. "/TxtAdd", "Text")
		txt.text = "---"

		if i <= 2 then
			txt = self:GetChildComponent("Enchant/Suit/UseSuit/" .. i .. "/Bg/Text", "Text")
			txt.text = i * 3 .. _("Desc_Piece")
			txt = self:GetChildComponent("Enchant/Suit/SelSuit/" .. i .. "/Bg/Text", "Text")
			txt.text = i * 3 .. _("Desc_Piece")
		end
	end

	txt = self:GetChildComponent("Enchant/Title/Text", "Text")
	txt.text = _("Desc_Suit_Current")
end

function DlgEquipDevelopEnchant:Show()
	GOUtil.SetActive(self.UIRootObject, true)

	if self.UIScrollTool and self.ContentPosY and self.ContentPosY ~= 0 then
		self.UIScrollTool:SetInitPos(Vector3(0, self.ContentPosY, 0))
		self.UIScrollTool:SetContentPosImmediate(Vector2(0, self.ContentPosY), self.listReelId)
	end

	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon9", self.infoRole.data.VocalCommon9)
end

function DlgEquipDevelopEnchant:Hide()
	RoleRDL.EquipRDL.SubEquipNewEnchant()

	if self.UIScrollTool then
		self.UIScrollTool:UpdateListDataKeepPos(self.listReelId)
	end

	GOUtil.SetActive(self.UIRootObject, false)

	if self.UIScrollTool then
		self.ContentPosY = self.UIScrollTool.ScrollView.content.anchoredPosition.y
	end
end

function DlgEquipDevelopEnchant:InitReelList()
	self.listReelId = ItemManager:GetScrollItemList() or {}

	GOUtil.SetActive(self.BtnGetReel, #self.listReelId == 0)

	local scrollArea = self:GetChildGameObject("ReelList/BgScroll/ScrollArea")
	local content = self:GetChildComponent("ReelList/BgScroll/ScrollArea/Content", "RectTransform")
	local count = #self.listReelId

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local reelId = self.listReelId[index]

		item:UpdateData(reelId, self.curReelIdx)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellReel, CellReel, self, false, addCallback, updateCallback)
end

function DlgEquipDevelopEnchant:InitData(vParam)
	if not vParam.slotIdx or not vParam.infoRole then
		return
	end

	self.slotIdx = vParam.slotIdx
	self.infoRole = vParam.infoRole

	if not self.IsSet then
		local imgIcon = self:GetChildComponent("ReelList/Role/Icon", "Image")
		local imgJob = self:GetChildComponent("ReelList/Role/Job", "Image")

		SetImageSprite(imgIcon, self.infoRole.actorData.CharacterIcon, self)
		SetImageSprite(imgJob, "UIDyAtlas/RoleJob/ICO_" .. self.infoRole.data.Job .. "_01_S", self)

		self.IsSet = true
	end

	self.infoSlot = self.infoRole:GetEquipSlot(self.slotIdx)
	self.infoEquip = EquipmentManager:GetEquip(self.infoRole:GetEquipId(self.slotIdx))
	self.curReelIdx = 0

	self:InitEquipInfo()
	self:UpdatePanel()
	self:UpdateReel()
end

function DlgEquipDevelopEnchant:InitEquipInfo()
	local icon, name = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, self.infoEquip, self.infoSlot.quality, self.infoSlot.grade)

	SetImageSprite(self.ImgEquipIcon, icon, self)

	self.TxtEquipName.text = name

	local isUnLock = self.infoRole:IsEquipSlotUnlocked(self.slotIdx)

	GOUtil.SetActive(self.BtnEnchant, isUnLock)
	GOUtil.SetActive(self.TxtLock, not isUnLock)

	if not isUnLock then
		self.TxtLock.text = string.format(Lang(12054), GetConfigArgJson("EquipmentUnlock")[self.slotIdx])
	end
end

function DlgEquipDevelopEnchant:UpdateEquipLevel()
	self.TxtEquipLevel.text = Lang(12002) .. self.infoSlot.level
end

function DlgEquipDevelopEnchant:UpdatePanel()
	self:UpdateUsedSuit()
	self:UpdateWillUseSuit()
	self:UpdateEquipLevel()
end

function DlgEquipDevelopEnchant:UpdateReel(updateNum)
	if self.recordReelIdx and self.recordReelIdx ~= 0 then
		local reelId = self.listReelId[self.recordReelIdx]

		if reelId ~= nil and ItemManager:GetItemCount(reelId) ~= 0 and reelId == self.infoSlot.scroll then
			self:UpdateReelSelect(self.recordReelIdx, updateNum)

			self.recordReelIdx = 0
		else
			self:UpdateReelList()
		end
	end
end

function DlgEquipDevelopEnchant:UpdateReelList()
	if self.UIScrollTool then
		self.listReelId = ItemManager:GetScrollItemList() or {}

		GOUtil.SetActive(self.BtnGetReel, #self.listReelId == 0)
		self.UIScrollTool:UpdateListData(self.listReelId)
	end
end

function DlgEquipDevelopEnchant:UpdateUsedSuit()
	if self.infoSlot.scroll ~= 0 then
		local attributes = self.infoSlot.attributes or {}

		for i = 1, 3 do
			if i <= #attributes then
				self["TxtAtt" .. i].text = _("eAttType_" .. attributes[i].type)

				local strValue = TenaryOp(attributes[i].param == 1, attributes[i].value, attributes[i].value / 10 .. "%")

				self["TxtAdd" .. i].text = "+" .. strValue

				GOUtil.SetActive(self["ImgRank" .. i], true)

				local _, rank = self:GetEnchantRank(self.slotIdx, self.infoSlot.scroll, attributes[i])

				SetImageSprite(self["ImgRank" .. i], "UI/PanelEquipment/AtlasEquipDevelop/ic_itemup_word_0" .. rank, self)
			else
				GOUtil.SetActive(self["ImgRank" .. i], false)

				self["TxtAtt" .. i].text = "---"
				self["TxtAdd" .. i].text = "---"
			end
		end

		self:SetSuitEffect(self.infoSlot.scroll, 1)
	else
		for i = 1, 3 do
			GOUtil.SetActive(self["ImgRank" .. i], false)

			self["TxtAtt" .. i].text = "---"
			self["TxtAdd" .. i].text = "---"
		end
	end
end

function DlgEquipDevelopEnchant:UpdateWillUseSuit(needplay)
	self:UpdateSuitState()

	if self.listReelId[self.curReelIdx] ~= nil then
		self:SetSuitEffect(self.listReelId[self.curReelIdx], 2, needplay)
	end

	self:UpdateReelInfo()
end

function DlgEquipDevelopEnchant:UpdateSuitState(_type)
	local isUse = self.infoSlot.scroll ~= 0
	local isSel = self.listReelId[self.curReelIdx] ~= nil
	local update = true

	update = true

	local update1 = true

	if isUse and self.Used == isUse or not isUse and self.Used == isUse and self.Seled == isSel then
		update1 = false
	end

	local update2 = true

	if self.Seled == isSel and self.Used == isUse then
		update2 = false
	end

	if update then
		GOUtil.SetActive(self.GoNoSuit, not isUse and not isSel)
	end

	if update1 then
		GOUtil.SetActive(self.GoUseSuit, isUse)
		GOUtil.SetActive(self.GoNoUseSuit, isSel and not isUse)
	end

	if update2 then
		GOUtil.SetActive(self.GoSelSuit, isSel)
		GOUtil.SetActive(self.GoNoSelSuit, isUse and not isSel)
	end

	self.Used = isUse
	self.Seled = isSel
end

function DlgEquipDevelopEnchant:SetSuitEffect(reelId, _type, needplay)
	local reelType = tonumber(ItemManager:Get(reelId).data.SubType)
	local listSuit = EquipmentManager.GetSuitByScrollType(reelType)

	if #listSuit == 0 then
		return
	end

	if _type == 1 then
		self.TxtUseSuitName.text = _("Desc_EquipEnchant_Effect") .. Lang(listSuit[#listSuit].Name)

		SetImageSprite(self.ImgUseSuitIcon, listSuit[#listSuit].Img .. "_s", self)
	else
		self.TxtSelSuitName.text = _("Desc_EquipEnchant_Effect") .. Lang(listSuit[#listSuit].Name)

		SetImageSprite(self.ImgSelSuitIcon, listSuit[#listSuit].Img .. "_s", self)
	end

	for i = 1, 2 do
		local imgSuit, txtSuit

		if _type == 1 then
			imgSuit = self["ImgUseSuit" .. i]
			txtSuit = self["TxtUseSuit" .. i]
			txtSuit.text = Lang(listSuit[i].Info)
		elseif _type == 2 then
			imgSuit = self["ImgSelSuit" .. i]
			txtSuit = self["TxtSelSuit" .. i]

			if needplay then
				txtSuit.text = ""

				if i == 1 then
					if self.Timer1 then
						TimerMgr.RemoveTimer(self.Timer1)

						self.Timer1 = nil
					end

					EffectMgr:Alloc("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Glow01", self.GoSelEffPoint1, true, 1)

					self.Timer1 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.25, function()
						txtSuit.text = Lang(listSuit[i].Info)
						self.Timer1 = nil
					end, nil)
				elseif i == 2 then
					if self.Timer2 then
						TimerMgr.RemoveTimer(self.Timer2)

						self.Timer2 = nil
					end

					if self.Timer3 then
						TimerMgr.RemoveTimer(self.Timer3)

						self.Timer3 = nil
					end

					local function fun()
						self.Timer2 = nil

						EffectMgr:Alloc("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Glow01_B", self.GoSelEffPoint2, true, 1)

						self.Timer3 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.25, function()
							txtSuit.text = Lang(listSuit[i].Info)
							self.Timer3 = nil
						end, nil)
					end

					self.Timer2 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.3, fun, nil)
				end
			end
		end

		local suitNum = self.infoRole:GetActiveSameSuitSubTypeNum(reelId, self.slotIdx) + 1

		if suitNum >= listSuit[i].Number then
			txtSuit.color = Color.New(0.39215686274509803, 0.39215686274509803, 0.39215686274509803, 1)

			DealWithListRef(self, UIUtil.SetImageGray(imgSuit, 0))
		else
			txtSuit.color = Color.New(0.5882352941176471, 0.5882352941176471, 0.5882352941176471, 1)

			DealWithListRef(self, UIUtil.SetImageGray(imgSuit, 1))
		end
	end
end

function DlgEquipDevelopEnchant:UpdateReelInfo()
	local isSel = self.curReelIdx ~= 0

	GOUtil.SetActive(self.GoAdd, not isSel)
	GOUtil.SetActive(self.GoSelReel, isSel)
	GOUtil.SetActive(self.GoNoSelReel, not isSel)
	GOUtil.SetActive(self.item.UIRootObject, isSel)

	if not isSel then
		self.TxtCostCoin.text = "---"
		self.TxtCostReel.text = _("Desc_Need") .. "：---"

		return
	end

	self.item:UpdateWithNumType(self.infoReel)

	self.TxtReelName.text = Lang(self.infoReel.data.Name)
	self.TxtReelInfo.text = Lang(self.infoReel.data.Info)
	self.TxtCostReel.text = _("Desc_Need") .. "：" .. GetConfigArgFloat("ScrollRankCost")

	local config = GetConfigArgJson("ScrollRankCost")[self.infoReel.data.Quality]

	SetImageSprite(self.ImgCostCoin, ItemManager:Get(config[1]):GetIcon(), self)

	self.TxtCostCoin.text = config[2]
end

function DlgEquipDevelopEnchant:OnClickedCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if self.curReelIdx == index then
		return
	end

	local hideIdx = self.curReelIdx

	self.curReelIdx = index
	self.recordReelIdx = index
	self.infoReel = ItemManager:Get(self.listReelId[index])

	self:UpdateReelSelect(hideIdx)
	self:UpdateWillUseSuit(true)
	RoleRDL.EquipRDL.SubEquipNewEnchant(self.infoReel.id)
	info.Item:UpdateDot()
end

function DlgEquipDevelopEnchant:UpdateReelSelect(hideIdx, updateNum)
	if self.UIScrollTool and self.UIScrollTool.ItemRoot2ItemDict then
		for _, v in self.UIScrollTool.ItemRoot2ItemDict:Enumerator() do
			if v.Item.Index == self.curReelIdx then
				v.Item:UpdateSelectState(true)
			end

			if v.Item.Index == hideIdx then
				v.Item:UpdateSelectState(false)

				if updateNum then
					v.Item:UpdateHoldNum()
				end
			end
		end
	end
end

function DlgEquipDevelopEnchant:OnClickedBtnEnchant()
	if not self.infoReel then
		UIMgr.ShowMsg(_("Desc_ChooseReel"))

		return
	end

	local isEnough = true
	local needNum = GetConfigArgFloat("ScrollRankCost")

	if isEnough then
		local config = GetConfigArgJson("ScrollRankCost")[self.infoReel.data.Quality]

		isEnough = ItemManager:IsItemHoldEnough(config[1], config[2], true)

		if not isEnough then
			local info = ItemManager:Get(config[1])

			UIMgr.ShowMsg(string.format(_("Develop_Cost_Not_Enough"), info:GetName()))

			return
		end
	end

	local function cb(index)
		if index == DlgCommonEvent.ButtonType.Ok then
			self:RequestEquipEnchant()
		elseif index == DlgCommonEvent.ButtonType.OkNoMoreTips then
			self:RequestEquipEnchant()

			EquipmentManager.NotExchangeTipNextTime = true
		end
	end

	if self.infoSlot.scroll ~= 0 then
		local rank1 = ItemManager:Get(self.infoSlot.scroll).data.Quality
		local rank2 = self.infoReel.data.Quality

		if rank2 < rank1 and not EquipmentManager.NotExchangeTipNextTime then
			UIMgr.ShowCommon(DlgCommonEvent.Type.NotPromptNextTime, _("Desc_Alert"), _("Desc_Equip_Enchant_Exchange"), cb, _("UI_confirm"), _("Button_Cancel"), true)
		else
			self:RequestEquipEnchant()
		end
	else
		self:RequestEquipEnchant()
	end
end

function DlgEquipDevelopEnchant:RequestEquipEnchant()
	local roleId = self.infoRole.id
	local slot = self.slotIdx
	local reelId = self.infoReel.id

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			local attr = vMsg.attributes
			local data = {
				infoRole = self.infoRole,
				slotIdx = slot,
				reelId = reelId,
				attr = attr
			}

			UIMgr.AddPanel(DlgEnchant(), data)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestEquipEnchant(roleId, slot, reelId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgEquipDevelopEnchant:OnClickedBtnGetReel()
	EquipmentManager.LastRoleId = self.infoRole.id

	require("UI/Page/PagePass/PageTeamPass")
	UIMgr.SwitchPanel(PageTeamPass)
end

function DlgEquipDevelopEnchant:UpdateEnchantPanel(IsSave)
	self.curReelIdx = 0
	self.infoReel = nil

	self:UpdatePanel()
	self:UpdateReel(true)

	if IsSave then
		Event.Instance:Fire("UpdateEquipAfterDevelop", {
			type = eDevelopType.Enchant
		})
		EffectMgr:Alloc("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_WC", self.UIRootObject, true, 1)

		local function fun()
			self.Timer4 = nil

			EffectMgr:Alloc("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_SW", self.ImgEquipIcon.gameObject, true, 1)
		end

		self.Timer4 = TimerMgr.AddTimer(eTimerType.ScaleTime, 1, fun, nil)
	end
end

function DlgEquipDevelopEnchant:OnClickedGoAdd()
	if self.effHandle then
		EffectMgr:Free(self.effHandle)

		self.effHandle = nil
	end

	self.effHandle = EffectMgr:Alloc("Fx/UI/FX_UI_Welfare/FX_UI_PanelEnchant", self.GoReelList, true, 1)
end

function DlgEquipDevelopEnchant:UpdateNetData()
	self:UpdatePanel()
	self:UpdateReel(true)
end

function DlgEquipDevelopEnchant:GetEnchantRank(slotIndex, reelId, attr)
	if not attr then
		return 0, 1
	end

	local ScrollData = require("luaData/ScrollData")
	local attrPool = {}
	local randomAttr = {}

	for _, v in pairs(ScrollData) do
		if v.Slot == slotIndex and v.ScrollID == reelId then
			attrPool = v.ValueList

			break
		end
	end

	for _, v in ipairs(attrPool) do
		if attr.type == v[2] and attr.param == v[3] then
			randomAttr = v

			break
		end
	end

	local min = randomAttr[#randomAttr - 1]
	local max = randomAttr[#randomAttr]
	local rate = attr.value / max
	local rank = 1
	local average = max / 5

	for i = 1, 5 do
		if attr.value <= i * average then
			rank = i

			break
		end
	end

	return rate, rank
end
