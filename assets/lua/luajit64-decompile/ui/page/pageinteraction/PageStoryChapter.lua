-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/PageStoryChapter.lua

require("UI/Page/PageInteraction/CellStoryChapter")
require("UI/Page/PageInteraction/CellVoice")
require("UI/Page/PagePass/PageStage")

local downdata = require("luaData/DownloadConfig")

PageStoryChapter = class("PageStoryChapter", UIPanel)

function PageStoryChapter:ctor()
	self.UIPrefabPath = "UI/PageInteraction/PanelFavorStory"
end

function PageStoryChapter:Purge()
	PageStoryChapter.base.Purge(self)

	if self.UIScrollToolStory then
		self.UIScrollToolStory:Purge()
	end

	if self.UIScrollToolVoice then
		self.UIScrollToolVoice:Purge()
	end

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	if self.infoRole then
		InfoSoundEventMgr:UnloadBank(self.infoRole.data.VocalBank)
	end

	ResourceMgr.Unload(self.PrefabCell)
	ResourceMgr.Unload(self.PrefabCellVoice)
	ResourceMgr.Unload(self.PrefabCellItem)
end

function PageStoryChapter:PreLoad()
	self:LoadResAsync("UI/PageInteraction/CellStoryChapter", "PrefabCell")
	self:LoadResAsync("UI/PageInteraction/CellFaverAward", "PrefabCellVoice")
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function PageStoryChapter:OnEnter()
	self.Button1 = self:GetChildGameObject("Panel/Button1")
	self.Button2 = self:GetChildGameObject("Panel/Button2")
	self.Button3 = self:GetChildGameObject("Panel/Button3")
	self.GoClick1 = self:GetChildGameObject("Panel/Button1/Image")
	self.GoClick2 = self:GetChildGameObject("Panel/Button2/Image")
	self.GoClick3 = self:GetChildGameObject("Panel/Button3/Image")
	self.PanelDlg = self:GetChildGameObject("Panel/PanelDlg")
	self.TextDlg = self:GetChildComponent("Panel/PanelDlg/Text", "Text")

	SetActiveFunc(self.PanelDlg, false)

	self.tex_fight = self:GetChildComponent("Panel/Image/tex_fight", "Text")
	self.tex_name = self:GetChildComponent("Panel/Image/img_name/tex_name", "Text")
	self.img_job = self:GetChildComponent("Panel/Image/img_name/img_job", "Image")
	self.imgRoleInfo = self:GetChildComponent("Panel/ScrollAreaInfo/Image", "Image")
	Text = self:GetChildComponent("Panel/Button1/Text", "Text")
	Text.text = _("PageChapter_title")
	Text = self:GetChildComponent("Panel/Button1/Image/Text", "Text")
	Text.text = _("PageChapter_title")
	Text = self:GetChildComponent("Panel/Button2/Text", "Text")
	Text.text = _("Desc_Voice")
	Text = self:GetChildComponent("Panel/Button2/Image/Text", "Text")
	Text.text = _("Desc_Voice")
	Text = self:GetChildComponent("Panel/Button3/Text", "Text")
	Text.text = _("Desc_Mean")
	Text = self:GetChildComponent("Panel/Button3/Image/Text", "Text")
	Text.text = _("Desc_Mean")
	self.ScrollAreaStory = self:GetChildGameObject("Panel/ScrollAreaStory")
	self.ScrollAreaVoice = self:GetChildGameObject("Panel/ScrollAreaVoice")
	self.ScrollAreaInfo = self:GetChildGameObject("Panel/ScrollAreaInfo")

	self:Init(self.show, self.data)
end

function PageStoryChapter:Init(show, data)
	if self.UIRootObject and not IsNil(self.UIRootObject) then
		SetActiveFunc(self.UIRootObject.gameObject, show)
	end

	self.show = show

	if show then
		self.data = data
		self.infoRole = data.infoRole
		self.tabIndex = data.tabIndex

		if self.UIRootObject and not IsNil(self.UIRootObject) then
			self:InitData()

			if not self.isFirst then
				self.isFirst = true

				self:InitScrollViewStory()
				self:InitScrollViewVoice()
			end

			if self.tabIndex == 3 then
				self:OnClickedClick3()
			elseif self.tabIndex == 2 then
				self:OnClickedClick2()
			elseif self.tabIndex == 1 then
				self:OnClickedClick1()
			end
		end

		self:UpdateDot()
	else
		if self.data then
			Event.Instance:Fire("SetVcScreenX", {
				isLeft = false,
				index = self.data.index
			})
		end

		self:CancelDot()
	end
end

