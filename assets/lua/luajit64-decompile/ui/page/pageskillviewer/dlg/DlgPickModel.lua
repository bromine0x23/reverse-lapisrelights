-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSkillViewer/Dlg/DlgPickModel.lua

DlgPickModel = class("DlgPickModel", UIPanel)

function DlgPickModel:ctor()
	DlgPickModel.base.ctor(self, "UI/PageFight/Dlg/GMDlgChangeMonster")
end

function DlgPickModel:Cache()
	DlgPickModel.base.Cache(self)
end

function DlgPickModel:Close(tParam)
	DlgPickModel.base.Close(self, tParam)
end

function DlgPickModel:Purge()
	DlgPickModel.base.Purge(self)

	self.list = {}
end

function DlgPickModel:OnRegisterEvent()
	self:AddClick(self.touch_close, self.OnBtnClose, PATH_SFX_UI_CANCEL)
end

function DlgPickModel:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end

	for i, cell in ipairs(self.Buttons) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function DlgPickModel:OnBtnClose()
	self:Show(false)
end

require("Util.EasyFilter")

local rankCfg = {
	"R",
	"SR",
	"SSR",
	"UR",
	"ALL"
}

function DlgPickModel:OnEnter()
	self.CurRank = "ALL"
	self.Buttons = {}
	self.FilterButtonT = self:GetChildGameObject("panel/Buttons/ButtonT")

	for I, item in ipairs(rankCfg) do
		local go = GOUtil.InstantiateUI(self.FilterButtonT, self:GetChildGameObject("panel/Buttons"))

		GOUtil.FindChildComponent(go, "Text", "Text").text = item

		local cell = {}

		cell.gameObject = go
		cell.Rank = item

		function cell.onClick()
			self.CurRank = cell.Rank

			self:Refresh()
		end

		self:AddClick(cell.gameObject, cell.onClick)
		table.insert(self.Buttons, cell)
	end

	self.FilterButtonT:SetActive(false)

	self.list = {}
	self.touch_close = self:GetChildGameObject("panel")
	self.itemT = self:GetChildGameObject("panel/Scroll View/Viewport/Content/ItemT")
	self.itemRoot = self.itemT.transform.parent.gameObject

	GOUtil.SetActive(self.itemT, false)

	local CharacterCardData = require("luaData/CharacterCard")

	self.CardCfgList = {}

	for k, v in pairs(CharacterCardData) do
		table.insert(self.CardCfgList, v)
	end

	for i, card in EasyFilter(self.CardCfgList):AddFilter(function(a)
		return a.Version == 1
	end):AddSorter(function(a, b)
		return a.ID < b.ID
	end):Ipairs() do
		local cell = {}

		cell.gameObject = GOUtil.InstantiateUI(self.itemT, self.itemRoot)

		cell.gameObject:SetActive(true)

		cell.card = card

		function cell.onClick()
			Event.Instance:Fire("CMD_Message", "changeMonster " .. cell.card.ID)
			SV:ReadyModel(cell.card.ID)
			self:OnBtnClose()
		end

		local txt = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)

		txt = GOUtil.GetComponent(txt, "Text")

		local weaponName = self:GetWeaponName(cell.card.CharacterID)

		if weaponName ~= "" then
			local a = 1
		end

		txt.text = weaponName .. " " .. tostring(card.ID) .. "\n" .. Lang(card.Name)

		self:AddClick(cell.gameObject, cell.onClick)
		table.insert(self.list, cell)
	end

	self:Show(false)
end

function DlgPickModel:Refresh()
	if self.CurRank == "ALL" then
		for i, cell in ipairs(self.list) do
			cell.gameObject:SetActive(true)
		end

		return
	end

	for i, cell in ipairs(self.list) do
		cell.gameObject:SetActive(false)
	end

	for i, cell in EasyFilter(self.list):AddFilter(function(a)
		return a.card.Rank == self.CurRank
	end):Ipairs() do
		cell.gameObject:SetActive(true)
	end
end

function DlgPickModel:Open()
	self:Show(true)
end

function DlgPickModel:GetWeaponName(unitId)
	local weaponName = ""
	local roleInfo = RoleMgr:GetRole(unitId)

	if not roleInfo then
		return ""
	end

	local weaponId = roleInfo:GetEquipId(eEquipSlotType.Weapon)
	local weaponData = require("luaData/Equipment")

	weaponName = weaponData[weaponId].Weapon

	return weaponName
end
