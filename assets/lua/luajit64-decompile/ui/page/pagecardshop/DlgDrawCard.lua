-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/DlgDrawCard.lua

DlgDrawCard = class("DlgDrawCard", UIPanel)

function DlgDrawCard:ctor()
	self.UIPrefabPath = "UI/PageCardShop/DlgDrawCard"
end

function DlgDrawCard:Purge()
	DlgDrawCard.base.Purge(self)

	if self.goDice then
		Object.Destroy(self.goDice)
	end

	if self.goDiceBoom then
		Object.Destroy(self.goDiceBoom)
	end

	if self.fAniCoroutine then
		coroutine.stop(self.fAniCoroutine)

		self.fAniCoroutine = nil
	end

	if self.fDiceCoroutine then
		coroutine.stop(self.fDiceCoroutine)

		self.fAniCoroutine = nil
	end

	if self.timerReward then
		TimerMgr.RemoveTimer(self.timerReward)
	end

	if self.timerScore then
		TimerMgr.RemoveTimer(self.timerScore)
	end

	if self.timerChange then
		TimerMgr.RemoveTimer(self.timerChange)
	end

	if self.timerListVec then
		TimerMgr.RemoveTimer(self.timerListVec)
	end

	if self.timerResult then
		TimerMgr.RemoveTimer(self.timerResult)
	end

	if self.timerNew then
		TimerMgr.RemoveTimer(self.timerNew)
	end

	if self.timerAutoShow then
		TimerMgr.RemoveTimer(self.timerAutoShow)
	end

	ResourceMgr.Unload(self.PrefabThrowDice)
	ResourceMgr.Unload(self.PrefabThrowDiceBoom)
	ResourceMgr.Unload(self.PrefabDice1)
	ResourceMgr.Unload(self.PrefabDice2)
	ResourceMgr.Unload(self.PrefabDice3)
	ResourceMgr.Unload(self.PrefabDice4)

	if self.rankUpVideoRef then
		ResourceMgr.Unload(self.rankUpVideoRef)
	end

	if self.bestRankVideoRef then
		ResourceMgr.Unload(self.bestRankVideoRef)
	end

	self.setter = nil
	self.DrawCardMore = nil
	self.newRoleList = nil
	self.isFinish = nil
	self.extraReward = nil

	for i, v in ipairs(self.effectHandelList) do
		EffectMgr:Free(v)
	end

	if EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_002"] then
		ResourceMgr.Unload(EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_002"])

		EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_002"] = nil
	end

	if EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_001"] then
		ResourceMgr.Unload(EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_001"])

		EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_001"] = nil
	end

	if EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_003"] then
		ResourceMgr.Unload(EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_003"])

		EffectMgr["EffCacheBattle/Common/ThrowDice/PP_DIce_Boom_003"] = nil
	end

	SoundMgr.UnloadBank(PATH_BANK_CARDSHOP)
	SoundMgr.UnloadBank(PATH_BANK_CARDSHOPRESULT)
	Event.Instance:Fire("CloseDlgShare")
end

function DlgDrawCard:PreLoad()
	self:LoadResAsync("Battle/Common/ThrowDice/ThrowDiceGo", "PrefabThrowDice")
	self:LoadResAsync("Battle/Common/ThrowDice/ThrowDiceBoomPrefab", "PrefabThrowDiceBoom")
	self:LoadResAsync("Battle/Common/ThrowDice/PP_Bg502_Dice_001", "PrefabDice1")
	self:LoadResAsync("Battle/Common/ThrowDice/PP_Bg502_Dice_002", "PrefabDice2")
	self:LoadResAsync("Battle/Common/ThrowDice/PP_Bg502_Dice_003", "PrefabDice3")
	self:LoadResAsync("Battle/Common/ThrowDice/PP_Bg502_Dice_004", "PrefabDice4")
end

function DlgDrawCard:OnEnter(vParam)
	Event.Instance:Fire("ShowEffect", false)

	self.vParam = vParam
	self.isFreeDraw = self.vParam.isFree
	self.setter = vParam.setter
	self.type = vParam.type

	SoundMgr.LoadBank(PATH_BANK_CARDSHOP, false, false)
	SoundMgr.LoadBank(PATH_BANK_CARDSHOPRESULT, false, false)

	self.leftTime = vParam.leftTime
	self.costItemId = vParam.costItemId
	self.costItemNum = vParam.costItemNum
	self.DrawCardMore = vParam.OnButtonDrawMore
	self.isInfinit = vParam.isInfinit
	self.infoId = vParam.infoId
	self.effectHandelList = {}

	local Text = self:GetChildComponent("ActionPanel/ButtonOne/Text", "Text")

	Text.text = _("UI_OK")
	Text = self:GetChildComponent("ActionPanel/Text", "Text")
	Text.text = _("Desc_LeftTimesToday")
	self.Group = self:GetChildComponent("PanelTen/Main/Group", "GridLayoutGroup")
	self.BtnDrawText = self:GetChildComponent("ActionPanel/ButtonTen/Text", "Text")
	self.TextOne = self:GetChildComponent("ActionPanel/ButtonOne/Text", "Text")
	self.TextTen = self:GetChildComponent("ActionPanel/ButtonTen/Text", "Text")
	self.TextNum = self:GetChildComponent("ActionPanel/ButtonTen/Image/TextNum", "Text")
	self.TextLeft = self:GetChildComponent("ActionPanel/TextLeft", "Text")
	self.TextTime = Text
	self.PanelOne = self:GetChildGameObject("PanelOne")
	self.PanelTen = self:GetChildGameObject("PanelTen")
	self.ImageIcon = self:GetChildComponent("ActionPanel/ButtonTen/ImageIcon", "Image")
	self.ActionPanel = self:GetChildGameObject("ActionPanel")

	self.PanelTen:SetActive(false)
	self.PanelOne:SetActive(false)

	self.ButtonOne = self:GetChildGameObject("ActionPanel/ButtonOne")
	self.ButtonTen = self:GetChildGameObject("ActionPanel/ButtonTen")
	self.ButtonTenFree = self:GetChildGameObject("ActionPanel/ButtonTenFree")
	self.ButtonTenFreeReset = self:GetChildComponent("ActionPanel/ButtonTenFree/TipFree/num", "Image")
	self.ButtonQuit = self:GetChildGameObject("ActionPanel/ButtonQuit")
	Text = self:GetChildComponent("ActionPanel/ButtonQuit/Text", "Text")
	Text = _("UI_OK")

	for i = 1, 10 do
		self["GoCellCard" .. i] = self:GetChildGameObject("PanelTen/Main/Group/" .. i)

		self["GoCellCard" .. i]:SetActive(false)
	end

	self.GoCellOne = self:GetChildGameObject("PanelOne/Cell")

	self.GoCellOne:SetActive(false)

	self.ImageLight = self:GetChildGameObject("PanelOne/ImageLight")

	self.ImageLight:SetActive(false)
	self.ActionPanel:SetActive(false)

	self.listDraw = {}
	self.getScore = 0
	self.extraReward = {}
	self.newRoleList = {}

	for _, s in pairs(self.setter.list) do
		if s.from == protocol_pb.AF_DRAW_CARD or s.from == protocol_pb.AF_INFINITE_DRAW_CARD then
			if s.newRole and s.newRole.id > 0 then
				table.insert(self.newRoleList, s.newRole.id)
			end

			table.insert(self.listDraw, {
				data = s
			})
		end

		if s.from == protocol_pb.AF_DRAW_CARD_EXTRA then
			table.insert(self.extraReward, s)
		end

		if s.asset == protocol_pb.I_SCORE_COIN then
			self.getScore = s.num
		end
	end

	self.index = 1
	self.goDiceBoom = GOUtil.InstantiatePrefab(self.PrefabThrowDiceBoom, nil)

	self.goDiceBoom:SetActive(false)

	self.goDiceBoomCamera = GOUtil.FindChildGameObject(self.goDiceBoom, "Cam_ThrowDiceBoom/CameraNode/Camera")
	self.goDice = GOUtil.InstantiatePrefab(self.PrefabThrowDice, nil)

	self.goDice:SetActive(false)

	self.ImgLight = self:GetChildGameObject("ImgLight")

	self.ImgLight:SetActive(false)

	for i = 1, 10 do
		local gd = GOUtil.FindChildGameObject(self.goDice, "dice_00" .. i)

		GOUtil.DestroyAllChildren(gd)
	end

	self.GoClick = self:GetChildGameObject("GoClick")

	self.GoClick:SetActive(false)

	self.ButtonSkipShowDice = self:GetChildGameObject("ButtonSkip")
	self.listVec = {}
	self.listGoDiceUpdate = {}
	self.listDiceShow = {}
	self.lsitGoBasic = {}
	self.listGoDice = {}
	self.bestRank = 1

	for i = 1, #self.listDraw do
		local sd = self.listDraw[i].data
		local infoRoleCard = RoleCardMgr:GetRoleCard(sd.id)
		local gd = GOUtil.FindChildGameObject(self.goDice, "dice_00" .. i)
		local hasRankup = sd.extra and sd.extra[1] and sd.extra[1] > 0
		local rankOff = 0

		if hasRankup then
			rankOff = -1

			local gv = GOUtil.GetComponent(gd, "ForceAtPosition")

			table.insert(self.listVec, gv)
		end

		local rank = infoRoleCard.cardRank + rankOff

		if rank < 1 then
			rank = 1
		end

		local g = GOUtil.InstantiatePrefab(self["PrefabDice" .. rank], gd)

		table.insert(self.listGoDice, g)
		GOUtil.SetTransformLocalScale(g, 2.2)

		self.bestRank = TenaryOp(rank > self.bestRank, rank, self.bestRank)

		if hasRankup then
			local gd = GOUtil.FindChildGameObject(g, "Upgrade")

			table.insert(self.listGoDiceUpdate, gd)

			local gs = GOUtil.FindChildGameObject(g, "Crack(Upgrade)")

			table.insert(self.listDiceShow, gs)

			local gb = GOUtil.FindChildGameObject(g, "Basic")

			table.insert(self.lsitGoBasic, gb)
			gb:SetActive(true)
		else
			local gs = GOUtil.FindChildGameObject(g, "Crack(Basic)")

			table.insert(self.listDiceShow, gs)
		end
	end

	self.ButtonSkip = self:GetChildGameObject("VideoBG/Button")
	self.ButtonSkipUp = self:GetChildGameObject("VideoBG2/Button")
	self.stopCoroutine = false

	function self.fAni()
		local video = self:GetChildComponent("VideoBG/video", "VideoPlayer")
		local strVideoPath = "Videos/CardPool/1-R"

		strVideoPath = #self.listDiceShow > 1 and (self.bestRank > 3 and "Videos/CardPool/2-UR" or self.bestRank > 2 and "Videos/CardPool/2-SSR" or "Videos/CardPool/2-R") or self.bestRank > 3 and "Videos/CardPool/1-UR" or self.bestRank > 2 and "Videos/CardPool/1-SSR" or "Videos/CardPool/1-R"

		if IsNil(self.UIRootObject) then
			return
		end

		self.bestRankVideoRef = UIUtil.SetVideoPlayerClip(video, strVideoPath)

		video.gameObject:SetActive(true)

		local t = tonumber(video.clip.length)

		coroutine.wait(t)
		video.gameObject:SetActive(false)

		if self.stopCoroutine then
			self.stopCoroutine = false
		else
			self:PlayDice()
		end
	end

	self.fAniCoroutine = coroutine.start(self.fAni)

	require("UI/Dlg/Public/DlgShare")
	self:SetSafeArea(self:GetChildGameObject("PanelOne/Safe"))

	self.ButtonShare = self:GetChildGameObject("Safe/ButtonShare")

	if InstructionMgr:IsInGuide() and not isShowShare then
		self.ButtonShare:SetActive(false)
	end

	if not NEED_SHARE then
		self.ButtonShare:SetActive(false)
	end

	self.ButtonShare:SetActive(false)

	if vParam.callback then
		vParam.callback()
	end
end

function DlgDrawCard:PlayDice()
	local VideoBG = self:GetChildGameObject("VideoBG")

	VideoBG:SetActive(false)
	self.goDice:SetActive(true)

	Physics.autoSimulation = true

	self.ButtonSkipShowDice:SetActive(true)

	self.SetDiceFinish = false

	function self.fDice()
		coroutine.wait(0.1)

		if #self.listDiceShow > 1 then
			self:PlayVoice("Play_SE_020_0037")
		else
			self:PlayVoice("Play_SE_020_0036")
		end

		coroutine.wait(2)

		if #self.listVec > 0 then
			self.ButtonSkip:SetActive(true)
			self.UIRootObject:SetActive(true)

			local VideoBG2 = self:GetChildGameObject("VideoBG2")

			VideoBG2:SetActive(true)

			local vup = self:GetChildComponent("VideoBG2/Up", "VideoPlayer")
			local playIndex = math.random(1, 6)

			self.rankUpVideoRef = UIUtil.SetVideoPlayerClip(vup, "Videos/CardPool/rankup" .. playIndex)

			vup.gameObject:SetActive(true)

			local t = tonumber(vup.clip.length)

			coroutine.wait(t)
			VideoBG2:SetActive(false)
			self.UIRootObject:SetActive(true)

			for i = 1, #self.listVec do
				local gv = self.listVec[i]

				gv:Apply()
			end

			self:PlayVoice("Play_SE_020_0039")

			for i = 1, #self.listVec do
				local gb = self.lsitGoBasic[i]

				gb:SetActive(false)

				local gu = self.listGoDiceUpdate[i]

				gu:SetActive(true)
			end

			coroutine.wait(3)
		end

		for i = 1, #self.listDiceShow do
			local g = self.listDiceShow[i]

			g:SetActive(true)
		end

		coroutine.wait(1)

		local gdb = GOUtil.FindChildGameObject(self.goDice, "Boom")

		gdb:SetActive(true)
		coroutine.wait(0.5)
		self.goDice:SetActive(false)
		self.UIRootObject:SetActive(true)
		self.ImgLight:SetActive(true)
		coroutine.wait(0.2)
		self.ImgLight:SetActive(false)

		self.goDiceBoomplayable = GOUtil.GetComponent(self.goDiceBoom, "PlayableDirector")

		self.goDiceBoom:SetActive(true)
		self.goDiceBoomplayable:Play()
		self.ButtonSkipShowDice:SetActive(true)
		self.UIRootObject:SetActive(true)
		self:SetGoDice()
		coroutine.wait(0.1)
		self:PlayVoice("Play_SE_020_0040")
		coroutine.wait(2)

		if not IsNil(self.goDice) and not IsNil(self.UIRootObject) then
			for i = 1, #self.listDraw do
				self.listDraw[i].itemIndex = i
			end

			table.sort(self.listDraw, function(a, b)
				local AhasChangeStar = TenaryOp(a.data.newRoleCard.id > 0, 0, 1)
				local BhasChangeStar = TenaryOp(b.data.newRoleCard.id > 0, 0, 1)
				local aRank = RoleCardMgr:GetRoleCard(a.data.id).cardRank
				local bRank = RoleCardMgr:GetRoleCard(a.data.id).cardRank

				if AhasChangeStar < BhasChangeStar then
					return true
				elseif BhasChangeStar < AhasChangeStar then
					return false
				end

				if bRank < aRank then
					return true
				elseif aRank < bRank then
					return false
				end

				if a.itemIndex < b.itemIndex then
					return true
				end

				return false
			end)
			self.UIRootObject:SetActive(true)
			self.GoClick:SetActive(true)
			self:OnButtonCell()
		end

		Physics.autoSimulation = false
	end

	self.fDiceCoroutine = coroutine.start(self.fDice)
end

function DlgDrawCard:SetGoDice()
	for i = 1, 10 do
		local gPos = GOUtil.FindChildGameObject(self.goDiceBoom, "ThrowDiceBoom/Dice_Ani_00" .. i - 1)

		gPos:SetActive(false)
	end

	local gTrack1 = GOUtil.FindChildGameObject(self.goDiceBoom, "FX_Group/Track01")
	local gTrack2 = GOUtil.FindChildGameObject(self.goDiceBoom, "FX_Group/Track10")

	gTrack1:SetActive(false)
	gTrack2:SetActive(false)

	local gLightStripUR = GOUtil.FindChildGameObject(self.goDiceBoom, "FX_Group/UR")
	local gLightStripNotUR = GOUtil.FindChildGameObject(self.goDiceBoom, "FX_Group/Non_UR")
	local gLightStripNotSR = GOUtil.FindChildGameObject(self.goDiceBoom, "FX_Group/Non_UR_Blue")

	gLightStripUR:SetActive(false)
	gLightStripNotUR:SetActive(false)

	if self.bestRank > 3 then
		gLightStripUR:SetActive(true)
	elseif self.bestRank > 2 then
		gLightStripNotUR:SetActive(true)
	else
		gLightStripNotSR:SetActive(true)
	end

	if self.type == 1 or self.type == 3 or self.type == 0 then
		gTrack1:SetActive(true)

		local gPos = GOUtil.FindChildGameObject(self.goDiceBoom, "ThrowDiceBoom/Dice_Ani_0010")

		if self.listGoDice[1] then
			gPos:SetActive(true)
			GOUtil.SetTransformLocalScale(self.listGoDice[1], 1)
			GOUtil.AttachGameObject(self.listGoDice[1], gPos)
		end
	else
		gTrack2:SetActive(true)

		for i = 1, 10 do
			local gPos = GOUtil.FindChildGameObject(self.goDiceBoom, "ThrowDiceBoom/Dice_Ani_00" .. i - 1)

			if self.listGoDice[i] then
				gPos:SetActive(true)
				GOUtil.SetTransformLocalScale(self.listGoDice[i], 1)
				GOUtil.AttachGameObject(self.listGoDice[i], gPos)
			end
		end
	end

	self.SetDiceFinish = true
end

function DlgDrawCard:OnRegisterEvent()
	self:AddClick(self.GoRoleClick, self.OnButtonGoRoleClick)
	self:AddClick(self.ButtonOne, self.OnButtonOk)
	self:AddClick(self.ButtonTen, self.OnButtonDrawMore)
	self:AddClick(self.ButtonTenFree, self.OnButtonDrawMore)
	self:AddClick(self.ButtonSkip, self.OnButtonSkip)
	self:AddClick(self.ButtonSkipUp, self.OnButtonSkip)
	self:AddClick(self.ButtonQuit, self.OnButtonQuit)
	self:AddClick(self.ButtonShare, self.OnButtonShare)
	self:AddClick(self.GoClick, self.OnButtonCell)
	self:AddClick(self.ButtonSkipShowDice, self.OnButtonSkip)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.OnUpdataItem, self)
	self:AddListener(self.GoCellOne, self.ShowOneCardInfo, EventTriggerType.PointerLongPress)

	for i = 1, 10 do
		self:AddListener(self["GoCellCard" .. i], self.ShowCardInfo, EventTriggerType.PointerLongPress)
	end
end

function DlgDrawCard:OnUnRegisterEvent()
	self:RemoveClick(self.GoRoleClick, self.OnButtonGoRoleClick)
	self:RemoveClick(self.ButtonOne, self.OnButtonOk)
	self:RemoveClick(self.ButtonTen, self.OnButtonDrawMore)
	self:RemoveClick(self.ButtonTenFree, self.OnButtonDrawMore)
	self:RemoveClick(self.ButtonSkip, self.OnButtonSkip)
	self:RemoveClick(self.ButtonSkipUp, self.OnButtonSkip)
	self:RemoveClick(self.ButtonQuit, self.OnButtonQuit)
	self:RemoveClick(self.ButtonShare, self.OnButtonShare)
	self:RemoveClick(self.GoClick, self.OnButtonCell)
	self:RemoveClick(self.ButtonSkipShowDice, self.OnButtonSkip)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.OnUpdataItem, self)
	self:RemoveListener(self.GoCellOne, self.ShowOneCardInfo, EventTriggerType.PointerLongPress)

	for i = 1, 10 do
		self:RemoveListener(self["GoCellCard" .. i], self.ShowCardInfo, EventTriggerType.PointerLongPress)
	end
end

function DlgDrawCard:OnButtonShare()
	local go = GameObject.Find("ClickEffectMountNode")

	if not IsNil(go) then
		go:SetActive(false)
	end

	self.ButtonShare:SetActive(false)
	self.ButtonOne:SetActive(false)
	self.ButtonTen:SetActive(false)
	require("UI/Dlg/Public/DlgShare")

	local function cb()
		self.ButtonShare:SetActive(true)
		self.ButtonOne:SetActive(true)
		self.ButtonTen:SetActive(true)
		self:ShowActionPanel()
	end

	local gc = GameObject.Find("Camera")
	local camera = GOUtil.GetComponent(gc, "Camera")

	Event.Instance:Fire("CloseDlgShare")

	local t2d = MiscUtil.CapturePicture(camera, UIMgr.UICamera)

	UIMgr.AddPanel(DlgShare(), {
		texture = t2d,
		callback = cb,
		GoBtnShare = self.ButtonShare
	})
end

function DlgDrawCard:OnButtonSkip()
	self.stopCoroutine = true

	coroutine.stop(self.fDiceCoroutine)
	coroutine.stop(self.fAniCoroutine)
	self:OnSkipAllToShowCard()

	self.fAniCoroutine = nil
	self.fDiceCoroutine = nil
	Physics.autoSimulation = false

	self.goDice:SetActive(false)
end

function DlgDrawCard:OnSkipAllToShowCard()
	local VideoBG = self:GetChildGameObject("VideoBG")

	VideoBG:SetActive(false)

	local VideoBG2 = self:GetChildGameObject("VideoBG2")

	VideoBG2:SetActive(false)
	self.goDice:SetActive(true)
	self.UIRootObject:SetActive(false)
	self.ImgLight:SetActive(false)

	self.goDiceBoomplayable = GOUtil.GetComponent(self.goDiceBoom, "PlayableDirector")

	self.goDiceBoom:SetActive(true)
	self.goDiceBoomplayable:Play()

	self.goDiceBoomplayable.time = 3

	self.UIRootObject:SetActive(true)
	self.ButtonSkipShowDice:SetActive(false)

	if not self.SetDiceFinish then
		self:SetGoDice()
	end

	for i = 1, #self.listDiceShow do
		local g = self.listDiceShow[i]

		g:SetActive(false)
	end

	if #self.listVec > 0 then
		self.timerListVec = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
			for i = 1, #self.listVec do
				local gb = self.lsitGoBasic[i]

				gb:SetActive(false)

				local gu = self.listGoDiceUpdate[i]

				gu:SetActive(true)
			end
		end, {})
	end

	if not IsNil(self.goDice) and not IsNil(self.UIRootObject) then
		for i = 1, #self.listDraw do
			self.listDraw[i].itemIndex = i
		end

		table.sort(self.listDraw, function(a, b)
			local AhasChangeStar = TenaryOp(a.data.newRoleCard.id > 0, 0, 1)
			local BhasChangeStar = TenaryOp(b.data.newRoleCard.id > 0, 0, 1)
			local aRank = RoleCardMgr:GetRoleCard(a.data.id).cardRank
			local bRank = RoleCardMgr:GetRoleCard(b.data.id).cardRank

			if AhasChangeStar < BhasChangeStar then
				return true
			elseif BhasChangeStar < AhasChangeStar then
				return false
			end

			if bRank < aRank then
				return true
			elseif aRank < bRank then
				return false
			end

			if a.itemIndex < b.itemIndex then
				return true
			end

			return false
		end)
		self.UIRootObject:SetActive(true)
		self.GoClick:SetActive(true)

		self.timerShowCard = TimerMgr.AddTimer(eTimerType.RealTime, TenaryOp(#self.listVec > 0, 2, 0), function()
			self:OnButtonCell()
		end, {})
	end
end

function DlgDrawCard:OnButtonExit()
	Event.Instance:Fire("ShowEffect", true)
	self:Close()
end

function DlgDrawCard:OnButtonGoNextClick()
	DlgShare.UpdateData(self.ButtonShare)

	if self.index <= #self.listDraw then
		self:OnDrawNext(self.index)
	else
		TaskManager.isTempTips = false

		TaskManager:ShowTaskTips()

		if self.type == 1 or self.type == 3 or self.type == 0 then
			self.PanelOne:SetActive(true)
			self.PanelTen:SetActive(false)
			self:UpdateOneCard()
		else
			self.PanelOne:SetActive(false)
			self.PanelTen:SetActive(true)
			self:UpdateAllCard()
		end

		local waitTime = 2

		if self.getScore ~= 0 or #self.extraReward > 0 then
			waitTime = 2 + GetConfigArgFloat("DragCardChangestarTipTime")
		end

		self.timerResult = TimerMgr.AddTimer(eTimerType.RealTime, waitTime, function()
			self:ShowActionPanel()
		end, {})
	end
end

function DlgDrawCard:ShowActionPanel()
	if InstructionMgr:IsInGuide() and not isShowShare then
		-- block empty
	else
		self.ButtonShare:SetActive(true)
	end

	if not NEED_SHARE then
		self.ButtonShare:SetActive(false)
	end

	if self.type == 3 then
		self.ButtonQuit:SetActive(true)
		self.ButtonOne:SetActive(false)
		self.ButtonTen:SetActive(false)
		self.TextLeft.gameObject:SetActive(false)
		self.TextTime.gameObject:SetActive(false)
		self.ActionPanel:SetActive(true)

		return
	end

	local cardPoolInfo = CardPoolManager:Get(self.infoId)
	local itemId = 0

	itemId = self.costItemId

	if cardPoolInfo.data.ActiveType ~= 0 then
		if cardPoolInfo.data.ActiveType == eCardPoolActiveType.StepUpPool then
			if cardPoolInfo.data.DayMaxNum > cardPoolInfo.usedTime then
				itemId = cardPoolInfo.data.TenCost[1]

				local infoItem = ItemManager:Get(itemId)

				self.BtnDrawText.text = Lang(cardPoolInfo.data.BtnText[3])
				self.TextNum.text = cardPoolInfo.data.TenCost[2] .. "/" .. TenaryOp(itemId == 502, PlayerInst:GetDiamondAll(), infoItem:GetCurResNum())

				self.ButtonTen:SetActive(true)

				local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

				UIUtil.SetImageOverrideSprite(self.ImageIcon, pathIcon, self)
			else
				local list = CardPoolManager:GetActivePoolList(cardPoolInfo.data.ActiveID)
				local nextInfo

				for i, v in ipairs(list) do
					if v.data.StepUpOrder == cardPoolInfo.data.StepUpOrder + 1 and v.data.StepUpTurn == cardPoolInfo.data.StepUpTurn then
						nextInfo = v

						break
					end
				end

				if nextInfo then
					itemId = nextInfo.data.TenCost[1]

					local infoItem = ItemManager:Get(itemId)

					self.BtnDrawText.text = Lang(nextInfo.data.BtnText[3])
					self.TextNum.text = nextInfo.data.TenCost[2] .. "/" .. TenaryOp(itemId == 502, PlayerInst:GetDiamondAll(), infoItem:GetCurResNum())

					local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

					UIUtil.SetImageOverrideSprite(self.ImageIcon, pathIcon, self)
				else
					CardPoolManager.newStepOpen = true

					self.ButtonTen:SetActive(false)
				end
			end
		elseif cardPoolInfo.data.ActiveType == eCardPoolActiveType.ChoosePool or cardPoolInfo.data.ActiveType == eCardPoolActiveType.ChooseCardPool then
			if cardPoolInfo.data.DayMaxNum <= cardPoolInfo.usedTime then
				self.ButtonTen:SetActive(false)
			elseif cardPoolInfo.data.ActiveType == eCardPoolActiveType.ChoosePool and self.type == 1 then
				self.ButtonTen:SetActive(false)
			end
		end

		self.ActionPanel:SetActive(true)
	else
		local infoItem = ItemManager:Get(itemId)

		if self.type == 0 then
			self.ButtonTen:SetActive(false)
		elseif self.type == 1 then
			self.BtnDrawText.text = _("CardShop_DrawOne")
			self.TextNum.text = self.costItemNum .. "/" .. TenaryOp(itemId == 502, PlayerInst:GetDiamondAll(), infoItem:GetCurResNum())
		else
			self.BtnDrawText.text = _("CardShop_DrawTen")
			self.TextNum.text = self.costItemNum .. "/" .. TenaryOp(itemId == 502, PlayerInst:GetDiamondAll(), infoItem:GetCurResNum())
		end

		self.TextLeft.text = self.leftTime

		self.ActionPanel:SetActive(true)

		if self.isInfinit then
			self.TextOne.text = _("Desc_ReDraw")
			self.TextTen.text = _("Desc_ConfirmDraw")

			self.TextLeft.gameObject:SetActive(false)
			self.TextTime.gameObject:SetActive(false)

			self.TextNum.text = "10"
		end

		local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

		UIUtil.SetImageOverrideSprite(self.ImageIcon, pathIcon, self)

		if cardPoolInfo.data.DayMaxNum <= cardPoolInfo.usedTime then
			self.ButtonTen:SetActive(false)
		end
	end

	if PlayerInst.InfoPlayer:CanFreeDrawPool(self.infoId) and self.type == 2 then
		self.ButtonTen:SetActive(false)
		self.ButtonTenFree:SetActive(true)
		UIUtil.SetImageSprite(self.ButtonTenFreeReset, string.format("UI/PageCardShop/AtlasCardShop/font_free_jp_%s", PlayerInst.InfoPlayer.freeDrawInfo.freeDrawCount), self)
	else
		if self.isFreeDraw then
			self.ButtonTen:SetActive(false)
		end

		self.ButtonTenFree:SetActive(false)
	end

	TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		InstructionMgr:TriggerWait("ShowDrawCardPanel")
	end, {})
