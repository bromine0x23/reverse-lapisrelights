-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/DlgNewStory.lua

DlgNewStory = class("DlgNewStory", UIPanel)

function DlgNewStory:ctor()
	self.UIPrefabPath = "UI/PanelActivity/DlgNewStory"
end

function DlgNewStory:PreLoad()
	return
end

function DlgNewStory:Purge()
	DlgNewStory.base.Purge(self)
	self:OnLeave()
end

function DlgNewStory:OnLeave()
	return
end

function DlgNewStory:OnRegisterEvent()
	self:AddClick(self.CloseBtn, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
	self:AddClick(self.GoTo, self.OnClickedBtnEnter)
end

function DlgNewStory:OnUnRegisterEvent()
	self:RemoveClick(self.CloseBtn, self.OnClickedBtnClose)
	self:RemoveClick(self.GoTo, self.OnClickedBtnEnter)
end

function DlgNewStory:OnEnter(vParam)
	self:DealWithLocalization()

	self.GoTo = self:GetChildGameObject("Panel/GoTo")
	self.CloseBtn = self:GetChildGameObject("Panel/Close")

	local list = ActiveCardPoolMgr:GetAll(vParam.id)
	local info = list[#list - 1]
	local infoRole

	if info.listItem[2][1].data.Type == "I_SOUL" then
		infoRole = RoleCardMgr:GetRole(info.listItem[2][1].data.Value)
	else
		infoRole = RoleCardMgr:GetRole(info.listItem[2][1]:GetNum())
	end

	self.Name = self:GetChildComponent("Panel/Name", "Text")
	self.RoleImage = self:GetChildComponent("Panel/RoleImage", "Image")

	local listStage = ActiveMgr.NewOpenStory
	local stageInfo = ChapterMgr:GetStage(tonumber(listStage[#listStage]))

	self.Name.text = Lang(stageInfo.data.Name)

	UIUtil.SetImageSprite(self.RoleImage, infoRole.data.UnlockPic[1], self)

	ActiveMgr.NewOpenStory = nil
end

function DlgNewStory:DealWithLocalization()
	return
end

function DlgNewStory:OnClickedBtnClose()
	self:Close()
end

function DlgNewStory:OnClickedBtnEnter()
	Event.Instance:Fire("OpenActiveStory")
	self:Close()
end
