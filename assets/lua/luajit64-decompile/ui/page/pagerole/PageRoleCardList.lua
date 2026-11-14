-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/PageRoleCardList.lua

require("UI/UIScrollTool")
require("UI/Dlg/Common/CellRoleCard")
require("UI/Page/PageRole/PageRoleCard")

PageRoleCardList = class("PageRoleCardList", UIPanel, true)

function PageRoleCardList:ctor()
	PageRoleCardList.base.ctor(self, "UI/PanelRole/PanelRoleCardList")
	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleCardList"),
		callback = self.OnBack,
		panel = self
	})
end

function PageRoleCardList:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/Common/CellRoleCard")

	EffectMgr:PreLoad("Fx/UI/EFF_UI_Back_Main/EFF_UI_Back_Main2", 1)
	EffectMgr:PreLoad("Fx/UI/eff_ui_event_up1-3/eff_ui_event_up2", 1)
end

function PageRoleCardList:OnRegisterEvent()
	return
end

function PageRoleCardList:OnUnRegisterEvent()
	return
end

function PageRoleCardList:OnLeave()
	if self.UIScrollTool ~= nil then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self.RoleHead = nil
	self.RoleName = nil
	self.TeamIcon = nil
	self.roleId = nil
	self.infoRole = nil
	self.listRoleCard = nil
end

function PageRoleCardList:Purge()
	PageRoleCardList.base.Purge(self)

	self.PrefabCell = nil

	self:OnLeave()
end

function PageRoleCardList:OnBack()
	UIMgr.PopPanel()
end

function PageRoleCardList:OnEnter(vParam)
	local data = vParam

	self.roleId = data.roleId

	local bg = self:GetChildGameObject("Bg")

	EffectMgr:Alloc("Fx/UI/EFF_UI_Back_Main/EFF_UI_Back_Main3", bg, true)

	self.RoleHead = self:GetChildComponent("Panel/Role/HeadMask/RoleHead", "Image")
	self.RoleName = self:GetChildComponent("Panel/Role/RoleName", "Text")
	self.TeamIcon = self:GetChildComponent("Panel/Role/TeamIcon", "Image")

	self:UpdatePanel()

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listRoleCard

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellRoleCard, self, true)

	self.UIScrollTool.ScrollView.horizontalScrollbar = self:GetChildComponent("Panel/Scrollbar", "Scrollbar")
end

function PageRoleCardList:UpdatePanel()
	self.listRoleCard = RoleCardMgr:GetAllHoldRoleCard(self.roleId)

	self:DealSort()

	local infoRole = RoleMgr:GetRole(self.roleId)

	UIUtil.SetImageSprite(self.RoleHead, infoRole.actorData.CharacterIcon)

	self.RoleName.text = infoRole:GetName()

	UIUtil.SetImageSprite(self.TeamIcon, "UIDyAtlas/Team/IC_IDH_" .. infoRole.data.Team .. "00")
end

function PageRoleCardList:UpdateCell(item, index)
	local infoRoleCard = self.listRoleCard[index]
	local cardId = infoRoleCard.id
	local data = {}

	data.cardId = cardId

	item:UpdateData(data)
end

function PageRoleCardList:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function PageRoleCardList:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local infoRoleCard = self.listRoleCard[index]
	local isHold = infoRoleCard:IsHold()

	if not isHold then
		return
	end

	local data = {}

	data.cardId = infoRoleCard.id

	UIMgr.SwitchPanel(PageRoleCard, data)
end

function PageRoleCardList:DealSort()
	local function funComps(a, b)
		return RoleCardMgr:GetCompareRankAndLevel(a, b, 1)
	end

	table.sort(self.listRoleCard, funComps)
end
