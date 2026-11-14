-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/PageBossActivity.lua

require("UI/Page/PageActivity/CellBossStage")
require("UI/Page/PageActivity/PageBossActivityShop")
require("UI/Page/PageActivity/PageBossActivityStage")
require("UI/Page/PageActivity/PageBossActivityStory")

local InfoTeam = require("Info/InfoTeam")
local BossActiveUIData = require("luaData/BossctiveUIData")

PageBossActivity = class("PageBossActivity", UIPanel)

function PageBossActivity:ctor()
	self.UIPrefabPath = "UI/PanelActivity/PanelBossActivity"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_Battle_Party"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnInfo,
		preCallback = self.PlayBackAni,
		panel = self
	})
end

function PageBossActivity:OnBack()
	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.partyBoss)

	if PageBossActivity.GetCurBossActive() == nil then
		PageBossActivity.EndActiveBackMain()
	else
		self:Close()
		UIMgr.PopPanel()
	end
end

function PageBossActivity:PreLoad()
	self:LoadResAsync("UI/PanelActivity/CellBossStage", "PrefabCellBossStage")
end

function PageBossActivity:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
	ResourceMgr.Unload(self.PrefabCellBossStage)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function PageBossActivity:OnRegisterEvent()
	self:AddClick(self.BtnStage, self.OnClickedBtnStage)
	self:AddClick(self.BtnStory, self.OnClickedBtnStory)
	self:AddClick(self.BtnShop, self.OnClickedBtnShop)
	Event.Instance:Add("OpenActiveStory", self.OnClickedBtnStory, self)
	Event.Instance:Add("UpdateStageNum", self.OnUpdateStageNum, self)
	Event.Instance:Add(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
end

function PageBossActivity:OnUnRegisterEvent()
	self:RemoveClick(self.BtnStage, self.OnClickedBtnStage)
	self:RemoveClick(self.BtnStory, self.OnClickedBtnStory)
	self:RemoveClick(self.BtnShop, self.OnClickedBtnShop)
	Event.Instance:Remove("OpenActiveStory", self.OnClickedBtnStory, self)
	Event.Instance:Remove("UpdateStageNum", self.OnUpdateStageNum, self)
	Event.Instance:Remove(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
end

function PageBossActivity:OnEnter(vParam)
	ChapterMgr.BossActivityStageType = nil

	if not GuideMgr:IsGuided(GuideFunctionType.EventStage) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.EventStage)
	end

	self:DealWithLocalization()

	self.Animator = self:GetChildComponent("", "Animator")
	self.BtnStage = self:GetChildGameObject("Panel/Main/Battle/Button")
	self.BtnStory = self:GetChildGameObject("Panel/Story")
	self.BtnShop = self:GetChildGameObject("Panel/Main/BtnShop/Btn")
	self.StageClose = self:GetChildGameObject("Panel/Main/Battle/Close")
	self.Icon = self:GetChildComponent("Panel/Icon", "Image")
	self.LittleTitalImage = self:GetChildComponent("Panel/Line", "Image")
	self.BattleIcon = self:GetChildComponent("Panel/Main/Battle", "Image")
	self.StoryIcon = self:GetChildComponent("Panel/Story/Mask/Image", "Image")
	self.BossIcon = self:GetChildComponent("Panel/Main/Boss", "Image")
	self.ShopIcon = self:GetChildComponent("Panel/Main/BtnShop", "Image")
	self.Desc = self:GetChildComponent("Panel/Line/Text", "Text")
	self.Time = self:GetChildComponent("Panel/Time/Text", "Text")
	self.TimeObj = self:GetChildGameObject("Panel/Time")
	self.TimeImage = self:GetChildComponent("Panel/Time", "Image")
	self.Name = self:GetChildComponent("Panel/Name", "Image")
	self.BattleText = self:GetChildComponent("Panel/Main/Battle/Button/Text", "Text")
	self.BattleArrow = self:GetChildComponent("Panel/Main/Battle/Button/Image", "Image")
	self.ImgShopRes = self:GetChildComponent("Panel/Main/BtnShop/ItemCount/Image", "Image")
	self.TxtShopResNum = self:GetChildComponent("Panel/Main/BtnShop/ItemCount/TextNum", "Text")
	self.GoBossHighPrize = self:GetChildGameObject("Panel/Main/Boss/HighPrize")
	self.GoNormalHighPrize = self:GetChildGameObject("Panel/Main/Battle/HighPrize")
	self.TxtChallengeNum = self:GetChildComponent("Panel/Main/Boss/TxtChallengeNum", "Text")
	self.TextNeedNum = self:GetChildComponent("Panel/Main/Boss/ItemCount/TextNum", "Text")
	self.ImageNeedIcon = self:GetChildComponent("Panel/Main/Boss/ItemCount/Image", "Image")
	self.BossMask = self:GetChildComponent("Panel/Main/Boss/Mask", "Image")
	self.Lock = self:GetChildGameObject("Panel/Main/Boss/Mask/Lock")
	self.LockText = self:GetChildComponent("Panel/Main/Boss/Mask/Lock/Text", "Text")
	self.CloseObj = self:GetChildGameObject("Panel/Main/Boss/Mask/Close")
	self.CloseTip = self:GetChildComponent("Panel/Main/Boss/Mask/Close/EndTip", "Text")
	self.CloseTime = self:GetChildComponent("Panel/Main/Boss/Mask/Close/EndTime", "Text")
	self.BossTip = self:GetChildComponent("Panel/Main/Boss/Tip", "Image")
	self.BossDropItem = self:GetChildComponent("Panel/Main/Boss/Tip/Text/Image", "Image")
	self.DropTip = self:GetChildComponent("Panel/Main/Boss/Tip/Text", "Text")
	self.BgGroup = self:GetChildGameObject("Panel/Main/Boss/BgGroup")
	self.ItemIcon = self:GetChildComponent("Panel/Main/BtnShop/ItemIcon", "Image")

	self:UpdatePanel()
	self:UpdatePoolRes()

	if not self.infoActive:IsPlayOpen() then
		self:UpdateActiveEnd()
	else
		self:InitBossListPanl()
	end
end

function PageBossActivity:DealWithLocalization()
	local txtAuto

	txtAuto = self:GetChildComponent("Panel/Main/Battle/Button/Text", "Text")
	txtAuto.text = _("Desc_GoToBattle")
	txtAuto = self:GetChildComponent("Panel/Main/BtnShop/Btn/Text", "Text")
	txtAuto.text = _("Desc_ActivityDraw")
	txtAuto = self:GetChildComponent("Panel/Main/Boss/Mask/Close/EndText", "Text")
	txtAuto.text = _("RaidBoss_Close_Tip_Tital")
	txtAuto = self:GetChildComponent("Panel/Main/Battle/TextNum", "Text")
	txtAuto.text = _("Desc_ActivityKeyDrop")
	txtAuto = self:GetChildComponent("Panel/Main/Boss/ItemCount/Text", "Text")
	txtAuto.text = _("Desc_Have")
	txtAuto = self:GetChildComponent("Panel/Main/BtnShop/ItemCount/Text", "Text")
	txtAuto.text = _("Desc_Have")
	txtAuto = self:GetChildComponent("Panel/Story/Text", "Text")
	txtAuto.text = _("PageChapter_title")
end

function PageBossActivity:PlayBackAni(callback)
	self.Animator:Play("PanelBossActivity_Hide")
	callback(1)
end

function PageBossActivity.GetCurBossActive()
	local list = ActiveMgr:GetOpenActiveByType(3)

	return list[1]
end

function PageBossActivity.EndActiveBackMain()
	UIMgr.ClearMain()
	UIMgr.SwitchPanel(PageMainStage, nil, true)
	UIMgr.ShowMsg(_("Msg_Active_Over"))
end

function PageBossActivity:UpdatePanel()
	self.infoActive = self.GetCurBossActive()

	if self.infoActive == nil then
		return
	end

	local infoChapter = ChapterMgr:GetChapter(self.infoActive.bossChapterId)

	self.listStage = infoChapter.listStage

	self:CheckNewUnlock()
	self.GoBossHighPrize:SetActive(self.infoActive:HaveDailyReward(eBossActiveType.boss))

	self.TxtChallengeNum.text = Lang(12470) .. ActiveChapterMgr.GetActiveRemainingChallengeNum(eBossActiveType.boss) .. "/" .. ActiveChapterMgr.GetSingleLimitChallengeNum(eBossActiveType.boss)

	local costItem = self.listStage[1].data.CostItem

	self.TextNeedNum.text = ItemManager:GetItemCount(costItem[1])

	UIUtil.SetImageSprite(self.ImageNeedIcon, ItemManager:GetIcon(costItem[1]), self)

	self.Time.text = self:GetTime(self.infoActive.data.StartTime) .. "~" .. self:GetTime(self.infoActive.data.EndTime)

	local UIData = BossActiveUIData[self.infoActive.id]

	UIUtil.SetImageSprite(self.Icon, UIData.TitalImage, self, true)
	GOUtil.SetRectTransformAnchoredPosition(self.Icon.gameObject, UIData.TitalPos[1], UIData.TitalPos[2])

	self.Time.color = getColorFromString(UIData.TimePos[3])
	self.TimeImage.color = getColorFromString(UIData.TimePos[4])

	GOUtil.SetRectTransformAnchoredPosition(self.TimeObj, UIData.TimePos[1], UIData.TimePos[2])
	UIUtil.SetImageSprite(self.BattleIcon, UIData.BattleImage, self)
	UIUtil.SetImageSprite(self.BossIcon, UIData.BossImage, self)
	UIUtil.SetImageSprite(self.BossTip, UIData.BossLineImage, self)
	UIUtil.SetImageSprite(self.ShopIcon, UIData.ShopImage, self)
	UIUtil.SetImageSprite(self.StoryIcon, UIData.StoryImage, self)

	if UIData.SignName ~= "" then
		UIUtil.SetImageSprite(self.Name, UIData.SignName, self, true)
		GOUtil.SetRectTransformAnchoredPosition(self.Name.gameObject, UIData.NamePos[1], UIData.NamePos[2])
	else
		SetActiveFunc(self.Name.gameObject, false)
	end

	UIUtil.SetImageSprite(self.LittleTitalImage, UIData.SubTitalImage, self)
	GOUtil.SetRectTransformAnchoredPosition(self.LittleTitalImage.gameObject, UIData.SubTitalDescPos[1], UIData.SubTitalDescPos[2])
	GOUtil.SetRectTransformSizeDelta(self.LittleTitalImage.gameObject, UIData.SubTitalDescLength[1], UIData.SubTitalDescLength[2])

	self.Desc.text = Lang(UIData.SubTitalDesc)
	self.Desc.color = getColorFromString(UIData.SubTitalDescPos[3])
	self.BossMask.color = getColorFromString(UIData.BossUnlockColor[1], UIData.BossUnlockColor[2])
	self.BattleArrow.color = getColorFromString(UIData.BattleColor)
	self.BattleText.color = getColorFromString(UIData.BattleColor)
end

function PageBossActivity:CheckNewUnlock()
	self.changeList = {}

	local unlockList = {}

	for key, value in pairs(self.listStage) do
		if value.isUnLock then
			unlockList[key] = "true"
		end
	end

	local oldList = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_BOSSACTIVITY_ENTER_STATE)

	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_BOSSACTIVITY_ENTER_STATE, unlockList)

	if #oldList == #unlockList then
		for key, value in pairs(unlockList) do
			if value ~= oldList[key] then
				self.changeList[key] = key
			end
		end
	end