function PageStoryChapter:InitData()
	local actor = SceneMainStage.Instance.curActor

	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
	Event.Instance:Fire("SetVcScreenX", {
		isLeft = true,
		index = self.data.index
	})

	self.tex_name.text = self.infoRole:GetName()
	self.tex_fight.text = "CV." .. self.infoRole:GetCVName()
	self.infoChapter = ChapterMgr:GetCurChapter(ChapterType.role, self.infoRole.id)

	SetImageSprite(self.img_job, "UIDyAtlas/RoleJob/ICO_" .. self.infoRole.data.Job .. "_01_S", self)

	if self.data.openVoical then
		self:OnClickedClick2()
	end

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
		"Desc_ChangeBackAvatar",
		"",
		"Desc_birthdayGift",
		"Desc_birthdaySend",
		"Desc_helloAfternoon",
		"Desc_helloZeroDay",
		"Desc_birthdayPlayerSend"
	}

	for i = 1, #listGroupName do
		if i == eInterctAnimType.readySendGiftToPlayer or i == eInterctAnimType.touchHead or i == eInterctAnimType.changeHead or i == eInterctAnimType.changeBack then
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
					if not string.isNullOrEmpty(data.name) then
						table.insert(self.listVoice, data)
					else
						print("ボイス ID: " .. behaviourData.VoiceName .. "存在しません！！！")
					end
				end
			end
		end
	end

	table.sort(self.listVoice, function(x, y)
		if x.behaviourData.Level == y.behaviourData.Level then
			return tonumber(x.behaviourData.VoiceName) < tonumber(y.behaviourData.VoiceName)
		else
			return x.behaviourData.Level < y.behaviourData.Level
		end
	end)
end

function PageStoryChapter:OnRegisterEvent()
	self:AddClick(self.Button1, self.OnClickedClick1)
	self:AddClick(self.Button2, self.OnClickedClick2)
	self:AddClick(self.Button3, self.OnClickedClick3)
	Event.Instance:Add(EventEnum.PlayVoice, self.PlayVoice, self)
end

function PageStoryChapter:OnUnRegisterEvent()
	self:RemoveClick(self.Button1, self.OnClickedClick1)
	self:RemoveClick(self.Button2, self.OnClickedClick2)
	self:RemoveClick(self.Button3, self.OnClickedClick3)
	Event.Instance:Remove("ChpterCiickDownReturn", self.Dlgretun, self)
	Event.Instance:Remove(EventEnum.PlayVoice, self.PlayVoice, self)
end

function PageStoryChapter:OnClickedClick1()
	SetActiveFunc(self.ScrollAreaStory, true)
	SetActiveFunc(self.ScrollAreaVoice, false)
	SetActiveFunc(self.ScrollAreaInfo, false)
	SetActiveFunc(self.GoClick1, false)
	SetActiveFunc(self.GoClick2, true)
	SetActiveFunc(self.GoClick3, true)

	self.tabIndex = 1

	self.UIScrollToolStory:UpdateListData(self.infoChapter.listStage)
	self:CancelDot()

	self.needCancelStoryDot = true
end

function PageStoryChapter:OnClickedClick2()
	SetActiveFunc(self.ScrollAreaStory, false)
	SetActiveFunc(self.ScrollAreaVoice, true)
	SetActiveFunc(self.ScrollAreaInfo, false)
	SetActiveFunc(self.GoClick1, true)
	SetActiveFunc(self.GoClick2, false)
	SetActiveFunc(self.GoClick3, true)

	self.tabIndex = 2

	self.UIScrollToolVoice:UpdateListData(self.listVoice)
	self:CancelDot()

	self.needCancelVoiceDot = true
end

function PageStoryChapter:OnClickedClick3()
	SetActiveFunc(self.ScrollAreaStory, false)
	SetActiveFunc(self.ScrollAreaVoice, false)
	SetActiveFunc(self.ScrollAreaInfo, true)
	SetActiveFunc(self.GoClick1, true)
	SetActiveFunc(self.GoClick2, true)
	SetActiveFunc(self.GoClick3, false)

	self.tabIndex = 3

	UIUtil.SetImageSprite(self.imgRoleInfo, self.infoRole.data.InfoIcon, self)
	self:CancelDot()
end

function PageStoryChapter:CancelDot()
	if self.needCancelStoryDot then
		self.needCancelStoryDot = false

		RoleRDL.InteractRDL.SubInteractStory(self.infoRole)
	end

	if self.needCancelVoiceDot then
		self.needCancelVoiceDot = false

		RoleRDL.InteractRDL.SubInteractVoice(self.infoRole)
	end
end

function PageStoryChapter:OnBack()
	Event.Instance:Fire("SetVcScreenX", {
		isLeft = false,
		index = self.data.index
	})
	UIMgr.PopPanel()
end

function PageStoryChapter:InitScrollViewStory()
	local scrollArea = self:GetChildGameObject("Panel/ScrollAreaStory")
	local content = self:GetChildComponent("Panel/ScrollAreaStory/Content", "Transform")
	local count = #self.infoChapter.listStage

	self.UIScrollToolStory = UIScrollTool()

	self.UIScrollToolStory:InitList(scrollArea, content, count, self.PrefabCell, CellStoryChapter, self, false)

	function self.UIScrollToolStory.ScrollView.beginDragCB()
		FingerGesturesUtil.Disable()
	end

	function self.UIScrollToolStory.ScrollView.onSlippingComplete()
		FingerGesturesUtil.Enable()
	end
