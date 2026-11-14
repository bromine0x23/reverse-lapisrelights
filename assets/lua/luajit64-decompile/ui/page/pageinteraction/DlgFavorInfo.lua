-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/DlgFavorInfo.lua

require("UI/Page/PageInteraction/CellFavor")
require("UI/Page/PageInteraction/CellFavorUnlock")

local favorPose = require("luaData/FavorPose")

DlgFavorInfo = class("DlgFavorInfo", UIPanel)

function DlgFavorInfo:ctor()
	self.UIPrefabPath = "UI/PageInteraction/DlgFavorInfo"
end

function DlgFavorInfo:PreLoad()
	self:LoadResAsync("UI/PageInteraction/CellFavor", "PrefabCellFavor")
	self:LoadResAsync("UI/PageInteraction/CellFavorUnlock", "PrefabCellFavorUnlock")

	self.listSectIcon = GetConfigArgJson("FavorRankIcon")

	for key, value in pairs(self.listSectIcon) do
		self:LoadAssetsAsync(value)
	end
end

function DlgFavorInfo:OnEnter()
	self.UIRootObject.transform:SetAsFirstSibling()

	self.listSect = GetConfigArgJson("FavorSection")
	self.listSectName = GetConfigArgJson("FavorRankName")
	self.GoImageInfo = self:GetChildGameObject("ImageInfo")
	self.PanelFavorInfo = self:GetChildGameObject("ImageInfo/Click")
	self.FavorAnimator = GOUtil.GetComponent(self.PanelFavorInfo, "Animator")
	self.TextFavorLevel = self:GetChildComponent("ImageInfo/ImageHeart/TxtFavorLevel", "Text")
	self.GoImageBar = self:GetChildGameObject("ImageInfo/ImageBar")
	self.ImageFillFavor = self:GetChildComponent("ImageInfo/ImageBar/Image", "Image")
	self.TextFavorValue = self:GetChildComponent("ImageInfo/ImageBar/TxtFavorExp", "Text")
	self.TextFavorSection = self:GetChildComponent("ImageInfo/TxtFavorName", "Text")
	self.ImageFavorSection = self:GetChildComponent("ImageInfo/ImageHeart", "Image")
	self.btn_favor_level = self:GetChildGameObject("ImageInfo/ImageHeart/btn_favor_level")
	self.TextSectName = self:GetChildComponent("ImageInfo/ImageHeart/TextSectName", "Text")
	self.Favor_Heart_Ani = self:GetChildComponent("ImageInfo/ImageHeart/img_Favor", "Animator")
	self.Favor_Heart_Ani_Text = self:GetChildComponent("ImageInfo/ImageHeart/img_Favor/Text", "Text")
	self.Favor_Heart_Ani2 = self:GetChildComponent("Effect/img_Favor2", "Animator")
	self.Favor_Heart_Ani_Text2 = self:GetChildComponent("Effect/img_Favor2/Text", "Text")
	self.TextClickTip = self:GetChildComponent("ImageInfo/TextClickTip", "Text")
	self.FX_Max = self:GetChildComponent("Effect/FX_Max/Particle System (1)", "ParticleSystem")
	self.TextClickTip.text = Lang(40013)

	if UIMgr.GetCurPanel().className == "PageInteraction" then
		SetActiveFunc(self.TextClickTip.gameObject, true)
	else
		SetActiveFunc(self.TextClickTip.gameObject, false)
	end

	local maxFavorLevel = GetConfigArgInt("FavorMaxLevel") - 1

	self.curMaxAddExp = LevelManager:GetRoleFavorExp(maxFavorLevel)
	self.listSectLevel = {}

	for i = 1, #self.listSectName do
		self:SetImageSprite(self.ImageIcon, self.listSectIcon[i])

		local needLv = 1

		if index == 1 then
			needLv = 1
		else
			needLv = self.listSect[i - 1]
			needLv = needLv == nil and 1 or needLv + 1
		end

		table.insert(self.listSectLevel, needLv)
	end

	self.ButtonMsg = self:GetChildGameObject("ImageInfo/ButtonMsg")
	self.PanelDlg = self:GetChildGameObject("PanelDlg")
	self.TextDlg = self:GetChildComponent("PanelDlg/Text", "Text")

	SetActiveFunc(self.PanelDlg, false)

	self.SectImg = self:GetChildComponent("FavorUnlock/SectBg/Image (1)", "Image")
	self.FavorLevelTxt = self:GetChildComponent("FavorUnlock/SectBg/TextFavorLevel", "Text")
	self.BackBtn = self:GetChildGameObject("FavorUnlock/BackBtn")
	self.NextBtn = self:GetChildGameObject("FavorUnlock/NextBtn")
	self.FavorUnlock = self:GetChildGameObject("FavorUnlock")
	self.CloseBtn = self:GetChildGameObject("CloseBtn")

	self:Localization()
	self:StartTimerFrame()
