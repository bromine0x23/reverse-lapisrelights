-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/CellApplyPlayer.lua

require("UI/Item/UIItemBase")

CellApplyPlayer = class("CellApplyPlayer", UIItemBase)

function CellApplyPlayer:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellApplyPlayer:OnEnter(vParam)
	local g = self.UIRootObject
	local txt

	txt = GOUtil.FindChildComponent(g, "Panel/Level/Text", "Text")
	txt.text = _("Union_Level")
	txt = GOUtil.FindChildComponent(g, "Panel/BtnRefuse/Text", "Text")
	txt.text = _("UI_Refuse")
	txt = GOUtil.FindChildComponent(g, "Panel/BtnAgree/Text", "Text")
	txt.text = _("UI_Agree")
	self.ImgPlayerAvatar = GOUtil.FindChildComponent(g, "Panel/Avatar/Icon", "Image")
	self.ImgPlayerHeadFrame = GOUtil.FindChildComponent(g, "Panel/Avatar/HeadFrame", "Image")
	self.TxtPlayerName = GOUtil.FindChildComponent(g, "Panel/Name", "Text")
	self.TxtPlayerLevel = GOUtil.FindChildComponent(g, "Panel/Level/TxtLv", "Text")
	self.TxtLineState = GOUtil.FindChildComponent(g, "Panel/Online/Text", "Text")
	self.BtnRefuse = GOUtil.FindChildGameObject(g, "Panel/BtnRefuse")
	self.BtnAgree = GOUtil.FindChildGameObject(g, "Panel/BtnAgree")

	self:AddClick(self.BtnAgree, self.OnClickedBtnAgree)
	self:AddClick(self.BtnRefuse, self.OnClickedBtnRefuse)
	self:AddClick(self.ImgPlayerAvatar.gameObject, self.OnClickPlayerAvatar)
end

function CellApplyPlayer:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.BtnAgree, self.OnClickedBtnAgree)
	self:RemoveClick(self.BtnRefuse, self.OnClickedBtnRefuse)
	self:RemoveClick(self.ImgPlayerAvatar.gameObject, self.OnClickPlayerAvatar)
end

function CellApplyPlayer:UpdateData(infoPlayer)
	self.info = infoPlayer

	local headIcon = infoPlayer:GetTitleIcon(PlayerTitleType.head)

	SetImageSprite(self.ImgPlayerAvatar, headIcon, self)

	local infoItem = ItemManager:Get(infoPlayer.headFrame)

	SetImageSprite(self.ImgPlayerHeadFrame, infoItem:GetIcon(), self)

	self.TxtPlayerName.text = infoPlayer.name
	self.TxtPlayerLevel.text = infoPlayer.curLevel

	if not infoPlayer.isOnline then
		self.TxtLineState.text = GetLogoutTimeFormat(tonumber(infoPlayer.pb.logoutTime))
	else
		self.TxtLineState.text = _("Desc_OnLine")
	end
end

function CellApplyPlayer:OnClickedBtnAgree()
	self:RequestOperateApplyPlayer(UnionOperateType.agree)
end

function CellApplyPlayer:OnClickedBtnRefuse()
	self:RequestOperateApplyPlayer(UnionOperateType.refuse)
end

function CellApplyPlayer:RequestOperateApplyPlayer(cmd)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			Event.Instance:Fire("UpdateApplylist")

			if cmd == UnionOperateType.agree then
				Event.Instance:Fire("UpdateMemberList")
			end
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			if vMsg.result.code == 4 then
				UnionApplyMgr:DealWithApplyPlayer({
					self.info.pid
				}, 1)
				Event.Instance:Fire("UpdateMemberList")
				Event.Instance:Fire("UpdateApplylist")
			elseif vMsg.result.code == 18 or vMsg.result.code == 20 then
				UnionApplyMgr:DealWithApplyPlayer({
					self.info.pid
				}, 2)
				Event.Instance:Fire("UpdateApplylist")
			end

			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestOperateUnionOrMember({
		cmd = cmd,
		targetId = self.info.pid
	}, wrap_cb)
end

function CellApplyPlayer:OnClickPlayerAvatar()
	local data = self.info

	data.id = self.info.pid
	data.level = self.info.curLevel
	self.info.id = self.info.pid

	Event.Instance:Fire("DlgOpPlayer", data)
end
