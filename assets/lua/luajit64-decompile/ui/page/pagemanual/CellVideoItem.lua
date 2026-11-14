-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/CellVideoItem.lua

require("UI/Item/UIItemBase")

CellVideoItem = class("CellVideoItem", UIItemBase)

function CellVideoItem:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellVideoItem:OnEnter(vParam)
	local g = self.UIRootObject

	self.VideoImage = GOUtil.FindChildComponent(g, "VideoImage", "Image")
	self.Play = GOUtil.FindChildGameObject(g, "Play")
	self.NameNormalBg = GOUtil.FindChildGameObject(g, "NameNormalBg")
	self.NameDownloadBg = GOUtil.FindChildGameObject(g, "NameDownloadBg")
	self.New = GOUtil.FindChildGameObject(g, "New")
	self.Downloading = GOUtil.FindChildGameObject(g, "Downloading")
	self.lock = GOUtil.FindChildGameObject(g, "lock")
	self.PointDownload = GOUtil.FindChildGameObject(g, "PointDownload")
	self.NameText = GOUtil.FindChildComponent(g, "NameText", "Text")
	self.BG = GOUtil.FindChildComponent(g, "BG", "Image")
	self.DownloadText = GOUtil.FindChildComponent(g, "Downloading/Text", "Text")
	self.downFill = GOUtil.FindChildComponent(g, "Downloading/downFill", "Image")
	self.AwardBtn = GOUtil.FindChildGameObject(g, "AwardBtn")
	self.AwardIcon = GOUtil.FindChildComponent(g, "AwardBtn/Icon", "Image")
	self.AwardCount = GOUtil.FindChildComponent(g, "AwardBtn/Text", "Text")
	self.AwardImg1 = GOUtil.FindChildComponent(self.AwardBtn, "bg", "Image")
	self.AwardImg2 = GOUtil.FindChildComponent(self.AwardBtn, "Image", "Image")
	self.Animator = GOUtil.FindChildComponent(g, "AwardBtn", "Animator")

	self:AddListener(self.BG.gameObject, self.OnCellClick, EventTriggerType.PointerClick)
	self:AddListener(self.AwardBtn, self.OnClickGetAward, EventTriggerType.PointerClick)
end

function CellVideoItem:OnLeave()
	self:RemoveListener(self.BG.gameObject, self.OnCellClick, EventTriggerType.PointerClick)
	self:RemoveListener(self.AwardBtn, self.OnClickGetAward, EventTriggerType.PointerClick)

	if self.data and self.data.ID then
		OptionDownMgr:RemoveCallback(self.data.ID, 3)
	end

	UnloadAllImageSprite(self)

	self.data = nil
	self.callback = nil
end

function CellVideoItem:UpdateData(data, callback)
	self.UIRootObject:SetActive(true)

	self.DownloadText.text = _("Desc_Downloading")

	if self.data and self.data.ID then
		OptionDownMgr:RemoveCallback(self.data.ID, 3)
	end

	self.data = data
	self.callback = callback
	self.curType = 1

	local list = CollectionManager.videoAwardList

	self:SetAwardBtn(not table.contains(list, self.data.ID) and ChapterMgr:GetStage(self.data.UnlockStageId):IsPass())
	UIUtil.SetImageSprite(self.AwardIcon, ItemManager:GetIcon(self.data.Award[1][1]), self.page)

	self.AwardCount.text = "x" .. self.data.Award[1][2]

	if not self.curImage or self.curImage and self.curImage ~= self.data.ImagePath then
		self.curImage = self.data.ImagePath

		UIUtil.SetImageSprite(self.VideoImage, self.data.ImagePath, self.page)
	end

	self.NameText.text = Lang(self.data.Name)

	if not ChapterMgr:GetStage(self.data.UnlockStageId):IsPass() then
		self.lock:SetActive(true)
		self.Play:SetActive(false)
		self.New:SetActive(false)
		self.PointDownload:SetActive(false)
		self.Downloading:SetActive(false)
		self.NameNormalBg:SetActive(true)
		self.NameDownloadBg:SetActive(false)

		self.NameText.text = "？？？"
		self.BG.color = getColorFromString("76BEC6")
		self.curType = 1
	elseif OptionDownMgr:CheckVideoExist(self.data.BundleName) or not AppConst.AssetBundleMode then
		self.lock:SetActive(false)
		self.Play:SetActive(true)
		self.New:SetActive(false)
		self.PointDownload:SetActive(false)
		self.Downloading:SetActive(false)
		self.NameNormalBg:SetActive(true)
		self.NameDownloadBg:SetActive(false)

		self.BG.color = getColorFromString("76BEC6")
		self.curType = 2
	elseif OptionDownMgr:CheckIsDownload(self.data.ID, 3) then
		self.lock:SetActive(false)
		self.Play:SetActive(false)
		self.New:SetActive(false)
		self.PointDownload:SetActive(false)
		self.Downloading:SetActive(true)
		self.NameNormalBg:SetActive(false)
		self.NameDownloadBg:SetActive(true)

		self.BG.color = getColorFromString("E6C7AA")

		self:AddCallback()

		self.curType = 3
	else
		self.lock:SetActive(false)
		self.Play:SetActive(false)
		self.New:SetActive(false)
		self.PointDownload:SetActive(true)
		self.Downloading:SetActive(false)
		self.NameNormalBg:SetActive(true)
		self.NameDownloadBg:SetActive(false)

		self.BG.color = getColorFromString("76BEC6")
		self.curType = 4
	end
