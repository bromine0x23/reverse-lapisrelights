-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBosslive/CellBossliveStage.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageCombatReadiness/PageCombatReadiness")

CellBossliveStage = class("CellBossliveStage", UIItemBase)

function CellBossliveStage:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBossliveStage:Create(vParam)
	CellBossliveStage.base.Create(self, vParam)
end

function CellBossliveStage:OnEnter()
	local g = self.UIRootObject

	if not self.listItem then
		self.listItem = {}
	end

	for i = 1, 3 do
		self["Stage" .. i] = GOUtil.FindChildGameObject(g, "" .. i)
		self["BtnInfo" .. i] = GOUtil.FindChildGameObject(g, "" .. i .. "/ImgType")

		self:AddClick(self["BtnInfo" .. i], self.OnClickedBtnInfo)

		self["GoFrame" .. i] = GOUtil.FindChildGameObject(g, "Panel/Star/Image" .. i)
		self["GoStar" .. i] = GOUtil.FindChildGameObject(g, "Panel/Star/Star" .. i)
		self["CellItem" .. i] = GOUtil.FindChildGameObject(g, "Panel/Award/Group/" .. i)

		local gItem = self["CellItem" .. i]
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.AnimRoot = GOUtil.GetComponent(g, "Animator")

	EventListenerMgr.AddAnimListener(self.UIRootObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)

	self.TxtStageName = GOUtil.FindChildComponent(g, "Panel/TxtName", "Text")
	self.TxtRecomLv = GOUtil.FindChildComponent(g, "Panel/TxtLevel", "Text")
	self.TxtStageCost = GOUtil.FindChildComponent(g, "Panel/Award/BgCost/TxtCost", "Text")
	self.TxtPlayNum = GOUtil.FindChildComponent(g, "Panel/Award/BgNum/Text", "Text")
	self.TxtAwardType = GOUtil.FindChildComponent(g, "Panel/Award/BgType/Text", "Text")
	self.DailyReward = GOUtil.FindChildGameObject(g, "Panel/Award/DailyReward")
	self.BtnSweep = GOUtil.FindChildGameObject(g, "Panel/BtnSweep")
	self.BtnEnter = GOUtil.FindChildGameObject(g, "Panel/BtnEnter")
	self.CellStageImg = GOUtil.FindChildComponent(g, "", "Image")
	self.EnterImg = GOUtil.FindChildComponent(g, "Panel/BtnEnter/Image", "Image")
	self.ImgType = GOUtil.FindChildComponent(g, "1/ImgType", "Image")

	self:AddClick(self.BtnSweep, self.OnClickedBtnSweep)
	self:AddClick(self.BtnEnter, self.OnClickedBtnEnter)

	self.GoLock = GOUtil.FindChildGameObject(g, "Lock")
	self.GoLockImg = GOUtil.FindChildGameObject(g, "Lock/Image")
	self.GoLockImg2 = GOUtil.FindChildGameObject(g, "Lock/Image2")
	self.TxtLock = GOUtil.FindChildComponent(g, "Lock/Image2/Text", "Text")

	self:AddClick(self.GoLock, self.OnClickedGoLock)

	self.GoNew = GOUtil.FindChildGameObject(g, "Panel/GoNew")
	self.GoStory = GOUtil.FindChildGameObject(g, "Panel/Award/Image")
	self.GoCost = GOUtil.FindChildGameObject(g, "Panel/Award/BgCost")
	self.GoStarGroup = GOUtil.FindChildGameObject(g, "Panel/Star")
	self.GoPlayNum = GOUtil.FindChildGameObject(g, "Panel/Award/BgNum")
end

function CellBossliveStage:OnLeave()
	for i = 1, 3 do
		self:RemoveClick(self["BtnInfo" .. i], self.OnClickedBtnInfo)
	end

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	self.AnimRoot = nil

	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	self:RemoveClick(self.BtnSweep, self.OnClickedBtnSweep)
	self:RemoveClick(self.BtnEnter, self.OnClickedBtnEnter)
	self:RemoveClick(self.GoLock, self.OnClickedGoLock)
	UnloadAllImageSprite(self)
end

