-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/PageImpression.lua

require("Info/InfoCollection")
require("UI/Page/PageManual/CellPicTab")
require("UI/Page/PageManual/CellFinalSkill")
require("UI/Page/PageManual/CellCollectionRole")
require("UI/Page/PageManual/DlgCardTimeLineView")

PageImpression = class("PageImpression", UIPanel)

function PageImpression:ctor()
	self.UIPrefabPath = "UI/PageManual/PageImpression"
	self.DlgExit = DlgExit()

	self:AddChildPanel(self.DlgExit, {
		title = _("Desc_Videos"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})

	self.DlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.DlgAssetsInfo)

	self.DlgCardTimeLineView = DlgCardTimeLineView()

	self:AddChildPanel(self.DlgCardTimeLineView, {
		beginCallback = function()
			self.canvasGroup.alpha = 0
			self.canvasGroup.blocksRaycasts = false

			self.effect:SetActive(false)
			self.Fx_UI_009_2:SetActive(false)
		end,
		endCallback = function()
			self.canvasGroup.alpha = 1
			self.Transition.color = Color.New(1, 1, 1, 1)

			SetActiveFunc(self.Transition, true)
			GOUtil.DOFade(self.Transition, 0, 0.7, DG.Tweening.Ease.Linear)
			TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
				self.canvasGroup.blocksRaycasts = true

				self.effect:SetActive(true)
				self.Fx_UI_009_2:SetActive(#self.AwardList > 0)
				SetActiveFunc(self.Transition, false)
			end, nil)
		end
	})
end

function PageImpression:PreLoad()
	self:LoadResAsync("UI/PageManual/CellPicTab", "PrefabCellTab", GameObject)
	self:LoadResAsync("UI/PageManual/CellCollectionRole", "PrefabCellRole", GameObject)
	self:LoadResAsync("UI/PageManual/CellFinalSkill", "PrefabCellSkill", GameObject)
end

function PageImpression:OnBack()
	UIMgr.PopPanel()
end

function PageImpression:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
	ResourceMgr.Unload(self.PrefabCellTab)
	ResourceMgr.Unload(self.PrefabCellRole)
	ResourceMgr.Unload(self.PrefabCellSkill)

	if self.UITabScrollTool then
		self.UITabScrollTool:Purge()
	end

	self.UITabScrollTool = nil

	if self.UISkillScrollTool then
		self.UISkillScrollTool:Purge()
	end

	self.UISkillScrollTool = nil

	if self.UIRoleScrollTool then
		self.UIRoleScrollTool:Purge()
	end

	self.UIRoleScrollTool = nil

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function PageImpression:OnRegisterEvent()
	for i = 1, 8 do
		self:AddClick(self.listIllItem[i].go, self.OnClickIllItem)
		self:AddClick(self.listIllItem[i].AwardBtn, self.OnClickPictureAward)
	end

	self:AddClick(self.Illustration, self.OnClickCloseIll)
	self:AddClick(self.BtnOneKey, self.OnClickBtnOneKey)
	Event.Instance:Add("ClickPoolTab", self.OnClickPoolTab, self)
	Event.Instance:Add("PlayCardTimeLine", self.OnClickPlayCardSkill, self)
	Event.Instance:Add("UpdateRedDot", self.UpdateRedDot, self)
end

function PageImpression:OnUnRegisterEvent()
	for i = 1, 8 do
		self:RemoveClick(self.listIllItem[i].go, self.OnClickIllItem)
		self:RemoveClick(self.listIllItem[i].AwardBtn, self.OnClickPictureAward)
	end

	self:RemoveClick(self.Illustration, self.OnClickCloseIll)
	self:RemoveClick(self.BtnOneKey, self.OnClickBtnOneKey)
	Event.Instance:Remove("ClickPoolTab", self.OnClickPoolTab, self)
	Event.Instance:Remove("PlayCardTimeLine", self.OnClickPlayCardSkill, self)
	Event.Instance:Remove("UpdateRedDot", self.UpdateRedDot, self)
end

