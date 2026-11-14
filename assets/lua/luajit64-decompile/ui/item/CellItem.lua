-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Item/CellItem.lua

require("UI/Item/UIItemBase")

local m_billing_product_pack_ext_info = require("luaData/m_billing_product_pack_ext_info")

CellItem = class("CellItem", UIItemBase)

function CellItem:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellItem:OnEnter()
	local g = self.UIRootObject

	self:Init(g)
	self:AddListener(g, self.OnClicked, EventTriggerType.PointerClick)
	self:AddListener(g, self.OnLongPress, EventTriggerType.PointerLongPress)
end

function CellItem:Init(g)
	self.Animator = GOUtil.GetComponent(g, "Animator")
	self.ItemIcon = GOUtil.FindChildComponent(g, "2/Icon", "Image")
	self.ItemCount = GOUtil.FindChildComponent(g, "2/BgTxt/Text", "Text")
	self.ItemCount.fontSize = 24
	self.ItemName = GOUtil.FindChildComponent(g, "2/Text", "Text")
	self.ItemRank1 = GOUtil.FindChildComponent(g, "2/Rank1", "Image")
	self.ItemRank2 = GOUtil.FindChildComponent(g, "2/Rank2", "Image")
	self.g1 = GOUtil.FindChildGameObject(g, "1")
	self.g2 = GOUtil.FindChildGameObject(g, "2")
	self.gWhipAward = GOUtil.FindChildGameObject(g, "obj_whipAward")

	self.gWhipAward:SetActive(false)

	self.gText = GOUtil.FindChildGameObject(g, "2/BgTxt")
	self.gImgGray = GOUtil.FindChildGameObject(g, "ImgGray")
	self.gImgGeted = GOUtil.FindChildGameObject(g, "ImgGeted")
	self.gImgGeted2 = GOUtil.FindChildGameObject(g, "ImgGeted2")
	self.gImgExtra = GOUtil.FindChildGameObject(g, "2/ImgExtra")
	self.ImgDynamic = GOUtil.FindChildComponent(g, "2/ImgDynamic", "Image")
	self.gImgWhip = GOUtil.FindChildGameObject(g, "2/ImgWhip")
	self.gImgActiveAward = GOUtil.FindChildGameObject(g, "2/ImgActiveAward")
	self.gImgHigh = GOUtil.FindChildGameObject(g, "2/DailyReward")
	self.gImgLimit = GOUtil.FindChildGameObject(g, "2/ImgLimit")
	self.gImgDot = GOUtil.FindChildGameObject(g, "2/ImgDot")
	self.gImgBgNum = GOUtil.FindChildComponent(g, "2/BgTxt", "Image")
	self.gImgFirstPass = GOUtil.FindChildGameObject(g, "2/ImgFirstPass")
	self.gImgStageAward = GOUtil.FindChildGameObject(g, "2/ImgStageAward")
	self.ImgGoldEnemy = GOUtil.FindChildComponent(g, "2/ImgGoldEnemy", "Image")
	self.ImgSeatNum = GOUtil.FindChildComponent(g, "2/ImgSeatNum", "Image")
	self.ImgDouble = GOUtil.FindChildComponent(g, "2/ImgDouble", "Image")
	self.TexGoldEnemy = GOUtil.FindChildComponent(g, "2/ImgGoldEnemy/Text", "Text")
	self.ImgSceneAwardFull = GOUtil.FindChildGameObject(g, "2/ImgSceneAwardFull")
	self.ImgSel = GOUtil.FindChildGameObject(g, "2/ImgSel")
	self.gImgLeftCount = GOUtil.FindChildGameObject(g, "2/ImgLeftCount")
	self.gImgNorBg = GOUtil.FindChildGameObject(g, "2/ImgLeftCount/Normal")
	self.gImgRateBg = GOUtil.FindChildGameObject(g, "2/ImgLeftCount/Rate")
	self.TextLeftCount = GOUtil.FindChildComponent(g, "2/ImgLeftCount/Count", "Text")
	self.TextLeftText = GOUtil.FindChildComponent(g, "2/ImgLeftCount/Text", "Text")
	self.gImgRate = GOUtil.FindChildGameObject(g, "2/ImgRate")
	self.ImgBirth = GOUtil.FindChildComponent(g, "ImgBirth", "Image")
	self.GoImgParty = GOUtil.FindChildGameObject(g, "ImageParty")
	self.noClick = false
	self.needLongPress = false

	for i = 1, 3 do
		self["starGo" .. i] = GOUtil.FindChildGameObject(g, "2/star/" .. i)
	end

	self.gImgDouble = GOUtil.FindChildGameObject(g, "ImgDouble2")
	self.gImgRoleHead = GOUtil.FindChildComponent(g, "2/ImgRoleHead", "Image")
	self.imgRoleHead = GOUtil.FindChildComponent(g, "2/ImgRoleHead/Image/Image", "Image")
	self.GoNotGet = GOUtil.FindChildGameObject(g, "2/ImgNotGet")
	self.RawImage = GOUtil.FindChildComponent(g, "2/RawImage", "RawImage")
