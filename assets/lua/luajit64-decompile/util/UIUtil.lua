-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/UIUtil.lua

function GetJobIcon(jobType, isSmall)
	local strJobIcon = ""

	if jobType == tostring(eJobType.Singer) then
		strJobIcon = "UIDyAtlas/Icon/ui_icon_singer_01"
	elseif jobType == tostring(eJobType.Dancer) then
		strJobIcon = "UIDyAtlas/Icon/ui_icon_dancer_01"
	elseif jobType == tostring(eJobType.Artist) then
		strJobIcon = "UIDyAtlas/Icon/ui_icon_actress_01"
	elseif jobType == tostring(eJobType.Speaker) then
		strJobIcon = "UIDyAtlas/Icon/ui_icon_mc_01"
	elseif jobType == tostring(eJobType.Model) then
		strJobIcon = "UIDyAtlas/Icon/ui_icon_model_01"
	end

	if isSmall then
		strJobIcon = strJobIcon .. "s"
	end

	return strJobIcon
end

function GetItemIcon(type, id)
	local infoItem = ItemManager:Get(id)

	if infoItem == nil then
		return ""
	end

	if type == eItemType.R_SOUL_AVATAR then
		return "UIDyAtlas/Cloth/Cloth/" .. infoItem.data.Icon
	else
		return infoItem.data.Icon
	end
end

function GetItemIconNamePostfix(bigType)
	local postfix = ""

	if bigType == "Small" then
		postfix = "_s"
	elseif bigType == "Middle" then
		postfix = "_mid"
	end

	return postfix
end

function GetItemIconByID(itemID, bigType)
	local infoItem = ItemManager:Get(itemID)

	if infoItem == nil then
		return ""
	end

	local icon = ""
	local type = infoItem:GetType()

	if type == eItemType.R_SOUL_AVATAR then
		icon = "UIDyAtlas/Cloth/Cloth/" .. infoItem.data.Icon
	elseif type == eItemType.I_SOUL or type == eItemType.I_ACTIVE_DRAW then
		icon = infoItem.data.Icon
	elseif type == eItemType.I_AVATAR then
		icon = "UIDyAtlas/Item/" .. infoItem.data.Icon
	else
		icon = "UIDyAtlas/Icon/" .. infoItem.data.Icon
	end

	return icon
end

function GetQualityLevel(level)
	local str = ""

	if level == 0 then
		-- block empty
	else
		str = "+" .. level
	end

	return str
end

function GetQualityBg(type)
	local i = EnumUtil.ToInt("eQualityType", tostring(type))
	local str = "UIDyAtlas/ItemBk/ui_bg_itembox_lv" .. i + 1

	return str
end

function GetQualityBg2(type)
	local i = EnumUtil.ToInt("eQualityType", tostring(type))
	local str = "UIDyAtlas/ItemBk/ui_bg_itembox_b" .. i

	return str
end

function GetEffectRoot()
	local Root = GameObject.Find("EffectRoot")

	if Root == nil then
		Root = GOUtil.NewGameObject("EffectRoot", nil)
	end

	return Root
end

function GetSceneRoot()
	return GameObject.Find("SCENE_ROOT")
end

function CreateEffect(root, path)
	return MxFxMgr.Instance:Alloc(PATH_EFFECT .. path, root, true)
end

function CreateFXEffect(root, path)
	return MxFxMgr.Instance:Alloc(PATH_FX .. path, root, true)
end

function GetTeamIcon(teamID, isBig)
	local strIcon = ""

	if teamID == 1 then
		strIcon = "UIDyAtlas/Icon/ui_icon_rank_sii0"
	elseif teamID == 2 then
		strIcon = "UIDyAtlas/Icon/ui_icon_rank_nii0"
	elseif teamID == 3 then
		strIcon = "UIDyAtlas/Icon/ui_icon_rank_hii0"
	elseif teamID == 4 then
		strIcon = "UIDyAtlas/Icon/ui_icon_rank_x0"
	elseif teamID == 5 then
		strIcon = "UIDyAtlas/Icon/ui_icon_rank_xii0"
	end

	if isBig then
		strIcon = strIcon .. "1"
	else
		strIcon = strIcon .. "2"
	end

	return strIcon
end

function GetTeamBgIcon(teamID)
	local strIcon = ""

	if teamID == 1 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_sii03"
	elseif teamID == 2 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_nii03"
	elseif teamID == 3 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_hii03"
	elseif teamID == 4 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_x03"
	elseif teamID == 5 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_xii03"
	end

	return strIcon