function PageImpression:OnEnter(vParam)
	self:DealWithLocalization()

	self.tabTypeGo = self:GetChildGameObject("Panel/TypeBtn")
	self.TypeUITab = UITab(self.tabTypeGo, 2, self.UpdataPageData, self, 1)
	self.ImageContent = self:GetChildGameObject("Panel/Content")
	self.effect = self:GetChildGameObject("FX_UI_Common_Glow")
	self.canvasGroup = self:GetChildComponent("", "CanvasGroup")
	self.listTeamData = TeamMgr.Instance:GetTeamList()
	self.Transition = self:GetChildComponent("Transition", "Image")
	self.BtnOneKey = self:GetChildGameObject("Panel/TypeBtn/BtnOneKey")
	self.ImgOneKey = self:GetChildComponent("Panel/TypeBtn/BtnOneKey", "Image")
	self.Fx_UI_009_2 = self:GetChildGameObject("Panel/TypeBtn/BtnOneKey/Fx_UI_009_2")
	self.listTab = {}

	for i = 1, #self.listTeamData do
		if self.listTeamData[i].ManualVersion == 1 then
			table.insert(self.listTab, self.listTeamData[i])
		end
	end

	self.listIllItem = {}

	for i = 1, 8 do
		local IllItem = {}

		IllItem.go = self:GetChildGameObject("Panel/Content/" .. i)
		IllItem.Text = GOUtil.FindChildComponent(IllItem.go, "Text", "Text")
		IllItem.Lock = GOUtil.FindChildGameObject(IllItem.go, "Lock")
		IllItem.Icon = GOUtil.FindChildComponent(IllItem.go, "", "Image")
		IllItem.AwardBtn = GOUtil.FindChildGameObject(IllItem.go, "AwardBtn")
		IllItem.AwardIcon = GOUtil.FindChildComponent(IllItem.go, "AwardBtn/Icon", "Image")
		IllItem.AwardCount = GOUtil.FindChildComponent(IllItem.go, "AwardBtn/Text", "Text")
		IllItem.Animator = GOUtil.FindChildComponent(IllItem.go, "AwardBtn", "Animator")
		IllItem.AwardImg1 = GOUtil.FindChildComponent(IllItem.go, "AwardBtn/bg", "Image")
		IllItem.AwardImg2 = GOUtil.FindChildComponent(IllItem.go, "AwardBtn/Image", "Image")

		table.insert(self.listIllItem, IllItem)
	end

	self.selectIndex = 1

	self:InitTabScrollView()
	self:InitRoleScrollView()
	self:InitSkillScrollView()
	self:UpdatePanel()
end

function PageImpression:DealWithLocalization()
	return
end

function PageImpression:UpdatePanel()
	self.listRole = TeamMgr.Instance:GetInfoRoleList(self.listTab[self.selectIndex].ID)
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

	self:UpdateTypeRed()
	self:UpdataPageData(true)
end

function PageImpression:InitTabScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea2")
	local content = self:GetChildComponent("Panel/ScrollArea2/Content", "Transform")
	local count = #self.listTab

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		local info = {}

		info.Path = self.listTab[index].ManualIcon

		item:UpdateImage(info, self.selectIndex)

		local path = string.format("Arrow/Manual/Video/%d", self.listTab[index].ID)

		item:SetDot(path)
	end

	self.UITabScrollTool = UIScrollTool()

	self.UITabScrollTool:InitList(ScrollArea, content, count, self.PrefabCellTab, CellPicTab, self, false, addClick, updateTab)
end

function PageImpression:InitRoleScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollAreaRole")
	local content = self:GetChildComponent("Panel/ScrollAreaRole/Content", "Transform")
	local count = 0

	local function ListUpdate(item, index)
		local data = self.listRole[index]

		item:UpdateData(data, self.curIndex == index, self.TypeUITab.index)
	end

	local function AddClick(item)
		self:AddClick(item.UIRootObject, function()
			local go = item.UIRootObject
			local info = self.UIRoleScrollTool.ItemRoot2ItemDict:GetValue(go)

			self.curInfoRole = self.listRole[info.Item.Index]
			self.curIndex = info.Item.Index

			for k, v in self.UIRoleScrollTool.ItemRoot2ItemDict:Enumerator() do
				v.Item:SetSelectImage(v.Item.Index == self.curIndex)
			end

			self:UpdataPageData()
		end)
	end

	self.UIRoleScrollTool = UIScrollTool()

	self.UIRoleScrollTool:InitList(ScrollArea, content, count, self.PrefabCellRole, CellCollectionRole, self, true, AddClick, ListUpdate)
