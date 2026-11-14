-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/CellGvgRank.lua

require("UI/Item/UIItemBase")

CellGvgRank = class("CellGvgRank", UIItemBase)

function CellGvgRank:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellGvgRank:Create(vParam)
	CellGvgRank.base.Create(self, vParam)
end

function CellGvgRank:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end

function CellGvgRank:OnEnter()
	self.flag = "rank"
	self.bg_rank_self = self:GetChildGameObject("btn_look/img_bg_self")
	self.bg_rank = self:GetChildGameObject("btn_look/Img_bg")
	self.bg_contribute_self = self:GetChildGameObject("img_bg_self")
	self.bg_contribute = self:GetChildGameObject("Img_bg")
	self.obj_grade = self:GetChildGameObject("img_grade")
	self.img_grade = self:GetChildComponent("img_grade/img_grade2", "Image")
	self.img_grade_blue = self:GetChildComponent("img_grade/img_grade1", "Image")
	self.tex_name = self:GetChildComponent("tex_name", "Text")
	self.txt_level = self:GetChildComponent("tex_level", "Text")
	self.txt_order = self:GetChildComponent("tex_order", "Text")
	self.obj_look = self:GetChildGameObject("btn_look")
	self.btn_look = self:GetChildGameObject("btn_look/obj_click")
	self.txt_look = self:GetChildComponent("btn_look/Text", "Text")
	self.img_icon = self:GetChildComponent("Img_PlayerIcon/Icon", "Image")
	self.img_frame = self:GetChildComponent("Img_PlayerIcon/Frame", "Image")
	self.img_unionicon = self:GetChildComponent("Img_UnionIcon/Icon", "Image")
	self.img_type = self:GetChildComponent("Img_UnionIcon/Type", "Image")
	self.obj_playerIcon = self:GetChildGameObject("Img_PlayerIcon")
	self.obj_unionIcon = self:GetChildGameObject("Img_UnionIcon")
	self.txt_score = self:GetChildComponent("tex_score", "Text")
	self.obj_bk = self:GetChildGameObject("bk")

	self:OnRegisterEvent()
	GOUtil.SetActive(self.obj_look, false)
	GOUtil.SetActive(self.bg_rank, false)
	GOUtil.SetActive(self.bg_rank_self, false)
	GOUtil.SetActive(self.bg_contribute_self, false)
	GOUtil.SetActive(self.bg_contribute, false)
	GOUtil.SetActive(self.obj_bk, false)
end

function CellGvgRank:BillboardRank()
	GOUtil.SetActive(self.obj_look, true)
	GOUtil.SetActive(self.bg_rank, true)
	GOUtil.SetActive(self.bg_rank_self, false)
	GOUtil.SetActive(self.bg_contribute_self, false)
	GOUtil.SetActive(self.bg_contribute, false)

	self.txt_look.text = _("Desc_LookOrganization")
end

function CellGvgRank:OwnRank()
	GOUtil.SetActive(self.obj_look, true)
	GOUtil.SetActive(self.bg_rank, false)
	GOUtil.SetActive(self.bg_rank_self, true)
	GOUtil.SetActive(self.bg_contribute_self, false)
	GOUtil.SetActive(self.bg_contribute, false)
	GOUtil.SetActive(self.obj_bk, true)

	self.txt_look.text = _("Desc_LookOrganization")
	self.img_grade_blue.enabled = false
	self.txt_order.color = getColorFromString("A0A0A0")
end

function CellGvgRank:BillboardContribution()
	self:BillboardRank()

	self.txt_look.text = _("Desc_LookTeam")
end

function CellGvgRank:OwnContribution()
	self:OwnRank()

	self.txt_look.text = _("Desc_LookTeam")
	self.img_grade_blue.enabled = false
	self.txt_order.color = getColorFromString("A0A0A0")
end

function CellGvgRank:Rank(data)
	self.playerId = nil
	self.union = data.info
	self.img_grade.enabled = false
	self.img_grade_blue.enabled = false

	if data.order > 0 then
		self.txt_order.text = data.order

		if data.order <= 3 then
			UIUtil.SetImageSprite(self.img_grade, "UI/PanelRank/atlasRank/IC_pvp_crown_0" .. data.order, self)

			self.img_grade.enabled = true
		else
			self.img_grade_blue.enabled = true
			self.txt_order.color = getColorFromString("FFFFFF")
		end
	else
		self.txt_order.text = Lang(40600009)
	end

	self.tex_name.text = data.name
	self.txt_score.text = string.format(_("Desc_GVG_Score"), data.score)
	self.txt_level.text = string.format(_("Desc_Level"), data.level)

	local bgPath = UnionTypeMgr:GetUnionTypeBgIcon(data.type)

	UIUtil.SetImageSprite(self.img_type, bgPath, self)

	local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(data.type)

	UIUtil.SetImageSprite(self.img_unionicon, avatarPath, self)
	GOUtil.SetActive(self.obj_playerIcon, false)
	GOUtil.SetActive(self.obj_unionIcon, true)
end

function CellGvgRank:Contribution(data)
	self.union = nil
	self.playerId = data.playerId
	self.img_grade.enabled = false
	self.img_grade_blue.enabled = false

	if data.order > 0 then
		self.txt_order.text = data.order

		if data.order <= 3 then
			UIUtil.SetImageSprite(self.img_grade, "UI/PanelRank/atlasRank/IC_pvp_crown_0" .. data.order, self)

			self.img_grade.enabled = true
		else
			self.img_grade_blue.enabled = true
			self.txt_order.color = getColorFromString("FFFFFF")
		end
	else
		self.txt_order.text = Lang(40600009)
	end

	self.tex_name.text = data.nickname
	self.txt_score.text = string.format(_("Desc_GVG_Contribution"), data.contribution)
	self.txt_level.text = string.format(_("Desc_Level"), LevelManager:GetPlayerLevel(data.levelExp))

	local infoItem = ItemManager:Get(data.headId)

	UIUtil.SetImageSprite(self.img_icon, infoItem:GetIcon(), self)

	infoItem = ItemManager:Get(data.headFrame)

	UIUtil.SetImageSprite(self.img_frame, infoItem:GetIcon(), self)
	GOUtil.SetActive(self.obj_playerIcon, true)
	GOUtil.SetActive(self.obj_unionIcon, false)
end

function CellGvgRank:OnRegisterEvent()
	self:AddClick(self.btn_look, self.OnClickedLook)
end

function CellGvgRank:OnUnRegisterEvent()
	self:RemoveClick(self.btn_look, self.OnClickedLook)
end

function CellGvgRank:OnClickedLook()
	if self.playerId then
		local pbPlayer = Infogvg.rank:FindPBPlayer(self.playerId)

		Event.Instance:Fire("EVENT_GVG_CHECK_TEAM", pbPlayer)
	elseif self.union then
		Event.Instance:Fire("EVENT_GVG_CHECK_UNION", self.union)
	end
end
