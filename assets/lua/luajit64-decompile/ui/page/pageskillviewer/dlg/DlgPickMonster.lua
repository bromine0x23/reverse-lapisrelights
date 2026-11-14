-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSkillViewer/Dlg/DlgPickMonster.lua

DlgPickMonster = class("DlgPickMonster", UIPanel)

function DlgPickMonster:ctor()
	DlgPickMonster.base.ctor(self, "UI/PageFight/Dlg/GMDlgChangeMonster")
end

function DlgPickMonster:Cache()
	DlgPickMonster.base.Cache(self)
end

function DlgPickMonster:Close(tParam)
	DlgPickMonster.base.Close(self, tParam)
end

function DlgPickMonster:Purge()
	DlgPickMonster.base.Purge(self)

	self.list = {}
	self.allcfgListItem = {}
end

function DlgPickMonster:OnRegisterEvent()
	self:AddClick(self.touch_close, self.OnBtnClose, PATH_SFX_UI_CANCEL)
end

function DlgPickMonster:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end

	for i, cell in ipairs(self.allcfgListItem) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function DlgPickMonster:OnBtnClose()
	self:Show(false)
end

local rankCfg = {
	"MONTER",
	"BOSS",
	"ALL",
	"ALL_MONSTERS"
}

function DlgPickMonster:OnEnter()
	self.touch_close = self:GetChildGameObject("panel")
	self.list = {}
	self.allcfgListItem = {}
	self.IsInit = false

	self:Show(false)
end

function DlgPickMonster:Refresh()
	if self.CurRank == "ALL_MONSTERS" then
		for i, cell in ipairs(self.list) do
			cell.gameObject:SetActive(false)
		end

		for i, cell in ipairs(self.allcfgListItem) do
			cell.gameObject:SetActive(true)
		end

		return
	else
		for i, cell in ipairs(self.allcfgListItem) do
			cell.gameObject:SetActive(false)
		end
	end

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
		local rank = TenaryOp(a.cfg.Boss == 0, "MONTER", "BOSS")

		return rank == self.CurRank
	end):Ipairs() do
		cell.gameObject:SetActive(true)
	end
end

function DlgPickMonster:Open()
	self:Show(true)

	if self.IsInit == true then
		return
	end

	self.IsInit = true
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

	local itemT = self:GetChildGameObject("panel/Scroll View/Viewport/Content/ItemT")
	local itemRoot = itemT.transform.parent.gameObject
	local monsters = require("luaData/Monster")
	local cfgMap = {}

	self.allcfgList = {}
	self.allcfgListItem = {}

	for k, cfg in pairs(monsters) do
		local val = cfgMap[tostring(cfg.ActorID)]

		if not val then
			cfgMap[tostring(cfg.ActorID)] = {}
			cfgMap[tostring(cfg.ActorID)] = cfg
		end

		table.insert(self.allcfgList, cfg)
	end

	table.sort(self.allcfgList, function(a, b)
		return a.ID < b.ID
	end)

	for i, cfg in ipairs(self.allcfgList) do
		local cell = {}

		cell.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)
		cell.cfg = cfg

		function cell.onClick()
			Event.Instance:Fire("CMD_Message", "changeMonster " .. cell.cfg.ID)
			SV:ReadyMonster(cell.cfg.ID)
			self:OnBtnClose()
		end

		local txt = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)

		txt = GOUtil.GetComponent(txt, "Text")
		txt.text = tostring(cfg.ID) .. "\n" .. Lang(cfg.Name)

		self:AddClick(cell.gameObject, cell.onClick)
		table.insert(self.allcfgListItem, cell)
		GOUtil.SetActive(cell.gameObject, false)
	end

	for k, cfg in pairs(cfgMap) do
		local cell = {}

		cell.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)
		cell.cfg = cfg

		function cell.onClick()
			Event.Instance:Fire("CMD_Message", "changeMonster " .. cell.cfg.ID)
			SV:ReadyMonster(cell.cfg.ID)
			self:OnBtnClose()
		end

		local txt = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)

		txt = GOUtil.GetComponent(txt, "Text")
		txt.text = tostring(cfg.ID) .. "\n" .. Lang(cfg.Name)

		self:AddClick(cell.gameObject, cell.onClick)
		table.insert(self.list, cell)
	end

	GOUtil.SetActive(itemT, false)
end
