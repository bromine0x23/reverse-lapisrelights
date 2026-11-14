-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/DlgPreviewWeapon.lua

DlgPreviewWeapon = class("DlgPreviewWeapon")

function DlgPreviewWeapon:ctor()
	return
end

function DlgPreviewWeapon:Init(renderCtrl)
	self.UI3DActorRotate = UI3DActorRotate()

	self.UI3DActorRotate:Init(renderCtrl.gameObject)

	self.WeaponPos = GOUtil.NewGameObject("WeaponPos", nil)
	self.UI3DActorRotate.actor = self.WeaponPos
	self.renderCtrl = renderCtrl
end

function DlgPreviewWeapon:Purge()
	self:ClearAssetRef()

	if not IsNil(self.WeaponPos) then
		GOUtil.DestroyAllChildren(self.WeaponPos)
		self.WeaponPos:Destroy()

		self.WeaponPos = nil
	end
end

function DlgPreviewWeapon:Exit()
	if not IsNil(self.WeaponPos) then
		GOUtil.DestroyAllChildren(self.WeaponPos)
	end

	self:ClearAssetRef()
end

function DlgPreviewWeapon:ClearAssetRef()
	if self.PrefabWeaponRef then
		ResourceMgr.Unload(self.PrefabWeaponRef)

		self.PrefabWeaponRef = nil
	end

	if self.AnimAssetRef then
		ResourceMgr.Unload(self.AnimAssetRef)

		self.AnimAssetRef = nil
	end
end

function DlgPreviewWeapon:OnRegisterEvent()
	return
end

function DlgPreviewWeapon:OnUnRegisterEvent()
	return
end

function DlgPreviewWeapon:EquipAvatar(id)
	local info = AvatarManager:GetAvatar(id)

	if not IsNil(self.WeaponPos) then
		local WeaponSit = info.data.WeaponSit

		GOUtil.SetTransformLocalPosition(self.WeaponPos, WeaponSit[1], WeaponSit[2], WeaponSit[3])
		GOUtil.SetTransformRotation(self.WeaponPos, WeaponSit[4], WeaponSit[5], WeaponSit[6])
	end

	self.renderCtrl:SetCameraPosition(10.5, 0.83, -2.632)
	ResourceMgr.BeginSubmit(function()
		if self.PrefabWeaponRef then
			local gw = GOUtil.InstantiatePrefabByCenter(self.PrefabWeaponRef, self.WeaponPos)
			local animtor = GOUtil.AddMissingComponent(gw, "Animator")

			self.AnimAssetRef = UIUtil.SetAnimatorController(info.data.WeaponAnimController, animtor)

			GOUtil.SetGameObjectLayer(gw, LayerMask.NameToLayer("RT"))
			GOUtil.SetTransformLocalPosition(gw, 0, 0, 0)
		end
	end)
	ResourceMgr.SubmitCache(info.data.AvatarPath, self, "PrefabWeaponRef", GameObject)
	ResourceMgr.EndSubmit()
end
