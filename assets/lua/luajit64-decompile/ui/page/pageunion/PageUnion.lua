-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/PageUnion.lua

require("UI/Page/PageUnion/PageUnionCanvas")

PageUnion = class("PageUnion", UIPanel)

function PageUnion:ctor()
	self.UIPrefabPath = "UI/PanelUnion/PanelUnion"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_Union"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageUnion:PreLoad()
	self:LoadResAsync("UI/PanelUnion/PanelUnionCanvas", "PrefabUnionCanvas", GameObject)
end

function PageUnion:OnBack()
	if UIMgr.GetPrePanel().className == "PageUnionCreate" then
		UIMgr.PopPanel(nil, 2)
	elseif UIMgr.GetPrePanel().className == "PageUnionJoin" then
		UIMgr.PopPanel(nil, 1)
	end

	UIMgr.PopPanel()
end

function PageUnion:Purge()
	self.base.Purge(self)

	if self.PageUnionCanvas then
		self.PageUnionCanvas.UIRootObject:Destroy()
		ResourceMgr.Unload(self.PrefabUnionCanvas)

		self.PageUnionCanvas = nil
	end
end

function PageUnion:OnRegisterEvent()
	self:AddClick(self.BtnUpLevel, self.OnClickedBtnUpLevel)
	self:AddClick(self.BtnChangeNotice, self.OnClickedBtnChangeNotice)
	self:AddClick(self.BtnMember, self.OnClickedBtnMember)
	self:AddClick(self.BtnRecruit, self.OnClickedBtnRecruit)
	self:AddClick(self.BtnTask, self.OnClickedBtnTask)
	self:AddClick(self.BtnPray, self.OnClickedBtnPray)
	self:AddClick(self.BtnSkill, self.OnClickedBtnSkill)
	self:AddClick(self.BtnRaid, self.OnClickedBtnRaid)
	self:AddClick(self.BtnGvg, self.OnClickedBtnGvg)
	self:AddClick(self.BtnShop, self.OnClickedBtnShop)
	Event.Instance:Add("UpdateReleUnion", self.UpdatePanel, self)
	Event.Instance:Add("UpdateUnionNotice", self.UpdateUnionNotice, self)
end

function PageUnion:OnUnRegisterEvent()
	self:RemoveClick(self.BtnUpLevel, self.OnClickedBtnUpLevel)
	self:RemoveClick(self.BtnChangeNotice, self.OnClickedBtnChangeNotice)
	self:RemoveClick(self.BtnMember, self.OnClickedBtnMember)
	self:RemoveClick(self.BtnRecruit, self.OnClickedBtnRecruit)
	self:RemoveClick(self.BtnTask, self.OnClickedBtnTask)
	self:RemoveClick(self.BtnPray, self.OnClickedBtnPray)
	self:RemoveClick(self.BtnSkill, self.OnClickedBtnSkill)
	self:RemoveClick(self.BtnRaid, self.OnClickedBtnRaid)
	self:RemoveClick(self.BtnGvg, self.OnClickedBtnGvg)
	self:RemoveClick(self.BtnShop, self.OnClickedBtnShop)
	Event.Instance:Remove("UpdateReleUnion", self.UpdatePanel, self)
	Event.Instance:Remove("UpdateUnionNotice", self.UpdateUnionNotice, self)
end

