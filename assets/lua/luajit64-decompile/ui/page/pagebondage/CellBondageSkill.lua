-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBondage/CellBondageSkill.lua

require("UI/Item/UIItemBase")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

CellBondageSkill = class("CellBondageSkill", UIItemBase)

function CellBondageSkill:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBondageSkill:Create(vParam)
	CellBondageSkill.base.Create(self, vParam)
end

function CellBondageSkill:OnEnter()
	local g = self.UIRootObject
	local txt = GOUtil.FindChildComponent(g, "BtnUp/Text", "Text")

	txt.text = _("PageRoleCard_TextUp")
	self.ImgSkillIcon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.TxtSkillName = GOUtil.FindChildComponent(g, "TxtName", "Text")
	self.TxtSkillInfo = GOUtil.FindChildComponent(g, "TxtDesc/Text", "TextView")
	self.TxtSkillLevel = GOUtil.FindChildComponent(g, "TxtLv", "Text")
	self.TxtSkillEnableInfo = GOUtil.FindChildComponent(g, "TxtEnable", "Text")
	self.TxtSkillPrompt = GOUtil.FindChildComponent(g, "TxtPrompt", "Text")
	self.ImgBgPrompt = GOUtil.FindChildComponent(g, "Image", "Image")
	self.GoLock = GOUtil.FindChildGameObject(g, "Lock")
	self.BtnUp = GOUtil.FindChildGameObject(g, "BtnUp")
	self.GoDot = GOUtil.FindChildGameObject(g, "BtnUp/Dot")

	self:AddClick(self.ImgSkillIcon.gameObject, self.OnClickedSkill)
	self:AddClick(self.BtnUp, self.OnClickedBtnUp)
end

function CellBondageSkill:OnLeave()
	self:RemoveClick(self.ImgSkillIcon.gameObject, self.OnClickedSkill)
	self:RemoveClick(self.BtnUp, self.OnClickedBtnUp)
	UnloadAllImageSprite(self)
end

function CellBondageSkill:UpdateData(infoSkill, infoCombination)
	self.info = infoSkill
	self.infoComb = infoCombination

	UIUtil.SetImageSprite(self.ImgSkillIcon, "UIDyAtlas/Skill/" .. infoSkill.data.Icon, self)

	self.TxtSkillName.text = Lang(infoSkill.data.Name)

	self:UpdateDynamicData()
end

function CellBondageSkill:UpdateDynamicData()
	self.TxtSkillInfo.Text = ModifyRichTextForTextView(skillTip.GetDesc(self.info.id, self.info.pb and self.info.pb.level or 1, 1))
	self.TxtSkillLevel.text = _("Player_Level") .. (self.info.pb and self.info.pb.level or 1)
	self.TxtSkillEnableInfo.text = string.format(_("Desc_FetterNeedIdolNum"), CombBondageMgr:GetEnableCondition(self.infoComb, self.info.id))
	self.isUnlock = CombBondageMgr:BondageSkillIsUnlock(self.infoComb, self.info.id)
	self.isMaxLevel = self.info:IsMaxLevel()

	local unlocks = CombBondageMgr.GetJustUnlockSkillIds(self.infoComb.id)

	if not self.isUnlock or unlocks ~= nil and table.contains(unlocks, self.info.id) then
		GOUtil.SetActive(self.GoLock, true)
		GOUtil.SetActive(self.BtnUp, false)
		GOUtil.SetActive(self.TxtSkillPrompt, true)

		local num, favorLv = CombBondageMgr:GetUnlockCondition(self.infoComb, self.info.id)

		self.TxtSkillPrompt.text = string.format(_("Desc_UnlockBondageSkill"), num, favorLv)

		UIUtil.SetGraphicColorRGB(self.TxtSkillPrompt, 1, 1, 1)
		UIUtil.SetGraphicColorRGB(self.ImgBgPrompt, 0.5058823529411764, 0.5411764705882353, 0.5686274509803921)
	else
		self:UpdateState()
	end
end

function CellBondageSkill:UpdateState()
	GOUtil.SetActive(self.GoLock, not self.isUnlock)
	GOUtil.SetActive(self.BtnUp, self.isUnlock and not self.isMaxLevel)
	GOUtil.SetActive(self.TxtSkillPrompt, not self.isUnlock or self.isMaxLevel)

	local color = sixNumToRGB(self.infoComb.data.SkillBgColor)

	UIUtil.SetGraphicColorRGB(self.ImgBgPrompt, color.r / 255, color.g / 255, color.b / 255)

	if self.isMaxLevel then
		self.TxtSkillPrompt.text = Lang(12197)

		UIUtil.SetGraphicColorRGB(self.TxtSkillPrompt, 0.34509803921568627, 0.3686274509803922, 0.3843137254901961)
	end
end

function CellBondageSkill:UpdateDot()
	return
end

function CellBondageSkill:OnClickedSkill()
	local data = {
		infoSkill = self.info,
		infoComb = self.infoComb
	}

	UIMgr.AddPanel(DlgBondageSkillTip(), data)
end

function CellBondageSkill:OnClickedBtnUp()
	if not self.isUnlock then
		return
	end

	Event.Instance:Fire("ShowUpgradePanel", {
		skill = self.info,
		comb = self.infoComb
	})
end
