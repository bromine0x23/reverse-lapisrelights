-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTheme/CellTheme.lua

require("UI/Item/UIItemBase")

CellTheme = class("CellTheme", UIItemBase)

function CellTheme:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTheme:OnEnter(vParam)
	local g = self.UIRootObject
	local textLock = GOUtil.FindChildComponent(g, "Panel/Lock/Button/Text", "Text")

	textLock.text = _("UI_GoUnLock")

	local textBuy = GOUtil.FindChildComponent(g, "Panel/LockBuy/Button/Text", "Text")

	textBuy.text = _("UI_Celltheme_Buy")

	local textDown = GOUtil.FindChildComponent(g, "Panel/ButtonDown/Text", "Text")

	textDown.text = _("UI_Download")

	local textChange = GOUtil.FindChildComponent(g, "Panel/ButtonChange/Text", "Text")

	textChange.text = _("Desc_SetThemeScene")
	self.seatNoFull = self:GetChildComponent("Panel/btn_item/img_stop/Text", "Transform")

	local Text = self:GetChildComponent("Panel/btn_item/img_stop/Text", "Text")

	Text.text = _("Desc_SeatNoFull")
	Text = self:GetChildComponent("Panel/btn_item/tex_full", "Text")
	Text.text = _("Desc_SeatFullReward")
	Text = self:GetChildComponent("Panel/btn_details/Text", "Text")
	Text.text = _("Desc_ThemeInfo")
	Text = self:GetChildComponent("Panel/ButtonPvw/Text", "Text")
	Text.text = _("Desc_ThemePreview")
	self.Bg = self:GetChildComponent("Bg", "Image")
	self.Icon = GOUtil.FindChildComponent(g, "Image", "Image")
	self.panel = GOUtil.FindChildGameObject(g, "Panel")
	self.new = GOUtil.FindChildGameObject(g, "Panel/New")
	self.lock = GOUtil.FindChildGameObject(g, "Panel/Lock")
	self.lockBuy = GOUtil.FindChildGameObject(g, "Panel/LockBuy")
	self.btnDown = GOUtil.FindChildGameObject(g, "Panel/ButtonDown")
	self.btnChange = GOUtil.FindChildGameObject(g, "Panel/ButtonChange")
	self.btnBuy = GOUtil.FindChildGameObject(g, "Panel/LockBuy/Button")
	self.btnGoUnlock = GOUtil.FindChildGameObject(g, "Panel/Lock/Button")
	self.btnPvw = GOUtil.FindChildGameObject(g, "Panel/ButtonPvw")
	self.TextUnlock = GOUtil.FindChildComponent(g, "Panel/Lock/Info/Text", "Text")
	self.TextNum = GOUtil.FindChildComponent(g, "Panel/LockBuy/Button/TextNum", "Text")
	self.ImageBuyIcon = GOUtil.FindChildComponent(g, "Panel/LockBuy/Button/ImageIcon", "Image")
	self.TextPreson = GOUtil.FindChildComponent(g, "Panel/tex_preson", "Text")
	self.ImgPreson = self:GetChildComponent("Panel/Img_preson/Image", "Image")
	self.img_lock = self:GetChildGameObject("Panel/img_lock")
	self.img_name = self:GetChildComponent("Panel/img_name", "Image")
	self.img_num = self:GetChildComponent("Panel/img_name/img_num", "Image")
	self.img_unstate = self:GetChildGameObject("Panel/img_state/img_unstate")
	self.img_instate = self:GetChildGameObject("Panel/img_state/img_instate")
	self.img_state = self:GetChildComponent("Panel/img_state", "Image")
	self.item_icon = self:GetChildComponent("Panel/btn_item/icon", "Image")
	self.btn_item_lock = self:GetChildGameObject("Panel/btn_item/tex_lock")
	self.tex_go_full = self:GetChildGameObject("Panel/btn_item/tex_full")
	self.btn_item_bg = self:GetChildGameObject("Panel/btn_item/bg")
	self.go_group = self:GetChildGameObject("Panel/go_group")
	self.btn_item = self:GetChildGameObject("Panel/btn_item")
	self.btn_details = self:GetChildGameObject("Panel/btn_details")
	self.fx_full = self:GetChildGameObject("Panel/btn_item/fx_full")
	self.Index = self:GetChildComponent("Panel/Index", "Text")
	self.tex_time = self:GetChildComponent("Panel/btn_item/bg/tex_time", "Text")
	self.bar = self:GetChildComponent("Panel/btn_item/bg/bar", "Image")
	self.tex_num = self:GetChildGameObject("Panel/btn_item/tex_num")
	self.goItem = self:GetChildGameObject("Panel/goItem")

	for i = 1, 3 do
		local goCell = GOUtil.Instantiate(self.goItem, self.go_group)

		SetActiveFunc(goCell, true)

		goCell.name = "item" .. i
	end

	SetActiveFunc(self.goItem, false)

	for i = 1, 3 do
		self["ItemBg" .. i] = self:GetChildComponent("Panel/go_group/item" .. i .. "/show/ImageBg", "Image")
		self["ItemIcon" .. i] = self:GetChildComponent("Panel/go_group/item" .. i .. "/show/ImageIcon", "Image")
		self["ItemTex" .. i] = self:GetChildComponent("Panel/go_group/item" .. i .. "/show/ImageName/Text", "Text")
		self["ItemShow" .. i] = self:GetChildGameObject("Panel/go_group/item" .. i .. "/show")
		self["BtnItem" .. i] = self:GetChildGameObject("Panel/go_group/item" .. i)
		self["text_heart" .. i] = self:GetChildComponent("Panel/go_group/item" .. i .. "/show/ImageHeart/text_heart", "Text")

		self:AddClick(self["BtnItem" .. i], self.OnClickedBtnItem)
	end

	self.img_stop = self:GetChildGameObject("Panel/btn_item/img_stop")

	self:AddClick(self.btnDown, self.OnClickedDown)
	self:AddClick(self.btnChange, self.OnClickedChange)
	self:AddClick(self.btnBuy, self.OnClickedBuy)
	self:AddClick(self.btnGoUnlock, self.OnClickedGoUnlock)
	self:AddClick(self.btnPvw, self.OnClickedPvw)
	self:AddClick(self.btn_item, self.OnClickedGetAward)
	self:AddClick(self.btn_details, self.OnClickedDetails)
	Event.Instance:Add("EventChangeScene", self.EventChangeScene, self)
