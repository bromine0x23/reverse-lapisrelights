-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFriend/DlgFriendAddPanel.lua

DlgFriendAddPanel = class("DlgFriendAddPanel", UIPanel)

function DlgFriendAddPanel:ctor()
	self.UIPrefabPath = "UI/PanelFriend/PanelAdd"
end

function DlgFriendAddPanel:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PanelFriend/CellFriend")
end

function DlgFriendAddPanel:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgFriendAddPanel:OnLeave()
	ResourceMgr.Unload(self.PrefabCell)

	if self.UIScrollToolRec then
		self.UIScrollToolRec:Purge()

		self.UIScrollToolRec = nil
	end

	if self.UIScrollToolReq then
		self.UIScrollToolReq:Purge()

		self.UIScrollToolReq = nil
	end

	if self.UIScrollToolRes then
		self.UIScrollToolRes:Purge()

		self.UIScrollToolRes = nil
	end
end

function DlgFriendAddPanel:OnRegisterEvent()
	self:AddClick(self.BtnSearch, self.OnClickBtnSearch)
	self:AddClick(self.BtnCancel, self.OnClickBtnCancel, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnApply, self.OnClickBtnApply)
	self:AddClick(self.BtnChange, self.OnClickBtnChange)
	self:AddClick(self.BtnAgree, self.OnClickBtnAgree)
	self:AddClick(self.BtnRefuse, self.OnClickBtnRefuse)
	self:AddClick(self.Btn_more, self.OnClickBtnMore)
	self:AddClick(self.GuideBtn, self.OnClickedGuideBtn)
	Event.Instance:Add("RefreshFriendRequestPanel", self.UpdateRequestPanel, self)
	Event.Instance:Add("RefreshFriendRecommdPanel", self.UpdateRecomPanel, self)
	Event.Instance:Add("RefreshFriendSearchPanel", self.UpdateResultPanel, self)
end

function DlgFriendAddPanel:OnUnRegisterEvent()
	self:RemoveClick(self.BtnSearch, self.OnClickBtnSearch)
	self:RemoveClick(self.BtnCancel, self.OnClickBtnCancel)
	self:RemoveClick(self.BtnApply, self.OnClickBtnApply)
	self:RemoveClick(self.BtnChange, self.OnClickBtnChange)
	self:RemoveClick(self.BtnAgree, self.OnClickBtnAgree)
	self:RemoveClick(self.BtnRefuse, self.OnClickBtnRefuse)
	self:RemoveClick(self.Btn_more, self.OnClickBtnMore)
	self:RemoveClick(self.GuideBtn, self.OnClickedGuideBtn)
	Event.Instance:Remove("RefreshFriendRequestPanel", self.UpdateRequestPanel, self)
	Event.Instance:Remove("RefreshFriendRecommdPanel", self.UpdateRecomPanel, self)
	Event.Instance:Remove("RefreshFriendSearchPanel", self.UpdateResultPanel, self)
end

