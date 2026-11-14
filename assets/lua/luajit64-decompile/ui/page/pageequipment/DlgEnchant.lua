-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgEnchant.lua

DlgEnchant = class("DlgEnchant", UIPanel)

function DlgEnchant:ctor()
	DlgEnchant.base.ctor(self, "UI/PanelEquipment/DlgEnchant")
end

function DlgEnchant:Purge()
	self.base.Purge(self)

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)
	end

	InfoSoundEventMgr:OnBack()
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Glow02")
end

function DlgEnchant:OnRegisterEvent()
	self:AddClick(self.BtnEnchant, self.OnClickBtnEnchant)
	self:AddClick(self.BtnSave, self.OnClickBtnSave)
	self:AddClick(self.BtnClose, self.OnClickBtnClose)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
end

function DlgEnchant:OnUnRegisterEvent()
	self:RemoveClick(self.BtnEnchant, self.OnClickBtnEnchant)
	self:RemoveClick(self.BtnSave, self.OnClickBtnSave)
	self:RemoveClick(self.BtnClose, self.OnClickBtnClose)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
end

function DlgEnchant:OnEnter(vParam)
	self:DealWithLocalization()

	self.TxtReelNeed = self:GetChildComponent("Panel/Panel1/Reel/TxtNeed", "Text")

	local goItem = self:GetChildGameObject("Panel/Panel1/Reel/Go/CellItem")

	self.Animator = self:GetChildComponent("Panel/Panel1/Reel/Go", "Animator")
	self.item = CellItem(goItem)

	self.item:InitItemByRoot(goItem)

	self.ImgCostCoin = self:GetChildComponent("Panel/Panel1/Button/Coin/Icon", "Image")
	self.TxtCostCoin = self:GetChildComponent("Panel/Panel1/Button/Coin/Text", "Text")
	self.TextPrompt = self:GetChildComponent("Panel/Panel1/TextPro", "Text")
	self.Panel1 = {}
	self.Panel2 = {}

	for i = 1, 3 do
		self.Panel1["GoAttr" .. i] = self:GetChildGameObject("Panel/Panel1/Attr/" .. i)
		self.Panel1["TxtAdd" .. i] = GOUtil.FindChildComponent(self.Panel1["GoAttr" .. i], "Text", "Text")
		self.Panel1["ImgRank" .. i] = GOUtil.FindChildComponent(self.Panel1["GoAttr" .. i], "Rank", "Image")
		self.Panel1["ImgRankBar" .. i] = GOUtil.FindChildComponent(self.Panel1["GoAttr" .. i], "Bar/Image", "Image")
		self.Panel1["GoLine" .. i] = self:GetChildGameObject("Panel/Panel1/Line/Line" .. i)
		self.Panel2["GoAttr" .. i] = self:GetChildGameObject("Panel/Panel2/Attr/" .. i)
		self.Panel2["TxtAdd" .. i] = GOUtil.FindChildComponent(self.Panel2["GoAttr" .. i], "Text", "Text")
		self.Panel2["ImgRank" .. i] = GOUtil.FindChildComponent(self.Panel2["GoAttr" .. i], "Rank", "Image")
		self.Panel2["ImgRankBar" .. i] = GOUtil.FindChildComponent(self.Panel2["GoAttr" .. i], "Bar/Image", "Image")
		self.Panel2["GoLine" .. i] = self:GetChildGameObject("Panel/Panel2/Line/Line" .. i)
	end

	self.BtnEnchant = self:GetChildGameObject("Panel/Panel1/Button")
	self.BtnSave = self:GetChildGameObject("Panel/Panel2/Button")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.ImgEnchant = GOUtil.GetComponent(self.BtnEnchant, "Image")
	self.ImgSave = GOUtil.GetComponent(self.BtnSave, "Image")
	self.ImgClose = GOUtil.GetComponent(self.BtnClose, "Image")

	self:InitData(vParam)
end

