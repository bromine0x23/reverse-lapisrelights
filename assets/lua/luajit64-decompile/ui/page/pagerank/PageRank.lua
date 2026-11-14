-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRank/PageRank.lua

require("UI/Page/PageRank/CellRank")
require("UI/Page/PageFriend/DlgOpPlayer")
require("UI/Page/PageGvg/CellGvgRank")

PageRank = class("PageRank", UIPanel)

function PageRank:ctor()
	self.UIPrefabPath = "UI/PanelRank/PanelRank"

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

function PageRank:Cache()
	PageRank.base.Cache(self)
end

function PageRank:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PanelRank/CellRank")
	self.PrefabCellGvg = ResourceMgr.LoadSync("UI/PageGvg/CellGvgRank")
end

function PageRank:OnBack()
	UIMgr.PopPanel()
end

function PageRank:Purge()
	PageRank.base.Purge(self)
	UITweenUtil.RemoveTween(self.tagGroup.transform)

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)
	end

	if self.PrefabCellGvg then
		ResourceMgr.Unload(self.PrefabCellGvg)
	end

	if self.UIScrollToolPanel then
		self.UIScrollToolPanel:Purge()

		self.UIScrollToolPanel = nil
	end

	if self.UIScrollToolGvg then
		self.UIScrollToolGvg:Purge()

		self.UIScrollToolGvg = nil
	end

	UnloadAllImageSprite(self)
end

function PageRank:Close()
	PageRank.base.Close(self)
end

function PageRank:OnRegisterEvent()
	for i = 1, 8 do
		self:AddClick(self["BtnTag" .. i], self.OnClickedChangeTag)
		self:AddClick(self["BtnTagSel" .. i], self.OnClickedSelectTag)
	end

	self:AddClick(self.btn_look_my, self.OnClickedLook)
	self:AddClick(self.btn_look_union, self.OnClickedLookUnion)
	Event.Instance:Add("DlgUnionBossRankEvent", self.DlgUnionBossRankEvent, self)
	Event.Instance:Add("SetRankViewPosYEvent", self.SetRankViewPosY, self)
	Event.Instance:Add("EVENT_GVG_MAINTAIN", self.OnGvgMaintain, self)
	Event.Instance:Add("EVENT_GVG_RANK", self.OnGvgRank, self)
	Event.Instance:Add("EVENT_GVG_CONTRIBUTION", self.OnGvgContribution, self)
	Event.Instance:Add("EVENT_GVG_CHECK_UNION", self.OnCheckUnion, self)
	Event.Instance:Add("EVENT_GVG_CHECK_TEAM", self.OnCheckTean, self)
end

function PageRank:OnUnRegisterEvent()
	for i = 1, 8 do
		self:RemoveClick(self["BtnTag" .. i], self.OnClickedChangeTag)
		self:RemoveClick(self["BtnTagSel" .. i], self.OnClickedSelectTag)
	end

	self:RemoveClick(self.btn_look_my, self.OnClickedLook)
	self:AddClick(self.btn_look_union, self.OnClickedLookUnion)
	Event.Instance:Remove("DlgUnionBossRankEvent", self.DlgUnionBossRankEvent, self)
	Event.Instance:Remove("SetRankViewPosYEvent", self.SetRankViewPosY, self)
	Event.Instance:Remove("EVENT_GVG_MAINTAIN", self.OnGvgMaintain, self)
	Event.Instance:Remove("EVENT_GVG_RANK", self.OnGvgRank, self)
	Event.Instance:Remove("EVENT_GVG_CONTRIBUTION", self.OnGvgContribution, self)
	Event.Instance:Remove("EVENT_GVG_CHECK_UNION", self.OnCheckUnion, self)
	Event.Instance:Remove("EVENT_GVG_CHECK_TEAM", self.OnCheckTean, self)
end

