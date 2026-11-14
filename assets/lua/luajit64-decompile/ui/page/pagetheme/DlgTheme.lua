-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTheme/DlgTheme.lua

require("Info/InfoTheme")
require("UI/Page/PageTheme/CellThemeItemHead")

DlgTheme = class("DlgTheme", UIPanel)

function DlgTheme:ctor()
	DlgTheme.base.ctor(self, "UI/PageTheme/DlgTheme")
end

function DlgTheme:Cache()
	DlgTheme.base.Cache(self)
end

function DlgTheme:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem", GameObject)
	self:LoadResAsync("UI/PageTheme/CellThemeItemHead", "PrefabCellThemeItemHead", GameObject)
	self:LoadResAsync("UI/Common/DlgCommon/DlgLongTip", "DlgLongTip", GameObject)
end

function DlgTheme:Purge()
	DlgTheme.base.Purge(self)

	if self.DlgLongTip then
		ResourceMgr.Unload(self.DlgLongTip)

		self.DlgLongTip = nil
	end

	if self.PrefabCellItem then
		if self.listItem then
			for i = 1, #self.listItem do
				self.listItem[i]:OnLeave()
			end
		end

		ResourceMgr.Unload(self.PrefabCellItem)

		self.PrefabCellItem = nil
		self.listItem = nil
	end

	if self.PrefabCellThemeItemHead then
		ResourceMgr.Unload(self.PrefabCellThemeItemHead)

		self.PrefabCellThemeItemHead = nil
	end

	if self.listCell then
		for i = 1, #self.listCell do
			self.listCell[i]:OnLeave()
		end

		self.listCell = nil
	end

	if self.DragRoleItem then
		self.DragRoleItem:OnLeave()
	end

	UnloadAllImageSprite(self)
end

function DlgTheme:Close()
	DlgTheme.base.Close(self)
end

function DlgTheme:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnCloseClick)
	self:AddClick(self.btn_hide, self.OnBtnHideDetails)

	for i = 1, #self.listThemeAll do
		self:AddClick(self["item_buy" .. i], self.OnClickedBuy)
		self:AddListener(self["group_itemSeat" .. i], self.OnPointerDown, EventTriggerType.PointerDown)
		self:AddListener(self["group_itemSeat" .. i], self.OnPointerUp, EventTriggerType.PointerUp)

		for n = 1, 3 do
			self:AddClick(self["ItemSeat" .. i .. "_" .. n], self.OnClickSeatItem)
		end
	end

	self:AddClick(self.BtnFilter, self.OnClickBtnFilter)
end

function DlgTheme:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnCloseClick)
	self:RemoveClick(self.btn_hide, self.OnBtnHideDetails)

	for i = 1, #self.listThemeAll do
		self:RemoveClick(self["item_buy" .. i], self.OnClickedBuy)
		self:RemoveListener(self["group_itemSeat" .. i], self.OnPointerDown, EventTriggerType.PointerDown)
		self:RemoveListener(self["group_itemSeat" .. i], self.OnPointerUp, EventTriggerType.PointerUp)

		for n = 1, 3 do
			self:RemoveClick(self["ItemSeat" .. i .. "_" .. n], self.OnClickSeatItem)
		end
	end

	self:AddClick(self.BtnFilter, self.OnClickBtnFilter)
end