end

function GetRoleBgByTeam(teamID)
	local strIcon = ""

	if teamID == 1 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_sii01r"
	elseif teamID == 2 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_nii01r"
	elseif teamID == 3 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_hii01r"
	elseif teamID == 4 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_x01r"
	elseif teamID == 5 then
		strIcon = "UIDyAtlas/Vote/ui_btn_rank_xii01r"
	end

	return strIcon
end

function GetTimeTampByString(str)
	local a1 = string.split(str, " ")

	if #a1 == 2 then
		local day = string.split(a1[1], "-")
		local time = string.split(a1[2], ":")

		if #day == 3 and #time == 3 then
			local yearT = tonumber(day[1])
			local monthT = tonumber(day[2])
			local dayT = tonumber(day[3])
			local hourT = tonumber(time[1])
			local minT = tonumber(time[2])
			local secT = tonumber(time[3])
			local t = os.time({
				year = yearT,
				month = monthT,
				day = dayT,
				hour = hourT,
				min = minT,
				sec = secT
			})

			return t
		end
	end

	return 0
end

function GetTimeByString(str)
	local a1 = string.split(str, " ")

	if #a1 == 2 then
		local day = string.split(a1[1], "-")
		local time = string.split(a1[2], ":")

		if #day == 3 and #time == 3 then
			local yearT = tonumber(day[1])
			local monthT = tonumber(day[2])
			local dayT = tonumber(day[3])
			local hourT = tonumber(time[1])
			local minT = tonumber(time[2])
			local secT = tonumber(time[3])

			return yearT, monthT, dayT
		end
	end

	return 0
end

function GetTimeTampAccurateToDay(str)
	local a1 = string.split(str, " ")

	if #a1 == 2 then
		local day = string.split(a1[1], "-")
		local time = string.split(a1[2], ":")

		if #day == 3 and #time == 3 then
			local yearT = tonumber(day[1])
			local monthT = tonumber(day[2])
			local dayT = tonumber(day[3])
			local hourT = tonumber(time[1])
			local minT = tonumber(time[2])
			local secT = tonumber(time[3])

			return os.time({
				hour = 0,
				min = 0,
				sec = 0,
				year = yearT,
				month = monthT,
				day = dayT
			})
		end
	end

	return 0
end

function GetTimeFormatBySecond(second, str)
	local d, v = math.modf(second / 86400)
	local h, v = math.modf(second / 3600)
	local y = second % 3600
	local m, v = math.modf(y / 60)
	local s = second % 60

	s = Mathf.Round(s)
	s = s % 60

	if str == "hour" then
		return string.format("%02d:%02d:%02d", h, m, s)
	elseif str == "minute" then
		if h > 0 then
			return string.format("%02d:%02d", h, m)
		else
			return string.format("%02d:%02d", m, s)
		end
	elseif str == "second" then
		return s
	elseif str == "day" then
		local dT = _("Desc_day")
		local hT = _("Desc_hour")
		local mT = _("Desc_minute")
		local sT = _("Desc_second")

		h = h - d * 24

		return string.format("%02d" .. dT .. "%02d" .. hT .. "%02d" .. mT .. "%02d" .. sT, d, h, m, s)
	elseif str == "DAY" then
		h = h - d * 24

		return string.format("%02d:%02d", d, h)
	else
		return second
	end
end

function GetTimeFormat(second)
	local duration = ""
	local days = math.floor(second / 86400)
	local hours = math.floor(second % 86400 / 3600)
	local minutes = math.floor(second % 86400 % 3600 / 60)
	local seconds = math.floor(second % 86400 % 3600 % 60)

	if days > 0 then
		duration = days .. _("Desc_day") .. hours .. _("Desc_hour")
	elseif hours > 0 then
		duration = hours .. _("Desc_hour") .. minutes .. _("Desc_minute")
	elseif minutes > 0 then
		duration = minutes .. _("Desc_minute") .. seconds .. _("Desc_second")
	elseif seconds >= 0 then
		duration = seconds .. _("Desc_second")
	end

	return duration
end

function GetTimeLimitByMinute(minute)
	local hour = Mathf.Floor(minute / DateUtil.MinutesPerHour)
	local minute = minute - hour * DateUtil.MinutesPerHour
	local str = ""

	if hour > 0 then
		if minute > 0 then
			str = table.concat({
				hour,
				_("Desc_hour"),
				minute,
				_("Desc_minute")
			})
		else
			str = table.concat({
				hour,
				_("Desc_hour")
			})
		end
	else
		str = table.concat({
			minute,
			_("Desc_minute")
		})
	end

	return str