end

function PageImpression:InitSkillScrollView()
	self.SkillScrollArea = self:GetChildGameObject("Panel/ScrollAreaSkill")

	local content = self:GetChildComponent("Panel/ScrollAreaSkill/Content", "Transform")
	local count = 0

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		local info = self.roleCardList[index]

		item:UpdateData(info)
	end

	self.UISkillScrollTool = UIScrollTool()

	self.UISkillScrollTool:InitList(self.SkillScrollArea, content, count, self.PrefabCellSkill, CellFinalSkill, self, false, addClick, updateTab)
end

function PageImpression:UpdataPageData(notKeep)
	if self.TypeUITab.index == 1 then
		self.SkillScrollArea:SetActive(true)
		self.ImageContent:SetActive(false)

		self.roleCardList = RoleCardMgr:GetRoleAllCard(self.curInfoRole.id)

		while #self.roleCardList < 6 do
			table.insert(self.roleCardList, {
				isEmpty = true
			})
		end

		self.UISkillScrollTool:UpdateListData(self.roleCardList)
	else
		self.SkillScrollArea:SetActive(false)
		self.ImageContent:SetActive(true)
		self:UpdateIllustration()
	end

	if notKeep == true then
		self.UIRoleScrollTool:UpdateListData(self.listRole)
	else
		self.UIRoleScrollTool:UpdateListDataKeepPos(self.listRole)
	end

	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)
	self:UpdateBtnOneKey()
end

function PageImpression:OnClickPoolTab(index)
	if index == self.selectIndex then
		return
	end

	self.selectIndex = index

	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)
	self:UpdatePanel()
end

function PageImpression:OnClickPlayCardSkill(info)
	self.DlgCardTimeLineView:Play(info.infoRole, info.skillId)
end

function PageImpression:UpdateIllustration()
	local function fun(isUnlock, isGetAward, v)
		local canGet = isUnlock and not isGetAward

		if isGetAward then
			v.AwardBtn:SetActive(false)

			return
		end

		v.AwardBtn:SetActive(true)

		local gray = TenaryOp(canGet, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(v.AwardImg1, gray))
		DealWithListRef(self, UIUtil.SetImageGray(v.AwardImg2, gray))
		DealWithListRef(self, UIUtil.SetImageGray(v.AwardIcon, gray))

		v.canGet = canGet

		if canGet then
			v.Animator:Play("Award_Get", 0, 0)
			GOUtil.SetTextColor(v.AwardCount.gameObject, 193, 115, 158)
		else
			v.Animator:Play("Empty", 0, 0)
			GOUtil.SetTextColor(v.AwardCount.gameObject, 88, 94, 109)
		end
	end

	self.pictureAwardList = {}
	self.illustrationDataList = CollectionManager:GetIllustrationInfo(self.curInfoRole.id)

	table.sort(self.illustrationDataList, function(a, b)
		if a.Type == b.Type then
			return a.ID < b.ID
		else
			return a.Type < b.Type
		end
	end)

	for i, v in ipairs(self.listIllItem) do
		if self.illustrationDataList[i] then
			v.go:SetActive(true)
			UIUtil.SetImageSprite(v.Icon, self.illustrationDataList[i].IconPath, self, false)

			v.Text.text = Lang(self.illustrationDataList[i].Name)

			local isUnlock = table.contains(self.curInfoRole.pb.pictures, self.illustrationDataList[i].ID)
			local isGetAward = table.contains(CollectionManager.pictureAwardList, self.illustrationDataList[i].ID)

			v.Lock:SetActive(not isUnlock)

			local canGet = isUnlock and not isGetAward

			fun(isUnlock, isGetAward, v)

			if canGet then
				table.insert(self.pictureAwardList, self.illustrationDataList[i].ID)
			end

			UIUtil.SetImageSprite(v.AwardIcon, ItemManager:GetIcon(self.illustrationDataList[i].Award[1][1]), self)

			v.AwardCount.text = "x" .. self.illustrationDataList[i].Award[1][2]
		else
			v.go:SetActive(false)
		end
	end
end