function DlgEnchant:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Panel1/Title/Text", "Text")
	txt.text = Lang(42351)
	txt = self:GetChildComponent("Panel/Panel1/NotAttr/Text", "Text")
	txt.text = Lang(42353)
	txt = self:GetChildComponent("Panel/Panel1/NotSuit/Text", "Text")
	txt.text = Lang(42354)
	txt = self:GetChildComponent("Panel/Panel1/Button/Text", "Text")
	txt.text = _("DlgEnchant_Execute_Again")
	txt = self:GetChildComponent("Panel/Panel2/Title/Text", "Text")
	txt.text = Lang(42352)
	txt = self:GetChildComponent("Panel/Panel2/NotAttr/Text", "Text")
	txt.text = Lang(42353)
	txt = self:GetChildComponent("Panel/Panel2/NotSuit/Text", "Text")
	txt.text = Lang(42354)
	txt = self:GetChildComponent("Panel/Panel2/TPrompt", "Text")
	txt.text = Lang(42355)
	txt = self:GetChildComponent("Panel/Panel2/Button/Text", "Text")
	txt.text = Lang(12248)

	for i = 1, 2 do
		txt = self:GetChildComponent("Panel/Panel1/Suit/" .. i .. "/Text", "Text")
		txt.text = 3 * i .. _("Desc_Piece")
		txt = self:GetChildComponent("Panel/Panel2/Suit/" .. i .. "/Text", "Text")
		txt.text = 3 * i .. _("Desc_Piece")
	end
end

function DlgEnchant:InitData(data)
	self.reelId = data.reelId
	self.slotIdx = data.slotIdx
	self.infoRole = data.infoRole
	self.enchantAttr = data.attr
	self.infoSlot = self.infoRole:GetEquipSlot(self.slotIdx)
	self.infoReel = ItemManager:Get(self.reelId)
	self.isPlaying = nil

	local imgIcon = self:GetChildComponent("Panel/Role/Icon", "Image")
	local imgJob = self:GetChildComponent("Panel/Role/Job", "Image")

	SetImageSprite(imgIcon, self.infoRole.actorData.CharacterIcon, self)
	SetImageSprite(imgJob, "UIDyAtlas/RoleJob/ICO_" .. self.infoRole.data.Job .. "_01_S", self)
	self:UpdatePanel()
end

function DlgEnchant:UpdatePanel()
	self:UpdateStaticCost()
	self:UpdateCostItem()
	self:UpdatePreEnchantInfo()
	self:UpdateCurEnchantInfo()
end

function DlgEnchant:UpdateStaticCost()
	self.item:UpdateWithNumType(self.infoReel)

	self.TxtReelNeed.text = _("Desc_Need") .. "：" .. GetConfigArgFloat("ScrollRankCost")

	local config = GetConfigArgJson("ScrollRankCost")[self.infoReel.data.Quality or 1]
	local coinId = config[1] or 501

	SetImageSprite(self.ImgCostCoin, ItemManager:GetIcon(coinId), self)

	self.TxtCostCoin.text = config[2] or 0
end

function DlgEnchant:UpdateCostItem()
	self.item:UpdateNumOnly(self.infoReel:GetNum(), true)

	local isReelEnough = self.infoReel:GetNum() >= GetConfigArgFloat("ScrollRankCost")

	if not isReelEnough then
		self.TxtReelNeed.color = Color.red
	end

	local config = GetConfigArgJson("ScrollRankCost")[self.infoReel.data.Quality or 1]
	local coinId = config[1] or 501
	local needCoin = config[2] or 0
	local isCoinEnough = ItemManager:IsItemHoldEnough(coinId, needCoin, true)

	if not isCoinEnough then
		self.TxtCostCoin.color = Color.red
	end

	if not isReelEnough then
		self.TextPrompt.text = string.format(_("Develop_Cost_Not_Enough"), self.infoReel:GetName())
	elseif not isCoinEnough then
		self.TextPrompt.text = string.format(_("Develop_Cost_Not_Enough"), ItemManager:Get(coinId):GetName())
	end

	GOUtil.SetActive(self.TextPrompt, not isReelEnough or not isCoinEnough)