function PageUnion:OnEnter(vParam)
	local needRequest = false

	if vParam and vParam.needRequestUnion ~= nil then
		needRequest = vParam.needRequestUnion
	end

	self:InitUnionCanvas()
	self:DealWithLocalization()

	self.TxtID = self:GetChildComponent("Panel/Bg/ID/TextID", "Text")
	self.TxtName = self:GetChildComponent("Panel/Bg/Name/TxtName", "Text")
	self.TxtLevel = self:GetChildComponent("Panel/Bg/Level/Txt", "Text")
	self.ImgHead = self:GetChildComponent("Panel/Bg/Head", "Image")
	self.ImgHeadIcon = self:GetChildComponent("Panel/Bg/Head/Icon", "Image")
	self.TxtActivity = self:GetChildComponent("Panel/Bg/Exp/TxtValue", "Text")
	self.ImgActivity = self:GetChildComponent("Panel/Bg/Exp/Bar/RateBar", "Image")
	self.ImgFundIcon = self:GetChildComponent("Panel/Bg/Fund/Item/Icon", "Image")
	self.TxtFundValue = self:GetChildComponent("Panel/Bg/Fund/Item/Text", "Text")
	self.TxtMemberNum = self:GetChildComponent("Panel/Bg/Member/Txt", "Text")
	self.TxtHeadNick = self:GetChildComponent("Panel/Bg/President/Txt", "Text")
	self.TxtNotice = self:GetChildComponent("Panel/Bg/Notice/Content/Text", "Text")
	self.BtnUpLevel = self:GetChildGameObject("Panel/Bg/Exp/Button")
	self.ImgBtnUpLevel = GOUtil.GetComponent(self.BtnUpLevel, "Image")
	self.BtnChangeNotice = self:GetChildGameObject("Panel/Bg/Notice/Button")
	self.BtnMember = self:GetChildGameObject("Panel/Bg/BtnGroup/BtnMember")
	self.BtnRecruit = self:GetChildGameObject("Panel/Bg/BtnGroup/BtnRecruit")
	self.BtnShop = self:GetChildGameObject("Panel/BtnShop")

	self:UpdatePanel()

	if UnionMgr.HasUnion() then
		Infogvg.net:RequestHelpReward()
	end

	if needRequest and UnionMgr.HasUnion() then
		local function wrap_cb()
			self:UpdatePanel()
		end

		PageUnion.RequestData(wrap_cb)
	elseif not UnionMgr.HasUnion() then
		PageUnion.GoBackMainPage()
	end
end

function PageUnion:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Bg/Level/Text", "Text")
	txt.text = _("Union_Level")
	txt = self:GetChildComponent("Panel/Bg/Exp/Text", "Text")
	txt.text = _("Desc_ClubExp")
	txt = self:GetChildComponent("Panel/Bg/Exp/Button/Text", "Text")
	txt.text = Lang(12061)
	txt = self:GetChildComponent("Panel/Bg/Fund/Text", "Text")
	txt.text = _("Union_Fund")
	txt = self:GetChildComponent("Panel/Bg/Member/Text", "Text")
	txt.text = _("Union_Member_Num")
	txt = self:GetChildComponent("Panel/Bg/President/Text", "Text")
	txt.text = Lang(6000)
	txt = self:GetChildComponent("Panel/Bg/BtnGroup/BtnMember/Text", "Text")
	txt.text = _("UI_Member")
	txt = self:GetChildComponent("Panel/Bg/BtnGroup/BtnRecruit/Text", "Text")
	txt.text = _("UI_Post_Recruitment")
end

function PageUnion:InitUnionCanvas()
	self.PageUnionCanvas = PageUnionCanvas(self.PrefabUnionCanvas, GameObject.Find("Launcher"), self)

	self.PageUnionCanvas:Create()

	self.BtnTask = GOUtil.FindChildGameObject(self.PageUnionCanvas.UIRootObject, "Event/Task")
	self.BtnPray = GOUtil.FindChildGameObject(self.PageUnionCanvas.UIRootObject, "Event/Wish")
	self.BtnSkill = GOUtil.FindChildGameObject(self.PageUnionCanvas.UIRootObject, "Event/Skill")
	self.BtnRaid = GOUtil.FindChildGameObject(self.PageUnionCanvas.UIRootObject, "Event/Raid")
	self.BtnGvg = GOUtil.FindChildGameObject(self.PageUnionCanvas.UIRootObject, "Event/Gvg")

	RedDotSystemMgr.SetUIRedDot(self.BtnTask, "Union/Task")
	RedDotSystemMgr.SetUIRedDot(self.BtnPray, "Union/Wish")

	local playOpen = Infogvg:IsPlayOpen() == true or Infogvg:ClosingActive() ~= nil
	local obj_gvglock = GOUtil.FindChildGameObject(self.PageUnionCanvas.UIRootObject, "Event/Gvg/lock")
	local obj_gvgunlock = GOUtil.FindChildGameObject(self.PageUnionCanvas.UIRootObject, "Event/Gvg/unlock")

	GOUtil.SetActive(obj_gvglock, not playOpen)
	GOUtil.SetActive(obj_gvgunlock, playOpen)

	self.GoRaidLock = GOUtil.FindChildGameObject(self.BtnRaid, "GoLock")
	self.GoRaidUnlock = GOUtil.FindChildGameObject(self.BtnRaid, "GoUnlock")