end

function CellTheme:OnLeave()
	self:RemoveClick(self.btnDown, self.OnClickedDown)
	self:RemoveClick(self.btnChange, self.OnClickedChange)
	self:RemoveClick(self.btnBuy, self.OnClickedBuy)
	self:RemoveClick(self.btnGoUnlock, self.OnClickedGoUnlock)
	self:RemoveClick(self.btnPvw, self.OnClickedPvw)
	self:RemoveClick(self.btn_details, self.OnClickedDetails)
	self:RemoveClick(self.btn_item, self.OnClickedGetAward)

	for i = 1, 3 do
		self:RemoveClick(self["BtnItem" .. i], self.OnClickedBtnItem)
	end

	Event.Instance:Remove("EventChangeScene", self.EventChangeScene, self)
	UnloadAllImageSprite(self)
end

function CellTheme:OnClickedDown()
	return
end

function CellTheme:OnClickedBuy()
	local function OnCallback(index)
		if index == 1 then
			-- block empty
		end
	end

	local info = self.info
	local cost = info.data.Cost
	local strIcon = ItemManager:GetIcon(cost[1])
	local num = cost[2]
	local strAlert = _("Desc_Alert")

	local function fun(type)
		if type == DlgCommonEvent.ButtonType.Ok then
			if cost[2] > ItemManager:GetItemCount(cost[1]) then
				local function OnCallback(index)
					if index == DlgCommonEvent.ButtonType.Ok then
						require("UI/Page/PageShop/PageShop")

						local infoItem = ItemManager:Get(cost[1])
						local fromWhere = infoItem.data.FromWhere
						local data = {
							tabMainIndex = fromWhere[1][2],
							tagIndex = fromWhere[1][3]
						}

						PageShop.InitNetData(data)
					end
				end

				UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("UI_Buy"), _("Desc_ClothesTickets_Not_Enough_Goto_Buy"), OnCallback, _("UI_Go"), nil, true)
			else
				self:RequestBuyTheme()
			end
		else
			self.fobiden = false
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.MsgWithAlert, _("Desc_Alert"), {
		content = string.format(_("Desc_BuyNewScene"), cost[2], info:GetName()),
		alert = string.format(_("Desc_HaveItemNum"), ItemManager:GetItemCount(cost[1]))
	}, fun, _("UI_Buy"))
