-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellHeadTip.lua

CellHeadTip = class("CellHeadTip", UIPanel_sync, true)

function CellHeadTip:ctor()
	CellHeadTip.base.ctor(self, "UI/PageFight/Cells/ItemAttribute")
	self:Reset()
end

function CellHeadTip:Cache()
	CellHeadTip.base.Cache(self)
end

function CellHeadTip:Close()
	CellHeadTip.base.Close(self)
end

function CellHeadTip:Reset()
	self.Owner = nil
	self.UniqueId = nil
	self.IsUnitPlayer = nil
	self.IsUnitEnemy = nil
	self.Camera = nil
	self.Scaler = nil
	self.img_selectTarget = nil
	self.dmgTipGo = nil
	self.CSharp = nil
end

function CellHeadTip:Purge()
	CellHeadTip.base.Purge(self)
	self:Reset()
end

function CellHeadTip:OnRegisterEvent()
	Event.Instance:Add("UnitDealDamage", self.OnUnitDealDamage, self)
	Event.Instance:Add("UnitHealHp", self.OnUnitHealHp, self)
	Event.Instance:Add("AddShield", self.OnUnitAddShield, self)
	Event.Instance:Add("UnitMissing", self.UnitMissing, self)
	Event.Instance:Add("BuffMiss", self.OnBuffMiss, self)
	Event.Instance:Add("OnBuffCutomMsg", self.OnBuffCutomMsg, self)
	Event.Instance:Add("OnSkillFloatTip", self.SkillFloatTip, self)
	Event.Instance:Add("OnUIEffect", self.OnUIEffect, self)
	Event.Instance:Add("GameChageStage", self.OnGameChageStage, self)
end

function CellHeadTip:OnUnRegisterEvent()
	Event.Instance:Remove("UnitDealDamage", self.OnUnitDealDamage, self)
	Event.Instance:Remove("UnitHealHp", self.OnUnitHealHp, self)
	Event.Instance:Remove("AddShield", self.OnUnitAddShield, self)
	Event.Instance:Remove("UnitMissing", self.UnitMissing, self)
	Event.Instance:Remove("BuffMiss", self.OnBuffMiss, self)
	Event.Instance:Remove("OnBuffCutomMsg", self.OnBuffCutomMsg, self)
	Event.Instance:Remove("OnSkillFloatTip", self.SkillFloatTip, self)
	Event.Instance:Remove("OnUIEffect", self.OnUIEffect, self)
	Event.Instance:Remove("GameChageStage", self.OnGameChageStage, self)
end

function CellHeadTip:OnEnter()
	self.HeadSelectObj = nil
	self.Camera = SceneMgr.GetCurrentScene().camera
	self.img_selectTarget = self:GetChildComponent("panel/obj_selectTargetRoot/img_selectTarget", "Image")
	self.HeadSelectObj = self:GetChildGameObject("panel/obj_selectTargetRoot")

	self:ShowTargetEffect(false)

	self.dmgTipGo = self:GetChildGameObject("panel/ItemDmgTip")

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.NORMAL then
		self.roleIconEffRoot = self.dmgTipGo
	else
		self.roleIconEffRoot = self:GetChildGameObject("panel/ItemFloatEffect")
	end

	self.floatTipRoots = {}

	local temp = {
		"panel/FloatTipRoots/Player",
		"panel/FloatTipRoots/PVPPlayer",
		"panel/FloatTipRoots/Monster",
		"panel/FloatTipRoots/Boss"
	}

	for i = 1, 4 do
		self.floatTipRoots[i] = {}

		local objs = self:GetChildGameObject(temp[i])

		for j = 1, objs.transform.childCount do
			local r = objs.transform:GetChild(j - 1)

			table.insert(self.floatTipRoots[i], r.gameObject)
		end
	end

	self:ShowTargetEffect(false)
	self:Show(false)
end

function CellHeadTip:Open()
	self:Show(true)
