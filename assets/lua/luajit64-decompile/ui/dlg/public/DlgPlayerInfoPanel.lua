-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgPlayerInfoPanel.lua

require("UI/Page/PagePlayerInfo/PagePlayer")

DlgPlayerInfoPanel = class("DlgPlayerInfoPanel", UIPanel)

function DlgPlayerInfoPanel:ctor()
	self.UIPrefabPath = "UI/PanelMainStage/DlgPlayerInfoPanel"
	self.isSyncLoad = true
end

function DlgPlayerInfoPanel:Cache()
	self.base.Cache(self)
end

function DlgPlayerInfoPanel:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
end

function DlgPlayerInfoPanel:OnLeave()
	self.ExpBar = nil
	self.TxtLevel = nil
end

function DlgPlayerInfoPanel:OnEnter(vParam)
	self:SetSafeArea(self.UIRootObject)

	local textLevel = self:GetChildComponent("BgBoard/BgLevel/Text", "Text")

	textLevel.text = "Lv."
	textLevel.fontSize = 22
	self.GoBgBoard = self:GetChildGameObject("BgBoard")
	self.ExpBar = self:GetChildComponent("BgBoard/ExpBar/ImgExp", "Image")
	self.TxtLevel = self:GetChildComponent("BgBoard/BgLevel/TxtLevel", "Text")
	self.TextExp = self:GetChildComponent("BgBoard/ExpBar/TxtExp", "Text")

	local TxtName = self:GetChildComponent("BgBoard/TxtName", "Text")

	TxtName.text = PlayerInst.InfoPlayer.name

	local headIcon = self:GetChildComponent("BgBoard/Head", "Image")
	local infoItem = ItemManager:Get(PlayerInst.InfoPlayer.headId)

	UIUtil.SetImageSprite(headIcon, infoItem:GetIcon(), self)

	local headFrameIcon = self:GetChildComponent("BgBoard/Head/Frame", "Image")

	infoItem = ItemManager:Get(PlayerInst.InfoPlayer.headFrame)

	UIUtil.SetImageSprite(headFrameIcon, infoItem:GetIcon(), self)
	self:NotifyUpdate()
end

function DlgPlayerInfoPanel:NotifyUpdate()
	self.TxtLevel.text = PlayerInst:GetCurLv()
	self.ExpBar.fillAmount = PlayerInst.InfoPlayer.curExp / PlayerInst.InfoPlayer.nextExp
	self.TextExp.text = PlayerInst.InfoPlayer.curExp .. "/" .. PlayerInst.InfoPlayer.nextExp
end

function DlgPlayerInfoPanel:OnRegisterEvent()
	self:AddClick(self.GoBgBoard, self.OnClickedPlayerInfo)
	Event.Instance:Add(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
end

function DlgPlayerInfoPanel:OnUnRegisterEvent()
	self:AddClick(self.GoBgBoard, self.OnClickedPlayerInfo)
	Event.Instance:Remove(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
end

function DlgPlayerInfoPanel:OnClickedPlayerInfo()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Player)

	if not isOpen then
		return
	end

	UIMgr.SwitchPanel(PagePlayer)
end
