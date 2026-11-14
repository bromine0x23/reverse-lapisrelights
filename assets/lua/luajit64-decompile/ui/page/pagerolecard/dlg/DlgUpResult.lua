-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgUpResult.lua

DlgUpResult = class("DlgUpResult", UIPanel)

local eUpType = {
	CardLevel = 1,
	Equip = 4,
	CardPetal = 3,
	PicTask = 6,
	CardStar = 2,
	Story = 7,
	Favor = 5
}

function DlgUpResult:ctor()
	DlgUpResult.base.ctor(self, "UI/PanelRoleCard/DlgUpResult")

	self.callback = nil
end

function DlgUpResult:Close(tParam)
	DlgUpResult.base.Close(self, tParam)
end

function DlgUpResult:Purge()
	DlgUpResult.base.Purge(self)

	if self.loadedBank then
		SoundMgr.DelayUnloadBank(self.loadedBank, 3)
	end

	self:OnLeave()
end

function DlgUpResult:OnLeave()
	UnloadAllImageSprite(self)

	if self.EffStarPath and self.StarHandle then
		EffectMgr:UnLoadEffect(self.EffStarPath)

		self.EffStarPath = nil
		self.StarHandle = nil
	end

	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)

		self.Timer1 = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end

	if self.Timer3 then
		TimerMgr.RemoveTimer(self.Timer3)

		self.Timer3 = nil
	end
end

function DlgUpResult:OnRegisterEvent()
	self:AddClick(self.GoQuit, self.OnClickQuit, PATH_SFX_UI_CANCEL)
end

function DlgUpResult:OnUnRegisterEvent()
	self:RemoveClick(self.GoQuit, self.OnClickQuit)
end

function DlgUpResult:OnEnter(vParam)
	self.GoLevel = self:GetChildGameObject("Panel/Level")
	self.GoStar = self:GetChildGameObject("Panel/Star")
	self.GoPetal = self:GetChildGameObject("Panel/Petal")
	self.GoFavor = self:GetChildGameObject("Panel/Favor")
	self.GoStory = self:GetChildGameObject("Panel/Story")
	self.GoLevelTitle = self:GetChildGameObject("Title/Level")
	self.GoStarTitle = self:GetChildGameObject("Title/Star")
	self.GoPetalTitle = self:GetChildGameObject("Title/Petal")
	self.GoEquipmentTitle = self:GetChildGameObject("Title/Equipment")
	self.GoFavorTitle = self:GetChildGameObject("Title/Favor")
	self.AttrConGo = self:GetChildGameObject("Panel/Attr/MaskGroup/AttrCon")

	for i = 1, #ATTRIBUTE_MAP[1] do
		self["PreAttr" .. i] = self:GetChildComponent("Panel/Attr/MaskGroup/AttrCon/" .. i .. "/Txt1", "Text")
		self["CurAttr" .. i] = self:GetChildComponent("Panel/Attr/MaskGroup/AttrCon/" .. i .. "/Txt2", "Text")
	end

	self.GoQuit = self:GetChildGameObject("Bg")
	self.TimerClose = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
		TimerMgr.RemoveTimer(self.TimerClose)

		self.TimerClose = nil
	end, {})

	local index = vParam.index

	if vParam.infoRoleCard then
		self.infoRoleCard = vParam.infoRoleCard
	end

	if vParam.infoRole then
		self.infoRole = vParam.infoRole
	end

	if vParam.slotIdx then
		self.slotIdx = vParam.slotIdx
	end

	if vParam.callback then
		self.callback = vParam.callback
	end

	if vParam.preLevel then
		self.preLevel = vParam.preLevel
	end

	if vParam.curLevel then
		self.curLevel = vParam.curLevel
	end

	if vParam.addAttr then
		self.addAttr = vParam.addAttr
	end

	if vParam.stageId then
		self.stageId = vParam.stageId
	end

	self:DealWithLocalization(index)
	self:InitData(index)
end

