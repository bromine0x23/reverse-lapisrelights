-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellResultAddUp.lua

CellResultAddUp = class("CellResultAddUp", UIPanel_sync)

function CellResultAddUp:ctor(camp)
	self.camp = camp

	if camp == EnumFight.Camp.PLAYER then
		CellResultAddUp.base.ctor(self, "UI/PageFight/Cells/CellResultAddUp_camp1")
	else
		CellResultAddUp.base.ctor(self, "UI/PageFight/Cells/CellResultAddUp_camp2")
	end
end

function CellResultAddUp:Cache()
	CellResultAddUp.base.Cache(self)
end

function CellResultAddUp:Close()
	CellResultAddUp.base.Close(self)
end

function CellResultAddUp:Purge()
	CellResultAddUp.base.Purge(self)
	self:ResetData()
end

function CellResultAddUp:OnRegisterEvent()
	self:AddClick(self.img_Head.gameObject, self.OnClick)
end

function CellResultAddUp:OnUnRegisterEvent()
	self:RemoveClick(self.img_Head.gameObject, self.OnClick)
end

function CellResultAddUp:ResetData()
	self.SkillDamage = {}
	self.BuffDamage = {}
	self.SumDamage = 0
	self.SumDamageTake = 0
	self.SumHeal = 0
	self.Owner = nil
end

function CellResultAddUp:OnEnter(vParam)
	self:ResetData()

	self.img_Head = self:GetChildComponent("img_Head", "Image")
	self.img_Rank = self:GetChildComponent("img_Rank", "Image")
	self.img_Job = self:GetChildComponent("img_Job", "Image")
	self.img_fill = self:GetChildComponent("img_fill", "Image")
	self.txt_Num = self:GetChildComponent("txt_Num", "Text")
	self.txt_NumPer = self:GetChildComponent("txt_NumPer", "Text")
	self.txt_NumPer.text = ""

	if self.camp == EnumFight.Camp.ENEMY then
		self.obj_monsterHeadFrame = self:GetChildGameObject("bk (1)", "Image")
	end

	self:Show(false)
end

function CellResultAddUp:SetParent(root)
	GOUtil.AttachGameObject(self.UIRootObject, root, true)
end

function CellResultAddUp:RefreshData(unitResult, teamResult)
	local unit = UnitActor.FindUnitById(unitResult.UniqueId)

	self.Owner = unit
	self.TeamResult = teamResult
	self.SkillDamage = unitResult.SkillDamage
	self.BuffDamage = unitResult.BuffDamage
	self.SumDamage = unitResult.SumDamage
	self.SumDamageTake = unitResult.SumDamageTake
	self.SumHeal = unitResult.SumHeal

	self:SetUI()
end

function CellResultAddUp:SetUI()
	if self.Owner.UnitClass == EnumFight.UnitClass.ENEMY then
		GP.SpriteUtil:SetSprite(self.img_Head, EnemyManager:Get(self.Owner.UnitId).data.CombatReadinessHeadIcon)
		GOUtil.SetActive(self.img_Rank, false)
	else
		local card = self.Owner.InfoRoleCard

		if card then
			GP.SpriteUtil:SetSprite(self.img_Head, card.data.HeadIcon)
			GOUtil.SetActive(self.img_Rank, true)
			GP.SpriteUtil:SetSprite(self.img_Rank, DlgUIResultAddUp.RankPic[card.data.Rank])
		end

		local jobpath = "UI/PageFight/AtlasPageBattle/ICO_" .. self.Owner.UnitData.data.Job .. "_01_S"

		GP.SpriteUtil:SetSprite(self.img_Job, jobpath)

		if self.Owner.UnitClass == EnumFight.UnitClass.PVPPLAYER then
			GOUtil.SetActive(self.obj_monsterHeadFrame, false)
			GOUtil.SetActive(self.img_Job.gameObject, true)
		end
	end
end

function CellResultAddUp:RefreshDmg()
	self:Show(true)

	self.txt_Num.text = string.format(_("LabelDamageCount"), math.ceil(self.SumDamage))

	local r = self.SumDamage / self.TeamResult.SumDamage

	if tostring(r) == "nan" then
		r = 0
	end

	self.img_fill.fillAmount = r
end

function CellResultAddUp:RefreshHeal()
	self:Show(true)

	self.txt_Num.text = string.format(_("LabelHealCount"), math.ceil(self.SumHeal))

	local r = self.SumHeal / self.TeamResult.SumHeal

	if tostring(r) == "nan" then
		r = 0
	end

	self.img_fill.fillAmount = r
end

function CellResultAddUp:RefreshTakeDmg()
	self:Show(true)

	self.txt_Num.text = string.format(_("LabelTakeDamageCount"), math.ceil(self.SumDamageTake))

	local r = self.SumDamageTake / self.TeamResult.SumDamageTake

	if tostring(r) == "nan" then
		r = 0
	end

	self.img_fill.fillAmount = r
end

function CellResultAddUp:OnClick()
	Event.Instance:Fire("ResultAddUpCellClick", self)
end