end

function PageBossActivity:UpdatePoolRes()
	local list = ActiveCardPoolMgr:GetAll(self.infoActive.id)
	local info = list[#list - 1]
	local itemId = info.data.OneCost[1]
	local infoItem = ItemManager:Get(itemId)

	UIUtil.SetImageSprite(self.ImgShopRes, infoItem.data.Icon .. "_S", self)
	UIUtil.SetImageSprite(self.BossDropItem, infoItem.data.Icon .. "_S", self)

	self.DropTip.text = infoItem:GetNameAndDesc() .. _("Desc_ActivityDrop")
	self.TxtShopResNum.text = infoItem:GetNum()

	UIUtil.SetImageSprite(self.ItemIcon, info.listItem[2][1].data.Icon, self)
end

function PageBossActivity:InitBossListPanl()
	local scrollArea = self:GetChildGameObject("Panel/Main/Boss/BgGroup/ScrollArea")
	local content = self:GetChildComponent("Panel/Main/Boss/BgGroup/ScrollArea/Content", "RectTransform")
	local count = #self.listStage

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellBossStage, CellBossStage, self, false)

	local posY = StageScrollViewPosMgr.GetPosY(eScrollViewPosType.partyBoss)

	if posY ~= 0 then
		self.UIScrollTool:SetInitPos(Vector3(0, posY, 0))
	end

	ChapterMgr.bossIndex = 0

	if self.listStage[1]:IsOpen() then
		SetActiveFunc(self.BgGroup, true)
		SetActiveFunc(self.BossMask, false)
		SetActiveFunc(self.BossTip.gameObject, false)
	else
		SetActiveFunc(self.BgGroup, false)
		SetActiveFunc(self.BossMask, true)
		SetActiveFunc(self.BossTip.gameObject, true)
		SetActiveFunc(self.Lock, true)
		SetActiveFunc(self.CloseObj, false)
		SetActiveFunc(self.GoBossHighPrize, false)

		local unlockInfo = ActiveMgr:GetUnlockStoryStage(self.listStage[1].id)
		local infoChapter = ChapterMgr:GetChapter(unlockInfo.data.ChapterID)

		if unlockInfo.data.Type == StageFromType.activeCommon then
			self.LockText.text = string.format(_("Dance_LockHint"), " " .. _("Desc_ActiveCommon") .. "-" .. Lang(unlockInfo.data.Name) .. " ")
		else
			self.LockText.text = string.format(_("Dance_LockHint"), " " .. Lang(infoChapter.data.Name) .. "-" .. Lang(unlockInfo.data.Name) .. " ")
		end
	end