end

function CellItem:OnLeave()
	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	UnloadAllImageSprite(self)
	self:RemoveListener(self.UIRootObject, self.OnClicked, EventTriggerType.PointerClick)
	self:RemoveListener(self.UIRootObject, self.OnLongPress, EventTriggerType.PointerLongPress)
end

function CellItem:OnClicked(data)
	if self.info == nil or self.noClick then
		return
	end

	if self.selCardCallback then
		self.selCardCallback(self.page, self.info)
		self.ImgSel:SetActive(true)

		return
	end

	if self.info.data.Type == "I_RAIDBOX" then
		require("UI.Page.PageActivityBossRaid.DlgTreasureBoxtPreview")
		UIMgr.AddPanel(DlgTreasureBoxtPreview(), {
			percent = self.percent
		})

		return
	end

	if self.tipData then
		UIMgr.ShowItemTip(self.info, self.tipData.initPanelIndex, self.tipData.showNum, self.tipData.needFromBtn, self.tipData.callback)
	else
		UIMgr.ShowItemTip(self.info)
	end
end

function CellItem:OnLongPress(data)
	if self.info ~= nil and self.needLongPress == true then
		if data.clickCount == 1 then
			if self.tipData then
				UIMgr.ShowItemTip(self.info, self.tipData.initPanelIndex, self.tipData.showNum, self.tipData.needFromBtn, self.tipData.callback)
			else
				UIMgr.ShowItemTip(self.info)
			end
		else
			UIMgr.HideItemTip()
		end
	end
end

function CellItem:UpdateDataByWhipAward(index, info)
	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.1 * index, function(...)
		if self.Animator ~= nil then
			self.Animator:Play("forward")
		end
	end, {
		1
	})

	self:UpdateWithNumType(info, true)
	self.g1:SetActive(false)
	self.g2:SetActive(false)
	self.gWhipAward:SetActive(true)
end

function CellItem:UpdateData(index, info, isPlay, withoutNum)
	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.1 * index, function(...)
		if self.Animator ~= nil then
			self.Animator:Play("forward")
		end
	end, {
		1
	})

	if not withoutNum then
		self:UpdateWithNumType(info, isPlay)
	else
		self:UpdateNoNumType(info, isPlay)
	end
end

function CellItem:SetSelCardCallback(_page, _cb)
	self.page = _page
	self.selCardCallback = _cb
end

function CellItem:UpdateNoNumType(info, isPlay)
	self.info = nil

	if info == nil or info.data == nil then
		return
	end

	if not isPlay and self.Animator ~= nil then
		self.Animator.enabled = false
	end

	self.info = info

	self:SetItemData(info)
	GOUtil.SetActive(self.g1, false)
	GOUtil.SetActive(self.g2, true)
	GOUtil.SetActive(self.gText, false)
end

