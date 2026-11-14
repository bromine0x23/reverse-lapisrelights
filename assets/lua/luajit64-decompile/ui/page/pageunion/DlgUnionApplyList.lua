-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/DlgUnionApplyList.lua

require("UI/Page/PageUnion/CellApplyPlayer")

DlgUnionApplyList = class("DlgUnionApplyList", UIPanel)

function DlgUnionApplyList:ctor()
	self.UIPrefabPath = "UI/PanelUnion/DlgUnionApplyList"
end

function DlgUnionApplyList:PreLoad()
	self:LoadResAsync("UI/PanelUnion/CellApplyPlayer", "PrefabCellApplyPlayer", GameObject)
end

function DlgUnionApplyList:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellApplyPlayer)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgUnionApplyList:OnRegisterEvent()
	self:AddClick(self.BtnShow, self.OnClickedBtnShow)
	self:AddClick(self.BtnHide, self.OnClickedBtnHide)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnCloseApply, self.OnClickedBtnCloseApply)
	self:AddClick(self.BtnAutoRatify, self.OnClickedBtnAutoRatify)
	self:AddClick(self.BtnManualRatify, self.OnClickedBtnManualRatify)
	Event.Instance:Add("UpdateApplylist", self.UpdateApplylist, self)
	Event.Instance:Add("UpdateUnionApply", self.ResetApplyList, self)
	Event.Instance:Add("DlgOpPlayer", self.ShowPlayerDetail, self)
end

function DlgUnionApplyList:OnUnRegisterEvent()
	self:RemoveClick(self.BtnShow, self.OnClickedBtnShow)
	self:RemoveClick(self.BtnHide, self.OnClickedBtnHide)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	self:RemoveClick(self.BtnCloseApply, self.OnClickedBtnCloseApply)
	self:RemoveClick(self.BtnAutoRatify, self.OnClickedBtnAutoRatify)
	self:RemoveClick(self.BtnManualRatify, self.OnClickedBtnManualRatify)
	Event.Instance:Remove("UpdateApplylist", self.UpdateApplylist, self)
	Event.Instance:Remove("UpdateUnionApply", self.ResetApplyList, self)
	Event.Instance:Remove("DlgOpPlayer", self.ShowPlayerDetail, self)

	if self.listGoLevel then
		for i = 1, #self.listGoLevel do
			self:RemoveClick(self.listGoLevel[i], self.OnClickedBtnRecruitLevel)
		end

		self.listGoLevel = nil
	end
end

