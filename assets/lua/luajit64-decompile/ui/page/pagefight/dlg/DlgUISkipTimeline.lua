-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUISkipTimeline.lua

DlgUISkipTimeline = class("DlgUISkipTimeline", UIPanel_sync)

function DlgUISkipTimeline:ctor()
	DlgUISkipTimeline.base.ctor(self, "UI/PageFight/Dlg/DlgUISkipTimeline")

	self.CellAutoBtn = CellAutoBtn()

	self:AddChildPanel(self.CellAutoBtn)
end

function DlgUISkipTimeline:Cache()
	DlgUISkipTimeline.base.Cache(self)
end

function DlgUISkipTimeline:Close()
	DlgUISkipTimeline.base.Close(self)
end

function DlgUISkipTimeline:Purge()
	DlgUISkipTimeline.base.Purge(self)
	UIMgr:RemoveSafeArea(self)
end

function DlgUISkipTimeline:OnEnter(vParam)
	UIMgr:SetSafeArea(self, self.UIRootObject)

	self.ani_panel = self:GetChildComponent("panel", "Animator")
	self.btn_skip = self:GetChildGameObject("panel/top/btn_skip")
	self.btn_showSkip = self:GetChildGameObject("panel")
	self.obj_autoBtnRoot = self:GetChildGameObject("panel/top/obj_autoBtnRoot")
	self.curTimeline = nil

	self.CellAutoBtn:SetParent(self.obj_autoBtnRoot)
	GOUtil.SetActive(self.btn_skip, false)
	self:Show(false)
end

function DlgUISkipTimeline:Open(timeline)
	self.curTimeline = timeline

	GOUtil.SetActive(self.btn_skip, false)
	GOUtil.SetActive(self.obj_autoBtnRoot, false)
	self:Show(true)
end

function DlgUISkipTimeline:Hide()
	self.curTimeline = nil

	self:Show(false)
end

function DlgUISkipTimeline:PlayOpen()
	self.ani_panel:Play("PageBattle_panel_close", 0, 1)
	self.ani_panel:Play("PageBattle_panel", 0, 0)
end

function DlgUISkipTimeline:OnRegisterEvent()
	self:AddClick(self.btn_skip, self.OnBtnSkip)
	self:AddClick(self.btn_showSkip, self.OnBtnShowSkip)
	Event.Instance:Add("SKIP_TIME_LINE", self.OnBtnSkip, self)
end

function DlgUISkipTimeline:OnUnRegisterEvent()
	self:RemoveClick(self.btn_skip, self.OnBtnSkip)
	self:RemoveClick(self.btn_showSkip, self.OnBtnShowSkip)
	Event.Instance:Remove("SKIP_TIME_LINE", self.OnBtnSkip, self)
end

function DlgUISkipTimeline:OnBtnSkip()
	if InstructionMgr.isSkipTimeLine == 1 then
		return
	end

	if self.curTimeline then
		Event.Instance:Fire("eventSkipTimeLine", self.curTimeline.TimelineId)
		self.curTimeline:Skip()
	end
end

function DlgUISkipTimeline:OnBtnShowSkip()
	if GOUtil.IsActiveSelf(self.btn_skip) == false then
		self:PlayOpen()
		GOUtil.SetActive(self.btn_skip, true)
		GOUtil.SetActive(self.obj_autoBtnRoot, true)
	end
end
