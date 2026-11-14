-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/DlgCharacterThin/DlgCharacterThin.lua

require("UI/Dlg/DlgCharacterThin/CellCharacterThin")

DlgCharacterThin = class("DlgCharacterThin", UIPanel)

function DlgCharacterThin:ctor(thinSystem, pageType)
	self.UIPrefabPath = "UI/Common/DlgCharacterThin/DlgCharacterThin"
	self.thinSystem = Tenary(thinSystem, THIN_SYSTEM_TYPE.Role)
	self.pageType = Tenary(pageType, THIN_PAGE_TYPE.Role)
end

function DlgCharacterThin:PreLoad()
	self:LoadResAsync("UI/Common/DlgCharacterThin/CellCharacterThin", "PrefabCellCharacterThin")
end

function DlgCharacterThin:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
	ResourceMgr.Unload(self.PrefabCellCharacterThin)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self:ClearFilters()
	self:ClearOptions()
end

function DlgCharacterThin:ClearFilters()
	if self.listCellFilter then
		for _, v in ipairs(self.listCellFilter) do
			self:RemoveClick(v, self.OnClickFilter)
		end

		self.listCellFilter = nil
	end
end

function DlgCharacterThin:ClearOptions()
	if self.listCellOption then
		for _, v in ipairs(self.listCellOption) do
			self:RemoveClick(v, self.OnClickOption)
		end

		self.listCellOption = nil
	end
end

function DlgCharacterThin:OnRegisterEvent()
	self:AddClick(self.BtnThin, self.Open)
	Event.Instance:Add("UpdateThinNotify", self.UpdateDot, self)
	Event.Instance:Add("UpdateThinAfterDevelop", self.UpdateRolesOrder, self)
end

function DlgCharacterThin:OnUnRegisterEvent()
	self:RemoveClick(self.BtnThin, self.Open)
	Event.Instance:Remove("UpdateThinNotify", self.UpdateDot, self)
	Event.Instance:Remove("UpdateThinAfterDevelop", self.UpdateRolesOrder, self)

	if self.IsOpened then
		self:RemoveClick(self.BtnFilter, self.OnClickBtnFilter)
		self:RemoveClick(self.GoClick, self.OnClickBack)
		self:RemoveClick(self.BtnBack, self.OnClickBack)
	end
end

function DlgCharacterThin:OnEnter(vParam)
	self.IsOpened = false
	self.BtnThin = self:GetChildGameObject("Panel/BtnThin")
	self.GoDot = self:GetChildGameObject("Panel/BtnThin/Dot")
	self.Animator = self:GetChildComponent("", "Animator")
	self.TxtFilter = self:GetChildComponent("Panel/BtnThin/Text", "Text")
	self.TxtOption = self:GetChildComponent("Panel/Panel/BtnFilter/Text", "Text")
	self.filter = GetThinShowClauses()
	self.filterCnt = #self.filter

	self:Init()
	self:UpdateSelectRule()
end

function DlgCharacterThin:Init()
	local rule = CharacterThinMgr.LastRule(self.thinSystem)

	self.preFilter = self.curFilter or rule.clause
	self.curFilter = rule.clause
	self.listOption = {}

	for _, v in ipairs(self.filter) do
		if self.curFilter == v then
			self.listOption[v] = rule.subclause
		else
			self.listOption[v] = 0
		end
	end

	self.selRoleIdx = nil

	self:UpdateRoleData()
end

function DlgCharacterThin:UpdateRoleData()
	self.listRole = CharacterThinMgr.GetRolesByRule(self.curFilter, self.listOption[self.curFilter])
	self.curRoleId = CharacterThinMgr.LastData(self.thinSystem).id

	if table.getn(self.listRole) == 0 then
		return
	end

	if not self.selRoleIdx then
		for k, v in ipairs(self.listRole) do
			if v.id == self.curRoleId then
				self.selRoleIdx = k

				break
			end
		end
	end

	self:UpdateDot()
end

function DlgCharacterThin:InitAtFirstOpen()
	self.IsOpened = true
	self.GoClick = self:GetChildGameObject("Click")
	self.GoRoleList = self:GetChildGameObject("Panel/Panel")
	self.Cell1 = self:GetChildGameObject("Panel/Cell1")
	self.Cell2 = self:GetChildGameObject("Panel/Cell2")
	self.Group1 = self:GetChildGameObject("Panel/Panel/MaskGroup/Group1")
	self.Group2 = self:GetChildGameObject("Panel/Panel/Group2")
	self.ScrollArea = self:GetChildGameObject("Panel/Panel/ScrollArea")
	self.BtnFilter = self:GetChildGameObject("Panel/Panel/BtnFilter")
	self.BtnBack = self:GetChildGameObject("Panel/Panel/BtnBack")

	self:AddClick(self.BtnFilter, self.OnClickBtnFilter)
	self:AddClick(self.GoClick, self.OnClickBack)
	self:AddClick(self.BtnBack, self.OnClickBack)
	self:InitFilterList()
