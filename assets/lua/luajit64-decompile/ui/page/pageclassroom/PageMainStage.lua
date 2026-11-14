-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageClassroom/PageMainStage.lua

require("UI/UIScrollTool")
require("UI/Item/UITab")
require("UI/Dlg/Public/DlgAssetsInfo")
require("UI/Dlg/Public/DlgPlayerInfoPanel")
require("UI/Page/PageClassroom/DlgMainStageCardPanel")
require("UI/Page/PageFittingroom/PageFittingroom")
require("UI/Page/PageOperation/DlgOperationActivePlayerBirthday")
require("UI/Page/PageClassroom/UIBoardAlbum")
require("UI/Page/PageClassroom/UIBoardAlbum2")
require("UI/Dlg/Public/DlgWeb")
require("UI/Page/PageOtherMenu/PageOtherMenuTop")
require("UI/Page/PageSetting/PageOption")
require("UI/Page/PageUnion/PageUnion")

systemType1 = {
	TutorialFunctionType.Union,
	TutorialFunctionType.Role,
	TutorialFunctionType.Card,
	TutorialFunctionType.DrawCard,
	TutorialFunctionType.PVP,
	TutorialFunctionType.Shop,
	TutorialFunctionType.Fight
}
systemType2 = {
	TutorialFunctionType.Task,
	0,
	TutorialFunctionType.Operation,
	TutorialFunctionType.Communication,
	TutorialFunctionType.Bondage,
	[6] = 0,
	[9] = 0,
	[7] = TutorialFunctionType.Work,
	[8] = TutorialFunctionType.Friend,
	[10] = TutorialFunctionType.Theme
}

local systemType3 = {
	TutorialFunctionType.PageRank,
	[2] = 0,
	[5] = 0,
	[3] = TutorialFunctionType.ThemeMode,
	[4] = TutorialFunctionType.Webview,
	[6] = TutorialFunctionType.Option
}
local systemType4 = {
	TutorialFunctionType.TimeTask,
	TutorialFunctionType.BossRaid,
	TutorialFunctionType.PatFace,
	TutorialFunctionType.PatFace,
	TutorialFunctionType.PatFace,
	TutorialFunctionType.PatFace
}
local adType = {
	TutorialFunctionType.Operation,
	TutorialFunctionType.OperationActive_BattlePass,
	TutorialFunctionType.Operation,
	TutorialFunctionType.Operation,
	TutorialFunctionType.Operation
}
local adType2 = {
	TutorialFunctionType.BossRaid,
	TutorialFunctionType.Operation,
	TutorialFunctionType.Boss,
	TutorialFunctionType.Operation,
	TutorialFunctionType.Operation
}
local sendReviewAgain = true

PageMainStage = class("PageMainStage", UIPanel)

function PageMainStage:ctor()
	self.UIPrefabPath = "UI/PanelMainStage/PanelMainStage"
	self.isSyncLoad = true

	self:AddChildPanel(DlgPlayerInfoPanel())

	self.dlgAssetsInfo = DlgAssetsInfo()
	self.dlgAssetsInfo.isSyncLoad = true

	self:AddChildPanel(self.dlgAssetsInfo, {
		IsPageMainStage = true
	})
	self:InitOperation()

	if OperationActiveMgr:JPIsCurrDaySmallThanGameStartDay() then
		return
	end
end

function PageMainStage:PreLoad()
	SceneMainStage.Instance.inInteraction = false

	Event.Instance:Fire("UpdateSceneDisplay", true)
	self:LoadResAsync("UI/PanelMainstage/CellAd", "PrefabCellAd", GameObject)
	self:LoadResAsync("UI/PanelMainstage/CellAd2", "PrefabCellAd2", GameObject)

	if RoleCardMgr:GetTipWindowVideoState() then
		self:LoadResAsync("UI/PanelOperation/New/DlgTipWindowVideo", "GoDlgTipWindowVideo", GameObject)
	end

	if OperationActiveMgr:IsPlayerLoginBirthday() and RoleCardMgr:GetTipWindowAwardState() == "0" then
		self:LoadResAsync("UI/PanelOperation/New/ModelDlg/CellPlayerBirthday", "GoCellPlayerBirthday", GameObject)
		self:LoadResAsync("UI/PanelOperation/New/DlgOperationActivePlayerBirthday", "GoDlgOperationActivePlayerBirthday", GameObject)
	end

	local adsList = InfoGameInst:GetTipWindowAdsList()

	self.spriteImageList = {}
	self.videoList = {}

	if RoleCardMgr:GetTipWindowOnGameState() == "1" then
		for i = 1, #adsList do
			if adsList[i].Type == 2 then
				table.insert(self.spriteImageList, adsList[i])
				self:LoadAssetsAsync(adsList[i].Resource, Sprite)
			elseif adsList[i].Type == 1 and InstructionMgr:IsGuidePassed() then
				self:LoadAssetsAsync(adsList[i].Resource, VideoClip)
				table.insert(self.videoList, adsList[i].Resource)
			end
		end

		if #self.spriteImageList ~= 0 then
			self:LoadResAsync("UI/PanelOperation/New/DlgTipWindow", "GoDlgTipWindow", GameObject)
		end

		if #self.videoList == 0 then
			RoleCardMgr:SetTipWindowVideoState("0")
		end

		if #self.spriteImageList == 0 then
			RoleCardMgr:SetTipWindowState("0")
		end
	end
end

function PageMainStage:InitOperation()
	self.allLoginPopupList = OperationActiveMgr:AllLoginPopupList()

	if table.getItemCount(self.allLoginPopupList) == 0 then
		RoleCardMgr:SetTipWindowAwardState("0")
	elseif RoleCardMgr:GetTipWindowPatFaceState() == "1" then
		RoleCardMgr:SetTipWindowAwardState("1")
	else
		RoleCardMgr:SetTipWindowAwardState("0")
	end

	if table.getItemCount(self.allLoginPopupList) ~= 0 and RoleCardMgr:GetTipWindowAwardState() == "1" and RoleCardMgr:GetTipWindowPatFaceState() == "1" then
		if InstructionMgr:IsInGuide() then
			return
		end

		local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

		if not isOpen then
			return
		end

		OperationActiveMgr.Tag = 1
		OperationActiveMgr.BattlePassTag = "Tab1"
		OperationActiveMgr.PageOperationActiveType = 2

		require("UI/Page/PageOperation/PageOperationActiveNew")

		self.PageOperationActiveNew = PageOperationActiveNew()
		self.PageOperationActiveNew.isSyncLoad = true

		self:AddChildPanel(self.PageOperationActiveNew)
	else
		self.notOpenTipWindow = true
	end
end

function PageMainStage:BoardAlbumListSort(adlist)
	local count = #adlist
	local adSelectedIdx = Mathf.Floor(count / 2) + 1
	local list = {}

	for i = 1, count do
		if adSelectedIdx <= count then
			list[adSelectedIdx] = adlist[i]
			adSelectedIdx = adSelectedIdx + 1
		end
	end

	local index = 1

	for i = table.getItemCount(list) + 1, #adlist do
		list[index] = adlist[i]
		index = index + 1
	end

	return list
end

function PageMainStage:Purge()
	self.base.Purge(self)

	if self.LimitActivityList then
		for key, value in pairs(self.LimitActivityList) do
			self:RemoveClick(value.obj, value.fun)
		end
	end

	if self.UIBoardAlbum then
		self.UIBoardAlbum:Purge()

		self.UIBoardAlbum = nil
	end

	if self.UIBoardAlbum2 then
		self.UIBoardAlbum2:Purge()

		self.UIBoardAlbum2 = nil
	end

	if SceneMainStage.Instance then
		SceneMainStage.Instance.inInteraction = true
	end

	if PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		-- block empty
	else
		Event.Instance:Fire("UpdateSceneDisplay", false)
	end

	if self.PrefabCellAd then
		ResourceMgr.Unload(self.PrefabCellAd)

		self.PrefabCellAd = nil
	end

	if self.PrefabCellAd2 then
		ResourceMgr.Unload(self.PrefabCellAd2)

		self.PrefabCellAd2 = nil
	end

	self.infoRoleBirthdayList = nil

	self:OnLeave()
	TutorialMgr:ResetRecord()
end

function PageMainStage:OnLeave()
	FingerGesturesUtil.Disable()
	Event.Instance:Fire("OnRemoveRandomIdle")
	Event.Instance:Fire(EventEnum.UpdateSceneObjectShow, false)
	Event.Instance:Fire(EventEnum.InPageMain, false)

	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)
	end

	if self.Timer3 then
		TimerMgr.RemoveTimer(self.Timer3)
	end

	if self.Timer4 then
		TimerMgr.RemoveTimer(self.Timer4)
	end

	if self.Timer5 then
		TimerMgr.RemoveTimer(self.Timer5)
	end

	if self.fAni then
		coroutine.stop(self.fAni)

		self.fAni = nil
	end

	GoodsInfoListMgr.isFirst = false
end

function PageMainStage:OnRegisterEvent()
	if self.FirstSystemGroupCount then
		for i = 1, self.FirstSystemGroupCount do
			self:AddClick(self["BtnFirstSystem" .. i], self.OnClickedBtnFirstSystem)
		end
	end

	if self.SecondSystemGroupCount then
		for j = 1, self.SecondSystemGroupCount do
			self:AddClick(self["BtnSecondSystem" .. j], self.OnClickedBtnSecondSystem)
		end
	end

	if self.ThirdSystemGroupCount then
		for k = 1, self.ThirdSystemGroupCount do
			self:AddClick(self["BtnThirdSystem" .. k], self.OnClickedBtnThirdSystem)
		end
	end

	if self.FourthSystemGroupCount then
		for n = 1, self.FourthSystemGroupCount do
			self:AddClick(self["BtnFourthSystem" .. n], self.OnClickedBtnFourthSystem)
		end
	end

	self:AddClick(self.btn_show_group2List, self.OnClickedShowGroup2List)
	self:AddClick(self.GoViceSystemOther, self.OnClickedBtnViceSystemOther)
	self:AddClick(self.TipWindow, self.OnCloseTipWindow, PATH_SFX_UI_CANCEL)
	self:AddClick(self.TipWindowBtn, self.OnCloseTipWindowOnClick)
	self:AddClick(self.TipWindowVideoButton, self.OnCloseTipWindowVideoOnClick)
	Event.Instance:Add("UpdateDotNotify", self.UpdateDotNotify, self)
	Event.Instance:Add("DealWithUIAnim", self.DealWithUIAnim, self)
	Event.Instance:Add("PageMainStageUpdatePanel", self.UpdatePanel, self)
	Event.Instance:Add("UpdateBossRaidOpen", self.UpdateBossRaidOpen, self)
	Event.Instance:Add("LuckyBackAwardBtnHide", self.LuckyBackAwardBtnHide, self)
	Event.Instance:Add("LuckyBackAwardBtnShow", self.LuckyBackAwardBtnShow, self)
	Event.Instance:Add("UpdateBossRaidTime", self.UpdateBossRaidTime, self)
	Event.Instance:Add("HideTimeLimitTaskBtnEvent", self.HideTimeLimitTaskBtnEvent, self)
	Event.Instance:Add("UpdateDailyTimeEvent", self.DailyTime, self)
	Event.Instance:Add("OpenSceneCamera", self.OpenSceneCamera, self)
	Event.Instance:Add("UpdatePopGift", self.UpdatePopGift, self)
	Event.Instance:Add("UpdateFirstCharge", self.UpdateFirstChargeOpen, self)
	Event.Instance:Add("UpdateWebViwe", self.AutoOpenWebViwe, self)
	EventListenerMgr.AddFingerGestureListener(self.OnPointerScreen, self, eFingerGestureType.Tap)
	EventListenerMgr.AddAnimListener(self.UIRootObject, self.OnAnimEnd, self, eAnimEventType.OnAnimationEnd)
end