function PageImpression:OnClickIllItem(data)
	local index = tonumber(data.pointerPress.gameObject.name)
	local data = self.illustrationDataList[index]

	if table.contains(self.curInfoRole.pb.pictures, data.ID) then
		UIMgr.HideMsg()
		require("UI/Page/PageManual/DlgIllustration")
		UIMgr.AddPanel(DlgIllustration(), {
			data = data
		})
	else
		UIMgr.ShowMsg(_("TipsNoFactorIllustration"))
	end
end

function PageImpression:OnClickPictureAward(data)
	local index = tonumber(data.pointerPress.gameObject.transform.parent.name)

	if not self.listIllItem[index].canGet then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	local infoData = self.illustrationDataList[index]

	self.curPressObj = data.pointerPress.gameObject

	NetManager:RequestGetCollectionAward(eCollectionAwardType.PICTURE, {
		infoData.ID
	}, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			table.insert(CollectionManager.pictureAwardList, infoData.ID)
			self:UpdateRedDot()
			self.curPressObj:SetActive(false)

			self.curPressObj = nil
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end, {
		self.curInfoRole.id
	})
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageImpression:UpdateTypeRed()
	self.combId = self.listTab[self.selectIndex].ID

	RedDotSystemMgr.SetUIRedDot(self.TypeUITab.btnGos[1], string.format("Arrow/Manual/Video/%d/Nirvana", self.combId))
	RedDotSystemMgr.SetUIRedDot(self.TypeUITab.selectGos[1], string.format("Arrow/Manual/Video/%d/Nirvana", self.combId))
	RedDotSystemMgr.SetUIRedDot(self.TypeUITab.btnGos[2], string.format("Arrow/Manual/Video/%d/Illustration", self.combId))
	RedDotSystemMgr.SetUIRedDot(self.TypeUITab.selectGos[2], string.format("Arrow/Manual/Video/%d/Illustration", self.combId))
end

function PageImpression:UpdateRedDot()
	self:UpdateBtnOneKey()
	self.UIRoleScrollTool:UpdateListDataKeepPos(self.listRole)
	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)
end

function PageImpression:UpdateBtnOneKey()
	self.AwardList = {}

	if self.TypeUITab.index == 1 then
		self.curType = eCollectionAwardType.FINALSKILL

		local list = ManualRDL.VideoRDL.Get_CAN_RECEIVE_NIRVANA()[self.combId]

		for roleID, listCardID in pairs(list) do
			for key, cardID in pairs(listCardID) do
				table.insert(self.AwardList, {
					cardID,
					roleID
				})
			end
		end
	else
		self.curType = eCollectionAwardType.PICTURE

		local list = ManualRDL.VideoRDL.Get_CAN_RECEIVE_ILLUSTRATION()[self.combId]

		for roleID, listPictureID in pairs(list) do
			for key, pictureID in pairs(listPictureID) do
				table.insert(self.AwardList, {
					pictureID,
					roleID
				})
			end
		end
	end

	if #self.AwardList > 0 then
		GOUtil.SetActive(self.Fx_UI_009_2, true)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PageManual/AtlasPageImpression/BTN_square_pink_01", self)
	else
		GOUtil.SetActive(self.Fx_UI_009_2, false)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PageManual/AtlasPageImpression/BTN_square_pink_02", self)
	end
end

function PageImpression:OnClickBtnOneKey()
	local rewardList = {}
	local roleList = {}

	for index, value in ipairs(self.AwardList) do
		table.insert(rewardList, value[1])
		table.insert(roleList, value[2])
	end

	if #rewardList == 0 then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	NetManager:RequestGetCollectionAward(self.curType, rewardList, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			if self.curType == eCollectionAwardType.FINALSKILL then
				table.merge(CollectionManager.skillAwardList, rewardList)
			elseif self.curType == eCollectionAwardType.PICTURE then
				table.merge(CollectionManager.pictureAwardList, rewardList)
			end

			self.UISkillScrollTool:UpdateListData(self.roleCardList)
			self:UpdateTypeRed()
			self:UpdateRedDot()
			self:UpdateIllustration()
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end, roleList)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageImpression:OnBackAndroid()
	if self.DlgCardTimeLineView:IsShow() then
		self.DlgCardTimeLineView:OnClickSkip()

		return true
	end

	return false
end
