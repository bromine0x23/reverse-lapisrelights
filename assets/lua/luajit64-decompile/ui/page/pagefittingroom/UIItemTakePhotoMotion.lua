-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/UIItemTakePhotoMotion.lua

require("UI/Item/UIItemBase")

UIItemTakePhotoMotion = class("UIItemTakePhotoMotion", UIItemBase)

function UIItemTakePhotoMotion:ctor(itemPrefabCache, parent, ownerUI)
	return
end

function UIItemTakePhotoMotion:OnEnter()
	self.Img_Icon = GOUtil.FindChildComponent(self.UIRootObject, "Img_Icon", "Image")
	self.Img_LockBk = GOUtil.FindChildGameObject(self.UIRootObject, "Img_LockBk")
	self.Txt_LockDesc = GOUtil.FindChildComponent(self.UIRootObject, "Img_LockBk/Txt_LockDesc", "Text")
	self.Txt_Name = GOUtil.FindChildComponent(self.UIRootObject, "Txt_Name", "Text")
end

function UIItemTakePhotoMotion:OnLeave()
	self.Img_Icon = nil
	self.Img_LockBk = nil
	self.Txt_LockDesc = nil
	self.Txt_Name = nil
end

function UIItemTakePhotoMotion:OnRegisterEvent()
	return
end

function UIItemTakePhotoMotion:OnUnRegisterEvent()
	return
end

function UIItemTakePhotoMotion:SetItem(strIcon, lockState, strDesc, strName)
	local unLock = lockState == MotionLockState.UnLock

	UIUtility.SetSprite(self.Img_Icon, strIcon, false)
	UIUtility.SetVisible(self.Img_LockBk, not unLock)
	UIUtility.SetComponentVisible(self.Txt_LockDesc, lockState == MotionLockState.FavorRankUnFit)
	UIUtility.SetComponentVisible(self.Txt_Name, unLock)

	if lockState == MotionLockState.FavorRankUnFit then
		UIUtility.SetText(self.Txt_LockDesc, strDesc)
	end

	if unLock then
		UIUtility.SetText(self.Txt_Name, strName)
	end
end

function UIItemTakePhotoMotion:SetName(strName)
	UIUtility.SetComponentVisible(self.Txt_Name, true)
	UIUtility.SetText(self.Txt_Name, strName)
end

function UIItemTakePhotoMotion:SetLockBkVisible(bVisible)
	UIUtility.SetVisible(self.Img_LockBk, bVisible)
end