end

function DlgCharacterThin:Open()
	if not self.IsOpened then
		self:InitAtFirstOpen()
	end

	self.IsOpen = true

	GOUtil.SetActive(self.GoRoleList, 1)
	GOUtil.SetActive(self.GoClick, 1)
	self.Animator:Play("DlgCharacterThin_show", 0, 0)

	self.curRoleId = CharacterThinMgr.LastData(self.thinSystem).id

	for k, v in ipairs(self.listRole) do
		if v.id == self.curRoleId then
			self.selRoleIdx = k

			break
		end
	end

	self:UpdateRoleList()
end

function DlgCharacterThin:UpdateRolesOrder()
	CharacterThinMgr.SortRoles(self.listRole)
end

function DlgCharacterThin:ResetPre()
	self:Init()
	self:UpdateFilterState()
	self:UpdateSelectRule()
end

function DlgCharacterThin:InitFilterList()
	self.listCellFilter = {}

	for i = 1, self.filterCnt do
		local cell = GOUtil.Instantiate(self.Cell1, self.Group1)

		cell.name = i

		local txt = GOUtil.FindChildComponent(cell, "Text", "Text")

		txt.text = GetThinClauseWord(self.filter[i])

		self:AddClick(cell, self.OnClickFilter)
		table.insert(self.listCellFilter, cell)
	end

	self:UpdateFilterState()
end

function DlgCharacterThin:InitOptions()
	self.listCellOption = self.listCellOption or {}

	local listOption = GetThinSubclauses(self.curFilter)

	local function FuncUpdate(cell, data)
		local GoComb = GOUtil.FindChildGameObject(cell, "Comb")
		local GoTeam = GOUtil.FindChildGameObject(cell, "Team")
		local GoJob = GOUtil.FindChildGameObject(cell, "Job")

		GOUtil.SetActive(GoComb, TenaryOp(self.curFilter == THIN_FILTER_NUM_TYPE.Comb, 1, 0))
		GOUtil.SetActive(GoTeam, 0)
		GOUtil.SetActive(GoJob, TenaryOp(self.curFilter == THIN_FILTER_NUM_TYPE.Job, 1, 0))

		if self.curFilter == THIN_FILTER_NUM_TYPE.Comb then
			SetImageSprite(GOUtil.FindChildComponent(cell, "Comb/Icon", "Image"), "UIDyAtlas/Team/IC_IDH_" .. data.id .. "00", self)
		elseif self.curFilter == THIN_FILTER_NUM_TYPE.Main_Team or self.curFilter == THIN_FILTER_NUM_TYPE.Comb_Team or self.curFilter == THIN_FILTER_NUM_TYPE.Union_Team or self.curFilter == THIN_FILTER_NUM_TYPE.PVP_Team then
			GOUtil.SetActive(GoTeam, 1)

			GOUtil.FindChildComponent(cell, "Team/Text", "Text").text = data[2]
		elseif self.curFilter == THIN_FILTER_NUM_TYPE.Job then
			SetImageSprite(GOUtil.FindChildComponent(cell, "Job/Icon", "Image"), "UI/Common/DlgCharacterThin/AtlasCharacterThin/ICO_" .. data[1] .. "_01_S", self)

			GOUtil.FindChildComponent(cell, "Job/Text", "Text").text = GetJobWord(data[2])
		end
	end

	local function FuncCreate(idx, data)
		local cell = GOUtil.Instantiate(self.Cell2, self.Group2)

		cell.name = tostring(idx)

		FuncUpdate(cell, data)
		self:AddClick(cell, self.OnClickOption)
		table.insert(self.listCellOption, cell)
	end

	local oldCnt = #self.listCellOption
	local newCnt = #listOption

	if oldCnt < newCnt then
		for i = 1, newCnt do
			if i <= oldCnt then
				FuncUpdate(self.listCellOption[i], listOption[i])
				GOUtil.SetActive(self.listCellOption[i], 1)
			else
				FuncCreate(i, listOption[i])
			end
		end
	else
		for i = 1, oldCnt do
			GOUtil.SetActive(self.listCellOption[i], TenaryOp(i <= newCnt, 1, 0))

			if i <= newCnt then
				FuncUpdate(self.listCellOption[i], listOption[i])
			end
		end
	end

	self:UpdateOptionState()