end

function PageStoryChapter:UpdateCell(item, index)
	local info = self.infoChapter.listStage[index]

	item:UpdateData(info, self.infoRole)
end

function PageStoryChapter:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell, "mute")

	local cellItem = CellItem(self.PrefabCellItem, item.GoItem, self)

	cellItem:Create()
	item:SetCellItem(cellItem)
end

function PageStoryChapter:OnClickedCell(data)
	local go = data.pointerPress

	if self.tabIndex == 1 then
		local info = self.UIScrollToolStory.ItemRoot2ItemDict:GetValue(go)
		local index = info.Item.Index

		self.infoStage = self.infoChapter.listStage[index]

		local favorLevel = self.infoStage.data.FavorLevel

		if favorLevel > self.infoRole.curFavorLevel then
			-- block empty
		else
			local isEnter = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_FAVOR_STORY_ENTER .. self.infoStage.id, true)

			InfoBGMEventMgr:Clear()
			PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_FAVOR_STORY_ENTER .. self.infoStage.id, true)
			PageStage.RequestStartStage(self.infoStage, "MainStage")
		end
	else
		local info = self.UIScrollToolVoice.ItemRoot2ItemDict:GetValue(go)
		local index = info.Item.Index
		local voiceData = self.listVoice[index]
		local favorLevel = voiceData.behaviourData.Level
		local behaviourData = voiceData.behaviourData

		if self.curbehaviourData ~= nil and self.curbehaviourData == behaviourData then
			return
		end

		RoleRDL.InteractRDL.SubInteractOneVoice(self.infoRole, behaviourData.VoiceName)
		info.Item:UpdateDot()

		if favorLevel > self.infoRole.curFavorLevel then
			SoundMgr.Play(PATH_SFX_UI_PROMPT)
		else
			SoundMgr.Play(PATH_SFX_UI_CLICK)

			if self.UIScrollToolVoice.ItemRoot2ItemDict then
				for _, v in self.UIScrollToolVoice.ItemRoot2ItemDict:Enumerator() do
					if not IsNil(v.Item.Animator) and v.Item.Animator.isActiveAndEnabled then
						v.Item.Animator:Play("Empty")
					end
				end
			end

			self.curbehaviourData = behaviourData

			info.Item.Animator:Play("Voice_Loop")

			local actor = SceneMainStage.Instance.curActor

			PreviewAnim(self.listVoice[index].behaviourData, actor, actor.InteractSettingFile, nil, nil, function()
				if self.listVoice[index].behaviourData == self.curbehaviourData then
					if self.UIScrollToolVoice.ItemRoot2ItemDict then
						for _, v in self.UIScrollToolVoice.ItemRoot2ItemDict:Enumerator() do
							if v.Item.voiceData and v.Item.voiceData.behaviourData == self.listVoice[index].behaviourData and not IsNil(v.Item.Animator) then
								v.Item.Animator:Play("Empty")
							end
						end
					end

					self.curbehaviourData = nil
				end
			end)
		end
	end
end

function PageStoryChapter:ShowSubTitle(str)
	SetActiveFunc(self.PanelDlg, true)

	self.TextDlg.text = str

	local function cb()
		SetActiveFunc(self.PanelDlg, false)
	end

	if self.timeId ~= nil then
		TimerMgr.RemoveTimer(self.timeId)
	end

	self.timeId = TimerMgr.AddTimer(eTimerType.RealTime, 4, cb, self)
end

function PageStoryChapter:InitScrollViewVoice()
	local scrollArea = self:GetChildGameObject("Panel/ScrollAreaVoice")
	local content = self:GetChildComponent("Panel/ScrollAreaVoice/Content", "Transform")
	local count = #self.listVoice

	local function UpdateCell(item, index)
		local voiceData = self.listVoice[index]

		item:UpdateData(voiceData, self.infoRole, self.curbehaviourData)
	end

	local function AddCellClick(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	self.UIScrollToolVoice = UIScrollTool()

	self.UIScrollToolVoice:InitList(scrollArea, content, count, self.PrefabCellVoice, CellVoice, self, false, AddCellClick, UpdateCell)

	function self.UIScrollToolVoice.ScrollView.beginDragCB()
		FingerGesturesUtil.Disable()
	end

	function self.UIScrollToolVoice.ScrollView.onSlippingComplete()
		FingerGesturesUtil.Enable()
	end
end

function PageStoryChapter:PlayVoice(str, actor)
	if self.infoRole then
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
end

function PageStoryChapter:UpdateDot()
	RedDotSystemMgr.SetUIRedDot(self.Button1, "Role/" .. self.infoRole.id .. "/Interact/Information/Story")
	RedDotSystemMgr.SetUIRedDot(self.Button2, "Role/" .. self.infoRole.id .. "/Interact/Information/Voice")
end
