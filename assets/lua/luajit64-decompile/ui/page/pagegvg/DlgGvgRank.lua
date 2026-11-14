-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgRank.lua

require("UI/Page/PageGvg/CellGvgRank")

DlgGvgRank = class("DlgGvgRank", UIPanel)
DlgGvgRank.rankType = 7

function DlgGvgRank:ctor()
	self.UIPrefabPath = "UI/PageGvg/DlgGvgRank"

	self:AddChildPanel(DlgExit(), {
		title = Lang(5000106),
		callback = self.OnBack,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function DlgGvgRank:Cache()
	DlgGvgRank.base.Cache(self)
end

function DlgGvgRank:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PageGvg/CellGvgRank")
end

function DlgGvgRank:OnBack()
	UIMgr.PopPanel(self.popstep)
end

function DlgGvgRank:Purge()
	DlgGvgRank.base.Purge(self)
	UITweenUtil.RemoveTween(self.tagGroup.transform)

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)
	end

	if self.UIScrollToolPanel then
		self.UIScrollToolPanel:Purge()

		self.UIScrollToolPanel = nil
	end

	UnloadAllImageSprite(self)
end

function DlgGvgRank:Close()
	DlgGvgRank.base.Close(self)
end

function DlgGvgRank:OnRegisterEvent()
	for i = 1, 2 do
		self:AddClick(self["BtnTag" .. i], self.OnClickedChangeTag)
		self:AddClick(self["BtnTagSel" .. i], self.OnClickedSelectTag)
	end

	Event.Instance:Add("EVENT_GVG_RANK", self.OnRank, self)
	Event.Instance:Add("EVENT_GVG_CONTRIBUTION", self.OnContribution, self)
	Event.Instance:Add("EVENT_GVG_CHECK_UNION", self.OnCheckUnion, self)
	Event.Instance:Add("EVENT_GVG_CHECK_TEAM", self.OnCheckTeam, self)
end

function DlgGvgRank:OnUnRegisterEvent()
	for i = 1, 2 do
		self:RemoveClick(self["BtnTag" .. i], self.OnClickedChangeTag)
		self:RemoveClick(self["BtnTagSel" .. i], self.OnClickedSelectTag)
	end

	Event.Instance:Remove("EVENT_GVG_RANK", self.OnRank, self)
	Event.Instance:Remove("EVENT_GVG_CONTRIBUTION", self.OnContribution, self)
	Event.Instance:Remove("EVENT_GVG_CHECK_UNION", self.OnCheckUnion, self)
	Event.Instance:Remove("EVENT_GVG_CHECK_TEAM", self.OnCheckTeam, self)
end

function DlgGvgRank:OnEnter(popstep)
	self.popstep = popstep
	self.tagGroup = self:GetChildGameObject("TagGroup")

	for i = 1, 2 do
		self["tab_go" .. i] = GOUtil.FindChildGameObject(self.tagGroup, i)
		self["BtnTag" .. i] = GOUtil.FindChildGameObject(self.tagGroup, i .. "/Btn")
		self["BtnTagSel" .. i] = GOUtil.FindChildGameObject(self.tagGroup, i .. "/Select")

		SetActiveFunc(self["BtnTag" .. i], true)
		SetActiveFunc(self["BtnTagSel" .. i], false)

		self["TexTag" .. i] = GOUtil.FindChildComponent(self.tagGroup, i .. "/Btn/Text", "Text")
		self["TexTagSel" .. i] = GOUtil.FindChildComponent(self.tagGroup, i .. "/Select/Text", "Text")
	end

	self.curIndex = 1

	SetActiveFunc(self.BtnTag1, false)
	SetActiveFunc(self.BtnTagSel1, true)

	self["TexTag" .. 1].text = _("Desc_rank_gvg_union")
	self["TexTagSel" .. 1].text = _("Desc_rank_gvg_union")
	self["TexTag" .. 2].text = _("Desc_rank_gvg_player")
	self["TexTagSel" .. 2].text = _("Desc_rank_gvg_player")
	self.UIScrollContent = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	self.Panel = self:GetChildGameObject("Panel")
	self.PanelRect = self:GetChildComponent("Panel", "Transform")
	self.UIScrollToolPanel = UIScrollTool()
	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	self.GoEmpey = self:GetChildGameObject("Panel/Tex_unList")
	self.GoMyRank = CellGvgRank(self.PrefabCell, self:GetChildGameObject("GoMyRank"))

	self.GoMyRank:Create()

	self.GoMyRank.UIRootObject.transform.localPosition = Vector3.zero

	Infogvg.net:RequestRank()
end

function DlgGvgRank:OnClickedSelectTag(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	for i = 1, 2 do
		SetActiveFunc(self["BtnTag" .. i], true)
		SetActiveFunc(self["BtnTagSel" .. i], false)
	end

	SetActiveFunc(self["BtnTag" .. index], false)
	SetActiveFunc(self["BtnTagSel" .. index], true)

	self.curIndex = index

	if index == 1 then
		Infogvg.net:RequestRank()
	else
		Infogvg.net:RequestContribution()
	end
end

function DlgGvgRank:OnClickedChangeTag(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	for i = 1, 2 do
		SetActiveFunc(self["BtnTag" .. i], true)
		SetActiveFunc(self["BtnTagSel" .. i], false)
	end

	SetActiveFunc(self["BtnTag" .. index], false)
	SetActiveFunc(self["BtnTagSel" .. index], true)

	if self.curIndex == index then
		return
	end

	self.curIndex = index

	if index == 1 then
		Infogvg.net:RequestRank()
	else
		Infogvg.net:RequestContribution()
	end
end

function DlgGvgRank:OnClickedLookUnion()
	require("UI/Page/DlgGvgRank/DlgUnionBossRank")
	UIMgr.AddPanel(DlgUnionBossRank(), {
		ismy = true,
		info = UnionMgr.releUnion
	})
end

function DlgGvgRank:RefreshRank()
	local datas = Infogvg.rank.billboard_rank
	local count = #datas

	local function onAdd(item)
		item:BillboardRank()
	end

	local function onUpdate(item, index)
		local data = datas[index]

		item:Rank(data)
	end

	GOUtil.SetActive(self.GoEmpey, count == 0)
	self.UIScrollToolPanel:InitList(self.ScrollArea, self.UIScrollContent, count, self.PrefabCell, CellGvgRank, self, false, onAdd, onUpdate)
	self.UIScrollToolPanel:UpdateListData(datas)
	self.GoMyRank:Rank(Infogvg.rank.own_rank)
	self.GoMyRank:OwnRank()
end

function DlgGvgRank:RefreshContribution()
	local datas = Infogvg.rank.billboard_contribution
	local count = #datas

	local function onAdd(item)
		item:BillboardContribution()
	end

	local function onUpdate(item, index)
		local data = datas[index]

		item:Contribution(data)
	end

	GOUtil.SetActive(self.GoEmpey, count == 0)
	self.UIScrollToolPanel:InitList(self.ScrollArea, self.UIScrollContent, count, self.PrefabCell, CellGvgRank, self, false, onAdd, onUpdate)
	self.UIScrollToolPanel:UpdateListData(datas)
	self.GoMyRank:Contribution(Infogvg.rank.own_contribution)
	self.GoMyRank:OwnContribution()
end

function DlgGvgRank:OnRank()
	self:RefreshRank()
end

function DlgGvgRank:OnContribution()
	self:RefreshContribution()
end

function DlgGvgRank:OnCheckUnion(union)
	if union then
		require("UI/Page/PageRank/DlgUnionBossRank")

		local data = {}

		data.pb = union

		UIMgr.AddPanel(DlgUnionBossRank(), {
			ismy = false,
			info = data
		}, self.UIRootObject)
	end
end

function DlgGvgRank:OnCheckTeam(pbPlayer)
	if not pbPlayer then
		return
	end

	require("UI/Page/PageRank/DlgRank")

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

			UIMgr.AddPanel(DlgRank(), {
				showRole = infoRole,
				teamCards = listCard,
				pbPlayer = pbPlayer
			}, self.UIRootObject)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGvgShowTeam(pbPlayer.playerId, wrap_cb)
end
