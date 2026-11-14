-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgPlayerLevelup.lua

require("UI/Dlg/DlgBase")
require("UI/Dlg/Common/DlgPlayerLevelupResult")

DlgPlayerLevelup = class("DlgPlayerLevelup", DlgBase)

function DlgPlayerLevelup:ctor()
	self.DlgPlayerLevelupResult = DlgPlayerLevelupResult()
	InLevelup = true
end

function DlgPlayerLevelup:Init(parent, vParam, onComplete)
	self.DlgPrefabPath = "UI/Common/DlgAniLevelup"

	self:SetParent(parent, true)
	self:Create(vParam)

	self.OnComplete = onComplete
end

function DlgPlayerLevelup:Cache()
	return
end

function DlgPlayerLevelup:OnEnter(vParam)
	InstructionMgr:HideMask()
	MxUtil.ChangeParent(self.UIRootObject, MxUIMgr.Instance.CommonTipRoot)

	self.vParam = vParam
	self.ImageLight = GOUtil.FindChildComponent(self.UIRootObject, "ImageLight", "Image")
	self.Image = GOUtil.FindChildComponent(self.UIRootObject, "Image", "Image")

	UIUtility.SetTransScale(self.Image.transform, Vector3.New(2, 2, 2))
	UIUtility.SetComponentVisible(self.Image, true)

	local tweener = DG.Tweening.ShortcutExtensions.DOScale(self.Image.transform, 1, 0.3)

	UIUtility.SetTweenerCallback(tweener, function(...)
		UIUtility.SetComponentVisible(self.ImageLight, true)

		local tween = DG.Tweening.ShortcutExtensions.DORotate(self.ImageLight.transform, Vector3(0, 0, 360), 2, DG.Tweening.RotateMode.FastBeyond360)

		UIUtility.SetRepeatLinearLoop(tween)
	end)
end

function DlgPlayerLevelup:OnLeave()
	return
end

function DlgPlayerLevelup:OnRegisterEventForInstruction()
	self:OnRegisterEvent()
end

function DlgPlayerLevelup:OnRegisterEvent()
	self:AutoRegistClick(self.UIRootObject, self.OnNext)
end

function DlgPlayerLevelup:OnUnRegisterEvent()
	return
end

function DlgPlayerLevelup:OnNext(...)
	self:Close()

	if self.vParam ~= nil then
		CreateDlgInScene(self.DlgPlayerLevelupResult, self.vParam)

		if self.DlgPlayerLevelupResult ~= nil then
			self.DlgPlayerLevelupResult.OnDlgClose[self] = self.HandleComplte
		end
	else
		self:HandleComplte()
	end
end

function DlgPlayerLevelup:HandleComplte()
	if self.OnComplete == nil then
		return
	end

	self.OnComplete()

	self.OnComplete = nil
end

function DlgPlayerLevelup.GetInstance()
	DlgPlayerLevelup.Instance = DlgPlayerLevelup.Instance or DlgPlayerLevelup()

	return DlgPlayerLevelup.Instance
end