function PageRank:OnClickedSelectTag(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	for i = 1, 8 do
		SetActiveFunc(self["BtnTag" .. i], true)
		SetActiveFunc(self["BtnTagSel" .. i], false)
	end

	SetActiveFunc(self["BtnTag" .. index], false)
	SetActiveFunc(self["BtnTagSel" .. index], true)

	self.curIndex = index

	self:UpdateScrollViewPanel(self.curIndex)
end

function PageRank:OnClickedChangeTag(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	for i = 1, 8 do
		SetActiveFunc(self["BtnTag" .. i], true)
		SetActiveFunc(self["BtnTagSel" .. i], false)
	end

	SetActiveFunc(self["BtnTag" .. index], false)
	SetActiveFunc(self["BtnTagSel" .. index], true)

	if self.curIndex == index then
		return
	end

	self.curIndex = index
	RankMgr.CurIndex = index

	self:UpdateScrollViewPanel(self.curIndex)
end

function PageRank:OnClickedLook()
	local InfoPVPData = require("Info/InfoPVP")

	if InfoPVPData:GetRocardtable(1) then
		require("UI/Page/PageRank/DlgRank")
		require("UI/Page/PageRank/DlgRank")
		DlgRank.RequestData(PlayerInst.InfoPlayer.pb)
	else
		UIMgr.ShowMsg(_("Desc_NoTeam"))
	end
end

function PageRank:OnClickedLookUnion()
	require("UI/Page/PageRank/DlgUnionBossRank")
	UIMgr.AddPanel(DlgUnionBossRank(), {
		ismy = true,
		info = UnionMgr.releUnion
	})
end

function PageRank:OnEnter(vParam)
	self.vParam = vParam
	self.tagGroup = self:GetChildGameObject("TagGroup")

	for i = 1, 8 do
		self["tab_go" .. i] = GOUtil.FindChildGameObject(self.tagGroup, i)
		self["BtnTag" .. i] = GOUtil.FindChildGameObject(self.tagGroup, i .. "/Btn")
		self["BtnTagSel" .. i] = GOUtil.FindChildGameObject(self.tagGroup, i .. "/Select")

		SetActiveFunc(self["BtnTag" .. i], true)
		SetActiveFunc(self["BtnTagSel" .. i], false)

		self["TexTag" .. i] = GOUtil.FindChildComponent(self.tagGroup, i .. "/Btn/Text", "Text")
		self["TexTagSel" .. i] = GOUtil.FindChildComponent(self.tagGroup, i .. "/Select/Text", "Text")
	end

	self.type1 = self:GetChildGameObject("PanelRank/GoMyRank/type1")
	self.type2 = self:GetChildGameObject("PanelRank/GoMyRank/type2")
	self.Tex_unList = self:GetChildGameObject("PanelRank/Panel/Tex_unList")
	self.curIndex = RankMgr.CurIndex

	if not OpenAllLock then
		if TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PageRank_Pvp) then
			self.curIndex = 3
		elseif TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PageRank_Union) then
			self.curIndex = 5
		elseif TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PageRank_BossRaid) then
			self.curIndex = 6
		end
	end

	SetActiveFunc(self["BtnTag" .. self.curIndex], false)
	SetActiveFunc(self["BtnTagSel" .. self.curIndex], true)

	self.boosRaidIsopen = false

	if ActivityBossRaidMgr.bossRaidTimeData then
		self.boosRaidIsopen = ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen()
	end

	SetActiveFunc(self["tab_go" .. 6], self.boosRaidIsopen)
	self:DealWithLocalization()
	self:Init()
	Infogvg:Init()

	self.infoPlayer = PlayerInst.InfoPlayer
	self.rankList = {}
	self.rankListValue = {}

	self:RequestRankEvent()
	UITweenUtil.CommonTweenRight(self.tagGroup.transform, 40, 0.14)
	RankMgr:SetRankDotStateList()
end

