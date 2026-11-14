-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgPayLaw.lua

DlgPayLaw = class("DlgPayLaw", UIPanel)

function DlgPayLaw:ctor()
	self.UIPrefabPath = "UI/Public/DlgPayLaw"
end

function DlgPayLaw:OnRegisterEvent()
	self:AddClick(self.LinkBtn, self.OnClickLink, PATH_SFX_UI_CANCEL)
end

function DlgPayLaw:OnUnRegisterEvent()
	self:RemoveClick(self.LinkBtn, self.OnClickLink)
end

function DlgPayLaw:OnAsyncPrecacheAllFinish()
	local tweenRoot = GOUtil.FindChildGameObject(self.uiRoot, "TweenRoot")

	self.uiRoot = tweenRoot or self.uiRoot

	DlgPayLaw.base.OnAsyncPrecacheAllFinish(self)
end

function DlgPayLaw:OnEnter(vParam)
	local g = self.UIRootObject

	self.LinkBtn = GOUtil.FindChildGameObject(g, "button")

	self.UIRootObject:SetActive(false)
end

function DlgPayLaw:Show(x, y, parent)
	if parent then
		self.UIRootObject.transform:SetParent(parent.transform, true)
	end

	GOUtil.SetTransformLocalPosition(self.UIRootObject, x, y, 0)
	self.UIRootObject:SetActive(true)
end

function DlgPayLaw:UpdatePos(x, y)
	GOUtil.SetTransformLocalPosition(self.UIRootObject, x, y, 0)
end

function DlgPayLaw:OnClickLink()
	UIMgr.AddPanel(PagePayRule(), {
		showOrder = 1002,
		mode = 2,
		curIndex = 3
	})
end
