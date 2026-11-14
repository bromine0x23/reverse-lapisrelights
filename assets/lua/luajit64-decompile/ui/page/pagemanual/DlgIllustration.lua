-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/DlgIllustration.lua

DlgIllustration = class("DlgIllustration", UIPanel)

function DlgIllustration:ctor()
	self.UIPrefabPath = "UI/PageManual/DlgIllustration"
end

function DlgIllustration:PreLoad()
	return
end

function DlgIllustration:Purge()
	DlgIllustration.base.Purge(self)
end

function DlgIllustration:OnRegisterEvent()
	self:AddClick(self.Illustration, self.Close)
end

function DlgIllustration:OnUnRegisterEvent()
	self:RemoveClick(self.Illustration, self.Close)
end

function DlgIllustration:OnEnter(vParam)
	self.Illustration = self:GetChildGameObject("Illustration")
	self.IllRawImage = self:GetChildComponent("Illustration/RawImage", "RawImage")

	self:UpdateData(vParam)
end

function DlgIllustration:UpdateData(vParam)
	local data = vParam.data

	UIUtil.SetRawImageTexture(self.IllRawImage, data.ImagePath, self)
	self.Illustration:SetActive(true)
end
