-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgCardPetal.lua

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

DlgCardPetal = class("DlgCardPetal", UIPanel)

function DlgCardPetal:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/DlgCardPetal"
end

function DlgCardPetal:Purge()
	self.base.Purge(self)
	GOUtil.DestroyAllChildren(self.CellGroup)
	UnloadAllImageSprite(self)
end

function DlgCardPetal:OnRegisterEvent()
	self:AddClick(self.GoClose, self.OnClickClose, PATH_SFX_UI_CANCEL)
end

function DlgCardPetal:OnUnRegisterEvent()
	self:RemoveClick(self.GoClose, self.OnClickClose)
end

function DlgCardPetal:OnEnter(vParam)
	local Text = self:GetChildComponent("Panel/Title/Image/Text", "Text")

	Text.text = _("Desc_Info_Quality")
	Text = self:GetChildComponent("Panel/Text", "Text")
	Text.text = _("Desc_ClickClose")
	self.GoCell = self:GetChildGameObject("Panel/Cell")
	self.CellGroup = self:GetChildGameObject("Panel/ScrollArea/Content")
	self.GoClose = self:GetChildGameObject("Bg")

	self:UpdatePanel(vParam)
end

function DlgCardPetal:UpdatePanel(vParam)
	local infoRoleCard = vParam.infoRoleCard
	local listUpSkill = infoRoleCard.data.FlowerSkill or {}

	for i = 1, #listUpSkill do
		if listUpSkill[i][1] then
			local go = GOUtil.Instantiate(self.GoCell, self.CellGroup)
			local state = GOUtil.FindChildGameObject(go, "State/State" .. infoRoleCard.cardRank)

			GOUtil.SetActive(state, true)

			for k = 1, infoRoleCard.maxPetal do
				local image = GOUtil.FindChildComponent(state, "" .. k, "Image")

				image.gameObject:SetActive(true)

				local gray = TenaryOp(k <= i, 0, 1)

				DealWithListRef(self, UIUtil.SetImageGray(image, gray))
			end

			local infoSkill = TalentManager:Get(listUpSkill[i][1])
			local imgSkillIcon = GOUtil.FindChildComponent(go, "Icon", "Image")
			local txtSkillName = GOUtil.FindChildComponent(go, "TxtName", "Text")
			local txtSkillInfo = GOUtil.FindChildComponent(go, "TxtInfo", "Text")
			local txtSkillLevel = GOUtil.FindChildComponent(go, "TxtLevel", "Text")

			UIUtil.SetImageSprite(imgSkillIcon, "UIDyAtlas/Skill/" .. infoSkill.data.Icon, self)

			txtSkillName.text = Lang(infoSkill.data.Name)
			txtSkillLevel.text = Lang(12002) .. listUpSkill[i][2] or 1
			txtSkillInfo.text = skillTip.GetDesc(infoSkill.id, listUpSkill[i][2] or 1, 0)

			local battleType = infoSkill.data.BattleSkillType

			GOUtil.FindChildGameObject(go, "TypeP"):SetActive(battleType == 2)
			GOUtil.FindChildGameObject(go, "TypeC"):SetActive(battleType == 3)

			local goLine = GOUtil.FindChildGameObject(go, "ImgLine")

			GOUtil.SetFont(txtSkillInfo, UIMgr.JPFonts.W5)
			goLine:SetActive(i ~= #listUpSkill)
		end
	end

	GOUtil.SetActive(self.GoCell, false)
end

function DlgCardPetal:OnClickClose()
	self:Close()
end