end

function PageUnion.RequestData(cb, notNeedLeave)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if cb then
				cb()
			end
		elseif not notNeedLeave and vMsg.result.code == 6 then
			if not notNeedLeave then
				PageUnion.GoBackMainPage(vMsg)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestReleUnionData(wrap_cb)
end

function PageUnion:UpdatePanel()
	self.infoUnion = UnionMgr.releUnion

	if not self.infoUnion then
		return
	end

	self:UpdatePremissionPanel()
	self:UpdateStaticData()
	self:UpdateDynamicData()
	self:UpdateRaidOpenState()
end

function PageUnion:UpdateStaticData()
	local infoUnion = self.infoUnion

	self.TxtID.text = string.format(_("Desc_Union_ID"), tostring(infoUnion.id))
	self.TxtName.text = infoUnion:GetName()

	UIUtil.SetImageSprite(self.ImgHead, UnionTypeMgr:GetUnionTypeBgIcon(infoUnion.pb.type), self)
	UIUtil.SetImageSprite(self.ImgHeadIcon, UnionTypeMgr:GetUnionTypeAvatarPath(infoUnion.pb.type), self)
end

function PageUnion:UpdatePremissionPanel()
	local jobId = UnionMemberMgr:GetMemberJob(PlayerInst.InfoPlayer.pid)

	self.canUpLevel = UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.upLevel)

	GOUtil.SetActive(self.BtnUpLevel, self.canUpLevel)

	local canRecruit = UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.recruit)

	GOUtil.SetActive(self.BtnRecruit, canRecruit)

	local canChangeNotice = UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.changeNotice)

	GOUtil.SetActive(self.BtnChangeNotice, canChangeNotice)
end

function PageUnion:UpdateDynamicData()
	local infoUnion = self.infoUnion

	self.TxtLevel.text = infoUnion.curLevel
	self.TxtActivity.text = infoUnion.curLiveness .. "/" .. infoUnion.nextLiveness
	self.ImgActivity.fillAmount = infoUnion.curLiveness / infoUnion.nextLiveness

	if self.canUpLevel then
		local gray = TenaryOp(infoUnion.curLevel >= infoUnion.maxLevel or infoUnion.curLiveness < infoUnion.nextLiveness, 1, 0)

		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnUpLevel, gray))
	end

	local infoItem = ItemManager:GetItemByType("CLUB_COIN")

	if infoItem then
		UIUtil.SetImageSprite(self.ImgFundIcon, infoItem:GetIcon(), self)
	end

	self.TxtFundValue.text = infoUnion.pb.coin
	self.TxtMemberNum.text = infoUnion.curMemberNum .. "/" .. infoUnion.maxMemberNum
	self.TxtHeadNick.text = infoUnion:GetOwnerName()

	self:UpdateUnionNotice()
end

function PageUnion:UpdateUnionNotice()
	local strNotice = self.infoUnion.notice

	if not strNotice or strNotice == "" then
		self.TxtNotice.color = getColorFromString("7A8185")
	else
		self.TxtNotice.color = getColorFromString("BBC3C8")
	end

	self.TxtNotice.text = self.infoUnion:GetNotice()
end

function PageUnion:UpdateRaidOpenState()
	local isOpenning = UnionRaidMgr.IsRaidOpen()

	GOUtil.SetActive(self.GoRaidLock, not isOpenning)
	GOUtil.SetActive(self.GoRaidUnlock, isOpenning)

	self.disableUpdate = isOpenning
end

function PageUnion:OnClickedBtnChangeNotice()
	if not UnionMgr.HasUnion(true) then
		return
	end

	require("UI/Page/PagePlayerInfo/DlgModifyNick")

	local str = self.infoUnion:GetNotice()

	UIMgr.AddPanel(DlgModifyNick(), {
		eModifyInputType.UnionNotice,
		str
	})
end

