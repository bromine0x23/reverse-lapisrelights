-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeSession.lua

GMDlgChangeSession = class("GMDlgChangeSession", UIPanel_sync)

function GMDlgChangeSession:ctor()
	GMDlgChangeSession.base.ctor(self, "UI/PageFight/Dlg/GMDlgChangeSession")
end

function GMDlgChangeSession:Cache()
	GMDlgChangeSession.base.Cache(self)
end

function GMDlgChangeSession:Close(tParam)
	GMDlgChangeSession.base.Close(self, tParam)
end

function GMDlgChangeSession:Purge()
	GMDlgChangeSession.base.Purge(self)

	self.btnDataMap = {}
end

function GMDlgChangeSession:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose)
	self:AddClick(self.touch_close, self.OnBtnClose)

	for i, go in ipairs(self.btnGoList) do
		self:AddClick(go, self.OnChangeSession)
	end
end

function GMDlgChangeSession:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnClose)
	self:RemoveClick(self.touch_close, self.OnBtnClose)

	for i, go in ipairs(self.btnGoList) do
		self:RemoveClick(go, self.OnChangeSession)
	end
end

function GMDlgChangeSession:OnBtnClose()
	self:Close()
end

function GMDlgChangeSession:OnEnter(vParam)
	self.touch_close = self:GetChildGameObject("panel")
	self.btnGoList = {}

	local _data = {
		1,
		2,
		3,
		4
	}

	self.btnDataMap = {}
	self.btn_close = self:GetChildGameObject("panel/btn_close")

	local root = self:GetChildGameObject("panel/skills_player")

	for i = 1, root.transform.childCount do
		local go = root.transform:GetChild(i - 1).gameObject

		table.insert(self.btnGoList, go)

		self.btnDataMap[go.name] = _data[i]
	end
end

function GMDlgChangeSession:OnChangeSession(data)
	local clickGo = data.pointerPress.gameObject
	local val = self.btnDataMap[clickGo.name]

	if val then
		Event.Instance:Fire("CMD_Message", "changesession " .. val)
	end
end
