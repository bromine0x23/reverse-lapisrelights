-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRank/DlgRank.lua

require("UI/Page/PageRoleCard/Cell/CellCard")

local InfoPVPData = require("Info/InfoPVP")

DlgRank = class("DlgRank", UIPanel)

function DlgRank:ctor()
	DlgRank.base.ctor(self, "UI/PanelRank/DlgRank")
end

function DlgRank:Cache()
	DlgRank.base.Cache(self)
end

function DlgRank:PreLoad()
	self:LoadResAsync("UI/Common/CellCard/CellCard", "PrefabCell")
end

function DlgRank:Purge()
	DlgRank.base.Purge(self)

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	if self.UIScrollToolPanel then
		self.UIScrollToolPanel:Purge()

		self.UIScrollToolPanel = nil
	end

	if self.gCell then
		for i = 1, 5 do
			if self.gCell[i] then
				self.gCell[i]:OnLeave()
			end
		end

		self.gCell = nil
	end

	if self.DlgPreviewActor then
		self.DlgPreviewActor:Purge()

		self.DlgPreviewActor = nil
	end

	UIMgr.HideMsg2()
end

function DlgRank:Close()
	DlgRank.base.Close(self)
end

function DlgRank:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnCloseClick)
end

function DlgRank:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnCloseClick)
end

function DlgRank.RequestData(pbPlayer, isUnionBossRaid)
	LoadingMgr.Show(eLoadingType.Repeat)

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			local pbRole = vMsg.role
			local pbRoleCards = vMsg.roleCards
			local infoRole = InfoRole(pbRole.id)

			infoRole:SetData(pbRole)

			local listCard = {}

			for _, pbRoleCard in ipairs(pbRoleCards) do
				table.insert(listCard, pbRoleCard)
			end

			if #listCard == 0 then
				UIMgr.ShowMsg(_("Desc_NoTeam"))

				return
			end

			UIMgr.AddPanel(DlgRank(), {
				showRole = infoRole,
				teamCards = listCard,
				pbPlayer = pbPlayer
			})
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	if isUnionBossRaid then
		NetManager:RequestUnionBossRaidTeam(pbPlayer.playerId, 1, wrap_cb)
	else
		NetManager:RequestPvpShowTeam(pbPlayer.playerId, wrap_cb)
	end
end

function DlgRank:OnEnter(vParam)
	self.infoRole = vParam.showRole
	self.listCard = vParam.teamCards
	self.pbPlayer = vParam.pbPlayer
	self.btn_close = self:GetChildGameObject("btn_close")
	self.img_title = self:GetChildComponent("img_title/img_title", "Image")
	self.img_title = self:GetChildComponent("img_title", "Image")
	self.tex_title = self:GetChildComponent("img_title/tex_title", "Text")
	self.tex_tips = self:GetChildComponent("img_title/tex_tips", "Text")
	self.tex_title.text = _("Desc_ShareTeam")
	self.tex_tips.text = _("Desc_ClickClose")

	self:InitScrollViewPanel()
end

function DlgRank:OnBtnCloseClick()
	self:Close()
end

function DlgRank:InitScrollViewPanel()
	local ScrollArea = self:GetChildGameObject("ScrollArea")
	local content = self:GetChildComponent("ScrollArea/Content", "Transform")

	local function AddClick(item)
		return
	end

	self.gCell = {}

	local length = #self.listCard

	if length > 5 then
		length = 5
	end

	for i = 1, length do
		local item = CellCard(self.PrefabCell, content.gameObject, self)

		item:Create()

		item.UIRootObject.name = i

		item:UpdateData({
			cardId = self.listCard[i].id,
			data = self.listCard[i],
			pbPlayer = self.pbPlayer
		}, false, true, true, true, true, true)
		GOUtil.SetTransformLocalScale(item.UIRootObject, 1)

		if i <= 3 then
			GOUtil.SetRectTransformAnchoredPosition(item.UIRootObject, -507 + 252 * i, 177)
		else
			GOUtil.SetRectTransformAnchoredPosition(item.UIRootObject, -382 + 252 * (i - 3), -180)
		end

		table.insert(self.gCell, item)
	end

	self.Control = self:GetChildComponent("Role", "UI3DRenderControl")
	self.DlgPreviewActor = DlgPreviewActor()
	self.DlgPreviewActor.IsLeft = true

	self.DlgPreviewActor:Init(self.Control, false, true)
	self:UpdateShowRole()
end

function DlgRank:UpdateShowRole()
	if self.infoRole == nil then
		GOUtil.SetActive(self.Control, false)

		return
	end

	if self.DlgPreviewActor then
		self.DlgPreviewActor:LoadActor(self.infoRole, true)
	end
end