function DlgUnionApplyList.InitData()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			UIMgr.AddPanel(DlgUnionApplyList())
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestUnionMembers(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgUnionApplyList:OnEnter(vParam)
	self:DealWithLocalization()

	self.GoEvent = self:GetChildGameObject("Panel/Event")
	self.BtnCloseApply = self:GetChildGameObject("Panel/Event/CloseApply/BtnCloseApply")
	self.SelCloseApply = self:GetChildGameObject("Panel/Event/CloseApply/SelCloseApply")
	self.BtnAutoRatify = self:GetChildGameObject("Panel/Event/AutoRatify/BtnAutoRatify")
	self.SelAutoRatify = self:GetChildGameObject("Panel/Event/AutoRatify/SelAutoRatify")
	self.BtnManualRatify = self:GetChildGameObject("Panel/Event/ManualRatify/BtnManualRatify")
	self.SelManualRatify = self:GetChildGameObject("Panel/Event/ManualRatify/SelManualRatify")
	self.GoRecruit = self:GetChildGameObject("Panel/Recruit")
	self.TxtRecruitLevel = self:GetChildComponent("Panel/Recruit/Level/TxtLevel", "Text")
	self.LvGroup = self:GetChildGameObject("Panel/Recruit/LvGroup")
	self.BtnShow = self:GetChildGameObject("Panel/Recruit/BtnShow")
	self.BtnHide = self:GetChildGameObject("Panel/Recruit/BtnHide")
	self.LvGroupAnim = self:GetChildComponent("Panel/Recruit", "Animator")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.GoNoApply = self:GetChildGameObject("Panel/TxtNoApply")

	self:UpdatePanel()
	UnionRDL.MemberRDL.CancelRD()
end

function DlgUnionApplyList:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Title/Text", "Text")
	txt.text = _("UI_Apply_List")
	txt = self:GetChildComponent("Panel/Event/CloseApply/TxtApply", "Text")
	txt.text = _("Toggle_Close_Apply")
	txt = self:GetChildComponent("Panel/Event/AutoRatify/TxtAuto", "Text")
	txt.text = _("Toggle_Auto_Ratify")
	txt = self:GetChildComponent("Panel/Event/ManualRatify/TxtManual", "Text")
	txt.text = _("Toggle_Manual_Ratify")
	txt = self:GetChildComponent("Panel/TxtNoApply", "Text")
	txt.text = _("Msg_Friend_Not_Apply_1")
	txt = self:GetChildComponent("Panel/Recruit/Level/Text", "Text")
	txt.text = _("Union_Lowest_Recruit")
end

function DlgUnionApplyList:UpdatePanel()
	self:UpdateScrollView()
	self:UpdatePremissionPanel()
end

function DlgUnionApplyList:UpdateScrollView(keepPos)
	self.listApply = UnionApplyMgr.listApply

	GOUtil.SetActive(self.GoNoApply, #self.listApply == 0)

	if self.UIScrollTool then
		if keepPos then
			self.UIScrollTool:UpdateListDataKeepPos(self.listApply)
		else
			self.UIScrollTool:UpdateListData(self.listApply)
		end

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.listApply

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local infoPlayer = self.listApply[index]

		item:UpdateData(infoPlayer)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellApplyPlayer, CellApplyPlayer, self, false, addCallback, updateCallback)
end

function DlgUnionApplyList:UpdatePremissionPanel()
	local jobId = UnionMemberMgr:GetMemberJob(PlayerInst.InfoPlayer.pid)
	local canSetting = UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.setting)

	if not canSetting then
		GOUtil.SetActive(self.GoEvent, false)
		GOUtil.SetActive(self.GoRecruit, false)

		local scrollArea = self:GetChildGameObject("Panel/ScrollArea")

		GOUtil.SetRectTransformSizeDelta(scrollArea, 1560, 786)
	else
		if not self.initedLevel then
			self:InitRecruitLevel()
		end

		self:UpdateJoinType()
		self:UpdateJoinLevel()
	end
end