end

function DlgEnchant:UpdateEventBtnGray()
	local isEnough = self:CheckCostEnough(true)
	local gray1 = TenaryOp(isEnough and not self.isPlaying, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgEnchant, gray1))

	local gray2 = TenaryOp(not self.isPlaying, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgSave, gray2))
	DealWithListRef(self, UIUtil.SetImageGray(self.ImgClose, gray2))
end

function DlgEnchant:UpdatePreEnchantInfo()
	local GoAttr = self:GetChildGameObject("Panel/Panel1/Attr")
	local GoSuit = self:GetChildGameObject("Panel/Panel1/Suit")
	local GoNotAttr = self:GetChildGameObject("Panel/Panel1/NotAttr")
	local GoNotSuit = self:GetChildGameObject("Panel/Panel1/NotSuit")
	local usedId = self.infoSlot.scroll

	GoAttr:SetActive(usedId ~= 0)
	GoSuit:SetActive(usedId ~= 0)
	GoNotAttr:SetActive(usedId == 0)
	GoNotSuit:SetActive(usedId == 0)

	if not usedId or usedId == 0 then
		return
	end

	self:SetAttribute(self.infoSlot.attributes, usedId, 1)

	local txtSuit = self:GetChildComponent("Panel/Panel1/Suit/Title/Layout/Text", "Text")
	local imgSuit = self:GetChildComponent("Panel/Panel1/Suit/Title/Layout/Icon", "Image")

	self:SetSuitEffect(usedId, txtSuit, imgSuit, 1)
end

function DlgEnchant:UpdateCurEnchantInfo()
	self:SetAttribute(self.enchantAttr, self.reelId, 2)

	local txtSuit = self:GetChildComponent("Panel/Panel2/Suit/Title/Layout/Text", "Text")
	local imgSuit = self:GetChildComponent("Panel/Panel2/Suit/Title/Layout/Icon", "Image")

	self:SetSuitEffect(self.reelId, txtSuit, imgSuit, 2)
end

function DlgEnchant:GetEnchantRank(slotIndex, reelId, attr)
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