function DlgFriendAddPanel:OnEnter(vParam)
	self:DealWithLocalization()

	self.PanelRecom = self:GetChildGameObject("Panel/Recom")
	self.PanelRequest = self:GetChildGameObject("Panel/Request")
	self.PanelResult = self:GetChildGameObject("Panel/Result")
	self.InputField = self:GetChildComponent("Panel/Search/InputField", "InputField")
	self.BtnCancel = self:GetChildGameObject("Panel/Search/BtnCancel")
	self.BtnSearch = self:GetChildGameObject("Panel/Search/BtnSearch")
	self.BtnApply = self:GetChildGameObject("Panel/Recom/BtnApply")
	self.BtnChange = self:GetChildGameObject("Panel/Recom/BtnChange")
	self.Btn_more = self:GetChildGameObject("Panel/Result/BgScroll/Btn_more")

	SetActiveFunc(self.Btn_more, false)

	self.goScrollArea = self:GetChildGameObject("Panel/Result/BgScroll/ScrollArea")
	self.goContent = self:GetChildGameObject("Panel/Result/BgScroll/ScrollArea/Content")
	self.ScrollAreaHeight = GOUtil.GetRectTransformSizeDeltaHeight(self.goScrollArea)
	self.BtnAgree = self:GetChildGameObject("Panel/Request/BtnAgree")
	self.BtnRefuse = self:GetChildGameObject("Panel/Request/BtnRefuse")
	self.BtnAgreeDisable = self:GetChildGameObject("Panel/Request/BtnAgree/Image")
	self.BtnRefuseDisable = self:GetChildGameObject("Panel/Request/BtnRefuse/Image")
	self.GuideBtn = self:GetChildGameObject("Panel/bg_title2/GuideBtn")
	self.GoNoRecommond = self:GetChildGameObject("Panel/Recom/BgScroll/Text")
	self.GoNoRequest = self:GetChildGameObject("Panel/Request/BgScroll/Text")
	self.TextSearchPrompt = self:GetChildComponent("Panel/Result/BgScroll/Text", "Text")
	self.TextSearchPrompt.text = _("Desc_None_Player_Search")

	local function wrap_cb(str)
		self:OnInputValueChanged(str)
	end

	self.InputField.onValueChanged:AddListener(wrap_cb)
end

function DlgFriendAddPanel:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Search/BtnSearch/Text", "Text")

	Text.text = _("UI_Search")
	Text = self:GetChildComponent("Panel/Recom/Title/Text", "Text")
	Text.text = _("System_Recommend")
	Text = self:GetChildComponent("Panel/Recom/BtnApply/Text", "Text")
	Text.text = _("Desc_Friend_AllApply")
	Text = self:GetChildComponent("Panel/Request/Title/Text", "Text")
	Text.text = _("UI_Apply_List")
	Text = self:GetChildComponent("Panel/Request/BtnRefuse/Text", "Text")
	Text.text = _("Desc_Friend_AllRefuse")
	Text = self:GetChildComponent("Panel/Request/BtnAgree/Text", "Text")
	Text.text = _("Desc_Friend_AllPass")
	Text = self:GetChildComponent("Panel/Result/Title/Text", "Text")
	Text.text = _("Search_Result")
	Text = self:GetChildComponent("Panel/Recom/BgScroll/Text", "Text")
	Text.text = Lang(12515)
	Text = self:GetChildComponent("Panel/Request/BgScroll/Text", "Text")
	Text.text = Lang(12516)
	Text = self:GetChildComponent("Panel/Result/BgScroll/Btn_more/Text", "Text")
	Text.text = _("Desc_ClickAddMorePlayer")
	Text = self:GetChildComponent("Panel/Search/InputField/Placeholder", "Text")
	Text.text = _("Desc_Input_Player_Info")
end

function DlgFriendAddPanel:Show()
	SetActiveFunc(self.UIRootObject, true)
	self:UpdatePanel()
end

function DlgFriendAddPanel:Hide()
	SetActiveFunc(self.UIRootObject, false)
end

function DlgFriendAddPanel:UpdatePanel()
	self:UpdateShowPanel()

	if FriendMgr:IsSearching() then
		self:UpdateResultPanel()
	else
		self:UpdateRecomPanel()
		self:UpdateRequestPanel()
	end
end

function DlgFriendAddPanel:UpdateShowPanel()
	local isSearching = FriendMgr:IsSearching()

	SetActiveFunc(self.PanelRecom, not isSearching)
	SetActiveFunc(self.PanelRequest, not isSearching)
	SetActiveFunc(self.PanelResult, isSearching)
end

