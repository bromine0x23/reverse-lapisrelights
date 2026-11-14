-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/CellUnionMember.lua

CellUnionMember = class("CellUnionMember", UIItemBase)

function CellUnionMember:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellUnionMember:OnEnter(vParam)
	local g = self.UIRootObject
	local txt = GOUtil.FindChildComponent(g, "Panel/Activity/Text", "Text")

	txt.text = _("Union_Member_Liveness")
	txt = GOUtil.FindChildComponent(g, "Panel/Online/Text", "Text")
	txt.text = _("Desc_OnLine")
	txt = GOUtil.FindChildComponent(g, "Panel/Outline/Text", "Text")
	txt.text = _("Server_Offline")
	self.ImgMemberAvatar = GOUtil.FindChildComponent(g, "Panel/Avatar/Icon", "Image")
	self.ImgMemberHeadFrame = GOUtil.FindChildComponent(g, "Panel/Avatar/HeadFrame", "Image")
	self.TxtMemberName = GOUtil.FindChildComponent(g, "Panel/TxtName", "Text")
	self.TxtMemberLevel = GOUtil.FindChildComponent(g, "Panel/Info/TxtLevel", "Text")
	self.TxtMemberPosition = GOUtil.FindChildComponent(g, "Panel/Info/TxtPosition", "Text")
	self.TxtMemberActivity = GOUtil.FindChildComponent(g, "Panel/Activity/TxtActivity", "Text")
	self.GoOnline = GOUtil.FindChildGameObject(g, "Panel/Online")
	self.GoOffline = GOUtil.FindChildGameObject(g, "Panel/Outline")
	self.GoMine = GOUtil.FindChildGameObject(g, "GoMine")
	self.GoOther = GOUtil.FindChildGameObject(g, "GoOther")
end

function CellUnionMember:UpdateData(infoMember)
	if infoMember == nil then
		return
	end

	self.TxtMemberName.text = PlayerInst.InfoPlayer.pid == infoMember.pid and PlayerInst.InfoPlayer.name or infoMember.name
	self.TxtMemberLevel.text = Lang(12002) .. infoMember.curLevel
	self.TxtMemberPosition.text = UnionJobMgr:GetUnionJobName(infoMember.jobId)
	self.TxtMemberActivity.text = infoMember.liveness

	local headIcon = infoMember:GetTitleIcon(PlayerTitleType.head)

	SetImageSprite(self.ImgMemberAvatar, headIcon, self)

	local infoItem = ItemManager:Get(infoMember.headFrame)

	SetImageSprite(self.ImgMemberHeadFrame, infoItem:GetIcon(), self)

	local memberId = infoMember.pid

	GOUtil.SetActive(self.GoMine, PlayerInst.InfoPlayer.pid == memberId)
	GOUtil.SetActive(self.GoOther, PlayerInst.InfoPlayer.pid ~= memberId)
	GOUtil.SetActive(self.GoOnline, infoMember.isOnline)
	GOUtil.SetActive(self.GoOffline, not infoMember.isOnline)
end

function CellUnionMember:OnLeave()
	UnloadAllImageSprite(self)
end
