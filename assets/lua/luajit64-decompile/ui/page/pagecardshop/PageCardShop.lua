-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/PageCardShop.lua

require("UI/Page/PageCardShop/CellRoleSign")
require("UI/Page/PageCardShop/CellStep")
require("UI/Page/PageCardShop/CellStepGroup")
require("UI/Page/PageCardShop/CellChooseTab")
require("UI/Page/PageCardShop/CellCardPool")
require("UI/Page/PageCardShop/DlgCardShopInfo")
require("UI/Page/PageCardShop/DlgDrawCard")
require("Info/InfoCardPool")
require("UI/Page/PageRoleCard/Page/PageRoleCard")
require("UI/Page/PageCardShop/DlgScoreShop")
require("UI/Page/PageCardShop/UICardPoolAlbum")
require("UI/Page/PageCardShop/UICardPoolStepUpAlbum")

PageCardShop = class("PageCardShop", UIPanel)
PageCardShop.enterImmediate = false
PageCardShop.needTips = true

function PageCardShop:ctor()
	self.UIPrefabPath = "UI/PageCardShop/PanelCardShop"
	self.dlgExit = DlgExit()

	self:AddChildPanel(self.dlgExit, {
		title = _("CardShop_Draw"),
		callback = self.OnBack,
		panel = self
	})

	self.dlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.dlgAssetsInfo, {
		x = -700,
		y = -42,
		AssetInfos = {
			510,
			502,
			501
		}
	})
end

function PageCardShop:OnBack()
	UIMgr.PopPanel()
	CardPoolManager:ResetNeedShow()
end

