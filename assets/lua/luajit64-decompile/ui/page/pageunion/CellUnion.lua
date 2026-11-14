-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/CellUnion.lua

CellUnion = class("CellUnion", UIItemBase)

function CellUnion:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellUnion:OnEnter(vParam)
	local g = self.UIRootObject
	local txt

	txt = self:GetChildComponent("Panel/Level/Text", "Text")
	txt.text = Lang(12004)
	txt = self:GetChildComponent("Panel/People/Text", "Text")
	txt.text = _("Union_Member_Num")
	self.UnionName = GOUtil.FindChildComponent(g, "Panel/Name", "Text")
	self.UnionLevel = GOUtil.FindChildComponent(g, "Panel/Level/TxtLevel", "Text")
	self.UnionPeopleNum = GOUtil.FindChildComponent(g, "Panel/People/TxtNum", "Text")
	self.UnionJoinLevel = GOUtil.FindChildComponent(g, "Panel/Prompt/Text", "Text")
	self.UnionTypeRoleBg = GOUtil.FindChildComponent(g, "Panel/Role", "Image")
	self.UnionTypeRole = GOUtil.FindChildComponent(g, "Panel/Role/Icon", "Image")
	self.UnionTypeName = GOUtil.FindChildComponent(g, "Panel/Type/Name", "Text")
	self.GoApplyed = GOUtil.FindChildGameObject(g, "Panel/Applyed")
	self.GoClosed = GOUtil.FindChildGameObject(g, "Panel/Closed")
	self.GoAuto = GOUtil.FindChildGameObject(g, "Panel/Auto")
	self.GoManual = GOUtil.FindChildGameObject(g, "Panel/Manual")
	self.TxtManual = GOUtil.FindChildComponent(g, "Panel/Manual/Text", "Text")
	self.GoSelect = GOUtil.FindChildGameObject(g, "Select")
end

function CellUnion:UpdateData(infoUnion, index)
	self.info = infoUnion
	self.UnionTypeName.text = UnionTypeMgr:GetUnionTypeName(infoUnion.pb.type)

	local bgPath = UnionTypeMgr:GetUnionTypeBgIcon(infoUnion.pb.type)

	SetImageSprite(self.UnionTypeRoleBg, bgPath, self)

	local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(infoUnion.pb.type)

	SetImageSprite(self.UnionTypeRole, avatarPath, self)

	self.UnionName.text = infoUnion:GetName()
	self.UnionLevel.text = infoUnion.curLevel
	self.UnionPeopleNum.text = infoUnion.curMemberNum .. "/" .. infoUnion.maxMemberNum

	local isApplyed = infoUnion:HaveApplied(PlayerInst.InfoPlayer.pid)
	local isClosed = infoUnion:IsClose()
	local isAuto = infoUnion:IsAuto()

	GOUtil.SetActive(self.GoApplyed, isApplyed)
	GOUtil.SetActive(self.GoClosed, not isApplyed and isClosed)
	GOUtil.SetActive(self.GoAuto, isAuto)
	GOUtil.SetActive(self.GoManual, not isAuto)

	local str = string.format(_("Msg_Union_Level_Recruit"), " <size=29>" .. infoUnion.joinLevel .. "</size>")

	if infoUnion.joinLevel == 0 then
		str = _("Mail_NoLimit")
	end

	self.TxtManual.text = str

	self:UpdateSelectState(self.Index == index)
end

function CellUnion:UpdateSelectState(active)
	GOUtil.SetActive(self.GoSelect, active)
end

function CellUnion:OnLeave()
	UnloadAllImageSprite(self)
end