end

function GetStrDisTime(second)
	local d, h, m, s = GetTimeFormatBySec(second)

	if d >= 1 then
		strTime = string.format("%d日%d時間", d, h)
	elseif d < 1 and h >= 1 then
		strTime = string.format("%d時間%d分", h, m)
	elseif h < 1 and m >= 1 then
		strTime = string.format("%d分%d秒", m, s)
	elseif m < 1 and s >= 1 then
		strTime = string.format("%d秒", s)
	else
		strTime = ""
	end

	return strTime
end

function GetLogoutTimeFormat(second)
	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local disTime = curTime - second
	local str = ""

	if disTime < 86400 then
		if disTime > 3600 then
			local hour = math.floor(disTime / 3600)

			str = string.format(_("Desc_Hours_Ago"), hour)
		else
			local minute = math.floor(disTime / 60)

			if minute == 0 then
				str = _("Desc_Just_Ago")
			else
				str = string.format(_("Desc_Minutes_Ago"), minute)
			end
		end
	else
		local day = math.floor(disTime / 86400)

		if day > 7 then
			day = 7
		end

		str = string.format(_("Desc_Days_Ago"), day)
	end

	return str
end

function PlayReturnBtnMove(returnBtnGo, duration)
	if returnBtnGo == nil then
		return
	end

	local moveComp = GOUtil.AddComponent(returnBtnGo, "UIMoveByAxis")

	moveComp:SetParam(-55, 58, duration, UIMoveByAxis.MoveAxis.X)
end

function PurgePage(_page)
	if _page == nil then
		return
	end

	if _page:IsShow() then
		_page:Close()
	end

	_page:Purge()
end

function CloseDlgUI(dlg)
	if dlg ~= nil and dlg:IsShow() then
		dlg:Close()
	end
end

function ClearDlgMemory(dlg, donotClearMemory)
	if dlg ~= nil then
		dlg:Purge()

		if not donotClearMemory then
			Launcher:ClearMemory()
		end
	end
end

function GetReputationById(id)
	if id ~= nil and id > 0 then
		local infoData = ReputationManager:Get(id)
		local data = infoData.data

		if data ~= nil then
			local showName = false
			local bgPath

			if data.BGIcon == nil or data.BGIcon == "" then
				bgPath = "UIDyAtlas/Item/ui_bg_icon_ch0" .. data.Quality
				showName = true
			else
				bgPath = "UIDyAtlas/Item/" .. data.BGIcon
			end

			local name = data.Name:ToLanguage()

			return bgPath, name, showName
		end
	end

	return nil, nil, nil
end

function GetReputationEffectById(id, parent)
	if id ~= nil and id > 0 then
		local data = DataManager.Instance:GetRecord_Lua("Reputation", id)

		if data ~= nil then
			local effFxBase

			if data.Quality <= 3 then
				effFxBase = MxFxMgr.Instance:Alloc(PATH_FX .. "Eff_UI_Pvp/Eff_UI_Pvp_Ch01_1", parent, true)
			elseif data.Quality == 4 then
				effFxBase = MxFxMgr.Instance:Alloc(PATH_FX .. "Eff_UI_Pvp/Eff_UI_Pvp_Ch01_2", parent, true)
			elseif data.Quality == 5 then
				effFxBase = MxFxMgr.Instance:Alloc(PATH_FX .. "Eff_UI_Pvp/Eff_UI_Pvp_Ch01_3", parent, true)
			end

			return effFxBase
		end
	end

	return nil
end

function GetItemNameID(itemID)
	local name = ""
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

	name = infoItem.data.Name:ToLanguage()

	return name
end

function GetItemMeasureWord(itemID)
	local infoItem = ItemManager:Get(itemID)

	if infoItem == nil then
		return ""
	end

	return GetItemMeasureWordByItemType(infoItem.data.Type)
end

