-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIResultAddUp.lua

require("UI/Page/PageFight/Cells/CellResultAddUp")
require("UI/Page/PageFight/Cells/CellResultAddUp_detail")

DlgUIResultAddUp = class("DlgUIResultAddUp", UIPanel_sync)
DlgUIResultAddUp.RankPic = {
	SR = "UI/PageFight/AtlasResultAddUp/BG_card_block_sr_01",
	SSR = "UI/PageFight/AtlasResultAddUp/BG_card_block_ssr_01",
	UR = "UI/PageFight/AtlasResultAddUp/BG_card_block_ur_01",
	R = "UI/PageFight/AtlasResultAddUp/BG_card_block_r_01"
}
DlgUIResultAddUp.enDetailType = {
	SkillCount = 1,
	Damage = 2
}

function DlgUIResultAddUp:ctor()
	DlgUIResultAddUp.base.ctor(self, "UI/PageFight/Dlg/DlgUIResultAddUp")

	self.cellsPlayer = {}
	self.cellsMonster = {}

	for i, unitId in ipairs(GP.PlayerUnitIds) do
		local cardId = GP.PlayerCardIds[i]
		local cell = CellResultAddUp(EnumFight.Camp.PLAYER)

		self:AddChildPanel(cell)
		table.insert(self.cellsPlayer, cell)
	end

	if GP.GameStartData.pvp == EnumFight.Pvp.NONE then
		for i, wave in ipairs(GP.EnemyUnitIds) do
			local cell = CellResultAddUp(EnumFight.Camp.ENEMY)

			self:AddChildPanel(cell)
			table.insert(self.cellsMonster, cell)
		end
	else
		for i, wave in ipairs(GP.EnemyUnitIds) do
			local cell = CellResultAddUp(EnumFight.Camp.ENEMY)

			self:AddChildPanel(cell)
			table.insert(self.cellsMonster, cell)
		end
	end
end

function DlgUIResultAddUp:Cache()
	DlgUIResultAddUp.base.Cache(self)
end

function DlgUIResultAddUp:Close()
	DlgUIResultAddUp.base.Close(self)
end

function DlgUIResultAddUp:Purge()
	DlgUIResultAddUp.base.Purge(self)

	for i, cell in ipairs(self.cellsPlayer) do
		cell:Close()
	end

	for i, cell in ipairs(self.cellsMonster) do
		cell:Close()
	end

	for i, cell in ipairs(self.cellsDetail_skill) do
		cell:Close()
	end

	UIMgr:RemoveSafeArea(self)
end

function DlgUIResultAddUp:OnRegisterEvent()
	self.tog_Dmg.onValueChanged:AddListener(self.OnToggleDmg)
	self.tog_Heal.onValueChanged:AddListener(self.OnToggleHeal)
	self.tog_TakeDmg.onValueChanged:AddListener(self.OnToggleTakeDmg)
	self:AddClick(self.btn_Close1, self.OnBtnClose1)
	self:AddClick(self.btn_Close2, self.OnBtnClose2)
	self:AddClick(self.btn_dmg, self.OnBtnDamage)
	self:AddClick(self.btn_skill, self.OnBtnSkill)
	Event.Instance:Add("ResultAddUpCellClick", self.OnResultAddUpCellClick, self)
end

function DlgUIResultAddUp:OnUnRegisterEvent()
	self.tog_Dmg.onValueChanged:RemoveListener(self.OnToggleDmg)
	self.tog_Heal.onValueChanged:RemoveListener(self.OnToggleHeal)
	self.tog_TakeDmg.onValueChanged:RemoveListener(self.OnToggleTakeDmg)
	self:RemoveClick(self.btn_Close1, self.OnBtnClose1)
	self:RemoveClick(self.btn_Close2, self.OnBtnClose2)
	self:RemoveClick(self.btn_dmg, self.OnBtnDamage)
	self:RemoveClick(self.btn_skill, self.OnBtnSkill)
	Event.Instance:Remove("ResultAddUpCellClick", self.OnResultAddUpCellClick, self)
end