function DlgFriendAddPanel:UpdateRecomPanel()
	self.listRecommend = FriendMgr:SortFriend(FriendMgr:GetRecommendList())

	SetActiveFunc(self.GoNoRecommond, #self.listRecommend == 0)

	if self.initRec then
		self.UIScrollToolRec:UpdateListData(self.listRecommend)
	else
		self:InitRecList()

		self.initRec = true
	end
end

function DlgFriendAddPanel:InitRecList()
	local scrollArea = self:GetChildGameObject("Panel/Recom/BgScroll/ScrollArea")
	local content = self:GetChildComponent("Panel/Recom/BgScroll/ScrollArea/Content", "RectTransform")
	local count = #self.listRecommend

	local function cb()
		Event.Instance:Fire("RefreshFriendRecommdPanel")
	end

	local function updateCallback(item, index)
		local infoPlayer = self.listRecommend[index]

		item:UpdateData(infoPlayer, eFLType.recommond, cb)
	end

	self.UIScrollToolRec = UIScrollTool()

	self.UIScrollToolRec:InitList(scrollArea, content, count, self.PrefabCell, CellFriend, self, false, nil, updateCallback)
end

function DlgFriendAddPanel:AddCellClick()
	return
end

function DlgFriendAddPanel:UpdateRequestPanel()
	self.listRequest = FriendMgr:GetApplyList()

	SetActiveFunc(self.GoNoRequest, #self.listRequest == 0)

	local gray = TenaryOp(#self.listRequest > 0, 0, 1)

	GOUtil.SetActive(self.BtnAgreeDisable, gray == 1)
	GOUtil.SetActive(self.BtnRefuseDisable, gray == 1)

	if self.initReq then
		self.UIScrollToolReq:UpdateListDataKeepPos(self.listRequest)
	else
		self:InitReqList()

		self.initReq = true
	end
end

function DlgFriendAddPanel:InitReqList()
	local scrollArea = self:GetChildGameObject("Panel/Request/BgScroll/ScrollArea")
	local content = self:GetChildComponent("Panel/Request/BgScroll/ScrollArea/Content", "RectTransform")
	local count = #self.listRequest

	local function cb()
		Event.Instance:Fire("RefreshFriendRequestPanel")
	end

	local function updateCallback(item, index)
		local infoPlayer = self.listRequest[index]

		item:UpdateData(infoPlayer, eFLType.request, cb)
	end

	self.UIScrollToolReq = UIScrollTool()

	self.UIScrollToolReq:InitList(scrollArea, content, count, self.PrefabCell, CellFriend, self, false, nil, updateCallback)
end

function DlgFriendAddPanel:OnClickBtnApply()
	if #self.listRecommend == 0 then
		UIMgr.ShowMsg(Lang(12515))

		return
	end

	local list = {}

	for i = 1, #self.listRecommend do
		local info = self.listRecommend[i]

		if FriendMgr:IsCanRequestAgain(info.id, true) then
			table.insert(list, info.id)
		end
	end

	if #list == 0 then
		UIMgr.ShowMsg(_("Msg_Requested_Today"))

		return
	end

	local data = {
		listId = list,
		callback = function()
			self:UpdateRecomPanel()
		end
	}

	Event.Instance:Fire("OperateAddFriend", data)
end

function DlgFriendAddPanel:OnClickBtnChange()
	local leftTime = FriendMgr:RefreshRecoverTime()

	if leftTime > 0 then
		UIMgr.ShowMsg(string.format(Lang(26000036), tostring(leftTime)))

		return
	else
		FriendMgr:SetLastChangeRecommendTime()
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			self:UpdateRecomPanel()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestRecommendList(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgFriendAddPanel:OnClickBtnAgree()
	local data = {
		type = 1,
		listInfo = self.listRequest,
		callback = function()
			self:UpdateRequestPanel()
		end
	}

	Event.Instance:Fire("OperatePlayerRequest", data)
end

function DlgFriendAddPanel:OnClickBtnRefuse()
	local data = {
		type = 2,
		listInfo = self.listRequest,
		callback = function()
			self:UpdateRequestPanel()
		end
	}

	Event.Instance:Fire("OperatePlayerRequest", data)
end

function DlgFriendAddPanel:UpdateResultPanel()
	self.listSearch = FriendMgr:GetSearchList()

	if FriendMgr:IsSearching() then
		self.InputField.text = FriendMgr.keyWord
	end

	GOUtil.SetActive(self.TextSearchPrompt, #self.listSearch == 0)
	self:InitResList()
end

function DlgFriendAddPanel:InitResList()
	if self.initRes then
		self.UIScrollToolRes:UpdateListDataKeepPos(self.listSearch)

		return
	end

	self.initRes = true

	local scrollArea = self:GetChildGameObject("Panel/Result/BgScroll/ScrollArea")
	local content = self:GetChildComponent("Panel/Result/BgScroll/ScrollArea/Content", "RectTransform")
	local count = #self.listSearch

	local function cb()
		Event.Instance:Fire("RefreshFriendSearchPanel")
	end

	local function updateCallback(item, index)
		local infoPlayer = self.listSearch[index]

		item:UpdateData(infoPlayer, eFLType.search, cb)
	end

	self.UIScrollToolRes = UIScrollTool()

	self.UIScrollToolRes:InitList(scrollArea, content, count, self.PrefabCell, CellFriend, self, false, nil, updateCallback)

	self.IsShowLoad = false

	function self.UIScrollToolRes.ScrollView.onScrollBottomCb(offBottom)
		if #self.listSearch == 0 or #self.listSearch % 20 ~= 0 then
			return
		end

		if offBottom > 0 then
			if offBottom >= 60 then
				self.IsShowLoad = true

				GOUtil.SetRectTransformSizeDeltaHeight(self.goScrollArea, self.ScrollAreaHeight - 70)
				self.UIScrollToolRes.ScrollView:SetViewBounds()
			end
		elseif self.IsShowLoad then
			self.IsShowLoad = false

			GOUtil.SetRectTransformSizeDeltaHeight(self.goScrollArea, self.ScrollAreaHeight)
			self.UIScrollToolRes.ScrollView:SetViewBounds()
		end

		GOUtil.SetActive(self.Btn_more, self.IsShowLoad)
	end
end

function DlgFriendAddPanel:OnClickBtnMore()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			if #vMsg.player ~= 0 then
				self:UpdateResultPanel()
			end

			self:ResetScrollView()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestSearchFriend(self.InputField.text, self.listSearch[#self.listSearch].pb.logoutTime, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgFriendAddPanel:OnClickBtnSearch()
	local keyWord = self.InputField.text

	if string.isNullOrEmpty(keyWord) then
		UIMgr.ShowMsg(Lang(12517))

		return
	end

	local cb

	do
		local isSearching = FriendMgr:IsSearching()

		function cb()
			if not isSearching then
				self:UpdateShowPanel()
			end
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			FriendMgr:SetKeyWord(keyWord)

			if #vMsg.player == 0 then
				if keyWord == PlayerInst.InfoPlayer.name or keyWord == tostring(PlayerInst.InfoPlayer.pid) then
					UIMgr.ShowMsg(Lang(12518))

					return
				else
					UIMgr.ShowMsg(Lang(12519))
				end
			end

			cb()
			self:UpdateResultPanel()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestSearchFriend(keyWord, 0, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgFriendAddPanel:OnClickBtnCancel()
	if string.isNullOrEmpty(self.InputField.text) then
		return
	end

	self.InputField.text = ""

	self:CancelSearchPanel()
end

function DlgFriendAddPanel:OnInputValueChanged(inputStr)
	if string.isNullOrEmpty(inputStr) then
		self:CancelSearchPanel()
	end
end

function DlgFriendAddPanel:CancelSearchPanel()
	if FriendMgr:IsSearching() then
		FriendMgr:ClearKeyWord()
		SetActiveFunc(self.PanelRecom, true)
		self:UpdateRecomPanel()
		SetActiveFunc(self.PanelRequest, true)
		self:UpdateRequestPanel()
		SetActiveFunc(self.PanelResult, false)
	end

	self:ResetScrollView()
end

function DlgFriendAddPanel:ResetScrollView()
	if self.IsShowLoad then
		self.IsShowLoad = false

		GOUtil.SetRectTransformSizeDeltaHeight(self.goScrollArea, self.ScrollAreaHeight)
		self.UIScrollToolRes.ScrollView:SetViewBounds()
		GOUtil.SetActive(self.Btn_more, false)
	end
end

function DlgFriendAddPanel:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Friend)
end
