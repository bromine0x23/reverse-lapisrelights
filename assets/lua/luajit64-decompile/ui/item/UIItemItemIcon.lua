-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Item/UIItemItemIcon.lua

require("UI/Item/UIItemBase")
require("UI/Dlg/Common/DlgItemDetail")

UIItemItemIcon = class("UIItemItemIcon", UIItemBase)

function UIItemItemIcon:ctor(itemPrefabCache, parent, ownerUI)
	self.id = 0
	self.num = 0
	self.extra = 0
	self.ClickCB = nil
	self.setter = nil
	self.NeedTipClick = true
	self.ScrollView = nil
end

function UIItemItemIcon:OnEnter()
	self.ImageBg = GOUtil.GetComponent(self.UIRootObject, "Image")
	self.Img_Icon = GOUtil.FindChildComponent(self.UIRootObject, "Img_Icon", "Image")
	self.Txt_Num = GOUtil.FindChildComponent(self.UIRootObject, "Txt_Num", "Text")
	self.Txt_Name = GOUtil.FindChildComponent(self.UIRootObject, "Txt_Name", "Text")
	self.ImageRole = GOUtil.FindChildGameObject(self.UIRootObject, "ImageRole")
	self.ImageRoleIcon = GOUtil.FindChildComponent(self.UIRootObject, "ImageRole/Image", "Image")
	self.ImageSkin = GOUtil.FindChildGameObject(self.UIRootObject, "ImageSkin")
	self.ImageSkinIcon = GOUtil.FindChildComponent(self.UIRootObject, "ImageSkin/Image", "Image")
	self.Text3 = GOUtil.FindChildComponent(self.UIRootObject, "Text3", "Text")
	self.ImageJobBg = GOUtil.FindChildComponent(self.UIRootObject, "ImageJobBg", "Image")
	self.ImageJob = GOUtil.FindChildComponent(self.UIRootObject, "ImageJob", "Image")
	self.ImageSkill = GOUtil.FindChildComponent(self.UIRootObject, "ImageSkill", "Image")
	self.ImageAvatar = GOUtil.FindChildComponent(self.UIRootObject, "ImageAvatar", "Image")
	self.ImageLimit = GOUtil.FindChildComponent(self.UIRootObject, "ImageLimit", "Image")
	self.ImageFood = GOUtil.FindChildComponent(self.UIRootObject, "ImageFood", "Image")
	self.ImageExtra = GOUtil.FindChildGameObject(self.UIRootObject, "ImageExtra")
	self.TextExtra = GOUtil.FindChildGameObject(self.UIRootObject, "TextExtra")
	self.ImageNew = GOUtil.FindChildGameObject(self.UIRootObject, "ImageNew")
	self.NeedTipClick = true
end

function UIItemItemIcon:OnLeave()
	self.Img_Icon = nil
	self.Txt_Num = nil
	self.Txt_Name = nil
	self.ImageRole = nil
	self.ImageRoleIcon = nil
	self.ImageBg = nil
	self.Text3 = nil
	self.ImageJob = nil
	self.ImageJobBg = nil
	self.ClickCB = nil
	self.ImageSkill = nil
	self.ImageAvatar = nil
	self.ImageLimit = nil
	self.ScrollViews = nil
	self.ImageExtra = nil
	self.TextExtra = nil
	self.ImageNew = nil

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end
end

function UIItemItemIcon:OnRegisterEvent()
	if not self.NeedTipClick then
		return
	end

	self:AutoRegistClick(self.UIRootObject, self.OnClickRoot)

	if self.ScrollViews ~= nil then
		for i, v in ipairs(self.ScrollViews) do
			local scrollContent = GOUtil.AddComponent(self.UIRootObject, "UIScrollViewContent")

			scrollContent.scrollView = v
		end
	end
end

function UIItemItemIcon:OnUnRegisterEvent()
	return
end

function UIItemItemIcon:OnClickRoot()
	if not self.NeedTipClick then
		return
	end

	if self.ScrollViews ~= nil then
		for i, v in ipairs(self.ScrollViews) do
			v:IsDragging()
		end

		return
	end

	if self.setter then
		DlgItemDetail.Show(self.setter)
	end
end

function UIItemItemIcon:SetClickCB(clickCB)
	self.ClickCB = clickCB
end

function UIItemItemIcon:CreateSetter(itemID, num)
	self.setter.id = self.id
	self.setter.num = self.num
	self.setter.asset = self.asset
end

function UIItemItemIcon:SetScrollView(scrollViews)
	self.ScrollViews = scrollViews
