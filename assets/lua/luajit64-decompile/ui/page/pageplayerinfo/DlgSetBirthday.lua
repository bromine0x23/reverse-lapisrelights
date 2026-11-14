-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/DlgSetBirthday.lua

DlgSetBirthday = class("DlgSetBirthday", UIPanel)

function DlgSetBirthday:ctor()
	DlgSetBirthday.base.ctor(self, "UI/PanelPlayerInfo/DlgSetBirthday")
end

function DlgSetBirthday:Purge()
	DlgSetBirthday.base.Purge(self)
	self:OnLeave()
end

function DlgSetBirthday:OnLeave()
	if self.MonthUIScrollTest then
		self.MonthUIScrollTest = nil
	end

	if self.DayUIScrollTest then
		self.DayUIScrollTest = nil
	end
end

function DlgSetBirthday:OnRegisterEvent()
	self:AddClick(self.ButtonSet, self.OnClickBtnSet)
	self:AddClick(self.ButtonConfirm, self.OnClickBtnConfirm)
	self:AddClick(self.ButtonCancel, self.OnClickBtnCancel, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonQuit, self.OnClickBtnQuit)
end

function DlgSetBirthday:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonSet, self.OnClickBtnSet)
	self:RemoveClick(self.ButtonConfirm, self.OnClickBtnConfirm)
	self:RemoveClick(self.ButtonCancel, self.OnClickBtnCancel)
	self:RemoveClick(self.ButtonQuit, self.OnClickBtnQuit)
end

function DlgSetBirthday:OnEnter(vParam)
	self:DealWithLocalization()

	self.ButtonSet = self:GetChildGameObject("Panel/ButtonSet")
	self.ButtonConfirm = self:GetChildGameObject("Panel/ButtonConfirm")
	self.ButtonCancel = self:GetChildGameObject("Panel/ButtonCancel")
	self.ButtonQuit = self:GetChildGameObject("Panel/ButtonQuit")
	self.ImgBtnSet = GOUtil.GetComponent(self.ButtonSet, "Image")
	self.GoPanelDate = self:GetChildGameObject("Panel/Date")
	self.GoPanelPrompt = self:GetChildGameObject("Panel/Prompt")
	self.GoItem = self:GetChildGameObject("Panel/Date/Item")
	self.GoMonthScroll = self:GetChildGameObject("Panel/Date/Month/Scroll")
	self.GoMonthContent = self:GetChildGameObject("Panel/Date/Month/Scroll/Content")
	self.ComMonthRaycast = GOUtil.GetComponent(self.GoMonthScroll, "UIEmpty4Raycast")
	self.GoDayScroll = self:GetChildGameObject("Panel/Date/Day/Scroll")
	self.GoDayContent = self:GetChildGameObject("Panel/Date/Day/Scroll/Content")
	self.ComDayRaycast = GOUtil.GetComponent(self.GoDayScroll, "UIEmpty4Raycast")
	self.birthday = 101

	self:InitMonth()
	self:InitDay()
	self:UpdatePanel(true)
end

function DlgSetBirthday:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Title/Text", "Text")
	txt.text = _("Desc_Set_Birthday")
	txt = self:GetChildComponent("Panel/ButtonSet/Text", "Text")
	txt.text = Lang(42627)
	txt = self:GetChildComponent("Panel/ButtonConfirm/Text", "Text")
	txt.text = Lang(12266)
	txt = self:GetChildComponent("Panel/ButtonCancel/Text", "Text")
	txt.text = Lang(12153)
end