function DlgUpResult:DealWithLocalization()
	local txt

	for i = 1, 4 do
		txt = self:GetChildComponent("Panel/Attr/MaskGroup/AttrCon/" .. i .. "/Text", "Text")

		if i == 1 then
			txt.text = _("Desc_Attribute_Hp")
		elseif i == 2 then
			txt.text = _("Desc_Attribute_Def")
		elseif i == 3 then
			txt.text = _("Desc_Attribute_AtkPhy")
		elseif i == 4 then
			txt.text = _("Desc_Attribute_AtkMgc")
		end
	end

	txt = self:GetChildComponent("Text", "Text")
	txt.text = Lang(12455)
end

function DlgUpResult:InitData(index)
	if index == eUpType.CardLevel then
		SoundMgr.PostEvent(PATH_SFX_UI_CARD_LEVELUP, self.UIRootObject)
		self:UpdateLevel()
	elseif index == eUpType.CardStar then
		self:UpdateStar()
	elseif index == eUpType.CardPetal then
		self:UpdatePetal()
	elseif index == eUpType.Equip then
		SoundMgr.PostEvent(PATH_SFX_UI_CARD_LEVELUP, self.UIRootObject)
		self:UpdateEquipmentUI()
	elseif index == eUpType.Favor then
		self:UpdateFavor()
	elseif index == eUpType.PicTask then
		self:UpdatePicTask()
	elseif index == eUpType.Story then
		self:UpdateStory()
	end
end

function DlgUpResult:UpdateLevel()
	GOUtil.SetActive(self.GoLevel, true)
	GOUtil.SetActive(self.GoLevelTitle, true)
	GOUtil.SetTransformLocalPosition(self.AttrConGo, 0, -100, 0)

	local txtPre = self:GetChildComponent("Panel/Level/TxtPre", "Text")
	local txtCur = self:GetChildComponent("Panel/Level/TxtCur", "Text")

	txtPre.text = string.format(_("Desc_Level"), self.infoRoleCard.preLevel)
	txtCur.text = string.format(_("Desc_Level"), self.infoRoleCard.curLevel)

	local role = RoleCardMgr:GetRole(self.infoRoleCard.id)

	if role then
		self.loadedBank = role.data.VocalBank

		SoundMgr.LoadBank(role.data.VocalBank, false, false)
		SoundMgr.PostEvent(role.data.VocalCharaUp, UIMgr.UICamera.gameObject)
	end

	self:UpdateAttr(eUpType.CardLevel)
end

function DlgUpResult:UpdateStar()
	GOUtil.SetActive(self.GoStar, true)
	GOUtil.SetActive(self.GoStarTitle, true)
	GOUtil.SetTransformLocalPosition(self.AttrConGo, 0, -100, 0)

	local maxStar = self.infoRoleCard.maxStarLevel
	local half = maxStar / 2
	local frame = self:GetChildGameObject("Panel/Star/Frame")
	local star1 = self:GetChildGameObject("Panel/Star/Star1")
	local star2 = self:GetChildGameObject("Panel/Star/Star2")

	GOUtil.SetActive(star1, half >= self.curStarLevel)
	GOUtil.SetActive(star2, half < self.curStarLevel)

	local curF, curS
	local star = TenaryOp(half >= self.curStarLevel, star1, star2)

	for i = 1, half do
		local f = GOUtil.FindChildGameObject(frame, "" .. i)
		local s = GOUtil.FindChildGameObject(star, "" .. i)

		f:SetActive(i >= self.curStarLevel)
		s:SetActive(i < self.curStarLevel)

		if half >= self.curStarLevel and self.curStarLevel == i or half < self.curStarLevel and self.curStarLevel - half == i then
			curF = f
			curS = s
		end
	end

	self.EffStarPath = "Fx/UI/FX_UI_006/FX_UI_006"
	self.Timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 0.3, function()
		SoundMgr.Play(PATH_SFX_UI_CARD_STARUP)

		self.StarHandle = EffectMgr:Alloc(self.EffStarPath, curF, true)
		self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, 0.3, function()
			GOUtil.SetActive(curF, false)
			GOUtil.SetActive(curS, true)
		end, {})
	end, {})

	self:UpdateAttr(eUpType.CardStar)