end

function DlgCharacterThin:UpdateRoleList()
	local function GetPos()
		local index = 1

		for k, v in ipairs(self.listRole) do
			if self.curRoleId == v.id then
				index = k

				break
			end
		end

		return GetContentPos(self.UIScrollTool.ScrollView, math.ceil(#self.listRole / 2), math.ceil(index / 2), true)
	end

	if self.UIScrollTool then
		if self.IsOpen then
			self.IsOpen = false

			local y = GetPos()

			self.UIScrollTool:SetInitPos(Vector3(0, y, 0))
			self.UIScrollTool:SetContentPosImmediate(Vector2(0, -y), self.listRole)
		else
			self.UIScrollTool:UpdateListData(self.listRole)
		end

		return
	end

	self.IsOpen = false

	local content = GOUtil.FindChildComponent(self.ScrollArea, "Content", "RectTransform")
	local count = #self.listRole

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickCellCharacter)
	end

	local function updateCallback(item, index)
		item:UpdateData(self.listRole[index], self.selRoleIdx, self.pageType)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.PrefabCellCharacterThin, CellCharacterThin, self, false, addCallback, updateCallback)
	self.UIScrollTool:SetInitPos(Vector3(0, GetPos(), 0))
end

function DlgCharacterThin:OnClickFilter(data)
	local filter = tonumber(data.pointerPress.name)

	if self.curFilter == filter and self.Group2State then
		return
	end

	self.Animator:Play("DlgCharacterThin_showGroup2", 0, 0)

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

function DlgCharacterThin:OnClickOption(data)
	local option = tonumber(data.pointerPress.name)

	if self.listOption[self.curFilter] == option then
		return
	end

	self:CloseOptionPanel()
	self:CloseFilterPanel()
	self:ResetLocalRule(option)
end

function DlgCharacterThin:OnClickCellCharacter(data)
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(data.pointerPress)
	local index = info.Item.Index

	if index == self.selRoleIdx then
		return
	end

	if not self.listRole[index].hold then
		UIMgr.ShowMsg(Lang(12910))

		return
	end

	local preIdx = self.selRoleIdx

	self.selRoleIdx = index

	self.UIScrollTool:UpdateCellSelect(preIdx, index)
	self:CloseOptionPanel()
	self:CloseFilterPanel()
	GOUtil.SetActive(self.GoClick, 0)
	GOUtil.SetActive(self.GoRoleList, 0)

	local role = self.listRole[index]
	local isHas = false

	for _, v in ipairs(CharacterThinMgr.LastData(self.thinSystem).roles) do
		if role.id == v.id then
			isHas = true

			break
		end
	end

	if not isHas then
		CharacterThinMgr.TempResetPreData(self.thinSystem, role.id)
	end

	self:RefreshShowRole()
end

function DlgCharacterThin:ResetLocalRule(option)
	self.listOption[self.preFilter] = 0
	self.listOption[self.curFilter] = option

	local rule = CharacterThinMgr.LastRule(self.thinSystem)

	if self.curFilter == rule.clause and option == rule.subclause then
		self.selRoleIdx = nil
	else
		self.selRoleIdx = 0
	end

	self:UpdateRoleData()
	self:UpdateRoleList()
	self:UpdateSelectRule(self.curFilter, option)
end

local function UpdateSelect(cell, selState)
	local GoDef = GOUtil.FindChildGameObject(cell, "Default")
	local GoSel = GOUtil.FindChildGameObject(cell, "Select")

	if selState then
		GOUtil.SetActive(GoDef, 0)
		GOUtil.SetActive(GoSel, 1)
	else
		GOUtil.SetActive(GoDef, 1)
		GOUtil.SetActive(GoSel, 0)
	end
end

function DlgCharacterThin:UpdateFilterState()
	if self.listCellFilter then
		for _, cell in ipairs(self.listCellFilter) do
			local filter = tonumber(cell.name)

			if filter == self.preFilter then
				UpdateSelect(cell, false)
			end

			if filter == self.curFilter then
				UpdateSelect(cell, true)
			end
		end
	end
end

function DlgCharacterThin:UpdateOptionState()
	if self.listCellOption then
		for k, cell in ipairs(self.listCellOption) do
			if self.listOption[self.curFilter] == k then
				UpdateSelect(cell, true)
			end

			if self.listOption[self.curFilter] ~= k then
				UpdateSelect(cell, false)
			end
		end
	end