function DlgSetBirthday:InitMonth()
	self.MonthUIScrollTest = GOUtil.AddMissingComponent(self.GoMonthScroll, "UIScrollTest")
	self.MonthUIScrollTest.content = self.GoMonthContent.transform
	self.MonthUIScrollTest.prefab = self.GoItem.transform
	self.MonthUIScrollTest.numItems = 12
	self.MonthUIScrollTest.itemSize = Vector2.New(120, 50)
	self.MonthUIScrollTest.space = Vector2.New(0, 0)
	self.MonthUIScrollTest.autoAttach = true
	self.MonthUIScrollTest.loop = true

	local function cb(isMoving)
		self:DelegateDayState(isMoving)
	end

	self.MonthUIScrollTest.onScrollChange:AddListener(cb)

	local function wrap_cb(month)
		if self.DayUIScrollTest then
			self.DayUIScrollTest.numItems = self:ResfreshDay(month)

			self.DayUIScrollTest:ResetList()
		end
	end

	self.MonthUIScrollTest.onChanged = wrap_cb
end

function DlgSetBirthday:InitDay()
	self.DayUIScrollTest = GOUtil.AddMissingComponent(self.GoDayScroll, "UIScrollTest")
	self.DayUIScrollTest.content = self.GoDayContent.transform
	self.DayUIScrollTest.prefab = self.GoItem.transform
	self.DayUIScrollTest.numItems = self:ResfreshDay(1)
	self.DayUIScrollTest.autoAttach = true
	self.DayUIScrollTest.itemSize = Vector2.New(120, 50)
	self.DayUIScrollTest.space = Vector2.New(0, 0)
	self.DayUIScrollTest.loop = true

	local function cb(isMoving)
		self:DelegateMonthState(isMoving)
	end

	self.DayUIScrollTest.onScrollChange:AddListener(cb)
end

function DlgSetBirthday:ResfreshDay(month)
	local tab1 = {
		1,
		3,
		5,
		7,
		8,
		10,
		12
	}
	local tab2 = {
		4,
		6,
		9,
		11
	}
	local tab3 = {
		2
	}
	local day = 0

	day = table.contains(tab1, month) and 31 or table.contains(tab2, month) and 30 or 29

	return day
end

function DlgSetBirthday:DelegateMonthState(isDayMove)
	if self.MonthUIScrollTest then
		self.MonthUIScrollTest:SetItemsState(isDayMove)

		self.ComMonthRaycast.enabled = not isDayMove
	end

	self.ImgBtnSet.raycastTarget = not isDayMove

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnSet, isDayMove and 1 or 0))
end

function DlgSetBirthday:DelegateDayState(isMonthMove)
	if self.DayUIScrollTest then
		self.DayUIScrollTest:SetItemsState(isMonthMove)

		self.ComDayRaycast.enabled = not isMonthMove
	end

	self.ImgBtnSet.raycastTarget = not isMonthMove

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnSet, isMonthMove and 1 or 0))
end

function DlgSetBirthday:UpdatePanel(showDate)
	GOUtil.SetActive(self.ButtonConfirm, not showDate)
	GOUtil.SetActive(self.ButtonCancel, not showDate)
	GOUtil.SetActive(self.ButtonSet, showDate)
	GOUtil.SetActive(self.GoPanelDate, showDate)
	GOUtil.SetActive(self.GoPanelPrompt, not showDate)
end

function DlgSetBirthday:OnClickBtnSet()
	local month = self.MonthUIScrollTest:GetSelectIdx()
	local day = self.DayUIScrollTest:GetSelectIdx()

	self.birthday = month * 100 + day

	self:UpdatePanel(false)
end

function DlgSetBirthday:OnClickBtnCancel()
	self:UpdatePanel(true)
end

function DlgSetBirthday:OnClickBtnConfirm()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			UIMgr.ShowMsg(_("Msg_Sucess_Set"))
			Event.Instance:Fire(EventEnum.UpdatePlayerInfo, ePlayerInfoType.birthday)
			OperationActiveMgr:SetPlayerBirthdayState(time, 1)
			self:Close()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestModifyPlayerInfo({
		birthday = self.birthday
	}, wrap_cb)
end

function DlgSetBirthday:OnClickBtnQuit()
	self:Close()
end