end

function UIItemItemIcon:SetItemOnlyIcon(itemID, num)
	self:SetItem(itemID, num)
	self.Txt_Num.gameObject:SetActive(false)
end

function UIItemItemIcon:SetItem(itemID, nNum, asset)
	self.setter = SetterData()

	self.Text3.gameObject:SetActive(false)
	self.ImageJob.gameObject:SetActive(false)
	self.ImageJobBg.gameObject:SetActive(false)
	self.ImageRole:SetActive(false)
	self.ImageSkin:SetActive(false)
	self.ImageFood.gameObject:SetActive(false)
	self.Img_Icon.gameObject:SetActive(true)

	if asset ~= nil and itemID == 0 then
		local grids

		if asset == protocol_pb.P_POWER then
			grids = DataManager.Instance:GetRecordsArray_Lua("ItemData", function(db)
				return db.Type == eItemType.P_POWER
			end)
		end

		if grids ~= nil and grids.Length > 0 then
			itemID = grids[0].ID
		end
	end

	if asset == protocol_pb.R_AVATAR then
		itemID = 571
	end

	local rId = itemID
	local rNum = nNum

	self.id = itemID
	self.num = nNum
	self.asset = asset

	local infoItem = ItemManager:Get(itemID)
	local imagePath = self:GetItemIconByID(itemID, nNum)
	local type

	if infoItem.data ~= nil then
		type = infoItem.data.Type

		if type == eItemType.EQUIP then
			itemID = nNum
		end
	else
		infoItem = EquipmentManager:GetEquip(itemID)

		if infoItem.data ~= nil then
			type = eItemType.EQUIP
		end
	end

	if not string.isNullOrEmpty(imagePath) then
		UIUtility.SetSprite(self.Img_Icon, imagePath, false)
	end

	UIUtility.SetText(self.Txt_Name, Langcode(infoItem.data.Name))

	local quality = eQualityType.White

	UIUtility.SetSprite(self.ImageBg, GetIconBkByItemType(type, quality), false)

	if type == eItemType.OFFER or type == eItemType.EQUIP then
		self.Txt_Num.gameObject:SetActive(false)

		if type == eItemType.EQUIP then
			self.setter.isEquip = true

			print(itemID)
			self:SetItemEquip(itemID)

			quality = infoItem.data.Quality
			self.id = rNum
		end
	elseif type == eItemType.R_SOUL then
		UIUtility.SetSprite(self.ImageRoleIcon, self:GetItemIconByID(itemID, nNum), false)
		self.ImageRole:SetActive(true)
		self.Img_Icon.gameObject:SetActive(false)
		self.ImageSkin:SetActive(false)
		self.Txt_Num.gameObject:SetActive(true)
		UIUtility.SetText(self.Txt_Num, tostring(nNum))
	elseif type == eItemType.I_SKIN then
		UIUtility.SetSprite(self.ImageSkinIcon, self:GetItemIconByID(itemID, nNum), false)
		self.ImageSkin:SetActive(true)
		self.Img_Icon.gameObject:SetActive(false)
		self.ImageRole:SetActive(false)
		self.Txt_Num.gameObject:SetActive(true)
		UIUtility.SetText(self.Txt_Num, tostring(nNum))
	elseif type == eItemType.I_FAVOR then
		local infoItem = ItemManager:Get(itemID)

		self:SetFavorSign(infoItem)
		self.Txt_Num.gameObject:SetActive(true)
		UIUtility.SetText(self.Txt_Num, tostring(nNum))
	elseif type == eItemType.R_AVATAR then
		local avatarId = nNum

		self.Txt_Num.gameObject:SetActive(false)

		local avatarData = AvatarManager:GetAvatar(avatarId)

		UIUtility.SetSprite(self.Img_Icon, "UIDyAtlas/Cloth/" .. avatarData.data.Icon, false)
	else
		self.Txt_Num.gameObject:SetActive(true)
		UIUtility.SetText(self.Txt_Num, tostring(self.num))
	end

	self:CreateSetter(itemID, nNum)
end

function UIItemItemIcon:SetItemEquip(equipId)
	self.Text3.gameObject:SetActive(true)
	self.ImageJob.gameObject:SetActive(true)
	self.ImageJobBg.gameObject:SetActive(true)

	local infoEquipData = EquipmentManager:GetData(equipId)

	self.Text3.text = GetQualityLevel(infoEquipData.QualityLevel)

	UIUtility.SetSprite(self.ImageBg, GetIconBkByItemType(eItemType.EQUIP, infoEquipData.Quality), false)
	UIUtility.SetSprite(self.ImageJobBg, GetQualityBg2(infoEquipData.Quality), false)
	UIUtility.SetSprite(self.ImageJob, GetJobIcon(infoEquipData.JobType, true), false)
