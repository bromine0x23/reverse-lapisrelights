-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/PageAddressBookNew.lua

require("UI/Page/PageCommunication/CellAddressNew")
require("UI/Page/PageCommunication/CellCommunicationPage")

PageAddressBookNew = class("PageAddressBookNew", UIPanel)

local PageCellCount = 6

function PageAddressBookNew:ctor()
	self.UIPrefabPath = "UI/PageCommunication/PageAddressBookNew"

	self:AddChildPanel(DlgExit(), {
		type = 2,
		title = _("eReturn_commc"),
		callback = self.OnBack,
		panel = self
	})
end

function PageAddressBookNew:PreLoad()
	self:LoadResAsync("UI/PageCommunication/CellAddressNew", "PrefabCell", GameObject)
	self:LoadResAsync("UI/PageCommunication/CellCommunicationPage", "PrefabCellPage")
end

function PageAddressBookNew:Purge()
	PageAddressBookNew.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	if self.PrefabCellPage then
		ResourceMgr.Unload(self.PrefabCellPage)

		self.PrefabCellPage = nil
	end

	if self.UIAddressScrollTool then
		self.UIAddressScrollTool:Purge()
	end

	self.UIAddressScrollTool = nil

	if self.UIPageScrollTool then
		self.UIPageScrollTool:Purge()
	end

	self.UIPageScrollTool = nil
end

function PageAddressBookNew:OnRegisterEvent()
	self:AddClick(self.Button1, self.OnClickedTag1)
	self:AddClick(self.Button2, self.OnClickedTag2)
	self:AddClick(self.ButtonModify, self.OnClickedModifyName)
	self:AddClick(self.ButtonCancel, self.OnClickedCancelName)
end

function PageAddressBookNew:OnUnRegisterEvent()
	self:RemoveClick(self.Button1, self.OnClickedTag1)
	self:RemoveClick(self.Button2, self.OnClickedTag2)
	self:RemoveClick(self.ButtonModify, self.OnClickedModifyName)
	self:RemoveClick(self.ButtonCancel, self.OnClickedCancelName)
end

function PageAddressBookNew:OnEnter(vParam)
	local teamId = 1

	if vParam then
		self.backRoleId = vParam.roleId
		teamId = RoleMgr:GetRole(vParam.roleId).data.Team
		self.initTabType = vParam.tabType
		self.initRoleId = vParam.roleId
	end

	self.Image1 = self:GetChildGameObject("Bg/Image1")
	self.Image2 = self:GetChildGameObject("Bg/Image2")
	self.teamDot = {}
	self.tabTeamGo = self:GetChildGameObject("Panel/TeamGroup/ScrollArea/Viewport/Content")
	self.TeamUITab = UITab(self.tabTeamGo, 7, self.TabTeamClick, self, teamId)
	self.tabTypeGo = self:GetChildGameObject("Panel/TypeBtn")
	self.TypeUITab = UITab(self.tabTypeGo, 2, self.TabTypeClick, self, self.initTabType)
	self.tabPageGo = self:GetChildGameObject("Panel/PageIndex")
	self.PageUITab = UITab(self.tabPageGo, 7, self.TabPageClick, self, 1)
	self.Name = self:GetChildComponent("Panel/AddressBg/Name", "InputField")
	self.Animator = self:GetChildComponent("", "Animator")
	self.PageTabs = {}

	for i = 1, 7 do
		self.PageTabs[i] = GOUtil.FindChildGameObject(self.tabPageGo, "Btn" .. i)
	end

	self.listComb = CombinationMgr:GetCombinationSortByTeamOder()

	local function wrap_cb(str)
		self:OnInputFieldChange(str)
	end

	self.Name.onEndEdit:AddListener(wrap_cb)
	self:InitAddressBookScrollView()
	self:InitPageScroll()
	self:InitData()
	self:UpdateDotTab()
	self:DealWithLocalization()
end

function PageAddressBookNew:OnBack()
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_TOPIC, {})
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, {})
	UIMgr.PopPanel()
end

function PageAddressBookNew:DealWithLocalization()
	return
end

function PageAddressBookNew:InitData()
	self:TabTeamClick()
end

function PageAddressBookNew:InitAddressBookScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = 0

	local function ListUpdate(item, index)
		local data = self.listRole[index]

		item:UpdateData(data, self.curIndex == index, self.TypeUITab.index)
	end

	local function AddClick(item)
		self:AddClick(item.UIRootObject, function()
			local go = item.UIRootObject
			local info = self.UIAddressScrollTool.ItemRoot2ItemDict:GetValue(go)

			self.curInfoRole = self.listRole[info.Item.Index]
			self.curIndex = info.Item.Index

			for k, v in self.UIAddressScrollTool.ItemRoot2ItemDict:Enumerator() do
				v.Item:SetSelectImage(v.Item.Index == self.curIndex)
			end

			self:ChangeTypeTab()
			self:UpdataPageData()
		end)
	end

	self.UIAddressScrollTool = UIScrollTool()

	self.UIAddressScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellAddressNew, self, false, AddClick, ListUpdate)
end

