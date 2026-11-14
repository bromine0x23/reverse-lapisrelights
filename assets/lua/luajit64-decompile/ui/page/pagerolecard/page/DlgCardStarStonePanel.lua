-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Page/DlgCardStarStonePanel.lua

DlgCardStarStonePanel = class("DlgCardStarStonePanel", UIPanel)

function DlgCardStarStonePanel:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/PanelCardStarStone"
end

function DlgCardStarStonePanel:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem", GameObject)
end

function DlgCardStarStonePanel:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellItem)

	if self.listCellItem then
		for _, item in ipairs(self.listCellItem) do
			if item and item.OnLeave then
				item:OnLeave()
			end
		end

		self.listCellItem = nil
	end
end

function DlgCardStarStonePanel:OnRegisterEvent()
	self:AddClick(self.BtnFight, self.OnClickedBtnEnter)
	self:AddClick(self.BtnStory, self.OnClickedBtnStoryEnter)
	Event.Instance:Add("UpdateStageNum", self.UpdateStagePlayNum, self)
	Event.Instance:Add("UpdateItemNumBySweep", self.UpdateSoulNum, self)
end

function DlgCardStarStonePanel:OnUnRegisterEvent()
	self:RemoveClick(self.BtnFight, self.OnClickedBtnEnter)
	self:RemoveClick(self.BtnStory, self.OnClickedBtnStoryEnter)
	Event.Instance:Remove("UpdateStageNum", self.UpdateStagePlayNum, self)
	Event.Instance:Remove("UpdateItemNumBySweep", self.UpdateSoulNum, self)
end

function DlgCardStarStonePanel:OnEnter(vParam)
	self:SetSafeArea(self.UIRootObject)
	self:DealWithLocalization()

	self.TxtStoryName = self:GetChildComponent("Panel/Story/Bg/TxtName", "Text")
	self.GoStoryLock = self:GetChildGameObject("Panel/Story/Lock")
	self.GoStoryAward = self:GetChildGameObject("Panel/Story/Award")
	self.TxtCardName = self:GetChildComponent("Panel/Pass/Bg/TxtName", "Text")
	self.TxtLeftNum = self:GetChildComponent("Panel/Pass/TxtGroup/TxtNum", "Text")
	self.TxtSoulNum = self:GetChildComponent("Panel/Pass/TxtGroup/Text", "Text")
	self.BtnFight = self:GetChildGameObject("Panel/Pass/BtnEnter")
	self.BtnStory = self:GetChildGameObject("Panel/Story/BtnEnter")
	self.OpenResult = TutorialMgr:IsOpen(TutorialFunctionType.CardPass)
	self.GoTxtGroup = self:GetChildGameObject("Panel/Pass/TxtGroup")
	self.GoPassLock = self:GetChildGameObject("Panel/Pass/Lock")
	self.TxtPassLock = self:GetChildComponent("Panel/Pass/Lock/Text", "Text")

	self:InitPanel(vParam)
end

function DlgCardStarStonePanel:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Pass/BtnEnter/Text", "Text")
	txt.text = Lang(42037)
	txt = self:GetChildComponent("Panel/Pass/TxtGroup/TxtRefresh", "Text")
	txt.text = string.format(Lang(8111005), tostring(InfoGameInst.RefreshTime))
	txt = self:GetChildComponent("Panel/Story/Lock/Text", "Text")
	txt.text = _("Desc_Card_Story_Unlock_Condition")
end

function DlgCardStarStonePanel:Show()
	GOUtil.SetActive(self.UIRootObject, true)
end

function DlgCardStarStonePanel:Hide()
	GOUtil.SetActive(self.UIRootObject, false)
end

function DlgCardStarStonePanel:InitPanel(data)
	if not data or not data.infoRoleCard then
		return
	end

	self.infoRoleCard = data.infoRoleCard
	self.TxtCardName.text = Lang(self.infoRoleCard.data.Name)
	self.infoStage = CardChapterMgr.GetCardChapterStory(self.infoRoleCard.id)
	self.TxtStoryName.text = self.infoStage:GetName()

	self:UpdateStory()
	self:UpdateFight()
	self:UpdateDot()
