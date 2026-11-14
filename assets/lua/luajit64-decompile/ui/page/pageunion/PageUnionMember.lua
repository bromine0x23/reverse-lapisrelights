-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/PageUnionMember.lua

require("UI/Page/PageUnion/CellUnionLog")
require("UI/Page/PageUnion/CellUnionMember")
require("UI/Page/PageUnion/DlgMemberDetail")

PageUnionMember = class("PageUnionMember", UIPanel)

function PageUnionMember:ctor()
	self.UIPrefabPath = "UI/PanelUnion/PanelUnionMember"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_UnionMembers"),
		callback = self.OnBack,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageUnionMember:PreLoad()
	self:LoadResAsync("UI/PanelUnion/CellUnionLog", "PrefabCellUnionLog", GameObject)
	self:LoadResAsync("UI/PanelUnion/CellUnionMember", "PrefabCellUnionMember", GameObject)
end

function PageUnionMember:OnBack()
	UIMgr.PopPanel()
end

function PageUnionMember:Purge()
	self.base.Purge(self)
	UITweenUtil.RemoveTween(self.content)
	self:OnLeave()
end

function PageUnionMember:OnLeave()
	ResourceMgr.Unload(self.PrefabCellUnionLog)
	ResourceMgr.Unload(self.PrefabCellUnionMember)

	if self.UIScrollToolMember then
		self.UIScrollToolMember:Purge()

		self.UIScrollToolMember = nil
	end

	if self.UIScrollToolLog then
		self.UIScrollToolLog:Purge()

		self.UIScrollToolLog = nil
	end

	if self.GoMineCell then
		if self.GoMineCell.OnLeave then
			self.GoMineCell:OnLeave()
		end

		self.GoMineCell = nil
	end
end

function PageUnionMember:OnRegisterEvent()
	self:AddClick(self.BtnQuit, self.OnClickedBtnQuitUnion, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnDisband, self.OnClickedBtnDisbandUnion)
	self:AddClick(self.BtnApplyList, self.OnClickedBtnApplyList)
	Event.Instance:Add("UpdateUnionLog", self.UpdateLogPanel, self)
	Event.Instance:Add("UpdateMemberList", self.UpdateMemberList, self)
	Event.Instance:Add("UpdateReleUnion", self.UpdateReleUnion, self)
	Event.Instance:Add("RequestMemberList", self.RequestMemberList, self)
end

function PageUnionMember:OnUnRegisterEvent()
	self:RemoveClick(self.BtnQuit, self.OnClickedBtnQuitUnion)
	self:RemoveClick(self.BtnDisband, self.OnClickedBtnDisbandUnion)
	self:RemoveClick(self.BtnApplyList, self.OnClickedBtnApplyList)
	Event.Instance:Remove("UpdateUnionLog", self.UpdateLogPanel, self)
	Event.Instance:Remove("UpdateMemberList", self.UpdateMemberList, self)
	Event.Instance:Remove("UpdateReleUnion", self.UpdateReleUnion, self)
	Event.Instance:Remove("RequestMemberList", self.RequestMemberList, self)
end

function PageUnionMember:OnEnter()
	self:DealWithLocalization()

	self.GoLogContent = self:GetChildGameObject("PanelLog/BgScroll/ScrollArea/Content")
	self.BtnQuit = self:GetChildGameObject("PanelMember/Event/BtnQuit")
	self.BtnDisband = self:GetChildGameObject("PanelMember/Event/BtnDisband")
	self.BtnApplyList = self:GetChildGameObject("PanelMember/Event/BtnApplyList")
	self.GoMinePoint = self:GetChildGameObject("PanelMember/MinePoint")
	self.GoPrompt = self:GetChildGameObject("PanelMember/Prompt")

	self:UpdatePanel()
end

function PageUnionMember:DealWithLocalization()
	local Text = self:GetChildComponent("PanelLog/Title/Text", "Text")

	Text.text = _("Desc_Union_Log")
	Text = self:GetChildComponent("PanelMember/Title/Text", "Text")
	Text.text = _("Desc_UnionMember_Overview")
	Text = self:GetChildComponent("PanelMember/Event/BtnDisband/Text", "Text")
	Text.text = _("UI_Disband_Union")
	Text = self:GetChildComponent("PanelMember/Event/BtnQuit/Text", "Text")
	Text.text = _("UI_Quick_Union")
	Text = self:GetChildComponent("PanelMember/Event/BtnApplyList/Text", "Text")
	Text.text = _("UI_Apply_List")
	Text = self:GetChildComponent("PanelMember/Prompt/Text", "Text")
	Text.text = _("Desc_Union_NoOther_Member")
end

function PageUnionMember.RequestData()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			UIMgr.SwitchPanel(PageUnionMember)
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestUnionMembersAndLogs(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageUnionMember:UpdatePanel()
	self:InitLogPanel()
	self:InitMineInfo()
	self:UpdateMemberPanel()
	self:UpdatePremissionUI()
end

function PageUnionMember:UpdateDot()
	local apply = UnionMgr.releUnion.applys

	GOUtil.SetActive(self.GoDot, #apply > 0)
end

function PageUnionMember:UpdatePremissionUI()
	local pid = PlayerInst.InfoPlayer.pid
	local jobId = UnionMemberMgr:GetMemberJob(pid)
	local canDisband = UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.disband)

	GOUtil.SetActive(self.BtnDisband, canDisband)
	GOUtil.SetActive(self.BtnQuit, not canDisband)

	local canDealApply = UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.apply)

	GOUtil.SetActive(self.BtnApplyList, canDealApply)