function PageCardShop:helpCallback()
	local info = self.curInfo

	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			UIMgr.AddPanel(DlgCardShopInfo(), {
				info = info,
				probDetail = vPBMessage.probDetail,
				tenProbDetail = vPBMessage.tenProbDetail
			})
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestCardPoolInfo(self.curInfo.data.ID, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageCardShop:Purge()
	PageCardShop.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.UIStepUpScrollTool then
		self.UIStepUpScrollTool:Purge()

		self.UIStepUpScrollTool = nil
	end

	UITweenUtil.RemoveTween(self.content)
	self:OnUnRegisterCell()

	if self.goDiceStart then
		Object.Destroy(self.goDiceStart)
	end

	if self.PrefabCellCardPool then
		ResourceMgr.Unload(self.PrefabCellCardPool)

		self.PrefabCellCardPool = nil
	end

	if self.PrefabCellRoleSign then
		ResourceMgr.Unload(self.PrefabCellRoleSign)

		self.PrefabCellRoleSign = nil
	end

	if self.PrefabThrowDiceStart then
		ResourceMgr.Unload(self.PrefabThrowDiceStart)

		self.PrefabThrowDiceStart = nil
	end

	if self.PrefabCellStep then
		ResourceMgr.Unload(self.PrefabCellStep)

		self.PrefabCellStep = nil
	end

	if self.PrefabCellChooseTab then
		ResourceMgr.Unload(self.PrefabCellChooseTab)

		self.PrefabCellChooseTab = nil
	end

	if self.UIAlbum then
		self.UIAlbum:Purge()

		self.UIAlbum = nil
	end

	if self.NewTurnTimer then
		TimerMgr.RemoveTimer(self.NewTurnTimer)
	end

	if self.CellChooseCardList then
		for i, v in ipairs(self.CellChooseCardList) do
			self:RemoveClick(v.UIRootObject, self.OnClickChooseCard)
		end

		self.CellChooseCardList = nil
	end

	self.dlgExit = nil
	self.dlgAssetsInfo = nil
	PageCardShop.selectIndex = nil

	self:UnloadRef()
	SoundMgr.UnloadBank(PATH_BANK_CARDSHOPGET)
	SoundMgr.UnloadBank(PATH_BANK_DRAWCARD)
	SoundMgr.UnloadBank(PATH_BANK_CARDSHOPRESULT)
	SoundMgr.UnloadBank(PATH_BANK_DRAWCARDUR)
end

function PageCardShop:PreLoad()
	PageCardShop.base.PreLoad(self)
	self:LoadResAsync("UI/PageCardShop/CellCardPool", "PrefabCellCardPool")
	self:LoadResAsync("UI/PageCardShop/CellRoleSign", "PrefabCellRoleSign")
	self:LoadResAsync("UI/PageCardShop/CellStep", "PrefabCellStep")
	self:LoadResAsync("UI/PageCardShop/CellChooseTab", "PrefabCellChooseTab")
	self:LoadResAsync("UI/PageCardShop/CellChooseCard", "PrefabCellChooseCard")
	self:LoadResAsync("UI/PageCardShop/CellStepGroup", "PrefabCellStepGroup")
	self:LoadResAsync("Battle/Common/ThrowDice/ThrowDice_Start", "PrefabThrowDiceStart", GameObject)
end

function PageCardShop.InitNetData(isSync)
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:GetSyncResource(function()
		LoadingMgr.Hide(eLoadingType.Repeat)

		if not CardPoolManager.init then
			local function callback(vPBMessage)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vPBMessage.result.code == NetManager.Result_Sucess then
					CardPoolManager.init = true

					for i, v in ipairs(vPBMessage.poolInfo) do
						CardPoolManager:Get(v.poolId):SetData(v)
					end

					PageCardShop.selectChooseIndex = nil
					PageCardShop.selectChooseCardTurn = nil

					UIMgr.SwitchPanel(PageCardShop, nil, false, isSync)
				elseif vPBMessage.result.code == NetManager.Result_Maintain then
					UIMgr.ShowMsg(_("Desc_FuncFobid"))
				else
					UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
				end
			end

			NetManager:RequestDrawCardPool(callback)
			LoadingMgr.Show(eLoadingType.Repeat)
		else
			PageCardShop.selectChooseIndex = nil
			PageCardShop.selectChooseCardTurn = nil

			UIMgr.SwitchPanel(PageCardShop, nil, false, isSync)
		end
	end)
end

function PageCardShop:OnEnter(vParam)
	local canvas = GOUtil.AddMissingComponent(self.dlgAssetsInfo.UIRootObject, "Canvas")

	canvas.overrideSorting = true
	canvas.sortingOrder = 10

	GOUtil.AddMissingComponent(self.dlgAssetsInfo.UIRootObject, "GraphicRaycaster")
	SoundMgr.LoadBank(PATH_BANK_CARDSHOPGET, false, false)
	SoundMgr.LoadBank(PATH_BANK_DRAWCARD, false, false)
	SoundMgr.LoadBank(PATH_BANK_CARDSHOPRESULT, false, false)
	SoundMgr.LoadBank(PATH_BANK_DRAWCARDUR, false, false)

	self.GoEffect = self:GetChildGameObject("Effect")
	self.Bg = self:GetChildComponent("Panel/Bg", "RawImage")
	self.GoBg = self:GetChildGameObject("Panel/Bg")
	self.CardPoolBg = self:GetChildGameObject("Panel/CardPoolBg")
	self.CanvasGroup = self:GetChildComponent("Panel/CardPoolBg/ActionPanel", "CanvasGroup")
	self.ButtonCheap = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap", "Image")
	self.CheapLastCount = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap/Image/Text", "Text")
	self.CheapItemIcon = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap/Coin/Icon", "Image")
	self.CheapItemNum = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap/Coin/Text", "Text")
	self.ButtonCheapTip2 = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap/Tip2/Text", "Text")
	self.ButtonCheapTip2Obj = self:GetChildGameObject("Panel/CardPoolBg/ActionPanel/ButtonCheap/Tip2")
	self.ButtonOne = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonOne", "Image")
	self.ButtonOneTip2 = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonOne/Tip2/Text", "Text")
	self.ButtonOneTip2Obj = self:GetChildGameObject("Panel/CardPoolBg/ActionPanel/ButtonOne/Tip2")
	self.ButtonTen = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen", "Image")
	self.ButtonTenTip1 = self:GetChildGameObject("Panel/CardPoolBg/ActionPanel/ButtonTen/Tip1")
	self.ButtonTenTip2 = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen/Tip2/Text", "Text")
	self.ButtonTenTip2Obj = self:GetChildGameObject("Panel/CardPoolBg/ActionPanel/ButtonTen/Tip2")
	self.ButtonTenFree = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTenFree", "Image")
	self.ButtonTenFreeReset = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTenFree/TipFree/num", "Image")
	self.ButtonHelp = self:GetChildGameObject("Panel/CardPoolBg/HelpButton")
	self.ButtonDetail = self:GetChildGameObject("Panel/CardPoolBg/DetailButton")
	self.ButtonAddRes = self:GetChildGameObject("Panel/InventoryPanel/Button")
	self.StepCount = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel/StepCount")
	self.StepCountText = self:GetChildComponent("Panel/CardPoolBg/StepUpPanel/StepCount/Text", "Text")
	self.TenCurObj = self:GetChildGameObject("Panel/CardPoolBg/ActionPanel/ButtonTen/Coin")
	self.TenCurItemIcon = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen/Coin/Icon", "Image")
	self.TenCurItemNum = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen/Coin/Text", "Text")
	self.NewTurnOpen = self:GetChildGameObject("Panel/CardPoolBg/NewTurnOpen")
	self.drawTip = self:GetChildGameObject("Panel/CardPoolBg/ActionPanel/Image")
	self.drawTipText = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/Image/Text", "Text")
	self.BtnOneText = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonOne/Text", "Text")
	self.BtnTenText = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen/Text", "Text")
	self.BtnCheapText = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap/Text", "Text")

	local Text

	Text = self:GetChildComponent("Panel/PanelLeftTime/Text", "Text")
	Text.text = _("Desc_LeftTimesToday")
	Text = self:GetChildComponent("Panel/CardPoolBg/ButtonShop/Text", "Text")
	Text.text = _("Desc_Deal")
	Text = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen/Tip1/Text", "Text")
	Text.text = _("Desc_DrawCardSpeTips")
	Text = self:GetChildComponent("Panel/CardPoolBg/DetailButton/Text", "Text")
	Text.text = _("CardShop_CardDetail")
	Text = self:GetChildComponent("Panel/CardPoolBg/HelpButton/Text", "Text")
	Text.text = _("CardShop_PoolInfo")
	self.TextNum1 = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonOne/Cost/TextNum", "Text")
	self.TextNum2 = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen/Cost/TextNum", "Text")
	self.TextLeft = self:GetChildComponent("Panel/PanelLeftTime/TextLeft", "Text")
	self.TextOpenTime = self:GetChildComponent("Panel/TextOpenTime", "Text")
	self.TextCheapNum = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap/Cost/TextNum", "Text")
	self.NotCheapNum = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap/Cost/NotCheapNum", "Text")
	self.ImageCheap = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonCheap/Cost/ImageIcon", "Image")
	self.ImageOne = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonOne/Cost/ImageIcon", "Image")
	self.ImageTen = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen/Cost/ImageIcon", "Image")
	self.NotCheapNumOne = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonOne/Cost/NotCheapNum", "Text")
	self.NotCheapNumTen = self:GetChildComponent("Panel/CardPoolBg/ActionPanel/ButtonTen/Cost/NotCheapNum", "Text")
	self.StepUpPanel = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel")
	self.ChoosePanel = self:GetChildGameObject("Panel/CardPoolBg/ChoosePanel")
	self.PanelRate = self:GetChildGameObject("Panel/CardPoolBg/PanelRate")
	self.TextRate = self:GetChildComponent("Panel/CardPoolBg/PanelRate/Text", "Text")
	self.Effect = self:GetChildGameObject("Effect")
	self.Panel = self:GetChildGameObject("Panel")
	self.ImageBG = self:GetChildGameObject("BG")
	self.ButtonShop = self:GetChildGameObject("Panel/CardPoolBg/ButtonShop")
	self.TextShopNum = self:GetChildComponent("Panel/CardPoolBg/ButtonShop/TextNum", "Text")
	self.ImageShopNumIcon = self:GetChildComponent("Panel/CardPoolBg/ButtonShop/Icon", "Image")
	self.UIStepUpAlbumContent = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel/ScrollArea/Content")
	self.UIStepUpAlbumBefore = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel/Before")
	self.UIStepUpAlbumNext = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel/Next")
	self.TurnImage = self:GetChildComponent("Panel/CardPoolBg/StepUpPanel/StepCount/Open/Turn", "Image")
	self.TurnOpen = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel/StepCount/Open")
	self.TurnTotal = self:GetChildComponent("Panel/CardPoolBg/StepUpPanel/StepCount/Open/Text2", "Text")
	self.TurnLock = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel/StepCount/Lock")
	self.StepUpDragArea = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel/ScrollArea")
	self.UIAlbumContent = self:GetChildGameObject("Panel/CardPoolBg/ChoosePanel/Mask/Content")
	self.UIAlbumBefore = self:GetChildGameObject("Panel/CardPoolBg/ChoosePanel/Before")
	self.UIAlbumNext = self:GetChildGameObject("Panel/CardPoolBg/ChoosePanel/Next")
	self.IdxDot = self:GetChildGameObject("Panel/CardPoolBg/ChoosePanel/Idx")
	self.IdxDotList = self:GetChildGameObject("Panel/CardPoolBg/ChoosePanel/List")
	self.TextEndTime = self:GetChildComponent("Panel/CardPoolBg/EndTime", "Text")
	self.ChooseCardPanel = self:GetChildGameObject("Panel/CardPoolBg/ChooseCardPanel")
	self.ChooseCardContent = self:GetChildGameObject("Panel/CardPoolBg/ChooseCardPanel/List")
	self.ChooseCardBefore = self:GetChildGameObject("Panel/CardPoolBg/ChooseCardPanel/Before")
	self.ChooseCardNext = self:GetChildGameObject("Panel/CardPoolBg/ChooseCardPanel/Next")
	self.ChooseCardLineBg = self:GetChildComponent("Panel/CardPoolBg/ChooseCardPanel/LineBg", "Image")
	self.listCardPool = CardPoolManager:GetAll()
	self.selectIndex = 1

	if PageCardShop.selectIndex then
		self.selectIndex = PageCardShop.selectIndex
	elseif InstructionMgr:IsGuidePassed() and not InstructionMgr:IsInGuide() and PlayerInst.InfoPlayer:CanFreeDraw() then
		for i = 1, #self.listCardPool do
			if PlayerInst.InfoPlayer:CanFreeDrawPool(self.listCardPool[i].id) then
				self.selectIndex = i

				break
			end
		end
	end

	self:UpdateCardPool()
	self:InitScrollView()

	self.ButtonSkip = self:GetChildGameObject("ButtonSkip")
	self.PanelAni = self:GetChildComponent("Panel", "Animator")

	local isFirst = not InstructionMgr:IsPassed(5)

	if isFirst then
		SetActiveFunc(SceneMainStage.Instance.Scene.Object, false)
		self:OnPlayFirstVideo()
	else
		SetActiveFunc(SceneMainStage.Instance.Scene.Object, false)
		SetActiveFunc(self.UIRootObject, true)

		PageCardShop.enterImmediate = false

		self.PanelAni:Play("FX_CardShopPanel", 0, 0)
		SetActiveFunc(self.ButtonSkip, false)
		self:LoadSpine()
	end
end

function PageCardShop:OnPlayFirstVideo()
	if self.goDiceStart == nil then
		self.goDiceStart = GOUtil.InstantiatePrefab(self.PrefabThrowDiceStart, nil)
		self.playableDirector = GOUtil.GetComponent(self.goDiceStart, "PlayableDirector")

		EventListenerMgr.AddPlayableDirectorListener(self.goDiceStart.gameObject, self.OnStopped, self, ePlayableDirectorEvent.OnStopped)
		EventListenerMgr.AddTimelineMarkerListener(self.goDiceStart.gameObject, self.OnPlayDirectSound, self, "SOUND")

		self.playableActor = GOUtil.FindChildComponent(self.goDiceStart, "GoActor", "Actor")
	end

	SetActiveFunc(self.goDiceStart, true)
	self.playableDirector:Play()
	SetActiveFunc(self.ButtonSkip, true)
	SetActiveFunc(self.dlgExit.UIRootObject, false)
	SetActiveFunc(self.dlgAssetsInfo.UIRootObject, false)
	SetActiveFunc(self.Effect, false)
	SetActiveFunc(self.Panel, false)
	SetActiveFunc(self.ImageBG, false)
end

function PageCardShop:OnPlayDirectSound(playable, event)
	local ActorLipSync = GOUtil.AddMissingComponent(self.playableActor.Root, "ActorLipSync")

	ActorLipSync:Init("Actors/Lips/VOX_GCA_0170")
	ActorLipSync:Play(self.playableActor, event.StringValue)
end

function PageCardShop:OnStopped(playableDirector)
	if playableDirector then
		playableDirector:Stop()
	end

	SetActiveFunc(self.UIRootObject, true)
	InstructionMgr:TriggerWait("ShowCardShopPanel")
	SetActiveFunc(self.ButtonSkip, false)
	SetActiveFunc(self.dlgExit.UIRootObject, true)
	SetActiveFunc(self.dlgAssetsInfo.UIRootObject, true)
	SetActiveFunc(self.Effect, true)
	SetActiveFunc(self.Panel, true)
	SetActiveFunc(self.ImageBG, true)
	SetActiveFunc(self.goDiceStart, false)
	UITweenUtil.CommonTweenRight(self.content, 40, 0.14)
	self:LoadSpine()
	self.PanelAni:Play("FX_CardShopPanel", 0, 0)
end

function PageCardShop:OnButtonSkip()
	self:OnStopped(self.playableDirector)
end

function PageCardShop:OnRegisterEvent()
	self:AddClick(self.ButtonOne.gameObject, self.OnButtonOne)
	self:AddClick(self.ButtonCheap.gameObject, self.OnButtonCheap)
	self:AddClick(self.ButtonTen.gameObject, self.OnButtonTen)
	self:AddClick(self.ButtonTenFree.gameObject, self.OnButtonTen)
	self:AddClick(self.ButtonHelp, self.helpCallback)
	self:AddClick(self.ButtonAddRes, self.OnButtonAddRes)
	self:AddClick(self.ButtonShop, self.OnButtonShop)
	self:AddClick(self.ButtonSkip, self.OnButtonSkip)
	self:AddClick(self.UIAlbumBefore, self.OnButtonUIAlbumBefore)
	self:AddClick(self.UIAlbumNext, self.OnButtonUIAlbumNext)
	self:AddClick(self.UIStepUpAlbumBefore, self.OnButtonUIStepUpAlbumBefore)
	self:AddClick(self.UIStepUpAlbumNext, self.OnButtonUIStepUpAlbumNext)
	self:AddClick(self.ButtonDetail, self.OnClickedCellDetail)
	self:AddClick(self.ChooseCardNext, self.OnClickChooseCardPoolNext)
	self:AddClick(self.ChooseCardBefore, self.OnClickChooseCardPoolBefore)
	Event.Instance:Add("UpdatePoolAndSpine", self.UpdatePoolAndSpine, self)
	Event.Instance:Add("ShowEffect", self.ShowEffect, self)
	Event.Instance:Add("UpdateMonthCard", self.UpdateMonthCard, self)
	Event.Instance:Add("OnPlayFirstVideo", self.OnPlayFirstVideo, self)
	Event.Instance:Add("UpdateCardPool", self.JpUpdateCardPool, self)
	self:AddListener(self.StepUpDragArea, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:AddListener(self.StepUpDragArea, self.OnDrag, EventTriggerType.Drag)
	self:AddListener(self.StepUpDragArea, self.OnEndDrag, EventTriggerType.EndDrag)
	self:AddListener(self.ChooseCardContent, self.OnChooseCardBeginDrag, EventTriggerType.BeginDrag)
	self:AddListener(self.ChooseCardContent, self.OnChooseCardDrag, EventTriggerType.Drag)
	self:AddListener(self.ChooseCardContent, self.OnChooseCardEndDrag, EventTriggerType.EndDrag)
end

function PageCardShop:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonOne.gameObject, self.OnButtonOne)
	self:RemoveClick(self.ButtonCheap.gameObject, self.OnButtonCheap)
	self:RemoveClick(self.ButtonTen.gameObject, self.OnButtonTen)
	self:RemoveClick(self.ButtonTenFree.gameObject, self.OnButtonTen)
	self:RemoveClick(self.ButtonHelp, self.helpCallback)
	self:RemoveClick(self.ButtonAddRes, self.OnButtonAddRes)
	self:RemoveClick(self.ButtonShop, self.OnButtonShop)
	self:RemoveClick(self.ButtonSkip, self.OnButtonSkip)
	self:RemoveClick(self.UIAlbumBefore, self.OnButtonUIAlbumBefore)
	self:RemoveClick(self.UIAlbumNext, self.OnButtonUIAlbumNext)
	self:RemoveClick(self.UIStepUpAlbumBefore, self.OnButtonUIStepUpAlbumBefore)
	self:RemoveClick(self.UIStepUpAlbumNext, self.OnButtonUIStepUpAlbumNext)
	self:RemoveClick(self.ButtonDetail, self.OnClickedCellDetail)
	self:RemoveClick(self.ChooseCardNext, self.OnClickChooseCardPoolNext)
	self:RemoveClick(self.ChooseCardBefore, self.OnClickChooseCardPoolBefore)
	Event.Instance:Remove("UpdatePoolAndSpine", self.UpdatePoolAndSpine, self)
	Event.Instance:Remove("ShowEffect", self.ShowEffect, self)
	Event.Instance:Remove("UpdateMonthCard", self.UpdateMonthCard, self)
	Event.Instance:Remove("OnPlayFirstVideo", self.OnPlayFirstVideo, self)
	Event.Instance:Remove("UpdateCardPool", self.JpUpdateCardPool, self)
	self:RemoveListener(self.StepUpDragArea, self.OnBeginDrag, EventTriggerType.BeginDrag)
	self:RemoveListener(self.StepUpDragArea, self.OnDrag, EventTriggerType.Drag)
	self:RemoveListener(self.StepUpDragArea, self.OnEndDrag, EventTriggerType.EndDrag)
	self:RemoveListener(self.ChooseCardContent, self.OnChooseCardBeginDrag, EventTriggerType.BeginDrag)
	self:RemoveListener(self.ChooseCardContent, self.OnChooseCardDrag, EventTriggerType.Drag)
	self:RemoveListener(self.ChooseCardContent, self.OnChooseCardEndDrag, EventTriggerType.EndDrag)
end

function PageCardShop:InitStepUpScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/CardPoolBg/StepUpPanel/ScrollArea")
	local content = self:GetChildComponent("Panel/CardPoolBg/StepUpPanel/ScrollArea/Content", "Transform")
	local count = #self.StepUpList

	local function addClick(item, index)
		return
	end

	local function updateTab(item, index)
		local beforeCount

		if index > 1 then
			beforeCount = self.StepUpList[index - 1].data.StepUpOrder
		end

		item:UpdateData(self.StepUpList[index], self.curInfo.data.StepUpOrder, index == #self.StepUpList, beforeCount)
	end

	self.UIStepUpScrollTool = UIScrollTool()

	self.UIStepUpScrollTool:InitList(ScrollArea, content, count, self.PrefabCellStep, CellStep, self, true, addClick, updateTab)
end

function PageCardShop:InitStepUpAlbum()
	local listData = self.StepUpSortList

	if self.UIStepUpAlbum then
		GOUtil.DestroyAllChildren(self.UIStepUpAlbumContent)
		Object.DestroyImmediate(GOUtil.GetComponent(self.UIStepUpAlbumContent, "UISelector"))
		self.UIStepUpAlbum:Purge()

		self.UIStepUpAlbum = nil
	end

	self.UIStepUpAlbum = UICardPoolStepUpAlbum()

	local count = #self.StepUpSortList
	local index = self.curInfo.data.StepUpTurn

	self.UIStepUpAlbum:Init(self.UIStepUpAlbumContent, listData, self.PrefabCellStepGroup, CellStepGroup, self.PrefabCellStep, self.curInfo.data.StepUpOrder, self.curInfo.data.StepUpTurn, self, index - 1)
end

function PageCardShop:UpdateStepUpArrow(index)
	self.stepUpIndex = index

	if self.curInfo.needShow then
		self.StepCountText.text = _("Desc_StepCountFinish")

		SetActiveFunc(self.TurnOpen, false)
	else
		SetActiveFunc(self.TurnOpen, true)

		self.StepCountText.text = ""

		UIUtil.SetImageSprite(self.TurnImage, "UI/PageCardShop/AtlasStepUp/bg_cardpool_step_num_0" .. index, self, true)
	end

	self.TurnTotal.text = "/" .. #self.StepUpSortList .. "周目"

	SetActiveFunc(self.TurnLock, index > self.curInfo.data.StepUpTurn)
	SetActiveFunc(self.UIStepUpAlbumBefore, index ~= 1)
	SetActiveFunc(self.UIStepUpAlbumNext, index ~= #self.StepUpSortList)
end

function PageCardShop:InitChooseAlbum()
	local listData = self.ChooseList

	GOUtil.DestroyAllChildren(self.IdxDotList)

	if self.UIAlbum then
		GOUtil.DestroyAllChildren(self.UIAlbumContent)
		Object.DestroyImmediate(GOUtil.GetComponent(self.UIAlbumContent, "UISelector"))
		self.UIAlbum:Purge()

		self.UIAlbum = nil
	end

	self.GoIdxShow = {}

	for i = 1, #self.ChooseList do
		local go = GOUtil.Instantiate(self.IdxDot, self.IdxDotList)

		SetActiveFunc(go, true)

		go.name = i

		local g = GOUtil.FindChildGameObject(go, "Image")

		table.insert(self.GoIdxShow, g)
	end

	self.UIAlbum = UICardPoolAlbum()

	local count = #self.ChooseList

	if PageCardShop.selectChooseIndex then
		self.UIAlbum:Init(self.UIAlbumContent, listData, self.PrefabCellChooseTab, CellChooseTab, self, PageCardShop.selectChooseIndex - 1)
	else
		self.UIAlbum:Init(self.UIAlbumContent, listData, self.PrefabCellChooseTab, CellChooseTab, self, 0)
	end

	for i, v in ipairs(self.ChooseList) do
		if v.data.StepUpOrder == PageCardShop.selectChooseIndex then
			self.curInfo = v
			PageCardShop.selectChooseIndex = nil

			break
		end
	end

	for i, v in ipairs(self.GoIdxShow) do
		SetActiveFunc(v, i == self.curInfo.data.StepUpOrder)
	end
end

function PageCardShop:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")

	self.content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")

	local count = #self.listCardPool

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, self.content, count, self.PrefabCellCardPool, CellCardPool, self, false)
end

function PageCardShop:UpdateCell(item, index)
	item.Index = index

	local info = self.listCardPool[index]

	item:UpdateData(info, self.selectIndex)
end

function PageCardShop:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function PageCardShop:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	if info.Item.Index == self.selectIndex then
		return
	end

	self.selectIndex = info.Item.Index
	PageCardShop.selectIndex = self.selectIndex

	self:UpdateCardPool(true)
	self:LoadSpine()
	self.PanelAni:Play("FX_CardShopPanel", 0, 0)
end

function PageCardShop:OnJumpCell()
	if PageCardShop.selectIndex == self.selectIndex then
		return
	end

	self.selectIndex = PageCardShop.selectIndex

	self:UpdateCardPool(true)
	self:LoadSpine()
	self.PanelAni:Play("FX_CardShopPanel", 0, 0)
end

function PageCardShop:OnButtonUIAlbumNext()
	if self.UIAlbum then
		self.UIAlbum:Next()
	end
end

function PageCardShop:OnButtonUIAlbumBefore()
	if self.UIAlbum then
		self.UIAlbum:Previous()
	end
end

function PageCardShop:OnButtonUIStepUpAlbumBefore()
	if self.UIStepUpAlbum then
		self.UIStepUpAlbum:Previous()
	end
end

function PageCardShop:OnButtonUIStepUpAlbumNext()
	if self.UIStepUpAlbum then
		self.UIStepUpAlbum:Next()
	end
end

function PageCardShop:OnButtonOne()
	self:DrawCard(1)
end

function PageCardShop:OnButtonTen()
	self:DrawCard(2)
end

function PageCardShop:OnButtonCheap()
	self:DrawCard(0)
end

function PageCardShop:OnButtonAddRes()
	require("UI/Page/PageShop/PageShop")
	PageShop.InitNetData({
		tagIndex = 1,
		tabMainIndex = tabMainType.package
	})
end

function PageCardShop.JpDrawCost(info, type, costItemId, infoItem, needNum)
	if not PageCardShop.HasEnough(costItemId, needNum) then
		if type == 1 then
			if info.data.OneCost and #info.data.OneCost > 2 then
				costItemId = info.data.OneCost[3]
				needNum = info.data.OneCost[4]
				infoItem = ItemManager:Get(costItemId)
			end
		elseif type == 0 then
			if info.data.OneDiscount and #info.data.OneDiscount > 2 then
				costItemId = info.data.OneDiscount[3]
				needNum = info.data.OneDiscount[4]
				infoItem = ItemManager:Get(costItemId)
			end
		elseif info.data.TenCost and #info.data.TenCost > 2 then
			costItemId = info.data.TenCost[3]
			needNum = info.data.TenCost[4]
			infoItem = ItemManager:Get(costItemId)
		end
	end

	return costItemId, infoItem, needNum
end

function PageCardShop.HasEnough(itemId, cost)
	local infoItem = ItemManager:Get(itemId)

	return cost <= infoItem:GetCurResNum()
end

function PageCardShop:JpAdjust(info)
	local cost1 = info.data.OneCost
	local cost2 = info.data.TenCost

	if #cost1 > 1 and not PageCardShop.HasEnough(cost1[1], cost1[2]) and #cost1 > 2 then
		self.TextNum1.text = cost1[4]

		if not info.data.BtnPic[2] or info.data.BtnPic[2] == "" then
			local infoItem2 = ItemManager:Get(cost1[3])
			local pathIcon = GetItemIcon(infoItem2:GetType(), infoItem2.id)

			UIUtil.SetImageSprite(self.ImageOne, pathIcon, self)
		end
	end

	if #cost2 > 1 then
		if not PlayerInst.InfoPlayer:CanFreeDrawPool(info.id) then
			SetActiveFunc(self.ButtonTen.gameObject, true)
		end

		if not PageCardShop.HasEnough(cost2[1], cost2[2]) and #cost2 > 2 then
			self.TextNum2.text = cost2[4]

			if not info.data.BtnPic[3] or info.data.BtnPic[3] == "" then
				local infoItem2 = ItemManager:Get(cost2[3])
				local pathIcon = GetItemIcon(infoItem2:GetType(), infoItem2.id)

				UIUtil.SetImageSprite(self.ImageTen, pathIcon, self)
			end
		end
	end

	if PlayerInst.InfoPlayer:CanFreeDrawPool(info.id) then
		SetActiveFunc(self.ButtonTenFree.gameObject, true)
		SetActiveFunc(self.ButtonTen.gameObject, false)
		UIUtil.SetImageSprite(self.ButtonTenFreeReset, string.format("UI/PageCardShop/AtlasCardShop/font_free_jp_%s", PlayerInst.InfoPlayer.freeDrawInfo.freeDrawCount), self)
	else
		SetActiveFunc(self.ButtonTenFree.gameObject, false)
	end
end

function PageCardShop:JpUpdateCardPool()
	local info = self.curInfo
	local cost1 = info.data.OneCost
	local cost2 = info.data.TenCost

	self.TextNum1.text = cost1[2]
	self.TextNum2.text = cost2[2]

	if info.data.BtnPic[2] and info.data.BtnPic[2] ~= "" then
		UIUtil.SetImageSprite(self.ButtonOne, info.data.BtnPic[2], self)
	else
		UIUtil.SetImageSprite(self.ButtonOne, "UI/PageCardShop/AtlasCardShop/BTN_giant_02b", self)

		if cost1[1] then
			local infoItem = ItemManager:Get(cost1[1])
			local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

			UIUtil.SetImageSprite(self.ImageOne, pathIcon, self)
		end
	end

	if info.data.BtnPic[3] and info.data.BtnPic[3] ~= "" then
		UIUtil.SetImageSprite(self.ButtonTen, info.data.BtnPic[3], self)
		SetActiveFunc(self.ImageTen.gameObject, false)
	else
		UIUtil.SetImageSprite(self.ButtonTen, "UI/PageCardShop/AtlasCardShop/BTN_giant_01b", self)
		SetActiveFunc(self.ImageTen.gameObject, true)

		if cost2[1] then
			local infoItem = ItemManager:Get(cost2[1])
			local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

			UIUtil.SetImageSprite(self.ImageTen, pathIcon, self)
		end
	end

	self:JpAdjust(info)
end

function PageCardShop:UpdateCardPool(keepPos)
	self.listCardPool = CardPoolManager:GetAll()

	local info = self.listCardPool[self.selectIndex]

	if info == nil then
		self.selectIndex = 1
		info = self.listCardPool[self.selectIndex]
	end

	self.curInfo = info

	if self.UIScrollTool then
		if keepPos then
			self.UIScrollTool:UpdateListDataKeepPos(self.listCardPool)
		else
			self.UIScrollTool:UpdateListData(self.listCardPool)
		end
	end

	SetActiveFunc(self.NewTurnOpen, false)
	SetActiveFunc(self.TextEndTime.gameObject, self.curInfo.data.TimeShow == 1)

	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if self.curInfo.data.CreateAccountPoolTime ~= 0 then
		self.endTime = tonumber(PlayerInst.InfoPlayer:GetRegisterTime()) + self.curInfo.data.CreateAccountPoolTime * 3600
	else
		self.endTime = GetTimeTampByString(self.curInfo.data.EndTime)
	end

	local d, h, m, s = GetTimeFormatBySec(self.endTime - curTime)

	if curTime > self.endTime then
		if self.curInfo.data.ActiveType == eCardPoolActiveType.ChooseCardPool and CardPoolManager:CheckItemHaveOpen(self.curInfo) then
			SetActiveFunc(self.TextEndTime.gameObject, false)
		else
			self.TextEndTime.text = _("Activate_Close")
		end
	elseif d > 0 then
		self.TextEndTime.text = _("Desc_RemainingTime") .. "<size=40>" .. d .. "</size>" .. _("Desc_day") .. "<size=40>" .. h .. "</size>" .. _("Desc_hour")
	elseif h + m == 0 then
		self.TextEndTime.text = _("Desc_RemainingLessThanOneSecond")
	else
		self.TextEndTime.text = _("Desc_RemainingTime") .. "<size=40>" .. h .. "</size>" .. _("Desc_hour") .. "<size=40>" .. m .. "</size>" .. _("Desc_minute")
	end

	local cost1 = info.data.OneCost
	local cost2 = info.data.TenCost

	self.TextNum1.text = cost1[2]
	self.TextNum2.text = cost2[2]

	if info.data.PriceOff[3] ~= 0 then
		SetActiveFunc(self.NotCheapNumTen.gameObject, true)

		self.NotCheapNumTen.text = info.data.PriceOff[3]
	else
		SetActiveFunc(self.NotCheapNumTen.gameObject, false)
	end

	local lastCheap = info.lastCheap
	local usedTime = info.usedTime
	local cost = info.data.OneCost

	if not cost[1] then
		cost = info.data.TenCost
	end

	local infoItem = ItemManager:Get(cost[1])

	if infoItem:GetType() == eItemType.P_DIAMOND or infoItem:GetType() == eItemType.P_DIAMOND_PAY then
		self.dlgAssetsInfo:ResetByList({
			502,
			501
		})
	else
		self.dlgAssetsInfo:ResetByList({
			cost[1],
			502,
			501
		})
	end

	self.BtnCheapText.text = Lang(info.data.BtnText[1])
	self.BtnOneText.text = Lang(info.data.BtnText[2])
	self.BtnTenText.text = Lang(info.data.BtnText[3])

	SetActiveFunc(self.ButtonCheap.gameObject, info.data.BtnText[1] ~= 0)
	SetActiveFunc(self.ButtonOne.gameObject, info.data.BtnText[2] ~= 0)
	SetActiveFunc(self.ButtonTen.gameObject, info.data.BtnText[3] ~= 0)
	SetActiveFunc(self.drawTip, false)

	self.TextLeft.text = info.data.DayMaxNum - usedTime

	SetActiveFunc(self.ButtonTenTip1, false)
	SetActiveFunc(self.ButtonCheapTip2Obj, self.curInfo.data.BtnTip[1] ~= 0 and #self.curInfo.data.OneDiscount > 0)
	SetActiveFunc(self.ButtonOneTip2Obj, self.curInfo.data.BtnTip[2] ~= 0 and #self.curInfo.data.OneCost > 0)
	SetActiveFunc(self.ButtonTenTip2Obj, self.curInfo.data.BtnTip[3] ~= 0 and #self.curInfo.data.TenCost > 0)

	self.ButtonCheapTip2.text = Lang(self.curInfo.data.BtnTip[1])
	self.ButtonOneTip2.text = Lang(self.curInfo.data.BtnTip[2])
	self.ButtonTenTip2.text = Lang(self.curInfo.data.BtnTip[3])

	SetActiveFunc(self.PanelRate, false)

	self.curInfo = info
	self.TextOpenTime.text = info.data.OpenTime .. "    " .. info.data.EndTime

	SetActiveFunc(self.ButtonDetail, #self.curInfo.data.CardIconList > 0)

	if info.usedTime >= info.data.DayMaxNum then
		DealWithListRef(self, UIUtil.SetImageGray(self.ButtonTen, 1))
		DealWithListRef(self, UIUtil.SetImageGray(self.ButtonOne, 1))

		self.ButtonTen.raycastTarget = false
		self.ButtonOne.raycastTarget = false
	else
		DealWithListRef(self, UIUtil.SetImageGray(self.ButtonTen, 0))
		DealWithListRef(self, UIUtil.SetImageGray(self.ButtonOne, 0))

		self.ButtonTen.raycastTarget = true
		self.ButtonOne.raycastTarget = true
	end

	if info.data.OneDiscount[1] ~= info.data.OneCost[1] or info.data.OneDiscount[2] ~= info.data.OneCost[2] then
		local infoItem = ItemManager:Get(cost1[1])
		local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)
		local cheapInfoItem = ItemManager:Get(info.data.OneDiscount[1])
		local pathCheapIcon = GetItemIcon(cheapInfoItem:GetType(), cheapInfoItem.id)

		if info.data.BtnPic[1] and info.data.BtnPic[1] ~= "" then
			UIUtil.SetImageSprite(self.ButtonCheap, info.data.BtnPic[1], self)
		else
			UIUtil.SetImageSprite(self.ButtonCheap, "UI/PageCardShop/AtlasCardShop/BTN_giant_02b", self)
		end

		UIUtil.SetImageSprite(self.ImageCheap, pathCheapIcon, self)

		self.CheapItemNum.text = cheapInfoItem:GetCurResNum()

		UIUtil.SetImageSprite(self.CheapItemIcon, pathCheapIcon .. "_S", self, true)
		SetActiveFunc(self.ButtonCheap.gameObject, true)

		self.TextCheapNum.text = info.data.OneDiscount[2]

		if info.data.PriceOff[1] ~= 0 then
			SetActiveFunc(self.NotCheapNum.gameObject, true)

			self.NotCheapNum.text = info.data.PriceOff[1]
		else
			SetActiveFunc(self.NotCheapNum.gameObject, false)
		end

		if info.lastCheap > 0 then
			self.CheapLastCount.text = _("Desc_Times") .. info.lastCheap

			SetActiveFunc(self.ButtonCheap.gameObject, true)
		else
			SetActiveFunc(self.ButtonCheap.gameObject, false)
		end
	else
		SetActiveFunc(self.ButtonCheap.gameObject, false)
	end

	if info.data.PoolType == 2 then
		SetActiveFunc(self.TenCurObj, false)
		SetActiveFunc(self.StepCount, false)
		SetActiveFunc(self.ChoosePanel, false)
		SetActiveFunc(self.ChooseCardPanel, false)
		SetActiveFunc(self.StepUpPanel, false)
	elseif info.data.ActiveType == eCardPoolActiveType.StepUpPool then
		SetActiveFunc(self.StepUpPanel, true)
		SetActiveFunc(self.ChoosePanel, false)
		SetActiveFunc(self.ChooseCardPanel, false)

		local infoItem = ItemManager:Get(cost2[1])
		local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

		if infoItem:GetType() == eItemType.P_DIAMOND_PAY then
			SetActiveFunc(self.TenCurObj, true)

			self.TenCurItemNum.text = infoItem:GetCurResNum()

			UIUtil.SetImageSprite(self.TenCurItemIcon, pathIcon .. "_S", self, true)
		else
			SetActiveFunc(self.TenCurObj, false)
		end

		SetActiveFunc(self.StepCount, true)

		local list = CardPoolManager:GetActivePoolList(info.data.ActiveID)

		if info.needShow then
			SetActiveFunc(self.ButtonCheap.gameObject, false)
			SetActiveFunc(self.ButtonOne.gameObject, false)
			SetActiveFunc(self.ButtonTen.gameObject, false)
			SetActiveFunc(self.drawTip, true)

			self.drawTipText.text = _("StepUp_DrawFinish")
		end

		self:UpdateStepUpPanel()
	elseif info.data.ActiveType == eCardPoolActiveType.ChoosePool then
		SetActiveFunc(self.StepUpPanel, false)
		SetActiveFunc(self.ChooseCardPanel, false)
		SetActiveFunc(self.ChoosePanel, true)
		SetActiveFunc(self.StepCount, false)
		self:UpdateChoosePanel()
	elseif info.data.ActiveType == eCardPoolActiveType.ChooseCardPool then
		SetActiveFunc(self.StepUpPanel, false)
		SetActiveFunc(self.ChooseCardPanel, true)
		SetActiveFunc(self.ChoosePanel, false)
		SetActiveFunc(self.StepCount, false)
		self:UpdateChooseCardPanel()
	else
		SetActiveFunc(self.StepUpPanel, false)
		SetActiveFunc(self.ChoosePanel, false)
		SetActiveFunc(self.ChooseCardPanel, false)
		SetActiveFunc(self.StepCount, false)
		SetActiveFunc(self.TenCurObj, false)
	end

	if info.data.BtnPic[2] and info.data.BtnPic[2] ~= "" then
		UIUtil.SetImageSprite(self.ButtonOne, info.data.BtnPic[2], self)
	else
		UIUtil.SetImageSprite(self.ButtonOne, "UI/PageCardShop/AtlasCardShop/BTN_giant_02b", self)
	end

	if cost1[1] then
		local infoItem = ItemManager:Get(cost1[1])
		local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

		UIUtil.SetImageSprite(self.ImageOne, pathIcon, self)
	end

	if info.data.BtnPic[3] and info.data.BtnPic[3] ~= "" then
		UIUtil.SetImageSprite(self.ButtonTen, info.data.BtnPic[3], self)
	else
		UIUtil.SetImageSprite(self.ButtonTen, "UI/PageCardShop/AtlasCardShop/BTN_giant_01b", self)
	end

	if cost2[1] then
		local infoItem = ItemManager:Get(cost2[1])
		local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

		UIUtil.SetImageSprite(self.ImageTen, pathIcon, self)
	end

	self:JpAdjust(info)
	SetActiveFunc(self.ButtonShop, false)

	self.TextShopNum.text = "0"

	if info.data.ShopId > 0 then
		SetActiveFunc(self.ButtonShop, true)

		local id = info.data.ScoreNum[1]
		local infoItem = ItemManager:Get(id)

		self.TextShopNum.text = infoItem:GetCurResNum()

		UIUtil.SetImageSprite(self.ImageShopNumIcon, infoItem:GetIcon(), self)
	end
end

function PageCardShop:UpdateStepUpPanel(stepUpOrder)
	self.StepUpList = CardPoolManager:GetActivePoolList(self.curInfo.data.ActiveID)
	self.StepUpSortList = CardPoolManager:SortStepUpList(self.StepUpList)

	self:InitStepUpAlbum()
end

function PageCardShop:UpdateChoosePanel()
	self.ChooseList = CardPoolManager:GetActivePoolList(self.curInfo.data.ActiveID)

	for i, v in ipairs(self.ChooseList) do
		if v.usedTime >= v.data.DayMaxNum then
			DealWithListRef(self, UIUtil.SetImageGray(self.ButtonTen, 1))
			DealWithListRef(self, UIUtil.SetImageGray(self.ButtonOne, 1))

			self.ButtonTen.raycastTarget = false
			self.ButtonOne.raycastTarget = false
		end
	end

	self:InitChooseAlbum()
end

function PageCardShop:UpdateChoosePool(data)
	local info = data

	if info.data.ID == self.curInfo.data.ID then
		return
	end

	for i, v in ipairs(self.ChooseList) do
		if v.usedTime >= v.data.DayMaxNum then
			DealWithListRef(self, UIUtil.SetImageGray(self.ButtonTen, 1))
			DealWithListRef(self, UIUtil.SetImageGray(self.ButtonOne, 1))

			self.ButtonTen.raycastTarget = false
			self.ButtonOne.raycastTarget = false
		end

		SetActiveFunc(self.GoIdxShow[i], i == info.data.StepUpOrder)
	end

	self.curInfo = info

	self:LoadSpine()
end

function PageCardShop:UpdateChooseCardPanel()
	local tmpList = CardPoolManager:GetActivePoolList(self.curInfo.data.ActiveID)

	self.ChooseCardList = {}

	for k, v in pairs(tmpList) do
		if not self.ChooseCardList[v.data.StepUpTurn] then
			self.ChooseCardList[v.data.StepUpTurn] = {}
		end

		table.insert(self.ChooseCardList[v.data.StepUpTurn], v)
	end

	for i, v in ipairs(self.ChooseCardList) do
		table.sort(v, function(a, b)
			return a.data.StepUpOrder < b.data.StepUpOrder
		end)
	end

	if PageCardShop.selectChooseCardTurn then
		self.curInfo = self.ChooseCardList[PageCardShop.selectChooseCardTurn][PageCardShop.selectChooseIndex]
		PageCardShop.selectChooseCardTurn = nil
		PageCardShop.selectChooseIndex = nil
	else
		self.curInfo = self.ChooseCardList[1][1]
	end

	if not self.isInitCellChooseCard then
		self.isInitCellChooseCard = true
		self.CellChooseCardList = {}

		for i = 1, 5 do
			local item = {}

			item.UIRootObject = GOUtil.InstantiateUIPrefab(self.PrefabCellChooseCard, self.ChooseCardContent)
			item.CardIcon = GOUtil.FindChildComponent(item.UIRootObject, "Card/CardIcon", "Image")
			item.CardBox = GOUtil.FindChildComponent(item.UIRootObject, "Box", "Image")
			item.CardName = GOUtil.FindChildComponent(item.UIRootObject, "NameBg/Text", "Text")
			item.Select = GOUtil.FindChildGameObject(item.UIRootObject, "Select")
			item.Mask = GOUtil.FindChildGameObject(item.UIRootObject, "Mask")

			local text = GOUtil.FindChildComponent(item.UIRootObject, "Mask/IsGet/Text", "Text")

			text.text = _("CardOwn")

			table.insert(self.CellChooseCardList, i, item)
			self:AddClick(item.UIRootObject, self.OnClickChooseCard)
		end
	end

	self:UpdateCellChooseCard()
	self:UpdateChooseCardPool()
end

function PageCardShop:UpdateCellChooseCard()
	local list = self.ChooseCardList[self.curInfo.data.StepUpTurn]
	local tmpList = CardPoolManager:GetActivePoolList(self.curInfo.data.ActiveID)

	for i, v in ipairs(tmpList) do
		if v.usedTime >= v.data.DayMaxNum then
			DealWithListRef(self, UIUtil.SetImageGray(self.ButtonTen, 1))
			DealWithListRef(self, UIUtil.SetImageGray(self.ButtonOne, 1))

			self.ButtonTen.raycastTarget = false
			self.ButtonOne.raycastTarget = false
		end
	end

	for i = 1, 5 do
		if i > #list then
			SetActiveFunc(self.CellChooseCardList[i].UIRootObject, false)
		else
			SetActiveFunc(self.CellChooseCardList[i].UIRootObject, true)

			local infoRoleCard = RoleCardMgr:GetRoleCard(list[i].data.CardIconList[1])

			UIUtil.SetImageSprite(self.CellChooseCardList[i].CardIcon, infoRoleCard.data.MidIcon, self)
			UIUtil.SetImageSprite(self.CellChooseCardList[i].CardBox, "UIDyAtlas/RoleCardRank/ui_hd_card_back_" .. infoRoleCard.rank .. "_7", self)

			self.CellChooseCardList[i].CardName.text = RoleCardMgr:GetRole(list[i].data.CardIconList[1]):GetName()

			SetActiveFunc(self.CellChooseCardList[i].Mask, infoRoleCard:IsGet())
		end
	end
end

function PageCardShop:OnClickChooseCard(obj)
	local index = obj.pointerPress.transform:GetSiblingIndex() + 1

	if self.curInfo.data.StepUpOrder == index then
		return
	end

	self.curInfo = self.ChooseCardList[self.curInfo.data.StepUpTurn][index]

	self:UpdateChooseCardPool()
end

function PageCardShop:UpdateChooseCardPool()
	UIUtil.SetImageSprite(self.ChooseCardLineBg, self.curInfo.data.StepUpBoard[1])

	for i, v in ipairs(self.CellChooseCardList) do
		SetActiveFunc(v.Select, i == self.curInfo.data.StepUpOrder)
	end

	self:LoadSpine()
end

function PageCardShop:OnClickChooseCardPoolBefore()
	local index = self.curInfo.data.StepUpTurn - 1

	if index == 0 then
		index = #self.ChooseCardList
	end

	self.curInfo = self.ChooseCardList[index][1]

	self:UpdateCellChooseCard()
	self:UpdateChooseCardPool()
end

function PageCardShop:OnClickChooseCardPoolNext()
	local index = self.curInfo.data.StepUpTurn + 1

	if index > #self.ChooseCardList then
		index = 1
	end

	self.curInfo = self.ChooseCardList[index][1]

	self:UpdateCellChooseCard()
	self:UpdateChooseCardPool()
end

function PageCardShop:LoadSpine()
	if self.spineGroupHandle then
		ResourceMgr.Cancel(self.spineGroupHandle)
	end

	self:OnUnRegisterCell()

	self.listGo = {}

	local info = self.curInfo

	self.spineGroupHandle = ResourceMgr.BeginSubmit(function()
		if self.prefabObj then
			if not self.listRef then
				self.listRef = {}
			end

			table.insert(self.listRef, self.prefabObj)

			if self.curbg then
				self.beforeBg = self.curbg
			end

			self.curbg = GOUtil.InstantiateUIPrefab(self.prefabObj, self.GoBg)

			local spineRoot = GOUtil.FindChildGameObject(self.curbg, "Image/Mask")

			if spineRoot then
				local spineCount = spineRoot.transform.childCount

				for i = 1, spineCount do
					local objroot = spineRoot.transform:GetChild(i - 1)

					GOUtil.UpdateSpineSkeleton(objroot.gameObject)

					if GOUtil.GetComponentInChildren(objroot.gameObject, "SpineAspectRatioFitter") then
						GOUtil.GetComponentInChildren(objroot.gameObject, "SpineAspectRatioFitter").enabled = false
					end
				end
			end

			if self.beforeBg then
				Object.Destroy(self.beforeBg.gameObject)

				self.beforeBg = nil
			end
		end
	end)

	ResourceMgr.SubmitCache(info.data.AnimationName, self, "prefabObj", GameObject)
	ResourceMgr.EndSubmit()
end

function PageCardShop:OnUnRegisterCell()
	if self.listGo == nil then
		return
	end

	for i = 1, #self.listGo do
		self:RemoveClick(self.listGo[i].Btn, self.OnClickedCellDetail)
		Object.Destroy(self.listGo[i].UIRootObject)
	end
end

function PageCardShop:OnButtonShop()
	DlgItemTip.GoToFrom(self.curInfo.data.ShopJump[1])
end

function PageCardShop:OnClickedCellDetail(data)
	local cardId = self.curInfo.data.CardIconList[1]

	local function callback()
		PageCardShop.selectIndex = self.selectIndex

		if self.curInfo.data.ActiveType == eCardPoolActiveType.ChoosePool then
			PageCardShop.selectChooseIndex = self.curInfo.data.StepUpOrder
		elseif self.curInfo.data.ActiveType == eCardPoolActiveType.ChooseCardPool then
			PageCardShop.selectChooseIndex = self.curInfo.data.StepUpOrder
			PageCardShop.selectChooseCardTurn = self.curInfo.data.StepUpTurn
		end
	end

	local data = {
		onlyShow = true,
		cardId = cardId,
		closeCallback = callback
	}

	UIMgr.SwitchPanel(PageRoleCard, data)

	PageCardShop.enterImmediate = true
end

function PageCardShop:OnDrag(data)
	if self.isDrag then
		local dragPosX = data.pressPosition.x - data.position.x

		if dragPosX > 30 then
			if self.stepUpIndex == #self.StepUpSortList then
				return
			end

			self:OnButtonUIStepUpAlbumNext()

			self.isDrag = false
		elseif dragPosX < -30 then
			if self.stepUpIndex == 1 then
				return
			end

			self:OnButtonUIStepUpAlbumBefore()

			self.isDrag = false
		end
	end
end

function PageCardShop:OnBeginDrag(data)
	self.isDrag = true
end

function PageCardShop:OnEndDrag(data)
	self.isDrag = false
end

function PageCardShop:OnChooseCardDrag(data)
	if self.isChooseCardDrag then
		local dragPosX = data.pressPosition.x - data.position.x

		if dragPosX > 60 then
			self:OnClickChooseCardPoolNext()

			self.isChooseCardDrag = false
		elseif dragPosX < -60 then
			self:OnClickChooseCardPoolBefore()

			self.isChooseCardDrag = false
		end
	end
end

function PageCardShop:OnChooseCardBeginDrag(data)
	self.isChooseCardDrag = true
end

function PageCardShop:OnChooseCardEndDrag(data)
	self.isChooseCardDrag = false
end

function PageCardShop:DrawCard(type)
	local info = self.curInfo

	CardPoolManager.infoCardPool = info

	if self.curInfo.data.ActiveType == eCardPoolActiveType.ChoosePool then
		PageCardShop.selectChooseIndex = self.curInfo.data.StepUpOrder
	elseif self.curInfo.data.ActiveType == eCardPoolActiveType.ChooseCardPool then
		PageCardShop.selectChooseIndex = self.curInfo.data.StepUpOrder
		PageCardShop.selectChooseCardTurn = self.curInfo.data.StepUpTurn
	end

	local function cb(setter)
		if setter ~= nil then
			SetActiveFunc(self.GoEffect, false)
			SoundMgr.StopAll()
			SoundMgr.PostEvent(PATH_BGM_CARDSHOPGET, UIMgr.UICamera.gameObject)

			local costItemId, costItemNum

			if type == 1 then
				costItemId = info.data.OneCost[1]
				costItemNum = info.data.OneCost[2]

				local infoItem = ItemManager:Get(costItemId)

				if costItemNum > infoItem:GetCurResNum() and #info.data.OneCost > 3 then
					costItemId = info.data.OneCost[3]
					costItemNum = info.data.OneCost[4]
				end
			elseif type == 0 then
				local infoPool = CardPoolManager:Get(info.id)

				if infoPool.lastCheap > 0 then
					costItemId = info.data.OneDiscount[1]
					costItemNum = info.data.OneDiscount[2]
				else
					costItemId = info.data.OneCost[1]
					costItemNum = info.data.OneCost[2]
				end
			else
				costItemId = info.data.TenCost[1]
				costItemNum = info.data.TenCost[2]

				local infoItem = ItemManager:Get(costItemId)

				if costItemNum > infoItem:GetCurResNum() and #info.data.TenCost > 3 then
					costItemId = info.data.TenCost[3]
					costItemNum = info.data.TenCost[4]
				end
			end

			local function cbClose()
				LoadingMgr.Hide(eLoadingType.Repeat)

				self.CanvasGroup.blocksRaycasts = true

				Event.Instance:Fire("UpdatePoolAndSpine")
			end

			local isFreeDraw = PlayerInst.InfoPlayer:CheckFreeGache(info.id, type)

			UIMgr.AddPanel(DlgDrawCard(), {
				setter = setter,
				type = type,
				infoId = info.id,
				costItemId = costItemId,
				costItemNum = costItemNum,
				leftTime = info.data.DayMaxNum - info.usedTime,
				OnButtonDrawMore = PageCardShop.DrawCardMore,
				isInfinit = info.data.PoolType == 2,
				callback = cbClose,
				isFree = isFreeDraw
			})

			self.CanvasGroup.blocksRaycasts = false

			LoadingMgr.Show(eLoadingType.Repeat)
		end
	end

	PageCardShop.DrawCardByType(type, info, cb)
end

function PageCardShop.DrawCardMore(type, dlg)
	local info = CardPoolManager.infoCardPool

	if info.data.ActiveID ~= 0 and info.data.DayMaxNum <= info.usedTime then
		local nextInfo
		local list = CardPoolManager:GetActivePoolList(info.data.ActiveID)

		for i, v in ipairs(list) do
			if v.data.StepUpOrder == info.data.StepUpOrder + 1 then
				nextInfo = v

				break
			end
		end

		if nextInfo then
			info = nextInfo
			CardPoolManager.infoCardPool = nextInfo
		else
			return
		end
	end

	if info.data.ActiveType == eCardPoolActiveType.ChoosePool then
		PageCardShop.selectChooseIndex = info.data.StepUpOrder
	elseif info.data.ActiveType == eCardPoolActiveType.ChooseCardPool then
		PageCardShop.selectChooseIndex = info.data.StepUpOrder
		PageCardShop.selectChooseCardTurn = info.data.StepUpTurn
	end

	local function cb(setter)
		if setter ~= nil then
			SoundMgr.StopAll()
			SoundMgr.PostEvent(PATH_BGM_CARDSHOPGET, UIMgr.UICamera.gameObject)

			local costItemId, costItemNum

			if type == 1 then
				costItemId = info.data.OneCost[1]
				costItemNum = info.data.OneCost[2]

				local infoItem = ItemManager:Get(costItemId)

				if costItemNum > infoItem:GetCurResNum() and #info.data.OneCost > 3 then
					costItemId = info.data.OneCost[3]
					costItemNum = info.data.OneCost[4]
				end
			elseif type == 0 then
				local infoPool = CardPoolManager:Get(info.id)

				if infoPool.lastCheap > 0 then
					costItemId = info.data.OneDiscount[1]
					costItemNum = info.data.OneDiscount[2]
				end
			else
				costItemId = info.data.TenCost[1]
				costItemNum = info.data.TenCost[2]

				local infoItem = ItemManager:Get(costItemId)

				if costItemNum > infoItem:GetCurResNum() and #info.data.TenCost > 3 then
					costItemId = info.data.TenCost[3]
					costItemNum = info.data.TenCost[4]
				end
			end

			local function cbClose()
				LoadingMgr.Hide(eLoadingType.Repeat)
				Event.Instance:Fire("UpdatePoolAndSpine")
				dlg:Close()
			end

			UIMgr.HideMsg()

			local isFreeDraw = PlayerInst.InfoPlayer:CheckFreeGache(info.id, type)

			UIMgr.AddPanel(DlgDrawCard(), {
				setter = setter,
				type = type,
				infoId = info.id,
				costItemId = costItemId,
				costItemNum = costItemNum,
				leftTime = info.data.DayMaxNum - info.usedTime,
				OnButtonDrawMore = PageCardShop.DrawCardMore,
				isInfinit = info.data.PoolType == 2,
				callback = cbClose,
				isFree = isFreeDraw
			})
			LoadingMgr.Show(eLoadingType.Repeat)
		end
	end

	PageCardShop.DrawCardByType(type, info, cb)
end

function PageCardShop.DrawCardByType(type, info, cb)
	local costItemId, costItemNum, infoItem, curNum, needNum
	local drawNum = 1
	local changeItemId
	local infoPool = CardPoolManager:Get(info.id)

	if type == 0 and infoPool.lastCheap == 0 then
		type = 1
	end

	if type == 1 then
		costItemId = info.data.OneCost[1]
		costItemNum = info.data.OneCost[2]
		changeItemId = info.data.OneCost[3]
		infoItem = ItemManager:Get(costItemId)
		curNum = infoItem:GetCurResNum()
		curNum = infoItem:GetCurResNum()
		needNum = costItemNum
	elseif type == 0 then
		costItemId = info.data.OneDiscount[1]
		needNum = info.data.OneDiscount[2]
		changeItemId = info.data.OneDiscount[3]
		infoItem = ItemManager:Get(costItemId)
		curNum = infoItem:GetCurResNum()
	else
		costItemId = info.data.TenCost[1]
		infoItem = ItemManager:Get(costItemId)
		changeItemId = info.data.TenCost[3]
		curNum = infoItem:GetCurResNum()
		needNum = info.data.TenCost[2]
		drawNum = 10
	end

	costItemId, infoItem, needNum = PageCardShop.JpDrawCost(info, type, costItemId, infoItem, needNum)

	local function fReqDraw()
		local function callback(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				if type == 1 or type == 0 then
					info.usedTime = info.usedTime + 1
				else
					info.usedTime = info.usedTime + 10
				end

				AppsFlyerService.SendGachaFinished(info.id)

				local infoPool = CardPoolManager:Get(info.id)

				infoPool.usedTime = info.usedTime

				if type == 0 then
					infoPool.lastCheap = infoPool.lastCheap - 1
					infoPool.isFirst = infoPool.isFirst + 1
				end

				if info.usedTime >= info.data.DayMaxNum then
					info.needShow = true
				end

				local setter = SetterData.GetSetterData(vPBMessage.setter)

				if info.data.PoolType == 2 then
					-- block empty
				else
					setter:Parse()
				end

				cb(setter)
			elseif vPBMessage.result.code == NetManager.Result_Timeout then
				local strContent = _("Desc_NoNetwork")

				UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
					Restart()
				end, _("UI_OK"), nil, false)
			elseif vPBMessage.result.code == 3 then
				TaskManager.isTempTips = false

				if info.data.ActiveType == 3 then
					local iconId = GetItemEmojiStr(costItemId)
					local itemName = ItemManager:Get(costItemId):GetName()
					local str = string.format(_("Goto_Store_CardPool"), iconId, itemName)

					local function goShop(index)
						if index == DlgCommonEvent.ButtonType.Ok then
							DlgItemTip.GoToFrom(info.data.ShopJump[1])
						end
					end

					UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Desc_Alert"), str, goShop, _("UI_confirm"), nil, true)
				else
					local notEnoughItem = ItemManager:Get(costItemId)

					UIMgr.ShowMsg(string.format(_("Desc_DrawCardNotEnoughItem"), notEnoughItem:GetName()))
				end

				cb(nil)
			else
				TaskManager.isTempTips = false

				UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
				cb(nil)
			end
		end

		TaskManager.isTempTips = true

		NetManager:RequestDrawCard(info.id, type, callback)
		LoadingMgr.Show(eLoadingType.Repeat)
	end

	local function cb(index)
		if index == 1 then
			fReqDraw()
		elseif index == 2 then
			if type == 0 then
				fReqDraw()

				return
			end

			local costItemId = costItemId
			local infoItem = ItemManager:Get(costItemId)
			local curNum = infoItem:GetCurResNum()

			print(curNum)

			local function OnCallback(index2)
				if index2 == 1 then
					fReqDraw()
				end
			end

			if changeItemId == costItemId then
				OnCallback(1)

				return
			end

			local infoItemCharge = ItemManager:Get(changeItemId)
			local chargeNum = info.data.OneCost[4]

			if type ~= 1 then
				chargeNum = chargeNum * (10 - curNum)
			end

			local strName = Lang(infoItem.data.Name)
			local leftNum = chargeNum - PlayerInst:GetDiamond()
			local strAlert

			UIMgr.ShowCommon(DlgCommonEvent.Type.Buy2, _("Desc_Alert"), {
				icon1Id = infoItemCharge.id,
				icon2Id = infoItem.id,
				num1 = chargeNum,
				num2 = drawNum - curNum,
				txt = _("Desc_BuyCommonTips"),
				strAlert = strAlert
			}, OnCallback, nil, nil, nil, true)
		end
	end

	if PlayerPrefs.HasKey("CardDrawTipsTime") then
		PageCardShop.needTips = not TimeIsTodayKc(tonumber(PlayerPrefs.GetString("CardDrawTipsTime", NetData:GetCurServerTime())))
	else
		PageCardShop.needTips = not InstructionMgr:IsInGuide()
	end

	PageCardShop.needTips = not InstructionMgr:IsInGuide()

	if type == 2 and PlayerInst.InfoPlayer:CanFreeDrawPool(infoPool.id) then
		if PageCardShop.needTips then
			local function vCallBack(index)
				if index == DlgCommonEvent.ButtonType.OkNoMoreTips then
					PageCardShop.needTips = false

					PlayerPrefs.SetString("CardDrawTipsTime", NetData:GetCurServerTime())
				end

				if index == DlgCommonEvent.ButtonType.Ok or index == DlgCommonEvent.ButtonType.OkNoMoreTips then
					cb(1)
				end
			end

			UIMgr.ShowCommon(DlgCommonEvent.Type.TodayNoMoreTipsCardShop, _("Desc_Alert"), {
				txt = _("FREE_GACHA_CONFIRM")
			}, vCallBack, nil, nil, nil, true)
		else
			cb(1)
		end
	elseif infoPool.data.ActiveType == 3 then
		local infoRoleCard = RoleCardMgr:GetRoleCard(infoPool.data.CardIconList[1])
		local roleName = RoleCardMgr:GetRole(infoPool.data.CardIconList[1]):GetName()
		local cardName = infoRoleCard:GetName()
		local iconId = GetItemEmojiStr(costItemId)
		local str = string.format(_("Desc_DrawCardDiamond_2"), iconId, needNum, roleName, cardName)

		local function OnCallback(index)
			if index == DlgCommonEvent.ButtonType.Ok then
				CheckDiamond(costItemId, needNum, drawNum, cb)
			else
				PageCardShop.selectChooseIndex = nil
				PageCardShop.selectChooseCardTurn = nil
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Desc_Alert"), str, OnCallback, _("UI_confirm"), nil, true)
	elseif PageCardShop.needTips then
		local function vCallBack(index)
			if index == DlgCommonEvent.ButtonType.OkNoMoreTips then
				PageCardShop.needTips = false

				PlayerPrefs.SetString("CardDrawTipsTime", NetData:GetCurServerTime())
			end

			if index == DlgCommonEvent.ButtonType.Ok or index == DlgCommonEvent.ButtonType.OkNoMoreTips then
				CheckDiamond(costItemId, needNum, drawNum, cb)
			else
				PageCardShop.selectChooseIndex = nil
				PageCardShop.selectChooseCardTurn = nil
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.TodayNoMoreTipsCardShop, _("Desc_Alert"), {
			item2 = 502,
			item1 = infoItem.id,
			num1 = needNum,
			num2 = drawNum
		}, vCallBack, nil, nil, nil, true)
	else
		CheckDiamond(costItemId, needNum, drawNum, cb)
	end
end

function PageCardShop:ShowEffect(isShow)
	if isShow == nil then
		SetActiveFunc(self.UIRootObject, true)
		SetActiveFunc(self.GoEffect, true)

		if self.contentPos then
			self.UIScrollTool:SetContentPos(self.contentPos, 0)

			self.contentPos = nil
		end

		local g = GameObject.Find("DlgDrawCard(Clone)")

		if g then
			SetActiveFunc(self.UIRootObject, false)
		end
	else
		SetActiveFunc(self.UIRootObject, isShow)
		SetActiveFunc(self.GoEffect, isShow)

		if isShow then
			self.UIScrollTool:SetContentPos(self.contentPos, 0)

			self.contentPos = nil
		else
			self.contentPos = self.content.anchoredPosition
		end
	end

	if isShow and self.curInfo.data.ActiveType == eCardPoolActiveType.StepUpPool and CardPoolManager.newStepOpen and not self.curInfo.needShow then
		CardPoolManager.newStepOpen = false

		SetActiveFunc(self.NewTurnOpen, true)

		self.NewTurnTimer = TimerMgr.AddTimer(eTimerType.RealTime, 3, function()
			SetActiveFunc(self.NewTurnOpen, false)
		end, {
			1
		})
	end
end

function PageCardShop:OnUpdateSecond()
	if self.curInfo == nil or not self.endTime or self.curInfo and self.curInfo.data.TimeShow == 0 then
		return
	end

	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local d, h, m, s = GetTimeFormatBySec(self.endTime - curTime)

	if curTime > self.endTime then
		if self.curInfo.data.ActiveType == eCardPoolActiveType.ChooseCardPool and CardPoolManager:CheckItemHaveOpen(self.curInfo) then
			SetActiveFunc(self.TextEndTime.gameObject, false)
		else
			self.TextEndTime.text = _("Activate_Close")
		end

		self.endTime = nil
	elseif d > 0 then
		self.TextEndTime.text = _("Desc_RemainingTime") .. "<size=40>" .. d .. "</size>" .. _("Desc_day") .. "<size=40>" .. h .. "</size>" .. _("Desc_hour")
	elseif h + m == 0 then
		self.TextEndTime.text = _("Desc_RemainingLessThanOneSecond")
	else
		self.TextEndTime.text = _("Desc_RemainingTime") .. "<size=40>" .. h .. "</size>" .. _("Desc_hour") .. "<size=40>" .. m .. "</size>" .. _("Desc_minute")
	end
end

function PageCardShop:UnloadRef()
	if self.spineGroupHandle then
		ResourceMgr.Cancel(self.spineGroupHandle)
	end

	if self.listRef then
		for _, v in pairs(self.listRef) do
			ResourceMgr.Unload(v)
		end

		self.listRef = nil
	end

	GOUtil.DestroyAllChildren(self.GoBg)
end

function PageCardShop:UpdateMonthCard()
	for _, info in pairs(self.listCardPool) do
		info:UpdateMonthCard()
	end

	local info = self.curInfo

	if info.data.OneDiscount[1] ~= info.data.OneCost[1] or info.data.OneDiscount[2] ~= info.data.OneCost[2] then
		local cheapInfoItem = ItemManager:Get(info.data.OneDiscount[1])
		local pathCheapIcon = GetItemIcon(cheapInfoItem:GetType(), cheapInfoItem.id)

		UIUtil.SetImageSprite(self.ImageCheap, pathCheapIcon, self)
		SetActiveFunc(self.ButtonCheap.gameObject, true)

		self.TextCheapNum.text = info.data.OneDiscount[2]
		self.CheapItemNum.text = cheapInfoItem:GetCurResNum()

		UIUtil.SetImageSprite(self.CheapItemIcon, pathCheapIcon .. "_S", self, true)

		if info.data.PriceOff[1] ~= 0 then
			SetActiveFunc(self.NotCheapNum.gameObject, true)

			self.NotCheapNum.text = info.data.PriceOff[1]
		else
			SetActiveFunc(self.NotCheapNum.gameObject, false)
		end

		if info.lastCheap > 0 then
			self.CheapLastCount.text = _("Desc_LeftTimes") .. info.lastCheap

			SetActiveFunc(self.ButtonCheap.gameObject, true)
		else
			SetActiveFunc(self.ButtonCheap.gameObject, false)
		end
	else
		SetActiveFunc(self.ButtonCheap.gameObject, false)
	end

	if info.data.TenCost[1] then
		local infoItem = ItemManager:Get(info.data.TenCost[1])

		if infoItem:GetType() == eItemType.P_DIAMOND_PAY then
			SetActiveFunc(self.TenCurObj, true)

			self.TenCurItemNum.text = infoItem:GetCurResNum()
		end
	end

	if info.data.ShopId > 0 then
		SetActiveFunc(self.ButtonShop, true)

		local id = info.data.ScoreNum[1]
		local infoItem = ItemManager:Get(id)

		self.TextShopNum.text = infoItem:GetCurResNum()

		UIUtil.SetImageSprite(self.ImageShopNumIcon, infoItem:GetIcon(), self)
	end
end

function PageCardShop:UpdatePoolAndSpine()
	self:UpdateCardPool()
	self:LoadSpine()
end

function PageCardShop:OnBackAndroid()
	if GOUtil.IsActiveSelf(self.ButtonSkip) then
		self:OnButtonSkip()

		return true
	end

	return false
end
