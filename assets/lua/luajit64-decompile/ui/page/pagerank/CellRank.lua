-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRank/CellRank.lua

require("UI/Item/UIItemBase")

CellRank = class("CellRank", UIItemBase)

function CellRank:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellRank:Create(vParam)
	CellRank.base.Create(self, vParam)
end

function CellRank:OnEnter()
	local g = self.UIRootObject

	self.type1 = self:GetChildGameObject("type1")
	self.type2 = self:GetChildGameObject("type2")
	self.Btn_nameIcon = GOUtil.FindChildGameObject(self.type1, "Btn_nameIcon")
	self.ImgPlayerHead = GOUtil.FindChildComponent(self.type1, "Btn_nameIcon/Icon", "Image")
	self.ImgPlayerHeadFrame = GOUtil.FindChildComponent(self.type1, "Btn_nameIcon/Frame", "Image")
	self.go_grade_title = GOUtil.FindChildGameObject(self.type1, "go_grade_title")
	self.go_grade = GOUtil.FindChildGameObject(self.type1, "img_grade")
	self.img_grade2 = GOUtil.FindChildComponent(self.type1, "img_grade2", "Image")
	self.tex_grade = GOUtil.FindChildComponent(self.type1, "img_grade/tex_grade", "Text")
	self.img_unionname = GOUtil.FindChildGameObject(self.type1, "img_unionname")
	self.tex_unionname = GOUtil.FindChildComponent(self.type1, "tex_unionname", "Text")
	self.tex_name = GOUtil.FindChildComponent(self.type1, "tex_name", "Text")
	self.tex_level = GOUtil.FindChildComponent(self.type1, "tex_level", "Text")
	self.tex_level.fontSize = 26
	self.bg_Text = GOUtil.FindChildComponent(self.type1, "bg/Text", "Text")
	self.bg_tex = GOUtil.FindChildComponent(self.type1, "bg/tex_", "Text")
	self.btn_look = GOUtil.FindChildGameObject(self.type1, "btn_look")
	self.img_type2_grade2 = GOUtil.FindChildComponent(self.type2, "img_grade2", "Image")
	self.go_grade2 = GOUtil.FindChildGameObject(self.type2, "img_grade")
	self.tex_grade2 = GOUtil.FindChildComponent(self.type2, "img_grade/tex_grade", "Text")
	self.tex_name2 = GOUtil.FindChildComponent(self.type2, "tex_name", "Text")
	self.tex_level2 = GOUtil.FindChildComponent(self.type2, "tex_level", "Text")
	self.ImgAvatarIcon = GOUtil.FindChildComponent(self.type2, "Img_UnionIcon/Icon", "Image")
	self.ImgAvatarFrame = GOUtil.FindChildComponent(self.type2, "Img_UnionIcon/Frame", "Image")
	self.ImgAvatarType = GOUtil.FindChildComponent(self.type2, "Img_UnionIcon/Typ", "Image")
	self.tex_ownerName = GOUtil.FindChildComponent(self.type2, "tex_ownerName", "Text")
	self.tex_bossBlood = GOUtil.FindChildComponent(self.type2, "tex_bossBlood", "Text")
	self.btn_look_union = GOUtil.FindChildGameObject(self.type2, "btn_look")
	Text = GOUtil.FindChildComponent(self.type1, "btn_look/Text", "Text")
	Text.text = _("Desc_LookTeam")
	Text = GOUtil.FindChildComponent(self.type2, "btn_look/Text", "Text")
	Text.text = _("Desc_LookOrganization")
	self.bg2 = GOUtil.FindChildComponent(self.type2, "bg", "Image")

	GOUtil.SetRectTransformAnchoredPosition(self.bg2.gameObject, 0, -30)
	GOUtil.SetRectTransformSizeDeltaWidth(self.bg2.gameObject, 600)
	GOUtil.SetRectTransformAnchoredPosition(self.tex_bossBlood.gameObject, 0, -31)
	GOUtil.SetRectTransformSizeDeltaWidth(self.tex_bossBlood.gameObject, 570)
	self:OnRegisterEvent()
end