function PageUnion:OnClickedBtnUpLevel()
	if not UnionMgr.HasUnion(true) then
		return
	end

	if self.infoUnion.curLevel >= self.infoUnion.maxLevel then
		UIMgr.ShowMsg(_("Msg_Union_Level_Max"))

		return
	end

	if self.infoUnion.curLiveness < self.infoUnion.nextLiveness then
		UIMgr.ShowMsg(_("Msg_Liveness_Less"))

		return
	end

	self:RequestServer(UnionOperateType.upLevel)
end

function PageUnion:OnClickedBtnRecruit()
	if not UnionMgr.HasUnion(true) then
		return
	end

	if LocalTimeDownNetManagerShow("P167_Response_11", 1) then
		return
	end

	self:RequestServer(UnionOperateType.recruit)
end

function PageUnion:RequestServer(cmd)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if cmd == UnionOperateType.upLevel then
				UIMgr.ShowMsg(_("Msg_Union_Level_Up_Success"))
				self:UpdatePanel()
			elseif cmd == UnionOperateType.recruit then
				UIMgr.ShowMsg(Lang(42517))
			end
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		elseif cmd == UnionOperateType.upLevel and vMsg.result.code == 4 then
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)

			local function cb()
				self:UpdatePanel()
			end

			self.RequestData(cb)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestOperateUnionOrMember({
		cmd = cmd
	}, wrap_cb)
end

function PageUnion:OnClickedBtnMember()
	if not UnionMgr.HasUnion(true) then
		return
	end

	require("UI/Page/PageUnion/PageUnionMember")
	PageUnionMember.RequestData()
end

function PageUnion:OnClickedBtnTask()
	require("UI/Page/PageUnionFunction/PageUnionTask")

	local function cb()
		UIMgr.SwitchPanel(PageUnionTask)
	end

	PageUnionTask.RequestData(cb)
end

function PageUnion:OnClickedBtnPray()
	if not UnionMgr.HasUnion(true) then
		return
	end

	require("UI/Page/PageUnionFunction/PageUnionWish")

	local function cb()
		UIMgr.SwitchPanel(PageUnionWish)
	end

	PageUnionWish.RequestData(cb)
end

function PageUnion:OnClickedBtnSkill()
	if not UnionMgr.HasUnion(true) then
		return
	end

	require("UI/Page/PageUnionFunction/PageUnionSkill")

	local function cb()
		UIMgr.SwitchPanel(PageUnionSkill)
	end

	PageUnionSkill.RequestData(cb)
end

function PageUnion:OnClickedBtnRaid()
	if not UnionMgr.HasUnion(true) then
		return
	end

	local isOpenning = UnionRaidMgr.IsRaidOpen()

	if not isOpenning then
		UIMgr.ShowMsg(string.format(_("Desc_Open_Time"), UnionRaidMgr.GetRaidOpenTime()))

		return
	end

	require("UI/Page/PageUnionRaid/PageUnionRaid")

	local function cb()
		UIMgr.SwitchPanel(PageUnionRaid)
	end

	PageUnionRaid.RequestData(cb)
end

function PageUnion:OnClickedBtnGvg()
	if not Infogvg:IsPlayOpen() and not Infogvg:ClosingActive() then
		UIMgr.ShowMsg(_("Msg_Gvg_Active_Over"))

		return
	end

	Infogvg:Refresh(true)
end

function PageUnion:OnClickedBtnShop()
	require("UI/Page/PageShop/PageShop")
	PageShop.InitNetData({
		tagIndex = 3,
		tabMainIndex = tabMainType.exchange
	})
end

function PageUnion:OnClickedBtnGuide()
	require("UI/Dlg/Public/GuideChooseTip")
	UIMgr.AddPanel(GuideChooseTip(), {
		guideType = "UnionGuide"
	})
end

function PageUnion.GoBackMainPage(vMsg)
	UnionMgr:DisbandUnion()
	UIMgr.ClearAndSavePageMainStage()
	UIMgr.PopPanel(nil, 0)

	if vMsg ~= nil then
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	else
		UIMgr.ShowMsg(_("Msg_Union_Been_Disband"))
	end
end

function PageUnion:OnUpdateSecond()
	if self.disableUpdate == nil or self.disableUpdate then
		return
	end

	if UnionRaidMgr.IsRaidOpen() then
		if self.isOnEnter then
			self:UpdateRaidOpenState()
		end

		self.disableUpdate = true

		return
	end
end