end

function DlgUpResult:UpdatePetal()
	GOUtil.SetActive(self.GoPetal, true)
	GOUtil.SetActive(self.GoPetalTitle, true)
	GOUtil.SetTransformLocalPosition(self.AttrConGo, 0, -100, 0)

	local cardRank = self.infoRoleCard.cardRank
	local maxPetal = self.infoRoleCard.maxPetal
	local prePetal = self:GetChildGameObject("Panel/Petal/1/State" .. cardRank)
	local curPetal = self:GetChildGameObject("Panel/Petal/2/State" .. cardRank)

	GOUtil.SetActive(prePetal, true)
	GOUtil.SetActive(curPetal, true)

	for i = 1, maxPetal do
		local imgPetal1 = GOUtil.FindChildComponent(prePetal, "" .. i, "Image")
		local imgPetal2 = GOUtil.FindChildComponent(curPetal, "" .. i, "Image")

		DealWithListRef(self, UIUtil.SetImageGray(imgPetal1, TenaryOp(i > self.prePetal, 1, 0)))
		DealWithListRef(self, UIUtil.SetImageGray(imgPetal2, TenaryOp(i > self.curPetal, 1, 0)))
	end

	self:UpdateAttr(eUpType.CardPetal)
end

function DlgUpResult:UpdateAttr(index)
	local preAttrs

	if index == eUpType.CardLevel then
		preAttrs = self.infoRoleCard:UpdateAtt(self.infoRoleCard.preLevel, self.infoRoleCard.curStarLevel, self.infoRoleCard.curPetal)
	elseif index == eUpType.CardStar then
		preAttrs = self.infoRoleCard:UpdateAtt(self.infoRoleCard.curLevel, self.infoRoleCard.curStarLevel - 1, self.infoRoleCard.curPetal)
	elseif index == eUpType.CardPetal then
		preAttrs = self.infoRoleCard:UpdateAtt(self.infoRoleCard.curLevel, self.infoRoleCard.curStarLevel, self.infoRoleCard.curPetal - 1)
	end

	local curAttrs = self.infoRoleCard:UpdateAtt(self.infoRoleCard.curLevel, self.infoRoleCard.curStarLevel, self.infoRoleCard.curPetal)

	for i = 1, #ATTRIBUTE_MAP[1] do
		self["PreAttr" .. i].text = math.floor(preAttrs:Get(i) + 0.5)
		self["CurAttr" .. i].text = math.floor(curAttrs:Get(i) + 0.5)
	end
end

function DlgUpResult:UpdateEquipmentUI()
	GOUtil.SetActive(self.GoEquipmentTitle, true)
	GOUtil.SetTransformLocalPosition(self.AttrConGo, 0, 0, 0)

	self.Timer3 = TimerMgr.AddTimer(eTimerType.RealTime, 0.3, function()
		SoundMgr.Play(PATH_SFX_UI_EQUIP_UPGRADE)
	end, {})

	self:UpdateEquipmentAttr()
end

function DlgUpResult:UpdateEquipmentAttr()
	self.infoSlot = self.infoRole:GetEquipSlot(self.slotIdx)
	self.equipId = self.infoRole:GetEquipId(self.slotIdx)

	local curQuality = self.infoSlot.quality
	local curGrade = self.infoSlot.grade
	local curLevel = self.infoSlot.level
	local listCurLv = EquipmentManager:GetProp(curLevel, self.infoRole.job, self.slotIdx, self.equipId)
	local listCurQua = EquipmentManager:GetQualityProp(self.infoRole.job, curQuality, curGrade, self.slotIdx)
	local lastQua, lastGra = EquipmentManager:GetLastQuality(curQuality, curGrade)
	local listLastQua = EquipmentManager:GetQualityProp(self.infoRole.job, lastQua, lastGra, self.slotIdx)

	for i = 1, #ATTRIBUTE_MAP[1] do
		self["PreAttr" .. i].text = math.floor(listCurLv[i] + listLastQua[i] + 0.5)
		self["CurAttr" .. i].text = math.floor(listCurLv[i] + listCurQua[i] + 0.5)
	end