function PageMainStage:OnUnRegisterEvent()
	if self.FirstSystemGroupCount then
		for i = 1, self.FirstSystemGroupCount do
			self:RemoveClick(self["BtnFirstSystem" .. i], self.OnClickedBtnFirstSystem)
		end
	end

	if self.SecondSystemGroupCount then
		for j = 1, self.SecondSystemGroupCount do
			self:RemoveClick(self["BtnSecondSystem" .. j], self.OnClickedBtnSecondSystem)
		end
	end

	if self.ThirdSystemGroupCount then
		for k = 1, self.ThirdSystemGroupCount do
			self:RemoveClick(self["BtnThirdSystem" .. k], self.OnClickedBtnThirdSystem)
		end
	end

	if self.FourthSystemGroupCount then
		for n = 1, self.FourthSystemGroupCount do
			self:RemoveClick(self["BtnFourthSystem" .. n], self.OnClickedBtnFourthSystem)
		end
	end

	if self.infoRoleBirthdayList then
		for i, v in pairs(self.infoRoleBirthdayList) do
			self:RemoveClick(v.obj, self.OnClickedRoleBirthday)
		end
	end

	self:RemoveClick(self.btn_show_group2List, self.OnClickedShowGroup2List)
	self:RemoveClick(self.TipWindow, self.OnCloseTipWindow)
	self:RemoveClick(self.TipWindowBtn, self.OnCloseTipWindowOnClick)
	self:RemoveClick(self.TipWindowVideoButton, self.OnCloseTipWindowVideoOnClick)
	self:RemoveClick(self.GoViceSystemOther, self.OnClickedBtnViceSystemOther)
	Event.Instance:Remove("UpdateDotNotify", self.UpdateDotNotify, self)
	Event.Instance:Remove("DealWithUIAnim", self.DealWithUIAnim, self)
	Event.Instance:Remove("PageMainStageUpdatePanel", self.UpdatePanel, self)
	Event.Instance:Remove("UpdateBossRaidOpen", self.UpdateBossRaidOpen, self)
	Event.Instance:Remove("LuckyBackAwardBtnHide", self.LuckyBackAwardBtnHide, self)
	Event.Instance:Remove("LuckyBackAwardBtnShow", self.LuckyBackAwardBtnShow, self)
	Event.Instance:Remove("UpdateBossRaidTime", self.UpdateBossRaidTime, self)
	Event.Instance:Remove("HideTimeLimitTaskBtnEvent", self.HideTimeLimitTaskBtnEvent, self)
	Event.Instance:Remove("UpdateDailyTimeEvent", self.DailyTime, self)
	Event.Instance:Remove("OpenSceneCamera", self.OpenSceneCamera, self)
	Event.Instance:Remove("UpdatePopGift", self.UpdatePopGift, self)
	Event.Instance:Remove("UpdateFirstCharge", self.UpdateFirstChargeOpen, self)
	Event.Instance:Remove("UpdateWebViwe", self.AutoOpenWebViwe, self)
	EventListenerMgr.RemoveFingerGestureListener(self.OnPointerScreen, self, eFingerGestureType.Tap)
	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.OnAnimEnd, self, eAnimEventType.OnAnimationEnd)

	if self.listAd then
		for i = 1, #self.listAd do
			self:RemoveClick(self.listAd[i], self.OnClickedGoAD)
		end

		self.listAd = nil
	end

	if self.listAd2 then
		for i = 1, #self.listAd2 do
			self:RemoveClick(self.listAd2[i], self.OnClickedGoAD2)
		end

		self.listAd2 = nil
	end
end

function PageMainStage:OnPointerScreen()
	if not self.hideUI then
		return
	end

	self.hideUI = not self.hideUI

	self:DealWithUIAnim(self.hideUI)
end

function PageMainStage:OnEnter(vParam)
	Input.multiTouchEnabled = false

	FingerGesturesUtil.Enable()
	InfoSoundEventMgr:OnBack()

	if InstructionMgr.callInId then
		require("UI.Page.PageCommunication.DlgCallIn")
		UIMgr.AddPanel(DlgCallIn(), {
			callId = InstructionMgr.callInId
		}, UIMgr.UIOverLayObject)

		InstructionMgr.callInId = nil
	end

	self.UIRootObject.transform:SetAsFirstSibling()

	if not self.SafeArea then
		self.SafeArea = self:GetChildGameObject("SafeArea")
	end

	self:SetSafeArea(self.SafeArea)

	local BottomRectImg = self:GetChildComponent("SafeArea/Group1/BottomRectImg", "RectTransform")
	local width = GOUtil.GetRectTransformWidth(self.UIRootObject)
	local height = GOUtil.GetRectTransformHeight(self.UIRootObject)
	local SafeAreaRect = self:GetChildComponent("SafeArea", "RectTransform")

	BottomRectImg.offsetMin = Vector2.New(-SafeAreaRect.anchorMin.x * width, BottomRectImg.offsetMin.y)
	BottomRectImg.offsetMax = Vector2.New((1 - SafeAreaRect.anchorMax.x) * width, BottomRectImg.offsetMax.y)
	BottomRectImg.sizeDelta = Vector2.New(BottomRectImg.sizeDelta.x, BottomRectImg.sizeDelta.y + SafeAreaRect.anchorMin.y * height)

	local topRectMask = self:GetChildComponent("SafeArea/topmask", "RectTransform")

	topRectMask.offsetMin = Vector2.New(-SafeAreaRect.anchorMin.x * width, topRectMask.offsetMin.y)
	topRectMask.offsetMax = Vector2.New((1 - SafeAreaRect.anchorMax.x) * width, topRectMask.offsetMax.y)

	BillingManager.Resume()
	Event.Instance:Fire(EventEnum.UpdateSceneObjectShow, true)
	SoundMgr.SetSwitch(PATH_SCENETYPE_GROUP, PATH_SCENETYPE_HOME, UIMgr.UICamera.gameObject)
	Event.Instance:Fire("OnAddRandomIdle")

	self.PlayerAnimator = self:GetChildComponent("DlgPlayerInfoPanel(Clone)", "Animator")
	self.AssetsAnimator = self:GetChildComponent("DlgAssetsInfo(Clone)", "Animator")
	self.RootAnimator = GOUtil.GetComponent(self.UIRootObject, "Animator")

	local next_stageInfo, next_stage_str = ChapterMgr:GetNewBieListString()

	self.next_stage = self:GetChildGameObject("SafeArea/Group1/7/next_stage")
	self.next_stage_animator = GOUtil.GetComponent(self.next_stage, "Animator")

	if next_stageInfo ~= nil and ChapterMgr:GetNextStageShow(next_stageInfo.Stage) then
		ChapterMgr.NextStageState = 1

		self.next_stage_animator:Play("nextStage_show", 0, 0)
		self.next_stage:SetActive(true)
	else
		ChapterMgr.NextStageState = 0
		self.next_stage.transform.localScale = Vector3(1, 0, 1)

		self.next_stage:SetActive(false)
	end

	self.Img_next_stage = self:GetChildComponent("SafeArea/Group1/7/next_stage/Image", "Image")
	self.Tex_next_stage = self:GetChildComponent("SafeArea/Group1/7/next_stage/Text3", "Text")

	if next_stageInfo and ChapterMgr:GetNextStageShow() then
		UIUtil.SetImageSprite(self.Img_next_stage, next_stageInfo.Icon, self, true)

		self.Tex_next_stage.text = Lang(next_stageInfo.Name) .. "\n<size=24>" .. next_stage_str .. "</size>"
	end

	self.FirstSystemGroupCount = table.getn(systemType1)

	for i = 1, self.FirstSystemGroupCount do
		self["BtnFirstSystem" .. i] = self:GetChildGameObject("SafeArea/Group1/" .. i)
		self["ImgBtnFirstSystem" .. i] = self:GetChildComponent("SafeArea/Group1/" .. i, "Image")
		self["ImgBtnFirstSystemIcon" .. i] = self:GetChildComponent("SafeArea/Group1/" .. i .. "/Icon", "Image")
		self["GoFirstSystemDot" .. i] = self:GetChildGameObject("SafeArea/Group1/" .. i .. "/Dot")

		if i == TutorialFunctionType.DrawCard then
			self.FreeDrawEffect = self:GetChildGameObject("SafeArea/Group1/" .. i .. "/Dot")
		end
	end

	self.SecondSystemGroupCount = table.getn(systemType2)

	for j = 1, self.SecondSystemGroupCount do
		self["BtnSecondSystem" .. j] = self:GetChildGameObject("SafeArea/Group2/" .. j)
	end

	self.Group3 = self:GetChildGameObject("SafeArea/Group3")
	self.ThirdSystemGroupCount = table.getn(systemType3)

	for k = 1, self.ThirdSystemGroupCount do
		self["BtnThirdSystem" .. k] = self:GetChildGameObject("SafeArea/Group3/" .. k)
		self["GoThirdSystemDot" .. k] = self:GetChildGameObject("SafeArea/Group3/" .. k .. "/Dot")
	end

	self.FourthSystemGroupCount = table.getn(systemType4)
	self.gRoleBirthday = self:GetChildGameObject("SafeArea/gRoleBirthday")
	self.Group4Go = self:GetChildGameObject("SafeArea/Group4")

	for n = 1, self.FourthSystemGroupCount do
		self["BtnFourthSystem" .. n] = self:GetChildGameObject("SafeArea/Group4/" .. n)

		if n == 1 then
			local taskListData = TaskLimitMgr:GetListLimitHourTask()[1]

			RedDotSystemMgr.SetUIRedDot(self["BtnFourthSystem" .. n], string.format("TaskLimitTime/%d", taskListData.ID))
		end
	end

	self.bossRaidTime = self:GetChildComponent("SafeArea/Group4/2/time", "Text")
	self.bossRaidTime.text = ""
	self.limitTime = self:GetChildComponent("SafeArea/Group4/1/time", "Text")
	self.limitTime.text = ""

	self:SetLimitTimeTaskState()

	for i = 3, 5 do
		self["luckyBackAwardTime" .. i] = self:GetChildComponent("SafeArea/Group4/" .. i .. "/time", "Text")
	end

	self.GoViceSystemOther = self:GetChildGameObject("Group2/other")
	self.btn_show_group2List = self:GetChildGameObject("SafeArea/Group2/btn_show_group2List")
	self.ArrowUIRedDot = GOUtil.GetComponent(self.btn_show_group2List, "UIRedDot")
	self.GPop = self:GetChildGameObject("SafeArea/GPop")

	self:UpdatePopGift()
	self:Init()

	self.hideUI = false

	Event.Instance:Fire(EventEnum.InPageMain, true)
	self:InitDotNotify()
	SceneMainStage.Instance:UpdateVCamera()
	SceneMainStage.Instance:HideVC()
	self:OnLoaded()

	TaskManager.canShowTips = true

	TaskManager:ShowTaskTips()
	self:RequestReview(vParam)
	NetManager.CheckCachedBuyItemPop()

	if PlayerInst.InfoPlayer:CanFreeDraw() then
		SetActiveFunc(self.FreeDrawEffect, true)
	end

	if InstructionMgr:IsInGuide() and InstructionMgr.show2DBtn then
		self.cardMode = false

		PersistentStoreUtil.SetBool("MainMode", self.cardMode)
		self:UpdateCardPanel()
	end
end

function PageMainStage:OpenPhoneCall()
	self.Timer1 = TimerMgr.AddTimer(eTimerType.FrameCount, 0, function()
		self:DealWithSystemOpenWindow()

		if RoleCardMgr:GetTipWindowOnGameState() == "1" then
			if RoleCardMgr:GetTipWindowState() == "0" and RoleCardMgr:GetTipWindowAwardState() == "0" then
				self:ShowPhoneCallIn()
			end
		else
			self:ShowPhoneCallIn()
		end
	end, {})
end

