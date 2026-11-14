-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBag/DlgItemExpireChange.lua

require("UI/Item/CellItem")

DlgItemExpireChange = class("DlgItemExpireChange", UIPanel)

function DlgItemExpireChange:ctor()
	self.UIPrefabPath = "UI/PageBag/DlgItemExpireChange"
end

function DlgItemExpireChange:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function DlgItemExpireChange:Purge()
	DlgItemExpireChange.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellItem)

	for _, v in pairs(self.listItem) do
		if v then
			v:OnLeave()
		end
	end
end

function DlgItemExpireChange:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnButtonQuit, PATH_SFX_UI_CANCEL)
end

function DlgItemExpireChange:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnButtonQuit)
end

function DlgItemExpireChange:OnButtonQuit()
	self:Close()
end

function DlgItemExpireChange:OnEnter(vParam)
	self.listItem = {}
	self.ButtonQuit = self:GetChildGameObject("Panel/ButtonQuit")

	local listNormal = vParam.listNormal
	local listExchange = vParam.listExchange

	self:UpateList("GroupItem", listNormal)
	self:UpateList("GroupExchange", listExchange)
	Event.Instance:Fire("UpdateBag")

	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Title/Text/", "Text")
	TextAuto.text = Lang(5000047)
	TextAuto = self:GetChildComponent("Panel/Bg/Text/", "Text")
	TextAuto.text = Lang(5000052)
	TextAuto = self:GetChildComponent("Panel/Bg/Text2/", "Text")
	TextAuto.text = Lang(5000053)
end

function DlgItemExpireChange:UpateList(path, list)
	local ScrollArea = self:GetChildGameObject("Panel/" .. path .. "/ScrollArea")
	local ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")

	ScrollView.horizontal = true
	ScrollView.content = self:GetChildComponent("Panel/" .. path .. "/ScrollArea/Content", "Transform")

	local count = #list

	for i = 1, count do
		local s = list[i]

		if s.asset == protocol_pb.RC_RECEIVE or s.asset == protocol_pb.I_SOUL then
			table.insert(self.listRoleCard, s)
		end

		if s.num < 0 then
			s.num = -s.num
		end

		local infoItem = SetterData.GetItemFromAsset(s)

		if infoItem ~= nil then
			local item = CellItem(self.PrefabCellItem, ScrollView.content.gameObject, self)

			item:Create()
			item:UpdateData(i, infoItem, false)
			item:OnLeave()

			item.noClick = true

			local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

			scrollviewContent.scrollView = ScrollView

			table.insert(self.listItem, item)
		end
	end
end
