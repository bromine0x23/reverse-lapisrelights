-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUICutInSession.lua

local imgCountTable = {}

imgCountTable[1] = "UIDyAtlas/Battle/ui_hd_word_session_1"
imgCountTable[2] = "UIDyAtlas/Battle/ui_hd_word_session_2"
imgCountTable[3] = "UIDyAtlas/Battle/ui_hd_word_session_3"
imgCountTable[4] = "UIDyAtlas/Battle/ui_hd_word_session_4"

local imgTypeSquare = {}

imgTypeSquare[1] = "UIDyAtlas/Battle/ui_hd_back_report_01b"
imgTypeSquare[2] = "UIDyAtlas/Battle/ui_hd_back_report_02b"
imgTypeSquare[3] = "UIDyAtlas/Battle/ui_hd_back_report_03b"

local imgTypeGround = {}

imgTypeGround[1] = "UIDyAtlas/Battle/ui_hd_back_report_01"
imgTypeGround[2] = "UIDyAtlas/Battle/ui_hd_back_report_02"
imgTypeGround[3] = "UIDyAtlas/Battle/ui_hd_back_report_03"

local imgTypeArrowBk = {}

imgTypeArrowBk[1] = "UIDyAtlas/Battle/ui_hd_word_sing5"
imgTypeArrowBk[2] = "UIDyAtlas/Battle/ui_hd_word_charge5"
imgTypeArrowBk[3] = "UIDyAtlas/Battle/ui_hd_word_dance5"

local imgSessionCountPic = {}

imgSessionCountPic[1] = "UIDyAtlas/Battle/ui_hd_word_cn_small"
imgSessionCountPic[2] = "UIDyAtlas/Battle/ui_hd_word_cn_middle"
imgSessionCountPic[3] = "UIDyAtlas/Battle/ui_hd_word_cn_big"
imgSessionCountPic[4] = "UIDyAtlas/Battle/ui_hd_word_cn_super"
DlgUICutInSession = class("DlgUICutInSession", UIPanel_sync)

function DlgUICutInSession:ctor()
	DlgUICutInSession.base.ctor(self, "UI/PageFight/Dlg/DlgUICutInSession")
end

function DlgUICutInSession:Cache()
	DlgUICutInSession.base.Cache(self)
end

function DlgUICutInSession:Close(tParam)
	DlgUICutInSession.base.Close(self, tParam)
end

function DlgUICutInSession:Purge()
	DlgUICutInSession.base.Purge(self)

	self.img_typeGround = nil
	self.img_square = nil
	self.img_countTxt = nil
	self.img_showName = nil
	self.trans_spineRoot = nil
	self.txt_forcepVal = nil
	self.img_sessionCountWord = nil
	self.trans_iconCenter = nil

	for _, icon in ipairs(self.iconList) do
		icon = nil
	end

	self.iconList = nil
end

function DlgUICutInSession:OnRegisterEvent()
	return
end

function DlgUICutInSession:OnUnRegisterEvent()
	return
end

function DlgUICutInSession:OnEnter(vParam)
	self.img_typeGround = self:GetChildComponent("panel/aniPart2/img_typeGround", "Image")
	self.img_square = self:GetChildComponent("panel/aniPart2/img_square", "Image")
	self.img_countTxt = self:GetChildComponent("panel/aniPart2/img_countTxt", "Image")
	self.img_showName = self:GetChildComponent("panel/aniPart2/img_showName", "Image")
	self.trans_spineRoot = self:GetChildComponent("panel/aniPart1/roleContent", "Transform")
	self.txt_forcepVal = self:GetChildComponent("panel1/image/forcepVal/txt_forcepVal", "Text")
	self.trans_forceValEffs = self:GetChildGameObject("panel1/eff").transform
	self.img_sessionCountWord = self:GetChildComponent("panel/aniPart2/img_sessionCountWord", "Image")
	self.trans_iconCenter = self:GetChildGameObject("panel/aniPart2/obj_iconCenter").transform
	self.iconList = {}

	local tempRoot = self:GetChildGameObject("panel/aniPart2/sessionContent").transform

	for i = 1, tempRoot.childCount do
		local obj = tempRoot:GetChild(i - 1).transform:GetChild(0).gameObject
		local moveSc = GOUtil.GetComponent(obj, "UIEffectMove")

		table.insert(self.iconList, moveSc)
	end

	self:Show(false)