function PageMainStage:Init()
	self:InitAdBoard()

	if not MailMgr.Requested and not SystemMaintainMgr:Deal(SystemMaintainType.mail) then
		self.Timer2 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.2, function()
			self:RequestGetMails()
		end, {})
	else
		MailMgr:RefreshListMail()
	end

	if not FriendMgr.Requested then
		self.Timer3 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.4, function()
			self:RequestFriend()
		end, {})
	end

	if FriendMgr.IsExitOnPageFriend then
		self:DealWithUIAnim(true)

		FriendMgr.IsExitOnPageFriend = false

		require("UI/Page/PageFriend/PageFriendMain")
		PageFriendMain.RequestData()
	end

	local InfoPVP = require("Info/InfoPVP")

	if InfoPVP.PBPVPSeason == nil then
		local function pc(pb)
			InfoPVP:SetData(pb)
			LoadingMgr.Hide(eLoadingType.Repeat)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSeasonData(0, 0, 0, pc)
	end

	local actTs = ActiveMgr:GetActiveByType(eActiveType.timespace)[1]

	if actTs then
		local isStart = actTs:IsStart()

		if isStart then
			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:GetTimeSpaceData(function(msg)
				TimeSpaceChapterMgr:Refresh()
				LoadingMgr.Hide(eLoadingType.Repeat)
			end)
		end
	end

	if not WorkMgr.Requested and not SystemMaintainMgr:Deal(SystemMaintainType.work) then
		self.Timer5 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.8, function()
			self:RequestGetWorks()
		end, {})
	end

	if not ActivityBossRaidMgr.Requested then
		self.Timer6 = TimerMgr.AddTimer(eTimerType.ScaleTime, 1, function()
			self:RequestBossRaidRecord()
		end, {})
	end

	self:UpdateCardPanel()
	self:UpdatePanel()

	if RoleCardMgr:GetTipWindowVideoState() then
		self:DealWithTipWindowVideo()
	else
		local adsList = InfoGameInst:GetTipWindowAdsList()
		local list = {}

		for i = 1, #adsList do
			if adsList[i].Type == 1 then
				table.insert(list, adsList[i])
			end
		end

		for i = 1, #list do
			self:UnloadAssetsByPath(list[i].Resource)
		end
	end

	if RoleCardMgr:GetTipWindowOnGameState() and #self.spriteImageList ~= 0 then
		self:DealWithTipWindow()
	elseif not RoleCardMgr:GetTipWindowVideoState() then
		self:DealWithTipWindowAward()
	end
end

function PageMainStage:RequestReview(vparm)
	local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()

	if not State then
		local tasklist = TaskManager:GetTaskListData(eTaskListType.battlePass)

		if tasklist then
			NetEncapManager:RequestPurchasePruduct(tasklist.ActivePayId, 1, "", {}, function()
				return
			end)
		end
	end

	if not vparm then
		return
	end

	if not sendReviewAgain then
		return
	end

	local OpenSystems = TutorialMgr:GetListOpenSystem()

	if #OpenSystems > 0 then
		return
	end

	local function wrap_cb(res)
		LoadingMgr.Hide(eLoadingType.Repeat)

		sendReviewAgain = res.sendAgain

		if res.requestReviewId > 0 then
			self:ShowReview(res.requestReviewId)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:GetRequestReview(wrap_cb)
end

function PageMainStage:ShowReview(requestReviewId)
	require("UI/Dlg/Common/DlgRequestReview")

	if Application.platform:ToInt() == RuntimePlatform.Android then
		UIMgr.AddPanel(DlgRequestReview(), {
			callback = function(eventType)
				print("clicked " .. tostring(eventType))

				local function wrap_cb(res)
					LoadingMgr.Hide(eLoadingType.Repeat)
				end

				LoadingMgr.Show(eLoadingType.Repeat)
				NetManager:SendRequestReviewStatus(requestReviewId, eventType, wrap_cb)

				if eventType == DlgRequestReview.EventType.CLICKED_YES then
					if Application.platform:ToInt() == RuntimePlatform.Android then
						Application.OpenURL(_("PageRequestReview_Link"))
					else
						Jackpot.Platform.StoreReview()
					end

					UIMgr.AddPanel(DlgRequestReview(), {
						type = DlgRequestReview.ButtonType.YES_ONLY,
						callback = function(eventType)
							print("clicked " .. tostring(eventType))
						end
					})
				end
			end
		}, self.UIRootObject)
	else
		NetManager:SendRequestReviewStatus(requestReviewId, DlgRequestReview.EventType.CLICKED_YES, function()
			return
		end)
		Jackpot.Platform.StoreReview()
	end
end

function PageMainStage:DealWithSystemOpenWindow()
	local OpenSystems = TutorialMgr:GetListOpenSystem()
	local isSystemOpen = #OpenSystems > 0
	local wrap_cb

	if isSystemOpen then
		PageMainStage.OpenSystenTip = true

		if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) ~= tonumber(TutorialFunctionType.PatFace) then
			require("UI/Dlg/Common/DlgSystemOpen")
			UIMgr.AddPanel(DlgSystemOpen(), {
				list = OpenSystems,
				panel = self
			})
		elseif RoleCardMgr:GetTipWindowState() == "1" and #self.spriteImageList ~= 0 and RoleCardMgr:GetTipWindowOnGameState() == "1" then
			if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) == tonumber(TutorialFunctionType.PatFace) then
				-- block empty
			elseif InstructionMgr:IsInGuide() then
				return
			end

			local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

			if not isOpen or not isSystemOpen or OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) ~= tonumber(TutorialFunctionType.PatFace) then
				-- block empty
			else
				FingerGesturesUtil.Disable()
				self:SetImageSprite(self.TipWindowImage, self.spriteImageList[self.TipWindowCurIndex].Resource)

				local startTime, closeTime, endTime = OperationActiveMgr.GetRelevanceActiveID(self.spriteImageList[self.TipWindowCurIndex].RelevanceActive[1], self.spriteImageList[self.TipWindowCurIndex].RelevanceActive[2])

				self.TipWindowTime.text = self:ShowOpenTime(startTime, endTime, true)

				if self.spriteImageList[self.TipWindowCurIndex].TimePos and self.spriteImageList[self.TipWindowCurIndex].TimePos[1] then
					GOUtil.SetRectTransformAnchoredPosition(self.TipWindowTime.gameObject, self.spriteImageList[self.TipWindowCurIndex].TimePos[1], self.spriteImageList[self.TipWindowCurIndex].TimePos[2])

					self.TipWindowTime.color = getColorFromString(self.spriteImageList[self.TipWindowCurIndex].TimePos[3])
					self.TipWindowTime.fontSize = self.spriteImageList[self.TipWindowCurIndex].TimePos[4]
					self.TipWindowTimeFullOutline.enabled = self.spriteImageList[self.TipWindowCurIndex].TimePos[5] == 1

					self:CheckFreeTipWindow(self.TipWindowCurIndex)
				end

				self.TipWindow.transform:SetAsLastSibling()
				self.TipWindow:SetActive(true)

				PageMainStage.entered = true
			end
		else
			if self.TipWindow then
				Object.Destroy(self.TipWindow)

				self.TipWindow = nil
			end

			if self.GoDlgTipWindow then
				ResourceMgr.Unload(self.GoDlgTipWindow)

				self.GoDlgTipWindow = nil
			end

			self.allLoginPopupList = OperationActiveMgr:AllLoginPopupList()

			if table.getItemCount(self.allLoginPopupList) ~= 0 and RoleCardMgr:GetTipWindowAwardState() == "1" and RoleCardMgr:GetTipWindowPatFaceState() == "1" then
				if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) == tonumber(TutorialFunctionType.PatFace) then
					-- block empty
				elseif InstructionMgr:IsInGuide() then
					return
				end

				local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

				if isOpen then
					OperationActiveMgr.Tag = 1
					OperationActiveMgr.BattlePassTag = "Tab1"
					OperationActiveMgr.PageOperationActiveType = 2

					if not RoleCardMgr:GetTipWindowVideoState() then
						self:DealWithTipWindowAward()
					end
				end
			else
				self.notOpenTipWindow = true
			end
		end
	end
end

function PageMainStage:DealWithTipWindowVideo()
	local adsList = InfoGameInst:GetTipWindowAdsList()
	local list = {}

	for i = 1, #adsList do
		if adsList[i].Type == 1 then
			table.insert(list, adsList[i])
		end
	end

	if #list == 0 then
		ResourceMgr.Unload(self.GoDlgTipWindowVideo)

		self.GoDlgTipWindowVideo = nil

		for i = 1, #list do
			self:UnloadAssetsByPath(list[i].Resource)
		end

		list = nil

		return
	end

	self.videoList = list

	local isOpen = TutorialMgr:IsOpenNoMsg(40)

	if not isOpen then
		return
	end

	Event.Instance:Fire("UpdateSceneDisplay", false)

	local DlgTipWindowVideo = GOUtil.InstantiateUIPrefab(self.GoDlgTipWindowVideo, self.UIRootObject)

	InfoBGMEventMgr:Clear()

	DlgTipWindowVideo.name = "DlgTipWindowVideo"
	self.TipWindowVideoButton = GOUtil.FindChildGameObject(DlgTipWindowVideo, "Button")
	self.TipWindowVideo = DlgTipWindowVideo

	if self.fAniCoroutine then
		coroutine.stop(self.fAniCoroutine)
	end

	self.startIndex = 1
	self.videoLength = #list

	function self.fAni(...)
		local Play = GOUtil.FindChildComponent(self.TipWindowVideo, "Play", "VideoPlayer")

		if not IsNil(self.TipWindowVideo) then
			self.TipWindowVideo:SetActive(true)
		end

		for i = self.startIndex, #list do
			if not IsNil(Play) then
				self.nowIndex = i

				self:SetVideoPlayerClip(Play, list[i].Resource)

				local t = tonumber(Play.clip.length)

				coroutine.wait(t)
			end
		end

		if not IsNil(self.TipWindowVideo) then
			self.TipWindowVideo:SetActive(false)

			if self.TipWindowVideo then
				Object.Destroy(self.TipWindowVideo)

				self.TipWindowVideo = nil

				ResourceMgr.Unload(self.GoDlgTipWindowVideo)

				self.GoDlgTipWindowVideo = nil

				for i = 1, #self.videoList do
					self:UnloadAssetsByPath(self.videoList[i].Resource)
				end

				self.videoList = nil
			end

			if RoleCardMgr:GetTipWindowOnGameState() == "1" and #self.spriteImageList ~= 0 then
				-- block empty
			else
				self:DealWithTipWindowAward()
			end

			coroutine.stop(self.fAni)
			InfoBGMEventMgr:LoadBank("PageMainStage", true)
			Event.Instance:Fire("UpdateSceneDisplay", true)
		end

		RoleCardMgr:SetTipWindowVideoState("0")
	end

	SoundMgr.StopAll()

	self.fAniCoroutine = coroutine.start(self.fAni)
end

function PageMainStage:CheckFreeTipWindow(idx)
	if #self.spriteImageList[idx].TimePos == 7 then
		SetActiveFunc(self.TipWindowTime.gameObject, false)
	else
		SetActiveFunc(self.TipWindowTime.gameObject, true)
	end
end

