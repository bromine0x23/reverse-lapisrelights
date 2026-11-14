-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageClassroom/DlgMail.lua

require("UI/Dlg/Common/DlgCardFilter")
require("UI/Page/PageClassroom/CellMail")

DlgMail = class("DlgMail", UIPanel)

function DlgMail:ctor()
	self.UIPrefabPath = "UI/PanelMainStage/PanelMail"
end

function DlgMail:PreLoad()
	self:LoadResAsync("UI/PanelMainStage/CellMail", "PrefabCell")
end

function DlgMail:Purge()
	DlgMail.base.Purge(self)
	self:OnLeave()
end

function DlgMail:OnLeave()
	ResourceMgr.Unload(self.PrefabCell)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgMail:OnRegisterEvent()
	self:AddClick(self.BtnAsc, self.OnClickedBtnAsc)
	self:AddClick(self.BtnDesc, self.OnClickedBtnDesc)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	self:AddClick(self.BtnFilter, self.OnClickedBtnFilter)
	self:AddClick(self.BtnRece.gameObject, self.OnClickedBtnRece)
	self:AddClick(self.BtnDel, self.OnClickedBtnDel)
	Event.Instance:Add("RefreshMailList", self.RefreshMailList, self)
end

function DlgMail:OnUnRegisterEvent()
	self:RemoveClick(self.BtnAsc, self.OnClickedBtnAsc)
	self:RemoveClick(self.BtnDesc, self.OnClickedBtnDesc)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	self:RemoveClick(self.BtnFilter, self.OnClickedBtnFilter)
	self:RemoveClick(self.BtnRece.gameObject, self.OnClickedBtnRece)
	self:RemoveClick(self.BtnDel, self.OnClickedBtnDel)
	Event.Instance:Remove("RefreshMailList", self.RefreshMailList, self)
end

function DlgMail:OnEnter(vParam)
	self:DealWithLocalization()

	self.BtnFilter = self:GetChildGameObject("Panel/BtnFilter")
	self.BtnAsc = self:GetChildGameObject("Panel/BtnAsc")
	self.BtnDesc = self:GetChildGameObject("Panel/BtnDesc")
	self.BtnRece = self:GetChildComponent("Panel/Receive/BtnRec", "Image")
	self.BtnDel = self:GetChildGameObject("Panel/Receive/BtnDel")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.GoNoneMail = self:GetChildGameObject("Panel/NoneMail")

	self:Init()
end

function DlgMail:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = _("Mail")

	local Text = self:GetChildComponent("Panel/Receive/BtnRec/Text", "Text")

	Text.text = _("Desc_OneKeyRec")

	local Text = self:GetChildComponent("Panel/Receive/BtnDel/Text", "Text")

	Text.text = _("Desc_DelRead")

	local Text = self:GetChildComponent("Panel/Receive/Text", "Text")

	Text.text = _("Mail_Prompt_Expired")
	Text = self:GetChildComponent("Panel/BtnFilter/Text", "Text")
	Text.text = _("Filter")
	Text = self:GetChildComponent("Panel/NoneMail/Text", "Text")
	Text.text = _("Desc_Mail_None")
end

