-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/FloatTip/FloatTipUtil.lua

local TipBase = class("TipBase", CacheableObject, true)

function TipBase:ctor()
	TipBase.base.ctor(self)
end

function TipBase:Reset()
	if self.gameObject == nil then
		return
	end

	GOUtil.SetActive(self.gameObject, false)
	GOUtil.AttachGameObject(self.gameObject, FloatTipUtil.GetDefaultRoot())
end

function TipBase:Instantiate(prefab)
	self.gameObject = GOUtil.InstantiateUIPrefab(prefab, nil)
	self.txt1 = GOUtil.FindChildComponent(self.gameObject, "txt_label1", "Text")
	self.txt1_graphic = GOUtil.FindChildComponent(self.gameObject, "txt_label1", "Graphic")
	self.txt_outline = GOUtil.FindChildComponent(self.gameObject, "txt_outline", "Text")
	self.txt_outline_graphic = GOUtil.FindChildComponent(self.gameObject, "txt_outline", "Graphic")
	self.txt2 = GOUtil.FindChildComponent(self.gameObject, "txt_label2", "Text")
	self.img = GOUtil.FindChildComponent(self.gameObject, "Image", "Image")
end

function TipBase:Init(root)
	if self.gameObject == nil then
		return
	end

	GOUtil.AttachGameObject(self.gameObject, root)
	GOUtil.SetActive(self.gameObject, true)
end

function TipBase:IsVaild()
	return self.gameObject ~= nil
end

function TipBase:SetNumText(num)
	local numStr = string.format("%d", num)

	UIUtil.SetTextString(self.txt1, numStr)
end

function TipBase:SetText(str)
	if self.txt_outline ~= nil then
		UIUtil.SetTextString(self.txt_outline, tostring(str))
	end

	UIUtil.SetTextString(self.txt1, tostring(str))
end

function TipBase:SetTextColor(rgba)
	if not rgba then
		UIUtil.SetGraphicColorRGBA(self.txt1_graphic, 1, 1, 1, 1)
	else
		UIUtil.SetGraphicColorRGBA(self.txt1_graphic, rgba.r, rgba.g, rgba.b, rgba.a)
	end
end

function TipBase:SetOutlineColorRGBA(rgba)
	if self.txt_outline ~= nil then
		if not rgba then
			UIUtil.SetGraphicColorRGBA(self.txt_outline_graphic, 1, 1, 1, 1)
		else
			UIUtil.SetGraphicColorRGBA(self.txt_outline_graphic, rgba.r, rgba.g, rgba.b, rgba.a)
		end
	elseif not rgba then
		UIUtil.SetOutlineColorRGBA(self.txt1_graphic.gameObject, -1, -1, -1, -1)
	else
		UIUtil.SetOutlineColorRGBA(self.txt1_graphic.gameObject, rgba.r, rgba.g, rgba.b, rgba.a)
	end
end

function TipBase:SetImage(imgPath)
	if imgPath then
		GP.SpriteUtil:SetSprite(self.img, imgPath)

		self.img.enabled = true

		self.img:SetNativeSize()
	else
		self.img.enabled = false
	end
end

FloatTipUtil = {}
FloatTipUtil.ObjectPool = {}
FloatTipUtil.DefaultRoot = nil
FloatTipUtil.GameObjects = {}

function FloatTipUtil.Purge()
	for i, obj in ipairs(FloatTipUtil.GameObjects) do
		obj = nil
	end

	FloatTipUtil.ObjectPool = {}
	FloatTipUtil.DefaultRoot = nil
	FloatTipUtil.GameObjects = {}
end

function FloatTipUtil.Cache()
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/FloatTip_ImgTxt", FloatTipUtil, "FloatTip_ImgTxt")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/FloatTip_Txt", FloatTipUtil, "FloatTip_Txt")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/FloatTip_Img", FloatTipUtil, "FloatTip_Img")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/1_normal", FloatTipUtil, "prefab_1_normal")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/1_normal_dot", FloatTipUtil, "prefab_1_normal_dot")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/1_normal_mix", FloatTipUtil, "prefab_1_normal_mix")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/1_normal_phy", FloatTipUtil, "prefab_1_normal_phy")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/1_normal_mag", FloatTipUtil, "prefab_1_normal_mag")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/1_normal_sheild", FloatTipUtil, "prefab_1_normal_sheild")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/3_weak_mix", FloatTipUtil, "prefab_3_weak_mix")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/3_weak_mag", FloatTipUtil, "prefab_3_weak_mag")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/3_weak_phy", FloatTipUtil, "prefab_3_weak_phy")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/5_crit_mag", FloatTipUtil, "prefab_5_crit_mag")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/5_crit_mix", FloatTipUtil, "prefab_5_crit_mix")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/5_crit_phy", FloatTipUtil, "prefab_5_crit_phy")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/6_recover", FloatTipUtil, "prefab_6_recover")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/6_recover_sheild", FloatTipUtil, "prefab_6_recover_sheild")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/2_break_mix", FloatTipUtil, "prefab_2_break_mix")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/2_break_phy", FloatTipUtil, "prefab_2_break_phy")
	ResourceMgr.SubmitCache("UI/PageFight/FloatTip/TipPrefab/2_break_mag", FloatTipUtil, "prefab_2_break_mag")