end

function DlgFavorInfo:ChangeFavor(data)
	if data.preFavorLevel then
		for i = data.preFavorLevel, data.curFavorLevel do
			local info = {}

			if i == data.curFavorLevel then
				info.data = data
			end

			info.level = i
			info.curFavorNextExp = LevelManager:GetRoleFavorNeedExp(info.level)
			info.sectionIndex = RoleMgr:GetFavorSectionIndex(info.level)
			info.value = self.infoRole.curFavorExp / self.infoRole.curFavorNextExp

			table.insert(self.aimList, info)
		end
	else
		local info = {}

		info.level = self.infoRole.curFavorLevel
		info.curFavorNextExp = LevelManager:GetRoleFavorNeedExp(info.level)
		info.sectionIndex = RoleMgr:GetFavorSectionIndex(info.level)
		info.value = self.infoRole.curFavorExp / self.infoRole.curFavorNextExp

		table.insert(self.aimList, info)
	end

	local isLevelUp = false
	local length = #self.aimList

	for i = length, 1, -1 do
		if isLevelUp then
			self.aimList[i].data = false
		end

		if self.aimList[i].data then
			isLevelUp = true
		end

		if length - i >= 5 then
			table.remove(self.aimList, i)
		end
	end
end

function DlgFavorInfo:ShowBlock()
	if self.BlockUI == nil then
		require("UI/Dlg/Public/DlgBlock")

		self.BlockUI = DlgBlock()
		DlgBlock.isSyncLoad = true

		UIMgr.AddPanel(self.BlockUI, nil, UIMgr.UIPopupObject)
	end
end

function DlgFavorInfo:HideBlock()
	if self.BlockUI then
		self.BlockUI:Close()

		self.BlockUI = nil
	end
end

function DlgFavorInfo:StartTimerFrame()
	self.fillSpeed = 0.1
	self.fillMax = false
	self.aimList = {}
	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.017, function()
		if self.fillMax then
			self.fillMax = false
			self.ImageFillFavor.fillAmount = 0

			return
		end

		if #self.aimList > 0 then
			self:ShowBlock()

			local info = self.aimList[1]
			local max = 1

			self.ImageFillFavor.fillAmount = self.ImageFillFavor.fillAmount + self.fillSpeed
			self.TextFavorValue.text = math.floor(self.ImageFillFavor.fillAmount * info.curFavorNextExp) .. "/" .. info.curFavorNextExp

			if #self.aimList == 1 then
				max = info.value
				self.TextFavorLevel.text = info.level

				local name = self.listSectName[info.sectionIndex]

				self.TextSectName.text = Lang(name)

				self:SetImageSprite(self.ImageFavorSection, self.listSectIcon[info.sectionIndex])

				self.TextFavorValue.text = self.infoRole.curFavorExp .. "/" .. self.infoRole.curFavorNextExp
			end

			if max <= self.ImageFillFavor.fillAmount then
				self.ImageFillFavor.fillAmount = max

				if self.ImageFillFavor.fillAmount == 1 then
					self.ImageFillFavor.fillAmount = 1
					self.fillMax = true
				end

				if info.level >= GetConfigArgInt("FavorMaxLevel") then
					self.ImageFillFavor.fillAmount = 1
					self.TextFavorValue.text = "Max"
					self.fillMax = false
				end

				if info.data then
					require("UI/Page/PageInteraction/DlgFavorUp")
					UIMgr.AddPanel(DlgFavorUp(), info.data)
				end

				table.remove(self.aimList, 1)
			end
		else
			self:HideBlock()
		end
	end, self, -1)
end

function DlgFavorInfo:StopTimerFrame()
	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end
end

