-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/DlgRaidBuff.lua

require("UI/Page/PageUnionRaid/CellRaidBuff")

DlgRaidBuff = class("DlgRaidBuff", UIPanel)

function DlgRaidBuff:ctor()
	self.UIPrefabPath = "UI/PanelUnionRaid/DlgRaidBuff"
end

function DlgRaidBuff:PreLoad()
	self:LoadResAsync("UI/PanelUnionRaid/CellRaidBuff", "PrefabCellRaidBuff", GameObject)
end

function DlgRaidBuff:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellRaidBuff)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgRaidBuff:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClcikedBtnClose)
	Event.Instance:Add("UpdateRaidSystem", self.Close, self)
end

function DlgRaidBuff:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClcikedBtnClose)
	Event.Instance:Remove("UpdateRaidSystem", self.Close, self)
end

function DlgRaidBuff:OnEnter()
	self:DealWithLocalization()

	self.GoPrompt = self:GetChildGameObject("Panel/Text")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")

	self:Init()
end

function DlgRaidBuff:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/Title/Text", "Text")

	txt.text = _("Desc_Addition_Hold")
	txt = self:GetChildComponent("Panel/Text", "Text")
	txt.text = _("Desc_Addition_Buff_None")
	txt = self:GetChildComponent("Panel/GoTip/Text", "Text")
	txt.text = _("ClubMirror_BuffTip_1")
end

function DlgRaidBuff:Init()
	local listBuffRecord = UnionRaidMgr.GetCanUseBuff()

	if #listBuffRecord == 0 then
		GOUtil.SetActive(self.GoPrompt, true)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/BgScroll/ScrollArea")
	local content = GOUtil.FindChildComponent(scrollArea, "Content", "Transform")
	local count = #listBuffRecord

	local function addCallback()
		return
	end

	local function updateCallback(item, index)
		item:UpdateData(listBuffRecord[index])
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellRaidBuff, CellRaidBuff, self, false, addCallback, updateCallback)
end

function DlgRaidBuff:OnClcikedBtnClose()
	self:Close()
end
