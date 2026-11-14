-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgCardUpResult.lua

DlgCardUpResult = class("DlgCardUpResult", UIPanel)

function DlgCardUpResult:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/DlgCardUpResult"
	self.callback = nil
end

function DlgCardUpResult:Purge()
	self.base.Purge(self)
end

function DlgCardUpResult:OnRegisterEvent()
	self:AddClick(self.GoClose, self.OnClickedClose)
end

function DlgCardUpResult:OnUnRegisterEvent()
	self:RemoveClick(self.GoClose, self.OnClickedClose)
end

function DlgCardUpResult:OnEnter(vParam)
	if not vParam then
		return
	end

	self:DealWithLocalization()

	self.GoClose = self:GetChildGameObject("Bg")
	self.GoStar = self:GetChildGameObject("Panel/Eff/Star")
	self.GoPetal = self:GetChildGameObject("Panel/Eff/Petal")
	self.GoEquip = self:GetChildGameObject("Panel/Eff/Equip")
	self.GoSkill = self:GetChildGameObject("Panel/Up/Skill")
	self.GoAttr = self:GetChildGameObject("Panel/Up/Attr")
	self.GoEquipList = self:GetChildGameObject("Panel/Up/Equip")
	self.EquipList = {}

	for i = 1, 6 do
		local cell = {}
		local g = self:GetChildGameObject("Panel/Up/Equip/" .. i)

		cell.obj = g
		cell.Icon = GOUtil.FindChildComponent(g, "Icon", "Image")
		cell.ImageLevel = GOUtil.FindChildComponent(g, "ImageLevel", "Image")
		cell.TextLevel = GOUtil.FindChildComponent(g, "TextLevel", "Text")

		table.insert(self.EquipList, cell)
	end

	self:Init(vParam)
end

function DlgCardUpResult:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Text", "Text")
	txt.text = Lang(42326)
	txt = self:GetChildComponent("Panel/Up/Skill/Text", "Text")
	txt.text = Lang(42182)
	txt = self:GetChildComponent("Panel/Up/Attr/Text", "Text")
	txt.text = _("Desc_Card_Attr_Up")
end

function DlgCardUpResult:Init(data)
	self.type = data.type
	self.infoRoleCard = data.infoRoleCard
	self.infoRole = data.infoRole
	self.slotIdx = data.slotIdx

	if data.slots then
		local slot = {}

		for i = 1, #data.slots do
			table.insert(slot, data.slots[i].slot)
		end

		self.slots = data.slots
		self.slotId = slot
	end

	self.callback = data.callback

	self:InitPanel()
end

function DlgCardUpResult:InitPanel()
	GOUtil.SetActive(self.GoStar, self.type == 1)
	GOUtil.SetActive(self.GoPetal, self.type == 2)
	GOUtil.SetActive(self.GoEquip, self.type == 3 or self.type == 4)
	GOUtil.SetActive(self.GoSkill, false)

	if self.type == 1 then
		SoundMgr.PostEvent(PATH_SFX_UI_CARD_STARUP, self.UIRootObject)
		GOUtil.SetTransformLocalPosition(self.GoAttr, 0, 0, 0)
	elseif self.type == 2 then
		SoundMgr.PostEvent(PATH_SFX_UI_CARD_SKILLUP, self.UIRootObject)

		local curPetal = self.infoRoleCard.curPetal
		local skill = self.infoRoleCard.data.FlowerSkill[curPetal]

		if skill and skill[1] then
			GOUtil.SetActive(self.GoSkill, true)
			self:UpdateSkill(skill[1])
		else
			GOUtil.SetTransformLocalPosition(self.GoAttr, 0, 0, 0)
		end
	elseif self.type == 3 then
		SoundMgr.PostEvent(PATH_SFX_UI_EQUIP_BREAKOUT, self.UIRootObject)
		GOUtil.SetTransformLocalPosition(self.GoAttr, 0, 0, 0)
	elseif self.type == 4 then
		SoundMgr.PostEvent(PATH_SFX_UI_EQUIP_BREAKOUT, self.UIRootObject)
		GOUtil.SetTransformLocalPosition(self.GoAttr, 0, 60, 0)
	end

	self:UpdateAttr()
end

function DlgCardUpResult:UpdateSkill(skillId)
	local infoSkill = TalentManager:Get(skillId)
	local preLevel = self.infoRoleCard:GetTalentLevelByPetal(skillId, self.infoRoleCard.curPetal - 1)
	local curLevel = self.infoRoleCard:GetTalentLevelByPetal(skillId, self.infoRoleCard.curPetal)
	local imgSkillIcon = GOUtil.FindChildComponent(self.GoSkill, "Icon", "Image")
	local txtSkillName = GOUtil.FindChildComponent(self.GoSkill, "TxtName", "Text")
	local txtPreLevel = GOUtil.FindChildComponent(self.GoSkill, "Result/TxtPre", "Text")
	local txtCurLevel = GOUtil.FindChildComponent(self.GoSkill, "Result/TxtCur", "Text")

	txtSkillName.text = Lang(infoSkill.data.Name)
	txtPreLevel.text = Lang(12004) .. " " .. tostring(preLevel) .. "/" .. infoSkill.data.HighestLevel
	txtCurLevel.text = Lang(12004) .. " " .. tostring(curLevel) .. "/" .. infoSkill.data.HighestLevel

	UIUtil.SetImageSprite(imgSkillIcon, "UIDyAtlas/Skill/" .. infoSkill.data.Icon, self)