function DlgUIResultAddUp:OnEnter()
	UIMgr:SetSafeArea(self, self.UIRootObject)

	self.curIndex = 0
	self.detailType = DlgUIResultAddUp.enDetailType.Damage
	self.cellsDetail_skill = {}
	self.obj_main = self:GetChildGameObject("panel/main")
	self.obj_detail = self:GetChildGameObject("panel/detail")
	self.obj_detailRoot = self:GetChildGameObject("panel/detail/scrollView/Viewport/Content")

	GOUtil.SetActive(self.obj_detail, false)

	self.btn_dmg = self:GetChildGameObject("panel/detail/btn_dmg")
	self.btn_skill = self:GetChildGameObject("panel/detail/btn_skill")
	self.obj_RootCamp1 = self:GetChildGameObject("panel/main/scrollCamp1/Viewport/Content")
	self.obj_RootCamp2 = self:GetChildGameObject("panel/main/scrollCamp2/Viewport/Content")
	self.btn_Close1 = self:GetChildGameObject("panel/main/btn_Close1")
	self.btn_Close2 = self:GetChildGameObject("panel/detail/btn_Close2")

	self.btn_Close2:SetActive(false)

	for i, cell in ipairs(self.cellsPlayer) do
		cell:SetParent(self.obj_RootCamp1)
	end

	for i, cell in ipairs(self.cellsMonster) do
		cell:SetParent(self.obj_RootCamp2)
	end

	self.cells = {}
	self.cells[EnumFight.Camp.PLAYER] = self.cellsPlayer
	self.cells[EnumFight.Camp.ENEMY] = self.cellsMonster
	self.tog_Dmg = self:GetChildComponent("panel/main/tog_Dmg", "Toggle")
	self.tog_Heal = self:GetChildComponent("panel/main/tog_Heal", "Toggle")
	self.tog_TakeDmg = self:GetChildComponent("panel/main/tog_TakeDmg", "Toggle")
	self.txt_togDmg = self:GetChildComponent("panel/main/tog_Dmg/Label", "Text")
	self.txt_togHeal = self:GetChildComponent("panel/main/tog_Heal/Label", "Text")
	self.txt_togTakeDmg = self:GetChildComponent("panel/main/tog_TakeDmg/Label", "Text")
	self.color_togOn = self.txt_togDmg.color
	self.color_togOff = self.txt_togHeal.color

	function self.OnToggleDmg(isOn)
		self:_OnToggleDmg(isOn)
	end

	function self.OnToggleHeal(isOn)
		self:_OnToggleHeal(isOn)
	end

	function self.OnToggleTakeDmg(isOn)
		self:_OnToggleTakeDmg(isOn)
	end

	self.txt_tip = self:GetChildComponent("panel/main/txt_tip", "Text")
	self.txt_tip.text = _("CharacterRecountTips")
	self.activeCell = {}
	self.img_detailHead = self:GetChildComponent("panel/detail/role/img_Head", "Image")
	self.img_detailRank = self:GetChildComponent("panel/detail/role/img_Rank", "Image")
	self.img_detailJob = self:GetChildComponent("panel/detail/role/img_Job", "Image")

	self:Show(false)
end

function DlgUIResultAddUp:OnBtnClose1()
	self:Show(false)

	if GP.GameStage ~= EnumFight.GameState.GAMEOVER then
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgBattleSetting", true)
	end
end

function DlgUIResultAddUp:OnBtnClose2()
	GOUtil.SetActive(self.obj_detail, false)
	self.btn_Close2:SetActive(false)
end

function DlgUIResultAddUp:OnBtnDamage()
	self.detailType = DlgUIResultAddUp.enDetailType.Damage

	GOUtil.SetActive(self.btn_dmg.transform:GetChild(0).gameObject, true)
	GOUtil.SetActive(self.btn_dmg.transform:GetChild(1).gameObject, false)
	GOUtil.SetActive(self.btn_skill.transform:GetChild(0).gameObject, false)
	GOUtil.SetActive(self.btn_skill.transform:GetChild(1).gameObject, true)
	self:OnDetailDamage(self.curUniqueId)
end

function DlgUIResultAddUp:OnBtnSkill()
	self.detailType = DlgUIResultAddUp.enDetailType.SkillCount

	GOUtil.SetActive(self.btn_dmg.transform:GetChild(0).gameObject, false)
	GOUtil.SetActive(self.btn_dmg.transform:GetChild(1).gameObject, true)
	GOUtil.SetActive(self.btn_skill.transform:GetChild(0).gameObject, true)
	GOUtil.SetActive(self.btn_skill.transform:GetChild(1).gameObject, false)
	self:OnDetailSkillCount(self.curUniqueId)
end

