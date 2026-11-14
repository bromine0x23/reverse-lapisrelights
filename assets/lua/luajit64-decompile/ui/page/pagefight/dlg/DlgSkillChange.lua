-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgSkillChange.lua

local remainBtnImgPath = {
	"UI/PageFight/SkillChange/BTN_timelimit_01",
	"UI/PageFight/SkillChange/BTN_timelimit_02"
}
local titalNormalPath = "UI/PageFight/SkillChange/BG_tower_frame_01"
local titalHardPath = "UI/PageFight/SkillChange/BG_tower_frame_01b"
local bookNormalPath = "UI/PageFight/SkillChange/BG_tower_frame_107"
local bookHardPath = "UI/PageFight/SkillChange/BG_tower_frame_107b"

require("UI.Page.PageFight.Cells.UISkillCard")

DlgSkillChange = class("DlgSkillChange", UIPanel_sync)

local const_wait_time = 20
local maxCount = 3

function DlgSkillChange:ctor()
	DlgSkillChange.base.ctor(self, "UI/PageFight/Dlg/DlgUISkillChange")

	self.cards = {}

	for i = 1, 5 do
		local card = UISkillCard(self)

		self:AddChildPanel(card)
		table.insert(self.cards, card)
	end

	self.CellAutoBtn = CellAutoBtn()

	self:AddChildPanel(self.CellAutoBtn)
end

function DlgSkillChange:Purge()
	self:StartRemainTime(false)
	DlgSkillChange.base.Purge(self)
end

function DlgSkillChange:OnEnter(vParam)
	self:Show(false)
	self:DealWithLocalization()

	self.countText = self:GetChildComponent("count/count_txt", "Text")
	self.okBtnImg = self:GetChildComponent("btn_start", "Image")
	self.btn = self:GetChildGameObject("btn_start")
	self.light = self:GetChildGameObject("light")
	self.btnMask = self:GetChildGameObject("btn_start/mask")
	self.img_fillTime = self:GetChildComponent("btn_remain/img_fillTime", "Image")
	self.img_fillTime.fillAmount = 0
	self.txt_time = self:GetChildComponent("btn_remain/txt_time", "Text")
	self.btn_remain = self:GetChildGameObject("btn_remain")
	self.img_remain = self:GetChildComponent("btn_remain", "Image")
	self.stageBG = self:GetChildComponent("StageName", "Image")
	self.stageImage = self:GetChildComponent("StageName/Image", "Image")
	self.stageName = self:GetChildComponent("StageName/Text", "Text")
	self.needRemain = true

	if GP.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		self.needRemain = false
	end

	self:StartRemainTime(self.needRemain)

	self.selectCount = 0
	self.timer = const_wait_time
	self.lastTime = -1

	for i, card in ipairs(self.cards) do
		local cardObj = self:GetChildGameObject("cards/con" .. i)

		GOUtil.AttachUIGameObject(card.UIRootObject, cardObj)
	end

	self.CellAutoBtn:SetParent(self:GetChildGameObject("obj_autoBtnRoot"))
end

function DlgSkillChange:DealWithLocalization()
	local TextAuto

	TextAuto = self:GetChildComponent("bg/txt1/", "Text")
	TextAuto.text = Lang(5000043)
	TextAuto = self:GetChildComponent("bg/txt2/", "Text")
	TextAuto.text = Lang(5000044)
	TextAuto = self:GetChildComponent("btn_start/txt/", "Text")
	TextAuto.text = Lang(5000045)
end

function DlgSkillChange:OnRegisterEvent()
	self:AddClick(self.btn, self.OnOkBtnClick)
	self:AddClick(self.btn_remain, self.OnRemainBtnClick)
	Event.Instance:Add("SetGuideBtn", self.OnSetGuide, self)
end

function DlgSkillChange:OnUnRegisterEvent()
	self:RemoveClick(self.btn, self.OnOkBtnClick)
	self:RemoveClick(self.btn_remain, self.OnRemainBtnClick)
	Event.Instance:Remove("SetGuideBtn", self.OnSetGuide, self)
end

function DlgSkillChange:Open(callback)
	self.callback = callback

	if self:AutoSelect() == true then
		return
	end

	local infoStage = ChapterMgr:GetStage(GP.StageId)

	if infoStage.data.ChapterType == ChapterFromType.towerhard or infoStage.data.ChapterType == ChapterFromType.tower then
		GOUtil.SetActive(self.stageBG, true)

		local infoChapter = ChapterMgr:GetChapter(infoStage.data.ChapterID)

		self.stageName.text = Lang(infoChapter.data.Name) .. "." .. Lang(infoStage.data.Name)

		UIUtil.SetImageSprite(self.stageBG, TenaryOp(infoStage.data.ChapterType == ChapterFromType.tower, titalNormalPath, titalHardPath), self)
		UIUtil.SetImageSprite(self.stageImage, TenaryOp(infoStage.data.ChapterType == ChapterFromType.tower, bookNormalPath, bookHardPath), self)
	else
		GOUtil.SetActive(self.stageBG, false)
	end

	self:Show(true)
	BattleConfig.TimeScaleActive(false, BattleConfig.Speed.One)
	BattleConfig.PostSoundEvent(PATH_BATTLE_MUSIC_READY, UIMgr.UICamera.gameObject)

	local delay = 0

	BattleConfig.Delay(0.4, function()
		for i, unit in ipairs(SceneMgr.GetCurrentScene().GP.Team.PlayerTeam) do
			for skillIdx, skill in ipairs(unit.OwnSkills) do
				if skill.BattleSkillType == EnumFight.SkillType.Active then
					BattleConfig.Delay(delay, function()
						self.cards[i]:Init(skill)
					end)

					delay = delay + 0.05
				end
			end
		end
	end)

	if InstructionMgr.showAutoBtn == false then
		self:StartRemainTime(false)
		self:EnableBtnRemain(false)
	else
		self:EnableBtnRemain(true)
		self:StartRemainTime(self.needRemain)
	end
