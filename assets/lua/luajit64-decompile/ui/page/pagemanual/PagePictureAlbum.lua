-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/PagePictureAlbum.lua

require("UI/Item/CellItem")
require("Info/InfoCollection")
require("UI/Page/PageManual/CellPicTab")

PagePictureAlbum = class("PagePictureAlbum", UIPanel)

function PagePictureAlbum:ctor()
	self.UIPrefabPath = "UI/PageManual/PagePictureAlbum"

	self:AddChildPanel(DlgExit(), {
		title = _("Desc_Figure"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42,
		AssetInfos = {
			533,
			502,
			501
		}
	})
end

function PagePictureAlbum:OnBack()
	UIMgr.PopPanel()
end

function PagePictureAlbum:PreLoad()
	return
end

function PagePictureAlbum:Purge()
	self.base.Purge(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	if self.DlgUnlockTask then
		self.DlgUnlockTask:Close()
	end

	self.DlgUnlockTask = nil
end

function PagePictureAlbum:OnRegisterEvent()
	self:AddClick(self.ActiveButton, self.OnClickActiveButton)
	self:AddClick(self.Favor, self.OpenFavorPanel)
	Event.Instance:Add("UpdatePicTask", self.UpdatePicTask, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdatePanel, self)
end

function PagePictureAlbum:OnUnRegisterEvent()
	self:RemoveClick(self.ActiveButton, self.OnClickActiveButton)
	self:RemoveClick(self.Favor, self.OpenFavorPanel)
	Event.Instance:Remove("UpdatePicTask", self.UpdatePicTask, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdatePanel, self)
end

function PagePictureAlbum:OnEnter(vParam)
	self:DealWithLocalization()

	self.ActiveButton = self:GetChildGameObject("Panel/ConditionPart/ActiveButton")
	self.ImgBtton = self:GetChildComponent("Panel/ConditionPart/ActiveButton", "Image")
	self.RoleImage = self:GetChildComponent("Panel/Mask2D/RoleImage", "RawImage")
	self.Favor = self:GetChildGameObject("Panel/ConditionPart/Items/Favor")
	self.FavorText = self:GetChildComponent("Panel/ConditionPart/Items/Favor/Text", "Text")
	self.FavorCellText = self:GetChildComponent("Panel/ConditionPart/Items/Favor/Image/BgTxt/Text", "Text")
	self.Desc = self:GetChildComponent("Panel/Desc", "TextView")
	self.Effect = self:GetChildGameObject("Panel/ConditionPart/ActiveButton/effect")
	self.listItem = {}

	for i = 1, 3 do
		self["ItemObj" .. i] = self:GetChildGameObject("Panel/ConditionPart/Items/CellNeedItem" .. i)

		local gItem = GOUtil.FindChildGameObject(self["ItemObj" .. i], "CellItem")
		local item = CellItem(gItem)

		item.tipData = {
			showNum = true,
			initPanelIndex = 3,
			needFromBtn = true
		}

		item:InitItemByRoot(gItem)

		item.tipData = {
			showNum = true,
			initPanelIndex = 3,
			needFromBtn = true
		}

		table.insert(self.listItem, item)

		self["NeedNum" .. i] = GOUtil.FindChildComponent(self["ItemObj" .. i], "Text", "Text")
		self["GoLess" .. i] = GOUtil.FindChildGameObject(self["ItemObj" .. i], "Less")
	end

	self.ConditionPart = self:GetChildGameObject("Panel/ConditionPart")
	self.roleId = vParam.roleId

	self:UpdatePanel()
end

function PagePictureAlbum:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/AwardBg/Avatar/Tital", "Text")
	txt.text = _("Desc_PicAlbum_1")
	txt = self:GetChildComponent("Panel/AwardBg/Manuscript/Tital", "Text")
	txt.text = _("Desc_PicAlbum_2")
	txt = self:GetChildComponent("Panel/AwardBg/Weapon/Tital", "Text")
	txt.text = _("Desc_PicAlbum_3")
	txt = self:GetChildComponent("Panel/AwardBg/Head/Tital", "Text")
	txt.text = _("Desc_PicAlbum_4")
	txt = self:GetChildComponent("Panel/ConditionPart/Condition", "Text")
	txt.text = _("Desc_ActiveCond")
	txt = self:GetChildComponent("Panel/AwardBg/Tital", "Text")
	txt.text = _("Desc_ActiveAward")
	txt = self:GetChildComponent("Panel/Tital/Tital", "Text")
	txt.text = _("Desc_Node")
	txt = self:GetChildComponent("Panel/ConditionPart/Tip", "Text")
	txt.text = _("Desc_PicAlbumTip")
end

function PagePictureAlbum:UpdatePanel()
	self.info = CollectionManager:GetPicOpenInfo(self.roleId)

	self.ConditionPart:SetActive(true)

	local needItemList = self.info.data.ItemNeed

	self.effectActive = true

	for i = 1, 3 do
		local cellItem = self.listItem[i]
		local item = needItemList[i]

		if item then
			local infoItem = ItemManager:Get(item[1])

			cellItem:UpdateWithNumType(infoItem)

			cellItem.ItemCount.text = infoItem:GetCurResNum()

			if item[2] > infoItem:GetCurResNum() then
				self.effectActive = false
				self["NeedNum" .. i].color = Color.red
			else
				self["NeedNum" .. i].color = getColorFromString("74898A")
			end

			self["NeedNum" .. i].text = _("Desc_Need") .. ":" .. item[2]

			self["ItemObj" .. i]:SetActive(true)
			GOUtil.SetActive(self["GoLess" .. i], not self.effectActive)
		else
			self["ItemObj" .. i]:SetActive(false)
		end
	end

	UIUtil.SetRawImageTexture(self.RoleImage, self.info.data.IconPath, self)
	GOUtil.SetRectTransformAnchoredPosition(self.RoleImage.gameObject, self.info.data.IconPos[1], self.info.data.IconPos[2])

	self.Desc.Text = Lang(self.info.data.Desc)

	if #self.info.data.condition > 0 and self.info.data.condition[1] and self.info.data.condition[1][1] and self.info.data.condition[1][1][1] == eCollectionTaskType.ROLE_LIKABILITY then
		self.Favor:SetActive(true)

		local infoRole = RoleMgr:GetRole(self.roleId)
		local cur = infoRole.curFavorLevel
		local need = self.info.data.condition[1][1][2]

		if cur < need then
			self.effectActive = false
			self.FavorText.color = Color.red
		else
			self.FavorText.color = getColorFromString("74898A")
		end

		self.FavorText.text = string.format(_("親密度：%s"), need)
		self.FavorCellText.text = string.format(_("Desc_Level"), cur)
	else
		self.Favor:SetActive(false)
	end

	self.Effect:SetActive(self.effectActive)

	local gray = TenaryOp(self.effectActive, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtton, gray))
end

function PagePictureAlbum:OnClickActiveButton()
	require("UI/Page/PageManual/DlgUnlockTask")

	if not self.effectActive then
		UIMgr.ShowMsg(_("TipsNoFactor"))

		return
	end

	local function call(type)
		if type == DlgCommon.ButtonType.OK then
			self:OnClickGetAward()
		end
	end

	local strAlert = _("Activation_PagePictureAlbum")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("PagePictureAlbum_Active"), strAlert, call, _("PageTalentTree_Active"), _("UI_Cancel"))
