-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/EffectMgr.lua

EffectMgr = {}

local _effectCfg = require("luaData/EffectData")

function EffectMgr:LoadAeestRef(path)
	return ResourceMgr.LoadSync(path, GameObject)
end

function EffectMgr:AllocById(effectId, goParent)
	local cfg = _effectCfg[effectId]

	if not cfg then
		print("EffectMgr:AllocId ERROR !!!! not found in EffectData  id = " .. effectId)

		return nil
	end

	local soundEvent = cfg.SoundEvent

	if soundEvent and soundEvent ~= "" then
		SoundMgr.PostEvent(soundEvent, goParent.gameObject)
	end

	local path = cfg.Prefab
	local life = cfg.Life

	if not self.Map then
		self.Map = {}
	end

	if life == 0 then
		life = 1
	end

	local handle = self:Alloc(path, goParent, true, life)

	if handle == nil then
		return nil
	end

	self.Map[handle] = cfg

	return handle
end

function EffectMgr:AllocAtById(effectId, position, _rotation, scale)
	local cfg = _effectCfg[effectId]

	if not cfg then
		print("EffectMgr:AllocId ERROR !!!! not found in EffectData  id = " .. tostring(effectId))

		return nil
	end

	local soundEvent = cfg.SoundEvent

	if soundEvent and soundEvent ~= "" then
		SoundMgr.PostEvent(soundEvent, nil)
	end

	local path = cfg.Prefab
	local life = cfg.Life

	if not self.Map then
		self.Map = {}
	end

	if life == 0 then
		life = 1
	end

	local handle = self:AllocAt(path, position, _rotation, true, life, scale)

	if handle == nil then
		return nil
	end

	self.Map[handle] = cfg

	return handle
end

function EffectMgr:CacheId(effectId)
	local cfg = _effectCfg[effectId]

	if not cfg then
		print("EffectMgr:CacheId ERROR !!!! not found in EffectData  id = " .. effectId)

		return
	end

	local path = cfg.Prefab

	EffectMgr:Cache(path)
end

function EffectMgr:AllocAt(path, position, _rotation, flag, duration, scale)
	if self["EffCache" .. path] == nil then
		self["EffCache" .. path] = self:LoadAeestRef(path)
	end

	if self["EffCache" .. path] == nil then
		print("<color=red> 错误！ 特效不存在于项目中， 检查路径：" .. path .. "</color>")

		return nil
	end

	if duration == nil then
		duration = -1
	end

	if scale and _rotation then
		return EffectManager.Alloc(self["EffCache" .. path], position, _rotation, scale, duration)
	end

	if scale then
		return EffectManager.Alloc(self["EffCache" .. path], position, scale, duration)
	end

	if _rotation then
		return EffectManager.Alloc(self["EffCache" .. path], position, _rotation, duration)
	end

	return EffectManager.Alloc(self["EffCache" .. path], position, duration)
end

function EffectMgr:Alloc(path, goParent, flag, duration)
	if self["EffCache" .. path] == nil then
		self["EffCache" .. path] = self:LoadAeestRef(path)
	end

	if self["EffCache" .. path] == nil then
		print("<color=red> 错误！ 特效不存在于项目中， 检查路径：" .. path .. "</color>")

		return nil
	end

	if duration == nil then
		duration = -1
	end

	return EffectManager.Alloc(self["EffCache" .. path], goParent.transform, duration), self["EffCache" .. path]
end

function EffectMgr:Free(handle)
	if handle ~= nil then
		if self.Map then
			local curCfg = self.Map[handle]

			if curCfg and curCfg.SoundEvent and curCfg.SoundEvent ~= "" then
				SoundMgr.ExecuteActionOnEvent(curCfg.SoundEvent, AkActionOnEventType.AkActionOnEventType_Stop)
			end
		end

		EffectManager.Free(handle)
	end
end

function EffectMgr:DelayFree(handle)
	if handle ~= nil and self.Map then
		local curCfg = self.Map[handle]

		if curCfg then
			if curCfg.SoundEvent and curCfg.SoundEvent ~= "" then
				SoundMgr.ExecuteActionOnEvent(curCfg.SoundEvent, AkActionOnEventType.AkActionOnEventType_Stop)
			end

			if curCfg.DelayFree == 0 then
				EffectManager.Free(handle)
			else
				EffectManager.DelayFree(handle, curCfg.DelayFree)
			end
		else
			EffectManager.DelayFree(handle)
		end
	end
end

function EffectMgr:Clear()
	EffectManager.Clear()

	for k, v in pairs(self) do
		if k ~= "Alloc" and k ~= "Free" and k ~= "Clear" and k ~= "Cache" and k ~= "AllocById" and k ~= "CacheId" and k ~= "DelayFree" and k ~= "AllocAtById" and k ~= "AllocAt" and k ~= "Prewarm" and k ~= "PreLoad" and k ~= "LoadAeestRef" and k ~= "UnLoadEffect" then
			self[k] = nil
		end
	end
end

function EffectMgr:PreLoad(path, count)
	local strPath = "EffCache" .. path

	self[strPath] = self:LoadAeestRef(strPath)

	if not self.PreWarmMap then
		self.PreWarmMap = {}
	end

	self.PreWarmMap[path] = count
end

function EffectMgr:Cache(path, count)
	ResourceMgr.SubmitCache(path, self, "EffCache" .. path, GameObject)

	if not self.PreWarmMap then
		self.PreWarmMap = {}
	end

	self.PreWarmMap[path] = count
end

function EffectMgr:Prewarm(path, count)
	if self["EffCache" .. path] then
		EffectManager.Prewarm(self["EffCache" .. path], count)
	else
		print("Prewarm ERROR , path = " .. path)
	end
end

function EffectMgr:UnLoadEffect(path)
	if self["EffCache" .. path] then
		ResourceMgr.Unload(self["EffCache" .. path])

		self["EffCache" .. path] = nil
	end
end