end

function DlgDrawCard:UpdateOneCard()
	local d = 2

	local function cb()
		local g = self.GoCellOne
		local sd = self.listDraw[1].data

		if sd then
			local hasChangeStar = not (sd.newRoleCard.id > 0)

			if hasChangeStar then
				UIMgr.ShowMsg(_("Desc_ShowChangeStar"))
				self:CellShowStar(self.GoCellOne, sd)
			end
		end

		self:PlayVoice("Play_SE_020_0041")

		if self.getScore ~= 0 then
			self.timerScore = TimerMgr.AddTimer(eTimerType.RealTime, GetConfigArgFloat("DragCardChangestarTipTime"), function()
				UIMgr.ShowMsg(string.format(_("Msg_GetScore"), self.getScore))
			end, {})
		end

		if #self.extraReward > 0 then
			self.timerReward = TimerMgr.AddTimer(eTimerType.RealTime, GetConfigArgFloat("DragCardChangestarTipTime"), function()
				UIMgr.AddPanel(DlgGetAward(), {
					list = self.extraReward
				})
			end, {})
		end

		self.isFinish = true
	end

	self:ShowNextChain(d, cb)
	SoundMgr.Stop(PATH_BGM_CARDSHOP)
	SoundMgr.PostEvent(PATH_BGM_CARDSHOPRESULT, UIMgr.UICamera.gameObject)
