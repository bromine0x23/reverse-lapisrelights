-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/DlgHistory.lua

require("UI/Page/PageCommunication/CellLine")

DlgHistory = class("DlgHistory", UIPanel, true)

function DlgHistory:ctor()
	self.UIPrefabPath = "UI/PageCommunication/DlgHistory"
end

function DlgHistory:PreLoad()
	self:LoadResAsync("UI/PageCommunication/CellLine", "PrefabCell")
end

function DlgHistory:Purge()
	DlgHistory.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)
	end

	ResourceMgr.Unload(self.PrefabCell)
end

function DlgHistory:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnClickedQuit, PATH_SFX_UI_CANCEL)
	Event.Instance:Add("DlgHistoryPlayVoice", self.PlayVoice, self)
	Event.Instance:Add("OnPhoneCallEnd", self.Close, self)
end

function DlgHistory:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnClickedQuit)
	Event.Instance:Remove("DlgHistoryPlayVoice", self.PlayVoice, self)
	Event.Instance:Remove("OnPhoneCallEnd", self.Close, self)
end

function DlgHistory:OnEnter(roleId)
	self.roleId = roleId
	self.ButtonQuit = self:GetChildGameObject("Panel/Close")

	self:DealWithLocalization()
	self:InitData()
	self:InitScrollView()
end

function DlgHistory:DealWithLocalization()
	return
end

function DlgHistory:InitData()
	self.infoList = ListToTable(ScenarioKit.Instance.UI.History.Datas)
end

function DlgHistory:OnClickedQuit()
	self:Close()
end

function DlgHistory:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.infoList

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCell, CellLine, self, false)

	self.timer = TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		self.UIScrollTool:SetFinalPos()
	end, self)
end

function DlgHistory:UpdateCell(item, index)
	item:UpdateData(self.infoList[index])
end

function DlgHistory:AddCellClick(item)
	return
end

function DlgHistory:PlayVoice(event)
	ScenarioKit.Instance.Sounds:PlayVoice(event)
end
