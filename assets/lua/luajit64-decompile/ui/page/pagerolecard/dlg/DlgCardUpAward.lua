-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgCardUpAward.lua

require("UI/Page/PageRoleCard/Cell/CellCardUpAward")

DlgCardUpAward = class("DlgCardUpAward", UIPanel)

function DlgCardUpAward:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/DlgCardUpAward"
end

function DlgCardUpAward:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PanelRoleCard/CellCardUpAward")
end

function DlgCardUpAward:Purge()
	self.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	ResourceMgr.Unload(self.PrefabCell)
end

function DlgCardUpAward:OnRegisterEvent()
	self:AddClick(self.BtnQuit, self.OnClickedBtnQuit, PATH_SFX_UI_CANCEL)
	Event.Instance:Add("UpdateAwardList", self.UpdateAwardList, self)
end

function DlgCardUpAward:OnUnRegisterEvent()
	self:RemoveClick(self.BtnQuit, self.OnClickedBtnQuit)
	Event.Instance:Remove("UpdateAwardList", self.UpdateAwardList, self)
end

function DlgCardUpAward:OnEnter(vParam)
	if not vParam or not vParam.infoRoleCard or not vParam.type then
		return
	end

	self.infoRoleCard = vParam.infoRoleCard
	self.aType = vParam.type

	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = vParam.title or ""
	self.BtnQuit = self:GetChildGameObject("Panel/Button")

	self:Init()
end

function DlgCardUpAward:Init()
	self.listAward = {}

	local list = RoleCardMgr:GetAward(self.infoRoleCard, self.aType)
	local max = #list

	if self.aType == 1 then
		max = self.infoRoleCard.maxStarLevel

		if max > #list and not max then
			-- block empty
		end
	end

	for i = 1, max do
		local temp = {
			list = list[i].award,
			index = list[i].index
		}

		table.insert(self.listAward, temp)
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.listAward

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellCardUpAward, self, false)
end

function DlgCardUpAward:UpdateCell(item, index)
	local list = self.listAward[index]

	item:UpdateData(self.infoRoleCard, list, self.aType)
end

function DlgCardUpAward:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function DlgCardUpAward:OnClickedCell(data)
	return
end

function DlgCardUpAward:UpdateAwardList()
	self.UIScrollTool:UpdateListDataKeepPos(self.listAward)

	if self.aType == 1 then
		Event.Instance:Fire("UpdateStarAward")
	else
		Event.Instance:Fire("UpdatePetalAward")
	end
end

function DlgCardUpAward:OnClickedBtnQuit()
	self:Close()
end
