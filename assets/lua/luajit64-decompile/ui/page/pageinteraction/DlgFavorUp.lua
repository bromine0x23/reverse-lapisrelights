-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/DlgFavorUp.lua

require("UI/Item/CellItem")

local favorPose = require("luaData/FavorPose")

DlgFavorUp = class("DlgFavorUp", UIPanel)

function DlgFavorUp:ctor()
	self.UIPrefabPath = "UI/PageInteraction/DlgFavorUp"
end

function DlgFavorUp:Purge()
	DlgFavorUp.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	EventListenerMgr.RemoveAnimListener(self.GStyle2, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	TimerMgr.RemoveTimer(self.Timer1)
	TimerMgr.RemoveTimer(self.Timer2)
end

function DlgFavorUp:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function DlgFavorUp:OnEnter(data)
	self.infoRole = data.infoRole
	self.Button = self:GetChildGameObject("GClick")
	self.listSectIcon = GetConfigArgJson("FavorRankIcon")
	self.listSectName = GetConfigArgJson("FavorRankName")
	self.preLv = data.preFavorLevel
	self.curLv = data.curFavorLevel
	self.preFavorIndex = RoleMgr:GetFavorSectionIndex(data.preFavorLevel)
	self.curFavorIndex = RoleMgr:GetFavorSectionIndex(data.curFavorLevel)
	self.DlgSectionUp = self:GetChildGameObject("DlgSectionUp")
	self.DlgUp = self:GetChildGameObject("DlgUp")
	self.GStyle1 = self:GetChildGameObject("DlgUp/GStyle1")
	self.GStyle2 = self:GetChildGameObject("DlgUp/GStyle2")
	self.AnimRoot = GOUtil.GetComponent(self.GStyle2, "Animator")

	EventListenerMgr.AddAnimListener(self.GStyle2, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	SetActiveFunc(self.DlgSectionUp, false)
	SetActiveFunc(self.DlgUp, true)

	self.endDlg = false

	local TextSect1 = self:GetChildComponent("DlgSectionUp/Text", "Text")
	local TextSect2 = self:GetChildComponent("DlgSectionUp/Text1", "Text")

	TextSect1.text = Lang(self.listSectName[self.preFavorIndex])
	TextSect2.text = Lang(self.listSectName[self.curFavorIndex])
	TextSect1 = self:GetChildComponent("DlgSectionUp/pre/Text", "Text")
	TextSect2 = self:GetChildComponent("DlgSectionUp/cur/Text", "Text")
	TextSect1.text = Lang(self.listSectName[self.preFavorIndex])
	TextSect2.text = Lang(self.listSectName[self.curFavorIndex])
	self.cellCost = self:GetChildGameObject("DlgUp/GStyle2/Group/0")

	SetActiveFunc(self.cellCost, false)

	for i = 1, 8 do
		self["gCell" .. i] = self:GetChildGameObject("DlgUp/GStyle2/Group/" .. i)

		SetActiveFunc(self["gCell" .. i], false)

		self["gCellTextTitle" .. i] = self:GetChildComponent("DlgUp/GStyle2/Group/" .. i .. "/Text", "Text")
		self["gCellTextImg" .. i] = self:GetChildComponent("DlgUp/GStyle2/Group/" .. i, "Image")
		self["gCellText" .. i] = self:GetChildComponent("DlgUp/GStyle2/Group/" .. i .. "/Text1", "Text")
	end

	self.index = 1
	self.indexPos = 0
	self.playTextList = {}

	local listPersist = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_LIST_FAVOR_POP .. self.infoRole.id)
	local hasVocalUnlock = false
	local listVocal = self.infoRole.data.VocalList

	for i = 1, #listVocal do
		local needFavorLv = listVocal[i][4]

		if self.curLv == needFavorLv and i < 3 then
			hasVocalUnlock = true
			self.playTextList[self.index] = {}
			self.playTextList[self.index].title = _("Desc_Voice")
			self.playTextList[self.index].tips = string.format(_("Msg_Unlock"), Lang(listVocal[i][2]))
			self.playTextList[self.index].img = "UIDyAtlas/Favor/BG_likeroom_lv_03"
			self.index = self.index + 1
		end
	end

	local hasPoseUnlock = false
	local infoARList = self:GetFavorPose()

	for i = 1, #infoARList do
		local needFavorLv = infoARList[i].FavorLevel

		if needFavorLv <= self.curLv and needFavorLv > self.preLv then
			hasPoseUnlock = true
			self.playTextList[self.index] = {}
			self.playTextList[self.index].title = "AR"
			self.playTextList[self.index].tips = string.format(_("Msg_Unlock"), _("New_Pose"))
			self.playTextList[self.index].img = "UIDyAtlas/Favor/BG_likeroom_lv_03"
			self.index = self.index + 1

			break
		end
	end

	local hasEquipSlotUnlock = false
	local listEquipUnlockNeed = GetConfigArgJson("EquipmentUnlock")

	for i = 1, #listEquipUnlockNeed do
		if self.curLv == listEquipUnlockNeed[i] and i < 2 then
			hasEquipSlotUnlock = true
			self.playTextList[self.index] = {}
			self.playTextList[self.index].title = _("Desc_Slot")
			self.playTextList[self.index].tips = string.format(_("Msg_Unlock"), _("Desc_Slot") .. i)
			self.playTextList[self.index].img = "UIDyAtlas/Favor/BG_likeroom_lv_05"
			self.index = self.index + 1
		end
	end

	local hasCostUnlock = false
	local cost1 = LevelManager:GetFavorValue("CardCostRatio", self.preLv)
	local cost2 = LevelManager:GetFavorValue("CardCostRatio", self.curLv)

	if cost2 ~= cost1 then
		hasCostUnlock = true
	end

	local hasStageUnlock = false
	local infoChapter = ChapterMgr:GetCurChapter(ChapterType.role, self.infoRole.id)

	for i = 1, #infoChapter.listStage do
		local infoStage = infoChapter.listStage[i]
		local favorLevel = infoStage.data.FavorLevel

		if favorLevel <= self.curLv and favorLevel > self.preLv then
			hasStageUnlock = true
			self.playTextList[self.index] = {}
			self.playTextList[self.index].title = _("FavorUp_Story")
			self.playTextList[self.index].tips = string.format(_("Msg_Unlock"), infoStage:GetName())
			self.playTextList[self.index].img = "UIDyAtlas/Favor/BG_likeroom_lv_05"
			self.index = self.index + 1

			local data = {}

			table.insert(data, 6)
			table.insert(data, self.infoRole.id)
			table.insert(data, infoStage.id)

			local str = PersistentStoreUtil.WrapList(data)

			PersistentStoreUtil.AddList(PersistentStoreUtil.KEY_LIST_FAVOR_POP .. self.infoRole.id, str)
		end
	end

	local TopicData = require("luaData/TopicData")
	local favorIndex = RoleMgr:GetFavorSectionIndex(self.infoRole.curFavorLevel)
	local listSect = GetConfigArgJson("FavorSection")
	local minLevel = 0
	local maxLevel = 0

	minLevel = favorIndex < 2 and 2 or listSect[favorIndex - 1]
	maxLevel = favorIndex > #listSect and 50 or listSect[favorIndex]

	local favorTopicList = TopicManager:GetAllTopicList(self.infoRole.id)
	local haveTopicUnlock = false

	for i = 1, #favorTopicList do
		local needFavorLv = favorTopicList[i].data.FavorUnlockLevel

		if needFavorLv ~= 0 and needFavorLv <= maxLevel and needFavorLv > self.infoRole.preFavorLevel and needFavorLv <= self.infoRole.curFavorLevel then
			haveTopicUnlock = true
			self.playTextList[self.index] = {}
			self.playTextList[self.index].title = Lang(5000060)
			self.playTextList[self.index].tips = string.format(_("Msg_Unlock"), Lang(TopicData[favorTopicList[i].data.ID].Name))
			self.playTextList[self.index].img = "UIDyAtlas/Favor/BG_likeroom_lv_04"
			self.index = self.index + 1
		end
	end

	local PhoneCallData = require("luaData/CallData")
	local havePhoneCallUnlock = false
	local favorPhoneCallList = PhoneCallManager:GetAllPhoneCallList(self.infoRole.id)

	for i = 1, #favorPhoneCallList do
		local needFavorLv = favorPhoneCallList[i].data.FavorUnlockLevel

		if needFavorLv ~= 0 and needFavorLv <= maxLevel and needFavorLv > self.infoRole.preFavorLevel and needFavorLv <= self.infoRole.curFavorLevel then
			havePhoneCallUnlock = true
			self.playTextList[self.index] = {}
			self.playTextList[self.index].title = Lang(5000061)
			self.playTextList[self.index].tips = string.format(_("Msg_Unlock"), Lang(PhoneCallData[favorPhoneCallList[i].data.ID].Name))
			self.playTextList[self.index].img = "UIDyAtlas/Favor/BG_likeroom_lv_04"
			self.index = self.index + 1
		end
	end

	SoundMgr.Play(PATH_SFX_UI_FAVOR_LEVELUP)

	if hasCostUnlock then
		SetActiveFunc(self.cellCost, true)

		local Text = self:GetChildComponent("DlgUp/GStyle2/Group/0/Text1", "Text")

		Text.text = cost1 .. "%"
		Text = self:GetChildComponent("DlgUp/GStyle2/Group/0/Text2", "Text")
		Text.text = cost2 .. "%"
		Text = self:GetChildComponent("DlgUp/GStyle2/Group/0/Text", "Text")
		Text.text = _("Filter_Card_3")
		self.index = self.index + 1
	end

	SetActiveFunc(self.GStyle1, true)
	SetActiveFunc(self.GStyle2, false)

	if hasVocalUnlock or hasStageUnlock or hasSkillUnlock or hasPoseUnlock or hasEquipSlotUnlock or hasCostUnlock or havePhoneCallUnlock or haveTopicUnlock then
		SetActiveFunc(self.GStyle2, true)

		FavorMgr.ShowFavorUnlock = true

		self:PlayEventAnim()
	else
		SetActiveFunc(self.GStyle1, true)
	end

	self:ClosePanel()
end

function DlgFavorUp:PlayEventAnim()
	for i = 1, #self.playTextList do
		if i > self.indexPos and i <= 8 + self.indexPos then
			SetActiveFunc(self["gCell" .. i - self.indexPos], true)

			self["gCellTextTitle" .. i - self.indexPos].text = self.playTextList[i].title
			self["gCellText" .. i - self.indexPos].text = self.playTextList[i].tips

			UIUtil.SetImageSprite(self["gCellTextImg" .. i - self.indexPos], self.playTextList[i].img, self)
		end
	end
end

function DlgFavorUp:EventAnim()
	self.indexPos = self.indexPos + 8

	if self.indexPos < #self.playTextList then
		for i = 1, 8 do
			SetActiveFunc(self["gCell" .. i], false)
		end

		SetActiveFunc(self.GStyle2, false)
		SetActiveFunc(self.GStyle2, true)
		self:PlayEventAnim()
	end
end

function DlgFavorUp:OnRegisterEvent()
	return
end

function DlgFavorUp:OnUnRegisterEvent()
	return
end

function DlgFavorUp:ClosePanel()
	local time = TenaryOp(self.index * 0.5 > 2, self.index * 0.5, 2)

	self.Timer1 = TimerMgr.AddTimer(eTimerType.RealTime, time, function()
		if self.preFavorIndex == self.curFavorIndex then
			self:Close()
		else
			SetActiveFunc(self.GStyle2, false)
			SetActiveFunc(self.DlgSectionUp, true)

			self.Timer3 = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
				SoundMgr.Play(PATH_SFX_UI_FAVOR_SECTIONUP)
			end, {})
		end
	end, {})
	self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, time + 2, function()
		Event.Instance:Fire("BackToInteraction")
		self:Close()
	end, {})
end

function DlgFavorUp:GetFavorPose()
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