end

function FloatTipUtil.OnEnter()
	FloatTipUtil.ObjectPool = {
		ImgTxtPool = ObjectPool(TipBase, FloatTipUtil.FloatTip_ImgTxt),
		TxtPool = ObjectPool(TipBase, FloatTipUtil.FloatTip_Txt),
		ImgPool = ObjectPool(TipBase, FloatTipUtil.FloatTip_Img),
		prefab_1_normal = ObjectPool(TipBase, FloatTipUtil.prefab_1_normal),
		prefab_1_normal_dot = ObjectPool(TipBase, FloatTipUtil.prefab_1_normal_dot),
		prefab_5_crit_mix = ObjectPool(TipBase, FloatTipUtil.prefab_5_crit_mix),
		prefab_5_crit_phy = ObjectPool(TipBase, FloatTipUtil.prefab_5_crit_phy),
		prefab_5_crit_mag = ObjectPool(TipBase, FloatTipUtil.prefab_5_crit_mag),
		prefab_3_weak_mix = ObjectPool(TipBase, FloatTipUtil.prefab_3_weak_mix),
		prefab_3_weak_phy = ObjectPool(TipBase, FloatTipUtil.prefab_3_weak_phy),
		prefab_3_weak_mag = ObjectPool(TipBase, FloatTipUtil.prefab_3_weak_mag),
		prefab_2_break_mix = ObjectPool(TipBase, FloatTipUtil.prefab_2_break_mix),
		prefab_2_break_phy = ObjectPool(TipBase, FloatTipUtil.prefab_2_break_phy),
		prefab_2_break_mag = ObjectPool(TipBase, FloatTipUtil.prefab_2_break_mag),
		prefab_1_normal_mix = ObjectPool(TipBase, FloatTipUtil.prefab_1_normal_mix),
		prefab_1_normal_phy = ObjectPool(TipBase, FloatTipUtil.prefab_1_normal_phy),
		prefab_1_normal_mag = ObjectPool(TipBase, FloatTipUtil.prefab_1_normal_mag),
		prefab_1_normal_sheild = ObjectPool(TipBase, FloatTipUtil.prefab_1_normal_sheild),
		prefab_6_recover = ObjectPool(TipBase, FloatTipUtil.prefab_6_recover),
		prefab_6_recover_sheild = ObjectPool(TipBase, FloatTipUtil.prefab_6_recover_sheild)
	}
end

function FloatTipUtil.Create(type, ...)
	local pool = FloatTipUtil.ObjectPool[type]
	local obj = pool:Create(...)

	BattleConfig.Delay(1.1, function()
		pool:Destroy(obj)
	end)
	table.insert(FloatTipUtil.GameObjects, obj)

	return obj
end

function FloatTipUtil.GetDefaultRoot()
	if not FloatTipUtil.DefaultRoot and SceneMgr.GetCurrentScene().GP then
		FloatTipUtil.DefaultRoot = SceneMgr.GetCurrentScene().PageFight.UIRootObject
	end

	return FloatTipUtil.DefaultRoot
end

function FloatTipUtil.NeverSurrenderTip(val, maxVal, root)
	local tip = FloatTipUtil.Create("ImgTxtPool", root)

	tip:SetText(tostring(val) .. "/" .. tostring(maxVal))
	tip:SetImage(FloatTipConfig.NeverSurrender)
end

function FloatTipUtil.ImgTip(root, imgPath)
	local tip = FloatTipUtil.Create("ImgPool", root)

	tip:SetImage(imgPath)
end

function FloatTipUtil.HealTip(healVal, root)
	local tip = FloatTipUtil.Create("prefab_6_recover", root)

	tip:SetNumText(healVal)
end

function FloatTipUtil.MissingTip(root)
	FloatTipUtil.ImgTip(root, FloatTipConfig.MissingTip)
end

function FloatTipUtil.ShieldTip(healVal, root)
	local tip = FloatTipUtil.Create("prefab_1_normal_sheild", root)

	tip:SetNumText(healVal)
end

function FloatTipUtil.AddShieldTip(healVal, root)
	local tip = FloatTipUtil.Create("prefab_6_recover_sheild", root)

	tip:SetNumText(healVal)