end

function DlgCardUpResult:UpdateAttr()
	local preAttr, curAttr

	if self.type == 1 or self.type == 2 then
		local level = self.infoRoleCard.curLevel
		local starLevel = self.infoRoleCard.curStarLevel
		local petal = self.infoRoleCard.curPetal

		if self.type == 1 then
			preAttr = self.infoRoleCard:UpdateAtt(level, starLevel - 1, petal)
		else
			preAttr = self.infoRoleCard:UpdateAtt(level, starLevel, petal - 1)
		end

		curAttr = self.infoRoleCard:UpdateAtt(level, starLevel, petal)
	elseif self.type == 3 then
		local equipId = self.infoRole:GetEquipId(self.slotIdx)
		local infoSlot = self.infoRole:GetEquipSlot(self.slotIdx)
		local listCurLv = EquipmentManager:GetProp(infoSlot.level, self.infoRole.job, self.slotIdx, equipId)
		local preQua, preGra = EquipmentManager:GetLastQuality(infoSlot.quality, infoSlot.grade)
		local listPreQua = EquipmentManager:GetQualityProp(self.infoRole.job, preQua, preGra, self.slotIdx)
		local listCurQua = EquipmentManager:GetQualityProp(self.infoRole.job, infoSlot.quality, infoSlot.grade, self.slotIdx)

		preAttr = AttributeOwner()
		curAttr = AttributeOwner()

		for k, v in pairs(ATTRIBUTE_NAME) do
			preAttr:SetBase(v, (listCurLv[k] or 0) + (listPreQua[k] or 0))
			curAttr:SetBase(v, (listCurLv[k] or 0) + (listCurQua[k] or 0))
		end
	elseif self.type == 4 then
		preAttr = AttributeOwner()
		curAttr = AttributeOwner()

		for i = 1, #self.slots do
			local equipId = self.infoRole:GetEquipId(self.slots[i].slot)
			local infoSlot = self.infoRole:GetEquipSlot(self.slots[i].slot)
			local listCurLv = EquipmentManager:GetProp(infoSlot.level, self.infoRole.job, self.slots[i].slot, equipId)
			local preQua, preGra = EquipmentManager:GetLastQuality(infoSlot.quality, infoSlot.grade)
			local listPreQua = EquipmentManager:GetQualityProp(self.infoRole.job, preQua, preGra, self.slots[i].slot)
			local listCurQua = EquipmentManager:GetQualityProp(self.infoRole.job, infoSlot.quality, infoSlot.grade, self.slots[i].slot)

			for k, v in pairs(ATTRIBUTE_NAME) do
				preAttr:ModBase(v, (listCurLv[k] or 0) + (listPreQua[k] or 0))
				curAttr:ModBase(v, (listCurLv[k] or 0) + (listCurQua[k] or 0))
			end

			GOUtil.SetActive(self.EquipList[i].obj, true)

			local infoEquip = EquipmentManager:GetEquip(equipId)
			local icon, _ = EquipmentManager:GetEquipSlotIconAndName(self.infoRole, infoEquip, infoSlot.quality, infoSlot.grade)

			SetImageSprite(self.EquipList[i].Icon, icon, self)

			local quaIdx = EquipmentManager:GetQualityIndex(infoSlot.quality, infoSlot.grade)

			self.EquipList[i].ImageLevel.color = getColorFromString(GetConfigArgJson("EquipQualityColor")[quaIdx].Color)
			self.EquipList[i].TextLevel.text = infoSlot.level
		end

		GOUtil.SetActive(self.GoEquipList, true)
	end

	local list = {}

	for k, v in ipairs(ATTRIBUTE_NAME) do
		local preAtt = preAttr:Get(v)
		local curAtt = curAttr:Get(v)

		table.insert(list, k)
	end

	local scrollArea = GOUtil.FindChildGameObject(self.GoAttr, "ScrollArea")
	local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "Transform")
	scrollView.vertical = true

	local cell = GOUtil.FindChildGameObject(self.GoAttr, "Cell")

	for i = 1, #list do
		local index = list[i]
		local preValue = preAttr:Get(index)
		local curValue = curAttr:Get(index)
		local go = GOUtil.Instantiate(cell, scrollView.content.gameObject)
		local txtAtt = GOUtil.FindChildComponent(go, "Name/Text", "Text")
		local txtPreValue = GOUtil.FindChildComponent(go, "TxtPre", "Text")
		local txtCurValue = GOUtil.FindChildComponent(go, "TxtCur", "Text")
		local txtAddValue = GOUtil.FindChildComponent(go, "TxtAdd", "Text")

		txtAtt.text = _("eAttType_" .. index)
		txtPreValue.text = tostring(math.floor(preValue + 0.5))
		txtCurValue.text = tostring(math.floor(curValue + 0.5))
		txtAddValue.text = "(+" .. math.floor(curValue + 0.5) - math.floor(preValue + 0.5) .. ")"
	end

	GOUtil.SetActive(cell, false)
end

function DlgCardUpResult:OnClickedClose()
	self:Close()

	if self.callback then
		self.callback()

		self.callback = nil
	end
end