end

function PageBossActivity:UpdateActiveEnd()
	SetActiveFunc(self.BgGroup, false)
	SetActiveFunc(self.BossMask, true)
	SetActiveFunc(self.Lock, false)
	SetActiveFunc(self.CloseObj, true)
	SetActiveFunc(self.TimeObj, false)
	SetActiveFunc(self.BossTip.gameObject, false)
	SetActiveFunc(self.GoBossHighPrize, false)
	SetActiveFunc(self.BtnStage, false)
	SetActiveFunc(self.StageClose, true)

	self.CloseTip.text = Lang(self.infoActive.data.RuleWord)

	local endTime = self:GetHourTime(self.infoActive.data.EndTime)
	local closeTime = self:GetHourTime(self.infoActive.data.CloseTime)

	self.CloseTime.text = string.format(_("BossActive_CloseTime"), endTime, closeTime)
end

function PageBossActivity:UpdateCell(item, index)
	local infoStage = self.listStage[index]

	infoStage.showEffect = self.changeList[index]
	self.changeList[index] = nil

	item:UpdateData(infoStage)
end

function PageBossActivity:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCellBossStage)
end

function PageBossActivity:OnClickedCellBossStage(data)
	local go = data.pointerPressRaycast.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local infoStage = self.listStage[index]
	local isOpen, msg = infoStage.isUnLock, Lang(5000004)

	if not isOpen then
		local infoChapter = ChapterMgr:GetChapterByStage(infoStage.data.ID)

		if table.contains(infoChapter.data.InitStage, infoStage.data.ID) then
			isOpen = true
		end
	end

	if not isOpen then
		UIMgr.ShowMsg(msg)

		return
	end

	if infoStage.data.ActType == 20 and infoStage:GetLeftPlayNum() == 0 then
		UIMgr.ShowMsg(_("Activity_BossFinish"))

		return
	end

	if infoStage.data.ActType == 20 then
		ChapterRDL.PartyRDL.DealBossClick()
		SetActiveFunc(info.Item.GoDot, false)
	end

	local posY = 0

	if not infoStage:IsNew() then
		posY = self.UIScrollTool.ScrollView.content.anchoredPosition.y
	end

	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.partyBoss, posY)

	ChapterMgr.bossIndex = index
	ChapterMgr.PageCombatReadinessType = 2

	UIMgr.AddPanel(PageCombatReadiness(), {
		stageId = infoStage.id
	})