end

function CellTheme:OnClickedGetAward()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			-- block empty
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestGetThemeAward(self.info.id, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function CellTheme:UpdateTime()
	if self.info.pb.surplus then
		if self.info.pb.surplus ~= 0 then
			local max = ThemeManager:GetMaxInfoThemeSec(self.info)
			local strTime = DateUtil.GetMomentHour00(max - self.info.pb.surplus)

			self.tex_time.text = strTime
			self.bar.fillAmount = self.info.pb.surplus / max

			if self.bar.fillAmount > 1 then
				self.bar.fillAmount = 1
			end

			if ThemeManager.surplus[self.info.id] == 0 and self.info.pb.surplus == max and not self.btn_item_lock.activeSelf then
				self:Update(self.info, self.isSel)
			end
		end

		self:GetChildComponent("Panel/btn_item/tex_num", "Text").text = "×" .. ThemeManager:GetInfoThemeCount(self.info)
	end
end

function CellTheme:RequestBuyTheme()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self.info = ThemeManager:Get(self.info.id)

			self:Update(self.info, true)
			Event.Instance:Fire("UpdatePageThemeDot")
			UIMgr.ShowMsg(_("Shop_success"))
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestBuyTheme(self.info.id, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function CellTheme:EventChangeScene()
	PersistentStoreUtil.SetInt(ePSKey.SceneId, self.info.id)
	SceneMgr.LoadScene("MainStage", {
		from = 6
	})
end

function CellTheme:OnClickedChange()
	local function wrap_cb(index2)
		if index2 == 1 then
			if self.SeatIndex ~= 3 then
				local function wrap_cb(index3)
					if index3 == 1 then
						local function OnCallback(index4)
							if index4 == 1 then
								ThemeManager.SelectedID = 0

								InfoBGMEventMgr:Clear()
								PersistentStoreUtil.SetInt(ePSKey.SceneId, self.info.id)
								InfoGameInst:SetCurrentTheme(self.info.id)
								SceneMgr.LoadScene("MainStage", {
									from = 6
								})
							end
						end

						self:RequestSetThemePosition(self.info.pb.seats, 1, OnCallback)
					end
				end

				local strTitle = _("Desc_Alert")
				local strOkText = _("UI_OK")
				local strCancelText = _("Quite_Cancel")
				local msg = _("Desc_SetMainSceneVerify")

				UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, msg, wrap_cb, strOkText, strCancelText)
			else
				local function OnCallback(index4)
					if index4 == 1 then
						ThemeManager.SelectedID = 0

						InfoBGMEventMgr:Clear()
						PersistentStoreUtil.SetInt(ePSKey.SceneId, self.info.id)
						InfoGameInst:SetCurrentTheme(self.info.id)
						SceneMgr.LoadScene("MainStage", {
							from = 6
						})
					end
				end

				self:RequestSetThemePosition(self.info.pb.seats, 1, OnCallback)
			end
		end
	end

	local strTitle = _("Desc_Alert")
	local strOkText = _("UI_OK")
	local strCancelText = _("Quite_Cancel")
	local msg = _("Desc_SetMainTheme")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, msg, wrap_cb, strOkText, strCancelText)
end