function GetItemMeasureWordByItemType(itemType)
	if itemType == eItemType.P_GOLD or itemType == eItemType.P_DIAMOND or itemType == eItemType.P_FRIEND_COIN or itemType == eItemType.P_PVP_COIN or itemType == eItemType.I_GEM or itemType == eItemType.I_GEM_CHIP then
		return Localization.Get("MeasureWord_Ge")
	elseif itemType == eItemType.P_POWER or itemType == eItemType.P_EXPECT or itemType == eItemType.P_LEVEL_EXP or itemType == eItemType.P_VIP_EXP or itemType == eItemType.R_LEVEL_EXP or itemType == eItemType.R_STAR_EXP then
		return Localization.Get("MeasureWord_Dian")
	elseif itemType == eItemType.P_LIVE_TICKET or itemType == eItemType.P_SUPPORT_TICKET or itemType == eItemType.P_PVP_TICKET or itemType == eItemType.P_SIGN_TICKET or itemType == eItemType.P_THEME_TICKET or itemType == eItemType.P_MAIN_TICKET then
		return Localization.Get("MeasureWord_Zhang")
	end

	return ""
end

function GetIconBkByItemType(itemType, qualityType)
	local bkPath = ""

	if itemType == tostring(eItemType.EQUIP) then
		local index = EnumUtil.ToInt("eQualityType", tostring(qualityType))

		bkPath = "UIDyAtlas/ItemBk/ui_bg_itembox_lv" .. index + 1
	else
		bkPath = itemType == tostring(eItemType.AVATAR) and "UIDyAtlas/ItemBk/ui_bg_itembox_r02" or itemType == tostring(eItemType.I_FAVOR) and "UIDyAtlas/ItemBk/ui_bg_itembox_r03" or (itemType == tostring(eItemType.P_DIAMOND) or itemType == tostring(eItemType.P_LIVE_TICKET) or itemType == tostring(eItemType.P_SUPPORT_TICKET) or itemType == tostring(eItemType.P_PVP_TICKET) or itemType == tostring(eItemType.P_SIGN_TICKET) or itemType == tostring(eItemType.P_THEME_TICKET)) and "UIDyAtlas/ItemBk/ui_bg_itembox_r01b" or itemType == tostring(eItemType.R_SOUL_AVATAR) and "UIDyAtlas/ItemBk/ui_item_avatarpatch_01" or "UIDyAtlas/ItemBk/ui_bg_itembox_r01"
	end

	return bkPath
end

function GetIconBkByAssetType(assetType, qualityType)
	local bkPath = ""

	if assetType == protocol_pb.EQUIP then
		if qualityType ~= nil and type(qualityType) ~= "number" then
			qualityType = qualityType:GetHashCode() + 1
		end

		bkPath = "UIDyAtlas/ItemBk/ui_bg_itembox_lv" .. qualityType
	else
		bkPath = assetType == protocol_pb.AVATAR and "UIDyAtlas/ItemBk/ui_bg_itembox_r02" or assetType == protocol_pb.I_FAVOR and "UIDyAtlas/ItemBk/ui_bg_itembox_r03" or (assetType == protocol_pb.P_DIAMOND or assetType == protocol_pb.P_LIVE_TICKET or assetType == protocol_pb.P_SUPPORT_TICKET or assetType == protocol_pb.P_PVP_TICKET or assetType == protocol_pb.P_SIGN_TICKET or assetType == protocol_pb.P_THEME_TICKET) and "UIDyAtlas/ItemBk/ui_bg_itembox_r01b" or itemType == protocol_pb.R_SOUL_AVATAR and "UIDyAtlas/ItemBk/ui_item_avatarpatch_01" or "UIDyAtlas/ItemBk/ui_bg_itembox_r01"
	end

	return bkPath
end

function GetIconBkByID(id)
	local infoItem = ItemManager:Get(id)
	local quality, itemType

	if infoItem.data ~= nil then
		itemType = infoItem.data.Type
		quality = infoItem.data.Quality
	else
		infoItem = EquipmentManager:GetEquip(itemID)

		if infoItem.data ~= nil then
			itemType = eItemType.EQUIP
			quality = infoItem.data.Quality
		end
	end

	if quality == nil or itemType == nil then
		PrintWithColor("GetIconBkByID ID[%d] is not exist!", "yellow", id)

		return ""
	end

	return GetIconBkByItemType(itemType, quality)
end

function SetGrayMaterial(transformP, state)
	return
end

function OnClickedRightArrow(ScrollView)
	local contentTrans = ScrollView.transform:GetChild(0)
	local gridLayout = contentTrans:GetComponent("GridLayoutGroup")
	local oneLength = gridLayout.cellSize.x + gridLayout.spacing.x
	local totalLength = contentTrans.childCount * oneLength
	local contentAnchoredP = contentTrans.anchoredPosition

	if contentAnchoredP.x - oneLength > -totalLength then
		ScrollView:SetContentPos(Vector2.New(contentAnchoredP.x - oneLength, contentAnchoredP.y), 0.1, nil)
	end
