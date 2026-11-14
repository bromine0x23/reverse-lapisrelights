-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTask/PageTaskTips.lua

PageTaskTips = class("PageTaskTips", UIPanel)

function PageTaskTips:ctor()
	self.UIPrefabPath = "UI/PanelTask/PageTaskTips"
end

function PageTaskTips:PreLoad()
	return
end

function PageTaskTips:OnLeave()
	TaskManager.isShowTips = false

	self:Close()
end

function PageTaskTips:Purge()
	PageTaskTips.base.Purge(self)
	UnloadAllImageSprite(self)
end

function PageTaskTips:OnRegisterEvent()
	EventListenerMgr.AddAnimListener(self.UIRootObject, self.CheckTips, self, eAnimEventType.OnAnimationEnd)
	Event.Instance:Add("CloseTaskTips", self.OnLeave, self)
end

function PageTaskTips:OnUnRegisterEvent()
	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.CheckTips, self, eAnimEventType.OnAnimationEnd)
	Event.Instance:Remove("CloseTaskTips", self.OnLeave, self)
end

function PageTaskTips:OnEnter()
	self.img_type = self:GetChildComponent("Panel/img_type", "Image")
	self.img_progress = self:GetChildComponent("Panel/img_progress", "Image")
	self.tex_title = self:GetChildComponent("Panel/tex_title", "Text")
	self.tex_now = self:GetChildComponent("Panel/tex_now", "Text")
	self.complete = self:GetChildGameObject("Panel/img_complete")
	self.Animtor = self:GetChildComponent("", "Animator")

	self:ShowTips()
end

function PageTaskTips:CheckTips()
	self:ShowTips()
end

function PageTaskTips:ShowTips()
	self.data = nil

	for key, value in pairs(TaskManager.tipsQueue) do
		self.data = value

		break
	end

	if self.data ~= nil then
		self.Animtor:Play("PageTaskTips_show", 0, 0)

		self.tex_title.text = self.data:GetDescTitle()
		self.tex_now.text = self.data.pb.num .. "/<size=28>" .. self.data.data.ArgInt .. "</size>"

		self.complete:SetActive(self.data:IsComplete())

		if self.data:IsComplete() then
			self.tex_now.text = self.data.data.ArgInt .. "/<size=28>" .. self.data.data.ArgInt .. "</size>"
		end

		self.img_progress.fillAmount = self.data.pb.num / self.data.data.ArgInt

		if self.data.Type == eTaskListType.main then
			UIUtil.SetImageSprite(self.img_type, "UI/PanelTask/AtlasTaskTips/BG_achievements_tip_01", self)
		elseif self.data.Type == eTaskListType.daily then
			UIUtil.SetImageSprite(self.img_type, "UI/PanelTask/AtlasTaskTips/BG_achievements_tip_02", self)
		elseif self.data.Type == eTaskListType.weekly then
			UIUtil.SetImageSprite(self.img_type, "UI/PanelTask/AtlasTaskTips/BG_achievements_tip_03", self)
		elseif self.data.Type == eTaskListType.achievement then
			UIUtil.SetImageSprite(self.img_type, "UI/PanelTask/AtlasTaskTips/BG_achievements_tip_04", self)
		end

		table.removeByValue(TaskManager.tipsQueue, self.data)
	else
		self:OnLeave()
	end
end