function PageRank:DealWithLocalization()
	self["TexTag" .. 3].text = _("eReturn_PVP")
	self["TexTag" .. 5].text = _("Desc_Camerata")
	self["TexTag" .. 6].text = _("eReturn_BossRaid")
	self["TexTagSel" .. 3].text = _("eReturn_PVP")
	self["TexTagSel" .. 5].text = _("Desc_Camerata")
	self["TexTagSel" .. 6].text = _("eReturn_BossRaid")
	self["TexTag" .. 7].text = _("Desc_rank_gvg_union")
	self["TexTagSel" .. 7].text = _("Desc_rank_gvg_union")
	self["TexTag" .. 8].text = _("Desc_rank_gvg_player")
	self["TexTagSel" .. 8].text = _("Desc_rank_gvg_player")

	local Text = GOUtil.FindChildComponent(self.type1, "Text", "Text")

	Text.text = _("Desc_MyInfo")
	Text = GOUtil.FindChildComponent(self.type1, "tex_ungrade", "Text")
	Text.text = Lang(40600009)
	Text = GOUtil.FindChildComponent(self.type1, "btn_look/Text", "Text")
	Text.text = _("Desc_LookTeam")
	Text = self:GetChildComponent("GoMaintain/Text", "Text")
	Text.text = _("Desc_FuncFobid") .. "..."
end

function PageRank:Init()
	self.GoMyRank_my = self:GetChildGameObject("PanelRank/GoMyRank")
	self.GoMaintain = self:GetChildGameObject("GoMaintain")

	GOUtil.SetActive(self.GoMaintain, false)

	self.ImgPlayerHead_my = GOUtil.FindChildComponent(self.type1, "Btn_nameIcon/Icon", "Image")
	self.ImgPlayerHeadFrame_my = GOUtil.FindChildComponent(self.type1, "Btn_nameIcon/Frame", "Image")
	self.go_tex_ungrade_my = GOUtil.FindChildGameObject(self.type1, "tex_ungrade")
	self.go_grade_my = GOUtil.FindChildGameObject(self.type1, "img_grade")
	self.img_grade2_my = GOUtil.FindChildComponent(self.type1, "img_grade2", "Image")
	self.tex_grade_my = GOUtil.FindChildComponent(self.type1, "img_grade/tex_grade", "Text")
	self.img_unionname_my = GOUtil.FindChildGameObject(self.type1, "img_unionname")
	self.tex_unionname_my = GOUtil.FindChildComponent(self.type1, "tex_unionname", "Text")
	self.tex_name_my = GOUtil.FindChildComponent(self.type1, "tex_name", "Text")
	self.tex_level_my = GOUtil.FindChildComponent(self.type1, "tex_level", "Text")
	self.bg_Text_my = GOUtil.FindChildComponent(self.type1, "bg/Text", "Text")
	self.bg_tex_my = GOUtil.FindChildComponent(self.type1, "bg/tex_", "Text")
	self.bg_tex_my.fontSize = 26
	self.btn_look_my = GOUtil.FindChildGameObject(self.type1, "btn_look")
	self.img_type2_grade2 = GOUtil.FindChildComponent(self.type2, "img_grade2", "Image")
	self.go_grade2 = GOUtil.FindChildGameObject(self.type2, "img_grade")
	self.tex_grade2 = GOUtil.FindChildComponent(self.type2, "img_grade/tex_grade", "Text")
	self.tex_name = GOUtil.FindChildComponent(self.type2, "tex_name", "Text")
	self.tex_level = GOUtil.FindChildComponent(self.type2, "tex_level", "Text")
	self.tex_unlevel = GOUtil.FindChildComponent(self.type2, "tex_unlevel", "Text")
	self.ImgAvatarIcon = GOUtil.FindChildComponent(self.type2, "Img_UnionIcon/Icon", "Image")
	self.ImgAvatarFrame = GOUtil.FindChildComponent(self.type2, "Img_UnionIcon/Frame", "Image")
	self.ImgAvatarType = GOUtil.FindChildComponent(self.type2, "Img_UnionIcon/Typ", "Image")
	self.tex_ununion = GOUtil.FindChildComponent(self.type2, "tex_ununion", "Text")
	self.tex_ownerName = GOUtil.FindChildComponent(self.type2, "tex_unionname", "Text")
	self.tex_bossBlood = GOUtil.FindChildComponent(self.type2, "tex_bossBlood", "Text")
	self.btn_look_union = GOUtil.FindChildGameObject(self.type2, "btn_look")
	self.PanelRect = self:GetChildComponent("PanelRank/Panel", "Transform")
	self.obj_panel = self:GetChildGameObject("PanelRank")
	self.obj_gvg = self:GetChildGameObject("PanelGvg")
	self.UIScrollToolGvg = UIScrollTool()
	self.obj_scrollGvg = self:GetChildGameObject("PanelGvg/Panel/ScrollArea")
	self.trans_contentGvg = self:GetChildComponent("PanelGvg/Panel/ScrollArea/Content", "Transform")
	self.obj_myrankroot = self:GetChildGameObject("PanelGvg/GoMyRank")
	self.GoMyRankGvg = CellGvgRank(self.PrefabCellGvg, self.obj_myrankroot)

	self.GoMyRankGvg:Create()

	self.GoMyRankGvg.UIRootObject.transform.localPosition = Vector3.zero
	self.obj_emptyData = self:GetChildGameObject("PanelGvg/Panel/obj_emptydata")
	self.obj_emptyUnion = self:GetChildGameObject("PanelGvg/Panel/obj_emptyunion")
	self.PanelRectGvg = self:GetChildComponent("PanelGvg/Panel", "Transform")

	GOUtil.SetActive(self.obj_emptyData, false)
	GOUtil.SetActive(self.obj_emptyUnion, false)