end

function OnClickedLeftArrow(ScrollView)
	local contentTrans = ScrollView.transform:GetChild(0)
	local gridLayout = contentTrans:GetComponent("GridLayoutGroup")
	local oneLength = gridLayout.cellSize.x + gridLayout.spacing.x
	local contentAnchoredP = contentTrans.anchoredPosition

	if contentAnchoredP.x < 0 then
		ScrollView:SetContentPos(Vector2.New(contentAnchoredP.x + oneLength, contentAnchoredP.y), 0.1, nil)
	end
end

function GetContentPos(scrollView, count, index, positionCenter)
	local gridLayout = GOUtil.GetComponent(scrollView.content.gameObject, "GridLayoutGroup")
	local rect = 0
	local padd, size, space = 0, 0, 0

	if scrollView.horizontal then
		rect = GOUtil.GetRectTransformWidth(scrollView.content.gameObject)
		padd = gridLayout.padding.left
		size = gridLayout.cellSize.x
		space = gridLayout.spacing.x
	else
		rect = GOUtil.GetRectTransformHeight(scrollView.content.gameObject)
		padd = gridLayout.padding.top
		size = gridLayout.cellSize.y
		space = gridLayout.spacing.y
	end

	local csize = padd + size * count + space * (count - 1)

	csize = csize < rect and rect or csize
	index = index or 1

	local cp, vp = 0, 0

	if positionCenter then
		cp = padd + size * index + space * (index - 1) - size / 2
		vp = rect / 2
	else
		cp = padd + size * index + space * (index - 1)
		vp = rect
	end

	local pos = 0

	if vp < cp and vp < csize - cp then
		pos = -(cp - vp)
	elseif vp >= csize - cp then
		pos = -(csize - rect)
	end

	return pos
end

function GetContentPosUGUIScroll(scrollView, count, index, positionCenter)
	local gridLayout = GOUtil.GetComponent(scrollView.content.gameObject, "GridLayoutGroup")
	local rect = 0
	local padd, size, space = 0, 0, 0

	if scrollView.horizontal then
		rect = GOUtil.GetRectTransformWidth(scrollView.gameObject)
		padd = gridLayout.padding.left
		size = gridLayout.cellSize.x
		space = gridLayout.spacing.x
	else
		rect = GOUtil.GetRectTransformHeight(scrollView.gameObject)
		padd = gridLayout.padding.top
		size = gridLayout.cellSize.y
		space = gridLayout.spacing.y
	end

	local csize = padd + size * count + space * (count - 1)

	csize = csize < rect and rect or csize
	index = index or 1

	local cp, vp = 0, 0

	if positionCenter then
		cp = padd + size * index + space * (index - 1) - size / 2
		vp = rect / 2
	else
		cp = padd + size * index + space * (index - 1)
		vp = rect
	end

	local pos = 0

	if vp < cp and vp < csize - cp then
		pos = -(cp - vp)
	elseif vp >= csize - cp then
		pos = -(csize - rect)
	end

	return pos
end

function SplitByParam(stringP, p1, p2, p3)
	local tableP = {}
	local aS = string.split(stringP, p1)

	for i = 1, #aS do
		if p2 ~= nil then
			local bS = string.split(aS[i], p2)

			for j = 1, #bS do
				if p3 ~= nil then
					local cS = string.split(bS[j], p3)

					for k = 1, #cS do
						table.insert(tableP, cS[k])
					end
				else
					table.insert(tableP, bS[j])
				end
			end
		else
			table.insert(tableP, aS[i])
		end
	end

	return tableP
end

function getColorFromString(str, alpha)
	local c = sixNumToRGB(str)

	return Color.New(c.r / 255, c.g / 255, c.b / 255, alpha or 1)
end

function sixNumToRGB(str_num, OutLine)
	local str_num_six

	if string.len(str_num) == 6 then
		str_num_six = str_num
	else
		str_num_six = string.sub(str_num, 1, 7)
	end

	local RGB = {}

	RGB.r = tonumber(string.sub(str_num_six, 1, 2), 16)
	RGB.g = tonumber(string.sub(str_num_six, 3, 4), 16)
	RGB.b = tonumber(string.sub(str_num_six, 5, 6), 16)

	if OutLine then
		RGB.a = OutLine
	end

	return RGB
end

function SetImageSprite(img, path, panel, isNative)
	local ref
	local native = isNative or false

	if type(panel) == "boolean" then
		if path ~= "" then
			ref = UIUtilSetImageSprite(img, path, panel)
		end
	elseif path ~= "" then
		ref = UIUtilSetImageSprite(img, path, native)

		DealWithListRef(panel, ref)
	end

	return ref
