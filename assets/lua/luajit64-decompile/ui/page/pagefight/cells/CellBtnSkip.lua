-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellBtnSkip.lua

local autoBtnImgPath = {
	"UI/PageFight/AtlasBattleSetting/BTN_ani_off",
	"UI/PageFight/AtlasBattleSetting/BTN_ani_on"
}

CellBtnSkip = class("CellBtnSkip", UIPanel_sync)

function CellBtnSkip:ctor(isOperatorCard)
	CellBtnSkip.base.ctor(self, "UI/PageFight/Cells/CellBtnSkip")
end

function CellBtnSkip:Cache()
	CellBtnSkip.base.Cache(self)

	for i, path in ipairs(autoBtnImgPath) do
		ResourceMgr.SubmitCache(path, self, "autoBtnImg_" .. i, Sprite)
	end
end

function CellBtnSkip:SetParent(root)
	GOUtil.AttachGameObject(self.UIRootObject, root, true)
end

function CellBtnSkip:OnEnter(vParam)
	self.img = self:GetChildComponent("panel/btn", "Image")
	self.btn = self.img.gameObject

	self:SetBtnImg(GP.SkipTimelineMode)

	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.SkipTimelineBtn)
	local gray = TenaryOp(isOpen, 0, 1)

	UIUtil.SetImageGray(self.img, gray)
end

function CellBtnSkip:Close()
	for i, path in ipairs(autoBtnImgPath) do
		self["autoBtnImg_" .. i] = nil
	end
end

function CellBtnSkip:OnRegisterEvent()
	CellBtnSkip.base.OnRegisterEvent(self)
	self:AddClick(self.btn, self.OnBtnClick)
	Event.Instance:Add("SwitchSkipMode", self.SetBtnImg, self)
end

function CellBtnSkip:OnUnRegisterEvent()
	CellBtnSkip.base.OnUnRegisterEvent(self)
	self:RemoveClick(self.btn, self.OnBtnClick)
	Event.Instance:Remove("SwitchSkipMode", self.SetBtnImg, self)
end

function CellBtnSkip:SetBtnImg(val)
	local idx = TenaryOp(val == false, 2, 1)
	local iconPath = self["autoBtnImg_" .. idx]

	if iconPath then
		GP.SpriteUtil:SetSprite(self.img, iconPath)
	end
end

function CellBtnSkip:OnBtnClick()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.SkipTimelineBtn) then
		return
	end

	local val = GP:SetSkilTimeLineMode()

	self:SetBtnImg(val)

	local idx = TenaryOp(val == false, 2, 1)
	local arr = {
		_("TipSkipOff"),
		_("TipSkipOn")
	}

	UIMgr.ShowMsg(arr[idx])
end