function DlgEnchant:SetAttribute(attributes, reelId, stype)
	for i = 1, 3 do
		local strType, strValue, rate, rank = "", 0, 0, 1

		if i <= #attributes then
			strType = _("eAttType_" .. attributes[i].type)
			strValue = TenaryOp(attributes[i].param == 1, attributes[i].value, attributes[i].value / 10 .. "%")
			rate, rank = self:GetEnchantRank(self.slotIdx, reelId, attributes[i])
		end

		if stype == 1 then
			self.Panel1["GoAttr" .. i]:SetActive(i <= #attributes)

			if i <= #attributes then
				self.Panel1["TxtAdd" .. i].text = strType .. "\n+" .. strValue

				SetImageSprite(self.Panel1["ImgRank" .. i], "UI/PanelEquipment/AtlasDlgEnchant/ic_itemup_word_0" .. rank, self)
				SetImageSprite(self.Panel1["ImgRankBar" .. i], "UI/PanelEquipment/AtlasDlgEnchant/fram_equip_" .. rank, self)
				GOUtil.SetTransformLocalScale(self.Panel1["ImgRankBar" .. i].gameObject, rate, 1, 1)
			end
		else
			self.Panel2["GoAttr" .. i]:SetActive(i <= #attributes)

			if i <= #attributes then
				SetImageSprite(self.Panel2["ImgRankBar" .. i], "UI/PanelEquipment/AtlasDlgEnchant/fram_equip_" .. rank, self)
				GOUtil.SetTransformLocalScale(self.Panel2["ImgRankBar" .. i].gameObject, 0, 1, 1)

				local function fun()
					self.Panel2["TxtAdd" .. i].text = strType

					SetImageSprite(self.Panel2["ImgRank" .. i], "UI/PanelEquipment/AtlasDlgEnchant/ic_itemup_word_0" .. rank, self)

					if rank == 5 then
						InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
						InfoSoundEventMgr:Play("VocalCommon10", self.infoRole.data.VocalCommon10)
					end

					local tweener = GOUtil.DOScale(self.Panel2["ImgRankBar" .. i].gameObject.transform, rate, 1)

					local function wrap_cb()
						self.Panel2["TxtAdd" .. i].text = strType .. "\n+" .. strValue

						EffectMgr:Alloc("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Glow02", self.Panel2["TxtAdd" .. i].gameObject, true)
						SoundMgr.Play("Play_SE_020_0031")

						self.isPlaying = false

						self:UpdateEventBtnGray()
					end

					GOUtil.SetTweenerCallback(tweener, wrap_cb)
				end

				self:PlayAnim(self.Panel2["TxtAdd" .. i], self.Panel2["ImgRank" .. i], fun)
			end
		end
	end

	for i = 1, 2 do
		if stype == 1 then
			self.Panel1["GoLine" .. i]:SetActive(i < #attributes)
		else
			self.Panel2["GoLine" .. i]:SetActive(i < #attributes)
		end
	end
end

function DlgEnchant:SetSuitEffect(reelId, txtSuit, suitIcon, stype)
	local scrollType = tonumber(ItemManager:Get(reelId).data.SubType)
	local listSuit = EquipmentManager.GetSuitByScrollType(scrollType)

	if #listSuit == 0 then
		return
	end

	txtSuit.text = _("Desc_EquipEnchant_Effect") .. Lang(listSuit[#listSuit].Name)

	UIUtil.SetImageSprite(suitIcon, listSuit[#listSuit].Img)

	local suitNum = self.infoRole:GetActiveSameSuitSubTypeNum(reelId, self.slotIdx) + 1

	for i = 1, 2 do
		local txtSuitInfo = self:GetChildComponent("Panel/Panel1/Suit/" .. i .. "/Scroll View/Viewport/Txt", "Text")

		if stype == 2 then
			txtSuitInfo = self:GetChildComponent("Panel/Panel2/Suit/" .. i .. "/Scroll View/Viewport/Txt", "Text")
		end

		txtSuitInfo.text = Lang(listSuit[i].Info)

		if suitNum >= listSuit[i].Number then
			txtSuitInfo.color = Color.New(0.39215686274509803, 0.39215686274509803, 0.39215686274509803, 1)
		else
			txtSuitInfo.color = Color.New(0.5882352941176471, 0.5882352941176471, 0.5882352941176471, 1)
		end
	end
end

function DlgEnchant:CheckCostEnough(noEnoughMsg)
	local needReel = GetConfigArgFloat("ScrollRankCost")
	local isEnough = ItemManager:IsItemHoldEnough(self.reelId, needReel, true)

	if isEnough then
		local config = GetConfigArgJson("ScrollRankCost")[self.infoReel.data.Quality]
		local coinId = config[1]
		local needCoin = config[2]

		isEnough = ItemManager:IsItemHoldEnough(coinId, needCoin, true)

		if not isEnough then
			return false, ItemManager:Get(coinId):GetName()
		end
	else
		return false, ItemManager:Get(self.reelId):GetName()
	end

	return true
end

function DlgEnchant:OnClickBtnEnchant()
	if self.isPlaying then
		return
	end

	local isEnough, name = self:CheckCostEnough()

	if not isEnough then
		UIMgr.ShowMsg(string.format(_("Develop_Cost_Not_Enough"), name))

		return
	end

	self.Animator.enabled = true

	self.Animator:Play("Enchant_Item_Scale_Anim", 0, 0)
	self:RequestEquipEnchant()
end

function DlgEnchant:RequestEquipEnchant()
	local roleId = self.infoRole.id
	local slot = self.slotIdx
	local reelId = self.reelId

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			self.enchantAttr = vMsg.attributes

			self:UpdateCostItem()
			self:UpdateCurEnchantInfo()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestEquipEnchant(roleId, slot, reelId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgEnchant:OnClickBtnSave()
	if self.isPlaying then
		return
	end

	local function cb(index)
		if index == DlgCommonEvent.ButtonType.Ok then
			self.save = true

			self:RequestSureEnchant()
		elseif index == DlgCommonEvent.ButtonType.OkNoMoreTips then
			self.save = true

			self:RequestSureEnchant()

			EquipmentManager.NotCoverTipNextTime = true
		end
	end

	if self.infoSlot.scroll ~= 0 and not EquipmentManager.NotCoverTipNextTime then
		UIMgr.ShowCommon(DlgCommonEvent.Type.NotPromptNextTime, _("Desc_Alert"), _("Desc_Equip_Enchant_Cover_1"), cb, _("UI_confirm"), _("Button_Cancel"), true)
	else
		self.save = true

		self:RequestSureEnchant()
	end
end

function DlgEnchant:RequestSureEnchant()
	local stype = self.save and 1 or 2

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			SoundMgr.Play("Play_SE_020_0032")

			if self.save then
				if #self.infoSlot.attributes == 0 then
					RoleRDL.EquipRDL.ResetEquipEnchant(self.infoRole, self.slotIdx)
				end

				self.infoRole:ChangeEquipEnchantScroll(self.slotIdx, self.reelId)
				self.infoRole:ChangeEquipSlotEnchantAttr(self.slotIdx, self.enchantAttr)
				Event.Instance:Fire("UpdateEnchantPanel", true)
			else
				Event.Instance:Fire("UpdateEnchantPanel", false)
			end

			self:Close()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestEquipEnchantResult(self.infoRole.id, self.slotIdx, stype, wrap_cb)
end

function DlgEnchant:OnClickBtnClose()
	if self.isPlaying then
		return
	end

	local function wrap_cb(index)
		if index == 1 then
			self.save = true

			self:RequestSureEnchant()
		elseif index == 2 then
			self.save = false

			self:RequestSureEnchant()
		end
	end

	local msg = ModifyRichTextForTextView(_("Desc_Property_Lost_GiveUp") .. "\n<size=22><color=red>" .. _("Desc_Equip_Enchant_Cover") .. "</color></size>")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg2, _("Tittle_Affirm"), msg, wrap_cb, _("UI_Save"), _("UI_GiveUp"), true)
end

function DlgEnchant:PlayAnim(text, image, callback)
	self.isPlaying = true

	self:UpdateEventBtnGray()

	local dailyTime = 0.1
	local num = 10
	local index = 0

	local function fun()
		index = index + 1

		if index == num then
			if callback then
				callback()
			end
		else
			local scrollData = EquipmentManager.GetScrollData(self.infoReel.id)

			if next(scrollData.AttrType) > 0 then
				local randomNum1 = math.random(table.getn(scrollData.AttrType))

				text.text = _("eAttType_" .. randomNum1)

				local randomNum2 = math.random(5)

				SetImageSprite(image, "UI/PanelEquipment/AtlasDlgEnchant/ic_itemup_word_0" .. randomNum2, self)
			end
		end
	end

	self.Timer = TimerMgr.AddTimer(eTimerType.ScaleTime, dailyTime, fun, self, num)
end

function DlgEnchant:UpdateNetData()
	if self.save then
		self.infoRole:ChangeEquipEnchantScroll(self.slotIdx, self.reelId)
		self.infoRole:ChangeEquipSlotEnchantAttr(self.slotIdx, self.enchantAttr)
		Event.Instance:Fire("UpdateEnchantPanel")
	end
end

function DlgEnchant:OnBackAndroid()
	self:OnClickBtnClose()
end