function PageMainStage:DealWithTipWindow()
	local DlgTipWindow = GOUtil.InstantiateUIPrefab(self.GoDlgTipWindow, self.UIRootObject)

	DlgTipWindow.name = "DlgTipWindow"
	self.TipWindow = DlgTipWindow
	self.TipWindowBtn = GOUtil.FindChildGameObject(self.TipWindow, "btn")
	self.TipWindowSel = GOUtil.FindChildGameObject(self.TipWindow, "btn/go_sel")
	self.TipWindowImage = GOUtil.FindChildComponent(self.TipWindow, "Image", "Image")
	self.TipWindowTime = GOUtil.FindChildComponent(self.TipWindow, "tex_time", "Text")
	self.TipWindowTimeFullOutline = GOUtil.FindChildComponent(self.TipWindow, "tex_time", "UnityEngine.UI.Outline")
	GOUtil.FindChildComponent(self.TipWindow, "btn/Text", "Text").text = _("Desc_ToDay_No_Tips")
	self.TipWindowCurIndex = 1

	local function cb()
		if RoleCardMgr:GetTipWindowState() == "1" and #self.spriteImageList ~= 0 and RoleCardMgr:GetTipWindowOnGameState() == "1" then
			local OpenSystems = TutorialMgr:GetListOpenSystem()
			local isSystemOpen = OpenSystems ~= nil and #OpenSystems > 0

			if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) == tonumber(TutorialFunctionType.PatFace) then
				-- block empty
			elseif InstructionMgr:IsInGuide() then
				return
			end

			local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

			if isOpen then
				if isSystemOpen then
					if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) ~= tonumber(TutorialFunctionType.PatFace) then
						-- block empty
					else
						FingerGesturesUtil.Disable()
						self:SetImageSprite(self.TipWindowImage, self.spriteImageList[self.TipWindowCurIndex].Resource)

						local startTime, closeTime, endTime = OperationActiveMgr.GetRelevanceActiveID(self.spriteImageList[self.TipWindowCurIndex].RelevanceActive[1], self.spriteImageList[self.TipWindowCurIndex].RelevanceActive[2])

						self.TipWindowTime.text = self:ShowOpenTime(startTime, endTime, true)

						if self.spriteImageList[self.TipWindowCurIndex].TimePos and self.spriteImageList[self.TipWindowCurIndex].TimePos[1] then
							GOUtil.SetRectTransformAnchoredPosition(self.TipWindowTime.gameObject, self.spriteImageList[self.TipWindowCurIndex].TimePos[1], self.spriteImageList[self.TipWindowCurIndex].TimePos[2])

							self.TipWindowTime.color = getColorFromString(self.spriteImageList[self.TipWindowCurIndex].TimePos[3])
							self.TipWindowTime.fontSize = self.spriteImageList[self.TipWindowCurIndex].TimePos[4]
							self.TipWindowTimeFullOutline.enabled = self.spriteImageList[self.TipWindowCurIndex].TimePos[5] == 1

							self:CheckFreeTipWindow(self.TipWindowCurIndex)
						end

						self.TipWindow.transform:SetAsLastSibling()
						self.TipWindow:SetActive(true)

						PageMainStage.entered = true
					end
				else
					FingerGesturesUtil.Disable()
					self:SetImageSprite(self.TipWindowImage, self.spriteImageList[self.TipWindowCurIndex].Resource)

					local startTime, closeTime, endTime = OperationActiveMgr.GetRelevanceActiveID(self.spriteImageList[self.TipWindowCurIndex].RelevanceActive[1], self.spriteImageList[self.TipWindowCurIndex].RelevanceActive[2])

					self.TipWindowTime.text = self:ShowOpenTime(startTime, endTime, true)

					if self.spriteImageList[self.TipWindowCurIndex].TimePos and self.spriteImageList[self.TipWindowCurIndex].TimePos[1] then
						GOUtil.SetRectTransformAnchoredPosition(self.TipWindowTime.gameObject, self.spriteImageList[self.TipWindowCurIndex].TimePos[1], self.spriteImageList[self.TipWindowCurIndex].TimePos[2])

						self.TipWindowTime.color = getColorFromString(self.spriteImageList[self.TipWindowCurIndex].TimePos[3])
						self.TipWindowTime.fontSize = self.spriteImageList[self.TipWindowCurIndex].TimePos[4]
						self.TipWindowTimeFullOutline.enabled = self.spriteImageList[self.TipWindowCurIndex].TimePos[5] == 1

						self:CheckFreeTipWindow(self.TipWindowCurIndex)
					end

					self.TipWindow.transform:SetAsLastSibling()
					self.TipWindow:SetActive(true)

					PageMainStage.entered = true
				end
			end
		elseif RoleCardMgr:GetTipWindowAwardState() == "1" and #self.allLoginPopupList ~= 0 and RoleCardMgr:GetTipWindowPatFaceState() == "1" then
			local OpenSystems = TutorialMgr:GetListOpenSystem()
			local isSystemOpen = OpenSystems ~= nil and #OpenSystems > 0

			if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) == tonumber(TutorialFunctionType.PatFace) then
				-- block empty
			elseif InstructionMgr:IsInGuide() then
				return
			end

			local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

			if isOpen then
				if isSystemOpen then
					if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) ~= tonumber(TutorialFunctionType.PatFace) then
						-- block empty
					elseif not RoleCardMgr:GetTipWindowVideoState() then
						self:DealWithTipWindowAward()
					end
				elseif not RoleCardMgr:GetTipWindowVideoState() then
					self:DealWithTipWindowAward()
				end
			end
		end
	end

	cb()
end

function PageMainStage:DealWithTipWindowAward()
	if self.PageOperationActiveNew then
		self.PageOperationActiveNew:InitPanel()
	end
end

function PageMainStage:OnCloseTipWindow()
	if self.TipWindowCurIndex < #self.spriteImageList then
		self.TipWindowCurIndex = self.TipWindowCurIndex + 1

		self:SetImageSprite(self.TipWindowImage, self.spriteImageList[self.TipWindowCurIndex].Resource)

		local startTime, closeTime, endTime = OperationActiveMgr.GetRelevanceActiveID(self.spriteImageList[self.TipWindowCurIndex].RelevanceActive[1], self.spriteImageList[self.TipWindowCurIndex].RelevanceActive[2])

		self.TipWindowTime.text = self:ShowOpenTime(startTime, endTime, true)

		if self.spriteImageList[self.TipWindowCurIndex].TimePos and self.spriteImageList[self.TipWindowCurIndex].TimePos[1] then
			GOUtil.SetRectTransformAnchoredPosition(self.TipWindowTime.gameObject, self.spriteImageList[self.TipWindowCurIndex].TimePos[1], self.spriteImageList[self.TipWindowCurIndex].TimePos[2])

			self.TipWindowTime.color = getColorFromString(self.spriteImageList[self.TipWindowCurIndex].TimePos[3])
			self.TipWindowTime.fontSize = self.spriteImageList[self.TipWindowCurIndex].TimePos[4]
			self.TipWindowTimeFullOutline.enabled = self.spriteImageList[self.TipWindowCurIndex].TimePos[5] == 1

			self:CheckFreeTipWindow(self.TipWindowCurIndex)
		end
	else
		FingerGesturesUtil.Enable()

		if self.TipWindow then
			Object.Destroy(self.TipWindow)
			ResourceMgr.Unload(self.GoDlgTipWindow)

			self.TipWindow = nil
			self.GoDlgTipWindow = nil
		end

		for i = 1, #self.spriteImageList do
			self:UnloadAssetsByPath(self.spriteImageList[i].Resource)
		end

		if RoleCardMgr:GetTipWindowAwardState() == "1" and table.getItemCount(self.allLoginPopupList) ~= 0 and RoleCardMgr:GetTipWindowPatFaceState() == "1" then
			local OpenSystems = TutorialMgr:GetListOpenSystem()
			local isSystemOpen = OpenSystems ~= nil and #OpenSystems > 0

			if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) == tonumber(TutorialFunctionType.PatFace) then
				-- block empty
			elseif InstructionMgr:IsInGuide() then
				return
			end

			local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

			if isOpen then
				if isSystemOpen then
					if OpenSystems[1] and OpenSystems[1] and tonumber(OpenSystems[1].id) ~= tonumber(TutorialFunctionType.PatFace) then
						-- block empty
					else
						self:DealWithTipWindowAward()
					end
				else
					self:DealWithTipWindowAward()
				end
			end
		else
			self.notOpenTipWindow = true
		end

		if table.getItemCount(self.allLoginPopupList) == 0 then
			self:AutoOpenWebViwe()
			RoleCardMgr:SetTipWindowAwardState("0")
		end
	end

	RoleCardMgr:SetTipWindowOnGameState("0")
end

function PageMainStage:OnCloseTipWindowOnClick()
	if RoleCardMgr:GetTipWindowState() == "1" then
		RoleCardMgr:SetTipWindowState("0")
		self.TipWindowSel:SetActive(true)
	else
		RoleCardMgr:SetTipWindowState("1")
		self.TipWindowSel:SetActive(false)
	end
end

function PageMainStage:OnCloseTipWindowVideoOnClick()
	coroutine.stop(self.fAni)

	if self.nowIndex < self.videoLength then
		self.startIndex = self.nowIndex + 1

		coroutine.start(self.fAni)

		return
	end

	RoleCardMgr:SetTipWindowVideoState("0")
	self.TipWindowVideo:SetActive(false)

	self.fAni = nil

	if self.TipWindowVideo then
		Object.Destroy(self.TipWindowVideo)

		self.TipWindowVideo = nil

		ResourceMgr.Unload(self.GoDlgTipWindowVideo)

		self.GoDlgTipWindowVideo = nil

		for i = 1, #self.videoList do
			self:UnloadAssetsByPath(self.videoList[i].Resource)
		end

		self.videoList = nil
	end

	if RoleCardMgr:GetTipWindowOnGameState() == "1" and #self.spriteImageList ~= 0 then
		-- block empty
	else
		self:DealWithTipWindowAward()
	end

	Event.Instance:Fire("UpdateSceneDisplay", true)
	InfoBGMEventMgr:LoadBank("PageMainStage", true)
end

function PageMainStage:NextStageOnclick()
	ChapterMgr:SetNextStageShow()

	local Animator = GOUtil.GetComponent(self.next_stage, "Animator")

	if ChapterMgr.NextStageState ~= 0 then
		ChapterMgr.NextStageState = 0

		self.next_stage_animator:Play("nextStage_close", 0, 0)
	end
end

function PageMainStage:UpdateCardPanel()
	if self.cardMode == nil then
		self.cardMode = PersistentStoreUtil.GetBool("MainMode", false)
	end

	if self.DlgMainStageCardPanel == nil then
		if self.cardMode then
			self.DlgMainStageCardPanel = DlgMainStageCardPanel()

			self.DlgMainStageCardPanel:Create(self.UIRootObject, self)
			self:AddChildPanel(self.DlgMainStageCardPanel)
		else
			return
		end
	end

	local imgMode = self:GetChildComponent("SafeArea/Group3/3", "Image")

	if self.cardMode then
		SetImageSprite(imgMode, "UI/PanelMainStage/AtlasMainStage/BTN_main_10b", self)
		self.DlgMainStageCardPanel:Show()
		FingerGesturesUtil.Disable()
		SetActiveFunc(self.GPop, false)
	else
		SetImageSprite(imgMode, "UI/PanelMainStage/AtlasMainStage/BTN_main_10", self)
		self.DlgMainStageCardPanel:Hide()
		FingerGesturesUtil.Enable()
		SetActiveFunc(self.GPop, true)
	end
end

local function GetSystemOpen(systemTypeTbl, index)
	local systemId = systemTypeTbl[index]

	if systemId and systemId ~= 0 then
		return TutorialMgr:IsOpenNoMsg(systemId)
	end

	return true
end

function PageMainStage:UpdatePanel()
	if GetSystemOpen(systemType4, 2) then
		GOUtil.GetComponentInChildren(self.BtnFourthSystem2, "Animator").enabled = true
	end

	self:UpdateSystemOpen()

	local OpenSystems = TutorialMgr:GetListOpenSystem()
	local isSystemOpen = #OpenSystems > 0

	OperationActiveMgr.PageMainShowGroup2ListState = not isSystemOpen
	self.showGroup2List = not OperationActiveMgr.PageMainShowGroup2ListState

	self:OnClickedShowGroup2List()
end