end

function CellHeadTip:Hide()
	self:Show(false)
end

function CellHeadTip:BindUnit(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if not unit then
		return
	end

	if unit.UnitClass == EnumFight.UnitClass.PLAYER and GP.FightMode == EnumFight.BattleType.BOSS then
		return
	end

	self.UniqueId = msg.uniqueId
	self.Owner = unit

	self.Owner:SetHeadTip(self)

	local imgPath = "UI/PageFight/AtlasPageBattle/ICO_aim_01"

	if self.Owner.UnitClass == EnumFight.Camp.PLAYER then
		imgPath = "UI/PageFight/AtlasPageBattle/ICO_aim_01b"
	end

	GP.SpriteUtil:SetSprite(self.img_selectTarget, imgPath)

	local offset = 0

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS and self.Owner.UnitClass == EnumFight.UnitClass.ENEMY then
		GOUtil.SetRectTransformAnchoredPosition(self.roleIconEffRoot, 0, 320)
	end

	local isHuman = false

	if self.Owner.UnitClass == 2 and self.Owner.UnitData.data.Boss == 1 then
		offset = 630

		GOUtil.SetRectTransformAnchoredPosition(self.HeadSelectObj, 0, offset)
		GOUtil.SetRectTransformAnchoredPosition(self.dmgTipGo, 0, 320)
	elseif self.Owner.UnitClass == 2 and self.Owner.UnitData.data.Boss == 0 then
		offset = 155

		GOUtil.SetRectTransformAnchoredPosition(self.HeadSelectObj, 0, offset)
		GOUtil.SetRectTransformAnchoredPosition(self.dmgTipGo, 0, 230)

		if self.Owner.UnitData.data.PlayType == 2 then
			isHuman = true
		end
	elseif self.Owner.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		offset = 380

		GOUtil.SetRectTransformAnchoredPosition(self.HeadSelectObj, 0, offset)
		GOUtil.SetRectTransformAnchoredPosition(self.dmgTipGo, 0, 230)

		isHuman = true
	else
		offset = 300

		GOUtil.SetRectTransformAnchoredPosition(self.HeadSelectObj, 0, offset)
		GOUtil.SetRectTransformAnchoredPosition(self.dmgTipGo, 0, 230)

		if self.Owner.Camp == EnumFight.Camp.PLAYER then
			isHuman = true
		end
	end

	if isHuman == true then
		local root = self.Owner:GetBone("HeadHit")

		if root then
			GOUtil.AttachUIGameObject(self.HeadSelectObj, self.UIRootObject.transform.parent.gameObject)

			local cs = GOUtil.AddMissingComponent(self.HeadSelectObj, "HeadAttribute")

			cs:Init(self.Camera, root.transform)
			cs:SetOffset(0, -50)
		end
	end

	self.CSharp = GOUtil.AddMissingComponent(self.UIRootObject, "HeadAttribute")

	self.CSharp:Init(self.Camera, self.Owner.ActorRoot.transform)
	self:Show(true)
end

function CellHeadTip:GetFloatTipRoot()
	local root = self.dmgTipGo
	local idx = 0

	if self.Owner.UnitClass == EnumFight.UnitClass.PLAYER then
		idx = 1
	elseif self.Owner.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		idx = 2
	elseif self.Owner.UnitClass == EnumFight.UnitClass.ENEMY then
		idx = self.Owner.UnitData.data.Boss == 0 and 3 or 4
	end

	if idx ~= 0 then
		local roots = self.floatTipRoots[idx]
		local r = math.random(1, #roots)

		root = roots[r]
	end

	return root
end

function CellHeadTip:ClearData()
	self.Owner = nil
	self.UniqueId = nil

	self:Show(false)
end

function CellHeadTip:Attach(root)
	GOUtil.AttachGameObject(self.UIRootObject, root, true)
end

function CellHeadTip:OnBuffMiss(uid, reason)
	if uid ~= self.UniqueId then
		return
	end

	local imgRoot, imgPath

	imgRoot = self:GetFloatTipRoot()

	if reason == EnumFight.BuffMissReason.Useless then
		imgPath = FloatTipConfig.BUFF_INVALID_MODE
	else
		imgPath = FloatTipConfig.BUFF_IMMUNE_MODE
	end

	FloatTipUtil.ImgTip(imgRoot, imgPath)
end

function CellHeadTip:OnUnitDealDamage(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	if msg.minusShield > 0 then
		BattleConfig.Delay(0.8, function()
			FloatTipUtil.ShieldTip(msg.minusShield, self.dmgTipGo)
		end)
	end

	if msg.minusHp > 0 then
		FloatTipUtil.DamageTip(self:GetFloatTipRoot(), msg)
	end
end

function CellHeadTip:OnUnitHealHp(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	if msg.healHp > 0 then
		FloatTipUtil.HealTip(msg.healHp, self.dmgTipGo)
	end
end

function CellHeadTip:OnUnitAddShield(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	if msg.addShield > 0 then
		FloatTipUtil.AddShieldTip(msg.addShield, self.dmgTipGo)
	end
end

function CellHeadTip:UnitMissing(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	FloatTipUtil.MissingTip(self:GetFloatTipRoot())
end

function CellHeadTip:OnBuffCutomMsg(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	if msg.custom == "NeverSurrender" then
		FloatTipUtil.NeverSurrenderTip(msg.args.CurVal, msg.args.MaxVal, self:GetFloatTipRoot())
	elseif msg.custom == "ClearBuff" then
		FloatTipUtil.ImgTip(self:GetFloatTipRoot(), FloatTipConfig.BuffCleanUp)
	elseif msg.custom == "BuffInvalid" then
		FloatTipUtil.ImgTip(self:GetFloatTipRoot(), FloatTipConfig.BUFF_INVALID_MODE)
	end
end

local _BattleSkillData = require("GamePerform.Object.InfoBattleSkillData")

function CellHeadTip:SkillFloatTip(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	if not _BattleSkillData:GetData(msg.skillId) then
		return
	end

	local cfg = _BattleSkillData:GetData(msg.skillId).Custom[msg.idx]

	if not cfg then
		return
	end

	if not cfg.FloatTip then
		return
	end

	if not cfg.FloatTip[msg.skillLv] then
		return
	end

	FloatTipUtil.ImgTip(self:GetFloatTipRoot(), cfg.FloatTip[msg.skillLv])
end

function CellHeadTip:OnUIEffect(uniqieId, effectId)
	if self.UniqueId ~= uniqieId then
		return
	end

	EffectMgr:AllocById(effectId, self.roleIconEffRoot)
end

function CellHeadTip:OnUnitUpdateAttri(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	if msg.attriName == "生命" then
		local val = self.Owner:GetAttri("最大生命")
		local max = self.Owner:GetAttri("最大生命")
		local cur = self.Owner:GetAttri("生命")

		if not val then
			return
		end

		self.txt_hp.text = msg.cur .. "/" .. val
	elseif msg.attriName == "最大生命" then
		local val = self.Owner:GetAttri("生命")

		if not val then
			return
		end

		self.txt_hp.text = val .. "/" .. msg.cur
	end
end

function CellHeadTip:ShowTargetEffect(val)
	GOUtil.SetActive(self.img_selectTarget.gameObject, val)
end

function CellHeadTip:SetActive(val)
	GOUtil.SetActive(self.UIRootObject, val)

	if self.HeadSelectObj then
		GOUtil.SetActive(self.HeadSelectObj, val)
	end
end

function CellHeadTip:OnGameChageStage(stage)
	if stage == -1 then
		return
	end

	self.img_selectTarget.enabled = stage == EnumFight.GameState.OPERATOR_WAIT
end
