-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/SystemMaintainMgr.lua

SystemMaintainMgr = {}

local SystemToProtocol = {
	pvp = 200,
	task = 60,
	work = 25,
	mail = 80,
	recruit = 100,
	operation = 132
}

SystemMaintainType = {
	pvp = "pvp",
	task = "task",
	work = "work",
	mail = "mail",
	recruit = "recruit",
	operation = "operation"
}

function SystemMaintainMgr:Init(protocols)
	if protocols == nil then
		return
	end

	self.preMaintainSystems = self.maintainSystems
	self.maintainSystems = protocols

	if self.preMaintainSystems ~= nil then
		self:DealDifferentSystem()
	end
end

function SystemMaintainMgr:IsSystemMaintenance(system_type)
	if self.maintainSystems == nil then
		return false
	end

	if system_type == nil then
		return false
	end

	return self:DealWithData(system_type)
end

function SystemMaintainMgr:DealWithData(system_type)
	local id = SystemToProtocol[system_type]

	if not id then
		return false
	end

	for _, v in ipairs(self.maintainSystems) do
		if v.id == id then
			return true
		end
	end

	return false
end

function SystemMaintainMgr:DealDifferentSystem()
	local dirty = {}
	local isExist = false

	for k, v in ipairs(self.preMaintainSystems) do
		isExist = false

		for i, j in ipairs(self.maintainSystems) do
			if j.id == v.id then
				isExist = true
			end
		end

		if not isExist then
			table.insert(dirty, v.id)
		end
	end

	for _, v in ipairs(dirty) do
		if v == SystemToProtocol.work then
			NetManager:RequestGetWorks(function(vMsg)
				if vMsg.result.code == NetManager.Result_Sucess then
					NotificationMgr:ChangeSetting(eNotificationType.CompleteWork)
				end
			end)
		elseif v == SystemToProtocol.task then
			NetManager:RequestTaskList(function()
				InfoGameInst:TipWindowAdsListSort()
			end)
		elseif v == SystemToProtocol.mail then
			NetManager:RequestGetMails(1, 0, function()
				return
			end)
		elseif v == SystemToProtocol.operation then
			NetManager:RequestActiveOperates(nil, function(vMsg)
				if vMsg.result.code == NetManager.Result_Sucess then
					OperationActiveMgr:SetData(vMsg.activeOperates)
					OperationRDL.Init()
					CalendarRDL.Init()
				end
			end)
		end
	end
end

function SystemMaintainMgr:Deal(system_type, showDig, showMsg)
	local state = self:IsSystemMaintenance(system_type)

	if state then
		if showDig then
			ShowFuncForbidDialog()
		elseif showMsg then
			UIMgr.ShowMsg(_("Desc_FuncFobid"))
		end
	end

	return state
end
