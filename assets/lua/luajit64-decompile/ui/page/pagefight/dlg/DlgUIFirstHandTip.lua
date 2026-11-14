-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIFirstHandTip.lua

DlgUIFirstHandTip = class("DlgUIFirstHandTip", UIPanel_sync)

function DlgUIFirstHandTip:ctor()
	DlgUIFirstHandTip.base.ctor(self, "UI/PageFight/Dlg/DlgUIFirstHandTip")
end

function DlgUIFirstHandTip:Cache()
	DlgUIFirstHandTip.base.Cache(self)
end

function DlgUIFirstHandTip:Close()
	DlgUIFirstHandTip.base.Close(self)
end

function DlgUIFirstHandTip:Purge()
	DlgUIFirstHandTip.base.Purge(self)
end

function DlgUIFirstHandTip:OnEnter()
	self:Show(false)
end

function DlgUIFirstHandTip:Open(camp)
	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		return
	end

	self.obj_camp1 = self:GetChildGameObject("panel/img_camp1")
	self.obj_camp2 = self:GetChildGameObject("panel/img_camp2")

	GOUtil.SetActive(self.obj_camp1, camp == 1)
	GOUtil.SetActive(self.obj_camp2, camp == 2)
	self:Show(true)
end

function DlgUIFirstHandTip:Hide()
	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		return
	end

	self:Show(false)
end

function DlgUIFirstHandTip:OnRegisterEvent()
	return
end

function DlgUIFirstHandTip:OnUnRegisterEvent()
	return
end