end

function UIItemItemIcon:SetItemWithSetter(setter)
	self.setter = setter

	local id = setter.id

	if setter.asset == protocol_pb.P_SKIN_COIN then
		id = 517
	elseif setter.asset == protocol_pb.P_DIAMOND then
		id = 502

		if setter.from == protocol_pb.PAY_EXTRA then
			self.TextExtra:SetActive(true)
		end
	end

	local num = setter.num

	self.Txt_Num.gameObject:SetActive(false)

	local quality = eQualityType.White

	if setter.asset == protocol_pb.OFFER then
		local workId = setter.extra[1]
		local infoWork = WorkTaskManager:Get(workId)

		icon = "UIDyAtlas/Item/" .. infoWork.data.Icon

		UIUtility.SetSprite(self.Img_Icon, icon, false)
		UIUtility.SetText(self.Txt_Name, infoWork.data.Name:ToLanguage())
	elseif setter.asset == protocol_pb.EQUIP then
		local equipId = setter.extra[1]
		local equipData = EquipmentManager:GetData(equipId)

		icon = "UIDyAtlas/Equipment/" .. equipData.Icon

		UIUtility.SetSprite(self.Img_Icon, icon, false)
		UIUtility.SetText(self.Txt_Name, equipData.Name)
		self:SetItemEquip(equipId)

		quality = equipData.Quality
	elseif setter.asset == protocol_pb.R_SOUL then
		local infoItem = ItemManager:Get(id)

		UIUtility.SetSprite(self.ImageRoleIcon, self:GetItemIconByID(id, num), false)
		self.ImageRole:SetActive(true)
		self.Img_Icon.gameObject:SetActive(false)
		self.ImageSkin:SetActive(false)
		UIUtility.SetText(self.Txt_Name, Langcode(infoItem.data.Name))
		self.Txt_Num.gameObject:SetActive(true)
		UIUtility.SetText(self.Txt_Num, tostring(num))
	elseif setter.asset == protocol_pb.I_SKIN then
		local infoItem = ItemManager:Get(id)

		UIUtility.SetSprite(self.ImageSkinIcon, self:GetItemIconByID(id, num), false)
		self.ImageSkin:SetActive(true)
		self.Img_Icon.gameObject:SetActive(false)
		self.ImageRole:SetActive(false)
		UIUtility.SetText(self.Txt_Name, Langcode(infoItem.data.Name))
		self.Txt_Num.gameObject:SetActive(true)
		UIUtility.SetText(self.Txt_Num, tostring(num))
	elseif setter.asset == protocol_pb.I_FAVOR then
		local infoItem = ItemManager:Get(id)

		self:SetFavorSign(infoItem)
		UIUtility.SetSprite(self.Img_Icon, self:GetItemIconByID(id, num), false)
		UIUtility.SetText(self.Txt_Name, Langcode(infoItem.data.Name))
		self.Txt_Num.gameObject:SetActive(true)
		UIUtility.SetText(self.Txt_Num, tostring(num))
	else
		local infoItem = ItemManager:Get(id)

		UIUtility.SetSprite(self.Img_Icon, self:GetItemIconByID(id, num), false)
		UIUtility.SetText(self.Txt_Name, Langcode(infoItem.data.Name))
		self.Txt_Num.gameObject:SetActive(true)
		UIUtility.SetText(self.Txt_Num, tostring(num))
	end

	UIUtility.SetSprite(self.ImageBg, GetIconBkByAssetType(setter.asset, quality), false)
end

function UIItemItemIcon:SetFavorSign(infoItem)
	self.ImageFood.gameObject:SetActive(true)

	local strPath = ""

	if infoItem.data.SubType == tostring(eFavorItemType.Dessert) then
		strPath = "ui_icon_gift_xd01"
	elseif infoItem.data.SubType == tostring(eFavorItemType.Sweets) then
		strPath = "ui_icon_gift_sp01"
	elseif infoItem.data.SubType == tostring(eFavorItemType.IceCream) then
		strPath = "ui_icon_gift_ly01"
	elseif infoItem.data.SubType == tostring(eFavorItemType.Toy) then
		strPath = "ui_icon_gift_wj01"
	elseif infoItem.data.SubType == tostring(eFavorItemType.Cosmetic) then
		strPath = "ui_icon_gift_hzp01"
	end

	UIUtility.SetSprite(self.ImageFood, "UIDyAtlas/Food/" .. strPath, false)