function DlgMail:Init()
	self.listMail = MailMgr:GetListMail()

	self.GoNoneMail:SetActive(#self.listMail == 0)
	self.BtnAsc:SetActive(true)
	self.BtnDesc:SetActive(false)
	self:InitCell()

	self.listState = {
		{
			0,
			0
		},
		{
			0,
			0,
			0
		}
	}

	local listAllCanRecId = MailMgr:GetOneKeyReceiveMailIds()
	local listRecId = self:GetOperationalMails(listAllCanRecId)
	local gray = TenaryOp(#listRecId > 0, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.BtnRece, gray))
end

function DlgMail:InitCell()
	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listMail

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellMail, self, false)

	self.UIScrollTool.ScrollView.verticalScrollbar = self:GetChildComponent("Panel/Scrollbar", "Scrollbar")
end

function DlgMail:UpdateCell(item, index)
	local infoMail = self.listMail[index]

	item:UpdateData(infoMail)
end

function DlgMail:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function DlgMail:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local infoMail = self.listMail[index]
	local isExpired = infoMail:IsExpired()

	if isExpired then
		UIMgr.ShowMsg(_("Msg_Mail_Expired"))
		self:RefreshMailList({
			infoMail.id
		})
		MailMgr:RemoveMailFromRead(infoMail)
		MailMgr:RemoveMailFromLock(infoMail)
		MailMgr:RemoveOneFromAllMail(infoMail.id)
		MailRDL.DealMail()

		return
	end

	local data = {}

	data.infoMail = infoMail

	require("UI/Page/PageClassroom/DlgMailDetail")
	UIMgr.AddPanel(DlgMailDetail(), data)
end

function DlgMail:OnClickedBtnFilter()
	local listState = self.listState
	local data = {
		{
			filterType = 1,
			title = _("Mail_Rec_Limit"),
			list = {
				_("Mail_Time_Limit"),
				_("Mail_Time_NoLimit")
			}
		},
		{
			filterType = 2,
			title = _("Mail_From_Source"),
			list = {
				_("Mail_From_System"),
				_("Mail_From_Idol"),
				_("Desc_MaxNumMail")
			}
		},
		panel = self,
		callback = self.ChangeFilter,
		listState = listState
	}

	UIMgr.AddPanel(DlgCardFilter(), data)
end

function DlgMail:ChangeFilter(data)
	local hasChange = data.hasChange

	self.listState = data.listState

	if hasChange then
		self.listMail = self:FilterMailList()

		if table.getn(self.listMail) == 0 then
			UIMgr.ShowMsg(_("Msg_Mail_NotFull"))
		end

		self.UIScrollTool:UpdateListData(self.listMail)
		self.GoNoneMail:SetActive(#self.listMail == 0)
	end
end

function DlgMail:FilterMailList()
	local listTime = self.listState[1]
	local listSend = self.listState[2]
	local timeType = 0

	for i = 1, #listTime do
		if listTime[i] > 0 then
			timeType = i

			break
		end
	end

	local listSource = {}

	for i = 1, #listSend do
		if listSend[i] > 0 then
			local _type = i ~= 3 and i or 4

			table.insert(listSource, _type)
		end
	end

	local list = {}

	list = MailMgr:GetMailsByTimeType(timeType)

	local cnt = #listSource

	if #list > 0 and cnt ~= 0 and cnt ~= 3 then
		if cnt == 1 then
			for i = #list, 1, -1 do
				if list[i].pb.sendType ~= listSource[1] then
					table.remove(list, i)
				end
			end
		elseif cnt == 2 then
			for i = #list, 1, -1 do
				local sendType = tonumber(list[i].pb.sendType)

				if sendType ~= listSource[1] and sendType ~= listSource[2] then
					table.remove(list, i)
				end
			end
		end
	end

	return list
end

function DlgMail:OnClickedBtnAsc()
	self.BtnAsc:SetActive(false)
	self.BtnDesc:SetActive(true)
	MailMgr:SortMailByTime(self.listMail)
	self.UIScrollTool:UpdateListData(self.listMail)
end

function DlgMail:OnClickedBtnDesc()
	self.BtnAsc:SetActive(true)
	self.BtnDesc:SetActive(false)
	MailMgr:SortMailByTime(self.listMail, true)
	self.UIScrollTool:UpdateListData(self.listMail)
end

function DlgMail:GetOperationalMails(mailIds)
	local list = {}

	for i = 1, #mailIds do
		for j = 1, #self.listMail do
			if mailIds[i] == self.listMail[j].id then
				table.insert(list, mailIds[i])

				break
			end
		end
	end

	return list
end

function DlgMail:RefreshMailList(listDelId)
	self.listMail = self:FilterMailList()

	if listDelId then
		for k, v in pairs(listDelId) do
			for i = #self.listMail, 1, -1 do
				if v == self.listMail[i].id then
					table.remove(self.listMail, i)

					break
				end
			end
		end
	end

	self.UIScrollTool:UpdateListDataKeepPos(self.listMail)
	self.GoNoneMail:SetActive(#self.listMail == 0)
end

function DlgMail:OnClickedBtnRece()
	local listAllCanRecId = MailMgr:GetOneKeyReceiveMailIds()
	local listRecId = self:GetOperationalMails(listAllCanRecId)

	if #listRecId <= 0 then
		UIMgr.ShowMsg(_("Msg_Mail_Recv_Unable"))

		return
	end

	local function wrap_cb(vMsg)
		self:ResponseMailsGift(vMsg, listRecId)
	end

	NetManager:RequestMailsGift(listRecId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgMail:ResponseMailsGift(vMsg, listRecId)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		for i = 1, #vMsg.mailAwards do
			local mailAward = vMsg.mailAwards[i]
			local infoMail = MailMgr:GetMail(tonumber(mailAward.id))

			infoMail:ResetData(mailAward.leftAwards)
		end

		local listDel = {}

		for _, info in ipairs(self.listMail) do
			if info:IsReceived() and info:IsOverflow() then
				MailMgr:RemoveOneFromAllMail(info.id)
				MailMgr:RemoveMailFromRead(info)
				table.insert(listDel, info.id)
			else
				MailMgr:ReadMail(info)
			end
		end

		self:RefreshMailList(listDel)
		MailRDL.DealMail()

		local listAllCanRecId = MailMgr:GetOneKeyReceiveMailIds()
		local listRecId = self:GetOperationalMails(listAllCanRecId)
		local gray = TenaryOp(#listRecId > 0, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self.BtnRece, gray))
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function DlgMail:OnClickedBtnDel()
	local listAllId = MailMgr:GetReadUnlockMailIds()

	self.listDelId = self:GetOperationalMails(listAllId)

	local haveNotRec = false

	for i = #self.listDelId, 1, -1 do
		local infoMail = MailMgr:GetMail(self.listDelId[i])
		local haveAnnex = infoMail:HaveAnnex()
		local haveRec = infoMail:IsReceived()

		if haveAnnex and not haveRec then
			table.remove(self.listDelId, i)

			haveNotRec = haveNotRec or true
		end
	end

	if #self.listDelId <= 0 then
		UIMgr.ShowMsg(_("Msg_Mail_Dele_Unable"))

		return
	end

	local function wrap_cb(vMsg)
		self:ResponseDeleteMail(vMsg, haveNotRec)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestDeleteMail(self.listDelId, wrap_cb)
end

function DlgMail:ResponseDeleteMail(vMsg, haveNotRec)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		if haveNotRec then
			UIMgr.ShowMsg(_("Msg_Mail_Del_Success_HaveNotRecv"))
		else
			UIMgr.ShowMsg(_("Msg_Mail_Del_Success"))
		end

		for i = 1, #self.listDelId do
			local infoMail = MailMgr:GetMail(self.listDelId[i])

			MailMgr:RemoveMailFromRead(infoMail)
		end

		self:RefreshMailList(self.listDelId)
		MailMgr:RemoveSomeFromAllMail(self.listDelId)
		MailRDL.DealMail()
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function DlgMail:OnClickedBtnClose()
	Event.Instance:Fire("DealWithUIAnim", false)
	self:Close()
end

function DlgMail:OnBackAndroid()
	self:OnClickedBtnClose()
end
