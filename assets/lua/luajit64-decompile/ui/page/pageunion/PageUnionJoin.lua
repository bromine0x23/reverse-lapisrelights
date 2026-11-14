-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/PageUnionJoin.lua

require("UI/Page/PageUnion/CellUnion")
require("UI/Page/PageUnion/PageUnionCreate")

local unionTypeData = require("luaData/ClubType")

PageUnionJoin = class("PageUnionJoin", UIPanel)

function PageUnionJoin:ctor()
	self.UIPrefabPath = "UI/PanelUnion/PanelUnionJoin"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_JoinUnion"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageUnionJoin:PreLoad()
	self:LoadResAsync("UI/PanelUnion/CellUnion", "PrefabCellUnion", GameObject)
end

function PageUnionJoin:OnBack()
	UIMgr.PopPanel()
end

function PageUnionJoin:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellUnion)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	UITweenUtil.RemoveTween(self.content.transform)
end

function PageUnionJoin:OnRegisterEvent()
	self:AddClick(self.BtnApply, self.OnClickedBtnApply)
	self:AddClick(self.BtnSearch, self.OnClickedBtnSearch)
	self:AddClick(self.BtnCancel, self.OnClickedBtnCancel, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnCreate, self.OnClickedBtnCreate)
	self:AddClick(self.BtnRefresh, self.OnClickedBtnRefresh)
	self:AddClick(self.BtnQuickJoin, self.OnClickedBtnQuickJoin, PATH_SFX_UI_CANCEL)
end

function PageUnionJoin:OnUnRegisterEvent()
	self:RemoveClick(self.BtnApply, self.OnClickedBtnApply)
	self:RemoveClick(self.BtnSearch, self.OnClickedBtnSearch)
	self:RemoveClick(self.BtnCancel, self.OnClickedBtnCancel)
	self:RemoveClick(self.BtnCreate, self.OnClickedBtnCreate)
	self:RemoveClick(self.BtnRefresh, self.OnClickedBtnRefresh)
	self:RemoveClick(self.BtnQuickJoin, self.OnClickedBtnQuickJoin)
end

function PageUnionJoin:OnEnter()
	self:DealWithLocalization()

	self.PanelUnionInfo = self:GetChildGameObject("PanelUnionInfo")
	self.UnionInfoAni = self:GetChildComponent("PanelUnionInfo", "Animator")
	self.UnionAvatarBg = self:GetChildComponent("PanelUnionInfo/UnionRole", "Image")
	self.UnionAvatar = self:GetChildComponent("PanelUnionInfo/UnionRole/Icon", "Image")
	self.UnionID = self:GetChildComponent("PanelUnionInfo/UnionID/TextID", "Text")
	self.UnionLevel = self:GetChildComponent("PanelUnionInfo/UnionLevel/TxtLevel", "Text")
	self.UnionName = self:GetChildComponent("PanelUnionInfo/UnionName/Text", "Text")
	self.UnionPeopleNum = self:GetChildComponent("PanelUnionInfo/UnionDetail/People/Text", "Text")
	self.UnionHeadNick = self:GetChildComponent("PanelUnionInfo/UnionDetail/Head/Text", "Text")
	self.UnionTypeName = self:GetChildComponent("PanelUnionInfo/UnionDetail/Type/Icon/Text", "Text")
	self.UnionJoinLevel = self:GetChildComponent("PanelUnionInfo/BtnApply/TextLimit", "Text")
	self.UnionNotice = self:GetChildComponent("PanelUnionInfo/UnionDetail/Notice/Text", "Text")
	self.BtnApply = self:GetChildGameObject("PanelUnionInfo/BtnApply")
	self.ImgBtnApply = GOUtil.GetComponent(self.BtnApply, "Image")
	self.TxtInput = self:GetChildComponent("PanelUnionList/Search/InputField", "InputField")

	local function wrap_cb(str)
		self:OnInputValueChanged(str)
	end

	self.TxtInput.onValueChanged:AddListener(wrap_cb)

	self.BtnSearch = self:GetChildGameObject("PanelUnionList/Search/BtnSearch")
	self.BtnCancel = self:GetChildGameObject("PanelUnionList/Search/BtnCancel")
	self.BtnCreate = self:GetChildGameObject("PanelUnionList/Event/BtnCreate")
	self.BtnRefresh = self:GetChildGameObject("PanelUnionList/Event/BtnChange")
	self.BtnQuickJoin = self:GetChildGameObject("PanelUnionList/Event/BtnQuickJoin")

	self:InitData()
end

