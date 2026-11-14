-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/InfoGvg_Portal.lua

local mt = class("InfoGvg_Portal")
local item = class("InfoGvg_Portal_Item")
local _filter = require("Util.EasyFilter")

function mt:ctor()
	self.activeId = -1
	self.portals = {}
	self.filter = _filter(self.portals)

	self:SetFilter()
end

function mt:Purge()
	if self.filter then
		self.filter:Purge()

		self.filter = nil
	end

	for i = #self.portals, 1, -1 do
		local item = table.remove(self.portals, i)

		item:Purge()
	end

	self.portals = {}
end

function mt:Get(step, portalIdx)
	return Infogvg.portal:Filter():IsStep(step):IsPortal(portalIdx):Get()[1]
end

function mt:Stages(step, portalIdx)
	return self:Get(step, portalIdx):Stages()
end

function mt:InitPortalItem(stepIdx, stageIdx)
	local cfg = Infogvg.cfg:MaxPortal()
	local maxPortal = cfg[stepIdx]
	local obj

	if maxPortal and maxPortal < stageIdx then
		obj = self.portals[#self.portals]
	else
		obj = item()
		obj.portalIdx = stageIdx

		table.insert(self.portals, obj)

		obj.order = #self.portals
		obj.stepIdx = stepIdx
	end

	return obj
end

function mt:SetFilter()
	function self.filter:IsStep(idx)
		return self:AddFilter(function(dest)
			return dest.stepIdx == idx
		end)
	end

	function self.filter:IsPortal(idx)
		return self:AddFilter(function(dest)
			return dest.portalIdx == idx
		end)
	end
end

function mt:Filter()
	return self.filter:Reset()
end

function item:ctor()
	self.stepIdx = 0
	self.portalIdx = 0
	self.order = 0
	self.stageUids = {}
end

function item:Purge()
	return
end

function item:AddStageUid(uid)
	table.insert(self.stageUids, uid)
end

function item:Stages()
	local stages = {}

	for i, uid in ipairs(self.stageUids) do
		table.insert(stages, Infogvg.stage:Get(uid))
	end

	return stages
end

function item:Stage()
	local targetStage

	for i, uid in ipairs(self.stageUids) do
		local stage = Infogvg.stage:Get(uid)

		if stage:IsComplete() == false and stage:IsLock() == false then
			targetStage = stage

			break
		end
	end

	return targetStage
end

return mt
