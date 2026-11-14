-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/DlgMemberDetail.lua

DlgMemberDetail = class("DlgMemberDetail", UIPanel)

function DlgMemberDetail:ctor()
	self.UIPrefabPath = "UI/PanelUnion/DlgMemberDetail"
end

function DlgMemberDetail:PreLoad()
	return
end

function DlgMemberDetail:Purge()
	self.base.Purge(self)
end

function DlgMemberDetail:OnRegisterEvent()
	self:AddClick(self.BtnShow, self.OnClickedBtnShow)
	self:AddClick(self.BtnHide, self.OnClickedBtnHide)
	self:AddClick(self.BtnKickUnion, self.OnClickedBtnKick)
	self:AddClick(self.BtnTranUnion, self.OnClickedBtnTranUnion)
	self:AddClick(self.BtnViewData, self.OnClickedBtnViewData)
	self:AddClick(self.BtnAddFriend, self.OnClickedBtnAddFriend)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
end

function DlgMemberDetail:OnUnRegisterEvent()
	self:RemoveClick(self.BtnShow, self.OnClickedBtnShow)
	self:RemoveClick(self.BtnHide, self.OnClickedBtnHide)
	self:RemoveClick(self.BtnKickUnion, self.OnClickedBtnKick)
	self:RemoveClick(self.BtnTranUnion, self.OnClickedBtnTranUnion)
	self:RemoveClick(self.BtnViewData, self.OnClickedBtnViewData)
	self:RemoveClick(self.BtnAddFriend, self.OnClickedBtnAddFriend)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)

	if self.listGoJob then
		self:RemoveClick(self.listGoJob[i], self.OnClickedGoJob)

		self.listGoJob = nil
	end
end

function DlgMemberDetail:OnEnter(vParam)
	self:DealWithLocalization()

	self.ImgMemberAvatar = self:GetChildComponent("Panel/Info/Avatar/Icon", "Image")
	self.ImgMemberHeadFrame = self:GetChildComponent("Panel/Info/Avatar/HeadFrame", "Image")
	self.TxtMemberName = self:GetChildComponent("Panel/Info/TxtName", "Text")
	self.TxtMemberLevel = self:GetChildComponent("Panel/Info/Level/TxtLevel", "Text")
	self.TxtMemberPosit = self:GetChildComponent("Panel/Info/Position/TxtPosit", "Text")
	self.BtnShow = self:GetChildGameObject("Panel/Info/BtnShow")
	self.BtnHide = self:GetChildGameObject("Panel/Info/BtnHide")
	self.PosList = self:GetChildGameObject("Panel/Info/PosList")
	self.BtnKickUnion = self:GetChildGameObject("Panel/BtnGroup/BtnKickUnion")
	self.BtnTranUnion = self:GetChildGameObject("Panel/BtnGroup/BtnTranUnion")
	self.BtnViewData = self:GetChildGameObject("Panel/BtnGroup/BtnViewData")
	self.BtnAddFriend = self:GetChildGameObject("Panel/BtnGroup/BtnAddFriend")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")

	self:InitData(vParam)
end

function DlgMemberDetail:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/Title/Text", "Text")
	Text.text = _("MemberDetail_Info")
	Text = self:GetChildComponent("Panel/Info/Level/Text", "Text")
	Text.text = Lang(12002)
	Text = self:GetChildComponent("Panel/Info/Position/Text", "Text")
	Text.text = Lang(42100)
	Text = self:GetChildComponent("Panel/BtnGroup/BtnKickUnion/Text", "Text")
	Text.text = _("UI_Kick_Union")
	Text = self:GetChildComponent("Panel/BtnGroup/BtnTranUnion/Text", "Text")
	Text.text = _("MemberDetail_PresidentTransfer")
	Text = self:GetChildComponent("Panel/BtnGroup/BtnViewData/Text", "Text")
	Text.text = _("UI_View_Data")
	Text = self:GetChildComponent("Panel/BtnGroup/BtnAddFriend/Text", "Text")
	Text.text = Lang(41037)
end

function DlgMemberDetail:InitData(vParam)
	self.infoMember = vParam.member
	self.infoOperator = UnionMemberMgr:GetMember(PlayerInst.InfoPlayer.pid)

	self:UpdatePanel()
end

function DlgMemberDetail:UpdatePanel()
	local avatarPath = self.infoMember:GetTitleIcon(PlayerTitleType.head)

	SetImageSprite(self.ImgMemberAvatar, avatarPath, self)

	local infoItem = ItemManager:Get(self.infoMember.headFrame)

	SetImageSprite(self.ImgMemberHeadFrame, infoItem:GetIcon(), self)

	self.TxtMemberName.text = self.infoMember.name
	self.TxtMemberLevel.text = self.infoMember.curLevel
	self.TxtMemberPosit.text = UnionJobMgr:GetUnionJobName(self.infoMember.jobId)

	local canTransfer = UnionJobMgr:HavePremission(self.infoOperator.jobId, UnionJobPremissionType.transfer)

	if canTransfer and self.infoMember.jobId ~= UnionJobType.head then
		GOUtil.SetActive(self.BtnShow, true)
	end

	local canTranUnion = UnionJobMgr:HavePremission(self.infoOperator.jobId, UnionJobPremissionType.tranUnion)
	local canRecvUnion = UnionMemberMgr:CanRecvUnion(self.infoMember.pid)

	GOUtil.SetActive(self.BtnTranUnion, canTranUnion and canRecvUnion and self.infoOperator.jobId == UnionJobType.head)

	local canKickUnion = UnionJobMgr:HavePremission(self.infoOperator.jobId, UnionJobPremissionType.tranUnion)

	GOUtil.SetActive(self.BtnKickUnion, canKickUnion and self.infoMember.jobId ~= UnionJobType.head)

	if FriendMgr:IsGameFriend(self.infoMember.pid) then
		GOUtil.SetActive(self.BtnAddFriend, false)
	end

	if canTransfer then
		if not self.inited then
			self:InitJobList()

			self.inited = true
		else
			self:UpdateJobList()
		end
	end
