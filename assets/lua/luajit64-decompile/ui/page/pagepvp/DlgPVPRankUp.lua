-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/DlgPVPRankUp.lua

local InfoPVPData = require("Info/InfoPVP")

DlgPVPRankUp = class("DlgPVPRankUp", UIPanel)

function DlgPVPRankUp:ctor()
	self.UIPrefabPath = "UI/PanelPVP/DlgPVPRankUp"
end

function DlgPVPRankUp:PreLoad()
	return
end

function DlgPVPRankUp:Purge()
	DlgPVPRankUp.base.Purge(self)
end

function DlgPVPRankUp:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnClickedButtonQuit)
end

function DlgPVPRankUp:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnClickedButtonQuit)
end

function DlgPVPRankUp:OnEnter(vParam)
	self.ButtonQuit = self:GetChildGameObject("BG")
	self.BeforeIcon = self:GetChildComponent("Rank/BeforeIcon", "Image")
	self.CurIcon = self:GetChildComponent("Rank/CurIcon", "Image")
	self.callback = vParam.callback

	UIUtil.SetImageSprite(self.BeforeIcon, string.gsub(InfoPVPData:GetIconNamebyscore(InfoPVPData.befScore), "_s", ""), false)
	UIUtil.SetImageSprite(self.CurIcon, string.gsub(InfoPVPData:GetIconNamebyscore(InfoPVPData.curScore), "_s", ""), false)

	InfoPVPData.befScore = InfoPVPData.curScore
end

function DlgPVPRankUp:OnClickedButtonQuit()
	self:Purge()

	if self.callback then
		self.callback()
	end
end