end

function PagePictureAlbum:OnClickGetAward()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			local info = CollectionManager:Get(self.info.data.ID)

			info:SetData(self.info.data.ID)

			if info.data.Reward[1] and info.data.Reward[1][1] == 2 then
				local infoRole = RoleMgr:GetRole(info.data.roleId)

				infoRole:AddExtraSkillData({
					level = 1,
					id = info.data.Reward[1][2]
				})
				require("UI.Page.PageRoleCard.Dlg.DlgUpResult")
				UIMgr.AddPanel(DlgUpResult(), {
					index = 6,
					addAttr = info.data.Reward[1][2],
					infoRole = infoRole
				})
			end

			CollectionManager:AddNewOpenTask(self.info.data.ID)
			Event.Instance:Fire("UpdatePicTask")
		elseif vPBMessage.result.code == NetManager.Result_Timeout then
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		else
			UIMgr.ShowMsg(_("TipsNoFactor"))
		end
	end

	NetManager:RequestFinishIllustratedTask(self.info.data.ID, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PagePictureAlbum:UpdatePicTask()
	require("UI/Page/PageManual/PagePictureTask")
	UIMgr.SwitchPanel(PagePictureTask, {
		newUnlock = true,
		roleId = self.roleId
	})
end

function PagePictureAlbum:OpenFavorPanel()
	local infoRole = RoleMgr:GetRole(self.roleId)
	local cur = infoRole.curFavorLevel
	local need = self.info.data.condition[1][1][2]

	if need <= cur then
		return
	end

	SceneMainStage.Instance:OnEnterInteractionByRoleId(self.roleId, {
		tag = 1
	})
end