function DlgUIResultAddUp:Open()
	if GP.AutoMode == true and GP.GameStage ~= EnumFight.GameState.GAMEOVER then
		UIMgr.ShowMsg(_("LabelFightLimit"))

		return
	end

	if GP.GameStage ~= EnumFight.GameState.OPERATOR_WAIT and GP.GameStage ~= EnumFight.GameState.GAMEOVER then
		UIMgr.ShowMsg(_("LabelFightLimit"))

		return
	end

	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)
	GOUtil.SetActive(self.obj_detail, false)
	GOUtil.SetActive(self.obj_main, true)

	local data = GP.GameResultAddUpData

	self:Show(true)

	local pIdx = 0
	local eIdx = 0
	local playerMaxData = {
		SumDamage = 0,
		SumHeal = 0,
		SumDamageTake = 0
	}
	local enemyMaxData = {
		SumDamage = 0,
		SumHeal = 0,
		SumDamageTake = 0
	}
	local maxDatas = {}

	maxDatas[EnumFight.Camp.PLAYER] = playerMaxData
	maxDatas[EnumFight.Camp.ENEMY] = enemyMaxData

	for uid, unitResult in pairs(data.unitData) do
		local temp = maxDatas[unitResult.Camp]

		if temp.SumDamage < unitResult.SumDamage then
			temp.SumDamage = unitResult.SumDamage
		end

		if temp.SumHeal < unitResult.SumHeal then
			temp.SumHeal = unitResult.SumHeal
		end

		if temp.SumDamageTake < unitResult.SumDamageTake then
			temp.SumDamageTake = unitResult.SumDamageTake
		end
	end

	for uid, unitResult in pairs(data.unitData) do
		local cell
		local unit = UnitActor.FindUnitById(unitResult.UniqueId)

		if unit.Camp == EnumFight.Camp.PLAYER then
			pIdx = pIdx + 1
			cell = self.cells[unit.Camp][pIdx]
		else
			eIdx = eIdx + 1
			cell = self.cells[unit.Camp][eIdx]
		end

		if cell then
			local maxData = maxDatas[unit.Camp]

			cell:RefreshData(unitResult, maxDatas[unit.Camp])
			table.insert(self.activeCell, cell)
		end
	end

	if self.curIndex == 0 then
		self:_OnToggleDmg(true)
	elseif self.curIndex == 1 then
		self.tog_Dmg.isOn = true

		self:_OnToggleDmg(true)
	elseif self.curIndex == 2 then
		self.tog_Heal.isOn = true

		self:_OnToggleHeal(true)
	elseif self.curIndex == 3 then
		self.tog_TakeDmg.isOn = true

		self:_OnToggleTakeDmg(true)
	end
end

function DlgUIResultAddUp:SetTogTxtColor(txt, isOn)
	if isOn == true then
		txt.color = self.color_togOn
	else
		txt.color = self.color_togOff
	end
end

function DlgUIResultAddUp:_OnToggleDmg(isOn)
	self:SetTogTxtColor(self.txt_togDmg, isOn)
	GOUtil.SetActive(self.txt_tip.gameObject, isOn)

	if isOn == false then
		return
	end

	for i, cell in ipairs(self.activeCell) do
		cell:RefreshDmg()
	end

	self.curIndex = 1

	table.sort(self.activeCell, function(a, b)
		if a.SumDamage ~= b.SumDamage then
			return a.SumDamage > b.SumDamage
		else
			return a.Owner.Order < b.Owner.Order
		end
	end)

	for i, cell in ipairs(self.activeCell) do
		cell.UIRootObject.transform:SetAsLastSibling()
	end
end

function DlgUIResultAddUp:_OnToggleHeal(isOn)
	self:SetTogTxtColor(self.txt_togHeal, isOn)

	if isOn == false then
		return
	end

	for i, cell in ipairs(self.activeCell) do
		cell:RefreshHeal()
	end

	self.curIndex = 2

	table.sort(self.activeCell, function(a, b)
		if a.SumHeal ~= b.SumHeal then
			return a.SumHeal > b.SumHeal
		else
			return a.Owner.Order < b.Owner.Order
		end
	end)

	for i, cell in ipairs(self.activeCell) do
		cell.UIRootObject.transform:SetAsLastSibling()
	end
end

function DlgUIResultAddUp:_OnToggleTakeDmg(isOn)
	self:SetTogTxtColor(self.txt_togTakeDmg, isOn)

	if isOn == false then
		return
	end

	for i, cell in ipairs(self.activeCell) do
		cell:RefreshTakeDmg()
	end

	self.curIndex = 3

	table.sort(self.activeCell, function(a, b)
		if a.SumDamageTake ~= b.SumDamageTake then
			return a.SumDamageTake > b.SumDamageTake
		else
			return a.Owner.Order < b.Owner.Order
		end
	end)

	for i, cell in ipairs(self.activeCell) do
		cell.UIRootObject.transform:SetAsLastSibling()
	end
