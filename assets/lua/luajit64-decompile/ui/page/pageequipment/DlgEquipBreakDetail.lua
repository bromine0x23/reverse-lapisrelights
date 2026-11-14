-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgEquipBreakDetail.lua

DlgEquipBreakDetail = class("DlgEquipBreakDetail", UIPanel)

function DlgEquipBreakDetail:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/DlgEquipBreakDetail"
end

function DlgEquipBreakDetail:Purge()
	DlgEquipBreakDetail.base.Purge(self)
end

function DlgEquipBreakDetail:OnRegisterEvent()
	self:AddClick(self.Bg, self.OnClickedClose)
end

function DlgEquipBreakDetail:OnUnRegisterEvent()
	self:RemoveClick(self.Bg, self.OnClickedClose)
end

function DlgEquipBreakDetail:OnEnter(vParam)
	self:DealWithLocalization()

	self.Bg = self:GetChildGameObject("Bg")

	for i = 1, 4 do
		self["TxtEquipAtt" .. i] = self:GetChildComponent("Panel/Attr/" .. i .. "/TxtAtt", "Text")
		self["TxtEquipAdd" .. i] = self:GetChildComponent("Panel/Attr/" .. i .. "/TxtAdd", "Text")
	end

	self.TxtEquipName = self:GetChildComponent("Panel/TxtName", "Text")

	self:UpdatePanel(vParam)
end

function DlgEquipBreakDetail:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/Title/Text", "Text")
	Text.text = _("Desc_BreakDetail")
	Text = self:GetChildComponent("Panel/TxtClose", "Text")
	Text.text = _("Desc_ClickClose")
end

function DlgEquipBreakDetail:UpdatePanel(data)
	local infoRole = data.infoRole
	local slotIdx = data.slotIdx
	local infoSlot = infoRole:GetEquipSlot(slotIdx)
	local equipId = infoRole:GetEquipId(slotIdx)
	local infoEquip = EquipmentManager:GetEquip(equipId)
	local listCurQua = EquipmentManager:GetQualityProp(infoRole.job, infoSlot.quality, infoSlot.grade, slotIdx)
	local nextQ, nextG = EquipmentManager:GetNextQuality(infoSlot.quality, infoSlot.grade)
	local listNextQua = EquipmentManager:GetQualityProp(infoRole.job, nextQ, nextG, slotIdx)

	for i = 1, 4 do
		self["TxtEquipAtt" .. i].text = _("eAttType_" .. i)
		self["TxtEquipAdd" .. i].text = "+" .. listNextQua[i] - listCurQua[i]
	end

	local curQualIdx = EquipmentManager:GetQualityIndex(infoSlot.quality, infoSlot.grade)
	local limitLevel = EquipmentManager.listMaxQualityLevel[curQualIdx]
	local path, name = EquipmentManager:GetEquipSlotIconAndName(infoRole, infoEquip, nextQ, nextG)
	local nextQualIdx = EquipmentManager:GetQualityIndex(nextQ, nextG)
	local col = GetConfigArgJson("EquipQualityColor")[nextQualIdx].Color

	self.TxtEquipName.text = string.format(_("Desc_AfterBreak"), limitLevel)
end

function DlgEquipBreakDetail:OnClickedClose()
	self:Close()
end