end

function PageUnionMember:InitLogPanel()
	self.listLog = UnionLogMgr.listLog

	local scrollArea = self:GetChildGameObject("PanelLog/ScrollArea")
	local content = self:GetChildComponent("PanelLog/ScrollArea/Content", "RectTransform")
	local count = #self.listLog

	local function addCallback(item)
		return
	end

	local function updateCallback(item, index)
		item:UpdateData(self.listLog[index])
	end

	self.UIScrollToolLog = UIScrollTool()

	self.UIScrollToolLog:InitList(scrollArea, content, count, self.PrefabCellUnionLog, CellUnionLog, self, false, addCallback, updateCallback)
end

function PageUnionMember:InitMineInfo()
	self.GoMineCell = CellUnionMember(self.PrefabCellUnionMember, self.GoMinePoint, self)

	self.GoMineCell:Create()
end

function PageUnionMember:UpdateMine()
	local infoMember = UnionMemberMgr:GetMember(PlayerInst.InfoPlayer.pid)

	self.GoMineCell:UpdateData(infoMember)
end

function PageUnionMember:UpdateMemberPanel(keepPos)
	self.listMember = UnionMemberMgr:SortMembers(UnionMemberMgr:GetListMemberNoMine())

	GOUtil.SetActive(self.GoPrompt, #self.listMember == 0)

	if not self.UIScrollToolMember then
		self:InitScrollView()
	elseif keepPos then
		self.UIScrollToolMember:UpdateListDataKeepPos(self.listMember)
	else
		self.UIScrollToolMember:UpdateListData(self.listMember)
	end

	self:UpdateMine()
end

function PageUnionMember:InitScrollView()
	local scrollArea = self:GetChildGameObject("PanelMember/ScrollArea")

	self.content = self:GetChildComponent("PanelMember/ScrollArea/Content", "RectTransform")

	local count = #self.listMember

	local function cellCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCellMember)
	end

	local function updateCallback(item, index)
		item:UpdateData(self.listMember[index])
	end

	self.UIScrollToolMember = UIScrollTool()

	self.UIScrollToolMember:InitList(scrollArea, self.content, count, self.PrefabCellUnionMember, CellUnionMember, self, false, cellCallback, updateCallback)
	UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
end

function PageUnionMember:OnClickedCellMember(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollToolMember.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local member = self.listMember[index]

	if member.pid == PlayerInst.InfoPlayer.pid then
		UIMgr.ShowMsg(_("Msg_Union_Self_Operate"))

		return
	end

	UIMgr.AddPanel(DlgMemberDetail(), {
		member = member
	})
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

function PageUnionMember:OnClickedBtnQuitUnion()
	local msg = _("Msg_Union_Quit")

	local function cb()
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess or vMsg.result.code == 2 then
				UIMgr.ClearAndSavePageMainStage()
				UIMgr.PopPanel(nil, 0)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		NetManager:RequestQuitUnion(wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	end

	CommonFunc(msg, cb)
end

function PageUnionMember:OnClickedBtnDisbandUnion()
	local msg = _("Msg_Union_Disband")

	local function cb()
		self:RequestOperateUnionOrMember(UnionOperateType.disband)
	end

	CommonFunc(msg, cb)
end

function PageUnionMember:RequestOperateUnionOrMember(cmd)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			if cmd == UnionOperateType.disband then
				UIMgr.ClearAndSavePageMainStage()
				UIMgr.PopPanel(nil, 0)
			end
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.code, vMsg)
		end
	end

	NetManager:RequestOperateUnionOrMember({
		cmd = cmd
	}, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageUnionMember:UpdateMemberList()
	self:UpdateMemberPanel(true)
end

function PageUnionMember:UpdateLogPanel()
	self.listLog = UnionLogMgr.listLog

	self.UIScrollToolLog:UpdateListDataKeepPos(self.listLog)

	local isDragging = self.UIScrollToolLog.ScrollView.IsDragging

	if not isDragging then
		self.UIScrollToolLog:SetContentPos(Vector2(0, 0), 0.5)
	end

	if self.UIScrollToolLog.ItemRoot2ItemDict then
		for k, v in self.UIScrollToolLog.ItemRoot2ItemDict:Enumerator() do
			if k == 1 then
				v.Item.Animator:Play("CellUnionLogScale")

				break
			end
		end
	end
end

function PageUnionMember:OnClickedBtnApplyList()
	require("UI/Page/PageUnion/DlgUnionApplyList")
	DlgUnionApplyList.InitData()
end

function PageUnionMember:UpdateReleUnion()
	if not UnionMgr.HasUnion() then
		return
	end

	self:UpdateMemberPanel()
	self:UpdatePremissionUI()
end

function PageUnionMember:RequestMemberList()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdateMemberPanel(true)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestUnionMembersAndLogs(wrap_cb)
end