end

function DlgCardStarStonePanel:UpdateFight()
	local isShow = self.OpenResult.open and self.infoRoleCard:CanChallenge()

	GOUtil.SetActive(self.GoPassLock, not isShow)
	GOUtil.SetActive(self.GoTxtGroup, isShow)
	GOUtil.SetActive(self.BtnFight, isShow)

	if not isShow then
		if self.infoRoleCard:CanChallenge() then
			self.TxtPassLock.text = self.OpenResult.desc
		else
			self.TxtPassLock.text = _("Desc_Item_Not_Open")
		end
	else
		self:UpdateSoulNum()
		self:UpdateStagePlayNum()
	end
end

function DlgCardStarStonePanel:UpdateSoulNum()
	if not self.OpenResult.open then
		return
	end

	self.TxtSoulNum.text = string.format(_("Card_Star_Stone_Hold"), "：" .. self.infoRoleCard.pb.soul)
end

function DlgCardStarStonePanel:UpdateStagePlayNum()
	if not self.OpenResult.open then
		return
	end

	self.TxtLeftNum.text = Lang(12338) .. "：" .. CardChapterMgr.GetTotalRemainingChallengeNum() .. "/" .. CardChapterMgr.GetTotalLimitChallengeNum()
end

function DlgCardStarStonePanel:UpdateStory()
	local isUnlock = self.infoRoleCard.curPetal >= GetConfigArgInt("CardStoryUnlock")

	self.GoStoryAward:SetActive(isUnlock)
	self.BtnStory:SetActive(isUnlock)
	self.GoStoryLock:SetActive(not isUnlock)

	local function FunUpdate(cell, award)
		local info = ItemManager:GetValueItem(award[1] or 501, award[2] or 0)

		cell:UpdateWithNumType(info)
		cell:SetGeted(self.infoStage:IsPass())
	end

	local function FunCreate(award)
		local cell = CellItem(self.PrefabCellItem, self.GoStoryAward, self)

		cell:Create()
		FunUpdate(cell, award)
		cell:SetFirstPass(true)
		table.insert(self.listCellItem, cell)
	end

	if isUnlock then
		self.listCellItem = self.listCellItem or {}

		local list = self.infoStage.data.FirstAward

		if #list > #self.listCellItem then
			for i = 1, #list do
				if i <= #self.listCellItem then
					GOUtil.SetActive(self.listCellItem[i].UIRootObject, true)
					FunUpdate(self.listCellItem[i], list[i])
				else
					FunCreate(list[i])
				end
			end
		else
			for i = 1, #self.listCellItem do
				if i <= #list then
					GOUtil.SetActive(self.listCellItem[i].UIRootObject, true)
					FunUpdate(self.listCellItem[i], list[i])
				else
					GOUtil.SetActive(self.listCellItem[i].UIRootObject, false)
				end
			end
		end
	end
end

function DlgCardStarStonePanel:OnClickedBtnStoryEnter()
	if self.infoRoleCard.curPetal < GetConfigArgInt("CardStoryUnlock") or self.infoStage == nil then
		UIMgr.ShowMsg(_("Desc_Not_Open"))

		return
	end

	require("UI/Page/PagePass/PageStage")
	PageStage.RequestStartStage(self.infoStage, "MainStage", cb)
end

function DlgCardStarStonePanel:OnClickedBtnEnter()
	ChapterMgr.cardIndex = self.infoRoleCard.id

	DlgCardStage.Init(self.infoRoleCard)
end

function DlgCardStarStonePanel:UpdateDot()
	RedDotSystemMgr.SetUIRedDot(self.BtnStory, "Stage/" .. self.infoRoleCard.id .. "/Story")
	RedDotSystemMgr.SetUIRedDot(self.BtnFight, "Stage/" .. self.infoRoleCard.id .. "/Fight")
end
