-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/PageFightDebug_Cmd.lua

local datas = {
	{
		cmd = "paddbuffa,",
		title = "1番目のバフ"
	},
	{
		cmd = "paddbuffa,",
		title = "1番目のバフ"
	}
}
local mt = {}

function mt:Init(go, data)
	self.gameObject = go
	self.button = GOUtil.FindGameObjectByName("btn_cmdConfirm", self.gameObject)
	self.txt_title = GOUtil.FindGameObjectByName("Text", self.gameObject)
	self.input = GOUtil.FindGameObjectByName("InputField", self.gameObject)
	self.txt_title.text = data.title
	self.data = data

	EventListenerMgr.AddUIListener(self.button, self.OnClick, self, EventTriggerType.PointerClick)
end

function mt:OnClick()
	Event.Instance:Fire("CMD_Message", self.data.cmd .. self.input.text)
end

function mt:Purge()
	EventListenerMgr.RemoveUIListener(self.button, self.OnClick, self, EventTriggerType.PointerClick)
end

PageFightDebug_Cmd = {}

function PageFightDebug_Cmd:Init(obj)
	self.gameObject = obj
	self.itemT = GOUtil.FindGameObjectByName("Viewport/Content/itemT", self.gameObject)

	self.itemT:SetActive(false)

	self.items = {}
end

function PageFightDebug_Cmd:Purge()
	return
end

function PageFightDebug_Cmd:CreateItems()
	local obj = GOUtil.InstantiateUI(self.itemT, self.itemT.parent.gameObject)

	for data in ipairs(datas) do
		local item = setmetatable({}, {
			__index = mt
		})

		item:Init(obj, data)
		table.insert(self.items, item)
	end
end
