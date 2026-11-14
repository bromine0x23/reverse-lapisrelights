-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageClassroom/DlgMailDetail.lua

require("UI/Item/CellItem")

DlgMailDetail = class("DlgMailDetail", UIPanel)

function DlgMailDetail:ctor()
	DlgMailDetail.base.ctor(self, "UI/PanelMainStage/DlgMailDetail")
end

function DlgMailDetail:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCell", GameObject)
end

function DlgMailDetail:Purge()
	DlgMailDetail.base.Purge(self)
	UIMgr.RemoveUpdatePanel(self)
	self:OnLeave()
end

function DlgMailDetail:OnLeave()
	ResourceMgr.Unload(self.PrefabCell)

	if self.listItem then
		for _, item in pairs(self.listItem) do
			if item.OnLeave ~= nil then
				item:OnLeave()
			end
		end

		self.listItem = nil
	end

	if self.ScrollView then
		GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
	end
end

function DlgMailDetail:OnRegisterEvent()
	self:AddClick(self.BtnReceive, self.OnClickedBtnReceive)
	self:AddClick(self.BtnDelete, self.OnClickedBtnDelete)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	self:AddClick(self.BtnUnLock, self.OnClickedBtnUnLock)
	self:AddClick(self.BtnLock, self.OnClickedBtnLock)
end

function DlgMailDetail:OnUnRegisterEvent()
	self:RemoveClick(self.BtnReceive, self.OnClickedBtnReceive)
	self:RemoveClick(self.BtnDelete, self.OnClickedBtnDelete)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	self:RemoveClick(self.BtnUnLock, self.OnClickedBtnUnLock)
	self:RemoveClick(self.BtnLock, self.OnClickedBtnLock)
end

function DlgMailDetail:OnEnter(vParam)
	self:DealWithLocalization()

	self.GoRect = self:GetChildGameObject("Panel/BgTitle/Rect")
	self.GoTitle = self:GetChildGameObject("Panel/BgTitle/Rect/Text")
	self.ScrollArea = self:GetChildGameObject("Panel/Mail/ScrollArea")
	self.Scrollbar = self:GetChildGameObject("Panel/Mail/Scrollbar")
	self.GoBgItem = self:GetChildGameObject("Panel/Mail/BgItem")
	self.BtnReceive = self:GetChildGameObject("Panel/BtnReceive")
	self.BtnDelete = self:GetChildGameObject("Panel/BtnDelete")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.BtnUnLock = self:GetChildGameObject("Panel/BtnUnLock")
	self.BtnLock = self:GetChildGameObject("Panel/BtnLock")

	if vParam and vParam.infoMail then
		self.infoMail = vParam.infoMail
		self.listAward = self.infoMail.assets

		if #self.listAward > 0 then
			self:InitScrollView()
		end

		self:UpdatePanel()
		MailMgr:ReadMail(self.infoMail)
	end
end

function DlgMailDetail:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/From/Text", "Text")

	Text.text = _("Mial_Source")
	Text = self:GetChildComponent("Panel/Limit/Text", "Text")
	Text.text = _("Mail_Rec_Limit")
	Text = self:GetChildComponent("Panel/BtnReceive/Text", "Text")
	Text.text = _("Desc_Get")
	Text = self:GetChildComponent("Panel/BtnDelete/Text", "Text")
	Text.text = _("UI_Delete")
end

function DlgMailDetail:InitScrollView()
	local area = self:GetChildGameObject("Panel/Mail/BgItem/ItemArea")

	self.ScrollView = GOUtil.AddMissingComponent(area, "UIScrollView")
	self.ScrollView.content = self:GetChildComponent("Panel/Mail/BgItem/ItemArea/Group", "Transform")
	self.ScrollView.horizontal = true

	self:UpdateItem()
end

function DlgMailDetail:UpdateItem()
	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)

	if #self.listAward <= 0 then
		return
	end

	self.listItem = {}

	for i = 1, #self.listAward do
		local item = CellItem(self.PrefabCell, self.ScrollView.content.gameObject)

		item:Create()

		local infoItem = self.listAward[i].infoItem

		item:UpdateWithNumType(infoItem)
		item:SetIconGray(self.listAward[i].state == 1)

		item.tipData = {
			showNum = true,
			initPanelIndex = 1,
			needFromBtn = false
		}

		local scrollViewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

		scrollViewContent.scrollView = self.ScrollView

		table.insert(self.listItem, item)
	end
end