function DlgFavorInfo:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("FavorUnlock/SectBg/Text", "Text")
	TextAuto.text = _("Desc_Relationship")
	TextAuto = self:GetChildComponent("FavorUnlock/SectBg/Text2", "Text")
	TextAuto.text = _("FavorInfo_GoodFeelLevel")
	TextAuto = self:GetChildComponent("FavorUnlock/UnlockBG/Tital/Text", "Text")
	TextAuto.text = _("FavorInfo_GoodFeelLevel")
	TextAuto = self:GetChildComponent("FavorUnlock/BackBtn/Text", "Text")
	TextAuto.text = _("Desc_Stepup")
	TextAuto = self:GetChildComponent("FavorUnlock/NextBtn/Text", "Text")
	TextAuto.text = _("Desc_Nextstep")
end

function DlgFavorInfo:HideVRBtn()
	SetActiveFunc(self.ButtonMsg, false)
end

function DlgFavorInfo:Init(infoRole, actor, index)
	if self.infoRole and self.infoRole ~= infoRole then
		InfoSoundEventMgr:UnloadBank(self.infoRole.data.VocalBank)
	end

	self.infoRole = infoRole
	self.actor = actor
	self.index = index

	self:InitData()
	self:NotifyUpdate()
	self:InitScrollViewFavorUnlock()

	self.TextFavorSection.text = self.infoRole:GetName()

	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
end

function DlgFavorInfo:RefreshRole(infoRole, actor, index)
	if self.infoRole and self.infoRole ~= infoRole then
		InfoSoundEventMgr:UnloadBank(self.infoRole.data.VocalBank)
	end

	self.infoRole = infoRole
	self.actor = actor
	self.index = index

	self:NotifyUpdate()
	self:InitData()

	self.TextFavorSection.text = self.infoRole:GetName()

	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
end

function DlgFavorInfo:Purge()
	DlgFavorInfo.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	if self.FavorScrollTool then
		self.FavorScrollTool:Purge()
	end

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	if self.infoRole then
		InfoSoundEventMgr:UnloadBank(self.infoRole.data.VocalBank)
	end

	if self.index then
		Event.Instance:Fire("SetVcScreenX", {
			index = self.index
		})
	end

	ResourceMgr.Unload(self.PrefabCellFavorUnlock)
	ResourceMgr.Unload(self.PrefabCellFavor)

	self.aimList = {}

	self:StopTimerFrame()
end