function DlgTheme:OnEnter(vParam)
	self.info = vParam.info
	self.listThemeAll = ThemeManager:GetAll()
	self.selListTheme = self.listThemeAll[1]
	self.selThemeIndex = 1
	self.btn_close = self:GetChildGameObject("Main/btn_close")
	self.btn_hide = self:GetChildGameObject("Main/Group2/btn_hide")
	self.tex_num = self:GetChildComponent("Main/tex_num", "Text")
	self.Group = self:GetChildGameObject("Main/Group")
	self.Group2 = self:GetChildGameObject("Main/Group2")
	self.groupContent = self:GetChildGameObject("Main/Group/ScrollArea/Content")
	self.go_group_item = self:GetChildGameObject("Main/Group/go_group_item")

	for i = 1, #self.listThemeAll do
		local goCell = GOUtil.Instantiate(self.go_group_item, self.groupContent)

		SetActiveFunc(goCell, true)

		goCell.name = "item" .. i
	end

	SetActiveFunc(self.go_group_item, false)

	self.go_group_item_head = self:GetChildGameObject("Main/Group/go_group_item/go_group_item_head")

	SetActiveFunc(self.go_group_item_head, false)

	for i = 1, #self.listThemeAll do
		local go_group = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy")

		SetActiveFunc(self.go_group_item_head, false)

		for n = 1, 3 do
			local goCell = GOUtil.Instantiate(self.go_group_item_head, go_group)

			SetActiveFunc(goCell, true)

			goCell.name = "item_head" .. n
		end
	end

	self.go_group2_item_head = self:GetChildGameObject("Main/Group2/item/go_group2_item_head")
	self.group2inbuy = self:GetChildGameObject("Main/Group2/item/inbuy")

	for i = 1, #self.listThemeAll do
		local goCell = GOUtil.Instantiate(self.go_group2_item_head, self.group2inbuy)

		SetActiveFunc(goCell, true)

		goCell.name = "item_head" .. i
	end

	SetActiveFunc(self.go_group2_item_head, false)

	self.listItem = {}

	for i = 1, #self.listThemeAll do
		self["item" .. i] = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i)
		self["item_bg_" .. i] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i, "Image")
		self["item_num" .. i] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i .. "/img_num", "Image")
		self["item_name" .. i] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i .. "/img_name", "Image")
		self["item_unbuy" .. i] = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i .. "/unbuy")
		self["item_inbuy" .. i] = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy")
		self["item_content" .. i] = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i .. "/unbuy/ScrollArea/Content")
		self["item_buy" .. i] = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i .. "/unbuy/btn_buy")
		self["item_buy_icon" .. i] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i .. "/unbuy/btn_buy/icon", "Image")
		self["item_buy_num" .. i] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i .. "/unbuy/btn_buy/tex_num", "Text")

		for n = 1, 3 do
			self["ItemSeat" .. i .. "_" .. n] = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy/item_head" .. n)
			self["ItemSeatBg" .. i .. "_" .. n] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy/item_head" .. n .. "/show/ImageBg", "Image")
			self["ItemSeatIcon" .. i .. "_" .. n] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy/item_head" .. n .. "/show/ImageIcon", "Image")
			self["ItemSeatTex" .. i .. "_" .. n] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy/item_head" .. n .. "/show/ImageName/Text", "Text")
			self["ItemSeatShow" .. i .. "_" .. n] = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy/item_head" .. n .. "/show")
			self["ItemSeatDot" .. i .. "_" .. n] = self:GetChildGameObject("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy/item_head" .. n .. "/dot")
			self["ItemSeatShowTextHeart" .. i .. "_" .. n] = self:GetChildComponent("Main/Group/ScrollArea/Content/item" .. i .. "/inbuy/item_head" .. n .. "/show/ImageHeart/text_heart", "Text")
		end
	end

	self.group_item = self:GetChildGameObject("Main/Group2/item")
	self.group_item_bg = self:GetChildComponent("Main/Group2/item", "Image")
	self.group_item_num = self:GetChildComponent("Main/Group2/item" .. "/img_num", "Image")
	self.group_item_name = self:GetChildComponent("Main/Group2/item" .. "/img_name", "Image")
	self.group_item_unbuy = self:GetChildGameObject("Main/Group2/item" .. "/unbuy")
	self.group_item_inbuy = self:GetChildGameObject("Main/Group2/item" .. "/inbuy")
	self.group_item_content = self:GetChildGameObject("Main/Group2/item" .. "/unbuy/ScrollArea/Content")
	self.group_item_buy_icon = self:GetChildComponent("Main/Group2/item" .. "/unbuy/btn_buy/icon", "Image")
	self.group_item_buy_num = self:GetChildComponent("Main/Group2/item" .. "/unbuy/btn_buy/tex_num", "Text")
	self.scrollArea1 = self:GetChildGameObject("Main/Group2/BG/ScrollArea")
	self.content1 = GOUtil.FindChildComponent(self.scrollArea1, "Content", "RectTransform")
	self.DragRoleItem = CellThemeItemHead(self.PrefabCellThemeItemHead, self.UIRootObject, self)

	self.DragRoleItem:Create()
	SetActiveFunc(self.DragRoleItem.UIRootObject, false)
	self.DragRoleItem:HideBG(true)
	GOUtil.AddComponent(self.DragRoleItem.UIRootObject, "UIRayIgnore")

	for n = 1, 3 do
		self["group_itemSeat" .. n] = self:GetChildGameObject("Main/Group2/item" .. "/inbuy/item_head" .. n)
		self["group_itemSeatBg" .. n] = self:GetChildComponent("Main/Group2/item" .. "/inbuy/item_head" .. n .. "/show/ImageBg", "Image")
		self["group_itemSeatIcon" .. n] = self:GetChildComponent("Main/Group2/item" .. "/inbuy/item_head" .. n .. "/show/ImageIcon", "Image")
		self["group_itemSeatTex" .. n] = self:GetChildComponent("Main/Group2/item" .. "/inbuy/item_head" .. n .. "/show/ImageName/Text", "Text")
		self["group_itemSeatShow" .. n] = self:GetChildGameObject("Main/Group2/item" .. "/inbuy/item_head" .. n .. "/show")
		self["group_itemSeatShowTextHeart" .. n] = self:GetChildComponent("Main/Group2/item" .. "/inbuy/item_head" .. n .. "/show/ImageHeart/text_heart", "Text")

		GOUtil.AddComponent(self["group_itemSeat" .. n], "UIDraggableObject")
		GOUtil.AddComponent(self["group_itemSeat" .. n], "UIDropObject")

		local dragComp = GOUtil.GetComponent(self["group_itemSeat" .. n], "UIDraggableObject")

		dragComp:SetDragTarget(self.DragRoleItem.UIRootObject, false)
		dragComp:SetDragFollow(true)

		dragComp.CanDrag = true

		dragComp:SetBeginDragCallback(function(data)
			self:OnBeginDragHeadItem(data)
		end)

		function dragComp.onEndDrag(data)
			dragComp.CanDrag = false

			self:OnEndDragHeadItem()
		end

		local dropComp = GOUtil.GetComponent(self["group_itemSeat" .. n], "UIDropObject")

		dropComp:SetDropCallbackWithNoColor(function(dropObj, dragObj)
			self:OnDragHeadItem(dropObj, dragObj)
		end)
	end

	self.teamIndex = 0

	self:UpdateGroup1()
	self:DealWithLocalization()

	self.filterCnt = #GetThinShowClauses()
	self.filteCell1 = self:GetChildGameObject("Main/Group2/Filter/filteCell1")
	self.filteCell2 = self:GetChildGameObject("Main/Group2/Filter/filteCell2")
	self.filteGroup1 = self:GetChildGameObject("Main/Group2/Filter/MaskGroup/filteGroup1")
	self.filteGroup2 = self:GetChildGameObject("Main/Group2/Filter/filteGroup2")

	SetActiveFunc(self.filteGroup1, false)
	SetActiveFunc(self.filteGroup2, false)

	self.BtnFilter = self:GetChildGameObject("Main/Group2/Filter/BtnFilter")
	self.TxtOption = self:GetChildComponent("Main/Group2/Filter/BtnFilter/Text", "Text")

	self:InitFilterList()

	self.thinSystem = Tenary(thinSystem, THIN_SYSTEM_TYPE.Role)

	local rule = CharacterThinMgr.LastRule(self.thinSystem)

	self.preFilter = rule.clause
	self.curFilter = rule.subclause
	self.listOption = {}

	for i = 1, self.filterCnt do
		if self.curFilter == i then
			self.listOption[i] = rule.option
		else
			self.listOption[i] = 0
		end
	end

	self:UpdateFilterState()
	self:UpdateSelectRule()
	ThemeManager:SetDlgThemeOpenState()