function PageAddressBookNew:InitPageScroll()
	local function ListUpdate(item, index)
		local data = self.ListPage[index]

		function data.callback()
			self.enterScene = true
		end

		item:UpdateData(data, self.TypeUITab.index)
	end

	local function AddClick(item, index)
		return
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollAreaPage")

	self.content = self:GetChildComponent("Panel/ScrollAreaPage/Content", "Transform")

	local count = 0

	self.UIPageScrollTool = UIScrollTool()

	self.UIPageScrollTool:InitList(scrollArea, self.content, count, self.PrefabCellPage, CellCommunicationPage, self, true, AddClick, ListUpdate)

	self.PageView = GOUtil.AddMissingComponent(scrollArea, "UIScrollViewPageView")

	local function wrap_cb(index)
		self.PageUITab.index = TenaryOp(index + 1 > self.pageCount, self.pageCount, index + 1)

		self.PageUITab:Update()
	end

	self.PageView.OnPageChanged:AddListener(wrap_cb)
end

function PageAddressBookNew:TabTeamClick()
	self.listRole = TeamMgr.Instance:GetInfoRoleList(CombinationMgr:Get(self.TeamUITab.index).data.ID)
	self.curInfoRole = self.listRole[1]
	self.curIndex = 1

	if self.initRoleId then
		for i = 1, #self.listRole do
			if self.listRole[i].id == self.initRoleId then
				self.curInfoRole = self.listRole[i]
				self.curIndex = i

				break
			end
		end

		self.initRoleId = nil
	end

	self.UIAddressScrollTool:UpdateListData(self.listRole)

	local posY = TenaryOp(self.curIndex * 208 - 904 > 0, self.curIndex * 208 - 904, 0)

	self.UIAddressScrollTool:SetContentPosImmediate(Vector2.New(0, posY), self.listRole)
	self:ChangeTypeTab()
	self:UpdataPageData()
end

function PageAddressBookNew:TabTypeClick()
	self:ChangeBackground()
	self:UpdataPageData()
	self:UpdateDotTab()
	self.UIAddressScrollTool:UpdateListDataKeepPos(self.listRole)
end

function PageAddressBookNew:ChangeBackground()
	if self.TypeUITab.index == 1 then
		self.Image1:SetActive(true)
		self.Image2:SetActive(false)
	else
		self.Image1:SetActive(false)
		self.Image2:SetActive(true)
	end
end

function PageAddressBookNew:ChangeTypeTab()
	self:ChangeBackground()
	self.TypeUITab:Update()
	self.Animator:Play("PageAddressBookNew_tag", 0, 0)
end

function PageAddressBookNew:TabPageClick()
	self.PageView:PageTo(self.PageUITab.index - 1)
end

function PageAddressBookNew:UpdataPageData()
	self.Name.text = self.curInfoRole:GetCommuName()

	if self.TypeUITab.index == 1 then
		self.listTopic = TopicManager:GetListTopic(self.curInfoRole.data.ID)
	elseif self.TypeUITab.index == 2 then
		self.listTopic = PhoneCallManager:GetListTopic(self.curInfoRole.data.ID)
	end

	self.pageCount = math.ceil(#self.listTopic / PageCellCount)
	self.ListPage = {}

	for i = 1, self.pageCount do
		local data = {}

		for j = (i - 1) * PageCellCount + 1, #self.listTopic do
			table.insert(data, self.listTopic[j])

			if #data == PageCellCount then
				break
			end
		end

		table.insert(self.ListPage, data)
	end

	if #self.ListPage == 0 then
		self.ListPage = {
			{}
		}
		self.pageCount = 1
	end

	self.UIPageScrollTool:UpdateListData(self.ListPage)

	for i = 1, #self.PageTabs do
		if i > self.pageCount then
			self.PageTabs[i]:SetActive(false)
		else
			self.PageTabs[i]:SetActive(true)
		end
	end

	self.PageUITab.index = 1

	self.PageUITab:Update()
	GOUtil.SetRectTransformAnchoredPosition(self.UIPageScrollTool.ScrollView.content.gameObject, 0, 0)
	self.PageView:RefreshPageIndex(self.pageCount)
end

function PageAddressBookNew:OnInputFieldChange(str)
	if self.curInfoRole:GetCommuName() == str then
		self.Name.text = self.curInfoRole:GetCommuName()

		return
	end

	if str == "" then
		self.Name.text = self.curInfoRole:GetCommuName()

		UIMgr.ShowMsg(_("Desc_EmptyName"))

		return
	end

	if utf8len(str) > 6 then
		self.Name.text = self.curInfoRole:GetCommuName()

		UIMgr.ShowMsg(_("Desc_NameLengthLimit"))

		return
	end

	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self.curInfoRole.pb.nickName = self.Name.text

			self.UIAddressScrollTool:UpdateListDataKeepPos(self.listRole)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)

			self.Name.text = self.curInfoRole:GetCommuName()
		end
	end

	NetManager:RequestModifyTopicName(self.curInfoRole.id, self.Name.text, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageAddressBookNew:UpdateDotTab()
	for i = 1, #self.TeamUITab.rootGos do
		local path

		if self.TypeUITab.index == 2 then
			path = "Communication/Call/" .. i
		else
			path = "Communication/News/" .. i
		end

		RedDotSystemMgr.SetUIRedDot(self.TeamUITab.rootGos[i], path)

		if i <= #self.listComb then
			self.TeamUITab.rootGos[self.listComb[i].data.ID].transform:SetSiblingIndex(i - 1)
		end
	end
end
