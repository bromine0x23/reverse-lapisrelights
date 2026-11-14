-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/PageBossActivityBG.lua

require("Info/InfoActive")
require("UI/Page/PageActivity/PageBossActivity")

local BossActiveUIData = require("luaData/BossctiveUIData")

PageBossActivityBG = class("PageBossActivityBG", UIPanel)

function PageBossActivityBG:ctor()
	self.UIPrefabPath = "UI/PanelActivity/PanelBossActivityBG"
	self.DlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.DlgAssetsInfo)
end

function PageBossActivityBG:PreLoad()
	return
end

function PageBossActivityBG:Purge()
	PageBossActivityBG.base.Purge(self)
	self:OnLeave()

	local pageStage = UIMgr.GetPanel("PageBossActivityStage")

	if pageStage then
		pageStage:Close()
	end

	local pageStage = UIMgr.GetPanel("PageBossActivity")

	if pageStage then
		pageStage:Close()
	end

	ChapterRDL.PartyRDL.ViewedSystem()
end

function PageBossActivityBG:OnLeave()
	if self.spineCnt then
		for i = 1, self.spineCnt do
			if self["SpineHandle" .. i] then
				ResourceMgr.Cancel(self["SpineHandle" .. i])

				self["SpineHandle" .. i] = nil
			end
		end

		self.spineCnt = nil
	end
end

function PageBossActivityBG:OnBack()
	UIMgr.SwitchPanel(PageMainStage)
end

function PageBossActivityBG:OnRegisterEvent()
	self:AddClick(self.BtnDetail, self.OnClickedBtnDetail)
end

function PageBossActivityBG:OnUnRegisterEvent()
	self:RemoveClick(self.BtnDetail, self.OnClickedBtnDetail)
end

function PageBossActivityBG.OpenActivity()
	local list = ActiveMgr:GetOpenActiveByType(3)
	local infoActive = list[1]

	if infoActive == nil then
		UIMgr.ClearMain()
		UIMgr.SwitchPanel(PageMainStage, nil, true)
		UIMgr.ShowMsg("Msg_Active_Over")

		return
	end

	local FirstChapter = infoActive:GetFirstStoryStage()

	if not FirstChapter then
		UIMgr.SwitchPanel(PageBossActivityBG)

		return
	end

	local infoStage = ChapterMgr:GetStage(FirstChapter)

	if infoStage:IsPass() then
		UIMgr.SwitchPanel(PageBossActivityBG)
	else
		require("UI/Page/PagePass/PageStage")

		ChapterMgr.BossActivityFirstOpen = true

		PageStage.RequestStartStage(infoStage, "MainStage")
	end
end

function PageBossActivityBG:OnEnter(vParam)
	self.GoSpinePoint = self:GetChildGameObject("Bg")

	local list = ActiveMgr:GetOpenActiveByType(3)

	self.infoActive = list[1]

	if self.infoActive == nil then
		UIMgr.ClearMain()
		UIMgr.SwitchPanel(PageMainStage, nil, true)
		UIMgr.ShowMsg("Msg_Active_Over")

		return
	end

	self:SetPartyAsset()

	self.UIData = BossActiveUIData[self.infoActive.id]

	local rawImage = self:GetChildComponent("Bg", "RawImage")

	UIUtil.SetRawImageTexture(rawImage, self.UIData.BgImage, self)
	self:LoadSpine()

	if ChapterMgr.BossActivityStageType then
		if ChapterMgr.BossActivityStageType == StageFromType.activeCommon then
			UIMgr.AddPanel(PageBossActivityStage(), self)
		elseif ChapterMgr.BossActivityStageType == StageFromType.story then
			UIMgr.AddPanel(PageBossActivityStory(), self)
		end
	else
		UIMgr.AddPanel(PageBossActivity(), self)
	end

	if ActiveMgr.NewOpenBossStage then
		self:ShowNewBossStageOpen()
	else
		self:ShowNewStoryOpen()
	end
end

function PageBossActivityBG:LoadSpine(cb)
	local canvas = GOUtil.AddMissingComponent(self.GoSpinePoint, "Canvas")

	canvas.overrideSorting = true
	canvas.sortingOrder = -5

	local spinePath = self.UIData.SpinePath
	local pos = self.UIData.SpinePos
	local roa = self.UIData.SpineRoa
	local scale = self.UIData.SpineScale

	self.spineCnt = #spinePath

	local idx = 1

	local function LoadSpineAsync(path)
		local function asyncFinishCallback()
			if self["SpineRef" .. idx] then
				self["Go" .. idx] = GOUtil.InstantiateUIPrefab(self["SpineRef" .. idx], self.GoSpinePoint)

				GOUtil.UpdateSpineSkeleton(self["Go" .. idx])
				GOUtil.SetRectTransformAnchoredPosition(self["Go" .. idx], pos[idx][1], pos[idx][2])
				GOUtil.SetTransformRotation(self["Go" .. idx], roa[idx][1], roa[idx][2], roa[idx][3])
				GOUtil.SetTransformLocalScale(self["Go" .. idx], scale[idx])
				DealWithListSpineRef(self, self["SpineRef" .. idx])

				self["SpineHandle" .. idx] = nil
				self["SpineRef" .. idx] = nil
				self["Go" .. idx].layer = 5

				local canvas = GOUtil.AddMissingComponent(self["Go" .. idx], "Canvas")

				canvas.overrideSorting = true
				canvas.sortingOrder = idx - #spinePath - 1
				idx = idx + 1

				if idx <= self.spineCnt then
					LoadSpineAsync(spinePath[idx])
				elseif cb then
					cb()
				end
			end
		end

		self["SpineHandle" .. idx] = ResourceMgr.BeginSubmit(asyncFinishCallback)

		ResourceMgr.SubmitCache(path, self, "SpineRef" .. idx, GameObject)
		ResourceMgr.EndSubmit()
	end

	LoadSpineAsync(spinePath[idx])
end

function PageBossActivityBG:ShowNewStoryOpen()
	local list = ActiveMgr.NewOpenStory

	if list and #list > 0 then
		require("UI.Page.PageActivity.DlgNewStory")
		UIMgr.AddPanel(DlgNewStory(), {
			id = self.infoActive.id
		})
	end
end

function PageBossActivityBG:ShowNewBossStageOpen()
	local stage = ActiveMgr.NewOpenBossStage

	if stage then
		require("UI.Page.PageActivity.DlgNewBossStage")
		UIMgr.AddPanel(DlgNewBossStage(), {
			callback = function()
				self:ShowNewStoryOpen()
			end
		})
	end
end

function PageBossActivityBG:SetPartyAsset()
	if not self.DlgAssetsInfo then
		return
	end

	local partyBossCostId, partyShopCostId
	local infoChapter = ChapterMgr:GetChapter(self.infoActive.bossChapterId)

	partyBossCostId = infoChapter.listStage[1].data.CostItem[1]

	local list = ActiveCardPoolMgr:GetAll(self.infoActive.id)

	partyShopCostId = list[1].data.OneCost[1]

	local powerId = ItemManager:GetItemByType("P_POWER").id

	self.DlgAssetsInfo:ResetByList({
		partyBossCostId,
		partyShopCostId,
		powerId
	})
end