function PageUnionJoin:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("PanelUnionInfo/UnionID/Text", "Text")
	Text.text = _("Union_ID")
	Text = self:GetChildComponent("PanelUnionInfo/UnionLevel/Text", "Text")
	Text.text = _("Union_Level")
	Text = self:GetChildComponent("PanelUnionInfo/UnionDetail/Title/Text", "Text")
	Text.text = _("Desc_Union_Detail")
	Text = self:GetChildComponent("PanelUnionInfo/UnionDetail/People/Title/Text", "Text")
	Text.text = _("Union_Member_Num")
	Text = self:GetChildComponent("PanelUnionInfo/UnionDetail/Head/Title/Text", "Text")
	Text.text = Lang(6000)
	Text = self:GetChildComponent("PanelUnionInfo/UnionDetail/Type/Title/Text", "Text")
	Text.text = _("Union_Attribution")
	Text = self:GetChildComponent("PanelUnionInfo/BtnApply/Text", "Text")
	Text.text = _("UI_Apply_Join")
	Text = self:GetChildComponent("PanelUnionList/Search/BtnSearch/Text", "Text")
	Text.text = _("UI_Search")
	Text = self:GetChildComponent("PanelUnionList/Event/BtnCreate/Text", "Text")
	Text.text = _("UI_Create")
	Text = self:GetChildComponent("PanelUnionList/Event/BtnQuickJoin/Text", "Text")
	Text.text = _("UI_Quick_Join")
	Text = self:GetChildComponent("PanelUnionList/Search/InputField/Placeholder", "Text")
	Text.text = _("Msg_Union_Name_Input")
end