end

function DlgDrawCard:UpdateAllCard()
	self.Group.enabled = false

	local d = 2

	local function cb()
		local showChangeStar = false

		for i = 1, 10 do
			local g = self["GoCellCard" .. i]
			local sd

			for index, v in ipairs(self.listDraw) do
				if i == v.itemIndex then
					sd = v.data

					break
				end
			end

			if sd then
				local hasChangeStar = not (sd.newRoleCard.id > 0)

				if hasChangeStar then
					if not showChangeStar then
						UIMgr.ShowMsg(_("Desc_ShowChangeStar"))

						showChangeStar = true
					end

					self:CellShowStar(g, sd)
				end
			end
		end

		if self.getScore ~= 0 then
			self.timerScore = TimerMgr.AddTimer(eTimerType.RealTime, GetConfigArgFloat("DragCardChangestarTipTime"), function()
				UIMgr.ShowMsg(string.format(_("Msg_GetScore"), self.getScore))
			end, {})
		end

		if #self.extraReward > 0 then
			self.timerReward = TimerMgr.AddTimer(eTimerType.RealTime, GetConfigArgFloat("DragCardChangestarTipTime"), function()
				UIMgr.AddPanel(DlgGetAward(), {
					list = self.extraReward
				})
			end, {})
		end

		self:PlayVoice("Play_SE_020_0041")

		self.isFinish = true
	end

	self:ShowNextChain(d, cb)
	SoundMgr.Stop(PATH_BGM_CARDSHOP)
	SoundMgr.PostEvent(PATH_BGM_CARDSHOPRESULT, UIMgr.UICamera.gameObject)