end

function DlgMemberDetail:InitJobList()
	self.listJob = UnionJobMgr:GetTransfersByJobType(self.infoOperator.jobId)
	self.curPosIdx = 1

	local goJob = GOUtil.FindChildGameObject(self.PosList, "Button")
	local jobGroup = GOUtil.FindChildGameObject(self.PosList, "Group")

	self.listGoJob = {}

	for i = 1, #self.listJob do
		local btnJob = GOUtil.InstantiateUI(goJob, jobGroup)
		local txtPos = GOUtil.FindChildComponent(btnJob, "Text", "Text")

		txtPos.text = UnionJobMgr:GetUnionJobName(self.listJob[i])
		btnJob.name = i

		self:AddClick(btnJob, self.OnClickedGoJob)
		table.insert(self.listGoJob, btnJob)
	end

	GOUtil.SetActive(goJob, false)
	self:UpdateJobList()
end

function DlgMemberDetail:UpdateJobList()
	if self.listGoJob == nil then
		return
	end

	for i = 1, #self.listJob do
		if self.infoMember.jobId == self.listJob[i] then
			self.curPosIdx = i
		end
	end

	for i = 1, #self.listGoJob do
		local btnJob = self.listGoJob[i]
		local imgBtnJob = GOUtil.GetComponent(btnJob, "Image")
		local goSelJob = GOUtil.FindChildGameObject(btnJob, "Select")

		imgBtnJob.enabled = tonumber(btnJob.name) ~= self.curPosIdx

		GOUtil.SetActive(goSelJob, tonumber(btnJob.name) == self.curPosIdx)
	end
end

function DlgMemberDetail:OnClickedGoJob(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)

	if index == self.curPosIdx then
		return
	end

	local canTransfer, msg = UnionJobMgr:CanTransfer(self.listJob[index])

	if not canTransfer then
		UIMgr.ShowMsg(msg)

		return
	end

	self.curPosIdx = index

	self:RequestOperateUnionOrMember(UnionOperateType.transfer)
end

function DlgMemberDetail:OnClickedBtnShow()
	GOUtil.SetActive(self.BtnShow, false)
	GOUtil.SetActive(self.BtnHide, true)
	GOUtil.SetActive(self.PosList, true)
end

function DlgMemberDetail:OnClickedBtnHide()
	GOUtil.SetActive(self.BtnShow, true)
	GOUtil.SetActive(self.BtnHide, false)
	GOUtil.SetActive(self.PosList, false)
end

local function CommonFunc(msg, callback)
	local function wrap_cb(index)
		if index == 1 then
			callback()
		end
	end

	local strTitle = _("Tittle_Affirm")
	local strOkText = _("Button_Yes")
	local strCancelText = _("Button_No")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, msg, wrap_cb, strOkText, strCancelText)
end

function DlgMemberDetail:OnClickedBtnKick()
	local msg = _("Msg_Union_Kick")

	local function wrap_cb()
		self:RequestOperateUnionOrMember(UnionOperateType.kick)
	end

	CommonFunc(msg, wrap_cb)
end

function DlgMemberDetail:OnClickedBtnTranUnion()
	local msg = _("Msg_Union_Tran")

	local function wrap_cb()
		if LocalTimeDownNetManagerShow("P167_Response_13", 1) then
			return
		end

		self:RequestOperateUnionOrMember(UnionOperateType.tranUnion)
	end

	CommonFunc(msg, wrap_cb)
end

function DlgMemberDetail:RequestOperateUnionOrMember(cmd)
	local vals = {
		cmd = cmd,
		targetId = self.infoMember.pid
	}

	if cmd == UnionOperateType.transfer then
		vals.targetJob = self.listJob[self.curPosIdx]
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if cmd == UnionOperateType.kick then
				self:Purge()
			else
				self:UpdatePanel()
			end

			Event.Instance:Fire("UpdateMemberList")
		elseif vMsg.result.code == 2 then
			self:Close()
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestOperateUnionOrMember(vals, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgMemberDetail:OnClickedBtnViewData()
	local playerId = self.infoMember.pid

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			local data = {}

			data.player = vMsg.player
			data.roleCards = vMsg.roleCards
			data.mainStageId = tonumber(vMsg.mainStageId)
			data.cardCount = vMsg.cardCount

			UIMgr.SwitchPanel(PagePlayer, data)
			self:Purge()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestPlayerInfo(playerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgMemberDetail:OnClickedBtnAddFriend()
	if not FriendMgr:IsCanRequestAgain(self.infoMember.pid) then
		return
	end

	if FriendMgr:IsOverMaxFriend() then
		UIMgr.ShowMsg(_("Msg_Friend_Num_Limit"))

		return
	end

	if InfoGameInst:IsOverRequestFriendNumToday() then
		UIMgr.ShowMsg(_("Msg_Apply_Limit_Today"))

		return
	end

	local listPlayerId = {
		self.infoMember.pid
	}

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			local listId = vMsg.playerId

			InfoGameInst:ChangeTodayRequestFriendNum(#listId)

			for i = 1, #listId do
				FriendMgr:AddToListRequest(listId[i])
			end

			UIMgr.ShowMsg(_("Msg_Sucess_Apply"))
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestAddFriend(listPlayerId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgMemberDetail:OnClickedBtnClose()
	self:Purge()
end