end

function UIItemItemIcon:GetItemIconByID(itemID, num)
	if itemID <= 0 then
		return nil
	end

	self.id = itemID
	self.num = num

	local infoItem = ItemManager:Get(itemID)
	local type

	if infoItem.data ~= nil then
		type = infoItem.data.Type
	else
		infoItem = EquipmentManager:GetEquip(itemID)

		if infoItem.data ~= nil then
			type = eItemType.EQUIP
		end
	end

	local icon = ""

	if type == tostring(eItemType.I_GEM) or type == tostring(eItemType.I_GEM_CHIP) then
		icon = "UIDyAtlas/Gem/" .. infoItem.data.Icon
	elseif type == tostring(eItemType.I_EXP) then
		icon = "UIDyAtlas/Item/" .. infoItem.data.Icon
	elseif type == tostring(eItemType.R_SOUL) then
		icon = PATH_CHAR_HEAD .. infoItem.data.Icon
	elseif type == tostring(eItemType.OFFER) then
		local infoWork = WorkTaskManager:Get(num)

		if infoWork.data ~= nil then
			icon = "UIDyAtlas/Item/" .. infoWork.data.Icon
		end
	elseif type == tostring(eItemType.I_FAVOR) then
		icon = "UIDyAtlas/Food/" .. infoItem.data.Icon
	elseif type == tostring(eItemType.I_SKIN) then
		icon = "UIDyAtlas/CharacterCard/Head/" .. infoItem.data.Icon
	elseif type == tostring(eItemType.EQUIP) then
		local infoEquipData = EquipmentManager:GetData(num)

		icon = "UIDyAtlas/Equipment/" .. infoEquipData.Icon
	elseif type == tostring(eItemType.REPUTATION) then
		icon = "UIDyAtlas/Icon/" .. infoItem.data.Icon
		self.num = 1
	elseif type == tostring(eItemType.P_POWER) then
		icon = "UIDyAtlas/Icon/" .. infoItem.data.Icon
	elseif type == tostring(eItemType.R_SOUL_AVATAR) then
		icon = "UIDyAtlas/Cloth/Cloth/" .. infoItem.data.Icon
	elseif infoItem.data ~= nil then
		icon = "UIDyAtlas/Icon/" .. infoItem.data.Icon
	end

	return icon
end

function UIItemItemIcon:SetNickIcon(icon, time, isBig)
	self:SetLimitTimeIcon(time)

	local strIcon = ""

	if isBig then
		strIcon = icon .. "2"
	else
		strIcon = icon .. "1"
	end

	UIUtility.SetSprite(self.Img_Icon, "UIDyAtlas/Icon/" .. strIcon, false)
	UIUtility.SetSprite(self.ImageBg, GetIconBkByItemType(eItemType.P_MAX, eQualityType.White), false)
end

function UIItemItemIcon:SetRoleIcon(roleId)
	self.setter = SetterData()
	self.setter.id = roleId
	self.setter.isRole = true

	local infoChar = CharacterMgr:GetCharacter(roleId)

	if infoChar ~= nil then
		UIUtility.SetSprite(self.Img_Icon, PATH_CHAR_HEAD .. infoChar:GetCharacterHeadIcon(), false)
	end

	UIUtility.SetSprite(self.ImageBg, "UIDyAtlas/ItemBk/ui_bg_itembox_r04", false)
end

function UIItemItemIcon:SetSkillIcon(talentId, endTime, startTime)
	self.setter = SetterData()
	self.setter.id = talentId
	self.setter.startTime = startTime
	self.setter.endTime = endTime
	self.setter.isTalent = true

	self:SetLimitTimeIcon(endTime)

	local talentData = GetTalentData(talentId)

	if talentData ~= nil then
		UIUtility.SetSprite(self.Img_Icon, "UIDyAtlas/Talent/" .. talentData.Icon, false)
		self.ImageSkill.gameObject:SetActive(true)
	end

	UIUtility.SetSprite(self.ImageBg, "UIDyAtlas/ItemBk/ui_bg_itembox_r05", false)
end

