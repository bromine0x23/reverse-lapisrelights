-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageStory/DlgStoryDialog.lua

DlgStoryDialog = class("DlgStoryDialog", UIPanel)

function DlgStoryDialog:ctor()
	DlgStoryDialog.base.ctor(self, "UI/PageStory/DlgStoryDialog")
end

function DlgStoryDialog:Purge()
	DlgStoryDialog.base.Purge(self)
end

function DlgStoryDialog:OnEnter(vParam)
	self.PanelNext = self:GetChildGameObject("Panel")
	self.TxtContent = self:GetChildComponent("Panel/TxtGroup/TxtContent", "Text")
	self.Typewriter = self:GetChildComponent("Panel/TxtGroup/TxtContent", "UITypewriter")
	self.ImgName = {}
	self.ImgName.L = self:GetChildComponent("Panel/ImgNameL", "Image")
	self.ImgName.R = self:GetChildComponent("Panel/ImgNameR", "Image")
	self.TxtName = {}
	self.TxtName.L = self:GetChildComponent("Panel/ImgNameL/TxtName", "Text")
	self.TxtName.R = self:GetChildComponent("Panel/ImgNameR/TxtName", "Text")
end

function DlgStoryDialog:OnLeave()
	self.TxtContent = nil
	self.PanelNext = nil
	self.Typewriter = nil
	self.ImgName = nil
end

function DlgStoryDialog:Close()
	self:Purge()
end

function DlgStoryDialog:IsShow()
	return self.UIRootObject ~= nil
end

function DlgStoryDialog:OnRegisterEvent()
	self:AddClick(self.PanelNext, self.OnPanelNext)
end

function DlgStoryDialog:OnUnRegisterEvent()
	self:RemoveClick(self.PanelNext, self.OnPanelNext)
end

function DlgStoryDialog:OnPanelNext()
	Event.Instance:Fire("OnStoryFlowNext")
end

function DlgStoryDialog:SetContent(content)
	UIUtil.SetTextString(self.TxtContent, content)
end

function DlgStoryDialog:PlayContent(content, speed)
	self.Typewriter:Play(content, speed)
end

function DlgStoryDialog:SetName(name, side)
	if side == "L" then
		local NameLGameObject = self.ImgName.L.gameObject

		if not GOUtil.IsActive(NameLGameObject) then
			GOUtil.SetActive(NameLGameObject, true)
		end

		local NameRGameObject = self.ImgName.R.gameObject

		if GOUtil.IsActive(NameRGameObject) then
			GOUtil.SetActive(NameRGameObject, false)
		end

		UIUtil.SetTextString(self.TxtName.L, name)
	elseif side == "R" then
		local NameRGameObject = self.ImgName.R.gameObject

		if not GOUtil.IsActive(NameRGameObject) then
			GOUtil.SetActive(NameRGameObject, true)
		end

		local NameLGameObject = self.ImgName.L.gameObject

		if GOUtil.IsActive(NameLGameObject) then
			GOUtil.SetActive(NameLGameObject, false)
		end

		UIUtil.SetTextString(self.TxtName.R, name)
	end
end