end

function DlgUIResultAddUp:OnResultAddUpCellClick(cell)
	if self.curIndex == 2 or self.curIndex == 3 then
		return
	end

	GOUtil.SetActive(self.obj_detail, true)
	self.btn_Close2:SetActive(true)

	if cell.Owner.UnitClass == EnumFight.UnitClass.ENEMY then
		GP.SpriteUtil:SetSprite(self.img_detailHead, EnemyManager:Get(cell.Owner.UnitId).data.CombatReadinessHeadIcon)

		local jobpath = "UI/PageFight/AtlasPageBattle/ICO_" .. cell.Owner.UnitData.data.Job .. "_01_S"

		GP.SpriteUtil:SetSprite(self.img_detailJob, jobpath)
		GOUtil.SetActive(self.img_detailRank, false)
	else
		local card = cell.Owner.InfoRoleCard

		if card then
			GP.SpriteUtil:SetSprite(self.img_detailHead, card.data.HeadIcon)

			local jobpath = "UI/PageFight/AtlasPageBattle/ICO_" .. cell.Owner.UnitData.data.Job .. "_01_S"

			GP.SpriteUtil:SetSprite(self.img_detailJob, jobpath)
			GOUtil.SetActive(self.img_detailRank, true)
			GP.SpriteUtil:SetSprite(self.img_detailRank, DlgUIResultAddUp.RankPic[card.data.Rank])
		end
	end

	local uid = cell.Owner.UniqueId

	if self.detailType == DlgUIResultAddUp.enDetailType.SkillCount then
		self:OnDetailSkillCount(uid)
	else
		self:OnDetailDamage(uid)
	end
end

function DlgUIResultAddUp:OnDetailSkillCount(uid)
	self.curUniqueId = uid

	if not GP.GameResultAddUpData.unitData[uid] then
		return
	end

	local skilldata = GP.GameResultAddUpData.unitData[uid].SkillDamage

	if not skilldata then
		return
	end

	local _list = {}

	for k, v in pairs(skilldata) do
		table.insert(_list, v)
	end

	table.sort(_list, function(a, b)
		return a.count < b.count
	end)

	for i, info in ipairs(_list) do
		local cell = self.cellsDetail_skill[i]

		if not cell then
			cell = CellResultAddUp_detail()

			table.insert(self.cellsDetail_skill, cell)
			self:AddChildPanelImmediately(cell)
			cell:SetParent(self.obj_detailRoot)
		end

		cell:RefreshSkill(info)
	end

	for i = #_list + 1, #self.cellsDetail_skill do
		self.cellsDetail_skill[i]:Show(false)
	end
end

function DlgUIResultAddUp:OnDetailDamage(uid)
	self.curUniqueId = uid

	if not GP.GameResultAddUpData.unitData[uid] then
		return
	end

	local _list = {}
	local skilldata = GP.GameResultAddUpData.unitData[uid].SkillDamage

	if skilldata then
		for k, v in pairs(skilldata) do
			if v.sum > 0 then
				table.insert(_list, v)
			end
		end
	end

	local buffdata = GP.GameResultAddUpData.unitData[uid].BuffDamage

	if buffdata then
		for k, v in pairs(buffdata) do
			if v.sum > 0 then
				table.insert(_list, v)
			end
		end
	end

	table.sort(_list, function(a, b)
		return a.sum < b.sum
	end)

	for i, info in ipairs(_list) do
		local cell = self.cellsDetail_skill[i]

		if not cell then
			cell = CellResultAddUp_detail()

			table.insert(self.cellsDetail_skill, cell)
			self:AddChildPanelImmediately(cell)
			cell:SetParent(self.obj_detailRoot)
		end

		cell:RefreshDamage(info, GP.GameResultAddUpData.unitData[uid].SumDamage)
	end

	for i = #_list + 1, #self.cellsDetail_skill do
		self.cellsDetail_skill[i]:Show(false)
	end
end

function DlgUIResultAddUp:OnBackAndroid()
	if GOUtil.IsActiveSelf(self.obj_detail) then
		self:OnBtnClose2()
	else
		self:OnBtnClose1()
	end
end