end

function PageRank:RequestRankEvent(curIndex)
	local function wrap_cb(vMsg)
		SetActiveFunc(self.obj_panel, true)
		SetActiveFunc(self.obj_gvg, false)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if self.isMainTain then
				GOUtil.SetActive(self.GoMaintain, false)

				self.isMainTain = false
			end

			SetActiveFunc(self.Tex_unList, false)

			local function callback(...)
				if self.curIndex == 3 then
					self.rankList = RankMgr:GetPvpRankList() or {}
				elseif self.curIndex == 5 then
					self.rankList = RankMgr:GetUnionRankList() or {}
				elseif self.curIndex == 6 then
					self.rankList = RankMgr:GetRankList() or {}
				else
					self.rankList = RankMgr:GetRankList() or {}
				end

				SetActiveFunc(self.Tex_unList, #self.rankList == 0)

				self.rankListValue, self.myScoreLevel = RankMgr:GetRankListSortValue(self.rankList, self.curIndex)
			end

			if curIndex == nil then
				callback()
				self:InitScrollViewPanel()
				self:InitMyRankPlayer()
			else
				callback()

				if not self.UIScrollToolPanel then
					self:InitScrollViewPanel()
					self:InitMyRankPlayer()
				end

				self.UIScrollToolPanel:SetContentPosImmediate(Vector2.zero, self.rankList)
				self:InitMyRankPlayer()
			end
		elseif vMsg.result.code == NetManager.Result_Maintain then
			GOUtil.SetActive(self.GoMaintain, true)

			self.isMainTain = true

			self:InitMyRankPlayer()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)

			self.rankList = {}

			if curIndex == nil then
				self:InitScrollViewPanel()
				self:InitMyRankPlayer()
			else
				if not self.UIScrollToolPanel then
					self:InitScrollViewPanel()
					self:InitMyRankPlayer()
				end

				self.UIScrollToolPanel:SetContentPosImmediate(Vector2.zero, self.rankList)
				self:InitMyRankPlayer()
			end
		end
	end

	if self.curIndex == 7 or self.curIndex == 8 then
		SetActiveFunc(self.GoMyRankGvg.UIRootObject, false)

		if UnionMgr.HasUnion(false) == false then
			SetActiveFunc(self.obj_panel, false)
			SetActiveFunc(self.obj_gvg, true)

			self.PanelRectGvg.offsetMin = Vector2.New(self.PanelRectGvg.offsetMin.x, 55)

			SetActiveFunc(self.obj_emptyUnion, true)
		end
	end

	if self.curIndex == 7 then
		Infogvg.net:RequestRank()
	elseif self.curIndex == 8 then
		Infogvg.net:RequestContribution()
	else
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestRank(self.curIndex, wrap_cb)
	end

	SetActiveFunc(self["tab_go" .. 3], OpenAllLock or TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PageRank_Pvp))
	SetActiveFunc(self["tab_go" .. 5], OpenAllLock or TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PageRank_Union))
	SetActiveFunc(self["tab_go" .. 6], self.boosRaidIsopen and (OpenAllLock or TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PageRank_BossRaid)))

	local gvgopen = Infogvg:IsPlayOpen()
	local openImgPath = {
		"7/Btn/Open",
		"8/Btn/Open",
		"7/Select/Open",
		"8/Select/Open"
	}
	local closeImgPath = {
		"7/Btn/Close",
		"8/Btn/Close",
		"7/Select/Close",
		"8/Select/Close"
	}

	for i, path in ipairs(openImgPath) do
		local go = GOUtil.FindChildGameObject(self.tagGroup, path)

		SetActiveFunc(go, gvgopen)
	end

	for i, path in ipairs(closeImgPath) do
		local go = GOUtil.FindChildGameObject(self.tagGroup, path)

		SetActiveFunc(go, not gvgopen)
	end