function DlgUnionApplyList:InitRecruitLevel()
	self.initedLevel = true
	self.listLevel = GetConfigArgJson("ClubRecruitLevel")
	self.curLevelIdx = 1

	local recruitLevel = UnionMgr.releUnion.joinLevel

	for i = 1, #self.listLevel do
		if recruitLevel == self.listLevel[i] then
			self.curLevelIdx = i
		end
	end

	local goLevel = self:GetChildGameObject("Panel/Recruit/LvGroup/Button")
	local goGroup = self:GetChildGameObject("Panel/Recruit/LvGroup/Group")

	self.listGoLevel = {}

	for i = 1, #self.listLevel do
		local btnLevel = GOUtil.Instantiate(goLevel, goGroup)
		local txtLevel = GOUtil.FindChildComponent(btnLevel, "Text", "Text")
		local level = self.listLevel[#self.listLevel + 1 - i]

		if level == 0 then
			txtLevel.text = Lang(12289)
		else
			txtLevel.text = level
		end

		self:AddClick(btnLevel, self.OnClickedBtnRecruitLevel)

		btnLevel.name = #self.listLevel + 1 - i

		table.insert(self.listGoLevel, btnLevel)
	end

	GOUtil.SetActive(goLevel, false)
end

function DlgUnionApplyList:UpdateJoinLevel()
	if self.listGoLevel == nil then
		return
	end

	for i = 1, #self.listGoLevel do
		local goLevel = self.listGoLevel[i]
		local imgBtn = GOUtil.GetComponent(goLevel, "Image")
		local goSel = GOUtil.FindChildGameObject(goLevel, "Select")

		imgBtn.enabled = tonumber(goLevel.name) ~= self.curLevelIdx

		GOUtil.SetActive(goSel, tonumber(goLevel.name) == self.curLevelIdx)
	end

	if self.listLevel[self.curLevelIdx] == 0 then
		self.TxtRecruitLevel.text = _("Mail_NoLimit")
	else
		self.TxtRecruitLevel.text = self.listLevel[self.curLevelIdx]
	end
end

function DlgUnionApplyList:OnClickedBtnShow()
	self.LvGroupAnim:Play("ScaleOpenAnim")
	GOUtil.SetActive(self.BtnShow, false)
	GOUtil.SetActive(self.BtnHide, true)
end

function DlgUnionApplyList:OnClickedBtnHide()
	self.LvGroupAnim:Play("ScaleCloseAnim")
	GOUtil.SetActive(self.BtnShow, true)
	GOUtil.SetActive(self.BtnHide, false)
end

function DlgUnionApplyList:OnClickedBtnRecruitLevel(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)

	if index == self.curLevelIdx then
		return
	end

	local function func()
		self.curLevelIdx = index

		UnionMgr:ChangeJoinLevel(self.listLevel[index])
		self:UpdateJoinLevel()
	end

	self:RequestUnionSetting(nil, nil, self.listLevel[index], func)
end

function DlgUnionApplyList:UpdateJoinType()
	self.joinType = UnionMgr.releUnion.joinType

	GOUtil.SetActive(self.SelCloseApply, self.joinType == 3)
	GOUtil.SetActive(self.SelAutoRatify, self.joinType == 2)
	GOUtil.SetActive(self.SelManualRatify, self.joinType == 1)
end

function DlgUnionApplyList:OnClickedBtnCloseApply()
	if self.joinType == 3 then
		return
	end

	self:RequestAboutJoinType(UnionJoinType.close)
end

function DlgUnionApplyList:OnClickedBtnAutoRatify()
	if self.joinType == 2 then
		return
	end

	self:RequestAboutJoinType(UnionJoinType.auto)
end

function DlgUnionApplyList:OnClickedBtnManualRatify()
	if self.joinType == 1 then
		return
	end

	self:RequestAboutJoinType(UnionJoinType.manual)
end

function DlgUnionApplyList:RequestAboutJoinType(joinType)
	if joinType == UnionMgr.releUnion.joinType then
		return
	end

	local function func()
		UnionMgr:ChangeJoinType(joinType)
		self:UpdateJoinType()
	end

	self:RequestUnionSetting(nil, joinType, self.listLevel[self.curLevelIdx], func)
end

function DlgUnionApplyList:RequestUnionSetting(notice, applyType, applyLevel, func)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			func()
		elseif vMsg.result.code == 2 then
			self:Close()
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestUnionSetting(notice, applyType, applyLevel, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgUnionApplyList:OnClickedBtnClose()
	self:Purge()
end

function DlgUnionApplyList:UpdateApplylist()
	self:UpdateScrollView(true)
	Event.Instance:Fire("UpdateApplyAfterOp")
end

function DlgUnionApplyList:ResetApplyList()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdatePanel()
		elseif vMsg.result.code == 2 then
			self:Close()
			PageUnion.GoBackMainPage(vMsg)
		end
	end

	NetManager:RequestUnionMembers(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgUnionApplyList:ShowPlayerDetail(info)
	if not info then
		return
	end

	local data = {
		type = 100,
		info = info,
		callback = function()
			self:Close()
		end
	}

	require("UI/Page/PageFriend/DlgOpPlayer")
	UIMgr.AddPanel(DlgOpPlayer(), data)
end
