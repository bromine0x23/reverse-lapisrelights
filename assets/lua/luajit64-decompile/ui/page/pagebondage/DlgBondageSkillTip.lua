-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBondage/DlgBondageSkillTip.lua

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

DlgBondageSkillTip = class("DlgBondageSkillTip", UIPanel)

function DlgBondageSkillTip:ctor()
	self.base.ctor(self, "UI/PanelBondage/DlgBondageSkillTip")
end

function DlgBondageSkillTip:Purge()
	self.base.Purge(self)
end

function DlgBondageSkillTip:OnRegisterEvent()
	self:AddClick(self.Bg, self.OnClickedClose)
end

function DlgBondageSkillTip:OnUnRegisterEvent()
	self:RemoveClick(self.Bg, self.OnClickedClose)
end

function DlgBondageSkillTip:OnEnter(vParam)
	self.Bg = self:GetChildGameObject("Bg")

	local txt = self:GetChildComponent("Bg/Text", "Text")

	txt.text = Lang(42326)
	self.ImgSkillIcon = self:GetChildComponent("Panel/Icon", "Image")
	self.TxtSkillName = self:GetChildComponent("Panel/Name/TxtName", "Text")
	self.TxtSkillCost = self:GetChildComponent("Panel/BgCost/TxtCost", "Text")
	self.TxtSkillLevel = self:GetChildComponent("Panel/BgLevel/TxtLevel", "Text")
	self.GoLock = self:GetChildGameObject("Panel/Lock")
	self.TxtDesc = self:GetChildComponent("Panel/Group/Desc/TxtDesc", "Text")
	self.Content = self:GetChildGameObject("Panel/Group/SceollArea/Content")
	self.GoCell = self:GetChildGameObject("Panel/Group/SceollArea/Content/1")

	self:Init(vParam)
end

function DlgBondageSkillTip:Init(data)
	local infoComb = data.infoComb

	self.infoSkill = data.infoSkill

	local curLevel = self.infoSkill.pb.level
	local maxLevel = self.infoSkill.data.HighestLevel
	local isUnlock = CombBondageMgr:BondageSkillIsUnlock(infoComb, self.infoSkill.id)

	GOUtil.SetActive(self.GoLock, isUnlock)

	local gray = TenaryOp(isUnlock, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgSkillIcon, gray))

	self.TxtSkillName.text = Lang(self.infoSkill.data.Name)

	UIUtil.SetImageSprite(self.ImgSkillIcon, "UIDyAtlas/Skill/" .. self.infoSkill.data.Icon, self)

	self.TxtSkillLevel.text = string.format(_("Desc_Level"), tostring(curLevel))
	self.TxtDesc.text = skillTip.GetDesc(self.infoSkill.id, curLevel, 0)

	if curLevel < maxLevel then
		self.listCell = {}

		table.insert(self.listCell, self.GoCell)

		local cnt = maxLevel - curLevel - 1

		for i = 1, cnt do
			local cell = GOUtil.Instantiate(self.GoCell, self.Content)

			cell.name = i + 1

			table.insert(self.listCell, cell)
		end

		self:UpdateCellSkill()
	else
		GOUtil.SetActive(self.GoCell, false)
	end
end

function DlgBondageSkillTip:UpdateCellSkill()
	self.listCell = self.listCell or {}

	for i = 1, #self.listCell do
		local go = self.listCell[i]
		local level = self.infoSkill.pb.level + i
		local txtLevel = GOUtil.FindChildComponent(go, "Level/Text", "Text")

		txtLevel.text = _("Player_Level") .. level

		local txtDesc = GOUtil.FindChildComponent(go, "TxtDesc", "Text")

		txtDesc.text = skillTip.GetDesc(self.infoSkill.id, level, 0)

		UIUtil.SetGraphicColorRGBA(txtDesc, 1, 1, 1, 0.5)
	end
end

function DlgBondageSkillTip:OnClickedClose()
	self:Close()
end