end

function DlgDrawCard:OnButtonGoRoleClick()
	self:OnNext()
end

function DlgDrawCard:OnNext()
	self.index = self.index + 1
end

function DlgDrawCard:OnButtonCell(data)
	self.index = 1

	self:OnDrawNext(self.index)
	self.GoClick:SetActive(false)
	self.ButtonSkipShowDice:SetActive(false)

	if self.timerShowCard then
		TimerMgr.RemoveTimer(self.timerShowCard)
	end
end

function DlgDrawCard:OnDrawNext(index)
	local sd = self.listDraw[index].data
	local hasChangeStar = not (sd.newRoleCard.id > 0)

	self.index = self.index + 1

	local infoRoleCard = RoleCardMgr:GetRoleCard(sd.id)
	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)
	local hasNewRole = table.contains(self.newRoleList, infoRoleCard.data.CharacterID)

	if hasNewRole then
		table.removeByValue(self.newRoleList, infoRoleCard.data.CharacterID)
	end

	local function ShowEffectFunc(...)
		local effectHandle

		if infoRoleCard.rank == "ur" then
			effectHandle = EffectMgr:Alloc("Battle/Common/ThrowDice/PP_DIce_Boom_002", self.listGoDice[self.listDraw[index].itemIndex], true)
		elseif infoRoleCard.rank == "ssr" then
			effectHandle = EffectMgr:Alloc("Battle/Common/ThrowDice/PP_DIce_Boom_001", self.listGoDice[self.listDraw[index].itemIndex], true)
		else
			effectHandle = EffectMgr:Alloc("Battle/Common/ThrowDice/PP_DIce_Boom_003", self.listGoDice[self.listDraw[index].itemIndex], true)
		end

		table.insert(self.effectHandelList, effectHandle)
	end

	local function showcard()
		self.listGoDice[self.listDraw[index].itemIndex]:SetActive(false)

		if self.type == 1 or self.type == 0 or self.type == 3 then
			self.PanelOne:SetActive(true)
			self.PanelTen:SetActive(false)
			self.GoCellOne:SetActive(true)
			self.ImageLight:SetActive(true)
			self:UpdateCell(self.GoCellOne, self.listDraw[1].data)
		else
			self.PanelOne:SetActive(false)
			self.PanelTen:SetActive(true)

			local g = self["GoCellCard" .. self.listDraw[index].itemIndex]

			g:SetActive(true)
			self:UpdateCell(g, self.listDraw[index].data)
		end
	end

	if hasChangeStar then
		ShowEffectFunc()

		self.timerChange = TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
			showcard()
		end, {})

		self:OnButtonGoNextClick()

		return
	end

	local function showDlgDrawOne()
		require("UI/Page/PageCardShop/DlgDrawOne")

		local dlgDrawOne = DlgDrawOne()

		dlgDrawOne.isSyncLoad = true

		UIMgr.AddPanel(dlgDrawOne, {
			callback = function()
				showcard()
				self.goDiceBoomCamera:SetActive(true)
				self:OnButtonGoNextClick()
			end,
			setter = sd
		})
	end

	local function showURcardShow()
		if infoRoleCard.rank == "ur" then
			require("UI/Page/PageCardShop/DlgURCardShow")

			local dlgURCardShow = DlgURCardShow()

			dlgURCardShow.isSyncLoad = true

			UIMgr.AddPanel(dlgURCardShow, {
				callback = function()
					showDlgDrawOne(true)
				end,
				infoRole = infoRole,
				infoRoleCard = infoRoleCard
			})
		else
			showDlgDrawOne()
		end
	end

	local function showNewRoleUnlock()
		if hasNewRole then
			require("UI/Page/PageCardShop/DlgNewRoleUnlock")

			local dlgNewRoleUnlock = DlgNewRoleUnlock()

			dlgNewRoleUnlock.isSyncLoad = true

			UIMgr.AddPanel(dlgNewRoleUnlock, {
				callback = function()
					showURcardShow(true)
				end,
				infoRole = infoRole
			})
			self:PlayVoice("Play_SE_020_0043")
		else
			showURcardShow()
		end
	end

	ShowEffectFunc()

	if index == 1 then
		self.timerNew = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
			self.goDiceBoomCamera:SetActive(false)
			showNewRoleUnlock()
		end, {})
	else
		self.goDiceBoomCamera:SetActive(false)
		showNewRoleUnlock()
	end