function PageMainStage:UpdateSystemOpen()
	local isOpen

	for i = 1, self.FirstSystemGroupCount do
		isOpen = GetSystemOpen(systemType1, i)

		local gray = TenaryOp(isOpen, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self["ImgBtnFirstSystem" .. i], gray))
		DealWithListRef(self, UIUtil.SetImageGray(self["ImgBtnFirstSystemIcon" .. i], gray))
	end

	for j = 1, self.SecondSystemGroupCount do
		isOpen = GetSystemOpen(systemType2, j)

		local gray = TenaryOp(isOpen, 0, 1)
		local img = GOUtil.GetComponent(self["BtnSecondSystem" .. j], "Image")

		DealWithListRef(self, UIUtil.SetImageGray(img, gray))
	end

	for k = 1, self.ThirdSystemGroupCount do
		isOpen = GetSystemOpen(systemType3, k)

		GOUtil.SetActive(self["BtnThirdSystem" .. k], isOpen)
	end

	local isADOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.AD)

	self.GoBoard:SetActive(isADOpen and not NoPay)
	self.GoBoard2:SetActive(isADOpen and not NoPay)
	self:UpdateBossRaidOpen()
	self:UpdateLuckyBackAward()
	self:LuckyBackAwardBtnShow()
	self:PlayerBirthdayShow()

	if self.notOpenTipWindow and RoleCardMgr:GetTipWindowPatFaceState() == "1" and RoleCardMgr:GetTipWindowState() == "0" then
		self:UpdateFirstChargeOpen()

		self.inited = true
	end

	if not self.inited then
		self:UpdateFirstRecharge()
	end

	self:OpenPhoneCall()
	UIUtil.ForceRebuildLayoutImmediate(self.Group3)

	local width = GOUtil.GetRectTransformSizeDeltaWidth(self.Group3)
	local widthRoot = GOUtil.GetRectTransformWidth(self.UIRootObject)
	local SafeAreaRect = self:GetChildComponent("SafeArea", "RectTransform")

	self.dlgAssetsInfo:ResetBannerPosition(-width - 10, 0)

	local Group4ListItemValue = 0

	for n = 1, self.FourthSystemGroupCount do
		if n == 1 then
			SetActiveFunc(self.BtnFourthSystem1, OperationActiveMgr.TimeLimitLastTime() ~= false)
		end

		if self["BtnFourthSystem" .. n].transform.localScale == Vector3.New(1, 1, 1) and self["BtnFourthSystem" .. n].gameObject.activeSelf then
			Group4ListItemValue = Group4ListItemValue + 1
		end
	end

	Group4ListItemValue = Group4ListItemValue + self:CheckLimitActivity()

	if self.LimitActivityList and #self.LimitActivityList > 0 then
		self:SetLimitActiviyTime()
	end

	self.RoleBirthdayList = OperationActiveMgr:GetRoleBirthdayAwardList()

	if not self.infoRoleBirthdayList then
		self.infoRoleBirthdayList = {}
	else
		for i, v in pairs(self.infoRoleBirthdayList) do
			SetActiveFunc(v.obj, false)
		end
	end

	local roleBirthSiblingIndex = 3

	for i, v in pairs(self.RoleBirthdayList) do
		if OpenAllLock or ChapterMgr:GetStage(v.data.OpenStage):IsPass() then
			local goRoleBirthday = GOUtil.Instantiate(self.gRoleBirthday, self.Group4Go)

			goRoleBirthday.name = v.data.CharacterRole

			SetActiveFunc(goRoleBirthday, true)
			goRoleBirthday.transform:SetSiblingIndex(roleBirthSiblingIndex)

			goRoleBirthday.transform.localScale = Vector3.New(0.9, 0.9, 1)
			Group4ListItemValue = Group4ListItemValue + 1
			roleBirthSiblingIndex = roleBirthSiblingIndex + 1

			self:AddClick(goRoleBirthday, self.OnClickedRoleBirthday)

			local info = {}

			info.data = v
			info.obj = goRoleBirthday
			info.text = GOUtil.FindChildComponent(goRoleBirthday, "time", "Text")

			table.insert(self.infoRoleBirthdayList, info)

			local infoRole = RoleMgr:GetRole(v.data.CharacterRole)

			if infoRole then
				UIUtil.SetImageSprite(GOUtil.FindChildComponent(goRoleBirthday, "img_role", "Image"), infoRole.actorData.ThemeIcon, self)
			end
		end
	end

	self:SetRoleBirthdayState()

	local gridLayoutGroup = self:GetChildGameObject("SafeArea/Group4")

	if Group4ListItemValue >= 6 then
		UIUtil.SetConstraintType(gridLayoutGroup, 2, 5)
	else
		UIUtil.SetConstraintType(gridLayoutGroup, 1, 1)
	end

	self:GetChildGameObject("SafeArea/Group4/Image").transform.localScale = TenaryOp(Group4ListItemValue == 0, Vector3.New(0, 0, 0), Vector3.New(1, 1, 1))
end

function PageMainStage:HideTimeLimitTaskBtnEvent()
	SetActiveFunc(self.BtnFourthSystem1, false)
end

function PageMainStage:OnClickedRoleBirthday(data)
	if SystemMaintainMgr:Deal(SystemMaintainType.operation, true) then
		return
	end

	self.RoleBirthdayList = OperationActiveMgr:GetRoleBirthdayAwardList()
	OperationActiveMgr.PageOperationActiveType = 2

	for i, v in pairs(self.RoleBirthdayList) do
		if tonumber(data.pointerPress.gameObject.name) == v.data.CharacterRole then
			local uiInfo = InfoOperationActive:GetOperationUIInfo(v.data.UIType .. "_" .. v.data.PageOrder)

			for i = 1, 1 do
				if uiInfo and uiInfo.Video and uiInfo.Video[i] and uiInfo.Video[i][1] then
					OperationActiveMgr.RoleBirthdayVideoClip = uiInfo.Video[i][1]
				end
			end

			require("UI/Page/PageOperation/DlgRoleBirthdayAward")
			UIMgr.AddPanel(DlgRoleBirthdayAward(), {
				isShowBG = true,
				infoActive = v
			})

			break
		end
	end
end

local function GetSystemOpenInfo(data, systemTypeTbl)
	local index = tonumber(data.pointerPress.gameObject.name)
	local systemId = systemTypeTbl[index]

	if systemId and systemId ~= 0 then
		local isOpen = TutorialMgr:IsOpenTut(systemId)

		return isOpen, index
	end

	return true, index
end

function PageMainStage:OnClickedBtnFirstSystem(data)
	local isOpen, index = GetSystemOpenInfo(data, systemType1)

	if not isOpen then
		return
	end

	if index == 1 then
		if not UnionMgr.HasUnion() then
			require("UI/Page/PageUnion/PageUnionJoin")

			local function cb()
				UIMgr.SwitchPanel(PageUnionJoin)
			end

			PageUnionJoin.RequestData(cb)
		else
			local function cb()
				UIMgr.SwitchPanel(PageUnion)
			end

			PageUnion.RequestData(cb, true)
		end
	elseif index == 2 then
		CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, 1)
		require("UI/Page/PageRole/PageRole")
		UIMgr.SwitchPanel(PageRole)
	elseif index == 3 then
		require("UI/Page/PageRoleCard/Page/PageRoleCardList")
		UIMgr.SwitchPanel(PageRoleCardList, {
			entType = 1
		})
	elseif index == 4 then
		if SystemMaintainMgr:Deal(SystemMaintainType.recruit, true) then
			return
		end

		require("UI/Page/PageCardShop/PageCardShop")
		PageCardShop.InitNetData()
	elseif index == 5 then
		if SystemMaintainMgr:Deal(SystemMaintainType.pvp, true) then
			return
		end

		local InfoPVP = require("Info/InfoPVP")
		local curtime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local endtiem = GetConfigArgInt("PVPSettleSeconds")

		local function pc(pb)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if pb.result.code == NetManager.Result_Maintain then
				ShowFuncForbidDialog()

				return
			end

			InfoPVP:SetData(pb)

			local time = InfoPVP:GetSeasondata().subSeasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			if pb.season.seasonStatus ~= 1 then
				UIMgr.ShowMsg(_("PvPSeason"))
			elseif time < 0 then
				UIMgr.ShowMsg(_("PvPSeason"))
			elseif time <= endtiem or tonumber(curtime) < tonumber(InfoPVP:GetSeasondata().subSeasonBeginTime) then
				UIMgr.ShowMsg(_("PvPSeason"))
			else
				require("UI/Page/pagePVP/PagePVPMain")
				UIMgr.SwitchPanel(PagePVPMain, InfoPVP.pb)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSeasonData(0, 0, 1, pc)
	elseif index == 6 then
		require("UI/Page/PageShop/PageShop")
		PageShop.InitNetData({
			tagIndex = 1,
			tabMainIndex = 6
		})
	elseif index == 7 then
		require("UI/Page/PageChapter/PageChapter")

		ChapterMgr.CurChapterEnumIndex = 0

		UIMgr.SwitchPanel(PageChapter, 1)
	end
end

function PageMainStage:OnClickedBtnViceSystemOther()
	UIMgr.AddPanel(PageOtherMenuTop(), {})
end

function PageMainStage:OnClickedShowGroup2List()
	local function func(isShow)
		for i = 5, 10 do
			SetActiveFunc(self["BtnSecondSystem" .. i], isShow)
		end
	end

	if not self.showGroup2List then
		self.showGroup2List = true
		OperationActiveMgr.PageMainShowGroup2ListState = true

		GOUtil.SetTransformRotation(self.btn_show_group2List, 0, 0, 0)
		func(not self.showGroup2List)
		RedDotSystemMgr.SetUIRedDotState(self.ArrowUIRedDot, true)
	else
		GOUtil.SetTransformRotation(self.btn_show_group2List, 0, 0, 180)

		self.showGroup2List = false
		OperationActiveMgr.PageMainShowGroup2ListState = false

		func(not self.showGroup2List)
		RedDotSystemMgr.SetUIRedDotState(self.ArrowUIRedDot, false)
	end
end

function PageMainStage:OnClickedBtnSecondSystem(data)
	local isOpen, index = GetSystemOpenInfo(data, systemType2)

	if not isOpen then
		return
	end

	if index == 1 then
		if SystemMaintainMgr:Deal(SystemMaintainType.task, true) then
			return
		end

		require("UI/Page/PageTask/PageTask")
		UIMgr.SwitchPanel(PageTask, {})
	elseif index == 2 then
		require("UI/Page/PageCalendar/PageCalendar")

		local isPvPOpen = true
		local count = 0
		local maxCout = 4

		local function complete()
			LoadingMgr.Hide(eLoadingType.Repeat)

			if count == maxCout then
				PageCalendar.RefreshAndShow(function()
					UIMgr.AddPanel(PageCalendar(), {
						PvPOpen = isPvPOpen
					}, UIMgr.UIPopupObject)
				end)
			end
		end

		local function fun()
			count = count + 1

			complete()
		end

		if UnionRaidMgr.IsSetData() then
			maxCout = maxCout - 1
		else
			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestUnionRaidData(fun)
		end

		if UnionWishMgr.IsSetData() then
			maxCout = maxCout - 1
		else
			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestUnionWishList(fun)
		end

		if ActivityBossRaidMgr.IsSetData() then
			maxCout = maxCout - 1
		else
			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestBossRaidData(0, fun)
		end

		local InfoPVP = require("Info/InfoPVP")
		local curtime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local endtiem = GetConfigArgInt("PVPSettleSeconds")

		local function pc(pb)
			if not pb.season then
				isPvPOpen = false
			end

			count = count + 1

			InfoPVP:SetData(pb)

			local time = InfoPVP:GetSeasondata().subSeasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			if time < 0 then
				isPvPOpen = false
			elseif time <= endtiem or tonumber(curtime) < tonumber(InfoPVP:GetSeasondata().subSeasonBeginTime) then
				isPvPOpen = false
			end

			complete()
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSeasonData(0, 0, 0, pc)
	elseif index == 3 then
		if SystemMaintainMgr:Deal(SystemMaintainType.operation, true) then
			return
		end

		OperationActiveMgr.Tag = 1
		OperationActiveMgr.BattlePassTag = "Tab1"
		OperationActiveMgr.PageOperationActiveType = 1

		require("UI/Page/PageOperation/PageOperationActiveNew")
		UIMgr.SwitchPanel(PageOperationActiveNew)
	elseif index == 4 then
		require("UI/Page/PageCommunication/PageAddressBookNew")
		UIMgr.SwitchPanel(PageAddressBookNew, nil)
	elseif index == 5 then
		require("UI/Page/PageBondage/PageBondage")
		UIMgr.SwitchPanel(PageBondage)
	elseif index == 6 then
		require("UI/Page/PageManual/PageManualMain")
		UIMgr.SwitchPanel(PageManualMain())
	elseif index == 7 then
		if SystemMaintainMgr:Deal(SystemMaintainType.work, true) then
			return
		end

		require("UI/Page/PageWork/PageWork")
		UIMgr.SwitchPanel(PageWork)
	elseif index == 8 then
		self:DealWithUIAnim(true)
		require("UI/Page/PageFriend/PageFriendMain")
		PageFriendMain.RequestData()
	elseif index == 9 then
		require("UI/Page/PageBag/PageBag")

		if ItemManager.tabIndex ~= 0 then
			ItemManager.tabIndex = 0
		end

		UIMgr.SwitchPanel(PageBag, {
			entType = 2
		})
	elseif index == 10 then
		require("UI/Page/PageTheme/PageTheme")
		require("UI/Page/PageTheme/PageSeat")

		ThemeManager.TypeID = 1

		UIMgr.SwitchPanel(PageTheme, {})
	end