function CellRank:UpdateData(info, index, _type, callback, listValue, isMyRankList)
	self.info = {}

	if index == 3 then
		self.info.pb = info.pb.player
		self.defensiveRoleCards = info.pb.defensiveRoleCards
		self.roles = info.pb.roles
	elseif index == 5 then
		self.info.pb = info
	else
		self.info = info
	end

	self.type = _type
	self.callback = callback

	SetActiveFunc(self.type1, true)
	SetActiveFunc(self.type2, false)

	if index == 3 then
		SetActiveFunc(self.bg_Text.gameObject, false)
		SetActiveFunc(self.bg_tex.gameObject, true)

		self.bg_tex.text = _("Desc_Score") .. self.info.pb.extras[1]

		SetActiveFunc(self.btn_look, true)
	elseif index == 5 then
		SetActiveFunc(self.type1, false)
		SetActiveFunc(self.type2, true)

		self.tex_name2.text = self.info.pb.pb.name
		self.tex_ownerName.text = self.info.pb.pb.ownerName
		self.tex_bossBlood.text = _("Desc_AllDps") .. tostring(self.info.pb.pb.score)
		self.tex_level2.text = string.format(_("Desc_Level"), tostring(self.info.pb.pb.level))

		if listValue >= 1 and listValue <= 3 then
			SetActiveFunc(self.go_grade2, false)
			SetActiveFunc(self.img_type2_grade2.gameObject, true)
			UIUtil.SetImageSprite(self.img_type2_grade2, "UI/PanelRank/atlasRank/IC_pvp_crown_0" .. listValue, self)
		else
			SetActiveFunc(self.go_grade2, true)
			SetActiveFunc(self.img_type2_grade2.gameObject, false)

			self.tex_grade2.text = listValue
		end

		local bgPath = UnionTypeMgr:GetUnionTypeBgIcon(self.info.pb.pb.type)

		UIUtil.SetImageSprite(self.ImgAvatarType, bgPath, self)

		local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(self.info.pb.pb.type)

		UIUtil.SetImageSprite(self.ImgAvatarIcon, avatarPath, self)

		return
	elseif index == 6 then
		SetActiveFunc(self.bg_Text.gameObject, false)
		SetActiveFunc(self.bg_tex.gameObject, true)
		SetActiveFunc(self.btn_look, false)

		if self.info.pb.extras ~= nil then
			self.bg_tex.text = _("Desc_AllDps") .. self.info.pb.extras[1]
		else
			return
		end
	end

	local infoItem = ItemManager:Get(self.info.pb.headId)

	UIUtil.SetImageSprite(self.ImgPlayerHead, infoItem:GetIcon(), self)

	infoItem = ItemManager:Get(self.info.pb.headFrame)

	UIUtil.SetImageSprite(self.ImgPlayerHeadFrame, infoItem:GetIcon(), self)

	self.tex_name.text = self.info.pb.nickname
	self.tex_level.text = string.format(_("Desc_Level"), LevelManager:GetPlayerLevel(self.info.pb.levelExp))

	if self.info.pb.clubName == "" then
		SetActiveFunc(self.tex_unionname.gameObject, false)
		SetActiveFunc(self.img_unionname, false)
	else
		SetActiveFunc(self.tex_unionname.gameObject, true)
		SetActiveFunc(self.img_unionname, true)

		self.tex_unionname.text = self.info.pb.clubName
	end

	self.tex_grade.text = listValue

	if listValue >= 1 and listValue <= 3 then
		SetActiveFunc(self.go_grade, false)
		SetActiveFunc(self.img_grade2.gameObject, true)
		UIUtil.SetImageSprite(self.img_grade2, "UI/PanelRank/atlasRank/IC_pvp_crown_0" .. listValue, self)
	else
		SetActiveFunc(self.go_grade, true)
		SetActiveFunc(self.img_grade2.gameObject, false)

		self.tex_grade.text = listValue
	end

	SetActiveFunc(self.go_grade_title, false)
end

function CellRank:OnRegisterEvent()
	self:AddClick(self.btn_look, self.OnClickedLook)
	self:AddClick(self.btn_look_union, self.OnClickedLookUnion)
	self:AddClick(self.Btn_nameIcon, self.OnClickHeadIcon)
end

function CellRank:OnUnRegisterEvent()
	self:RemoveClick(self.btn_look, self.OnClickedLook)
	self:RemoveClick(self.btn_look_union, self.OnClickedLookUnion)
	self:RemoveClick(self.Btn_nameIcon, self.OnClickHeadIcon)
end

function CellRank:OnClickedLook()
	require("UI/Page/PageRank/DlgRank")
	DlgRank.RequestData(self.info.pb)
end

function CellRank:OnClickedLookUnion()
	require("UI/Page/PageRank/DlgUnionBossRank")
	UIMgr.AddPanel(DlgUnionBossRank(), {
		ismy = false,
		info = self.info.pb
	})
end

function CellRank:OnClickHeadIcon()
	self.info.level = LevelManager:GetPlayerLevel(self.info.pb.levelExp)
	self.info.id = self.info.pb.playerId

	local data = {
		type = self.type,
		info = self.info
	}

	UIMgr.AddPanel(DlgOpPlayer(), data)
end

function CellRank:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end
