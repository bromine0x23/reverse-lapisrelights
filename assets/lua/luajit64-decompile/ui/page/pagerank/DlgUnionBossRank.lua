-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRank/DlgUnionBossRank.lua

require("Info/FuncOperablity")

DlgUnionBossRank = class("DlgUnionBossRank", UIPanel)

function DlgUnionBossRank:ctor()
	DlgUnionBossRank.base.ctor(self, "UI/PanelRank/DlgUnionBossRank")
end

function DlgUnionBossRank:Cache()
	DlgUnionBossRank.base.Cache(self)
end

function DlgUnionBossRank:PreLoad()
	self:LoadResAsync("UI/Common/CellCard/CellCard", "PrefabCell")
end

function DlgUnionBossRank:Purge()
	DlgUnionBossRank.base.Purge(self)

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	if self.UIScrollToolPanel then
		self.UIScrollToolPanel:Purge()
	end
end

function DlgUnionBossRank:Close()
	DlgUnionBossRank.base.Close(self)
end

function DlgUnionBossRank:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnCloseClick)
	self:AddClick(self.btn_enter, self.OnEnterCloseClick)
end

function DlgUnionBossRank:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnCloseClick)
	self:RemoveClick(self.btn_enter, self.OnEnterCloseClick)
end

function DlgUnionBossRank:OnEnter(vParam)
	self.info = vParam.info
	self.ismy = vParam.ismy
	self.btn_close = self:GetChildGameObject("Panel/ButtonExit")
	self.btn_enter = self:GetChildGameObject("Panel/btn_enter")

	SetActiveFunc(self.btn_enter, not self.ismy)
	SetActiveFunc(self.btn_enter, not self.ismy and not UnionMgr.releUnion)

	self.tex_id = self:GetChildComponent("Panel/tex_id", "Text")
	self.tex_level = self:GetChildComponent("Panel/tex_level", "Text")
	self.tex_union_name = self:GetChildComponent("Panel/img_union_name/tex_union_name", "Text")
	self.tex_number = self:GetChildComponent("Panel/go_main/go_tex/tex_number", "Text")
	self.tex_name = self:GetChildComponent("Panel/go_main/go_tex/tex_name", "Text")
	self.tex_type = self:GetChildComponent("Panel/go_main/go_tex/tex_type", "Text")
	self.tex_tips = self:GetChildComponent("Panel/go_main/go_tex/tex_tips", "Text")
	self.ImgAvatarType = self:GetChildComponent("Panel/Img_UnionIcon/Type", "Image")
	self.ImgAvatarIcon = self:GetChildComponent("Panel/Img_UnionIcon/Icon", "Image")
	self.ImgAvatarFrame = self:GetChildComponent("Panel/Img_UnionIcon/Frame", "Image")

	if self.ismy then
		self.tex_id.text = self.info.id
		self.tex_level.text = self.info.curLevel
		self.tex_union_name.text = self.info.pb.name
		self.tex_number.text = self.info.curMemberNum .. "/" .. self.info.maxMemberNum
		self.tex_name.text = RankMgr:GetOwnerClub()[1].ownerName
		self.tex_type.text = UnionTypeMgr:GetUnionTypeName(self.info.pb.type)
		self.tex_tips.text = self.info:GetNotice()

		local bgPath = UnionTypeMgr:GetUnionTypeBgIcon(self.info.pb.type)

		UIUtil.SetImageSprite(self.ImgAvatarType, bgPath, self)

		local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(self.info.pb.type)

		UIUtil.SetImageSprite(self.ImgAvatarIcon, avatarPath, self)
	else
		self.tex_id.text = self.info.pb.id
		self.tex_level.text = self.info.pb.level
		self.tex_union_name.text = self.info.pb.name
		self.tex_number.text = table.getn(self.info.pb.members) .. "/" .. LevelManager:GetClubLevelMaxMembers(self.info.pb.level)
		self.tex_name.text = self.info.pb.ownerName
		self.tex_type.text = UnionTypeMgr:GetUnionTypeName(self.info.pb.type)
		self.tex_tips.text = self:GetNotice()

		local bgPath = UnionTypeMgr:GetUnionTypeBgIcon(self.info.pb.type)

		UIUtil.SetImageSprite(self.ImgAvatarType, bgPath, self)

		local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(self.info.pb.type)

		UIUtil.SetImageSprite(self.ImgAvatarIcon, avatarPath, self)
	end
end

function DlgUnionBossRank:GetNotice()
	if self.info.pb.notice == "" then
		return Lang(1)
	end

	return self.info.pb.notice
end

function DlgUnionBossRank:OnBtnCloseClick()
	self:Close()
end

function DlgUnionBossRank:OnEnterCloseClick()
	local canApply, msg = self:CanApplyJoin(infoUnion)

	if not canApply then
		UIMgr.ShowMsg(msg)

		return
	end

	self:RequestJoinUnion(1)
end

function DlgUnionBossRank:CanApplyJoin()
	local msg = ""

	local function HaveApplied()
		local applys = self.info.pb.applys or {}

		for i = 1, #applys do
			if applys[i] == PlayerInst.InfoPlayer.pid then
				return true
			end
		end

		return false
	end

	local haveApplied = HaveApplied()

	if haveApplied then
		msg = _("Msg_Union_Repeat_Apply")

		return false, msg
	end

	local joinType = self.info.pb.joinType

	if joinType == UnionJoinType.close then
		msg = _("Msg_Union_Close_Join")

		return false, msg
	end

	local curMemberNum = table.getn(self.info.pb.members)

	if curMemberNum == LevelManager:GetClubLevelMaxMembers(self.info.pb.level) then
		msg = _("Msg_Union_Full")

		return false, msg
	end

	local joinLevel = self.info.pb.joinLevel

	if joinLevel > PlayerInst:GetCurLv() then
		msg = _("Msg_Union_Level_Less")

		return false, msg
	end

	return true
end

function DlgUnionBossRank:RequestJoinUnion(_type)
	if UnionMgr.HasUnion() then
		UIMgr.ShowMsg(_("Msg_Union_Joined"))

		return
	end

	local option = _type
	local clubId = self.info.pb.id

	if _type == 2 then
		clubId = nil
	end

	local function wrap_cb(Msg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if Msg.result.code == 0 then
			if option == 1 and UnionMgr.releUnion == nil then
				UIMgr.ShowMsg(_("Msg_Sucess_Apply_1"))
			end

			require("UI/Page/PageRank/PageRank")
			Event.Instance:Fire("DlgUnionBossRankEvent")
			self:Close()
		else
			UIMgr.ShowMsg(Msg.result.desc, Msg)
		end
	end

	NetManager:RequestApplyJoinUnion(option, clubId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end