function CellBossliveStage:UpdateData(data, msg, index)
	local infoStage = data.infoStage

	self.info = infoStage
	self.stageIndex = data.index

	local chapterType = infoStage.data.ChapterType
	local stageType = infoStage.data.Type

	for i = 1, 3 do
		-- block empty
	end

	if stageType == 5 then
		SetActiveFunc(self.Stage1, true)
	end

	local isUnLock = infoStage:IsOpen()
	local isNew = infoStage:IsNew()
	local isEnter = PersistentStoreUtil.GetStageEnter(self.info.data.ID)

	SetActiveFunc(self.GoLock, not isUnLock)
	SetActiveFunc(self.BtnEnter, isUnLock)

	local num = TenaryOp(isUnLock, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.CellStageImg, num))
	DealWithListRef(self, UIUtil.SetImageGray(self.EnterImg, num))
	DealWithListRef(self, UIUtil.SetImageGray(self.ImgType, num))

	if index == 1 then
		if msg ~= nil and not isUnLock then
			local list = string.split(msg, "★")

			self:GetChildComponent("Lock/Image/Text", "Text").text = string.format(Lang(40610015), list[1])
		else
			self:GetChildComponent("Lock/Image/Text", "Text").text = ""
		end
	end

	SetActiveFunc(self.GoStory, false)
	SetActiveFunc(self.GoCost, false)
	SetActiveFunc(self.GoStarGroup, false)
	SetActiveFunc(self.GoPlayNum, false)
	SetActiveFunc(self.BtnSweep, false)
	SetActiveFunc(self.TxtRecomLv.gameObject, false)

	if stageType == 2 then
		SetActiveFunc(self.GoStory, true)
	else
		SetActiveFunc(self.GoCost, true)

		self.TxtStageCost.text = infoStage.data.Stamina

		local starCount = infoStage:GetStar()

		if isUnLock then
			SetActiveFunc(self.GoStarGroup, true)
			self:SetStar(starCount)
		end

		if infoStage.data.SafeLevel ~= 0 then
			SetActiveFunc(self.TxtRecomLv.gameObject, true)

			self.TxtRecomLv.text = Lang(12333) .. "LV." .. infoStage.data.SafeLevel
		end
	end

	if infoStage:GetMaxLeftPlayNum() ~= 0 and stageType ~= 2 then
		SetActiveFunc(self.GoPlayNum, true)

		local num = infoStage.pb.playNum

		if num > infoStage:GetMaxLeftPlayNum() then
			num = infoStage:GetMaxLeftPlayNum()
		end

		self.TxtPlayNum.text = Lang(5000009) .. infoStage:GetMaxLeftPlayNum() - num .. "/" .. infoStage:GetMaxLeftPlayNum()
	end

	if chapterType == 4 and stageType == 5 then
		SetActiveFunc(self.GoPlayNum, false)
	end

	local isNoNum = false
	local listAward = {}
	local txtTitle = Lang(5000007)

	if isNew or not isUnLock then
		listAward = infoStage.data.FirstAward
	elseif stageType == 2 then
		listAward = infoStage.data.FirstAward
	else
		txtTitle = Lang(12488)
		isNoNum = true
		listAward = infoStage.data.ItemList
	end

	self.TxtAwardType.text = txtTitle

	for i = 1, 3 do
		local gItem = self["CellItem" .. i]
		local item = self.listItem[i]
		local award = listAward[i]

		if award and award[1] then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			if isNoNum == false then
				item:UpdateWithNumType(infoItem)
			else
				item:UpdateNoNumType(infoItem)
			end

			item:SetGeted(stageType == 2 and not isNew and isUnLock)
			SetActiveFunc(gItem, true)
			item:SetGray(num == 1)
		else
			SetActiveFunc(gItem, false)
		end
	end

	local activeInfo = ActiveMgr:GetActiveInfoByStageData(self.info.data)

	if activeInfo ~= nil then
		SetActiveFunc(self.DailyReward, activeInfo:HaveDailyReward())
	else
		SetActiveFunc(self.DailyReward, false)
	end
end

function CellBossliveStage:SetLockInfo(str)
	if str then
		SetActiveFunc(self.GoLockImg, false)
		SetActiveFunc(self.GoLockImg2, true)
		SetActiveFunc(self.TxtLock.gameObject, true)

		self.TxtLock.text = str
	end
end

function CellBossliveStage:SetStar(starCount)
	for i = 1, 3 do
		SetActiveFunc(self["GoFrame" .. i], starCount < i)
		SetActiveFunc(self["GoStar" .. i], i <= starCount)
	end
end

function CellBossliveStage:OnClickedGoLock()
	if not self.info:IsOpen() then
		UIMgr.ShowMsg(_("PageTalentTree_Locked"))

		return
	end
end

function CellBossliveStage:OnClickedBtnInfo()
	UIMgr.AddPanel(DlgStageDetail(), {
		infoStage = self.info
	}, UIMgr.UIOverLayObject)
end

function CellBossliveStage:OnClickedBtnEnter()
	if BossliveChapterMgr.GetBossliveRemainingChallengeNum() == 0 then
		UIMgr.ShowMsg(_("PvPbattleNum"))

		return
	end

	self.AnimRoot:Play("CellStage")
end

function CellBossliveStage:EventAnim()
	if self.info.data.Type ~= 2 then
		ChapterMgr.PageCombatReadinessType = 1

		UIMgr.AddPanel(PageCombatReadiness(), {
			stageId = self.info.id
		})
		self.AnimRoot:Play("New State")
	else
		self:BeginStage(1)
	end
end

function CellBossliveStage:OnClickedBtnSweep()
	local starCnt = self.info:GetStar()

	if starCnt ~= 3 then
		UIMgr.ShowMsg(_("PageBattleTeam_SweepLock"))

		return
	end

	self:BeginStage(2)
end

function CellBossliveStage:BeginStage(stype)
	local stageType = self.info.data.Type
	local chapterType = self.info.data.ChapterType

	if chapterType == 4 then
		local infoActive = ActiveMgr:GetActiveInfoByStageData(self.info.data)
		local isCanPlay, msg = infoActive:IsPlayOpen()

		if not isCanPlay then
			UIMgr.ShowMsg(msg)

			return
		end
	end

	PersistentStoreUtil.SetStageEnter(self.info.data.ID, true)
	Event.Instance:Fire(EventEnum.EnterStage, {
		stype = stype,
		infoStage = self.info
	})
end
