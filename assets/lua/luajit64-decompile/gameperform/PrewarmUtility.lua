-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/PrewarmUtility.lua

local EffectCfg = require("luaData/EffectData")
local BuffData = require("luaData/BattleBuffData")
local BulletData = require("luaData.BulletData")

PrewarmUtility = class("PrewarmUtility")

local preImg = {
	"UI/PageFight/AtlasBattleInfo/BTN_auto_02_cn",
	"UI/PageFight/AtlasBattleSetting/BTN_ani_off",
	"UI/PageFight/AtlasBattleSetting/BTN_ani_on",
	"UI/PageFight/AtlasPageBattle/ui_hd_batback_100",
	"UI/PageFight/AtlasPageBattle/ui_hd_batback_200",
	"UI/PageFight/AtlasPageBattle/ui_hd_icon_charge_s",
	"UI/PageFight/AtlasPageBattle/ui_hd_icon_dance_s",
	"UI/PageFight/AtlasPageBattle/ui_hd_icon_sing_s",
	"UI/PageFight/AtlasPageBattle/ui_hd_icon_up_02",
	"UI/PageFight/AtlasPageBattle/ui_hd_icon_down_02",
	"UI/PageFight/SkillChange/BTN_timelimit_01",
	"UI/PageFight/SkillChange/BTN_timelimit_02",
	"UI/PageFight/SkillChange/ui_hd_button_cn_auto",
	"UI/PageFight/SkillChange/BTN_auto_02_cn",
	"UI/PageFight/SkillChange/ui_hd_button_cn_auto_02",
	"UI/PageFight/AtlasResult/ui_hd_word_en_clear",
	"UI/PageFight/AtlasResult/ui_hd_word_en_failed",
	"UI/PageFight/AtlasPageBattle/ICO_aim_01",
	"UI/PageFight/AtlasPageBattle/ICO_aim_01b",
	"UIDyAtlas/Team/IC_SKI_jb_01",
	"UIDyAtlas/Team/IC_SKI_jb_02",
	"UIDyAtlas/Team/IC_SKI_jb_03",
	"UIDyAtlas/Team/IC_SKI_jb_04",
	"UIDyAtlas/Team/IC_SKI_jb_05",
	"UIDyAtlas/Team/IC_SKI_jb_06",
	"UIDyAtlas/Team/IC_SKI_jb_07",
	"UIDyAtlas/Battle/ui_hd_icon_huineng_01",
	"UIDyAtlas/Battle/ui_hd_icon_huineng_02",
	"UIDyAtlas/Battle/ui_hd_icon_lvneng_01",
	"UIDyAtlas/Battle/ui_hd_icon_lvneng_02",
	"UIDyAtlas/Battle/ui_hd_icon_yuneng_01",
	"UIDyAtlas/Battle/ui_hd_icon_yuneng_02",
	"UI/PageFight/AtlasPageBattle/BG_back_red_01",
	"UI/PageFight/AtlasPageBattle/BG_back_blue_01",
	"UI/PageFight/AtlasPageBattle/BG_back_yellow_01",
	"UIDyAtlas/Battle/ui_hd_icon_sing_s",
	"UIDyAtlas/Battle/ui_hd_icon_charge_s",
	"UIDyAtlas/Battle/ui_hd_icon_dance_s",
	"UIDyAtlas/Battle/ui_hd_icon_sing",
	"UIDyAtlas/Battle/ui_hd_icon_charge",
	"UIDyAtlas/Battle/ui_hd_icon_dance",
	"UI/PageFight/AtlasPageBattle/ui_hd_word_cn_fury",
	"UI/PageFight/AtlasPageBattle/ui_hd_word_cn_fury2",
	"UI/PageFight/AtlasPageBattle/ui_hd_word_cn_fury3",
	"UIDyAtlas/Battle/ui_hd_word_session_1",
	"UIDyAtlas/Battle/ui_hd_word_session_2",
	"UIDyAtlas/Battle/ui_hd_word_session_3",
	"UIDyAtlas/Battle/ui_hd_word_session_4",
	"UIDyAtlas/Battle/ui_hd_back_report_01b",
	"UIDyAtlas/Battle/ui_hd_back_report_02b",
	"UIDyAtlas/Battle/ui_hd_back_report_03b",
	"UIDyAtlas/Battle/ui_hd_back_report_01",
	"UIDyAtlas/Battle/ui_hd_back_report_02",
	"UIDyAtlas/Battle/ui_hd_back_report_03",
	"UIDyAtlas/Battle/ui_hd_word_sing5",
	"UIDyAtlas/Battle/ui_hd_word_charge5",
	"UIDyAtlas/Battle/ui_hd_word_dance5",
	"UIDyAtlas/Battle/ui_hd_word_cn_small",
	"UIDyAtlas/Battle/ui_hd_word_cn_middle",
	"UIDyAtlas/Battle/ui_hd_word_cn_big",
	"UIDyAtlas/Battle/ui_hd_word_cn_super",
	"UIDyAtlas/Skill/IC_battleup_03_cn",
	"UIDyAtlas/Skill/IC_battleup_01_cn",
	"UIDyAtlas/Skill/IC_battleup_04_cn",
	"UIDyAtlas/Skill/IC_battleup_02_cn",
	FloatTipConfig.HealTip,
	FloatTipConfig.MissingTip,
	FloatTipConfig.ShieldTip,
	FloatTipConfig.AddShieldTip,
	FloatTipConfig.CirticalDamage_Phy,
	FloatTipConfig.CirticalDamage_Mag,
	FloatTipConfig.CirticalDamage_Mix,
	FloatTipConfig.JobDecDamage_Phy,
	FloatTipConfig.JobDecDamage_Mag,
	FloatTipConfig.JobDecDamage_Mix,
	FloatTipConfig.JobIncDamage,
	FloatTipConfig.PoisonDamage,
	FloatTipConfig.NeverSurrender,
	FloatTipConfig.DotBreak,
	"UIDyAtlas/Floattip/ui_hd_word_cn_up_2",
	"UIDyAtlas/Floattip/ui_hd_word_cn_down_2",
	"UIDyAtlas/Floattip/ui_hd_word_cn_up_3",
	"UIDyAtlas/Floattip/ui_hd_word_cn_down_3",
	"UIDyAtlas/Floattip/ui_hd_word_cn_up_4",
	"UIDyAtlas/Floattip/ui_hd_word_cn_down_4",
	FloatTipConfig.BuffCleanUp,
	FloatTipConfig.BUFF_INVALID_MODE,
	FloatTipConfig.BUFF_INVALID_ICON,
	FloatTipConfig.BUFF_IMMUNE_MODE,
	FloatTipConfig.BUFF_IMMUNE_ICON
}
local preEff = {}
local preEffIds = {
	FloatEffConfig.HealTip,
	FloatEffConfig.MissingTip,
	FloatEffConfig.AddShieldTip,
	FloatEffConfig.DmgTip,
	BattleConfig.BreakShield.Fx[1],
	BattleConfig.BreakShield.Fx[2],
	BattleConfig.BreakShield.Fx[3]
}
local CONST_PREWARM_EFF_COUNT = 5