end

function DlgUpResult:UpdateFavor()
	GOUtil.SetActive(self.GoFavor, true)
	GOUtil.SetActive(self.GoFavorTitle, true)
	GOUtil.SetTransformLocalPosition(self.AttrConGo, 0, -100, 0)

	local txtPre = self:GetChildComponent("Panel/Favor/TxtPre", "Text")
	local txtCur = self:GetChildComponent("Panel/Favor/TxtCur", "Text")
	local listName = GetConfigArgJson("FavorRankName")

	txtPre.text = Lang(listName[RoleMgr:GetFavorSectionIndex(self.preLevel)])
	txtCur.text = Lang(listName[RoleMgr:GetFavorSectionIndex(self.curLevel)])

	self:UpdateFavorAttr()
end

function DlgUpResult:UpdateFavorAttr()
	local skilllist = self.infoRole.data.FavorLevelSkill

	for i, v in ipairs(skilllist) do
		if v[1] == self.preLevel then
			local infoTalent = TalentManager:Get(v[2])

			self.preSkillAttr = infoTalent.data.Argus1[1] or {
				0,
				0,
				0,
				0
			}
		end

		if v[1] == self.curLevel then
			local infoTalent = TalentManager:Get(v[2])

			self.curSkillAttr = infoTalent.data.Argus1[1] or {
				0,
				0,
				0,
				0
			}
		end
	end

	for i = 1, #ATTRIBUTE_MAP[1] do
		if self.preSkillAttr then
			self["PreAttr" .. i].text = self.preSkillAttr[i]
		else
			self["PreAttr" .. i].text = 0
		end

		self["CurAttr" .. i].text = self.curSkillAttr[i]
	end
end

function DlgUpResult:UpdatePicTask()
	GOUtil.SetActive(self.GoFavorTitle, true)
	GOUtil.SetTransformLocalPosition(self.AttrConGo, 0, -100, 0)
	self:UpdatePicTaskAttr()
end

function DlgUpResult:UpdateStory()
	GOUtil.SetActive(self.GoStory, true)
	GOUtil.SetActive(self.GoFavorTitle, true)

	local Txt = self:GetChildComponent("Panel/Story/Txt", "Text")
	local stage = ChapterMgr:GetStage(self.stageId)

	Txt.text = string.format(_("Desc_FinishStory"), Lang(stage.data.Name))

	GOUtil.SetTransformLocalPosition(self.AttrConGo, 0, -100, 0)
	self:UpdatePicTaskAttr()
end

function DlgUpResult:UpdatePicTaskAttr()
	local infoTalent = TalentManager:Get(self.addAttr)
	local skillAttr = infoTalent.data.Argus1[1]
	local listRoleCard = RoleCardMgr:GetRoleHoldCard(self.infoRole.id)
	local cardIdx = 1

	for k, card in ipairs(listRoleCard) do
		if card.id == self.infoRole.pb.roleCardId then
			cardIdx = k

			break
		end
	end

	local infoRoleCard = listRoleCard[cardIdx]
	local att = self.infoRole:UpdateAttWithCard(infoRoleCard)

	for i = 1, #ATTRIBUTE_MAP[1] do
		if skillAttr and skillAttr[i] > 0 then
			self["PreAttr" .. i].text = math.floor(att:Get(i) + 0.5) - skillAttr[i]
			self["CurAttr" .. i].text = math.floor(att:Get(i) + 0.5)
		else
			SetActiveFunc(self["PreAttr" .. i].transform.parent.gameObject, false)
		end
	end
end

function DlgUpResult:OnClickQuit()
	if self.TimerClose then
		return
	end

	InstructionMgr:TriggerWait("EndCardUpResult")
	self:Close()

	if self.callback then
		self.callback()

		self.callback = nil
	end

	if InstructionMgr.NeedGoMainStage then
		InstructionMgr.NeedGoMainStage = false

		SceneMgr.LoadScene("MainStage")
	end
end

function DlgUpResult:OnBackAndroid()
	self:OnClickQuit()
end