end

local dmgType = {
	cri = 16,
	strong = 32,
	weak = 64,
	phy = 2,
	dot = 1,
	mag = 4,
	mix = 6,
	shieldbreak = 128
}

local function And(num1, num2)
	local tmp1 = num1
	local tmp2 = num2
	local str = ""

	repeat
		local s1 = tmp1 % 2
		local s2 = tmp2 % 2

		if s1 == s2 then
			if s1 == 1 then
				str = "1" .. str
			else
				str = "0" .. str
			end
		else
			str = "0" .. str
		end

		tmp1 = math.modf(tmp1 / 2)
		tmp2 = math.modf(tmp2 / 2)
	until tmp1 == 0 and tmp2 == 0

	return tonumber(str, 2)
end

local function Or(num1, num2)
	local tmp1 = num1
	local tmp2 = num2
	local str = ""

	repeat
		local s1 = tmp1 % 2
		local s2 = tmp2 % 2

		if s1 == s2 then
			if s1 == 0 then
				str = "0" .. str
			else
				str = "1" .. str
			end
		else
			str = "1" .. str
		end

		tmp1 = math.modf(tmp1 / 2)
		tmp2 = math.modf(tmp2 / 2)
	until tmp1 == 0 and tmp2 == 0

	return tonumber(str, 2)
end

local function DstMask(...)
	local outMask = 0

	for i, mask in ipairs({
		...
	}) do
		outMask = Or(outMask, mask)
	end

	return outMask
end

local function IsDstMask(mask, ...)
	local dstMask = DstMask(...)

	if And(mask, dstMask) == dstMask then
		return true
	end

	return false
end

local function GetPrefabKey(mask)
	local k = "prefab_1_normal"

	if mask == 0 then
		k = "prefab_1_normal"
	elseif IsDstMask(mask, dmgType.dot) == true then
		k = "prefab_1_normal_dot"
	elseif IsDstMask(mask, dmgType.cri, dmgType.mix) == true then
		k = "prefab_5_crit_mix"
	elseif IsDstMask(mask, dmgType.cri, dmgType.phy) == true then
		k = "prefab_5_crit_phy"
	elseif IsDstMask(mask, dmgType.cri, dmgType.mag) == true then
		k = "prefab_5_crit_mag"
	elseif IsDstMask(mask, dmgType.weak, dmgType.mix) == true then
		k = "prefab_3_weak_mix"
	elseif IsDstMask(mask, dmgType.weak, dmgType.phy) == true then
		k = "prefab_3_weak_phy"
	elseif IsDstMask(mask, dmgType.weak, dmgType.mag) == true then
		k = "prefab_3_weak_mag"
	elseif IsDstMask(mask, dmgType.shieldbreak, dmgType.mix) == true then
		k = "prefab_2_break_mix"
	elseif IsDstMask(mask, dmgType.shieldbreak, dmgType.phy) == true then
		k = "prefab_2_break_phy"
	elseif IsDstMask(mask, dmgType.shieldbreak, dmgType.mag) == true then
		k = "prefab_2_break_mag"
	elseif IsDstMask(mask, dmgType.mix) == true then
		k = "prefab_1_normal_mix"
	elseif IsDstMask(mask, dmgType.phy) == true then
		k = "prefab_1_normal_phy"
	elseif IsDstMask(mask, dmgType.mag) == true then
		k = "prefab_1_normal_mag"
	else
		print("ERROR, not found floattip mask , " .. tostring(mask))
	end

	local str = ""

	for name, v in pairs(dmgType) do
		if IsDstMask(mask, v) == true then
			str = str .. " " .. name
		end
	end

	return k
end

function FloatTipUtil.DamageTip(root, msg)
	local mask = 0

	if msg.isCritical == true then
		mask = Or(mask, dmgType.cri)
	end

	if msg.dmgType == EnumFight.DamageType.DotBreak then
		mask = Or(mask, dmgType.dot)
	end

	if msg.jobMul > 1 then
		mask = Or(mask, dmgType.strong)
	end

	if msg.jobMul < 1 then
		mask = Or(mask, dmgType.weak)
	end

	if msg.breakShieldState == EnumFight.BreakShieldState.BREAKED then
		mask = Or(mask, dmgType.shieldbreak)
	end

	if msg.dot > 0 then
		mask = Or(mask, dmgType.dot)
	end

	if msg.damagePhy > 0 then
		mask = Or(mask, dmgType.phy)
	end

	if msg.damageMag > 0 then
		mask = Or(mask, dmgType.mag)
	end

	local key = GetPrefabKey(mask)
	local label = tostring(msg.minusHp)
	local tip = FloatTipUtil.Create(key, root)

	tip:SetNumText(label)
end
