-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/PagePictureTask.lua

require("Info/InfoCollection")
require("UI/Page/PageManual/CellPicTask")
require("UI/Page/PageManual/CellPicTab")

PagePictureTask = class("PagePictureTask", UIPanel)

function PagePictureTask:ctor()
	self.UIPrefabPath = "UI/PageManual/PagePictureTask"

	self:AddChildPanel(DlgExit(), {
		title = _("Desc_Figure"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PagePictureTask:OnBack()
	if self.newUnlock then
		UIMgr.PopPanel(nil, 2)
	else
		UIMgr.PopPanel()
	end

	CollectionManager.curSelectTaskId = nil
end

function PagePictureTask:PreLoad()
	self:LoadResAsync("UI/PageManual/CellPicTab", "PrefabCellTab", GameObject)
	self:LoadResAsync("UI/PageManual/CellPicTask", "PrefabCellTask", GameObject)
end

function PagePictureTask:Purge()
	self.base.Purge(self)
	UITweenUtil.RemoveTween(self.content)

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	ResourceMgr.Unload(self.PrefabCellTab)
	ResourceMgr.Unload(self.PrefabCellTask)

	if self.UITabScrollTool then
		self.UITabScrollTool:Purge()
	end

	self.UITabScrollTool = nil

	if self.UITaskScrollTool then
		self.UITaskScrollTool:Purge()
	end

	self.UITaskScrollTool = nil

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	local DlgUnlockTask = UIMgr.GetPanel("DlgUnlockTask")

	if DlgUnlockTask then
		DlgUnlockTask:Close()

		DlgUnlockTask = nil
	end
end

function PagePictureTask:OnRegisterEvent()
	self:AddClick(self.Icon.gameObject, self.OnClickFinalTask)
	self:AddClick(self.ActiveBtn, self.OnClickActiveBtn)
	self:AddClick(self.BtnL, self.OnClickLeft)
	self:AddClick(self.BtnR, self.OnClickRight)
	Event.Instance:Add("ClickPoolTab", self.OnClickPoolTab, self)
	Event.Instance:Add("UpdatePicTask", self.UpdatePicTask, self)
	Event.Instance:Add("OpenDlgIllustration", self.OpenDlgIllustration, self)
end

function PagePictureTask:OnUnRegisterEvent()
	self:RemoveClick(self.Icon.gameObject, self.OnClickFinalTask)
	self:RemoveClick(self.ActiveBtn, self.OnClickActiveBtn)
	self:RemoveClick(self.BtnL, self.OnClickLeft)
	self:RemoveClick(self.BtnR, self.OnClickRight)
	Event.Instance:Remove("ClickPoolTab", self.OnClickPoolTab, self)
	Event.Instance:Remove("UpdatePicTask", self.UpdatePicTask, self)
	Event.Instance:Remove("OpenDlgIllustration", self.OpenDlgIllustration, self)
end

function PagePictureTask:OnEnter(vParam)
	self:DealWithLocalization()

	self.roleId = vParam.roleId
	self.infoRole = RoleMgr:GetRole(self.roleId)
	self.newUnlock = vParam.newUnlock
	self.Name = self:GetChildComponent("BG/ImageBg/ItemInfo/Name", "Text")
	self.Desc = self:GetChildComponent("BG/ImageBg/ItemInfo/Desc/Scroll View/Viewport/Content", "Text")
	self.DescContent = self:GetChildGameObject("BG/ImageBg/ItemInfo/Desc")
	self.Icon = self:GetChildComponent("BG/ImageBg/ItemInfo/Icon", "Image")
	self.Fill = self:GetChildComponent("BG/ImageBg/ItemInfo/Image/Fill", "Image")
	self.ProgText = self:GetChildComponent("BG/ImageBg/ItemInfo/Image/ProgText", "Text")
	self.ActiveBtn = self:GetChildGameObject("BG/ImageBg/ItemInfo/ActiveBtn")
	self.ImgBtn = self:GetChildComponent("BG/ImageBg/ItemInfo/ActiveBtn", "Image")
	self.IsActive = self:GetChildGameObject("BG/ImageBg/ItemInfo/IsActive")
	self.Animator = self:GetChildComponent("", "Animator")
	self.BtnL = self:GetChildGameObject("Panel/GoArrow/BtnL")
	self.BtnR = self:GetChildGameObject("Panel/GoArrow/BtnR")
	self.BtnLDot = GOUtil.FindChildGameObject(self.BtnL, "Dot")
	self.BtnRDot = GOUtil.FindChildGameObject(self.BtnR, "Dot")

	local tabCount = CollectionManager:GetRoleTaskTabCount(self.roleId)

	self.listTab = {}

	for i = 1, tabCount do
		local data = {}

		data.name = _("PicTaskName_" .. i)

		table.insert(self.listTab, data)
	end

	if vParam.itemId then
		CollectionManager.curSelectTaskId = CollectionManager:GetInfoIDByAvatar(self.roleId, vParam.itemId)
	end

	if CollectionManager.curSelectTaskId ~= nil then
		local info = CollectionManager:Get(CollectionManager.curSelectTaskId)

		self.selectIndex = info.data.PageIndex

		local list = CollectionManager:GetInfoListByPage(self.roleId, self.selectIndex)

		table.sort(list, function(a, b)
			return a[1].data.type < b[1].data.type
		end)

		for i, v in ipairs(list) do
			if v[1].data.type == info.data.type then
				self.pageIndex = i

				break
			end
		end
	else
		self.selectIndex = 1
		self.pageIndex = 1
	end

	self.tabPageGo = self:GetChildGameObject("Panel/PageIndex")
	self.PageUITab = UITab(self.tabPageGo, 7, self.TabPageClick, self, self.pageIndex)
	self.PageTabs = {}

	for i = 1, 7 do
		self.PageTabs[i] = GOUtil.FindChildGameObject(self.tabPageGo, "Btn" .. i)
	end

	self:UpdatePanel()
	self:InitTabScrollView()
	self:InitTaskScrollView()
end

function PagePictureTask:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Tital/Tital", "Text")
	txt.text = _("Desc_TaskList")
	txt = self:GetChildComponent("BG/ImageBg/ItemInfo/Tital", "Text")
	txt.text = _("Desc_TaskList")
	txt = self:GetChildComponent("BG/ImageBg/ItemInfo/Tital", "Text")
	txt.text = _("Desc_FinalReward")
	txt = self:GetChildComponent("BG/ImageBg/ItemInfo/ActiveBtn/Text", "Text")
	txt.text = _("PageTalentTree_Active")
end

function PagePictureTask:UpdatePanel()
	self.pageInfoList = CollectionManager:GetInfoListByPage(self.roleId, self.selectIndex)

	table.sort(self.pageInfoList, function(a, b)
		return a[1].data.type < b[1].data.type
	end)

	if #self.pageInfoList > 1 then
		self.tabPageGo:SetActive(true)

		for i = 1, #self.PageTabs do
			if i <= #self.pageInfoList then
				self.PageTabs[i]:SetActive(true)
			else
				self.PageTabs[i]:SetActive(false)
			end
		end

		if self.PageUITab.index == 1 then
			self.BtnL:SetActive(false)
			self.BtnR:SetActive(true)
		elseif self.PageUITab.index == #self.pageInfoList then
			self.BtnL:SetActive(true)
			self.BtnR:SetActive(false)
		else
			self.BtnL:SetActive(true)
			self.BtnR:SetActive(true)
		end
	else
		self.BtnL:SetActive(false)
		self.BtnR:SetActive(false)
		self.tabPageGo:SetActive(false)
	end

	self.infoList = self.pageInfoList[self.pageIndex]

	table.sort(self.infoList, function(a, b)
		return a.data.figureId[2] < b.data.figureId[2]
	end)

	self.finalTask = self.infoList[#self.infoList]

	table.remove(self.infoList, #self.infoList)

	self.Name.text = Lang(self.finalTask.data.Name)
	self.Desc.text = Lang(self.finalTask.data.Desc)

	UIUtil.SetImageSprite(self.Icon, self.finalTask.data.IconPath, self, false)

	self.curNum = 0
	self.totalNum = #self.infoList

	for i, v in ipairs(self.infoList) do
		if v:IsGetAward() then
			self.curNum = self.curNum + 1
		end
	end

	self.Fill.fillAmount = self.curNum / self.totalNum
	self.ProgText.text = self.curNum .. "/" .. self.totalNum

	if self.finalTask:IsGetAward() then
		self.IsActive:SetActive(true)
		self.ActiveBtn:SetActive(false)
		self.DescContent.gameObject:SetActive(true)
	else
		self.IsActive:SetActive(false)
		self.ActiveBtn:SetActive(true)
		self.DescContent.gameObject:SetActive(false)

		local gray = TenaryOp(self.curNum == self.totalNum, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtn, gray))
	end

	CollectionManager.curSelectTaskId = self.infoList[TenaryOp(self.curNum == self.totalNum, 1, self.curNum + 1)].data.ID

	if #self.pageInfoList ~= 1 then
		local info = self.pageInfoList[self.pageIndex][1]

		if info then
			local LHas, RHas = ManualRDL.NotesRDL.HasCanRecvLOrR(self.infoRole, info.data.PageIndex, info.data.type)

			GOUtil.SetActive(self.BtnLDot, LHas)
			GOUtil.SetActive(self.BtnRDot, RHas)
		end
	end
end

function PagePictureTask:UpdateTaskScroll()
	local pos = GetContentPos(self.UITaskScrollTool.ScrollView, self.totalNum, TenaryOp(self.curNum == self.totalNum, 1, self.curNum + 1), true)

	self.UITaskScrollTool:SetInitPos(Vector3(0, pos, 0))
	self.UITaskScrollTool:SetContentPosImmediate(Vector2(0, -pos), self.infoList)

	self.pos = pos
end

function PagePictureTask:InitTabScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea2")
	local content = self:GetChildComponent("Panel/ScrollArea2/Content", "Transform")
	local count = #self.listTab

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		local info = {}

		info.tabName = self.listTab[index].name

		item:UpdateData(info, self.selectIndex)

		local path = string.format(GetNodesPath(3), self.infoRole.data.Team, self.roleId, item.Index)

		item:SetDot(path)
	end

	self.UITabScrollTool = UIScrollTool()

	self.UITabScrollTool:InitList(ScrollArea, content, count, self.PrefabCellTab, CellPicTab, self, false, addClick, updateTab)
end

function PagePictureTask:InitTaskScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")

	self.content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")

	local count = #self.infoList

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		local info = self.infoList[index]

		item:UpdateData(info)
	end

	self.UITaskScrollTool = UIScrollTool()

	self.UITaskScrollTool:InitList(ScrollArea, self.content, count, self.PrefabCellTask, CellPicTask, self, false, addClick, updateTab)

	local pos = GetContentPos(self.UITaskScrollTool.ScrollView, self.totalNum, TenaryOp(self.curNum == self.totalNum, 1, self.curNum + 1), true)

	self.UITaskScrollTool:SetInitPos(Vector3(0, pos, 0))
	UITweenUtil.DoPosAnimationUp(self.content, 300, 0.3, pos)
end

function PagePictureTask:OnClickPoolTab(index)
	if index == self.selectIndex then
		return
	end

	self.selectIndex = index

	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)

	self.pageIndex = 1
	self.PageUITab.index = 1

	self.PageUITab:Update()
	self:UpdatePanel()
	self:UpdateTaskScroll()
	UITweenUtil.RemoveTween(self.content)

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	self.content.gameObject:SetActive(false)

	self.timer = TimerMgr.AddTimer(eTimerType.FrameCount, 2, function()
		self.content.gameObject:SetActive(true)
		UITweenUtil.DoPosAnimationUp(self.content, 300, 0.3, self.pos)
	end, nil)

	self.Animator:Play("PagePictureTask_show", 0, 0)
end

function PagePictureTask:OnClickLeft()
	self.PageUITab.index = self.PageUITab.index - 1

	self.PageUITab:Update()
	self:TabPageClick()
end

function PagePictureTask:OnClickRight()
	self.PageUITab.index = self.PageUITab.index + 1

	self.PageUITab:Update()
	self:TabPageClick()
end

function PagePictureTask:TabPageClick()
	self.pageIndex = self.PageUITab.index

	self:UpdatePanel()
	self:UpdateTaskScroll()
	UITweenUtil.RemoveTween(self.content)

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	self.content.gameObject:SetActive(false)

	self.timer = TimerMgr.AddTimer(eTimerType.FrameCount, 2, function()
		self.content.gameObject:SetActive(true)
		UITweenUtil.DoPosAnimationUp(self.content, 300, 0.3, self.pos)
	end, nil)

	self.Animator:Play("PagePictureTask_show", 0, 0)
end

function PagePictureTask:OnClickFinalTask()
	if self.finalTask:IsGetAward() then
		local item = ItemManager:GetValueItem(self.finalTask.data.Reward[1][2], self.finalTask.data.Reward[1][3], nil, self.finalTask.data.Reward[1][4])
		local type = item:GetType()

		if type == eItemType.P_HEAD then
			require("UI/Page/PagePlayerInfo/PagePlayer")

			local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Player)

			if not isOpen then
				return
			end

			UIMgr.SwitchPanel(PagePlayer, {
				SwitchHead = self.finalTask.data.Reward[1][2]
			})
		elseif type == eItemType.P_HEAD_FRAME then
			require("UI/Page/PagePlayerInfo/PagePlayer")

			local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Player)

			if not isOpen then
				return
			end

			UIMgr.SwitchPanel(PagePlayer, {
				SwitchHeadFrame = self.finalTask.data.Reward[1][2]
			})
		elseif type == eItemType.R_AVATAR then
			local infoAvatar = AvatarManager:GetAvatar(self.finalTask.data.Reward[1][3])

			if infoAvatar.data.Slot[1] == "Weapon" then
				require("UI/Page/PageEquipment/PageEquipAvatar")
				UIMgr.SwitchPanel(PageEquipAvatar, {
					roleId = self.roleId,
					avatarId = self.finalTask.data.Reward[1][3]
				})
			else
				require("UI/Page/PageFittingroom/PageFittingroom")
				UIMgr.SwitchPanel(PageFittingroom, {
					infoRole = RoleMgr:GetRole(self.roleId),
					avatarId = self.finalTask.data.Reward[1][3]
				})
			end
		elseif type == eItemType.R_PICTURE then
			self:OpenDlgIllustration(self.finalTask.data.Reward[1][2], self.roleId)
		end
	end
end

function PagePictureTask:OnClickActiveBtn()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			local info = CollectionManager:Get(self.finalTask.data.ID)

			info:SetData(self.finalTask.data.ID)

			if info.data.Reward[1] and info.data.Reward[1][1] == 2 then
				local infoRole = RoleMgr:GetRole(self.roleId)

				infoRole:AddExtraSkillData({
					level = 1,
					id = info.data.Reward[1][2]
				})
				require("UI.Page.PageRoleCard.Dlg.DlgUpResult")
				UIMgr.AddPanel(DlgUpResult(), {
					index = 6,
					addAttr = info.data.Reward[1][2],
					infoRole = self.infoRole
				})
			end

			CollectionManager:AddNewOpenTask(self.finalTask.data.ID)
			self:UpdatePicTask()
		elseif vPBMessage.result.code == NetManager.Result_Timeout then
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		else
			UIMgr.ShowMsg(_("TipsNoFactor"))
		end
	end

	NetManager:RequestFinishIllustratedTask(self.finalTask.data.ID, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PagePictureTask:UpdatePicTask()
	self.curNum = 0
	self.totalNum = #self.infoList

	for i, v in ipairs(self.infoList) do
		if v:IsGetAward() then
			self.curNum = self.curNum + 1
		end
	end

	self.Fill.fillAmount = self.curNum / self.totalNum
	self.ProgText.text = self.curNum .. "/" .. self.totalNum

	self.UITaskScrollTool:UpdateListDataKeepPos(self.infoList)
	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)

	if self.finalTask:IsGetAward() then
		self.IsActive:SetActive(true)
		self.ActiveBtn:SetActive(false)
		self.DescContent.gameObject:SetActive(true)
	else
		self.IsActive:SetActive(false)
		self.ActiveBtn:SetActive(true)
		self.DescContent.gameObject:SetActive(false)

		local gray = TenaryOp(self.curNum == self.totalNum, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtn, gray))
	end
end

function PagePictureTask:OpenDlgIllustration(itemId, roleId)
	local list = CollectionManager:GetIllustrationInfo(roleId)

	for k, v in pairs(list) do
		if v.ID == itemId then
			require("UI/Page/PageManual/DlgIllustration")
			UIMgr.AddPanel(DlgIllustration(), {
				data = v
			})

			break
		end
	end
end