end

function DlgTheme:InitFilterList()
	self.listCellFilter = {}

	SetActiveFunc(self.filteCell1, true)

	for i = 1, self.filterCnt do
		local cell = GOUtil.Instantiate(self.filteCell1, self.filteGroup1)

		cell.name = i

		local txt = GOUtil.FindChildComponent(cell, "Text", "Text")

		txt.text = GetThinClauseWord(i)

		self:AddClick(cell, self.OnClickFilter)
		table.insert(self.listCellFilter, cell)
	end

	SetActiveFunc(self.filteCell1, false)
end

function DlgTheme:InitOptions()
	self:ClearOptions()

	self.listCellOption = {}

	local listOption = GetThinSubclauses(self.curFilter)

	SetActiveFunc(self.filteCell2, true)

	for k, v in ipairs(listOption) do
		local cell = GOUtil.Instantiate(self.filteCell2, self.filteGroup2)

		cell.name = k

		local GoComb = GOUtil.FindChildGameObject(cell, "Comb")
		local GoTeam = GOUtil.FindChildGameObject(cell, "Team")
		local GoJob = GOUtil.FindChildGameObject(cell, "Job")

		SetActiveFunc(GoComb, false)
		SetActiveFunc(GoTeam, false)
		SetActiveFunc(GoJob, false)

		if self.curFilter == THIN_FILTER_NUM_TYPE.Comb then
			SetActiveFunc(GoComb, true)
			SetImageSprite(GOUtil.FindChildComponent(cell, "Comb/Icon", "Image"), "UIDyAtlas/Team/IC_IDH_" .. v.data.ID .. "00", self)
		elseif self.curFilter == THIN_FILTER_NUM_TYPE.Main_Team then
			SetActiveFunc(GoTeam, true)

			GOUtil.FindChildComponent(cell, "Team/Text", "Text").text = v[2]
		elseif self.curFilter == THIN_FILTER_NUM_TYPE.Job then
			SetActiveFunc(GoJob, true)
			SetImageSprite(GOUtil.FindChildComponent(cell, "Job/Icon", "Image"), "UI/Common/DlgCharacterThin/AtlasCharacterThin/ICO_" .. v[1] .. "_01_S", self)

			GOUtil.FindChildComponent(cell, "Job/Text", "Text").text = GetJobWord(v[2])
		end

		self:AddClick(cell, self.OnClickOption)
		table.insert(self.listCellOption, cell)
	end

	SetActiveFunc(self.filteCell2, false)
	self:UpdateOptionState()
end

function DlgTheme:UpdateSelectRule(filter, option)
	if not filter or not option then
		local rule = CharacterThinMgr.LastRule(self.thinSystem)

		filter = rule.clause
		option = rule.subclause
	end

	local strFilter = GetThinClauseWord(filter)
	local strOption = ""

	if filter == THIN_FILTER_NUM_TYPE.All then
		strOption = GetThinClauseWord(filter)
	else
		local list = GetThinSubclauses(filter)

		if filter == THIN_FILTER_NUM_TYPE.Comb then
			strOption = Lang(list[option].data.Name)
		elseif filter == THIN_FILTER_NUM_TYPE.Main_Team then
			strOption = list[option][2]
		elseif filter == THIN_FILTER_NUM_TYPE.Job then
			strOption = GetJobWord(list[option][2])
		end
	end

	self.TxtOption.text = strOption