end

function PageRank:DlgUnionBossRankEvent()
	self:UpdateScrollViewPanel(self.curIndex)
end

function PageRank:SetRankViewPosY()
	if self.UIScrollToolPanel then
		local posY = self.UIScrollToolPanel.ScrollView.content.anchoredPosition.y

		RankMgr:SetRankViewPosY(posY)
	end
end

function PageRank:InitScrollViewPanel()
	local ScrollArea = self:GetChildGameObject("PanelRank/Panel/ScrollArea")
	local content = self:GetChildComponent("PanelRank/Panel/ScrollArea/Content", "Transform")

	self.Panel = self:GetChildGameObject("PanelRank/Panel")
	self.UIScrollToolPanel = UIScrollTool()
	self.ScrollArea = ScrollArea

	local count = #self.rankList

	local function AddClick()
		return
	end

	local function CellUpdate(item, index)
		local infoPlayer = self.rankList[index]
		local listValue = self.rankListValue[index]

		local function cb()
			return
		end

		item:UpdateData(infoPlayer, self.curIndex, 100, cb, listValue)
	end

	self.UIScrollToolPanel:InitList(self.ScrollArea, content, count, self.PrefabCell, CellRank, self, false, AddClick, CellUpdate)
end

function PageRank:UpdateScrollViewPanel()
	self:RequestRankEvent(self.curIndex)
	RankMgr:SetRankViewPosY(0)
end