end

function DlgDrawCard:ShowNextChain(duration, cb)
	self.timerNext = TimerMgr.AddTimer(eTimerType.RealTime, duration, function()
		cb()

		cb = nil

		TimerMgr.RemoveTimer(self.timerNext)

		self.timerNext = nil
	end, nil)
end

function DlgDrawCard:AutoShowActionPanel()
	self.timerAutoShow = TimerMgr.AddTimer(eTimerType.RealTime, 0.4, function()
		self:OnButtonGoNextClick()
	end, {})
end

function DlgDrawCard:OnQuit()
	Event.Instance:Fire("ShowEffect", true)
	UIMgr.HideMsg()
	self:Close()
	SoundMgr.StopAll()
	SoundMgr.PostEvent(PATH_BGM_CARDSHOP, UIMgr.UICamera.gameObject)
end

function DlgDrawCard:OnButtonQuit()
	self:Close()
	Event.Instance:Fire("ShowBag", true)
end

function DlgDrawCard:OnButtonOk()
	if self.isInfinit then
		local function OnCallback(index)
			if index == 1 then
				self.DrawCardMore(self.type, self)
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), _("Desc_TipReDraw"), OnCallback, _("UI_OK"), _("Quite_Cancel"), true)
	else
		self:OnQuit()
	end
