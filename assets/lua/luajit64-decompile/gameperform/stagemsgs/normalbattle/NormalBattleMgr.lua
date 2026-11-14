-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/NormalBattle/NormalBattleMgr.lua

NormalBattleMgr = class("NormalBattleMgr")

function NormalBattleMgr:ctor(GP)
	self.GP = GP
	self.actions = {}
	self.lastCamp = 0
end

function NormalBattleMgr:Create(data)
	self.lastCamp = 0

	if self.GP.Pvp ~= EnumFight.Pvp.NONE then
		self.GP.Team:SetActive(EnumFight.Camp.ENEMY, true)
	end

	local actionData

	for i, msg in ipairs(data) do
		if msg.eventId == "阶段-改变" then
			-- block empty
		elseif msg.eventId == "选球" then
			-- block empty
		elseif msg.eventId == "行动开始" then
			if actionData ~= nil then
				local actionNode = NormalBattleAction(self.GP, self)

				actionNode:Create(actionData)
				table.insert(self.actions, actionNode)
			end

			actionData = {}

			table.insert(actionData, msg)
		elseif actionData ~= nil then
			table.insert(actionData, msg)
		else
			self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
		end
	end

	if actionData ~= nil then
		local actionNode = NormalBattleAction(self.GP, self)

		actionNode:Create(actionData)
		table.insert(self.actions, actionNode)
	end

	for i, actionNode in ipairs(self.actions) do
		actionNode:SetActionIdx(i, #self.actions)
	end
end

function NormalBattleMgr:Play(complete)
	self.complete = complete

	self:Next()
end

function NormalBattleMgr:Next()
	if #self.actions > 0 then
		local actionNode = table.remove(self.actions, 1)

		if self.GP.PVPMode == true and self.GP.RoundData.CurRound ~= nil then
			local camp = UnitActor.FindUnitById(actionNode.groupData.uniqueIds[1]).Camp

			if self.lastCamp ~= camp then
				self.lastCamp = camp

				if camp == 1 then
					-- block empty
				elseif camp == 2 then
					BattleConfig.Delay(BattleConfig.PVPActorFxExitDelay + 0.5, function()
						self.GP.CameraUtil:EnablePVPCamear(true)
						self.GP.UI.DlgUIRoundTip:Open(function()
							actionNode:Play(function()
								self:Next()
							end)
						end, camp)
					end)

					return
				end
			end

			if camp == 2 then
				if actionNode.groupData.groupIdx == 1 and actionNode.groupData.sessionType ~= 0 then
					self.GP.CameraUtil:EnablePVPCamear(true)
				end
			else
				self.GP.CameraUtil:EnablePVPCamear(false)
			end
		end

		actionNode:Play(function()
			self:Next()
		end)
	elseif self.GP.PVPMode == true then
		BattleConfig.Delay(BattleConfig.PVPActorFxExitDelay + 0.5, self.complete)
	else
		self.complete()
	end
end

function NormalBattleMgr:Dispose()
	for i, v in ipairs(self.actions) do
		v:Dispose()
	end
end
