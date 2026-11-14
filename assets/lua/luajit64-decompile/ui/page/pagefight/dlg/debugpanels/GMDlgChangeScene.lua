-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeScene.lua

GMDlgChangeScene = class("GMDlgChangeScene", UIPanel_sync)

function GMDlgChangeScene:ctor()
	GMDlgChangeScene.base.ctor(self, "UI/PageFight/Dlg/GMDlgChangeScene")
end

function GMDlgChangeScene:Cache()
	GMDlgChangeScene.base.Cache(self)
end

function GMDlgChangeScene:Close(tParam)
	GMDlgChangeScene.base.Close(self, tParam)
end

function GMDlgChangeScene:Purge()
	GMDlgChangeScene.base.Purge(self)

	self.list = {}
end

function GMDlgChangeScene:OnRegisterEvent()
	self:AddClick(self.touch_close, self.OnBtnClose)
end

function GMDlgChangeScene:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function GMDlgChangeScene:OnBtnClose()
	self:Close()
end

local function lastIndexOf(haystack, needle)
	local i, j
	local k = 0

	repeat
		i = j
		j, k = string.find(haystack, needle, k + 1, true)
	until j == nil

	return i
end

function GMDlgChangeScene:OnEnter(vParam)
	self.touch_close = self:GetChildGameObject("panel")
	self.list = {}

	local itemT = self:GetChildGameObject("panel/Scroll View/Viewport/Content/ItemT")
	local itemRoot = itemT.transform.parent.gameObject
	local infoTables = require("luaData/BattleStage")
	local maps = {}

	for k, cfg in pairs(infoTables) do
		if not maps[cfg.MainSceneId] then
			maps[cfg.MainSceneId] = cfg.MainSceneId
		end

		if not maps[cfg.BossSceneId] then
			maps[cfg.BossSceneId] = cfg.BossSceneId
		end
	end

	for k, id in pairs(maps) do
		local cell = {}

		cell.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)
		cell.id = id

		function cell.onClick()
			SceneMgr.GetCurrentScene():ChangeMainScene(tonumber(id))
			self:Close()
		end

		local txt = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)

		txt = GOUtil.GetComponent(txt, "Text")
		txt.text = tostring(id)

		if SceneMgr.data[id] then
			local path = SceneMgr.data[id].Resource

			if path then
				local index = lastIndexOf(path, "/")

				if index then
					local name = string.sub(path, index + 1, #path)

					txt.text = tostring(id) .. "\n" .. name
				end
			end
		end

		self:AddClick(cell.gameObject, cell.onClick)
		table.insert(self.list, cell)
	end

	GOUtil.SetActive(itemT, false)
end