function DlgMailDetail:UpdatePanel()
	local txtMail = GOUtil.GetComponent(self.GoTitle, "Text")
	local txtSource = self:GetChildComponent("Panel/From/TxtSource", "Text")
	local txtLimit = self:GetChildComponent("Panel/Limit/TxtTime", "Text")
	local txtContent = self:GetChildComponent("Panel/Mail/ScrollArea/Content", "TextView")

	txtMail.text = self.infoMail.pb.title

	UIUtil.ForceRebuildLayoutImmediate(self.GoTitle)

	self.TitleWidth = GOUtil.GetRectTransformWidth(self.GoTitle)
	self.RectWidth = GOUtil.GetRectTransformWidth(self.GoRect)

	if self.TitleWidth > self.RectWidth then
		self.curPosition = (self.TitleWidth - self.RectWidth) / 2 + 20

		GOUtil.SetTransformLocalPosition(self.GoTitle, self.curPosition, 0, 0)
		UIMgr.SetUpdatePanel(self)
	end

	txtSource.text = "  " .. self.infoMail.pb.sender

	if self.infoMail.pb.endTime == 0 then
		txtLimit.text = "  " .. _("Mail_NoLimit")
	else
		local second = self.infoMail.pb.endTime / DateUtil.MillsPerSecond

		txtLimit.text = os.date("  %Y.%m.%d %H:%M", second)
	end

	txtContent.Text = ModifyRichTextForTextView(self.infoMail.pb.content)

	local haveLock = self.infoMail:IsLocked()

	self.BtnLock:SetActive(haveLock)
	self.BtnUnLock:SetActive(not haveLock)
	self:UpdateReceiveState(true)
end

function DlgMailDetail:UpdateReceiveState(isFirst)
	local haveAnnex = self.infoMail:HaveAnnex()
	local haveReced = self.infoMail:IsReceived()

	self.BtnReceive:SetActive(haveAnnex and not haveReced)
	self.BtnDelete:SetActive(not haveAnnex or haveReced)

	if not isFirst then
		return
	end

	self.GoBgItem:SetActive(haveAnnex)

	local ha = haveAnnex and 230 or 390
	local wa = GOUtil.GetRectTransformSizeDeltaWidth(self.ScrollArea)

	GOUtil.SetRectTransformSizeDelta(self.ScrollArea, wa, ha)

	local hb = haveAnnex and 160 or 320
	local wb = GOUtil.GetRectTransformSizeDeltaWidth(self.Scrollbar)

	GOUtil.SetRectTransformSizeDelta(self.Scrollbar, wb, hb)
end

function DlgMailDetail:OnClickedBtnReceive()
	local function wrap_cb(vMsg)
		self:ResponseMailsGift(vMsg)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestMailsGift({
		self.infoMail.id
	}, wrap_cb)
end

function DlgMailDetail:ResponseMailsGift(vMsg)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		if not vMsg.mailAwards then
			return
		end

		for i = 1, #vMsg.mailAwards do
			local mailAward = vMsg.mailAwards[i]
			local infoMail = MailMgr:GetMail(tonumber(mailAward.id))

			infoMail:ResetData(mailAward.leftAwards)
		end

		if self.infoMail:IsOverflow() and self.infoMail:IsReceived() then
			MailMgr:RemoveOneFromAllMail(self.infoMail.id)
			MailMgr:RemoveMailFromRead(self.infoMail)
			Event.Instance:Fire("RefreshMailList", {
				self.infoMail.id
			})
			self:Close()
		else
			self.listAward = self.infoMail.assets

			self:UpdateReceiveState()
			self:UpdateItem()
		end
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function DlgMailDetail:OnClickedBtnDelete()
	local haveLock = self.infoMail:IsLocked()

	if haveLock then
		UIMgr.ShowMsg(_("Msg_Mail_Locked"))

		return
	end

	local listId = {
		self.infoMail.id
	}
	local txtTitle = _("Mail_Confirm_Del")
	local msg = _("Mail_Prompt_Delete")
	local txtOk = _("Button_Yes")
	local txtCancle = _("Button_No")

	local function wrap_cb1(pb)
		self:ResponseDeleteMail(pb)
	end

	local function wrap_cb2(index)
		if index == 1 then
			NetManager:RequestDeleteMail(listId, wrap_cb1)
			LoadingMgr.Show(eLoadingType.Repeat)
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Del, txtTitle, msg, wrap_cb2, txtOk, txtCancle, false)
end

function DlgMailDetail:ResponseDeleteMail(vMsg)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vMsg.result.code == 0 then
		MailMgr:RemoveMailFromRead(self.infoMail)
		Event.Instance:Fire("RefreshMailList", {
			self.infoMail.id
		})
		MailMgr:RemoveOneFromAllMail(self.infoMail.id)
		UIMgr.ShowMsg(_("Msg_Mail_Del_Success"))
		self:Close()
	else
		UIMgr.ShowMsg(vMsg.result.desc, vMsg)
	end
end

function DlgMailDetail:OnClickedBtnUnLock()
	self.BtnLock:SetActive(true)
	self.BtnUnLock:SetActive(false)
	MailMgr:LockMail(self.infoMail)
end

function DlgMailDetail:OnClickedBtnLock()
	self.BtnLock:SetActive(false)
	self.BtnUnLock:SetActive(true)
	MailMgr:RemoveMailFromLock(self.infoMail)
end

function DlgMailDetail:OnClickedBtnClose()
	Event.Instance:Fire("RefreshMailList")
	self:Close()
end

local speed = 60
local delayTime = 2

function DlgMailDetail:OnUpdate()
	self.lastTime = (self.lastTime or 0) + Time.deltaTime

	if self.lastTime <= delayTime then
		return
	end

	self.curPosition = self.curPosition - speed * Time.deltaTime

	if self.curPosition < -(self.RectWidth + self.TitleWidth) / 2 - 10 then
		self.curPosition = (self.RectWidth + self.TitleWidth) / 2
	end

	GOUtil.SetTransformLocalPosition(self.GoTitle, self.curPosition, 0, 0)
end