end

function PageMainStage:OnClickedBtnThirdSystem(data)
	local isOpen, index = GetSystemOpenInfo(data, systemType3)

	if not isOpen then
		return
	end

	print(self.className .. "---------------" .. self.base.className)

	if index == 1 then
		RankMgr.CurIndex = 3

		require("UI/Page/PageRank/PageRank")
		UIMgr.SwitchPanel(PageRank, {
			isMian = true
		})
	elseif index == 2 then
		if SystemMaintainMgr:Deal(SystemMaintainType.mail, true) then
			return
		end

		FingerGesturesUtil.Disable()
		require("UI/Page/PageClassroom/DlgMail")
		UIMgr.AddPanel(DlgMail())
		self:DealWithUIAnim(true)
	elseif index == 3 then
		self.cardMode = not self.cardMode

		PersistentStoreUtil.SetBool("MainMode", self.cardMode)
		self:UpdateCardPanel()
	elseif index == 4 then
		PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_WEBVIEW_TIME, InfoGameInst.gameInfo.webTime)
		self:DealWithUIAnim(true)
		FingerGesturesUtil.Disable()
		UIMgr.AddPanel(DlgWeb(), {
			isAuto = false
		}, UIMgr.UIPopupObject)
	elseif index == 5 then
		Event.Instance:Fire("DealWithUIAnim", true)
	elseif index == 6 then
		UIMgr.SwitchPanel(PageOption, {})
	end
end

function PageMainStage:OnClickedBtnFourthSystem(data)
	local isOpen, index = GetSystemOpenInfo(data, systemType4)

	if not isOpen then
		return
	end

	if index == 1 then
		if SystemMaintainMgr:Deal(SystemMaintainType.task, true) then
			return
		end

		self.hideUI = true

		require("UI/Page/PageOperation/DlgTimeLimitTask")
		self.dlgAssetsInfo:OnFingerTap()
		self:DealWithUIAnim(true)
		UIMgr.SwitchPanel(DlgTimeLimitTask())
	elseif index == 2 then
		if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
			ActivityBossRaidMgr.selectTab = nil

			require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")
			UIMgr.SwitchPanel(PageActivityBossRaid())
		else
			UIMgr.ShowMsg(_("Msg_Active_Over"))
		end
	elseif index >= 3 and index <= 5 then
		if SystemMaintainMgr:Deal(SystemMaintainType.operation, true) then
			return
		end

		require("UI/Page/PageOperation/DlgLuckyBackAward")

		local list = GoodsInfoListMgr:GetLuckyList()
		local info = list[index - 2]

		if info ~= nil then
			UIMgr.AddPanel(DlgLuckyBackAward(), {
				isShowBG = true,
				info = info
			})
		end
	elseif index == 6 then
		require("UI/Page/PageOperation/DlgFirstRecharge")
		UIMgr.AddPanel(DlgFirstRecharge())
	end
end

function PageMainStage:DealWithUIAnim(flag)
	self.hideUI = flag

	if not flag then
		if not self.SafeArea then
			self.SafeArea = self:GetChildGameObject("SafeArea")
		end

		self:SetSafeArea(self.SafeArea)
		self.RootAnimator:Play("PanelMainStage_Come")
		self.PlayerAnimator:Play("DlgPlayerInfoPanel_come")
		self.AssetsAnimator:Play("DlgAssetsInfo_come")
		FingerGesturesUtil.Enable()

		local next_stageInfo, next_stage_str = ChapterMgr:GetNewBieListString()

		if next_stageInfo ~= nil and not flag and ChapterMgr:GetNextStageShow() then
			if ChapterMgr.NextStageState ~= 1 then
				ChapterMgr.NextStageState = 1

				self.next_stage_animator:Play("nextStage_show", 0, 0)
			end
		elseif ChapterMgr.NextStageState ~= 0 then
			ChapterMgr.NextStageState = 0

			self.next_stage_animator:Play("nextStage_close", 0, 0)
		end
	else
		if not self.SafeArea then
			self.SafeArea = self:GetChildGameObject("SafeArea")
		end

		SceneArea(self.SafeArea)
		self.RootAnimator:Play("PanelMainStage_Back")
		self.PlayerAnimator:Play("DlgPlayerInfoPanel_back")
		self.AssetsAnimator:Play("DlgAssetsInfo_back")
		self:OnAnimEnd()

		local next_stageInfo, next_stage_str = ChapterMgr:GetNewBieListString()

		if next_stageInfo ~= nil and not flag and ChapterMgr:GetNextStageShow() then
			if ChapterMgr.NextStageState ~= 1 then
				ChapterMgr.NextStageState = 1

				self.next_stage_animator:Play("nextStage_show", 0, 0)
			end
		elseif ChapterMgr.NextStageState ~= 0 then
			ChapterMgr.NextStageState = 0

			self.next_stage_animator:Play("nextStage_close", 0, 0)
		end
	end
end

function PageMainStage:OnAnimEnd()
	if self.hideUI == nil then
		self.hideUI = false
	end
end

function PageMainStage:InitDotNotify()
	self:UpdateAboutDot()
end

function PageMainStage:UpdateDotNotify(key, isShow)
	local isOpen = false

	if key == ePSKey.Dot_BossRaid then
		isOpen = GetSystemOpen(systemType4, 2)
		GOUtil.GetComponentInChildren(self.BtnFourthSystem2, "Animator").enabled = isShow and isOpen
	end
end

function PageMainStage:UpdateAboutDot()
	if TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Role) then
		local role = CharacterThinMgr.SwitchData(THIN_SYSTEM_TYPE.Role).roles[1]

		if role then
			RedDotSystemMgr.SetUIRedDot(self.BtnFirstSystem2, "Role/" .. role.id)
		end
	else
		RedDotSystemMgr.SetUIRedDot(self.BtnFirstSystem2, nil)
	end

	if TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Card) then
		RedDotSystemMgr.SetUIRedDot(self.BtnFirstSystem3, "Card")
	else
		RedDotSystemMgr.SetUIRedDot(self.BtnFirstSystem3, nil)
	end
end

function PageMainStage:UpdatePopGift()
	local SceneInst = SceneMainStage.Instance
	local camera = GOUtil.GetComponent(SceneInst.UnityCamera, "Camera")

	for i = 1, 5 do
		self["GPop" .. i] = self:GetChildGameObject("SafeArea/GPop/" .. i)
		self["GPopFollow" .. i] = GOUtil.AddMissingComponent(self["GPop" .. i], "HeadAttribute")

		self["GPop" .. i]:SetActive(false)

		local infoRole = SceneInst.InfoRoles[i]

		if SceneInst.Actors[i] and infoRole and infoRole:HasGift() then
			self["GPop" .. i]:SetActive(true)
			self["GPopFollow" .. i]:Init(camera, SceneInst.Actors[i].Root.transform)

			if InfoGameInst:GetCurrentTheme() == 2 then
				if i == 2 then
					self["GPopFollow" .. i]:SetOffset(160, 800)
				else
					self["GPopFollow" .. i]:SetOffset(170, 700)
				end
			elseif InfoGameInst:GetCurrentTheme() == 3 then
				if i == 1 then
					self["GPopFollow" .. i]:SetOffset(-60, 600)
				elseif i == 2 then
					self["GPopFollow" .. i]:SetOffset(250, 600)
				else
					self["GPopFollow" .. i]:SetOffset(160, 600)
				end
			else
				self["GPopFollow" .. i]:SetOffset(160, 600)
			end
		end
	end
end

function PageMainStage:OpenSceneCamera()
	Event.Instance:Fire("UpdateSceneDisplay", true)
end

function PageMainStage:SetLimitTimeTaskState()
	local endTime = OperationActiveMgr.TimeLimitLastTime()

	if endTime == false then
		self.isOpenLimitTimeTask = false

		SetActiveFunc(self.BtnFourthSystem1, false)

		return false
	end

	self.isOpenLimitTimeTask = true
	self.limitTime.text = GetTimeFormat(endTime)

	return true
end

function PageMainStage:SetRoleBirthdayState()
	if self.infoRoleBirthdayList then
		for key, value in pairs(self.infoRoleBirthdayList) do
			local isOpen, curServerTime, beginTime, overTime = value.data:OnMonthAndDay()

			if not isOpen then
				SetActiveFunc(value.obj, false)
			else
				local time = overTime - curServerTime

				value.text.text = GetTimeFormat(Mathf.Floor(time))
			end
		end
	end
end

function PageMainStage:OnUpdateSecond()
	if self.next_stage and self.next_stage_animator and tonumber(self.next_stage.transform.localScale.y) == 0 and not self.hideUI and ChapterMgr:GetNextStageShow() then
		local next_stageInfo, next_stage_str = ChapterMgr:GetNewBieListString()

		self.next_stage:SetActive(next_stageInfo ~= nil and ChapterMgr:GetNextStageShow())

		if next_stageInfo ~= nil and ChapterMgr:GetNextStageShow() then
			if ChapterMgr.NextStageState ~= 1 then
				ChapterMgr.NextStageState = 1

				self.next_stage:SetActive(true)
				self.next_stage_animator:Play("nextStage_show", 0, 0)
			end
		elseif ChapterMgr.NextStageState ~= 0 then
			ChapterMgr.NextStageState = 0

			self.next_stage_animator:Play("nextStage_close", 0, 0)
		end
	end

	self:UpdateLuckyBackAward()
	self:SetRoleBirthdayState()

	if self.bossRaidTime and ActivityBossRaidMgr.selfBossEndTime and ActivityBossRaidMgr.selfBossEndTime ~= 0 then
		local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		if curTime <= ActivityBossRaidMgr.selfBossEndTime and ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsPlayOpen() then
			if ActivityBossRaidMgr.IsBreak() then
				self.BtnFourthSystem2:SetActive(false)
			else
				local distime = ActivityBossRaidMgr.selfBossEndTime - curTime

				self.bossRaidTime.text = GetTimeFormatBySecond(distime, "hour")

				self.BtnFourthSystem2:SetActive(true)
			end
		else
			ActivityBossRaidMgr.selfBossEndTime = 0
			self.bossRaidTime.text = ""

			self.BtnFourthSystem2:SetActive(false)
		end
	end

	if self.isOpenLimitTimeTask then
		self:SetLimitTimeTaskState()
	end

	if self.LimitActivityList and #self.LimitActivityList > 0 then
		self:SetLimitActiviyTime()
	end

	local function IsShowOpen(startTime, endTime)
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local showEndTime = GetTimeTampByString(endTime)
		local isShowEnd = false

		if showEndTime ~= 0 and showEndTime <= curServerTime then
			isShowEnd = true
		end

		return isShowEnd
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if self.nextRefreshTime and curServerTime >= self.nextRefreshTime then
		self:InitAdBoard()
	end

	CalendarRDL.Update()
end

function PageMainStage:UpdateLuckyBackAward()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for key, value in pairs(GoodsInfoListMgr:GetLuckyList()) do
		local time = value.endTime - curServerTime

		if time >= 0 then
			local timeText = self["luckyBackAwardTime" .. key + 2]

			if timeText ~= nil then
				timeText.text = GetTimeFormatBySecond(time, "hour")
			end
		else
			self:LuckyBackAwardBtnHide(key)
		end
	end