function PrewarmUtility:ctor(GP)
	self.GP = GP

	self:Reset()
end

function PrewarmUtility:Reset()
	self.Sprites = {}
	self.SpritePaths = {}
	self.EffectMap = {}
	self.EffectPathList = {}
end

function PrewarmUtility:Cache()
	for i, imgPath in ipairs(preImg) do
		self:_SubmitCache(imgPath)
	end

	for i, path in ipairs(self.SpritePaths) do
		self:_SubmitCache(path)
	end

	for _, effpath in ipairs(preEff) do
		BattleConfig.FxPrewarm(effpath, CONST_PREWARM_EFF_COUNT)
	end

	for _, effId in ipairs(preEffIds) do
		self:PushEffect(effId)
	end

	self:_CacheEffect()
end

function PrewarmUtility:SpritePath(path)
	if path == nil or path == "" then
		return
	end

	table.insert(self.SpritePaths, path)
end

function PrewarmUtility:PushEffect(effId)
	if effId == nil or effId == 0 then
		return
	end

	if self.EffectMap[tostring(effId)] then
		return
	end

	if not EffectCfg[effId] then
		return
	end

	local effPath = EffectCfg[effId].Prefab

	if effPath == "" then
		return
	end

	self.EffectMap[tostring(effId)] = effPath
end

function PrewarmUtility:_SubmitCache(path)
	if path == nil or path == "" then
		return
	end

	ResourceMgr.SubmitCache(path, self.Sprites, path, Sprite)
end

function PrewarmUtility:_CacheEffect()
	for k, eff in pairs(self.EffectMap) do
		BattleConfig.FxCache(eff, 1)
	end
end

function PrewarmUtility:PrewarmEffect()
	for k, eff in pairs(self.EffectMap) do
		BattleConfig.FxPrewarm(eff, CONST_PREWARM_EFF_COUNT)
	end
end

function PrewarmUtility:Purge()
	for k, v in pairs(self.Sprites) do
		v = nil
	end

	for k, eff in pairs(self.EffectMap) do
		v = nil
	end

	self:Reset()