end

function DlgTheme:UpdateFilterState()
	local function fun(cell)
		local index = tonumber(cell.name)
		local GoDef = GOUtil.FindChildGameObject(cell, "Default")
		local GoSel = GOUtil.FindChildGameObject(cell, "Select")

		SetActiveFunc(GoDef, index ~= self.curFilter)
		SetActiveFunc(GoSel, index == self.curFilter)
	end

	if self.listCellFilter then
		for _, v in ipairs(self.listCellFilter) do
			fun(v)
		end
	end
end

function DlgTheme:OnClickBtnFilter()
	SetActiveFunc(self.filteGroup1, not GOUtil.IsActiveSelf(self.filteGroup1))

	if not GOUtil.IsActiveSelf(self.filteGroup1) then
		self:CloseOptionPanel()
	end
end

function DlgTheme:ResetLocalRule(option)
	self.listOption[self.preFilter] = 0
	self.listOption[self.curFilter] = option
	self.selRoleIdx = 0

	self:UpdateRoleData()
	self:UpdateSelectRule(self.curFilter, option)
end

function DlgTheme:UpdateRoleData()
	self.listRole = CharacterThinMgr.GetRolesByRule(self.curFilter, self.listOption[self.curFilter])
	self.headList = self.listRole

	self:UpdateCellItem()
	GOUtil.SetRectTransformAnchoredPosition(self.Content, 0, 0)
end

function DlgTheme:UpdateOptionState()
	if self.listCellOption then
		for k, cell in ipairs(self.listCellOption) do
			local GoDef = GOUtil.FindChildGameObject(cell, "Default")
			local GoSel = GOUtil.FindChildGameObject(cell, "Select")

			SetActiveFunc(GoDef, self.listOption[self.curFilter] ~= k)
			SetActiveFunc(GoSel, self.listOption[self.curFilter] == k)
		end
	end
end

function DlgTheme:ClearFilters()
	if self.listCellFilter then
		for _, v in ipairs(self.listCellFilter) do
			self:RemoveClick(v, self.OnClickFilter)
		end

		self.listCellFilter = nil
	end

	GOUtil.DestroyAllChildren(self.Group1)
end

function DlgTheme:ClearOptions()
	if self.listCellOption then
		for _, v in ipairs(self.listCellOption) do
			self:RemoveClick(v, self.OnClickOption)
		end

		self.listCellOption = nil
	end

	GOUtil.DestroyAllChildren(self.filteGroup2)
end

function DlgTheme:OnClickFilter(data)
	local filter = tonumber(data.pointerPress.name)

	local function ResetFilter()
		self.preFilter = self.curFilter
		self.curFilter = filter

		self:UpdateFilterState()
	end

	if filter == THIN_FILTER_NUM_TYPE.All then
		ResetFilter()

		if self.preFilter ~= filter then
			self:ResetLocalRule(0)
		end

		self:CloseOptionPanel()
		SetActiveFunc(self.filteGroup1, not GOUtil.IsActiveSelf(self.filteGroup1))
	else
		if filter == THIN_FILTER_NUM_TYPE.Main_Team and not next(GetThinSubclauses(filter)) then
			UIMgr.ShowMsg(Lang(7001037))

			return
		end

		ResetFilter()
		self:InitOptions()
		self:UpdateOptionState()
		self:OpenOptionPanel()
	end
end

function DlgTheme:OnClickOption(data)
	local option = tonumber(data.pointerPress.name)

	if self.listOption[self.curFilter] == option then
		return
	end

	self:CloseOptionPanel()
	SetActiveFunc(self.filteGroup1, not GOUtil.IsActiveSelf(self.filteGroup1))
	self:ResetLocalRule(option)
end

function DlgTheme:OpenOptionPanel()
	SetActiveFunc(self.filteGroup2, true)
end

function DlgTheme:CloseOptionPanel()
	if GOUtil.IsActiveSelf(self.filteGroup2) then
		SetActiveFunc(self.filteGroup2, false)
	end
end

function DlgTheme:DealWithLocalization()
	local Text = self:GetChildComponent("Main/bg_title/Text", "Text")

	Text.text = _("Desc_SetScene")
	Text = self:GetChildComponent("Main/Group2/btn_hide/Text", "Text")
	Text.text = _("Desc_Storage")
	Text = self:GetChildComponent("Main/Group2/item/Text", "Text")
	Text.text = _("Desc_RemoveIdol")

	for i = 1, 3 do
		Text = GOUtil.FindChildComponent(self["item_unbuy" .. i], "Image/Text", "Text")
		Text.text = _("Desc_CumulativeRewards")
		Text = GOUtil.FindChildComponent(self["item_unbuy" .. i], "tex_max_num", "Text")
		Text.text = string.format(_("Desc_IdolSeatNum"), "3")
		Text = GOUtil.FindChildComponent(self["item_unbuy" .. i], "btn_buy/Text", "Text")
		Text.text = _("Desc_BuySceneTheme")
	end