end

function DlgDrawCard:OnButtonDrawMore()
	if self.isInfinit then
		local function OnCallback(index)
			if index == 1 then
				local function callback(vPBMessage)
					LoadingMgr.Hide(eLoadingType.Repeat)

					if vPBMessage.result.code == NetManager.Result_Sucess then
						AppsFlyerService.SendGachaFinished(self.infoId)

						local info = CardPoolManager:Get(self.infoId)

						if self.type == 1 or self.type == 0 then
							info.usedTime = info.usedTime + 1
						else
							info.usedTime = info.usedTime + 10
						end

						if info.usedTime >= info.data.DayMaxNum then
							info.needShow = true
						end

						local setter = SetterData.GetSetterData(vPBMessage.setter)

						setter:Parse()
						Event.Instance:Fire("UpdateCardPool")
						self:OnQuit()
					elseif vMsg.result.code == NetManager.Result_Timeout then
						local strContent = _("Desc_NoNetwork")

						UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
							Restart()
						end, _("UI_OK"), nil, false)
					else
						UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
					end
				end

				NetManager:RequestDrawCard(self.infoId, 10, callback)
				LoadingMgr.Show(eLoadingType.Repeat)
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), _("Desc_TipConfirmDraw"), OnCallback, _("UI_OK"), _("Quite_Cancel"), true)
	else
		self.DrawCardMore(self.type, self)
	end