end

function DlgCharacterThin:UpdateSelectRule(filter, option)
	if not filter or not option then
		local rule = CharacterThinMgr.LastRule(self.thinSystem)

		filter = rule.clause
		option = rule.subclause
	end

	local strOption = ""

	if filter == THIN_FILTER_NUM_TYPE.All then
		strOption = GetThinClauseWord(filter)
	else
		local list = GetThinSubclauses(filter)

		if filter == THIN_FILTER_NUM_TYPE.Comb then
			local list = CombinationMgr:GetCombinationSortByTeamOder()

			strOption = _("Team_0" .. list[option].data.ID)
		elseif filter == THIN_FILTER_NUM_TYPE.Main_Team then
			strOption = list[option][2]
		elseif filter == THIN_FILTER_NUM_TYPE.Job then
			strOption = GetJobWord(list[option][2])
		end
	end

	self.TxtOption.text = strOption
	self.TxtFilter.text = strOption
end

function DlgCharacterThin:OnClickBtnFilter()
	if self.Group1State then
		GOUtil.SetActive(self.Group1, 0)

		self.Group1State = false
	else
		GOUtil.SetActive(self.Group1, 1)

		self.Group1State = true

		self.Animator:Play("DlgCharacterThin_showGroup", 0, 0)
	end

	self:CloseOptionPanel()
end

function DlgCharacterThin:OpenOptionPanel()
	if not self.Group2State then
		GOUtil.SetActive(self.Group2, 1)

		self.Group2State = true
	end
end

function DlgCharacterThin:CloseFilterPanel()
	if self.Group1State then
		GOUtil.SetActive(self.Group1, 0)

		self.Group1State = false
	end
end

function DlgCharacterThin:CloseOptionPanel()
	if self.Group2State then
		GOUtil.SetActive(self.Group2, false)

		self.Group2State = false
	end
end

function DlgCharacterThin:OnClickBack()
	GOUtil.SetActive(self.GoRoleList, 0)
	GOUtil.SetActive(self.GoClick, 0)
	self:CloseFilterPanel()
	self:CloseOptionPanel()

	if next(self.listRole) == nil then
		UIMgr.ShowMsg(_("Msg_Thin_Filter_None"))
		self:ResetPre()

		return
	end

	local idx = 0

	for k, v in ipairs(self.listRole) do
		if v.hold then
			idx = k

			break
		end
	end

	if idx == 0 then
		UIMgr.ShowMsg(_("Msg_Thin_Filter_Char_Hold_None"))
		self:ResetPre()

		return
	end

	local rule = CharacterThinMgr.LastRule(self.thinSystem)

	if self.curFilter == THIN_FILTER_NUM_TYPE.All then
		if rule.clause == self.curFilter then
			return
		end
	elseif self.listOption[self.curFilter] == 0 or rule.clause == self.curFilter and rule.subclause == self.listOption[self.curFilter] then
		self.preFilter = self.curFilter
		self.curFilter = rule.clause

		self:UpdateFilterState()

		return
	end

	local preIdx = self.selRoleIdx

	self.selRoleIdx = idx == 0 and 1 or idx

	if self.UIScrollTool then
		self.UIScrollTool:UpdateCellSelect(preIdx, self.selRoleIdx)
	end

	self:RefreshShowRole(true)
end

function DlgCharacterThin:RefreshShowRole(updateArrow)
	local infoRole = self.listRole[self.selRoleIdx]

	CharacterThinMgr.ResetInterface(self.thinSystem, self.curFilter, self.listOption[self.curFilter], infoRole.id, self.selRoleIdx)
	Event.Instance:Fire("UpdateShowCharacter", infoRole, updateArrow)

	if updateArrow then
		self:UpdateDot()
	elseif RoleRDL.NewRDL.IsNewRole(infoRole) then
		self:UpdateDot()
	end
end

function DlgCharacterThin:UpdateDot()
	local hasDot = false

	for _, v in ipairs(self.listRole) do
		if v.hold then
			if self.pageType == THIN_PAGE_TYPE.Fitting then
				if RoleRDL.FittingRDL.IsHasNewAvatar(v) then
					hasDot = true

					break
				end
			elseif self.pageType == THIN_PAGE_TYPE.Role and RoleRDL.IsShowDot(v.id) then
				hasDot = true

				break
			end
		end
	end

	if self.hasDot ~= hasDot then
		SetActiveWithState(self, "GoDot", hasDot)

		self.hasDot = hasDot
	end
end