function CellTheme:RequestSetThemePosition(listSeat, type, callback)
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			callback(1)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			callback(0)
		end
	end

	NetManager:RequestSetThemePosition(self.info.id, listSeat, type, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function CellTheme:OnClickedPvw()
	ThemeManager.SelectedIsSave = 1
	ThemeManager.SceneTypeID = PersistentStoreUtil.GetInt(ePSKey.SceneId)

	if ThemeManager.SceneTypeID ~= self.info.id then
		InfoBGMEventMgr:Clear()
		PersistentStoreUtil.SetInt(ePSKey.SceneId, self.info.id)
		SceneMgr.LoadScene("MainStage", {
			from = 7
		})
	else
		ThemeManager.TypeID = 2

		InfoBGMEventMgr:Clear()
		require("UI/Page/PageTheme/PageSeat")
		UIMgr.SwitchPanel(PageSeat, 1)
	end
end

function CellTheme:OnClickedGoUnlock()
	require("UI/Page/PageChapter/PageChapter")
	UIMgr.SwitchPanel(PageChapter, 1)

	do return end

	local info = self.info
	local UnlockLevel = info.data.UnlockLevel
	local UnlockStage = info.data.UnlockStage

	local function OnCallback(index)
		if index == 1 then
			require("UI/Page/PageChapter/PageChapter")
			UIMgr.SwitchPanel(PageChapter, 1)
		end
	end

	local str = ""

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Go_Get"), str, OnCallback, _("UI_Go"))
end

function CellTheme:Update(info, isSel, isUIAlbum)
	local SeatIndex = 0
	local SeatCount = info.data.SeatCount

	for i = 1, info.data.SeatCount do
		if info.geted then
			local id = info.pb.seats[i]

			if id ~= 0 then
				SetActiveFunc(self["ItemShow" .. i], true)

				local infoRole = RoleMgr:GetRole(id)
				local listTeamData = RoleMgr:GetTeamList()
				local teamId = infoRole.data.Team
				local teamBgPath = listTeamData[teamId].BGIcon

				UIUtil.SetImageSprite(self["ItemIcon" .. i], infoRole.actorData.CharacterIcon, self)
				UIUtil.SetImageSprite(self["ItemBg" .. i], teamBgPath, self)

				self["ItemTex" .. i].text = infoRole:GetName()
				self["text_heart" .. i].text = infoRole.curFavorLevel
				SeatIndex = SeatIndex + 1
			else
				SetActiveFunc(self["ItemShow" .. i], false)
			end
		end
	end

	self.SeatIndex = SeatIndex

	GOUtil.SetRectTransformAnchoredPosition(self.item_icon.gameObject, 0, 30)
	SetActiveFunc(self.tex_num, true)
	SetActiveFunc(self.btn_item_lock, false)
	SetActiveFunc(self.fx_full, false)
	SetActiveFunc(self.tex_go_full, false)
	SetActiveFunc(self.img_stop, SeatIndex ~= 3)

	if isUIAlbum then
		SetActiveFunc(self.btn_details, isSel)
		SetActiveFunc(self.btnPvw, isSel)
	end

	if SeatIndex == 3 then
		self.bar.color = Color.New(1, 1, 1, 1)
	else
		self.bar.color = Color.New(1, 1, 1, 0.6)
	end

	if info.pb.surplus then
		SetActiveFunc(self.btn_item_bg, info.pb.surplus ~= ThemeManager:GetMaxInfoThemeSec(info))
		SetActiveFunc(self.btn_item_lock, info.pb.surplus == ThemeManager:GetMaxInfoThemeSec(info))
		SetActiveFunc(self.fx_full, info.pb.surplus == ThemeManager:GetMaxInfoThemeSec(info))
	else
		SetActiveFunc(self.btn_item_bg, false)
	end

	SetActiveFunc(self:GetChildGameObject("dot"), false)

	self.info = info
	self.isSel = isSel

	self:UpdateTime()

	local colorStr = TenaryOp(SeatIndex == 0, string.format("<color=#e22a2a>%s</color>/%s", SeatIndex, info.data.SeatCount), string.format("<color=#29c4c4>%s</color>/%s", SeatIndex, info.data.SeatCount))

	self.TextPreson.text = colorStr

	SetActiveFunc(self.img_lock, false)
	SetActiveFunc(self.go_group, ThemeManager.isShowDetails)
	SetActiveFunc(self.img_unstate, false)
	UIUtil.SetImageSprite(self.ImgPreson, "UI/PageTheme/AtlasPageTheme/BG_roomline_07a", self)
	UIUtil.SetImageSprite(self.img_name, "UI/PageTheme/AtlasPageTheme/BG_roomsel_word_0" .. info.id, self)
	UIUtil.SetImageSprite(self.img_num, "UI/PageTheme/AtlasPageTheme/BG_roomline_word_0" .. info.id, self)
	UIUtil.SetImageSprite(self.Bg, "UI/PageTheme/AtlasPageTheme/BG_roomsel_13", self)

	self.Index.text = info.id

	UIUtil.SetImageSprite(self.Icon, info.data.Icon, self)

	local listAward = info.data.BaseReward[1]

	UIUtil.SetImageSprite(self.item_icon, ItemManager:GetIcon(listAward[1]), self)

	self:GetChildComponent("Panel/btn_item/tex_num", "Text").text = "×" .. ThemeManager:GetInfoThemeCount(info)

	SetActiveFunc(self.btnChange, false)
	SetActiveFunc(self.img_instate, true)
	SetActiveFunc(self.lockBuy, false)
	SetActiveFunc(self.lock, false)

	if info.geted then
		SetActiveFunc(self.btnChange, curThemeId ~= info.id)
		SetActiveFunc(self.img_instate, false)

		local curThemeId = PersistentStoreUtil.GetInt(ePSKey.SceneId)

		if curThemeId == info.id then
			SetActiveFunc(self.btnChange, false)
			SetActiveFunc(self.img_instate, true)
			UIUtil.SetImageSprite(self.Bg, "UI/PageTheme/AtlasPageTheme/BG_roomline_15", self)
		end
	elseif info:IsUnlocked() then
		SetActiveFunc(self.lockBuy, true)
		SetActiveFunc(self.lock, false)

		self.TextPreson.text = "×3"

		SetActiveFunc(self.btn_item_lock, false)
		SetActiveFunc(self.fx_full, false)
		SetActiveFunc(self.img_lock, true)
		SetActiveFunc(self.tex_go_full, true)
		SetActiveFunc(self.tex_num, false)
		SetActiveFunc(self.btn_item_bg, false)
		SetActiveFunc(self.go_group, false)
		SetActiveFunc(self.img_unstate, true)
		SetActiveFunc(self.img_instate, false)
		SetActiveFunc(self.img_stop, false)
		UIUtil.SetImageSprite(self.ImgPreson, "UI/PageTheme/AtlasPageTheme/BG_roomline_07b", self)

		local cost = info.data.Cost
		local strIcon = ItemManager:GetIcon(cost[1])

		UIUtil.SetImageSprite(self.ImageBuyIcon, strIcon, self)
		GOUtil.SetRectTransformAnchoredPosition(self.item_icon.gameObject, 0, 12)

		self.TextNum.text = cost[2]
	else
		local UnlockLevel = info.data.UnlockLevel
		local UnlockStage = info.data.UnlockStage

		if UnlockStage == 0 then
			self.TextUnlock.text = string.format(_("PageTalentTree_Unlock_level"), UnlockLevel)
		else
			local infoStage = ChapterMgr:GetStage(UnlockStage)

			self.TextUnlock.text = _("PageBadge_from") .. infoStage:GetName()
		end
	end

	if self.btn_item_bg.activeSelf and self.tex_time.text ~= "" then
		self.seatNoFull.localPosition = Vector3(0, -120, 0)
	else
		self.seatNoFull.localPosition = Vector3(0, -92, 0)
	end
end

function CellTheme:OnClickedDetails()
	ThemeManager.isShowDetails = not ThemeManager.isShowDetails

	SetActiveFunc(self.go_group, ThemeManager.isShowDetails and self.info.geted)
	Event.Instance:Fire("PageThemeInfoEvent")
end

function CellTheme:OnClickedBtnItem(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(string.sub(go.name, 5, 5))

	require("UI/Page/PageTheme/DlgTheme")
	UIMgr.AddPanel(DlgTheme(), {})
end