function PageRank:InitMyRankPlayer()
	SetActiveFunc(self.GoMyRank_my, not self.isMainTain)

	if self.isMainTain then
		self.PanelRect.offsetMin = Vector2.New(self.PanelRect.offsetMin.x, 55)

		return
	end

	SetActiveFunc(self.type1, true)
	SetActiveFunc(self.type2, false)

	self.PanelRect.offsetMin = Vector2.New(self.PanelRect.offsetMin.x, 55)

	self.UIScrollToolPanel.ScrollView:SetViewBounds()

	local posY = RankMgr:GetRankViewPosY()

	if posY == 0 then
		self.UIScrollToolPanel:UpdateListData(self.rankList)
	else
		self.UIScrollToolPanel.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)

		RankMgr:SetRankViewPosY(0)
	end

	if self.curIndex == 3 then
		self.PanelRect.offsetMin = Vector2.New(self.PanelRect.offsetMin.x, 245)

		self.UIScrollToolPanel.ScrollView:SetViewBounds()
		SetActiveFunc(self.bg_Text_my.gameObject, false)
		SetActiveFunc(self.bg_tex_my.gameObject, true)

		self.bg_tex_my.text = _("Desc_Score") .. RankMgr:GetPlayerScore()

		SetActiveFunc(self.btn_look_my, true)
	elseif self.curIndex == 5 then
		SetActiveFunc(self.type1, false)
		SetActiveFunc(self.type2, true)

		local function callback()
			self.UIScrollToolPanel.ScrollView:SetViewBounds()

			if posY == 0 then
				self.UIScrollToolPanel:UpdateListData(self.rankList)
			end
		end

		if not UnionMgr.HasUnion() then
			self.PanelRect.offsetMin = Vector2.New(self.PanelRect.offsetMin.x, 55)

			callback()
			SetActiveFunc(self.GoMyRank_my, false)
			SetActiveFunc(self.tex_ununion.gameObject, true)
			SetActiveFunc(self.tex_name.gameObject, false)
			SetActiveFunc(self.tex_level.gameObject, false)
			SetActiveFunc(self.tex_unlevel.gameObject, true)

			self.tex_bossBlood.text = _("Desc_AllDps") .. 0
		else
			self.PanelRect.offsetMin = Vector2.New(self.PanelRect.offsetMin.x, 245)

			callback()
			SetActiveFunc(self.GoMyRank_my, true)
			SetActiveFunc(self.tex_ununion.gameObject, false)
			SetActiveFunc(self.tex_name.gameObject, true)
			SetActiveFunc(self.tex_level.gameObject, true)

			self.tex_name.text = UnionMgr.releUnion.pb.name

			local unionList = UnionMgr.releUnion

			if RankMgr:GetPlayerRank() <= 0 then
				SetActiveFunc(self.tex_unlevel.gameObject, true)
				SetActiveFunc(self.go_grade2, false)
				SetActiveFunc(self.img_type2_grade2.gameObject, false)
			else
				SetActiveFunc(self.tex_unlevel.gameObject, false)

				if RankMgr:GetPlayerRank() >= 1 and RankMgr:GetPlayerRank() <= 3 then
					SetActiveFunc(self.go_grade2, false)
					SetActiveFunc(self.img_type2_grade2.gameObject, true)
					UIUtil.SetImageSprite(self.img_type2_grade2, "UI/PanelRank/atlasRank/IC_pvp_crown_0" .. RankMgr:GetPlayerRank(), self)
				else
					SetActiveFunc(self.go_grade2, true)
					SetActiveFunc(self.img_type2_grade2.gameObject, false)

					self.tex_grade2.text = RankMgr:GetPlayerRank()
				end
			end

			self.tex_bossBlood.text = _("Desc_AllDps") .. RankMgr:GetPlayerScore()
			self.tex_name.text = unionList.pb.name
			self.tex_ownerName.text = RankMgr:GetOwnerClub()[1].ownerName
			self.tex_level.text = string.format(_("Desc_Level"), unionList.curLevel)

			local bgPath = UnionTypeMgr:GetUnionTypeBgIcon(unionList.pb.type)

			UIUtil.SetImageSprite(self.ImgAvatarType, bgPath, self)

			local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(unionList.pb.type)

			UIUtil.SetImageSprite(self.ImgAvatarIcon, avatarPath, self)
		end

		return
	elseif self.curIndex == 6 then
		self.PanelRect.offsetMin = Vector2.New(self.PanelRect.offsetMin.x, 245)

		self.UIScrollToolPanel.ScrollView:SetViewBounds()
		SetActiveFunc(self.btn_look_my, false)
		SetActiveFunc(self.bg_Text_my.gameObject, false)
		SetActiveFunc(self.bg_tex_my.gameObject, true)

		self.bg_tex_my.text = _("Desc_AllDps") .. RankMgr:GetPlayerScore()
	end

	local infoItem = ItemManager:Get(self.infoPlayer.headId)

	UIUtil.SetImageSprite(self.ImgPlayerHead_my, infoItem:GetIcon(), self)

	infoItem = ItemManager:Get(self.infoPlayer.headFrame)

	UIUtil.SetImageSprite(self.ImgPlayerHeadFrame_my, infoItem:GetIcon(), self)

	self.tex_name_my.text = self.infoPlayer.name
	self.tex_level_my.text = string.format(_("Desc_Level"), self.infoPlayer.curLevel)

	if self.infoPlayer.clubName == "" or self.curIndex == 3 or self.curIndex == 6 then
		SetActiveFunc(self.tex_unionname_my.gameObject, false)
		SetActiveFunc(self.img_unionname_my, false)
	else
		self.tex_unionname_my.text = self.infoPlayer.clubName
	end

	if RankMgr:GetPlayerRank() <= 0 then
		SetActiveFunc(self.go_tex_ungrade_my, true)
		SetActiveFunc(self.go_grade_my, false)
		SetActiveFunc(self.img_grade2_my.gameObject, false)
	elseif RankMgr:GetPlayerRank() >= 1 and RankMgr:GetPlayerRank() <= 3 then
		SetActiveFunc(self.go_tex_ungrade_my, falseGoMyRank)
		SetActiveFunc(self.go_grade_my, false)
		SetActiveFunc(self.img_grade2_my.gameObject, true)
		UIUtil.SetImageSprite(self.img_grade2_my, "UI/PanelRank/atlasRank/IC_pvp_crown_0" .. RankMgr:GetPlayerRank(), self)
	else
		SetActiveFunc(self.go_tex_ungrade_my, false)
		SetActiveFunc(self.go_grade_my, true)
		SetActiveFunc(self.img_grade2_my.gameObject, false)

		self.tex_grade_my.text = RankMgr:GetPlayerRank()
	end