end

function SetImageOverrideSprite(img, path, panel, isNative)
	local ref
	local native = isNative or false

	if type(panel) == "boolean" then
		if path ~= "" then
			ref = UIUtilSetImageOverrideSprite(img, path, panel)
		end
	elseif path ~= "" then
		ref = UIUtilSetImageOverrideSprite(img, path, native)

		DealWithListRef(panel, ref)
	end

	return ref
end

function SetRawImageTexture(rawImg, path, panel, isNative)
	local ref
	local native = isNative or false

	if type(panel) == "boolean" then
		ref = UIUtilSetRawImageTexture(rawImg, path, panel)
	else
		ref = UIUtilSetRawImageTexture(rawImg, path, native)

		DealWithListRef(panel, ref)
	end

	return ref
end

function DealWithListRef(panel, ref)
	if panel and ref then
		panel.listRef = panel.listRef or {}

		table.insert(panel.listRef, ref)
	end
end

function UnloadAllImageSprite(panel)
	if panel.listRef then
		for _, v in pairs(panel.listRef) do
			ResourceMgr.Unload(v)
		end

		panel.listRef = nil
	end

	if panel.listSpineRef then
		for _, v in ipairs(panel.listSpineRef) do
			ResourceMgr.Unload(v)
		end

		panel.listSpineRef = nil
	end
end

function DealWithListSpineRef(panel, ref, limitNum)
	if panel and ref then
		panel.listSpineRef = panel.listSpineRef or {}

		if limitNum and limitNum < #panel.listSpineRef + 1 then
			ResourceMgr.Unload(panel.listSpineRef[1])
			table.remove(panel.listSpineRef, 1)
		end

		table.insert(panel.listSpineRef, ref)
	end
end

function IsIphoneX()
	if Screen.width == 2436 and Screen.height == 1125 then
		return true
	end

	if Screen.width == 2160 and Screen.height == 1080 then
		return true
	end

	return false
end

function DealWithSafeArea(RectTransformComponent)
	local r = Screen.safeArea
	local anchorMin = r.position
	local anchorMax = r.position + r.size

	anchorMin.x = anchorMin.x / Screen.width * 1.1
	anchorMin.y = TenaryOp(anchorMin.y / Screen.height < 0.03, anchorMin.y / Screen.height, 0.03)
	anchorMax.x = anchorMax.x / Screen.width * 0.99
	anchorMax.y = TenaryOp(anchorMax.y / Screen.height < 0, anchorMax.y / Screen.height, 1)
	RectTransformComponent.anchorMin = anchorMin
	RectTransformComponent.anchorMax = anchorMax
end

function SafeArea(gameObject)
	if not IsNil(gameObject) then
		local RectTransformComponent = GOUtil.GetComponent(gameObject, "RectTransform")

		if RectTransformComponent then
			local r = Screen.safeArea
			local anchorMin = r.position
			local anchorMax = r.position + r.size

			anchorMin.x = TenaryOp(anchorMin.x / Screen.width < 0.06, anchorMin.x / Screen.width, 0.06)
			anchorMin.y = TenaryOp(anchorMin.y / Screen.height < 0.01, anchorMin.y / Screen.height, 0.01)
			anchorMax.x = TenaryOp(anchorMax.x / Screen.width > 0.945, anchorMax.x / Screen.width, 0.945)
			anchorMax.y = TenaryOp(anchorMax.y / Screen.height < 0, anchorMax.y / Screen.height, 1)
			RectTransformComponent.anchorMin = anchorMin
			RectTransformComponent.anchorMax = anchorMax
		end
	end
end

function SceneArea(gameObject)
	if Application.isEditor == false then
		local RectTransformComponent = GOUtil.GetComponent(gameObject, "RectTransform")

		if RectTransformComponent then
			local anchorMin = Vector2.New(0, 0)
			local anchorMax = Vector2.New(1, 1)

			anchorMin.x = 0
			anchorMin.y = 0
			anchorMax.x = 1
			anchorMax.y = 1
			RectTransformComponent.anchorMin = anchorMin
			RectTransformComponent.anchorMax = anchorMax
		end
	end
end

local _LocaleText = require("luaData/_LocaleText")

function Langcode(id)
	return id
end