end

function PageBossActivity:OnClickedBtnStory()
	if PageBossActivity.GetCurBossActive() == nil then
		PageBossActivity.EndActiveBackMain()
	else
		UIMgr.AddPanel(PageBossActivityStory())
		self:Close()
	end
end

function PageBossActivity:OnClickedBtnStage()
	if PageBossActivity.GetCurBossActive() == nil then
		PageBossActivity.EndActiveBackMain()
	else
		UIMgr.AddPanel(PageBossActivityStage())
		self:Close()
	end
end

function PageBossActivity:OnClickedBtnShop()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			UIMgr.SwitchPanel(PageBossActivityShop, {
				activeId = self.infoActive.id,
				pools = vPBMessage.pools
			})
			self:Close()
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	if PageBossActivity.GetCurBossActive() == nil then
		PageBossActivity.EndActiveBackMain()
	else
		NetManager:RequestGetActityPool(self.infoActive.id, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	end
end

function PageBossActivity:OnClickedBtnInfo()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.EventStage)
end

function PageBossActivity:OnUpdateStageNum()
	if self.UIScrollTool then
		self.UIScrollTool:UpdateListDataKeepPos(self.listStage)
	end
end

function PageBossActivity:GetTime(strTime)
	local str = ""
	local a = string.split(strTime, " ")

	if #a > 0 then
		local date = string.split(a[1], "-")
		local yearT = tonumber(date[1])
		local monthT = tonumber(date[2])
		local dayT = tonumber(date[3])

		str = string.format(_("Desc_TimeShow"), monthT, dayT)
	end

	return str
end

function PageBossActivity:GetHourTime(strTime)
	local str = ""
	local a = string.split(strTime, " ")

	if #a > 0 then
		local date = string.split(a[1], "-")
		local yearT = tonumber(date[1])
		local monthT = tonumber(date[2])
		local dayT = tonumber(date[3])
		local hour = string.sub(a[2], 1, 5)

		str = monthT .. "/" .. dayT .. " " .. hour
	end

	return str
end

function PageBossActivity:NotifyUpdate()
	local costItem = self.listStage[1].data.CostItem

	self.TextNeedNum.text = ItemManager:GetItemCount(costItem[1])

	local list = ActiveCardPoolMgr:GetAll(self.infoActive.id)
	local info = list[#list - 1]
	local itemId = info.data.OneCost[1]
	local infoItem = ItemManager:Get(itemId)

	self.TxtShopResNum.text = infoItem:GetNum()
end

function PageBossActivity:OnBackAndroid()
	local exitPanel = self:GetChildPanel("DlgExit")

	if exitPanel then
		exitPanel:OnClickedBtnReturn()
	end
end