end

function DlgUICutInSession:Open(msg, callback)
	if #msg.uniqueIds <= 1 or msg.sessionType == 0 then
		if callback then
			callback()
		end

		return
	end

	local _idx = math.random(1, #msg.uniqueIds)
	local randomUnit = UnitActor.FindUnitById(msg.uniqueIds[_idx])

	Event.Instance:Fire("UnitVocalEvent", UnitVocal.enType.Cutin, randomUnit)
	self:Show(true)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)
	BattleConfig.PlaySound("Play_SE_020_0027")

	local showCount = #msg.uniqueIds
	local isBossFight = false

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS then
		isBossFight = true

		local root = self.trans_spineRoot.gameObject

		self:PlaySpine(msg.uniqueIds, root)
	end

	self:Refresh(showCount, msg.sessionType, msg.uniqueIds)
	BattleConfig.Delay(BattleConfig.Guide.CutIn, function()
		InstructionMgr:TriggerWait("CutIn")
	end)
	BattleConfig.Delay(2, function()
		self:HideAllSpines()
		self:Show(false)

		if not isBossFight then
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true)
		end

		if callback then
			callback()
		end
	end)
end

function DlgUICutInSession:Refresh(showCount, type, uniqueIds)
	local path = imgCountTable[showCount]

	GP.SpriteUtil:SetSprite(self.img_countTxt, path)

	path = imgTypeGround[type]

	GP.SpriteUtil:SetSprite(self.img_typeGround, path)

	path = imgTypeSquare[type]

	GP.SpriteUtil:SetSprite(self.img_square, path)

	path = imgSessionCountPic[showCount]

	GP.SpriteUtil:SetSprite(self.img_sessionCountWord, path)

	path = imgTypeArrowBk[type]

	GP.SpriteUtil:SetSprite(self.img_showName, path)

	for i = 1, self.trans_forceValEffs.childCount do
		GOUtil.SetActive(self.trans_forceValEffs:GetChild(i - 1).gameObject, i <= showCount + 1)
	end

	local sessionBonusMP = GetConfigArgJson("SessionBonusMP")
	local mp_val = sessionBonusMP[showCount]

	for i = #uniqueIds + 1, #self.iconList do
		local img = GOUtil.GetComponent(self.iconList[i]:GetGameObject(), "Image")

		if img then
			img.enabled = false
		end
	end

	for i = 1, #uniqueIds do
		local unit = UnitActor.FindUnitById(uniqueIds[i])
		local unitId = unit.UnitId
		local img = GOUtil.GetComponent(self.iconList[i]:GetGameObject(), "Image")
		local path = EnumBattle.GetSecctionShowIcon(type)

		self.iconList[i]:GetGameObject().transform.localPosition = Vector3(0, 0, 0)

		GOUtil.SetActive(self.iconList[i]:GetGameObject().transform.parent.gameObject, true)

		img.enabled = true

		GP.SpriteUtil:SetSprite(img, path)
		BattleConfig.Delay(0.7, function()
			self.iconList[i]:Play(self.trans_iconCenter, self.iconList[i]:GetGameObject().transform.parent, nil)
		end)
	end

	if type == EnumBattle.SeccionType.force then
		mp_val = mp_val + GetConfigArgJson("MPSessionGetMP")[#uniqueIds]
	end

	UIUtil.SetTextString(self.txt_forcepVal, "+" .. tostring(Mathf.Ceil(mp_val)))
end

function DlgUICutInSession:PlaySpine(uniqueIds, root)
	for i, uniqueId in ipairs(uniqueIds) do
		SceneMgr.GetCurrentScene().PageFight:PlaySpine(uniqueId, root)
	end
end

function DlgUICutInSession:HideAllSpines()
	SceneMgr.GetCurrentScene().PageFight:HideAllSpines()
end