function CheckNoAsset(curGold, curDiamond, cb)
	if curGold > PlayerInst:GetGold() or curDiamond > PlayerInst:GetDiamond() then
		local function OnCallback(index)
			if index == DlgCommonEvent.ButtonType.Ok then
				cb(1)
			else
				cb(0)
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("UI_Buy"), _("Goto_Store"), OnCallback, _("UI_Go"), nil, true)

		return true
	end

	return false
end

function CheckPayDiamond(price, content, callBack, default)
	if default ~= nil then
		default()
	end
end

function CheckDiamond(id, need, drawNum, cb)
	local infoItem = ItemManager:Get(id)
	local type = infoItem:GetType()
	local isNoEnough = false

	if type == eItemType.P_DIAMOND_PAY then
		if need > PlayerInst:GetDiamondPay() then
			isNoEnough = true
		else
			cb(1)
		end
	elseif type == eItemType.P_DIAMOND then
		if need > PlayerInst:GetDiamondAll() then
			isNoEnough = true
		else
			cb(1)
		end
	elseif need > infoItem:GetCurResNum() then
		cb(2)

		return
	else
		cb(1)

		return
	end

	if isNoEnough then
		cb(2)
	end
end

function ShowNextChain(duration, cb)
	TimerMgr.AddTimer(eTimerType.RealTime, duration, function()
		cb()
	end, {})
end

function ReplaceDiamond(costNum, callBack, noMsg)
	local hold = PlayerInst:GetDiamond()
	local holdAll = PlayerInst:GetDiamondAll()

	if hold < costNum and costNum <= holdAll then
		local str = string.format(_("Desc_Diamaond_Replace_By_Pay_Diamaond"), hold, costNum - hold)

		UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Desc_Alert"), str, callBack, _("UI_confirm"), nil, true)
	else
		if noMsg then
			return
		end

		local item = ItemManager:GetItemByType("P_DIAMOND")

		UIMgr.ShowMsg(string.format(Lang(12390), Lang(item.data.Name)))
	end
end

function NumMagnitudeConversion(number, n)
	local mag = GetConfigArgInt("MagnitudeAssetNumber")

	if mag <= number then
		number = GetPreciseDecimal(number / mag, n or 1)

		return number .. _("Desc_Magnitude")
	end

	return tostring(number)
end

function NumMillionMagnitudeConversion(number, n)
	if type(number) ~= "number" then
		return number
	end

	if number >= 100000000 then
		number = GetPreciseDecimal(number / 10000, 0)

		return number .. _("Desc_Magnitude")
	elseif number >= 1000000 then
		number = GetPreciseDecimal(number / 10000, n or 1)

		return number .. _("Desc_Magnitude")
	end

	return tostring(number)
end

local strColor1 = "#585E62"
local strColor2 = "#01B34C"
local strColor3 = "red"

function GetItemShowStrNum(need, hold, hideHold)
	need = need or 0
	hold = hold or 0

	local colNeed, colHold = strColor1, strColor2

	if hold < need then
		if hideHold then
			colNeed = strColor3
		else
			colHold = strColor3
		end
	end

	local strVal = "<color=" .. colNeed .. ">" .. need .. "</color>"

	if not hideHold then
		strVal = strVal .. "/<color=" .. colHold .. ">" .. hold .. "</color>"
	end

	return strVal
end

function GetItemShowStrNum2(need, hold)
	need = need or 0
	hold = hold or 0

	local colNeed, colHold = strColor1, strColor2

	if hold < need then
		colHold = strColor3
	end

	return "<color=" .. colHold .. ">" .. hold .. "</color>/<color=" .. colNeed .. ">" .. need .. "</color>"
end

function HorizontalToVertical(text)
	return text:gsub("ー", "Ｉ")
end

function GetItemEmojiStr(itemId)
	if itemId == 510 then
		return "[0]"
	elseif itemId == 502 then
		return "[1]"
	elseif itemId == 513 then
		return "[2]"
	elseif itemId == 501 then
		return "[3]"
	elseif itemId == 503 then
		return "[4]"
	elseif itemId == 511 then
		return "[5]"
	elseif itemId == 1051 then
		return "[6]"
	elseif itemId == 516 then
		return "[7]"
	elseif itemId == 536 then
		return "[14]"
	elseif itemId == 1054 then
		return "[15]"
	elseif itemId == 543 or itemId == 77770024 then
		return "[16]"
	elseif itemId == 20000 then
		return "[17]"
	elseif itemId == 77770056 then
		return "[8]"
	end

	return itemId
end