function CellItem:UpdateWithNumType(info, isPlay, randomnum)
	self.info = nil

	if info == nil or info.data == nil then
		return
	end

	if not isPlay and self.Animator ~= nil then
		self.Animator.enabled = false
	end

	self.info = info

	self:SetItemData(info)

	local num = NumMagnitudeConversion(info:GetNum())

	if randomnum then
		randomnum = NumMagnitudeConversion(randomnum)

		local str = num .. "~" .. randomnum
		local _, count = string.gsub(str, "[^\x80-\xC1]", "")

		self.ItemCount.text = str

		if count > 6 then
			self.ItemCount.text = num .. "\n~" .. randomnum
		end
	else
		self.ItemCount.text = num
	end

	GOUtil.SetActive(self.g1, false)
	GOUtil.SetActive(self.g2, true)

	local _type = info:GetType()

	if _type == eItemType.RC_RECEIVE or _type == eItemType.R_AVATAR or _type == eItemType.P_AVATAR or _type == eItemType.R_PICTURE then
		GOUtil.SetActive(self.gText, false)
	else
		GOUtil.SetActive(self.gText, true)
	end
end

function CellItem:SetItemData(info)
	ItemManager:SetItemInfo(info, self.ItemIcon, self.ItemRank1, self.ItemRank2, self)

	if self.gImgRoleHead == nil then
		return
	end

	if info:GetType() == eItemType.R_AVATAR or info:GetType() == eItemType.R_FAVOR_EXP then
		if info.roleId and info.roleId > 0 then
			GOUtil.SetActive(self.gImgRoleHead, true)

			local infoRole = RoleMgr:GetRole(info.roleId)

			UIUtil.SetImageSprite(self.imgRoleHead, infoRole.actorData.CharacterIcon, self)
		else
			GOUtil.SetActive(self.gImgRoleHead, false)
		end
	else
		GOUtil.SetActive(self.gImgRoleHead, false)
	end
end

function CellItem:ResetItemIcon(path)
	SetImageSprite(self.ItemIcon, path, self)
end

function CellItem:UpdateWithName(info)
	self:UpdateWithNumType(info)
	GOUtil.SetActive(self.ItemName, false)

	self.gImgBgNum.enabled = false

	if info:GetType() == eItemType.I_SOUL then
		GOUtil.SetActive(self.gText, true)
	end

	self.ItemCount.text = info:GetCurResNum()
end

function CellItem:UpdateNumOnly(num, noColor)
	self.ItemCount.text = num

	if not noColor then
		local strCol = num <= 0 and "FF0000" or "585E62"

		self:UpdateNumColor(strCol)
	end
end

function CellItem:UpdateNumColor(strCol)
	local color = sixNumToRGB(strCol)

	UIUtil.SetGraphicColorRGB(self.ItemCount, color.r / 255, color.g / 255, color.b / 255)
end

function CellItem:SetGray(isGray)
	GOUtil.SetActive(self.gImgGray, isGray)
end

function CellItem:SetGeted(isGeted)
	GOUtil.SetActive(self.gImgGeted, isGeted)
end

function CellItem:SetDot(hasDot)
	GOUtil.SetActive(self.gImgDot, hasDot)
end

function CellItem:SetGetedGreen(isGeted)
	GOUtil.SetActive(self.gImgGeted2, isGeted)
end

function CellItem:SetSignDouble(isDouble)
	GOUtil.SetActive(self.ImgDouble.gameObject, isDouble)
end

function CellItem:SetBirth(isBirth)
	GOUtil.SetActive(self.ImgBirth.gameObject, isBirth)
end

function CellItem:SetIconGray(isGray)
	local gray = TenaryOp(isGray, 1, 0)

	DealWithListRef(self, UIUtil.SetImageGray(self.ItemIcon, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ItemRank1, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ItemRank2, gray))
end

function CellItem:SetExtra(isExtra)
	GOUtil.SetActive(self.gImgExtra, isExtra)
end