end

function CellVideoItem:HideSelf()
	if self.data and self.data.ID then
		OptionDownMgr:RemoveCallback(self.data.ID, 3)
	end

	self.data = nil
	self.callback = nil

	self.UIRootObject:SetActive(false)
end

function CellVideoItem:AddCallback()
	local function DownloadFinsh()
		self.New:SetActive(true)

		if self.callback then
			self.callback()
		end
	end

	local function DownloadError()
		if self.callback then
			self.callback()
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), _("Desc_NoNetwork"), vCallBack, _("UI_OK"), nil, false)
	end

	local function UpdateProgress(value, str)
		self.downFill.fillAmount = value
		self.DownloadText.text = _("Desc_Downloading")
	end

	OptionDownMgr:AddCallback(self.data.ID, DownloadFinsh, DownloadError, UpdateProgress, self.openFrom)
end

function CellVideoItem:OnCellClick(data)
	if self.curType == 1 then
		if self.data.UnlockStageId > 0 then
			local infoStage = ChapterMgr:GetStage(self.data.UnlockStageId)
			local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)
			local str
			local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)

			if infoChapter ~= nil and infoChapter.data.Type == 1 and i ~= nil and j ~= nil then
				local strStage = "<color=yellow>" .. i .. "-" .. j .. "</color>"

				str = _("eBattleType_1") .. strStage .. Lang(infoStage.data.Name) .. " " .. _("Prompt_TutorialLimitStage")
			elseif infoChapter ~= nil and infoChapter.data.Type ~= 1 and i ~= nil and j ~= nil then
				local strStage = "<color=yellow>" .. Lang(i) .. "-" .. Lang(j) .. "</color>"

				str = strStage .. Lang(infoStage.data.Name) .. " " .. _("Prompt_TutorialLimitStage")
			end

			UIMgr.ShowMsg(str)
		end
	elseif self.curType == 2 then
		Event.Instance:Fire("PlayStroyVideo", self.data.Path)
	elseif self.curType == 3 then
		OptionDownMgr:CancelOptionalDownload(self.data.ID, 3)

		if self.callback then
			self.callback()
		end

		self.curType = 4
	elseif self.curType == 4 then
		self:RequestDownload()
	end
end

function CellVideoItem:RequestDownload()
	local function DownloadFinsh()
		if self.callback then
			self.callback()
		end
	end

	local function DownloadError()
		if self.callback then
			self.callback()
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), _("Desc_NoNetwork"), vCallBack, _("UI_OK"), nil, false)
	end

	local function UpdateProgress(value, str)
		self.downFill.fillAmount = value
		self.DownloadText.text = _("Desc_Downloading")
	end

	local function cb(index, isWifi)
		if index == DlgCommonEvent.ButtonType.OkNoMoreTips then
			OptionDownMgr.needTips = false
		end

		if index == DlgCommonEvent.ButtonType.Ok or index == DlgCommonEvent.ButtonType.OkNoMoreTips then
			self.lock:SetActive(false)
			self.Play:SetActive(false)
			self.New:SetActive(false)
			self.PointDownload:SetActive(false)
			self.Downloading:SetActive(true)
			self.NameNormalBg:SetActive(false)
			self.NameDownloadBg:SetActive(true)

			self.BG.color = getColorFromString("E6C7AA")
			self.curType = 3

			OptionDownMgr:RequestDownloadVideo(self.data.ID, DownloadFinsh, DownloadError, UpdateProgress, self.data.BundleName)
		end
	end

	if tostring(Application.internetReachability) == "ReachableViaCarrierDataNetwork" and OptionDownMgr.needTips then
		local strContent = _("Desc_NetworkChange")

		UIMgr.ShowCommon(DlgCommonEvent.Type.TodayNoMoreTips, _("Desc_Alert"), {
			strContent
		}, cb, _("UI_OK"), _("Quite_Cancel"))
	else
		cb(1)
	end
end

function CellVideoItem:OnClickGetAward()
	if not self.canGet then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	NetManager:RequestGetCollectionAward(eCollectionAwardType.VIDEO, {
		self.data.ID
	}, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			table.insert(CollectionManager.videoAwardList, self.data.ID)
			Event.Instance:Fire("UpdateRedDot")
			self:SetAwardBtn(false)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function CellVideoItem:SetAwardBtn(canGet)
	if table.contains(CollectionManager.videoAwardList, self.data.ID) then
		self.AwardBtn:SetActive(false)

		return
	end

	self.AwardBtn:SetActive(true)

	self.canGet = canGet

	local gray = TenaryOp(canGet, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.AwardImg1, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.AwardImg2, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.AwardIcon, gray))

	if canGet then
		self.Animator:Play("Award_Get", 0, 0)
		GOUtil.SetTextColor(self.AwardCount.gameObject, 193, 115, 158)
	else
		self.Animator:Play("Empty", 0, 0)
		GOUtil.SetTextColor(self.AwardCount.gameObject, 88, 94, 109)
	end
end
