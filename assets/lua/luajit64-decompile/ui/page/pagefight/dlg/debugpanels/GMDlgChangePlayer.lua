-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangePlayer.lua

GMDlgChangePlayer = class("GMDlgChangePlayer", UIPanel_sync)

function GMDlgChangePlayer:ctor()
	GMDlgChangePlayer.base.ctor(self, "UI/PageFight/Dlg/GMDlgChangeMonster")
end

function GMDlgChangePlayer:Cache()
	GMDlgChangePlayer.base.Cache(self)
end

function GMDlgChangePlayer:Close(tParam)
	GMDlgChangePlayer.base.Close(self, tParam)
end

function GMDlgChangePlayer:Purge()
	GMDlgChangePlayer.base.Purge(self)

	self.list = {}
end

function GMDlgChangePlayer:OnRegisterEvent()
	self:AddClick(self.touch_close, self.OnBtnClose)
end

function GMDlgChangePlayer:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function GMDlgChangePlayer:OnBtnClose()
	self:Close()
end

function GMDlgChangePlayer:OnEnter(vParam)
	self.list = {}
	self.touch_close = self:GetChildGameObject("panel")

	local itemT = self:GetChildGameObject("panel/Scroll View/Viewport/Content/ItemT")
	local itemRoot = itemT.transform.parent.gameObject
	local cards = require("luaData/CharacterCard")
	local cfgMap = {}

	for k, cfg in pairs(cards) do
		local val = cfgMap[tostring(cfg.CharacterID)]

		if not val then
			cfgMap[tostring(cfg.CharacterID)] = {}

			table.insert(cfgMap[tostring(cfg.CharacterID)], cfg)
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