end

function DlgSkillChange:EnableBtnRemain(_val)
	GOUtil.SetActive(self.btn_remain, _val)
end

function DlgSkillChange:OnSetGuide(_val)
	if IsNil(self.UIRootObject) then
		return
	end

	if GOUtil.IsActiveSelf(self.UIRootObject.gameObject) == false then
		return
	end

	if InstructionMgr.showAutoBtn == false then
		self:StartRemainTime(false)
		self:EnableBtnRemain(false)
	else
		self:EnableBtnRemain(true)
		self:StartRemainTime(self.needRemain)
	end
end

function DlgSkillChange:UpdateSelect()
	self.selectCount = 0

	for _, card in ipairs(self.cards) do
		if card.select then
			self.selectCount = self.selectCount + 1
		end
	end

	self.countText.text = "<color=#fedf3d>" .. self.selectCount .. "</color>/3"

	if self:IsMaxCount() then
		self:OkBtnEnable(true)
		InstructionMgr:TriggerWait("SelectBattleSkillCard")
	else
		self:OkBtnEnable(false)
	end
end

function DlgSkillChange:IsMaxCount()
	return self.selectCount == maxCount
end

function DlgSkillChange:OkBtnEnable(value)
	if value then
		self.okBtnImg.raycastTarget = true

		self.btnMask:SetActive(false)
		self.light:SetActive(true)
	else
		self.okBtnImg.raycastTarget = false

		self.btnMask:SetActive(true)
		self.light:SetActive(false)
	end
end

function DlgSkillChange:AutoSelect()
	if RoleCardMgr:GetChooseStartCardState() == "0" then
		return false
	end

	local ids = {}

	for i, unit in ipairs(SceneMgr.GetCurrentScene().GP.Team.PlayerTeam) do
		for skillIdx, skill in ipairs(unit.OwnSkills) do
			if skill.BattleSkillType == EnumFight.SkillType.Active then
				table.insert(ids, skill.Id)

				if #ids == 3 then
					UIMgr.RemoveUpdatePanel(self)
					SceneMgr.GetCurrentScene().GP:SetFightStartTime(os.time())

					if self.callback then
						self.callback()
					end

					Event.Instance:Fire("ReqSkillChange", ids)

					return true
				end
			end
		end
	end

	return false
end

function DlgSkillChange:OnOkBtnClick()
	UIMgr.RemoveUpdatePanel(self)
	self:Show(false)
	BattleConfig.TimeScaleActive(true)

	local ids = {}

	for _, card in ipairs(self.cards) do
		if card.select and card.unitSkill then
			table.insert(ids, card.unitSkill.Id)
		end
	end

	SceneMgr.GetCurrentScene().GP:SetFightStartTime(os.time())

	if self.callback then
		self.callback()
	end

	Event.Instance:Fire("ReqSkillChange", ids)
end

function DlgSkillChange:SetBtnRemainImg(isRemainMode)
	local idx = TenaryOp(isRemainMode == false, 1, 2)
	local iconPath = remainBtnImgPath[idx]

	if iconPath and GP then
		GP.SpriteUtil:SetSprite(self.img_remain, iconPath)
	end
end

function DlgSkillChange:OnRemainBtnClick()
	self.needRemain = not self.needRemain

	local str = ""

	if self.needRemain == true then
		str = _("Msg_SkillSelectCountOpen")
	else
		str = _("Msg_SkillSelectCountPsuse")
	end

	UIMgr.ShowMsg(str)
	self:StartRemainTime(self.needRemain)
end

function DlgSkillChange:OnUpdate()
	self.timer = self.timer - Time.deltaTime

	if self.lastTime ~= math.ceil(self.timer) then
		self.lastTime = math.ceil(self.timer)
		self.txt_time.text = tostring(self.lastTime)
	end

	self.img_fillTime.fillAmount = self.timer / const_wait_time

	if self.lastTime > 0 then
		return
	end

	local _selectCount = 0

	for _, card in ipairs(self.cards) do
		if card.select == true then
			_selectCount = _selectCount + 1
		end
	end

	for _, card in ipairs(self.cards) do
		if _selectCount >= maxCount then
			break
		end

		if card.select == false then
			card.select = true
			_selectCount = _selectCount + 1
		end
	end

	UIMgr.HideSkillTip()
	self:OnOkBtnClick()
end

function DlgSkillChange:StartRemainTime(val)
	self:SetBtnRemainImg(val)

	if val == true then
		UIMgr.SetUpdatePanel(self)
	else
		UIMgr.RemoveUpdatePanel(self)
	end
end
