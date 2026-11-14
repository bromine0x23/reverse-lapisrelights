-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellHeadTipOnIcon.lua

CellHeadTipOnIcon = class("CellHeadTipOnIcon")

local _BuffData = require("luaData/BattleBuffData")

function CellHeadTipOnIcon:ctor(uniqueId, root)
	self:Reset()
	self:OnRegisterEvent()
end

function CellHeadTipOnIcon:Reset()
	self.Owner = nil
	self.UniqueId = nil
	self.roleIconEffRoot = nil
	self.UIFxHandles = {}
end

function CellHeadTipOnIcon:Purge()
	self:OnUnRegisterEvent()

	for k, v in pairs(self.UIFxHandles) do
		for i, handle in ipairs(v) do
			EffectMgr:Free(handle)
		end

		self.UIFxHandles[k] = nil
	end

	self:Reset()
end

function CellHeadTipOnIcon:OnRegisterEvent()
	Event.Instance:Add("AddBuff", self.OnAddBuff, self)
	Event.Instance:Add("RemoveBuff", self.OnRemoveBuff, self)
	Event.Instance:Add("OnBuffExe", self.OnBuffExe, self)
	Event.Instance:Add("UnitDealDamage", self.OnUnitDealDamage, self)
	Event.Instance:Add("UnitHealHp", self.OnUnitHealHp, self)
	Event.Instance:Add("AddShield", self.OnUnitAddShield, self)
	Event.Instance:Add("UnitMissing", self.UnitMissing, self)
	Event.Instance:Add("BuffMiss", self.OnBuffMiss, self)
	Event.Instance:Add("IconFx", self.OnIconFx, self)
end

function CellHeadTipOnIcon:OnUnRegisterEvent()
	Event.Instance:Remove("AddBuff", self.OnAddBuff, self)
	Event.Instance:Remove("RemoveBuff", self.OnRemoveBuff, self)
	Event.Instance:Remove("OnBuffExe", self.OnBuffExe, self)
	Event.Instance:Remove("UnitDealDamage", self.OnUnitDealDamage, self)
	Event.Instance:Remove("UnitHealHp", self.OnUnitHealHp, self)
	Event.Instance:Remove("AddShield", self.OnUnitAddShield, self)
	Event.Instance:Remove("UnitMissing", self.UnitMissing, self)
	Event.Instance:Remove("BuffMiss", self.OnBuffMiss, self)
	Event.Instance:Remove("IconFx", self.OnIconFx, self)
end

function CellHeadTipOnIcon:Bind(uniqueId, root)
	local unit = UnitActor.FindUnitById(uniqueId)

	if not unit then
		return
	end

	self.UniqueId = uniqueId
	self.Owner = unit
	self.roleIconEffRoot = root
end

function CellHeadTipOnIcon:ClearData()
	self.Owner = nil
	self.UniqueId = nil

	self:Show(false)
end

function CellHeadTipOnIcon:OnAddBuff(uniqueId, buffId, buffUid)
	if self.UniqueId ~= uniqueId then
		return
	end

	if not _BuffData[buffId] then
		return
	end

	local fxs = _BuffData[buffId].UIFxsOnIcon

	self.UIFxHandles[tostring(self.buffUid)] = self.UIFxHandles[tostring(self.buffUid)] or {}

	for i, fx in ipairs(fxs) do
		local handle = EffectMgr:AllocById(fx, self.roleIconEffRoot)

		table.insert(self.UIFxHandles[tostring(self.buffUid)], handle)
	end
end

function CellHeadTipOnIcon:OnRemoveBuff(uniqueId, buffId, buffUid)
	if self.UniqueId ~= uniqueId then
		return
	end

	local handles = self.UIFxHandles[tostring(self.buffUid)]

	if handles then
		for i, handle in ipairs(handles) do
			EffectMgr:Free(handle)
		end
	end
end

function CellHeadTipOnIcon:OnBuffExe(uniqueId, buffId, buffUid)
	if self.UniqueId ~= uniqueId then
		return
	end

	if not _BuffData[buffId] then
		return
	end

	local fxs = _BuffData[buffId].UIExeFxsOnIcon

	self.UIFxHandles[tostring(self.buffUid)] = self.UIFxHandles[tostring(self.buffUid)] or {}

	for i, fx in ipairs(fxs) do
		local handle = EffectMgr:AllocById(fx, self.roleIconEffRoot)

		table.insert(self.UIFxHandles[tostring(self.buffUid)], handle)
	end
end

function CellHeadTipOnIcon:OnBuffMiss(uid, reason)
	if uid ~= self.UniqueId then
		return
	end

	local effid = 0

	effid = reason == EnumFight.BuffMissReason.Useless and 90089 or 90088

	EffectMgr:AllocById(effid, self.roleIconEffRoot)
end

function CellHeadTipOnIcon:OnUnitDealDamage(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	if msg.dmgType ~= EnumFight.DamageType.Dot then
		EffectMgr:AllocById(FloatEffConfig.DmgTip, self.roleIconEffRoot)
	end
end

function CellHeadTipOnIcon:OnUnitHealHp(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	EffectMgr:AllocById(FloatEffConfig.HealTip, self.roleIconEffRoot)
end

function CellHeadTipOnIcon:OnUnitAddShield(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	if msg.addShield > 0 then
		EffectMgr:AllocById(FloatEffConfig.AddShieldTip, self.roleIconEffRoot)
	end
end

function CellHeadTipOnIcon:UnitMissing(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	EffectMgr:AllocById(FloatEffConfig.MissingTip, self.roleIconEffRoot)
end

function CellHeadTipOnIcon:OnIconFx(msg)
	if self.UniqueId ~= msg.uniqueId then
		return
	end

	EffectMgr:AllocById(msg.fx, self.roleIconEffRoot)
end