end

function PageMainStage:LuckyBackAwardBtnShow()
	self.BtnFourthSystem3:SetActive(false)
	self.BtnFourthSystem4:SetActive(false)
	self.BtnFourthSystem5:SetActive(false)

	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

	if not isOpen then
		return
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for key, value in pairs(GoodsInfoListMgr:GetLuckyList()) do
		local time = value.endTime - curServerTime

		if time >= 0 then
			local system = self["BtnFourthSystem" .. key + 2]

			if system ~= nil and not system.activeSelf then
				local systemImg = GOUtil.GetComponent(system, "Image")
				local icon = ShopManager:GetProduct(value.id).data.Icon

				UIUtil.SetImageSprite(systemImg, icon, self)
				system:SetActive(true)
			end
		end
	end

	if InstructionMgr:IsInGuide() then
		return
	end
end

function PageMainStage:LuckyBackAwardBtnHide(type)
	if type ~= nil then
		local system = self["BtnFourthSystem" .. type + 2]

		if system ~= nil and system.activeSelf then
			system:SetActive(false)
		end
	else
		self.BtnFourthSystem3:SetActive(false)
		self.BtnFourthSystem4:SetActive(false)
		self.BtnFourthSystem5:SetActive(false)
	end
end

function PageMainStage:PlayerBirthdayShow()
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

	if not isOpen then
		return
	end

	if OperationActiveMgr:IsPlayerLoginBirthday() and RoleCardMgr:GetTipWindowAwardState() == "0" then
		local playerBirthdayInfo = OperationActiveMgr:GetPlayerBirthdayInfo()

		if playerBirthdayInfo then
			local tempPanel = GOUtil.InstantiateUIPrefab(self.GoDlgOperationActivePlayerBirthday, UIMgr.UIRootObject)

			self.DlgOperationActivePlayerBirthday = DlgOperationActivePlayerBirthday(tempPanel)

			self.DlgOperationActivePlayerBirthday:InitItemByRoot(tempPanel, {
				isShowClose = true,
				PrefabCell = self.GoCellPlayerBirthday,
				PrefabDlg = self.GoDlgOperationActivePlayerBirthday
			})
			self.DlgOperationActivePlayerBirthday:Init(playerBirthdayInfo, nil, true)
		end
	end
end

function PageMainStage:InitAdBoard()
	self:RefreshAdBoardData()

	self.adCount = table.getItemCount(self.AdBannerType1List)
	self.adCount2 = table.getItemCount(self.AdBannerType2List)
	self.GoBoard = self:GetChildGameObject("SafeArea/Board")
	self.GoBoard2 = self:GetChildGameObject("SafeArea/Board2")

	local goAdGroup = self:GetChildGameObject("SafeArea/Board/Bg/ImgRect")
	local goAdGroup2 = self:GetChildGameObject("SafeArea/Board2/Bg/ImgRect")

	if self.UIBoardAlbum then
		Object.Destroy(GOUtil.GetComponent(goAdGroup, "UISelectorSpecialEdition"))
		self.UIBoardAlbum:Purge()

		self.UIBoardAlbum = nil
	end

	if self.UIBoardAlbum2 then
		Object.Destroy(GOUtil.GetComponent(goAdGroup2, "UISelectorSpecialEdition"))
		self.UIBoardAlbum2:Purge()

		self.UIBoardAlbum2 = nil
	end

	self.listAd = {}
	self.listAd2 = {}
	self.listAdShowCount1 = 0
	self.listAdShowCount2 = 0

	if #self.adlinkList1 then
		local imgGroup = self:GetChildGameObject("SafeArea/Board/Bg/ImgGroup")
		local point = self:GetChildGameObject("SafeArea/Board/Bg/ImgGroup/1")

		for i = 1, #self.adlinkList1 do
			if self.AdBannerType1List[i] then
				local go = GOUtil.InstantiatePrefab(self.PrefabCellAd, goAdGroup)

				if i > 1 and not self["GoAdShow" .. i] then
					local obj = GOUtil.FindGameObjectByName(i, imgGroup)

					if obj == nil then
						local p = GOUtil.Instantiate(point, imgGroup)

						p.name = i
					end
				end

				local imgAd = GOUtil.GetComponent(go, "Image")

				SetImageSprite(imgAd, self.AdBannerType1List[i].BannerIcon, self)

				go.name = i
				self["GoAdShow" .. i] = self:GetChildGameObject("SafeArea/Board/Bg/ImgGroup/" .. i .. "/Sel")
				self["GoAdHide" .. i] = self:GetChildGameObject("SafeArea/Board/Bg/ImgGroup/" .. i .. "/Img")

				self:AddClick(go, self.OnClickedGoAD)
				table.insert(self.listAd, go)

				self.listAdShowCount1 = self.listAdShowCount1 + 1
			else
				SetActiveFunc(self:GetChildGameObject("SafeArea/Board/Bg/ImgGroup/" .. i), false)
			end
		end

		GOUtil.SetRectTransformSizeDelta(imgGroup, self.listAdShowCount1 * 25, 24)
	end

	if #self.adlinkList2 then
		local imgGroup2 = self:GetChildGameObject("SafeArea/Board2/Bg/ImgGroup")
		local point2 = self:GetChildGameObject("SafeArea/Board2/Bg/ImgGroup/1")

		for i = 1, #self.adlinkList2 do
			if self.AdBannerType2List[i] then
				local go = GOUtil.InstantiatePrefab(self.PrefabCellAd2, goAdGroup2)

				if i > 1 and not self["GoAdShow2" .. i] then
					local obj = GOUtil.FindGameObjectByName(i, imgGroup2)

					if obj == nil then
						local p = GOUtil.Instantiate(point2, imgGroup2)

						p.name = i
					end
				end

				local imgAd = GOUtil.GetComponent(go, "Image")

				SetImageSprite(imgAd, self.AdBannerType2List[i].BannerIcon, self)

				local img_lock = GOUtil.FindChildGameObject(go, "img_lock")
				local img_unlock = GOUtil.FindChildGameObject(go, "img_unlock")
				local tex_time = GOUtil.FindChildComponent(go, "img_time/tex_time", "Text")
				local startTime, closeTime, endTime = OperationActiveMgr.GetRelevanceActiveID(self.AdBannerType2List[i].RelevanceActive[1], self.AdBannerType2List[i].RelevanceActive[2])

				SetActiveFunc(img_lock, not self:IsShowOpenTime(startTime, endTime) or not TutorialMgr:IsOpenNoMsg(self.AdBannerType2List[i].NewBieType))
				SetActiveFunc(img_unlock, self:IsShowOpenTime(startTime, endTime) and TutorialMgr:IsOpenNoMsg(self.AdBannerType2List[i].NewBieType))

				local function GetTimeFormat(strTime, _type)
					local time_format = ""
					local a = string.split(strTime, " ")

					if #a > 0 then
						local day = string.split(a[1], "-")
						local time = string.split(a[2], ":")

						if #day == 3 and #time == 3 then
							local yearT = tonumber(day[1])
							local monthT = tonumber(day[2])
							local dayT = tonumber(day[3])
							local hourT = tonumber(time[1])
							local minT = time[2]

							if _type == 1 then
								time_format = string.format(_("Desc_ActiveBannerCloseTime"), monthT, dayT, hourT, minT)
							else
								time_format = string.format(_("Desc_ActiveBannerEndTime"), monthT, dayT, hourT, minT)
							end
						end
					end

					return time_format
				end

				if not string.isNullOrEmpty(closeTime) and not string.isNullOrEmpty(endTime) then
					local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

					if curServerTime > GetTimeTampByString(endTime) then
						tex_time.text = GetTimeFormat(closeTime, 1)
					else
						tex_time.text = GetTimeFormat(endTime, 2)
					end
				else
					tex_time.text = "-"
				end

				go.name = i
				self["GoAdShow2" .. i] = self:GetChildGameObject("SafeArea/Board2/Bg/ImgGroup/" .. i .. "/Sel")
				self["GoAdHide2" .. i] = self:GetChildGameObject("SafeArea/Board2/Bg/ImgGroup/" .. i .. "/Img")

				self:AddClick(go, self.OnClickedGoAD2)
				table.insert(self.listAd2, go)
				SetActiveFunc(self:GetChildGameObject("SafeArea/Board2/Bg/ImgGroup/" .. i), true)

				self.listAdShowCount2 = self.listAdShowCount2 + 1
			else
				SetActiveFunc(self:GetChildGameObject("SafeArea/Board2/Bg/ImgGroup/" .. i), false)
			end
		end

		GOUtil.SetRectTransformSizeDelta(imgGroup2, self.listAdShowCount2 * 25, 24)
	end

	SetActiveFunc(self:GetChildGameObject("SafeArea/Board/Bg/ImgGroup/Image1"), self.listAdShowCount1 > 0)
	SetActiveFunc(self:GetChildGameObject("SafeArea/Board/Bg/ImgGroup/Image2"), self.listAdShowCount1 > 0)
	SetActiveFunc(self:GetChildGameObject("SafeArea/Board2/Bg/ImgGroup/Image1"), self.listAdShowCount2 > 0)
	SetActiveFunc(self:GetChildGameObject("SafeArea/Board2/Bg/ImgGroup/Image2"), self.listAdShowCount2 > 0)

	self.UIBoardAlbum = UIBoardAlbum()

	self.UIBoardAlbum:Init(goAdGroup, self, 0, self.listAd)

	self.UIBoardAlbum2 = UIBoardAlbum2()

	self.UIBoardAlbum2:Init(goAdGroup2, self, 0, self.listAd2)
end

function PageMainStage:RefreshAdBoardData()
	if self.listAd then
		for i = 1, #self.listAd do
			self:RemoveClick(self.listAd[i], self.OnClickedGoAD)
			Object.Destroy(self.listAd[i])
		end

		self.listAd = nil
	end

	if self.listAd2 then
		for i = 1, #self.listAd2 do
			self:RemoveClick(self.listAd2[i], self.OnClickedGoAD2)
			Object.Destroy(self.listAd2[i])
		end

		self.listAd2 = nil
	end

	local ActiveBanner = require("luaData/ActiveBanner")

	self.adlinkList1 = self.adlinkList1 or {}
	self.adlinkList2 = self.adlinkList2 or {}

	if next(self.adlinkList1) == nil or next(self.adlinkList2) == nil then
		for k, v in pairsByKeys(ActiveBanner) do
			if v.Type == 0 then
				table.insert(self.adlinkList1, v)
			elseif v.Type == 1 then
				table.insert(self.adlinkList2, v)
			end
		end

		self.adlinkList1 = self:BoardAlbumListSort(self.adlinkList1)
		self.adlinkList2 = self:BoardAlbumListSort(self.adlinkList2)
	end

	self.AdBannerType1List = {}
	self.AdBannerType2List = {}
	self.nextRefreshTime = nil

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k, v in pairsByKeys(ActiveBanner) do
		if v.Type == 0 then
			local startTime, endTime = OperationActiveMgr.GetRelevanceActiveID(v.RelevanceActive[1], v.RelevanceActive[2])

			if TutorialMgr:IsOpenNoMsg(v.NewBieType) then
				if self:IsShowOpenTime(startTime, endTime) then
					table.insert(self.AdBannerType1List, v)

					if not self.nextRefreshTime or GetTimeTampByString(endTime) < self.nextRefreshTime or curServerTime > self.nextRefreshTime then
						self.nextRefreshTime = GetTimeTampByString(endTime)
					end
				elseif not self.nextRefreshTime or curServerTime <= GetTimeTampByString(startTime) and GetTimeTampByString(startTime) < self.nextRefreshTime then
					self.nextRefreshTime = GetTimeTampByString(startTime)
				end
			end
		elseif v.Type == 1 then
			local startTime, endTime = OperationActiveMgr.GetRelevanceActiveID(v.RelevanceActive[1], v.RelevanceActive[2])

			if TutorialMgr:IsOpenNoMsg(v.NewBieType) then
				if self:IsShowOpenTime(startTime, endTime) then
					table.insert(self.AdBannerType2List, v)

					if not self.nextRefreshTime or GetTimeTampByString(endTime) < self.nextRefreshTime or curServerTime > self.nextRefreshTime then
						self.nextRefreshTime = GetTimeTampByString(endTime)
					end
				elseif not self.nextRefreshTime or curServerTime <= GetTimeTampByString(startTime) and GetTimeTampByString(startTime) < self.nextRefreshTime then
					self.nextRefreshTime = GetTimeTampByString(startTime)
				end
			end
		end
	end

	self.AdBannerType1List = self:BoardAlbumListSort(self.AdBannerType1List)
	self.AdBannerType2List = self:BoardAlbumListSort(self.AdBannerType2List)

	local chargeExist, info = OperationActiveMgr:CheckFirstRechargeExist()
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

	if not chargeExist or not isOpen or not not NoPay then
		for i = table.getItemCount(self.AdBannerType1List), 1, -1 do
			if self.AdBannerType1List[i] and self.AdBannerType1List[i].ID == 1 then
				table.remove(self.AdBannerType1List, i)
			end
		end
	end
