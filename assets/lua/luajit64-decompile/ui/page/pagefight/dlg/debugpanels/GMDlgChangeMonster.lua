-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeMonster.lua

GMDlgChangeMonster = class("GMDlgChangeMonster", UIPanel_sync)

function GMDlgChangeMonster:ctor()
	GMDlgChangeMonster.base.ctor(self, "UI/PageFight/Dlg/GMDlgChangeMonster")
end

function GMDlgChangeMonster:Cache()
	GMDlgChangeMonster.base.Cache(self)
end

function GMDlgChangeMonster:Close(tParam)
	GMDlgChangeMonster.base.Close(self, tParam)
end

function GMDlgChangeMonster:Purge()
	GMDlgChangeMonster.base.Purge(self)

	self.list = {}
end

function GMDlgChangeMonster:OnRegisterEvent()
	self:AddClick(self.touch_close, self.OnBtnClose)
end

function GMDlgChangeMonster:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function GMDlgChangeMonster:OnBtnClose()
	self:Close()
end

function GMDlgChangeMonster:OnEnter(vParam)
	self.list = {}
	self.touch_close = self:GetChildGameObject("panel")

	local itemT = self:GetChildGameObject("panel/Scroll View/Viewport/Content/ItemT")
	local itemRoot = itemT.transform.parent.gameObject
	local monsters = require("luaData/Monster")
	local cfgMap = {}

	for k, cfg in pairs(monsters) do
		local val = cfgMap[tostring(cfg.ActorID)]

		if not val then
			cfgMap[tostring(cfg.ActorID)] = {}
			cfgMap[tostring(cfg.ActorID)] = cfg
		end
	end

	for k, cfg in pairs(cfgMap) do
		local cell = {}

		cell.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)
		cell.cfg = cfg

		function cell.onClick()
			Event.Instance:Fire("CMD_Message", "changeMonster " .. cell.cfg.ID)
			self:Close()
		end

		local txt = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)

		txt = GOUtil.GetComponent(txt, "Text")
		txt.text = tostring(cfg.ID) .. "\n" .. Lang(cfg.Name)

		self:AddClick(cell.gameObject, cell.onClick)
		table.insert(self.list, cell)
	end

	GOUtil.SetActive(itemT, false)
end
