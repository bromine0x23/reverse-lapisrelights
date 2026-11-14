-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/DlgChooseCard.lua

require("UI/Dlg/Common/CellRoleCard")

DlgChooseCard = class("DlgChooseCard", UIPanel)

function DlgChooseCard:ctor()
	self.UIPrefabPath = "UI/PanelRole/DlgChooseCard"
	self.close_cb = nil
	self.enter_cb = nil
end

function DlgChooseCard:PreLoad()
	self:LoadResAsync("UI/Common/CellCard/CellRoleCard", "PrefabCell", GameObject)
end

function DlgChooseCard:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self.close_cb = nil
	self.enter_cb = nil

	UIMgr.RemoveUpdatePanel(self)
	System.GC.Collect()
end

function DlgChooseCard:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgChooseCard:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgChooseCard:OnEnter(vParam)
	UIMgr.SetUpdatePanel(self)
	self:DealWithLocalization()

	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.GoPanel = self:GetChildGameObject("Panel")

	if not vParam or not vParam.infoRole then
		return
	end

	self.infoRole = vParam.infoRole
	self.preEquipCardId = self.infoRole.pb.roleCardId or 0
	self.close_cb = vParam.callback
	self.enter_cb = vParam.panelCb

	if self.enter_cb then
		self.enter_cb()

		self.enter_cb = nil
	end

	self.updated = false

	self:InitScrollViewRoleCard()
end

function DlgChooseCard:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/ImgTitle/Text", "Text")
	txt.text = _("PageRole_Equip_Card")
end

function DlgChooseCard:OnUpdate()
	if self.updated then
		UIMgr.RemoveUpdatePanel(self)

		return
	end

	local panelScale = GOUtil.GetTransformLocalScale(self.GoPanel, x, y, z)

	if panelScale == 1 and self.UIScrollTool then
		self.updated = true

		self.UIScrollTool:UpdateListData(self.listAllCard)
	end
end

function DlgChooseCard:InitScrollViewRoleCard()
	self.listAllCard = RoleCardMgr:GetRoleAllCard(self.infoRole.id)

	CardSortMgr.CardOtherSort(CardSortMgr.SORT_TYPES.LEVEL, CardSortMgr.SORT_TYPES.RANK, self.listAllCard)

	for k, v in ipairs(self.listAllCard) do
		if v:IsHold() and self.preEquipCardId == v.id then
			self.curIndex = k
		end
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.listAllCard

	local function addCallback()
		return
	end

	local function updateCallback(item, index)
		item:UpdateData(self.listAllCard[index])
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellRoleCard, self, true, addCallback, updateCallback)
end

function DlgChooseCard:SetEquipCard(index)
	local infoRoleCard = self.listAllCard[index]

	if not infoRoleCard:IsHold() or infoRoleCard.id == self.infoRole.pb.roleCardId then
		return
	end

	local preIdx = self.curIndex

	self.curIndex = index

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.UIScrollTool:UpdateCellSelect(preIdx, self.curIndex)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestEquipCard(self.listAllCard[self.curIndex].id, wrap_cb)
end

function DlgChooseCard:OnClickedBtnClose()
	if self.close_cb then
		self.close_cb()

		self.close_cb = nil
	end

	if self.preEquipCardId ~= self.infoRole.pb.roleCardId then
		Event.Instance:Fire("UpdateRoleEquipedCard")
	end

	self:Close()
end
