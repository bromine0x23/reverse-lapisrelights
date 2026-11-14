-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBondage/DlgBondageSkillSelect.lua

require("UI/Page/PageBondage/CellCombinationSkill")
require("UI/Page/PageBondage/DlgBondageSkillTip")

DlgBondageSkillSelect = class("DlgBondageSkillSelect", UIPanel)

function DlgBondageSkillSelect:ctor()
	self.base.ctor(self, "UI/PanelBondage/DlgBondageSkillSelect")
end

function DlgBondageSkillSelect:PreLoad()
	self:LoadResAsync("UI/PanelBondage/CellCombinationSkill", "PrefabCell")
end

function DlgBondageSkillSelect:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)
	self:OnLeave()
	BondageRDL.RemoveAllBondageUnlock()
end

function DlgBondageSkillSelect:OnLeave()
	if self.listCell then
		for i = 1, #self.listCell do
			self.listCell[i]:OnLeave()
		end

		self.listCell = nil
	end
end

function DlgBondageSkillSelect:OnRegisterEvent()
	self:AddClick(self.BtnUnload, self.OnClickedBtnUnload)
	self:AddClick(self.BtnChange, self.OnClickedBtnChange)
	self:AddClick(self.Button, self.OnClickedBtnClose)
	Event.Instance:Add("ShowSkillTip", self.ShowSkillTip, self)
end

function DlgBondageSkillSelect:OnUnRegisterEvent()
	self:RemoveClick(self.BtnUnload, self.OnClickedBtnUnload)
	self:RemoveClick(self.BtnChange, self.OnClickedBtnChange)
	self:RemoveClick(self.Button, self.OnClickedBtnClose)
	Event.Instance:Remove("ShowSkillTip", self.ShowSkillTip, self)
end

function DlgBondageSkillSelect:OnEnter(vParam)
	self:DealWithLocalization()

	self.BtnUnload = self:GetChildGameObject("Panel/Group/BtnUnload")
	self.BtnChange = self:GetChildGameObject("Panel/Group/BtnChange")
	self.Button = self:GetChildGameObject("Panel/Button")
	self.GoNoUse = self:GetChildGameObject("Panel/TxtNone")

	self:Init(vParam)
end

function DlgBondageSkillSelect:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = _("Desc_Bondage_Select")
	Text = self:GetChildComponent("Panel/TxtNone", "Text")
	Text.text = _("Msg_Bondage_Useful_None")
	Text = self:GetChildComponent("Panel/TxtPrompt", "Text")
	Text.text = _("Desc_FetterActivationCondition")
	Text = self:GetChildComponent("Panel/Group/BtnUnload/Text", "Text")
	Text.text = Lang(5000012)
	Text = self:GetChildComponent("Panel/Group/BtnChange/Text", "Text")
	Text.text = Lang(12302)
end

function DlgBondageSkillSelect:Init(data)
	self.teamSystemAgent = data
	self.selCombId = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex].fetterTeamId
	self.listComb = CombBondageMgr:GetEnabledBondageCombList()

	GOUtil.SetActive(self.BtnUnload, #self.listComb <= 0)

	if #self.listComb <= 0 then
		GOUtil.SetActive(self.BtnChange, false)
		GOUtil.SetActive(self.BtnUnload, false)

		return
	end

	self.selIndex = 1

	for i = 1, #self.listComb do
		if self.listComb[i].id == self.selCombId then
			self.selIndex = i
		end
	end

	self:UpdateBtn()
	self:InitCombinationBondage()
end

function DlgBondageSkillSelect:UpdateBtn()
	local curSelId = self.listComb[self.selIndex].id

	GOUtil.SetActive(self.BtnChange, self.selCombId ~= curSelId)
	GOUtil.SetActive(self.BtnUnload, self.selCombId ~= 0)
end

function DlgBondageSkillSelect:InitCombinationBondage()
	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")

	GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	local content = self:GetChildGameObject("Panel/ScrollArea/Content")

	self.listCell = {}

	for i = 1, #self.listComb do
		local cell = CellCombinationSkill(self.PrefabCell, content, self)

		cell:Create()

		cell.UIRootObject.name = i

		self:AddClick(cell.UIRootObject, self.OnClickedCombination)
		table.insert(self.listCell, cell)
	end

	self:UpdateCellCombinationSkill()
end

function DlgBondageSkillSelect:UpdateCellCombinationSkill()
	if not self.listCell then
		return
	end

	local teamIdx = self.teamSystemAgent.teamIndex
	local teamAgent = self.teamSystemAgent.teamList[teamIdx]
	local listRoleId = {}

	local function fun(infoRoleCard)
		local roleId = infoRoleCard.data.CharacterID
		local isHave = false

		for _, v in ipairs(listRoleId) do
			if roleId == v then
				isHave = true

				break
			end
		end

		if not isHave then
			table.insert(listRoleId, roleId)
		end
	end

	for _, v in pairs(teamAgent.slotList) do
		if v.upInfoRoleCard then
			fun(v.upInfoRoleCard)
		end

		if v.addInfoRoleCard then
			fun(v.addInfoRoleCard)
		end
	end

	for i = 1, #self.listComb do
		local cell = self.listCell[i]
		local infoComb = self.listComb[i]
		local data = {
			info = infoComb,
			battleNum = CombinationMgr:GetCombRoleNumByRoleList(infoComb.id, listRoleId)
		}

		cell:UpdateData(data)

		if tonumber(cell.UIRootObject.name) == self.selIndex then
			cell:UpdateSelectState(true)
		end
	end
end

function DlgBondageSkillSelect:OnClickedCombination(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)

	if self.selIndex == index then
		return
	end

	local preIdx = self.selIndex

	self.selIndex = index

	if self.listCell[preIdx] then
		self.listCell[preIdx]:UpdateSelectState(false)
	end

	if self.listCell[index] then
		self.listCell[index]:UpdateSelectState(true)
	end

	BondageRDL.RemoveBondageUnlock(self.listComb[preIdx].id)
	self:UpdateBtn()
end

function DlgBondageSkillSelect:OnClickedBtnChange()
	local curSelCombId = self.listComb[self.selIndex].id

	if self.selCombId == curSelCombId then
		UIMgr.ShowMsg(_("Desc_Equiped"))

		return
	end

	local list = CombBondageMgr:GetUnlockSkillByCombId(curSelCombId)

	if #list == 0 then
		UIMgr.ShowMsg(_("Msg_Bondage_Unlock_SKill_None"))

		return
	end

	local infoComb = self.listComb[self.selIndex]
	local rNum = math.random(1, #infoComb.listRole)
	local role = infoComb.listRole[rNum]

	if role then
		InfoSoundEventMgr:LoadBank(role.data.VocalBank)
		InfoSoundEventMgr:Play("VocalTeam", role.data.VocalTeam)
	end

	Event.Instance:Fire("TeamBondageChange", curSelCombId)
	self:Close()
end

function DlgBondageSkillSelect:OnClickedBtnUnload()
	Event.Instance:Fire("TeamBondageChange", 0)
	self:Close()
end

function DlgBondageSkillSelect:ShowSkillTip(data)
	UIMgr.AddPanel(DlgBondageSkillTip(), data)
end

function DlgBondageSkillSelect:OnClickedBtnClose()
	self:Close()
end
