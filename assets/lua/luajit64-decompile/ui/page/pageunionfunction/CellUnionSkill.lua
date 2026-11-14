-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/CellUnionSkill.lua

require("UI/Item/UIItemBase")

CellUnionSkill = class("CellUnionSkill", UIItemBase)

function CellUnionSkill:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellUnionSkill:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImgSkillIcon = GOUtil.FindChildComponent(g, "SkillIcon", "Image")
	self.TxtSkillName = GOUtil.FindChildComponent(g, "TxtName", "Text")
	self.TxtSkillLevel = GOUtil.FindChildComponent(g, "TxtLevel", "Text")
	self.ImgExp = GOUtil.FindChildComponent(g, "ExpRate/Rate", "Image")
	self.TxtExp = GOUtil.FindChildComponent(g, "TxtExp", "Text")
	self.GoSelect = GOUtil.FindChildGameObject(g, "Select")
	self.TxtPopular = GOUtil.FindChildComponent(g, "Popular/Text", "Text")
	self.BtnPopular = GOUtil.FindChildGameObject(g, "Popular")
	self.GoEnablePopular = GOUtil.FindChildGameObject(g, "Popular/Image1")
	self.GoDisablePopular = GOUtil.FindChildGameObject(g, "Popular/Image2")

	self:AddClick(self.BtnPopular, self.OnClickedBtnPopular)
end

function CellUnionSkill:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.BtnPopular, self.OnClickedBtnPopular)
end

function CellUnionSkill:UpdateData(infoUnionSkill, index)
	self.info = infoUnionSkill
	self.selIndex = index
	self.TxtSkillName.text = Lang(infoUnionSkill.data.Name)

	SetImageSprite(self.ImgSkillIcon, infoUnionSkill:GetIconPath(), self)

	if infoUnionSkill:IsMaxLevel() then
		self.ImgExp.fillAmount = 1

		local maxNeedExp = UnionSkillMgr:GetClubSkillNeedExp(self.info.id, self.info.maxLevel - 1)

		self.TxtExp.text = maxNeedExp .. "/" .. maxNeedExp
		self.TxtSkillLevel.text = _("Desc_Role_Reach_MaxLv")
	else
		self.ImgExp.fillAmount = self.info.curExp / self.info.nextExp
		self.TxtExp.text = self.info.curExp .. "/" .. self.info.nextExp
		self.TxtSkillLevel.text = _("Player_Level") .. self.info.curLevel
	end

	self:UpdatePopular()
	self:UpdateSelectState(index == self.Index)
end

function CellUnionSkill:UpdateSelectState(state)
	SetActiveFunc(self.GoSelect, state)
end

function CellUnionSkill:UpdatePopular()
	if not self.info then
		return
	end

	self.TxtPopular.text = "x" .. self.info.hotSpot

	SetActiveFunc(self.GoEnablePopular, self.info.selfHot)
	SetActiveFunc(self.GoDisablePopular, not self.info.selfHot)
end

function CellUnionSkill:OnClickedBtnPopular()
	local isOverrun = not UnionSkillMgr:CanPointSkill()

	if isOverrun and not self.info.selfHot then
		UIMgr.ShowMsg(_("Msg_Popularity_Not_Enough"))

		return
	end

	local isPoint = not self.info.selfHot

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.info:ChangeSelfHot(isPoint)
			self.info:ChangeHotSpot(TenaryOp(isPoint, 1, -1))
			self:UpdatePopular()
			Event.Instance:Fire("UpdateUsableSpot")
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestSetUnionSkillHotSpot(self.info.id, isPoint, wrap_cb)
end