function DlgFavorInfo:OnRegisterEvent()
	self:AddClick(self.PanelFavorInfo, self.OnClickHeart)
	self:AddClick(self.CloseBtn, self.OnClickCloseBtn)
	self:AddClick(self.ButtonMsg, self.OnClickedButtonMsg)
	Event.Instance:Add(EventEnum.UpdateFavorTouch, self.NotifyUpdate, self)
	Event.Instance:Add(EventEnum.PlayVoice, self.PlayVoice, self)
	Event.Instance:Add("FavorLevelUp", self.FavorLevelUp, self)
	Event.Instance:Add("ChangeFavor", self.ChangeFavor, self)
	self:AddClick(self.BackBtn, self.OnClickBack)
	self:AddClick(self.NextBtn, self.OnClickNext)
	self:AddClick(self.btn_favor_level, self.OnClickFavorLevel)
	Event.Instance:Add("ShowSubTitle", self.ShowSubTitle, self)
	EventListenerMgr.AddAnimListener(self.Favor_Heart_Ani.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.AddAnimListener(self.Favor_Heart_Ani2.gameObject, self.EventAnim2, self, eAnimEventType.OnAnimationEnd)
end

function DlgFavorInfo:OnUnRegisterEvent()
	self:RemoveClick(self.PanelFavorInfo, self.OnClickHeart)
	self:RemoveClick(self.CloseBtn, self.OnClickCloseBtn)
	self:RemoveClick(self.ButtonMsg, self.OnClickedButtonMsg)
	Event.Instance:Remove(EventEnum.UpdateFavorTouch, self.NotifyUpdate, self)
	Event.Instance:Remove(EventEnum.PlayVoice, self.PlayVoice, self)
	Event.Instance:Remove("FavorLevelUp", self.FavorLevelUp, self)
	Event.Instance:Remove("ChangeFavor", self.ChangeFavor, self)
	self:RemoveClick(self.BackBtn, self.OnClickBack)
	self:RemoveClick(self.NextBtn, self.OnClickNext)
	self:RemoveClick(self.btn_favor_level, self.OnClickFavorLevel)
	Event.Instance:Remove("ShowSubTitle", self.ShowSubTitle, self)
	EventListenerMgr.RemoveAnimListener(self.Favor_Heart_Ani.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.RemoveAnimListener(self.Favor_Heart_Ani2.gameObject, self.EventAnim2, self, eAnimEventType.OnAnimationEnd)
end

function DlgFavorInfo:PlayVoice(str, actor)
	do return end

	print("PlayVoice")

	local listPath = self.infoRole.data.Vocals
	local strPath, strVocal

	for i = 1, #listPath do
		local list = listPath[i]
		local key = list[1]

		if key == str then
			strPath = list[2]
			strVocal = tonumber(list[3])
		end
	end

	if strPath then
		if self.isPlayering then
			return
		end

		self.isPlayering = true

		SoundMgr.PlayWithCallback(strPath, AkCallbackType.AK_EndOfEvent, AkCallbackManager.EventCallback(function(in_cookie, in_type, in_info)
			self.isPlayering = false
		end))

		local ActorLipSync = GOUtil.AddMissingComponent(self.UIRootObject, "ActorLipSync")

		ActorLipSync:Init(self.infoRole.data.Lips)

		if actor then
			ActorLipSync:Play(actor, strPath)
		else
			self:ShowSubTitle(Lang(strVocal))

			if self.actor then
				ActorLipSync:Play(self.actor, strPath)
			end
		end
	end
end

function DlgFavorInfo:UpdateFavorIdleName(str)
	self.TextFavorSection.text = str
end

function DlgFavorInfo:NotifyUpdate()
	if self.FavorUnlock.activeSelf == false then
		self.TextFavorLevel.text = self.infoRole.curFavorLevel
	end

	self.TextFavorValue.text = self.infoRole.curFavorExp .. "/" .. self.infoRole.curFavorNextExp
	self.ImageFillFavor.fillAmount = self.infoRole.curFavorExp / self.infoRole.curFavorNextExp

	if self.infoRole.curFavorLevel == GetConfigArgInt("FavorMaxLevel") then
		self.TextFavorValue.text = "Max"
		self.ImageFillFavor.fillAmount = 1
	end

	self.TextAddExp = self:GetChildComponent("ImageInfo/ImageBar/TextAddExp", "Text")
	self.ImgAddExp = self:GetChildGameObject("ImageInfo/ImageBar/Image2")
	self.TextAddLevel = self:GetChildComponent("ImageInfo/ImageHeart/TextAddLevel", "Text")
	self.AddLevelAnimator = self:GetChildComponent("ImageInfo/ImageHeart/TextAddLevel", "Animator")
	self.AddExpAnimator = self:GetChildComponent("ImageInfo/ImageBar/TextAddExp", "Animator")
	self.FavorLevelTxt.text = self.infoRole.curFavorLevel

	local maxFavorLevel = GetConfigArgInt("FavorMaxLevel")
	local maxExp = LevelManager:GetRoleFavorNeedExp(maxFavorLevel)
	local rate = 1 / (#self.listSectIcon - 1)
	local curSectTouchLevel = self.listSectLevel[self.infoRole.sectionIndex]
	local nextSectTouchLevel = 1

	if self.infoRole.sectionIndex + 1 <= #self.listSectLevel then
		nextSectTouchLevel = self.listSectLevel[self.infoRole.sectionIndex + 1]
	end

	local addAmount = (self.infoRole.curFavorLevel - curSectTouchLevel) / (nextSectTouchLevel - curSectTouchLevel)

	if self.infoRole.sectionIndex >= #self.listSectLevel then
		self.infoRole.sectionIndex = #self.listSectLevel
	end

	local name = self.listSectName[self.infoRole.sectionIndex]

	self.TextFavorSection.text = self.infoRole:GetName()
	self.TextSectName.text = Lang(name)

	self:SetImageSprite(self.ImageFavorSection, self.listSectIcon[self.infoRole.sectionIndex])
	Event.Instance:Fire("UpdateAddLevelGift", true)
end

function DlgFavorInfo:ShowSubTitle(str)
	if IsNil(self.PanelDlg) then
		return
	end

	SetActiveFunc(self.PanelDlg, true)

	self.TextDlg.text = str

	local function cb()
		if not IsNil(self.PanelDlg) then
			SetActiveFunc(self.PanelDlg, false)
		end
	end

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	self.timeId = TimerMgr.AddTimer(eTimerType.RealTime, 4, cb, self)
end

function DlgFavorInfo:AddExpLevel(list, hideAdd)
	if list == nil then
		return
	end

	if tonumber(list[4]) ~= 0 then
		local text = "<size=60>+</size>" .. list[3]

		if self.TextAddLevel.text ~= text then
			self.TextAddLevel.text = text

			if self.AddLevelAnimatorTime ~= nil and Time.time - self.AddLevelAnimatorTime < 0.2 then
				self.TextAddExp.text = "<color=#585E62>" .. _("Friendliness") .. "</color>+" .. list[4]

				return
			end

			if self.AddLevelAnimator.isActiveAndEnabled then
				self.AddLevelAnimator:Play("TextAddLevel_change", 0, 0)
			end

			self.AddLevelAnimatorTime = Time.time
		end

		text = "<color=#585E62>" .. _("Friendliness") .. "</color>+" .. list[4]

		if self.TextAddExp.text ~= text then
			self.TextAddExp.text = text

			if self.AddExpAnimatorTime ~= nil and Time.time - self.AddExpAnimatorTime < 0.2 then
				return
			end

			if self.AddExpAnimator.isActiveAndEnabled then
				self.AddExpAnimator:Play("TextAddExp_change", 0, 0)
			end

			self.AddExpAnimatorTime = Time.time
		end

		SetActiveFunc(self.TextAddLevel.gameObject, list[3] ~= 0 and not hideAdd)
		SetActiveFunc(self.TextAddExp.gameObject, self.infoRole.curFavorLevel ~= GetConfigArgInt("FavorMaxLevel"))
		SetActiveFunc(self.ImgAddExp, self.infoRole.curFavorLevel ~= GetConfigArgInt("FavorMaxLevel"))
	else
		SetActiveFunc(self.TextAddExp.gameObject, false)
		SetActiveFunc(self.ImgAddExp, false)
		SetActiveFunc(self.TextAddLevel.gameObject, false)
	end
end

function DlgFavorInfo:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function DlgFavorInfo:OnClickedCell(data)
	local go = data.pointerPress.transform.gameObject

	print(go.name)

	local info = self.FavorScrollTool.ItemRoot2ItemDict:GetValue(go)

	if info.Item.unlockInfo.type == eFavorUnlockType.vocal then
		local behaviourData = info.Item.unlockInfo.data.behaviourData

		if self.curbehaviourData ~= nil and self.curbehaviourData:Equals(behaviourData) then
			return
		end

		if self.FavorScrollTool.ItemRoot2ItemDict then
			for _, v in self.FavorScrollTool.ItemRoot2ItemDict:Enumerator() do
				if not IsNil(v.Item.Animator) and v.Item.Animator.isActiveAndEnabled then
					v.Item.Animator:Play("Empty")
				end
			end
		end
	end

	info.Item:OnGoToClick()
end

function DlgFavorInfo:PlayVoiceAndAnim(data, item)
	self.playItem = item

	local actor = SceneMainStage.Instance.curActor

	self.curbehaviourData = data

	if self.curbehaviourData.SoundEvent ~= nil and self.curbehaviourData.SoundEvent ~= "" then
		item.Animator:Play("Voice_Loop")
	end

	PreviewAnim(data, actor, actor.InteractSettingFile, nil, nil, function()
		if data:Equals(self.curbehaviourData) then
			for _, v in self.FavorScrollTool.ItemRoot2ItemDict:Enumerator() do
				if v.Item.unlockInfo and v.Item.unlockInfo.type == eFavorUnlockType.vocal and v.Item.unlockInfo.data.behaviourData == data and not IsNil(v.Item.Animator) then
					v.Item.Animator:Play("Empty")
				end
			end

			self.curbehaviourData = nil
		end
	end)
end

function DlgFavorInfo:OnClickedButtonMsg()
	return
end

function DlgFavorInfo:InitData()
	local actor = SceneMainStage.Instance.curActor

	self.listVoice = {}

	local isf = actor.InteractSettingFile
	local listGroup = GetISFBehaviour(isf)
	local listGroupName = {
		"Desc_GoodMorning",
		"Desc_GoodNight",
		"Desc_PrepareGiveGiftsToPlayer",
		"Desc_GiveGiftsToPlayer",
		"Desc_GiveGiftsToIdol",
		"Desc_GiveFavoriteToIdol",
		"Desc_TouchIdolHead",
		"Desc_IdolHead",
		"Desc_IdolBody",
		"Desc_IdolFavorability",
		"Desc_LevelUp",
		"Desc_StageUp",
		"Desc_Highest",
		"Desc_ChangeAvatar",
		"Desc_ChangeHeadAvatar",
		"Desc_ChangeBackAvatar"
	}

	for i = 1, #listGroupName do
		if i == 3 or i == 7 or i == 15 or i == 16 then
			-- block empty
		else
			local group = listGroup[i]
			local listBehaviour = group.m_Behaviours

			for n = 1, listBehaviour.Count do
				behaviourData = listBehaviour:get_Item(n - 1)

				local data = {}

				data.name = Lang(tonumber(behaviourData.VoiceName))
				data.behaviourData = behaviourData

				if behaviourData.ShowInVoiceList then
					table.insert(self.listVoice, data)
				end
			end
		end
	end
end

eFavorUnlockType = {
	cost = 4,
	equipment = 3,
	phoneCall = 8,
	skillNode = 5,
	topic = 7,
	stage = 2,
	ar = 6,
	vocal = 1
}

function DlgFavorInfo:GetFavorUnlockList(favorIndex)
	local listSect = GetConfigArgJson("FavorSection")
	local minLevel = 0
	local maxLevel = 0

	minLevel = favorIndex < 2 and 2 or listSect[favorIndex - 1]
	maxLevel = favorIndex > #listSect and 50 or listSect[favorIndex]

	local unlockList = {}

	for i = 1, #self.listVoice do
		local needFavorLv = self.listVoice[i].behaviourData.Level

		if needFavorLv >= TenaryOp(favorIndex == 1, 0, minLevel) and needFavorLv <= maxLevel then
			local unlockData = {}

			unlockData.type = eFavorUnlockType.vocal
			unlockData.data = self.listVoice[i]
			unlockData.level = needFavorLv

			table.insert(unlockList, unlockData)
		end
	end

	local listStage = ChapterMgr:GetCurChapter(ChapterType.role, self.infoRole.id).listStage

	for i = 1, #listStage do
		local needFavorLv = listStage[i].data.FavorLevel

		if needFavorLv ~= 1 and minLevel <= needFavorLv and needFavorLv <= maxLevel then
			local unlockData = {}

			unlockData.type = eFavorUnlockType.stage
			unlockData.data = listStage[i]
			unlockData.level = needFavorLv

			table.insert(unlockList, unlockData)
		end
	end

	local listEquip = GetConfigArgJson("EquipmentUnlock")

	for i = 1, #listEquip do
		local needFavorLv = listEquip[i]

		if needFavorLv ~= 1 and minLevel <= needFavorLv and needFavorLv <= maxLevel then
			local unlockData = {}

			unlockData.type = eFavorUnlockType.equipment
			unlockData.data = listEquip[i]
			unlockData.level = needFavorLv

			table.insert(unlockList, unlockData)
		end
	end

	local haveCostUnlock = false

	for i = minLevel - 1, maxLevel - 1 do
		local cost1 = LevelManager:GetFavorValue("CardCostRatio", i)
		local cost2 = LevelManager:GetFavorValue("CardCostRatio", i + 1)

		if cost2 ~= cost1 then
			if i + 1 > self.infoRole.curFavorLevel then
				local unlockData = {}

				unlockData.type = eFavorUnlockType.cost
				unlockData.level = i + 1

				table.insert(unlockList, unlockData)
			elseif not haveCostUnlock then
				haveCostUnlock = true

				local unlockData = {}

				unlockData.type = eFavorUnlockType.cost
				unlockData.level = i + 1

				table.insert(unlockList, unlockData)
			end
		end
	end

	local favorPoseList = self:GetFavorPose()

	for i = 1, #favorPoseList do
		local needFavorLv = favorPoseList[i].FavorLevel

		if needFavorLv ~= 1 and minLevel <= needFavorLv and needFavorLv <= maxLevel then
			if needFavorLv > self.infoRole.curFavorLevel then
				local unlockData = {}

				unlockData.type = eFavorUnlockType.ar
				unlockData.data = favorPoseList[i]
				unlockData.level = needFavorLv

				table.insert(unlockList, unlockData)
			else
				local unlockData = {}

				unlockData.type = eFavorUnlockType.ar
				unlockData.data = favorPoseList[i]
				unlockData.level = needFavorLv

				table.insert(unlockList, unlockData)
			end
		end
	end

	local favorTopicList = TopicManager:GetAllTopicList(self.infoRole.id)

	for i = 1, #favorTopicList do
		local needFavorLv = favorTopicList[i].data.FavorUnlockLevel

		if needFavorLv ~= 0 and minLevel <= needFavorLv and needFavorLv <= maxLevel then
			if needFavorLv > self.infoRole.curFavorLevel then
				local unlockData = {}

				unlockData.type = eFavorUnlockType.topic
				unlockData.data = favorTopicList[i].data
				unlockData.level = needFavorLv

				table.insert(unlockList, unlockData)
			else
				local unlockData = {}

				unlockData.type = eFavorUnlockType.topic
				unlockData.data = favorTopicList[i].data
				unlockData.level = needFavorLv

				table.insert(unlockList, unlockData)
			end
		end
	end

	local favorPhoneCallList = PhoneCallManager:GetAllPhoneCallList(self.infoRole.id)

	for i = 1, #favorPhoneCallList do
		local needFavorLv = favorPhoneCallList[i].data.FavorUnlockLevel

		if needFavorLv ~= 0 and minLevel <= needFavorLv and needFavorLv <= maxLevel then
			if needFavorLv > self.infoRole.curFavorLevel then
				local unlockData = {}

				unlockData.type = eFavorUnlockType.phoneCall
				unlockData.data = favorPhoneCallList[i].data
				unlockData.level = needFavorLv

				table.insert(unlockList, unlockData)
			else
				local unlockData = {}

				unlockData.type = eFavorUnlockType.phoneCall
				unlockData.data = favorPhoneCallList[i].data
				unlockData.level = needFavorLv

				table.insert(unlockList, unlockData)
			end
		end
	end

	table.sort(unlockList, function(a, b)
		if self.infoRole.curFavorLevel >= a.level and self.infoRole.curFavorLevel >= b.level then
			if a.type < b.type then
				return true
			elseif a.type == b.type then
				return a.level < b.level
			else
				return false
			end
		else
			return a.level < b.level
		end
	end)

	return unlockList
end

function DlgFavorInfo:GetFavorPose()
	local list = {}
	local id = self.infoRole.data.ID

	for i = 1, #favorPose do
		local v = favorPose[i]

		if v.Character == id then
			table.insert(list, v)
		end
	end

	return list
end

function DlgFavorInfo:OnClickHeart()
	if self.FavorUnlock.activeSelf == false and UIMgr.GetCurPanel().className == "PageInteraction" then
		self.favorIndex = RoleMgr:GetFavorSectionIndex(self.infoRole.curFavorLevel)

		SetActiveFunc(self.FavorUnlock, true)
		SetActiveFunc(self.CloseBtn, true)
		self:UpdateFavorUnlock(self.favorIndex)
		self:UpdateShowFavorLevelBtn(true)
		SetActiveFunc(self.TextClickTip.gameObject, false)
		Event.Instance:Fire("SetVcScreenX", {
			isLeft = true,
			leftOffset = 0.4,
			index = self.index
		})
	else
		SetActiveFunc(self.FavorUnlock, false)
		self:NotifyUpdate()

		if UIMgr.GetCurPanel().className == "PageInteraction" then
			SetActiveFunc(self.TextClickTip.gameObject, true)
			Event.Instance:Fire("SetVcScreenX", {
				isLeft = false,
				index = self.index
			})
		end
	end
end

function DlgFavorInfo:OnClickCloseBtn()
	SetActiveFunc(self.FavorUnlock, false)
	SetActiveFunc(self.CloseBtn, false)
	SetActiveFunc(self.TextClickTip.gameObject, true)
	self:NotifyUpdate()
	Event.Instance:Fire("SetVcScreenX", {
		isLeft = false,
		index = self.index
	})
end

function DlgFavorInfo:UpdateShowFavorLevelBtn(isFlag)
	self.btn_favor_level = self:GetChildGameObject("ImageInfo/ImageHeart/btn_favor_level")

	if not self.favorIndex then
		self.favorIndex = RoleMgr:GetFavorSectionIndex(self.infoRole.curFavorLevel)
	end

	local list = LevelManager:GetLevelAwardList()
	local isShow = false

	if list[self.favorIndex - 1] then
		SetActiveFunc(self.btn_favor_level, isFlag and self.infoRole.pb.favorLevelRecord < list[self.favorIndex - 1].ID)
	else
		SetActiveFunc(self.btn_favor_level, isFlag and isShow)
	end
end

function DlgFavorInfo:PlayFavorHeartAnimation(addExp)
	SetActiveFunc(self.Favor_Heart_Ani.gameObject, true)

	self.Favor_Heart_Ani.enabled = true

	self.Favor_Heart_Ani:Play("img_Favor")

	self.Favor_Heart_Ani_Text.text = _("Friendliness") .. " +" .. tostring(addExp)
end

function DlgFavorInfo:PlayFavorHeartAnimation2(addExp)
	SetActiveFunc(self.Favor_Heart_Ani2.gameObject, true)

	self.Favor_Heart_Ani2.enabled = true

	self.Favor_Heart_Ani2:Play("img_Favor")

	self.Favor_Heart_Ani_Text2.text = _("Friendliness") .. " +" .. tostring(addExp)
end

function DlgFavorInfo:EventAnim()
	SetActiveFunc(self.Favor_Heart_Ani.gameObject, false)
end

function DlgFavorInfo:EventAnim2()
	SetActiveFunc(self.Favor_Heart_Ani2.gameObject, false)
end

function DlgFavorInfo:OnClickFavorLevel()
	require("UI/Page/PageInteraction/DlgFavorLevelAward")

	local data = {
		title = _("Desc_Order_Reward"),
		role = self.infoRole
	}

	UIMgr.AddPanel(DlgFavorLevelAward(), data)
end

function DlgFavorInfo:UpdateFavorUnlock(favorIndex)
	UIUtil.SetImageSprite(self.SectImg, "UI/PageInteraction/AtlasPageInteraction/AtlasDlgFavor/BG_word_likelv_0" .. favorIndex, self)
	self:SetImageSprite(self.ImageFavorSection, self.listSectIcon[favorIndex])

	local name = self.listSectName[favorIndex]

	self.TextSectName.text = Lang(name)

	if favorIndex == 1 then
		self.TextFavorLevel.text = "1"
	else
		self.TextFavorLevel.text = GetConfigArgJson("FavorSection")[favorIndex - 1] + 1
	end

	if favorIndex > 1 then
		SetActiveFunc(self.BackBtn.gameObject, true)
	else
		SetActiveFunc(self.BackBtn.gameObject, false)
	end

	if favorIndex == #GetConfigArgJson("FavorSection") then
		SetActiveFunc(self.NextBtn.gameObject, false)
	else
		SetActiveFunc(self.NextBtn.gameObject, true)
	end

	self.unlockList = self:GetFavorUnlockList(favorIndex)

	self.FavorScrollTool:UpdateListData(self.unlockList)
end

function DlgFavorInfo:InitScrollViewFavorUnlock()
	local scrollArea = self:GetChildGameObject("FavorUnlock/UnlockBG/ScrollArea")
	local content = self:GetChildComponent("FavorUnlock/UnlockBG/ScrollArea/Content", "Transform")
	local count = 0

	self.FavorScrollTool = UIScrollTool()

	self.FavorScrollTool:InitList(scrollArea, content, count, self.PrefabCellFavorUnlock, CellFavorUnlock, self, false)

	function self.FavorScrollTool.ScrollView.beginDragCB()
		FingerGesturesUtil.Disable()
	end

	function self.FavorScrollTool.ScrollView.onSlippingComplete()
		FingerGesturesUtil.Enable()
	end
end

function DlgFavorInfo:UpdateCell(item, index)
	item:UpdateData(self.unlockList[index], self.infoRole.curFavorLevel, self.infoRole, self.curbehaviourData)
end

function DlgFavorInfo:OnClickBack()
	self.favorIndex = self.favorIndex - 1

	self:UpdateFavorUnlock(self.favorIndex)
	self:UpdateShowFavorLevelBtn(true)
end

function DlgFavorInfo:OnClickNext()
	self.favorIndex = self.favorIndex + 1

	self:UpdateFavorUnlock(self.favorIndex)
	self:UpdateShowFavorLevelBtn(true)
end

function DlgFavorInfo:FavorLevelUp()
	if self.FavorUnlock.activeSelf == true then
		self.FavorScrollTool:UpdateListDataKeepPos(self.unlockList)
	end
end

function DlgFavorInfo:PlayFxMax()
	self.FX_Max:Stop()
	self.FX_Max:Play()
end