function CellItem:SetFree(goodsInfo, itemInfo)
	for k, v in pairs(m_billing_product_pack_ext_info) do
		if v.goods_data_id == goodsInfo.id and v.item_id == itemInfo.id and v.is_paid == "FALSE" then
			local img = GOUtil.FindChildComponent(self.gImgExtra, "", "Image")

			UIUtil.SetImageSprite(img, "UI/PageShop/AtlasShop/ui_icon_jp_omake", self)
			img:SetNativeSize()
			GOUtil.SetActive(self.gImgExtra, true)

			break
		end
	end
end

function CellItem:SetHigh(isHigh)
	if isHigh == nil then
		isHigh = false
	end

	GOUtil.SetActive(self.gImgHigh, isHigh)
end

function CellItem:SetImgDynamic(path)
	UIUtil.SetImageSprite(self.ImgDynamic, path, self)
	self.ImgDynamic:SetNativeSize()
	GOUtil.SetActive(self.ImgDynamic.gameObject, true)
end

function CellItem:SetWhip(isWhip)
	GOUtil.SetActive(self.gImgWhip, isWhip)
end

function CellItem:SetActiveAward(isActiveAward)
	GOUtil.SetActive(self.gImgActiveAward, isActiveAward)
end

function CellItem:SetImgSeatNum(num)
	GOUtil.SetActive(self.ImgSeatNum, true)
	UIUtil.SetImageSprite(self.ImgSeatNum, "UIDyAtlas/ItemRarity/BG_roomline_word_0" .. num, self)
end

function CellItem:SetSceneAwardFull(isFull)
	GOUtil.SetActive(self.ImgSceneAwardFull, isFull)
end

function CellItem:SetStar(level)
	GOUtil.SetActive(self["starGo" .. level], true)
end

function CellItem:SetFirstPass(isFirstPass)
	SetActiveFunc(self.gImgFirstPass, isFirstPass)
end

function CellItem:SetDouble(isDouble)
	GOUtil.SetActive(self.gImgDouble, isDouble)
end

function CellItem:SetGoldEnemy(enemyId, num, IC_tip)
	GOUtil.SetActive(self.ImgGoldEnemy.gameObject, true)

	self.TexGoldEnemy.text = "x" .. num

	UIUtil.SetImageSprite(self.ImgGoldEnemy, IC_tip, self)
end

function CellItem:SetStageAward(isStageAward)
	GOUtil.SetActive(self.gImgStageAward, isStageAward)
end

function CellItem:SetLeftCount(isRate, count, isOpen)
	GOUtil.SetActive(self.gImgLeftCount, isOpen)
	GOUtil.SetActive(self.gImgRate, isRate)
	GOUtil.SetActive(self.gImgRateBg, isOpen and isRate)
	GOUtil.SetActive(self.gImgNorBg, isOpen and not isRate)

	if isOpen then
		self.TextLeftCount.text = count .. _("Desc_count")
		self.TextLeftText.text = _("Activate_ Remain")

		self:SetIconGray(count == 0)
	else
		self:SetIconGray(false)
	end
end

function CellItem:SkipAnimator()
	if self.Animator ~= nil then
		self.Animator:Play("forward")
	end

	self.Animator:Update(1)
	self.Animator:Update(1)
end

function CellItem:SetNotGet()
	local txt = GOUtil.FindChildComponent(self.GoNotGet, "Text", "Text")

	txt.text = Lang(12162)

	GOUtil.SetActive(self.GoNotGet, true)
end

function CellItem:SetEffect(assetRefRawimage, assetRefMaterial)
	GOUtil.SetActive(self.RawImage, true)
	UIUtil.SetRawImageTexture(self.RawImage, assetRefRawimage)
	UIUtil.SetRawImageMaterial(self.RawImage, assetRefMaterial)
end

function CellItem:SetShowImgParty(vbool)
	if vbool == nil then
		vbool = false
	end

	GOUtil.SetActive(self.GoImgParty, vbool)
end
