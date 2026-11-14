-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/InfoGvg_PersistentData.lua

local mt = class("InfoGvg_PersistentData")

function mt:ctor()
	self.animPortalIdxs = {}
	self.animPortalStep = 1
	self.animPanel = false
	self.deadFlagList = {}
end

function mt:Refresh()
	local needAnim = false
	local animPortalIdxs = {}
	local previousActiveId = PersistentStoreUtil.GetInt("KEY_GVG_ID")

	if previousActiveId ~= Infogvg.stage.activeId then
		PersistentStoreUtil.SetInt("KEY_GVG_ID", Infogvg.stage.activeId)
		PersistentStoreUtil.SetInt("KEY_GVG_STEP", 1)
		PersistentStoreUtil.SetInt("KEY_GVG_RESETTIMES", 0)
		PersistentStoreUtil.SetList("KEY_GVG_PORTAL_RESETTIMES", {})
		PersistentStoreUtil.SetList("KEY_GVG_PORTAL_DEAD", {})
	end

	local previousStep = PersistentStoreUtil.GetInt("KEY_GVG_STEP")
	local previousResetTimes = PersistentStoreUtil.GetInt("KEY_GVG_RESETTIMES")
	local previousPortalResetTimes = PersistentStoreUtil.GetList("KEY_GVG_PORTAL_RESETTIMES")
	local previousPortalDeadTimes = PersistentStoreUtil.GetList("KEY_GVG_PORTAL_DEAD")
	local condition1 = previousStep < Infogvg.stage.curStep
	local _restTimes = Infogvg.stage.resetTimes[Infogvg.stage.curStep]
	local condition2 = Infogvg.stage.curStep == previousStep and previousResetTimes < _restTimes

	if condition1 == true or condition2 == true then
		needAnim = true
	end

	local _saveRefreshList = {}
	local _saveDeadList = {}
	local _refreshportalIdxList = {}
	local _portalIdxList = {}

	for i, portal in Infogvg.portal:Filter():IsStep(Infogvg.stage.curStep):Ipairs() do
		local stage = portal:Stages()[1]

		table.insert(_saveRefreshList, stage.refreshTimes)

		if Infogvg.stage.curStep == previousStep then
			if previousResetTimes < _restTimes then
				-- block empty
			elseif stage.refreshTimes ~= tonumber(previousPortalResetTimes[i]) then
				table.insert(animPortalIdxs, i)
			end

			local deadFlag = 0

			deadFlag = portal:Stage() and 0 or 1

			table.insert(_saveDeadList, deadFlag)

			if deadFlag == 1 and tonumber(previousPortalDeadTimes[i]) ~= 1 and not animPortalIdxs[i] then
				table.insert(animPortalIdxs, i)
			end
		end
	end

	PersistentStoreUtil.SetInt("KEY_GVG_STEP", Infogvg.stage.curStep)
	PersistentStoreUtil.SetInt("KEY_GVG_RESETTIMES", _restTimes)
	PersistentStoreUtil.SetList("KEY_GVG_PORTAL_RESETTIMES", _saveRefreshList)
	PersistentStoreUtil.SetList("KEY_GVG_PORTAL_DEAD", _saveDeadList)

	self.animPortalIdxs = animPortalIdxs
	self.animPortalStep = Infogvg.stage.curStep
	self.animPanel = needAnim
end

return mt