end

function PrewarmUtility:AddUnit(unit)
	if unit.UnitClass == EnumFight.UnitClass.PLAYER then
		local path = "UI/PageFight/AtlasPageBattle/ICO_" .. unit.UnitData.data.Job .. "_01_S"

		self:SpritePath(path)

		local path2 = "UI/PageFight/AtlasPageBattle/ICO_" .. unit.UnitData.data.Job .. "_01_S2"

		self:SpritePath(path2)

		local card_fields = {
			"SmallIcon",
			"HitIcon"
		}

		for i, field in ipairs(card_fields) do
			local path = unit.InfoRoleCard.data[field]

			if path and path ~= "" then
				self:SpritePath(path)
			end
		end

		self:SpritePath("UIDyAtlas/RoleJob/ICO_" .. unit.UnitData.data.Job .. "_01")
		self:SpritePath("UIDyAtlas/RoleJob/ICO_" .. unit.UnitData.data.Job .. "_01_S")
		self:SpritePath("UI/PageFight/AtlasPageBattle/ICO_" .. unit.UnitData.data.Job .. "_01_S2")

		local jobpath = "UI/PageFight/SkillChange/ICO_" .. unit.UnitData.data.Job .. "_02"

		self:SpritePath(jobpath)

		local rolepath = unit.InfoRoleCard.data.MidIcon

		self:SpritePath(rolepath)
	elseif unit.UnitClass == EnumFight.UnitClass.ENEMY then
		self:SpritePath(EnemyManager:Get(unit.UnitId).data.HeadIcon)
		self:SpritePath("UI/PageFight/AtlasPageBattle/ICO_" .. unit.UnitData.data.Job .. "_01_S")
		self:PushEffect(unit.UnitData.data.DamageFx)
		self:PushEffect(unit.UnitData.data.AppearFx)
		self:PushEffect(unit.UnitData.data.CastFx)
		self:PushEffect(unit.UnitData.data.LaunchFx)
		self:PushEffect(unit.UnitData.data.DieFx)

		for i, castFx in ipairs(unit.UnitData.data.DieFxs) do
			self:PushEffect(castFx)
		end
	end
end

function PrewarmUtility:AddSkill(skill)
	if skill.IconPath ~= "" then
		self:SpritePath(skill.IconPath)
	end

	for i, castFx in ipairs(skill.infoBattleSkill.CastFxs) do
		self:PushEffect(castFx)
	end

	for i, castFx in ipairs(skill.infoBattleSkill.CampFxs) do
		self:PushEffect(castFx)
	end

	for i, castFx in ipairs(skill.infoBattleSkill.CameraFxs) do
		self:PushEffect(castFx)
	end

	for actionKeyIdx, actionKeyData in ipairs(skill.infoBattleSkill.Custom) do
		for key, val in pairs(actionKeyData) do
			if key == "ADD_BUFF" then
				local buffId = val[skill.Level]

				buffId = buffId or val[1]

				self:AddBuff(buffId)
			end

			if key == "Hit_eff" then
				local fxs = val[skill.Level]

				fxs = fxs or val[1]

				for fxIdx, fx in ipairs(fxs) do
					self:PushEffect(fx)
				end
			end

			if key == "Bullet" then
				local bulletIds = val[skill.Level]

				bulletIds = bulletIds or val[1]

				for bulletIdx, bulletId in ipairs(bulletIds) do
					self:AddBullet(bulletId)
				end
			end
		end
	end
end

function PrewarmUtility:AddBuff(buffId)
	if buffId == 0 then
		return
	end

	local cfg = BuffData[buffId]

	if not cfg then
		return
	end

	if cfg.Icon ~= "" then
		self:SpritePath(cfg.Icon)
	end

	self:PushEffect(cfg.Fx)
	self:PushEffect(cfg.RemoveFx)
	self:PushEffect(cfg.ExeFx)

	for i, eff in ipairs(cfg.RoundFx) do
		self:PushEffect(eff)
	end

	for i, eff in ipairs(cfg.UIExeFxsOnIcon) do
		self:PushEffect(eff)
	end

	for i, eff in ipairs(cfg.UIExeFxs) do
		self:PushEffect(eff)
	end

	for i, eff in ipairs(cfg.UIFxsOnIcon) do
		self:PushEffect(eff)
	end

	for i, eff in ipairs(cfg.UIFxs) do
		self:PushEffect(eff)
	end
end

function PrewarmUtility:AddBullet(bulletId)
	if bulletId == 0 then
		return
	end

	local cfg = BulletData[bulletId]

	if not cfg then
		return
	end

	self:PushEffect(cfg.Fx)
end
