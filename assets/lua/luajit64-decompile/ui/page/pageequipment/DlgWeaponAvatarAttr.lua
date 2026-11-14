-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgWeaponAvatarAttr.lua

require("UI/Page/PageEquipment/CellAvatarAttr")

DlgWeaponAvatarAttr = class("DlgWeaponAvatarAttr", UIPanel)

function DlgWeaponAvatarAttr:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/DlgWeaponAvatarAttr"
end

function DlgWeaponAvatarAttr:PreLoad()
	self:LoadResAsync("UI/PanelEquipment/CellAvatarAttr", "PrefabCellAvatarAttr", GameObject)
end

function DlgWeaponAvatarAttr:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellAvatarAttr)

	if self.listCell then
		for _, cell in ipairs(self.listCell) do
			if cell.OnLeave then
				cell:OnLeave()
			end
		end

		self.listCell = nil
	end
end

function DlgWeaponAvatarAttr:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClickedButtonClose)
end

function DlgWeaponAvatarAttr:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClickedButtonClose)
end

function DlgWeaponAvatarAttr:OnEnter(vParam)
	self:DealWithLocalization()

	self.Button = self:GetChildGameObject("Panel/Button")
	self.UIScrollView = self:GetChildComponent("Panel/ScrollArea", "UIScrollView")

	self:Init(vParam)
end

function DlgWeaponAvatarAttr:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/Title/Text", "Text")

	txt.text = _("Desc_Active_View")
	txt = self:GetChildComponent("Panel/Text1", "Text")
	txt.text = _("Desc_Unlock_Weapon_Avatar")
	txt = self:GetChildComponent("Panel/Text2", "Text")
	txt.text = _("Desc_Weapon_Avatar_Att_Get")
end

function DlgWeaponAvatarAttr:Init(infoRole)
	self.listAvatar = AvatarManager:GetWeaponAvatarList(infoRole)
	self.listCell = {}

	for i = 1, #self.listAvatar do
		local avatarData = self.listAvatar[i]
		local cell = CellAvatarAttr(self.PrefabCellAvatarAttr, self.UIScrollView.content.gameObject, self)

		cell:Create()

		local isUnLock = AvatarManager:IsUnlocked(infoRole, avatarData.InfoAvatar)

		cell:UpdateData(avatarData.InfoAvatar, isUnLock)
		table.insert(self.listCell, cell)
	end
end

function DlgWeaponAvatarAttr:OnClickedButtonClose()
	self:Close()
end