function UIItemItemIcon:SetAvatarIcon(avatarId, endTime, startTime)
	self.setter = SetterData()
	self.setter.id = avatarId
	self.setter.startTime = startTime
	self.setter.endTime = endTime
	self.setter.isAvatar = true

	self:SetLimitTimeIcon(endTime)

	local avatarData = AvatarManager:GetAvatar(avatarId)

	if avatarData ~= nil then
		UIUtility.SetSprite(self.Img_Icon, "UIDyAtlas/Cloth/" .. avatarData.data.Icon, false)
		self.ImageAvatar.gameObject:SetActive(true)
	end

	UIUtility.SetSprite(self.ImageBg, GetIconBkByItemType(eItemType.AVATAR, eQualityType.White), false)
end

function UIItemItemIcon:SetSwimSuitChipIcon(nAvatarID)
	local avatarData = AvatarManager:GetAvatar(nAvatarID)

	if avatarData ~= nil then
		UIUtility.SetSprite(self.Img_Icon, "UIDyAtlas/Cloth/" .. avatarData.data.Icon, false)
	end

	UIUtility.SetSprite(self.ImageBg, GetIconBkByItemType(eItemType.R_SOUL_AVATAR), false)
end

function UIItemItemIcon:SetLimitTimeIcon(time)
	if time == "" or time == nil then
		self.ImageLimit.gameObject:SetActive(false)
	else
		self.ImageLimit.gameObject:SetActive(true)
	end
end

function UIItemItemIcon:ShowAni(targetPos, wrap_cb)
	local gt = self.UIRootObject.transform
	local defaultPos = gt.localPosition + Vector3(100, -200, 0)

	DG.Tweening.ShortcutExtensions.DOLocalJump(gt, defaultPos, 150, 2, 1.5, false)

	self.timer = TimerMgr.AddTimer(1.5, function()
		if gt == nil then
			return
		end

		local t2 = DG.Tweening.ShortcutExtensions.DOLocalMove(gt, targetPos, 0.6, false)

		UIUtility.DOFade(GOUtil.GetComponent(self.UIRootObject, "Image"), 0, 0.8, nil)
		UIUtility.DOFade(self.Img_Icon, 0, 0.8, nil)
		UIUtility.DOFade(self.Txt_Num, 0, 0.8, nil)
		UIUtility.DOFade(self.Txt_Name, 0, 0.8, nil)
		UIUtility.SetTweenerCallback(t2, function(...)
			GameObject.Destroy(self.UIRootObject)
		end)

		local infoItem = ItemManager:Get(self.id)

		if infoItem.data ~= nil and infoItem.data.Type == eItemType.OFFER then
			local data2 = {}

			data2.id = self.num
			data2.callback = wrap_cb

			CreateDlgInScene(DlgExploreGetWorkTask(), data2)
		elseif wrap_cb then
			wrap_cb()
		end
	end)
end

function UIItemItemIcon:SetNumSize(size)
	self.Txt_Num.fontSize = size
end

function UIItemItemIcon:SetSize(vector)
	UIUtility.SetRTSize(self.UIRootObject:GetComponent("RectTransform"), vector)
end

function UIItemItemIcon:SetPos(pos)
	UIUtility.SetGameObjRTPos(self.UIRootObject, pos.x, pos.y)
end

function UIItemItemIcon:SetScale(vector)
	UIUtility.SetTransScale(self.UIRootObject:GetComponent("RectTransform"), vector)
end

function UIItemItemIcon:OnClickIcon()
	if self.ClickCB ~= nil then
		self.ClickCB(self.Index, self.id)
	end
end

function UIItemItemIcon:SetRaycastTargetEnable(bEnable)
	local img = GOUtil.GetComponent(self.UIRootObject, "Image")

	if img == nil then
		return
	end

	img.raycastTarget = bEnable
end

function UIItemItemIcon:SetNumVisible(bVisible)
	UIUtility.SetComponentVisible(self.Txt_Num, bVisible)
end

function UIItemItemIcon:SetName(strName)
	UIUtility.SetText(self.Txt_Name, strName)
end

function UIItemItemIcon:SetIcon(strIcon)
	UIUtility.SetSprite(self.Img_Icon, strIcon, false)
end

function UIItemItemIcon:SetNameVisible(bVisible)
	UIUtility.SetComponentVisible(self.Txt_Name, bVisible)
end

function UIItemItemIcon:SetNameColor(vColor)
	UIUtility.SetGraphicColor(self.Txt_Name, vColor)
end

function UIItemItemIcon:SetNameOutlineColor(vColor)
	if self.Txt_Name == nil then
		return
	end

	local outline = GOUtil.GetComponent(self.Txt_Name.gameObject, "Outline")

	UIUtility.SetOutlineColor(outline, vColor)
end