end

function PageRank:OnGvgMaintain()
	GOUtil.SetActive(self.GoMaintain, true)
end

function PageRank:OnGvgRank()
	local datas = Infogvg.rank.billboard_rank
	local count = #datas

	local function onAdd(item)
		if self.curIndex == 7 then
			item:BillboardRank()
		end
	end

	local function onUpdate(item, index)
		if self.curIndex == 7 then
			local data = datas[index]

			item:Rank(data)
		end
	end

	self:RefreshGvgRank(count, onAdd, onUpdate, datas)
	self.GoMyRankGvg:Rank(Infogvg.rank.own_rank)
	self.GoMyRankGvg:OwnRank()
end

function PageRank:OnGvgContribution()
	local datas = Infogvg.rank.billboard_contribution
	local count = #datas

	local function onAdd(item)
		if self.curIndex == 8 then
			item:BillboardContribution()
		end
	end

	local function onUpdate(item, index)
		if self.curIndex == 8 then
			local data = datas[index]

			item:Contribution(data)
		end
	end

	self:RefreshGvgRank(count, onAdd, onUpdate, datas)
	self.GoMyRankGvg:Contribution(Infogvg.rank.own_contribution)
	self.GoMyRankGvg:OwnContribution()
end

function PageRank:RefreshGvgRank(count, onAdd, onUpdate, datas)
	SetActiveFunc(self.obj_panel, false)
	SetActiveFunc(self.obj_gvg, true)
	GOUtil.SetActive(self.GoMaintain, false)
	GOUtil.SetActive(self.obj_emptyData, count == 0)
	SetActiveFunc(self.obj_emptyUnion, false)

	self.PanelRectGvg.offsetMin = Vector2.New(self.PanelRectGvg.offsetMin.x, 245)

	self.UIScrollToolGvg:InitList(self.obj_scrollGvg, self.trans_contentGvg, count, self.PrefabCellGvg, CellGvgRank, self, false, onAdd, onUpdate)
	self.UIScrollToolGvg:UpdateListData(datas)
	GOUtil.SetActive(self.GoMyRankGvg.UIRootObject, true)
end

function PageRank:OnCheckUnion(union)
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

function PageRank:OnCheckTean(pbPlayer)
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
