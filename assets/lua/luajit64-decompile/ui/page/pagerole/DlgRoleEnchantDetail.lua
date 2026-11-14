-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/DlgRoleEnchantDetail.lua

DlgRoleEnchantDetail = class("DlgRoleEnchantDetail", UIPanel)

function DlgRoleEnchantDetail:ctor()
	self.UIPrefabPath = "UI/PanelRole/DlgRoleEnchantDetail"
end

function DlgRoleEnchantDetail:Purge()
	self.base.Purge(self)
end

function DlgRoleEnchantDetail:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedClose)
end

function DlgRoleEnchantDetail:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedClose)
end

function DlgRoleEnchantDetail:OnEnter(vParam)
	self:DealWithLocalization()

	self.TxtNone = self:GetChildComponent("Panel/Text", "Text")
	self.TxtNone.text = _("Desc_Equip_Enchant_None")
	self.BtnClose = self:GetChildGameObject("Panel/Button")

	self:Init(vParam)
end

function DlgRoleEnchantDetail:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/Title/Text", "Text")

	txt.text = _("Desc_Equip_Enchant_View")
end

function DlgRoleEnchantDetail:Init(role)
	if role == nil or not role.hold then
		return
	end

	local t = {}

	for i = 1, EquipmentManager.EquipSlotCnt do
		local slot = role:GetEquipSlot(i)

		if role:IsEquipSlotUnlocked(i) and #slot.attributes ~= 0 then
			table.insert(t, {
				i,
				slot
			})
		end
	end

	for i = 1, EquipmentManager.EquipSlotCnt do
		local go = self:GetChildGameObject("Panel/ScrollArea/Content/" .. i)

		if t[i] then
			local slot = t[i][2]
			local equip = EquipmentManager:GetEquip(role:GetEquipId(t[i][1]))
			local icon = GOUtil.FindChildComponent(go, "Equip/Icon", "Image")
			local path = EquipmentManager:GetEquipSlotIconAndName(role, equip, slot.quality, slot.grade)

			SetImageSprite(icon, path, self)

			for j = 1, EquipmentManager.EquipEnchantCnt do
				local go2 = GOUtil.FindChildGameObject(go, "Attr/" .. j)

				if j <= #slot.attributes then
					local rankIcon = GOUtil.FindChildComponent(go2, "Rank", "Image")
					local a, rank = EquipmentManager.GetEnchantRank(t[i][1], slot.scroll, slot.attributes[j])

					SetImageSprite(rankIcon, "UI/PanelRole/AtlasPanelRole/ic_itemup_word_0" .. rank, self)

					local txtName = GOUtil.FindChildComponent(go2, "TxtName", "Text")

					txtName.text = _("eAttType_" .. slot.attributes[j].type)

					local txtValue = GOUtil.FindChildComponent(go2, "TxtValue", "Text")

					txtValue.text = "+" .. TenaryOp(slot.attributes[j].param == 1, slot.attributes[j].value, slot.attributes[j].value / 10 .. "%")
				else
					go2:SetActive(false)
				end
			end
		else
			go:SetActive(false)
		end
	end

	GOUtil.SetActive(self.TxtNone, #t == 0)
end

function DlgRoleEnchantDetail:OnClickedClose()
	self:Close()
end
