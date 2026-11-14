-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/DlgFavorLevelAward.lua

require("UI/Page/PageInteraction/CellFavorLevelAward")

DlgFavorLevelAward = class("DlgFavorLevelAward", UIPanel)

function DlgFavorLevelAward:ctor()
	self.UIPrefabPath = "UI/PageInteraction/DlgFavorLevelAward"
end

function DlgFavorLevelAward:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PageInteraction/CellFavorLevelAward")
end

function DlgFavorLevelAward:Purge()
	self.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	self.PrefabCell = nil
end

function DlgFavorLevelAward:OnRegisterEvent()
	self:AddClick(self.BtnQuit, self.OnClickedBtnQuit, PATH_SFX_UI_CANCEL)
end

function DlgFavorLevelAward:OnUnRegisterEvent()
	self:RemoveClick(self.BtnQuit, self.OnClickedBtnQuit)
end

function DlgFavorLevelAward:OnEnter(vParam)
	if not vParam then
		return
	end

	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = vParam.title or ""
	self.infoRole = vParam.role

	if not self.infoRole then
		return
	end

	self.BtnQuit = self:GetChildGameObject("Panel/Button")

	self:Init()
end

function DlgFavorLevelAward:Init()
	self.listAward = LevelManager:GetLevelAwardList()
	self.listSkill = LevelManager:GetFavorLevelSkillList(self.infoRole.id)

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.listAward

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellFavorLevelAward, self, false)
end

function DlgFavorLevelAward:UpdateCell(item, index)
	local list = self.listAward[index]

	item:UpdateData(list, self.infoRole.pb.favorLevelRecord, self.listSkill[index])
end

function DlgFavorLevelAward:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function DlgFavorLevelAward:OnClickedCell(data)
	return
end

function DlgFavorLevelAward:OnClickedBtnQuit()
	self:Close()
end