end

function DlgDrawCard:UpdateCell(g, setterData)
	local infoRoleCard = RoleCardMgr:GetRoleCard(setterData.id)
	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

	self.CardBg = GOUtil.FindChildComponent(g, "Main/CardMask/Bg", "RawImage")
	self.CardIcon = GOUtil.FindChildComponent(g, "Main/CardMask/CardIcon", "RawImage")
	self.ImgIcon = GOUtil.FindChildComponent(g, "Main/CardMask/Icon", "Image")

	GOUtil.DestroyAllChildren(self.CardIcon.gameObject)
	self.CardBg.gameObject:SetActive(false)
	self.CardIcon.gameObject:SetActive(false)
	UIUtil.SetImageSprite(self.ImgIcon, infoRoleCard.data.MidIcon, self)

	self.CardRank = GOUtil.FindChildComponent(g, "Main/CardRank", "Image")

	UIUtil.SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_10", self)

	self.CardName = GOUtil.FindChildComponent(g, "Main/CardName", "Text")
	self.CardName.text = infoRoleCard:GetName()
	self.CardJob = GOUtil.FindChildComponent(g, "Main/Job", "Image")

	UIUtil.SetImageSprite(self.CardJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S", self)

	self.CardLevel = GOUtil.FindChildComponent(g, "Main/TxtValue", "Text")
	self.CardLevel.text = 1
	self.GoFrame = GOUtil.FindChildGameObject(g, "Main/CardStar/Frame")
	self.GoStar1 = GOUtil.FindChildGameObject(g, "Main/CardStar/Star1")
	self.GoStar2 = GOUtil.FindChildGameObject(g, "Main/CardStar/Star2")

	RoleCardMgr:SetStar(infoRoleCard, self, 0)

	self.GoMain = GOUtil.FindChildGameObject(g, "Main")
	self.GoCardStar = GOUtil.FindChildGameObject(g, "ImageStar")

	self.GoMain:SetActive(true)
	self.GoCardStar:SetActive(false)

	self.ImageStar = GOUtil.FindChildComponent(g, "ImageStar", "Image")

	UIUtil.SetImageSprite(self.ImageStar, infoRoleCard.data.RoleStar, self)

	self.ImageStarCount = GOUtil.FindChildComponent(g, "ImageStar/TxtCount", "Text")
	self.ImageStarCount.text = "X" .. setterData.num
	self.GoNo = GOUtil.FindChildGameObject(g, "Go/GoNo")
	self.FX_DrawCardShow_CTL = GOUtil.FindChildGameObject(g, "Go/GoNo/FX_DrawCardShow_CTL")
	self.FX_DrawCardShow_STL = GOUtil.FindChildGameObject(g, "Go/GoNo/FX_DrawCardShow_STL")
	self.FX_DrawCardShow_Card = GOUtil.FindChildGameObject(g, "Go/GoNo/FX_DrawCardShow_Card")
	self.FX_DrawCardShow_Change = GOUtil.FindChildGameObject(g, "Go/GoNo/FX_DrawCardShow_Change")
	self.GoUR = GOUtil.FindChildGameObject(g, "Go/GoUR")
	self.FX_DrawCardShow_CardUR = GOUtil.FindChildGameObject(g, "Go/GoUR/FX_DrawCardShow_CardUR")
	self.FX_DrawCardShow_ChangeUR = GOUtil.FindChildGameObject(g, "Go/GoUR/FX_DrawCardShow_ChangeUR")
	self.FX_DrawCardShow_CTLUR = GOUtil.FindChildGameObject(g, "Go/GoUR/FX_DrawCardShow_CTLUR")
	self.FX_DrawCardShow_STLUR = GOUtil.FindChildGameObject(g, "Go/GoUR/FX_DrawCardShow_STLUR")

	self.GoNo:SetActive(false)
	self.GoUR:SetActive(false)
	self.FX_DrawCardShow_CTL:SetActive(false)
	self.FX_DrawCardShow_STL:SetActive(false)
	self.FX_DrawCardShow_Card:SetActive(false)
	self.FX_DrawCardShow_Change:SetActive(false)
	self.FX_DrawCardShow_CardUR:SetActive(false)
	self.FX_DrawCardShow_ChangeUR:SetActive(false)
	self.FX_DrawCardShow_CTLUR:SetActive(false)
	self.FX_DrawCardShow_STLUR:SetActive(false)

	local isUR = infoRoleCard.rank == "ur"
	local isSSR = infoRoleCard.rank == "ssr"

	if isUR then
		self.GoUR:SetActive(true)
		self.FX_DrawCardShow_CTLUR:SetActive(true)
		self.FX_DrawCardShow_CardUR:SetActive(true)
	elseif isSSR then
		self.GoNo:SetActive(true)
		self.FX_DrawCardShow_CTL:SetActive(true)
		self.FX_DrawCardShow_Card:SetActive(true)
	else
		self.GoNo:SetActive(false)
	end
end

function DlgDrawCard:CellShowStar(g, setterData)
	if IsNil(g) then
		return
	end

	local GoMain = GOUtil.FindChildGameObject(g, "Main")
	local GoCardStar = GOUtil.FindChildGameObject(g, "ImageStar")

	GoMain:SetActive(false)
	GoCardStar:SetActive(true)

	local infoRoleCard = RoleCardMgr:GetRoleCard(setterData.id)
	local ImageStar = GOUtil.FindChildComponent(g, "ImageStar", "Image")

	UIUtil.SetImageSprite(ImageStar, infoRoleCard.data.RoleStar .. "_02", self)

	self.GoNo = GOUtil.FindChildGameObject(g, "Go/GoNo")
	self.FX_DrawCardShow_CTL = GOUtil.FindChildGameObject(g, "Go/GoNo/FX_DrawCardShow_CTL")
	self.FX_DrawCardShow_STL = GOUtil.FindChildGameObject(g, "Go/GoNo/FX_DrawCardShow_STL")
	self.FX_DrawCardShow_Card = GOUtil.FindChildGameObject(g, "Go/GoNo/FX_DrawCardShow_Card")
	self.FX_DrawCardShow_Change = GOUtil.FindChildGameObject(g, "Go/GoNo/FX_DrawCardShow_Change")
	self.GoUR = GOUtil.FindChildGameObject(g, "Go/GoUR")
	self.FX_DrawCardShow_CardUR = GOUtil.FindChildGameObject(g, "Go/GoUR/FX_DrawCardShow_CardUR")
	self.FX_DrawCardShow_ChangeUR = GOUtil.FindChildGameObject(g, "Go/GoUR/FX_DrawCardShow_ChangeUR")
	self.FX_DrawCardShow_CTLUR = GOUtil.FindChildGameObject(g, "Go/GoUR/FX_DrawCardShow_CTLUR")
	self.FX_DrawCardShow_STLUR = GOUtil.FindChildGameObject(g, "Go/GoUR/FX_DrawCardShow_STLUR")

	self.GoNo:SetActive(false)
	self.GoUR:SetActive(false)
	self.FX_DrawCardShow_CTL:SetActive(false)
	self.FX_DrawCardShow_STL:SetActive(false)
	self.FX_DrawCardShow_Card:SetActive(false)
	self.FX_DrawCardShow_Change:SetActive(false)
	self.FX_DrawCardShow_CardUR:SetActive(false)
	self.FX_DrawCardShow_ChangeUR:SetActive(false)
	self.FX_DrawCardShow_CTLUR:SetActive(false)
	self.FX_DrawCardShow_STLUR:SetActive(false)

	local isUR = infoRoleCard.rank == "ur"
	local isSSR = infoRoleCard.rank == "ssr"

	if isUR then
		self.GoUR:SetActive(true)
		self.FX_DrawCardShow_ChangeUR:SetActive(true)
		self.FX_DrawCardShow_STLUR:SetActive(true)
	elseif isSSR then
		self.GoNo:SetActive(true)
		self.FX_DrawCardShow_Change:SetActive(true)
		self.FX_DrawCardShow_STL:SetActive(true)
	else
		self.GoNo:SetActive(false)
	end
end

function DlgDrawCard:OnUpdataItem()
	local cardPoolInfo = CardPoolManager:Get(self.infoId)

	if cardPoolInfo.data.ActiveType ~= 0 then
		if cardPoolInfo.data.ActiveType == eCardPoolActiveType.StepUpPool then
			if cardPoolInfo.data.DayMaxNum > cardPoolInfo.usedTime then
				local itemId = cardPoolInfo.data.TenCost[1]
				local infoItem = ItemManager:Get(itemId)

				self.BtnDrawText.text = Lang(cardPoolInfo.data.BtnText[3])
				self.TextNum.text = cardPoolInfo.data.TenCost[2] .. "/" .. TenaryOp(itemId == 502, PlayerInst:GetDiamondAll(), infoItem:GetCurResNum())
			else
				local list = CardPoolManager:GetActivePoolList(cardPoolInfo.data.ActiveID)
				local nextInfo

				for i, v in ipairs(list) do
					if v.data.StepUpOrder == cardPoolInfo.data.StepUpOrder + 1 and v.data.StepUpTurn == cardPoolInfo.data.StepUpTurn then
						nextInfo = v

						break
					end
				end

				if nextInfo then
					local itemId = nextInfo.data.TenCost[1]
					local infoItem = ItemManager:Get(itemId)

					self.BtnDrawText.text = Lang(nextInfo.data.BtnText[3])
					self.TextNum.text = nextInfo.data.TenCost[2] .. "/" .. TenaryOp(itemId == 502, PlayerInst:GetDiamondAll(), infoItem:GetCurResNum())
				end
			end
		end
	else
		local itemId = self.costItemId
		local infoItem = ItemManager:Get(itemId)

		if self.type == 1 or self.type == 0 then
			self.BtnDrawText.text = Lang(cardPoolInfo.data.BtnText[2])
			self.TextNum.text = self.costItemNum .. "/" .. TenaryOp(itemId == 502, PlayerInst:GetDiamondAll(), infoItem:GetCurResNum())
		else
			self.BtnDrawText.text = Lang(cardPoolInfo.data.BtnText[3])
			self.TextNum.text = self.costItemNum .. "/" .. TenaryOp(itemId == 502, PlayerInst:GetDiamondAll(), infoItem:GetCurResNum())
		end
	end
end

function DlgDrawCard:PlayVoice(strPath)
	self.curPlayVoice = strPath

	SoundMgr.Play(self.curPlayVoice)
end

function DlgDrawCard:ShowCardInfo(data)
	if data.clickCount == 1 then
		if not self.isFinish then
			return
		end

		local go = data.pointerPressRaycast.gameObject
		local index = tonumber(go.name)
		local sd

		for i = 1, #self.listDraw do
			if self.listDraw[i].itemIndex == index then
				sd = self.listDraw[i].data

				break
			end
		end

		if not sd then
			return
		end

		local hasChangeStar = not (sd.newRoleCard.id > 0)

		if hasChangeStar then
			return
		end

		local data = {
			onlyShow = true,
			cardId = sd.id
		}

		UIMgr.AddPanel(PageRoleCard(), data)
	end
end

function DlgDrawCard:ShowOneCardInfo(data)
	if data.clickCount == 1 then
		if not self.isFinish then
			return
		end

		local sd = self.listDraw[1].data

		if not sd then
			return
		end

		local hasChangeStar = not (sd.newRoleCard.id > 0)

		if hasChangeStar then
			return
		end

		local data = {
			onlyShow = true,
			cardId = sd.id
		}

		UIMgr.AddPanel(PageRoleCard(), data)
	end
end

function DlgDrawCard:OnBackAndroid()
	local VideoBG = self:GetChildGameObject("VideoBG")
	local VideoBG2 = self:GetChildGameObject("VideoBG2")

	if GOUtil.IsActiveSelf(VideoBG) or GOUtil.IsActiveSelf(VideoBG2) then
		self:OnButtonSkip()
	elseif GOUtil.IsActiveSelf(self.ButtonOne) and GOUtil.IsActiveSelf(self.ActionPanel) then
		self:OnButtonOk()
	end

	return true
end