end

function DlgTheme:UpdateGroup1()
	SetActiveFunc(self.Group, true)
	SetActiveFunc(self.Group2, false)
	SetActiveFunc(self:GetChildGameObject("Main/tex_num"), true)

	self.tex_num.text = string.format(_("Desc_OccupyIdol"), "<color=#29c4c4>" .. #ThemeManager:GetRoleInSeatList(self.listThemeAll) .. "</color>/" .. ThemeManager:GetInThemeSeat())

	for i = 1, #self.listThemeAll do
		local info = self.listThemeAll[i]

		i = info.id

		UIUtil.SetImageSprite(self["item_bg_" .. i], "UI/PageTheme/AtlasPageTheme/BG_roomsel_pic_0" .. i, self)
		UIUtil.SetImageSprite(self["item_num" .. i], "UI/PageTheme/AtlasPageTheme/BG_roomline_word_0" .. i, self)
		UIUtil.SetImageSprite(self["item_name" .. i], "UI/PageTheme/AtlasPageTheme/BG_roomsel_word_0" .. i, self)
		SetActiveFunc(self["item_unbuy" .. i], not info.geted)
		SetActiveFunc(self["item_inbuy" .. i], info.geted)
		GOUtil.DestroyAllChildren(self["item_content" .. i])

		if not info.geted then
			for n = 1, #info.data.BaseReward do
				local item = CellItem(self.PrefabCellItem, self["item_content" .. i], self)

				item:Create()

				item.UIRootObject.name = n

				local listAward = info.data.BaseReward[n]
				local infoItem = ItemManager:GetValueItem(listAward[1], listAward[2])

				item:UpdateNoNumType(infoItem)
				table.insert(self.listItem, item)
			end

			local cost = info.data.Cost

			GOUtil.SetRectTransformSizeDelta(self["item_content" .. i], 122 * #info.data.BaseReward, 118)

			local strIcon = ItemManager:GetIcon(cost[1])

			UIUtil.SetImageSprite(self["item_buy_icon" .. i], strIcon, self)

			self["item_buy_num" .. i].text = cost[2]
		else
			for n = 1, info.data.SeatCount do
				if info.geted then
					local id = info.pb.seats[n]

					if id ~= 0 then
						SetActiveFunc(self["ItemSeatShow" .. i .. "_" .. n], true)

						local infoRole = RoleMgr:GetRole(id)
						local listTeamData = RoleMgr:GetTeamList()
						local teamId = infoRole.data.Team
						local teamBgPath = listTeamData[teamId].BGIcon

						UIUtil.SetImageSprite(self["ItemSeatIcon" .. i .. "_" .. n], infoRole.actorData.CharacterIcon, self)

						self["ItemSeatTex" .. i .. "_" .. n].text = infoRole:GetName()
						self["ItemSeatShowTextHeart" .. i .. "_" .. n].text = infoRole.curFavorLevel
					else
						SetActiveFunc(self["ItemSeatShow" .. i .. "_" .. n], false)
					end
				end

				RedDotSystemMgr.SetUIRedDot(self["ItemSeat" .. i .. "_" .. n], string.format("Arrow/Theme/Seat/%d", info.id))
			end
		end
	end

	Event.Instance:Fire("UpdatePageThemeDot")
end

function DlgTheme:UpdateGroup2(index)
	SetActiveFunc(self.Group, false)
	SetActiveFunc(self.Group2, true)
	SetActiveFunc(self:GetChildGameObject("Main/tex_num"), false)

	local info = {}

	for i = 1, #self.listThemeAll do
		if index == self.listThemeAll[i].id then
			info = self.listThemeAll[i]
		end
	end

	ThemeRDL.RemoveNewPlayerPrefs(info.id)

	self.selListTheme = info
	self.selThemeIndex = info.id

	UIUtil.SetImageSprite(self.group_item_bg, "UI/PageTheme/AtlasPageTheme/BG_roomsel_pic_0" .. index, self)
	UIUtil.SetImageSprite(self.group_item_num, "UI/PageTheme/AtlasPageTheme/BG_roomline_word_0" .. index, self)
	UIUtil.SetImageSprite(self.group_item_name, "UI/PageTheme/AtlasPageTheme/BG_roomsel_word_0" .. index, self)
	SetActiveFunc(self.group_item_unbuy, not info.geted)
	SetActiveFunc(self.group_item_inbuy, info.geted)

	if not info.geted then
		for n = 1, #info.data.BaseReward do
			local item = CellItem(self.PrefabCellItem, self.group_item_content, self)

			item:Create()

			item.UIRootObject.name = n

			local listAward = info.data.BaseReward[n]
			local infoItem = ItemManager:GetValueItem(listAward[1], listAward[2])

			item:UpdateWithNumType(infoItem)
			table.insert(self.listItem, item)
		end

		local cost = info.data.Cost

		GOUtil.SetRectTransformSizeDelta(self.group_item_content, 122 * #info.data.BaseReward, 118)

		local strIcon = ItemManager:GetIcon(cost[1])

		UIUtil.SetImageSprite(self.group_item_buy_icon, strIcon, self)

		self.group_item_buy_num.text = cost[2]
	else
		for n = 1, info.data.SeatCount do
			if info.geted then
				local id = info.pb.seats[n]

				if id ~= 0 then
					SetActiveFunc(self["group_itemSeatShow" .. n], true)

					local infoRole = RoleMgr:GetRole(id)
					local listTeamData = RoleMgr:GetTeamList()
					local teamId = infoRole.data.Team
					local teamBgPath = listTeamData[teamId].BGIcon

					UIUtil.SetImageSprite(self["group_itemSeatIcon" .. n], infoRole.actorData.CharacterIcon, self)

					self["group_itemSeatTex" .. n].text = infoRole:GetName()
					self["group_itemSeatShowTextHeart" .. n].text = infoRole.curFavorLevel
				else
					SetActiveFunc(self["group_itemSeatShow" .. n], false)
				end
			end
		end
	end

	if self.isUIScroll then
		return
	end

	self.isUIScroll = true
	self.listTeam = RoleMgr:GetTeamList()
	self.headList = {}

	for i = 1, #RoleMgr:GetAllRole() do
		local infoRole = RoleMgr:GetAllRole()[i]

		table.insert(self.headList, infoRole)
	end

	self.Content = self:GetChildGameObject("Main/Group2/BG/ScrollArea/Content")
	self.ScrollRect = self:GetChildComponent("Main/Group2/BG/ScrollArea", "ScrollRect")
	self.ScrollRectGo = self:GetChildGameObject("Main/Group2/BG/ScrollArea")
	self.RectContent = GOUtil.GetComponent(self.Content, "RectTransform")
	self.listCell = {}

	for i = 1, #self.headList do
		local item = CellThemeItemHead(self.PrefabCellThemeItemHead, self.Content)

		item:Create()

		item.UIRootObject.name = i

		GOUtil.AddComponent(item.UIRootObject, "UIDraggableObject")
		self:AddListener(item.UIRootObject, self.OnLongPress, EventTriggerType.PointerLongPress)
		self:AddClick(item.UIRootObject, self.OnHeadClick)

		local list = ThemeManager:GetRoleInSeatList(self.listThemeAll)
		local isSel = false

		for n = 1, #list do
			if self.headList[i].id == list[n] then
				isSel = true
			end
		end

		local dragComp = GOUtil.GetComponent(item.UIRootObject, "UIDraggableObject")

		dragComp.CanDrag = false

		dragComp:SetDragFollow(true)
		dragComp:SetDragTarget(self.DragRoleItem.UIRootObject, false)
		item:UpdateData(self.headList[i], isSel, self.ScrollRectGo)
		table.insert(self.listCell, item)
	end

	GOUtil.SetRectTransformSizeDelta(self.Content, self.RectContent.sizeDelta.x, #self.headList % 6 * 216)
end

function DlgTheme:UpdateCellItem()
	if not self.listCell then
		return
	end

	for i = 1, #self.listCell do
		SetActiveFunc(self.listCell[i].UIRootObject, false)
	end

	for i = 1, #self.headList do
		local list = ThemeManager:GetRoleInSeatList(self.listThemeAll)
		local isSel = false

		for n = 1, #list do
			if self.headList[i].id == list[n] then
				isSel = true
			end
		end

		local dragComp = GOUtil.GetComponent(self.listCell[i].UIRootObject, "UIDraggableObject")

		dragComp.CanDrag = false

		dragComp:SetDragFollow(true)
		dragComp:SetDragTarget(self.DragRoleItem.UIRootObject, false)
		SetActiveFunc(self.listCell[i].UIRootObject, true)
		self.listCell[i]:UpdateData(self.headList[i], isSel, self.ScrollRectGo)
	end
end

function DlgTheme:OnHeadClick(data)
	if self.longPressTempGo then
		local dragComp = GOUtil.GetComponent(self.longPressTempGo.gameObject, "UIDraggableObject")

		if dragComp.isMove then
			return
		end
	end

	local go = data.pointerPress
	local index = tonumber(go.name)
	local templist = {}
	local count = 0

	for m = 1, 3 do
		if self.selListTheme.pb.seats[m] ~= 0 then
			count = count + 1
		end
	end

	if count == 3 then
		UIMgr.ShowMsg(_("Msg_FullSeat"))

		return
	end

	for i = 1, #self.listThemeAll do
		if self.selListTheme.pb.seats[i] == 0 then
			if self.headList[index].hold then
				local isSame = false

				for m = 1, 3 do
					if self.selListTheme.pb.seats[m] == self.headList[index].id then
						isSame = true
					end
				end

				if isSame then
					return
				end

				self.selListTheme.pb.seats[i] = self.headList[index].id

				for n = 1, 3 do
					table.insert(templist, self.selListTheme.pb.seats[n])
				end

				local function OnCallback(index)
					if index == 1 then
						self:UpdateGroup2(self.selThemeIndex)
					end
				end

				self:RequestSetThemePosition(templist, 2, OnCallback)
			end

			break
		end
	end
end

function DlgTheme:OnPointerUp(data)
	local go = data.pointerPressRaycast
	local index = tonumber(string.sub(go.gameObject.name, 10, 10))
	local dragComp = GOUtil.GetComponent(self["group_itemSeat" .. index], "UIDraggableObject")

	dragComp.CanDrag = false
	self.ScrollRect.vertical = true

	if not self.isBeginIndex then
		local templist = {}

		if self.selListTheme.pb.seats[index] ~= 0 then
			self.selListTheme.pb.seats[index] = 0

			for n = 1, 3 do
				table.insert(templist, self.selListTheme.pb.seats[n])
			end

			local function OnCallback(index)
				if index == 1 then
					self:UpdateGroup2(self.selThemeIndex)
				end
			end

			self:RequestSetThemePosition(templist, 2, OnCallback)
		end
	end
end

function DlgTheme:OnLongPress(data)
	if data.clickCount == 1 then
		self.ScrollRect.vertical = false

		local go = data.pointerPress

		self.longPressTempGo = go

		local index = tonumber(go.name)

		SetActiveFunc(self.DragRoleItem.UIRootObject, true)

		if not self.headList[index].hold then
			SetActiveFunc(self.DragRoleItem.UIRootObject, false)

			return
		end

		self.LongPressItemRoleID = self.headList[index].id

		self.DragRoleItem:UpdateData(self.headList[index])

		local dragComp = GOUtil.GetComponent(go.gameObject, "UIDraggableObject")

		if not dragComp.isLeave then
			if dragComp.isMove then
				self.DragRoleItem.UIRootObject.transform.localScale = Vector3(0, 0, 0)

				SetActiveFunc(self.DragRoleItem.UIRootObject, false)

				self.ScrollRect.vertical = true

				return
			end

			function dragComp.mOnLeave(data)
				return
			end

			dragComp:SetDragFollow(true)
			dragComp:SetDragTarget(self.DragRoleItem.UIRootObject, false)

			function dragComp.onEndDrag(data)
				dragComp.CanDrag = false

				self:OnEndDragHeadItem()
			end

			self.DragRoleItem.UIRootObject.transform.localScale = Vector3(1.1, 1.1, 1.1)
			self.tempHeadGo = go.gameObject
			dragComp.CanDrag = true

			GOUtil.SetTransformPosition(self.DragRoleItem.UIRootObject, go.transform.position.x, go.transform.position.y, go.transform.position.z)
		else
			self.DragRoleItem.UIRootObject.transform.localScale = Vector3(0, 0, 0)

			SetActiveFunc(self.DragRoleItem.UIRootObject, false)

			self.ScrollRect.vertical = true
		end
	else
		self.DragRoleItem.UIRootObject.transform.localScale = Vector3(0, 0, 0)
		self.ScrollRect.vertical = true
	end
end

function DlgTheme:OnBeginDragHeadItem(pointerEventData)
	local curRaycast = pointerEventData.pointerCurrentRaycast

	if curRaycast.gameObject == nil then
		return
	end

	local index = tonumber(string.sub(curRaycast.gameObject.name, 10, 10))

	if self.selListTheme.pb.seats[index] == 0 then
		SetActiveFunc(self.DragRoleItem.UIRootObject, false)

		return
	end

	self.isBeginIndex = index
end

function DlgTheme:OnEndDragHeadItem()
	self.LongPressItemRoleID = nil

	if self.isBeginIndex then
		local info = self:GetListTheme()

		info.pb.seats[self.isBeginIndex] = 0

		local templist = {}

		local function OnCallback(index)
			if index == 1 then
				self:UpdateGroup2(self.selThemeIndex)
			end
		end

		for i = 1, 3 do
			table.insert(templist, info.pb.seats[i])
		end

		self:RequestSetThemePosition(templist, 2, OnCallback)

		self.isBeginIndex = nil
	end
end

function DlgTheme:OnDragHeadItem(dropObject, dragObject)
	self.isBeginIndex = nil

	if self.DragRoleItem.UIRootObject.activeSelf then
		local dropIndex = tonumber(string.sub(dropObject.gameObject.name, 10, 10))
		local dragIndex = tonumber(string.sub(dragObject.gameObject.name, 10, 10))
		local _, dropCount = string.gsub(dropObject.gameObject.name, "[^\x80-\xC1]", "")
		local _, dragCount = string.gsub(dragObject.gameObject.name, "[^\x80-\xC1]", "")

		local function OnCallback(index)
			if index == 1 then
				self:UpdateGroup2(self.selThemeIndex)
			end
		end

		if dropCount == 10 and dragCount == 10 then
			local tempRoleID = self:GetListTheme().pb.seats[dropIndex]
			local info = self:GetListTheme()

			info.pb.seats[dropIndex] = info.pb.seats[dragIndex]
			info.pb.seats[dragIndex] = tempRoleID

			local templist = {}

			for i = 1, 3 do
				table.insert(templist, info.pb.seats[i])
			end

			self:RequestSetThemePosition(templist, 2, OnCallback)
		end

		if dropCount == 10 and dragCount ~= 10 then
			local info = self:GetListTheme()

			for i = 1, 3 do
				if tonumber(info.pb.seats[i]) == tonumber(self.LongPressItemRoleID) then
					info.pb.seats[i] = 0
				end
			end

			local tempRoleID = self.LongPressItemRoleID

			info.pb.seats[dropIndex] = tempRoleID

			local strTitle = Lang(12199)
			local strOkText = Lang(12243)
			local strCancelText = Lang(12153)
			local infoRole = RoleMgr:GetRole(self.LongPressItemRoleID)
			local msg = string.format(Lang(42377), infoRole:GetName())

			for m = 1, #self.listThemeAll do
				if self.listThemeAll[m].id ~= info.id then
					for n = 1, 3 do
						if self.listThemeAll[m].pb.seats[n] == self.LongPressItemRoleID then
							local function wrapcb2(index2)
								if index2 == 1 then
									local templist = {}

									for i = 1, 3 do
										table.insert(templist, info.pb.seats[i])
									end

									self:RequestSetThemePosition(templist, 2, OnCallback)
								end
							end

							UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, msg, wrapcb2, strOkText, strCancelText)

							return
						end
					end
				end
			end

			local templist = {}

			for i = 1, 3 do
				table.insert(templist, info.pb.seats[i])
			end

			self:RequestSetThemePosition(templist, 2, OnCallback)
		end
	end

	SetActiveFunc(self.DragRoleItem.UIRootObject, false)

	self.ScrollRect.vertical = true
end

function DlgTheme:GetListTheme()
	for i = 1, #self.listThemeAll do
		if self.listThemeAll[i].id == self.selThemeIndex then
			return self.listThemeAll[i]
		end
	end
end

function DlgTheme:RequestSetThemePosition(listSeat, type, callback)
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			local x = self.selListTheme
			local list = ThemeManager:GetRoleInSeatList(self.listThemeAll)

			self:UpdateCellItem()
			callback(1)
			Event.Instance:Fire("PageThemeUpdateInfoEvent", self.listThemeAll, self.selThemeIndex, self.listThemeAll[self.selThemeIndex].id)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			callback(0)
		end
	end

	NetManager:RequestSetThemePosition(self:GetListTheme().id, listSeat, type, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgTheme:OnClickSeatItem(data)
	local go = data.pointerPress

	self:UpdateGroup2(tonumber(string.sub(data.pointerPress.transform.parent.parent.gameObject.name, 5, 5)))
	self:UpdateCellItem()
	GOUtil.SetRectTransformAnchoredPosition(self.Content, 0, 0)
end

function DlgTheme:OnBtnHideDetails()
	self:ClearOptions()
	SetActiveFunc(self.filteGroup1, false)
	SetActiveFunc(self.filteGroup2, false)
	self:UpdateGroup1()
end

function DlgTheme:OnBtnCloseClick()
	SceneMainStage.Instance:UpdateRole()
	Event.Instance:Fire("UpdatePageThemeDot")
	self:Close()
end

function DlgTheme:OnClickedBuy(data)
	local go = data.pointerPressRaycast
	local index = tonumber(string.sub(data.pointerPress.transform.parent.parent.gameObject.name, 5, 5))
	local info

	for i = 1, #self.listThemeAll do
		if self.listThemeAll[i].id == index then
			info = self.listThemeAll[i]
		end
	end

	local cost = info.data.Cost
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
				self:RequestBuyTheme(info)
			end
		else
			self.fobiden = false
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.MsgWithAlert, _("Desc_Alert"), {
		content = string.format(_("Desc_BuyNewScene"), cost[2], info:GetName()),
		alert = string.format(_("Desc_HaveItemNum"), ItemManager:GetItemCount(cost[1]))
	}, fun, _("UI_Buy"), nil, nil, true)
end

function DlgTheme:RequestBuyTheme(info)
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self:UpdateGroup1()
			Event.Instance:Fire("PageThemeUpdateInfoEvent", self.listThemeAll, self.selThemeIndex, self.listThemeAll[self.selThemeIndex].id)
			UIMgr.ShowMsg(_("Shop_success"))
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestBuyTheme(info.id, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgTheme:OnPointerDown(data)
	local go = data.pointerPressRaycast
	local index = tonumber(string.sub(go.gameObject.name, 10, 10))

	if self.selListTheme.pb.seats[index] == 0 then
		SetActiveFunc(self.DragRoleItem.UIRootObject, false)

		return
	end

	local dragComp = GOUtil.GetComponent(self["group_itemSeat" .. index], "UIDraggableObject")

	self.DragRoleItem.UIRootObject.transform.localScale = Vector3(1, 1, 1)

	dragComp:SetDragTarget(self.DragRoleItem.UIRootObject, false)
	dragComp:SetDragFollow(true)

	dragComp.CanDrag = true

	self.DragRoleItem:UpdateData(RoleMgr:GetRole(self.selListTheme.pb.seats[index]))
end