function SetActiveFunc(go, vbool)
	if go == nil then
		return
	end

	if vbool == nil then
		vbool = false
	end

	GOUtil.SetActive(go, vbool)
end

function SetActiveWithState(page, key, vbool, isComponent)
	if page.listState == nil then
		page.listState = {}
	end

	if IsNil(page[key]) then
		return
	end

	if vbool == nil then
		vbool = false
	end

	if page.listState[key] == nil then
		page.listState[key] = false
	end

	if page.listState[key] ~= vbool then
		GOUtil.SetActive(page[key], TenaryOp(vbool, 1, 0))

		page.listState[key] = vbool
	end
end

function GetSortCharacterTeam(list)
	local type

	for _, v in pairsByKeys(list) do
		if v.data and v.data.TeamOrder and v.listRole then
			type = 1
		elseif v.TeamOrder then
			type = 2
		end
	end

	if type == 1 then
		local function func(a, b)
			if a.data.TeamOrder == b.data.TeamOrder then
				return a.data.ID < b.data.ID
			else
				return a.data.TeamOrder < b.data.TeamOrder
			end
		end

		table.sort(list, func)

		local StandOrderList = {}

		for k, v in pairsByKeys(list) do
			StandOrderList[k] = {}

			for k2, infoRole in pairsByKeys(v.listRole) do
				StandOrderList[k][k2] = {}
			end

			for k2, infoRole in pairsByKeys(v.listRole) do
				StandOrderList[k][infoRole.data.StandOrder] = infoRole.data.ID
			end
		end

		for k, v in pairsByKeys(list) do
			v.data.MemberList = StandOrderList[k]
		end
	elseif type == 2 then
		local CombData = require("luaData/CharacterTeam")
		local Character = require("luaData/CharacterRole")
		local StandOrderList = {}

		for k, v in pairsByKeys(CombData) do
			StandOrderList[k] = {}

			for k2, MemberID2 in pairsByKeys(v.MemberList) do
				StandOrderList[k][k2] = MemberID2
			end

			for k3, MemberID3 in pairsByKeys(v.MemberList) do
				for k2, infoRole in pairsByKeys(Character) do
					if infoRole.ID == MemberID3 then
						StandOrderList[k][infoRole.StandOrder] = infoRole.ID

						break
					end
				end
			end
		end

		for k, v in pairsByKeys(CombData) do
			v.MemberList = StandOrderList[k]
		end

		list = CombData
	end

	return list
end

function CheckTime(_time)
	if _time and Time.realtimeSinceStartup - _time < 2 then
		UIMgr.ShowMsg(_("Desc_NoMoreFxxkingClick"))

		return false
	end

	return true
end

function NetManagerTimeDownToLocal(str, timeStr)
	if #timeStr == 1 then
		local timeStrList = string.split(timeStr[1], ":")
		local time = timeStrList[1] * 3600 + timeStrList[2] * 60 + timeStrList[3]
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		time = curServerTime + time

		PersistentStoreUtil.SetString(str, time)
	elseif #timeStr == 2 then
		local time = timeStr[1] * 3600 + timeStr[2] * 60
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		time = curServerTime + time

		PersistentStoreUtil.SetString(str, time)
	end
end

function LocalTimeDownNetManagerShow(str, type)
	local time = PersistentStoreUtil.GetString(str)

	if time == "" then
		return false
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	time = time - curServerTime

	if type == 1 then
		local d, v = math.modf(time / 86400)
		local h, v = math.modf(time / 3600)
		local y = time % 3600
		local m, v = math.modf(y / 60)
		local s = time % 60

		str = string.gsub(_(str), "{0}", string.format("%02d:%02d:%02d", h, m, s))

		if time > 0 then
			UIMgr.ShowMsg(str)
		end

		return time > 0
	elseif type == 2 then
		local d, v = math.modf(time / 86400)
		local h, v = math.modf(time / 3600)
		local y = time % 3600
		local m, v = math.modf(y / 60)
		local s = time % 60

		str = string.gsub(_(str), "{0}", h)
		str = string.gsub(_(str), "{1}", m)

		if time > 0 then
			UIMgr.ShowMsg(str)
		end

		return time > 0
	end
end

function ModifyRichTextForTextView(richText)
	local t = {}

	for v in string.gmatch(richText, "(<.-=.->)") do
		table.insert(t, v)
	end

	for _, v in ipairs(t) do
		local str = string.match(v, "=(.-)>")
		local newStr = string.gsub(v, str, "\"" .. str .. "\"")

		richText = string.gsub(richText, v, newStr)
	end

	return richText
end
