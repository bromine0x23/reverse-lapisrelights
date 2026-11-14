-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/UIGreenDot.lua

UIGreenDot = class("UIGreenDot")

function UIGreenDot:ctor()
	return
end

function UIGreenDot:Cache()
	MxResMgr.Instance:SubmitCacheLua("UI/Common/ImgGreenDot", self, "PrefabImgGreenDot")
end

function UIGreenDot:Create(parentGo, posOffset)
	local go = GOUtil.InstantiatePrefab(self.PrefabImgGreenDot, parentGo)

	if posOffset ~= nil then
		UIUtility.SetGameObjRTPos(go, posOffset.x, posOffset.y)
	end

	return go
end

function UIGreenDot:Purge()
	self.PrefabImgGreenDot = nil
end

UIGreenDot.Instance = UIGreenDot.Instance or UIGreenDot()