end

function PageMainStage:IsShowOpenTime(startTime, endTime, isCellAd2)
	if not startTime or not endTime then
		return false and false
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local showStartTime = GetTimeTampByString(startTime)
	local showEndTime = GetTimeTampByString(endTime)
	local isShowStart = true

	if showStartTime ~= 0 and curServerTime < showStartTime then
		isShowStart = false
	end

	local isShowEnd = false

	if showEndTime ~= 0 and showEndTime <= curServerTime then
		isShowEnd = true
	end

	if isCellAd2 then
		isShowStart = true
	end

	return isShowStart and not isShowEnd
end

function PageMainStage:ShowOpenTime(startTime, endTime, isUnYear)
	if startTime or endTime then
		local a = string.split(startTime, " ")
		local StartTime = ""
		local EndTime = ""

		if #a > 0 then
			local date = string.split(a[1], "-")
			local yearT = tonumber(date[1])
			local monthT = tonumber(date[2])
			local dayT = tonumber(date[3])
			local data2 = string.split(a[2], ":")

			StartTime = yearT .. "/" .. monthT .. "/" .. dayT .. " " .. data2[1] .. ":" .. data2[2]

			if isUnYear then
				StartTime = monthT .. "/" .. dayT .. " " .. data2[1] .. ":" .. data2[2]
			end
		end

		local b = string.split(endTime, " ")

		if #b > 0 then
			local date = string.split(b[1], "-")
			local yearT = tonumber(date[1])
			local monthT = tonumber(date[2])
			local dayT = tonumber(date[3])
			local data2 = string.split(b[2], ":")

			EndTime = yearT .. "/" .. monthT .. "/" .. dayT .. " " .. data2[1] .. ":" .. data2[2]

			if isUnYear then
				EndTime = monthT .. "/" .. dayT .. " " .. data2[1] .. ":" .. data2[2]
			end
		end

		return StartTime .. "-" .. EndTime
	else
		return ""
	end
end

function PageMainStage:UpdateAdBoard(index)
	self.adCount = self.adCount or #self.adlinkList1

	for i = 1, self.adCount do
		self["GoAdShow" .. i]:SetActive(i == index)
		self["GoAdHide" .. i]:SetActive(i ~= index)
	end
end

function PageMainStage:UpdateAdBoard2(index)
	self.adCount2 = self.adCount2 or #self.adlinkList2

	for i = 1, self.adCount2 do
		self["GoAdShow2" .. i]:SetActive(i == index)
		self["GoAdHide2" .. i]:SetActive(i ~= index)
	end
end

function PageMainStage:OnClickedGoAD(data)
	if self.UIBoardAlbum.UISelector.IsDragging then
		return
	end

	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local isOpen = TutorialMgr:IsOpenTut(self.AdBannerType1List[index].NewBieType)

	if not isOpen then
		return
	end

	local fromWhere = {}

	for k, v in pairsByKeys(self.AdBannerType1List) do
		if self.AdBannerType1List[k].FromWhere and k == index then
			fromWhere = self.AdBannerType1List[k].FromWhere[1]

			break
		end
	end

	if #fromWhere == 0 then
		return
	end

	DlgItemTip.GoToFrom(fromWhere)
end

function PageMainStage:OnClickedGoAD2(data)
	if self.UIBoardAlbum2.UISelector.IsDragging then
		return
	end

	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local StartTime, EndTime = OperationActiveMgr.GetRelevanceActiveID(self.AdBannerType2List[index].RelevanceActive[1], self.AdBannerType2List[index].RelevanceActive[2])

	if not self:IsShowOpenTime(StartTime, EndTime) then
		UIMgr.ShowMsg(_("Msg_Active_UnLock"))

		return
	end

	local isOpen = TutorialMgr:IsOpenTutWithMessage(self.AdBannerType2List[index].NewBieType, true)

	if not isOpen then
		return
	end

	local fromWhere = {}

	for k, v in pairsByKeys(self.AdBannerType2List) do
		if self.AdBannerType2List[k].FromWhere and k == index then
			fromWhere = self.AdBannerType2List[k].FromWhere[1]

			break
		end
	end

	if #fromWhere == 0 then
		return
	end

	DlgItemTip.GoToFrom(fromWhere)
end

function PageMainStage:RequestGetMails()
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetMails(1, 0, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)
	end)
end

function PageMainStage:RequestFriend()
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestFriendList(function(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)
	end)
end

function PageMainStage:RequestGetWorks()
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetWorks(function(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)
		NotificationMgr.Instance:Init()
	end)
end

function PageMainStage:RequestBossRaidRecord()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			ActivityBossRaidMgr.Requested = true
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestBossRaidRecord(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageMainStage:UpdateBossRaidOpen()
	if ActivityBossRaidMgr.bossRaidTimeData == nil then
		local activityList = ActiveMgr:GetActiveByType(eActiveType.bossraid)

		for i, v in ipairs(activityList) do
			if v:IsShowOpen() then
				ActivityBossRaidMgr.bossRaidTimeData = v

				break
			end
		end
	end

	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local isShowBossRaid = false

	if ActivityBossRaidMgr.selfBossEndTime and ActivityBossRaidMgr.selfBossEndTime ~= 0 and curTime <= ActivityBossRaidMgr.selfBossEndTime then
		isShowBossRaid = true
	end

	self.BtnFourthSystem2:SetActive(ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsPlayOpen() and TutorialMgr:IsOpenNoMsg(TutorialFunctionType.BossRaid) and isShowBossRaid and not ActivityBossRaidMgr.IsBreak())
end

function PageMainStage:UpdateFirstChargeOpen()
	local chargeExist, info = OperationActiveMgr:CheckFirstRechargeExist()
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

	if not chargeExist or not isOpen or not not NoPay then
		self:InitAdBoard()
	end

	if chargeExist then
		local openTipType = OperationActiveMgr.firstChargeType
		local getIndex = #info.pb.awardRecords
		local needMoney = info.data.DailyTime[1][getIndex + 1]

		if isOpen and not NoPay and (openTipType == 1 or openTipType == 2 and needMoney <= info.pb.record) then
			require("UI/Page/PageOperation/DlgFirstRecharge")
			UIMgr.AddPanel(DlgFirstRecharge())
		end
	end

	self:UpdateFirstRecharge()
end

function PageMainStage:UpdateFirstRecharge()
	local chargeExist = OperationActiveMgr:CheckFirstRechargeExist()
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

	GOUtil.SetActive(self.BtnFourthSystem6, chargeExist and isOpen and not NoPay)
end

function PageMainStage:AutoOpenWebViwe()
	if OperationActiveMgr:IsAutoShowWebView() then
		self:DealWithUIAnim(true)

		local function func(...)
			self:ShowPhoneCallIn()
		end

		UIMgr.AddPanel(DlgWeb(), {
			isAuto = true,
			callback = func
		}, UIMgr.UIPopupObject)
	else
		self:ShowPhoneCallIn()
	end
end

function PageMainStage:UpdateBossRaidTime()
	self.bossRaidTime.text = ""

	self.BtnFourthSystem2:SetActive(false)
end

function PageMainStage:ShowPhoneCallIn()
	if SceneMainStage.Instance.IsEnterInteraction then
		return
	end

	if PageMainStage.OpenSystenTip then
		PageMainStage.OpenSystenTip = false

		return
	end

	if PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, true) then
		return
	end

	local phoneNum = PersistentStoreUtil.GetListCount(PersistentStoreUtil.KEY_NEW_PHONE_CALL)
	local topicNum = PersistentStoreUtil.GetListCount(PersistentStoreUtil.KEY_NEW_TOPIC)

	if phoneNum == 1 and topicNum == 0 then
		local list = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL)

		require("UI.Page.PageCommunication.DlgCallIn")
		UIMgr.AddPanel(DlgCallIn(), {
			callId = tonumber(list[1])
		}, UIMgr.UIOverLayObject)
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, true)
	elseif phoneNum == 0 and topicNum == 1 then
		require("UI.Page.PageCommunication.DlgCallIn")

		local list = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_NEW_TOPIC)

		UIMgr.AddPanel(DlgCallIn(), {
			topicId = tonumber(list[1])
		}, UIMgr.UIOverLayObject)
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, true)
	elseif phoneNum ~= 0 or topicNum ~= 0 then
		require("UI.Page.PageCommunication.DlgNewUnreadMessage")
		UIMgr.AddPanel(DlgNewUnreadMessage(), nil, UIMgr.UIOverLayObject)
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, true)
	end
end

function PageMainStage:CheckLimitActivity()
	if self.LimitActivityList == nil then
		local activityList = OperationActiveMgr:GetLimitActivityList()

		self.LimitActivityList = {}

		for key, value in pairs(activityList) do
			local item = GOUtil.Instantiate(self.BtnFourthSystem1, self.Group4Go)

			item.name = value.data.ID

			SetActiveFunc(item, true)
			item.transform:SetSiblingIndex(0)
			UIUtil.SetImageSprite(GOUtil.FindChildComponent(item, "", "Image"), value.data.ActiveIcon, self)

			local function fun()
				self:OpenLimitActivity(value)
			end

			self:AddClick(item, fun)

			local data = {}

			data.obj = item
			data.fun = fun
			data.time = GetTimeTampByString(value.data.ShowEndTime)
			data.text = GOUtil.FindChildComponent(item, "time", "Text")
			data.isEnd = false

			table.insert(self.LimitActivityList, data)
			RedDotSystemMgr.SetUIRedDot(item, "TaskLimitTime/" .. value.data.DailyTime[1][1])
		end

		return #activityList
	end

	return 0
end

function PageMainStage:SetLimitActiviyTime()
	for key, value in pairs(self.LimitActivityList) do
		if value.isEnd == false then
			local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
			local endTime = value.time - curServerTime

			if endTime <= 0 then
				value.isEnd = true

				SetActiveFunc(value.obj, false)
			else
				value.text.text = GetTimeFormat(endTime)
			end
		end
	end
end

function PageMainStage:OpenLimitActivity(infoActive)
	if SystemMaintainMgr:Deal(SystemMaintainType.task, true) then
		return
	end

	self.hideUI = true

	require("UI/Page/PageOperation/DlgLimitActivity")
	self.dlgAssetsInfo:OnFingerTap()
	self:DealWithUIAnim(true)
	UIMgr.SwitchPanel(DlgLimitActivity(), infoActive)
end

function PageMainStage:OnBackAndroid()
	if self.TipWindowVideo and GOUtil.IsActiveSelf(self.TipWindowVideo) then
		self:OnCloseTipWindowVideoOnClick()

		return true
	elseif self.TipWindow then
		self:OnCloseTipWindow()

		return true
	elseif self.PageOperationActiveNew and self.PageOperationActiveNew:IsShow() then
		self.PageOperationActiveNew:OnClickedClose()

		return true
	end

	if self.hideUI then
		self:OnPointerScreen()

		return true
	end

	return false
end