function PageUnionJoin.RequestData(cb)
	local function wrap_cb(Msg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if Msg.result.code == NetManager.Result_Sucess then
			if cb then
				cb()
			end
		else
			UIMgr.ShowMsg(Msg.result.desc, Msg)
		end
	end

	local listId

	if #UnionListMgr.listUnion ~= 0 then
		listId = {}

		for _, v in ipairs(UnionListMgr.listUnion) do
			table.insert(listId, v.id)
		end
	end

	NetManager:RequestUnionList(nil, listId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageUnionJoin:InitData()
	self.curPanelType = UnionListMgr.UnionListType.Common

	self:UpdatePanel()
end

function PageUnionJoin:UpdatePanel()
	self:InitPanel()

	self.unionIdx = 1

	if #self.listUnion > 0 then
		self:UpdateSelectUnionInfo()
	end

	self:UpdateScrollView()
end

function PageUnionJoin:InitPanel()
	local isCommon = self.curPanelType == UnionListMgr.UnionListType.Common

	if isCommon then
		self.listUnion = UnionListMgr.listUnion
	else
		self.listUnion = UnionListMgr.listSearchUnion
	end

	GOUtil.SetActive(self.BtnRefresh, isCommon)
	GOUtil.SetActive(self.BtnQuickJoin, #self.listUnion ~= 0 and isCommon)
	GOUtil.SetActive(self.PanelUnionInfo, #self.listUnion ~= 0)
end

function PageUnionJoin:UpdateScrollView(keepPos)
	if self.UIScrollTool then
		if keepPos then
			self.UIScrollTool:UpdateListDataKeepPos(self.listUnion)
		else
			self.UIScrollTool:UpdateListData(self.listUnion)
		end

		return
	end

	local scrollArea = self:GetChildGameObject("PanelUnionList/ScrollArea")

	self.content = self:GetChildComponent("PanelUnionList/ScrollArea/Content", "RectTransform")

	local count = #self.listUnion

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local infoUnion = self.listUnion[index]

		item:UpdateData(infoUnion, self.unionIdx)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCellUnion, CellUnion, self, false, addCallback, updateCallback)
	UITweenUtil.DoListAnimationUp(self.content.transform, 300, 0.3, nil, nil)
end

function PageUnionJoin:OnClickedCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if index == self.unionIdx then
		return
	end

	local preIdx = self.unionIdx

	self.unionIdx = index

	self.UIScrollTool:UpdateCellSelect(preIdx, index)
	self:UpdateSelectUnionInfo()
	self.UnionInfoAni:Play("PanelUnionInfo_show", 0, 0)
end

function PageUnionJoin:UpdateSelectUnionInfo()
	local infoUnion = self.listUnion[self.unionIdx]
	local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(infoUnion.pb.type)

	SetImageSprite(self.UnionAvatar, avatarPath, self)

	local bgPath = UnionTypeMgr:GetUnionTypeBgIcon(infoUnion.pb.type)

	SetImageSprite(self.UnionAvatarBg, bgPath, self)

	self.UnionID.text = infoUnion.id
	self.UnionLevel.text = infoUnion.curLevel
	self.UnionName.text = infoUnion:GetName()
	self.UnionPeopleNum.text = infoUnion.curMemberNum .. "/" .. infoUnion.maxMemberNum
	self.UnionHeadNick.text = infoUnion:GetOwnerName()
	self.UnionTypeName.text = UnionTypeMgr:GetUnionTypeName(infoUnion.pb.type)

	local str = string.format(_("Msg_Union_Level_Recruit"), "<size=29>" .. infoUnion.joinLevel .. "</size>")

	if infoUnion.joinLevel == 0 then
		str = _("Mail_NoLimit")
	end

	self.UnionJoinLevel.text = str
	self.UnionNotice.text = infoUnion:GetNotice()

	local canApply = FuncOperablity:CanApplyJoin(infoUnion)
	local gray = TenaryOp(canApply, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnApply, gray))
end

function PageUnionJoin:OnClickedBtnSearch()
	local keyword = self.TxtInput.text

	if keyword == "" then
		UIMgr.ShowMsg(_("Msg_Union_Name_Input"))

		return
	end

	self.curPanelType = UnionListMgr.UnionListType.Search

	local function wrap_cb(Msg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if Msg.result.code == NetManager.Result_Sucess then
			local listUnion = UnionListMgr.listSearchUnion

			if #listUnion == 0 then
				UIMgr.ShowMsg(_("Msg_Union_Null_Search"))
			end

			self:UpdatePanel()
		else
			UIMgr.ShowMsg(Msg.result.desc, Msg)
		end
	end

	NetManager:RequestUnionList(keyword, nil, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageUnionJoin:OnClickedBtnCancel()
	if string.isNullOrEmpty(self.TxtInput.text) then
		return
	end

	self.TxtInput.text = ""

	if self.curPanelType == UnionListMgr.UnionListType.Search then
		self.curPanelType = UnionListMgr.UnionListType.Common

		self:UpdatePanel()
	end
end

function PageUnionJoin:OnInputValueChanged(str)
	if self.curPanelType == UnionListMgr.UnionListType.Search and string.isNullOrEmpty(str) then
		self.TxtInput.text = ""
		self.curPanelType = UnionListMgr.UnionListType.Common

		self:UpdatePanel()
	end
end

function PageUnionJoin:OnClickedBtnRefresh()
	local isCanPull, second = UnionListMgr:IsCanPullUnions()

	if not isCanPull then
		UIMgr.ShowMsg(string.format(_("Msg_Union_Fast_Refresh"), tostring(second)))

		return
	end

	local function wrap_cb(Msg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if Msg.result.code == NetManager.Result_Sucess then
			self:UpdatePanel()
			UnionListMgr:SetLastPullTime()
		else
			UIMgr.ShowMsg(Msg.result.desc, Msg)
		end
	end

	NetManager:RequestUnionList(nil, nil, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageUnionJoin:OnClickedBtnApply()
	local infoUnion = self.listUnion[self.unionIdx]
	local canApply, msg = FuncOperablity:CanApplyJoin(infoUnion)

	if not canApply then
		UIMgr.ShowMsg(msg)

		return
	end

	if LocalTimeDownNetManagerShow("P162_Response_5", 2) then
		return
	end

	self:RequestJoinUnion(1)
end

function PageUnionJoin:OnClickedBtnQuickJoin()
	self:RequestJoinUnion(2)
end

function PageUnionJoin:JPSendJionUnionDataToAppsfly(result)
	local infoUnion = self.listUnion[self.unionIdx]
	local charactorID = unionTypeData[infoUnion.pb.type].CharacterId

	AppsFlyerService.SendJoinClub(result, charactorID)
end

function PageUnionJoin:RequestJoinUnion(option)
	local clubId = self.listUnion[self.unionIdx].id

	if option == 2 then
		clubId = nil
	end

	local function wrap_cb(Msg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if Msg.result.code == NetManager.Result_Sucess then
			if UnionMgr.HasUnion() then
				self:JPSendJionUnionDataToAppsfly(1)
				UIMgr.SwitchPanel(PageUnion)

				return
			elseif option == 1 then
				self:JPSendJionUnionDataToAppsfly(0)
				UIMgr.ShowMsg(_("Msg_Sucess_Apply_1"))
				self.listUnion[self.unionIdx]:AddApply(PlayerInst.InfoPlayer.pid)
			end
		elseif Msg.result.code == 6 then
			self:JPSendJionUnionDataToAppsfly(0)
			UIMgr.ShowMsg(_("Msg_Union_Joined"))

			local function cb()
				UIMgr.SwitchPanel(PageUnion)
			end

			PageUnion.RequestData(cb)

			return
		else
			self:JPSendJionUnionDataToAppsfly(0)
			UIMgr.ShowMsg(Msg.result.desc, Msg)
		end

		self:RequestLastUnionList()
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestApplyJoinUnion(option, clubId, wrap_cb)
end

function PageUnionJoin:RequestLastUnionList()
	local listId = {}

	for _, v in ipairs(self.listUnion) do
		table.insert(listId, v.id)
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.UIScrollTool:UpdateListDataKeepPos(self.listUnion)
			self:UpdateSelectUnionInfo()
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestUnionList(nil, listId, wrap_cb, self.curPanelType)
end

function PageUnionJoin:OnClickedBtnCreate()
	if UnionMgr.HasUnion() then
		UIMgr.ShowMsg(_("Msg_Union_Joined"))

		return
	end

	UIMgr.SwitchPanel(PageUnionCreate)
end

function PageUnionJoin:OnClickedBtnGuide()
	require("UI/Dlg/Public/GuideChooseTip")
	UIMgr.AddPanel(GuideChooseTip(), {
		guideType = "UnionGuide"
	})
end
