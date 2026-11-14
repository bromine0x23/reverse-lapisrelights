-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgEquipDevelopResult.lua

DlgEquipDevelopResult = class("DlgEquipDevelopResult", UIPanel)

function DlgEquipDevelopResult:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/DlgEquipDevelopResult"
	self.callback = nil
end

function DlgEquipDevelopResult:Purge()
	self.base.Purge(self)
	TimerMgr.RemoveTimer(self.timer)
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_TextGlow/FX_UI_TextGlow")
	UnloadAllImageSprite(self)
end

function DlgEquipDevelopResult:OnRegisterEvent()
	self:AddClick(self.GoClose, self.OnClickedClose)
end

function DlgEquipDevelopResult:OnUnRegisterEvent()
	self:RemoveClick(self.GoClose, self.OnClickedClose)
end

function DlgEquipDevelopResult:OnEnter(vParam)
	if not vParam then
		return
	end

	self:DealWithLocalization()

	self.GoClose = self:GetChildGameObject("Bg")
	self.list = {}

	for i = 1, 6 do
		local cell = {}
		local g = self:GetChildGameObject("Panel/Attr/AttrCon/" .. i)

		cell.obj = g
		cell.Icon = GOUtil.FindChildComponent(g, "IconEquip", "Image")
		cell.Txt1 = GOUtil.FindChildComponent(g, "Txt1", "Text")
		cell.Txt2 = GOUtil.FindChildComponent(g, "Txt2", "Text")
		cell.Name = GOUtil.FindChildComponent(g, "Name", "Text")
		cell.Line = GOUtil.FindChildGameObject(g, "line")

		table.insert(self.list, cell)
	end

	self:Init(vParam)
end

function DlgEquipDevelopResult:DealWithLocalization()
	return
end

function DlgEquipDevelopResult:Init(data)
	self.infoRole = data.infoRole
	self.slot = data.slot
	self.levelBefore = data.levelBefore
	self.callback = data.callback

	self:InitPanel()
end

function DlgEquipDevelopResult:InitPanel()
	local slotContains = {}

	for i = #self.slot, 1, -1 do
		if table.contains(slotContains, self.slot[i].slot) or self.levelBefore[self.slot[i].slot] == self.slot[i].level then
			table.remove(self.slot, i)
		else
			table.insert(slotContains, self.slot[i].slot)
		end
	end

	for i = 1, 6 do
		if i <= #self.slot then
			local infoEquip = EquipmentManager:GetEquip(self.infoRole:GetEquipId(self.slot[i].slot))
			local icon, name = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, infoEquip, self.slot[i].quality, self.slot[i].grade)

			SetImageSprite(self.list[i].Icon, icon, self)

			self.list[i].Txt1.text = string.format(_("Desc_Level"), self.levelBefore[self.slot[i].slot])
			self.list[i].Txt2.text = string.format(_("Desc_Level"), self.infoRole.pb.slots[self.slot[i].slot].level)
			self.list[i].Name.text = name
		else
			self.list[i].obj:SetActive(false)
		end
	end

	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.3, function()
		for i = 1, 6 do
			if i <= #self.slot then
				EffectMgr:Alloc("Fx/UI/FX_UI_TextGlow/FX_UI_TextGlow", self.list[i].Line, true)
			end
		end
	end, {})
end

function DlgEquipDevelopResult:OnClickedClose()
	self:Close()

	if self.callback then
		self.callback()

		self.callback = nil
	end
end
