-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgPhase.lua

DlgPhase = class("DlgPhase", UIPanel)

require("UI/Page/PageCombatReadiness/CellMonster")

function DlgPhase:ctor()
	self.UIPrefabPath = "UI/Common/DlgPhase/DlgPhase"
end

function DlgPhase:PreLoad()
	self:LoadResAsync("UI/PanelCombatReadiness/CellMonster", "PrefabMonster")
end

function DlgPhase:Purge()
	DlgPhase.base.Purge(self)
	self:OnLeave()

	if self.UIScrollToolMonster then
		self.UIScrollToolMonster:Purge()
	end

	if self.PrefabMonster then
		ResourceMgr.Unload(self.PrefabMonster)

		self.PrefabMonster = nil
	end
end

function DlgPhase:OnLeave()
	self.Button = nil
end

function DlgPhase:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClickedBtn)
end

function DlgPhase:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClickedBtn)
end

function DlgPhase:OnEnter(vParam)
	self.listMonster = vParam.infoStage.listMonster

	local recommendJob = vParam.recommendJob
	local textTitle = self:GetChildComponent("Panel/BgTitle/Text", "Text")

	textTitle.text = _("DlgPhase_Counter_Job")
	self.Button = self:GetChildGameObject("Panel/Button")
	self.ScrollArea = self:GetChildGameObject("Panel/Image2/ScrollArea")
	self.content = self:GetChildComponent("Panel/Image2/ScrollArea/Content", "Transform")
	self.job = self:GetChildComponent("Panel/Image1/job", "Image")

	SetImageSprite(self.job, "UIDyAtlas/RoleJob/IC_" .. recommendJob .. "_02_cn", self)

	local Text = self:GetChildComponent("Panel/Image2/Text", "Text")

	Text.text = ""

	local count = #self.listMonster

	local function AddClick(item)
		return
	end

	local function CellUpdate(item, index)
		local data = self.listMonster[index]

		item:UpdateData(data, index, vParam.infoStage)
	end

	self.UIScrollToolMonster = UIScrollTool()

	self.UIScrollToolMonster:InitList(self.ScrollArea, self.content, count, self.PrefabMonster, CellMonster, self, true, AddClick, CellUpdate)
end

function DlgPhase:OnClickedBtn()
	self:Close()
end
