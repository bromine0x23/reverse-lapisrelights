-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/GameMessage.lua

local json = require("GameLogic.Util.json4lua")
local print_enable = false
local print = function(...)
	if print_enable == true then
		print(...)
	end
end

GameMessage = class("GameMessage", nil, true)

function GameMessage:ctor(GP)
	self.GP = GP

	self:Reset()
	self:ResigterMsgAction()
end

function GameMessage:Reset()
	self.RecordingList = {}
	self.CurRecording = nil
	self.MsgActionMap = {}
end

function GameMessage:Register()
	Event.Instance:Add("GameRecording", self.GameRecording, self)
end

function GameMessage:UnRegister()
	Event.Instance:Remove("GameRecording", self.GameRecording, self)
end

function GameMessage:Start()
	self:Register()
end

function GameMessage:End()
	self:UnRegister()
	self:Reset()
end

function GameMessage:GameRecording(msg)
	if msg.eventId == "阶段-改变" then
		print(EnumFight.GameStageStr(msg.lastStage) .. "  ->  " .. EnumFight.GameStageStr(msg.stage))

		if #self.RecordingList == 1 and msg.lastStage ~= EnumFight.GameState.READY then
			self:Excute()
		end

		self:CreateStageRecord(msg)
	end

	if self.CurRecording then
		if self.CurRecording.Stage == EnumFight.GameState.OPERATOR_WAIT and self.GP.GameStage == EnumFight.GameState.OPERATOR_WAIT then
			self:DoMsgAction(msg.eventId, msg)
		elseif self.CurRecording.Stage == EnumFight.GameState.DEBUG and self.GP.GameStage == EnumFight.GameState.OPERATOR_WAIT then
			self:DoMsgAction(msg.eventId, msg)
		elseif self.CurRecording.Stage == EnumFight.GameState.DEBUG and self.GP.GameStage == EnumFight.GameState.GAMEOVER then
			self:DoMsgAction(msg.eventId, msg)
		else
			self.CurRecording:GameRecording(msg)
		end
	else
		print("error 不应该进这里 ")
	end
end

function GameMessage:CreateStageRecord(msg)
	local record

	if msg.stage == EnumFight.GameState.INIT then
		-- block empty
	elseif msg.stage == EnumFight.GameState.READY_END or msg.stage == EnumFight.GameState.NEWWAVE then
		record = StageNewWave(self.GP)
	elseif msg.stage == EnumFight.GameState.READY then
		record = StageReady(self.GP)
	elseif msg.stage == EnumFight.GameState.NORMAL then
		record = StageNormal(self.GP)
	elseif msg.stage == EnumFight.GameState.OPERATOR_WAIT then
		-- block empty
	elseif msg.stage == EnumFight.GameState.PLAYER_CARD then
		record = StageDoCard(self.GP)
	elseif msg.stage == EnumFight.GameState.APPEAR_SKILL then
		record = StageAppearSkill(self.GP)
	elseif msg.stage == EnumFight.GameState.PLAYER_SESSION then
		record = StageSession(self.GP)
	elseif msg.stage == EnumFight.GameState.ENEMY_ACTION then
		record = StageEnemyAction(self.GP)
	elseif msg.stage == EnumFight.GameState.ERROR then
		-- block empty
	elseif msg.stage == EnumFight.GameState.WARN then
		-- block empty
	elseif msg.stage == EnumFight.GameState.DEBUG then
		-- block empty
	elseif msg.stage == EnumFight.GameState.GAMEOVER then
		-- block empty
	end

	if record == nil then
		record = StageRecordBase(self.GP)
	end

	table.insert(self.RecordingList, record)
	record:SetCurStage(msg.stage)

	self.CurRecording = record
end

function GameMessage:Excute()
	if not self.CurRecording then
		return
	end

	local record = self.RecordingList[1]

	if not record then
		print("<color=red> *********** 消息列表执行完了 *********** 上一个状态:" .. EnumFight.GameStageStr(self.CurRecording.Stage) .. " </color>")

		return
	else
		print("<color=red> *********** 开始执行 *********** 当前状态:" .. EnumFight.GameStageStr(record.Stage) .. " </color>")
	end

	self.GP.GameStage = record.Stage

	if record.Stage ~= EnumFight.GameState.OPERATOR_WAIT then
		Event.Instance:Fire("GameChageStage", self.GP.GameStage)
	end

	if record.Stage == EnumFight.GameState.INIT then
		self:DoDefaultAction(record)
		table.remove(self.RecordingList, 1)
	elseif record.Stage == EnumFight.GameState.READY then
		record:Excute()
	elseif record.Stage == EnumFight.GameState.READY_END then
		record:Excute()
	elseif record.Stage == EnumFight.GameState.NEWWAVE then
		record:Excute()
	elseif record.Stage == EnumFight.GameState.NORMAL then
		record:Excute()
	elseif record.Stage == EnumFight.GameState.OPERATOR_WAIT then
		if self.GP.PVPMode == true then
			self.GP.CameraUtil:EnablePVPCamear(true)
			self.GP.UI.DlgUIRoundTip:Open(function()
				Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
				Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true, function()
					Event.Instance:Fire("GameChageStage", self.GP.GameStage)
					self:DoDefaultAction(record)
					self:ExcuteEnd()
				end)
			end, EnumFight.Camp.PLAYER)
		else
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true, function()
				Event.Instance:Fire("GameChageStage", self.GP.GameStage)
				self:DoDefaultAction(record)
				self:ExcuteEnd()
			end)
		end
	elseif record.Stage == EnumFight.GameState.APPEAR_SKILL then
		record:Excute()
	elseif record.Stage == EnumFight.GameState.PLAYER_CARD then
		record:Excute()
	elseif record.Stage == EnumFight.GameState.PLAYER_SESSION then
		record:Excute()
	elseif record.Stage == EnumFight.GameState.ENEMY_ACTION then
		record:Excute()
	elseif record.Stage == EnumFight.GameState.DEBUG then
		self:DoDefaultAction(record)
		BattleConfig.Delay(0.1, function()
			self:ExcuteEnd()
		end)
	elseif record.Stage == EnumFight.GameState.GAMEOVER then
		self:DoDefaultAction(record)
		self:ExcuteEnd()
	else
		print("<color=red> " .. EnumFight.GameStageStr(record.Stage) .. " 未实现 走默认方法</color>")
		self:DoDefaultAction(record)
		self:ExcuteEnd()
	end
end

function GameMessage:ExcuteEnd()
	if #self.RecordingList >= 1 then
		table.remove(self.RecordingList, 1)
		self:Excute()
	end
end

function GameMessage:GetRecordingList()
	return self.RecordingList
end

function GameMessage:DebugRecording()
	local record = self.RecordingList[1]

	if not record then
		return "no record"
	end

	local str = EnumFight.GameStageStr(record.Stage)

	for i, msg in ipairs(record.MsgList) do
		str = str .. msg.eventId .. "\n"
	end

	print("record : " .. str)

	return str
end

function GameMessage:DoDefaultAction(record)
	for i, msg in ipairs(record.MsgList) do
		self:DoMsgAction(msg.eventId, msg)
	end
end

function GameMessage:ResigterMsgAction()
	self:AddAction("召唤单位-准备创建", self.GP.SummonUnitReady, self.GP)
	self:AddAction("单位-准备创建", self.GP.UnitReady, self.GP)
	self:AddAction("创建战斗", self.GP.CreateFight, self.GP)
	self:AddAction("单位-创建", self.GP.UnitCreate, self.GP)
	self:AddAction("召唤单位-创建", self.GP.SummonUnitCreate, self.GP)
	self:AddAction("单位-准备立即创建", self.GP.UnitCreateReadyImmediately, self.GP)
	self:AddAction("单位-立即创建", self.GP.UnitCreateImmediately, self.GP)
	self:AddAction("单位-更新属性", self.GP.UnitUpdateAttri, self.GP)
	self:AddAction("队伍-更新属性", self.GP.TeamUpdateAttri, self.GP)
	self:AddAction("阶段-改变", self.GP.ChangeStage, self.GP, true)
	self:AddAction("更新回合", self.GP.RefreshRound, self.GP)
	self:AddAction("更新波数", self.GP.RefreshWave, self.GP)
	self:AddAction("更新回合Session", self.GP.RefreshRoundSession, self.GP)
	self:AddAction("更新回合Card", self.GP.RefreshRoundCard, self.GP)
	self:AddAction("建议选球", self.GP.SuggestSession, self.GP)
	self:AddAction("卡牌释放", self.GP.DoCard, self.GP)
	self:AddAction("卡牌清除", self.GP.ClearCard, self.GP)
	self:AddAction("行动开始", self.GP.SessionCutIn, self.GP)
	self:AddAction("单位-销毁", self.GP.UnitDestroy, self.GP)
	self:AddAction("单位-移动", self.GP.UnitMove, self.GP)
	self:AddAction("更新连击", self.GP.UpdateCombo, self.GP)
	self:AddAction("单位-怒气buff", self.GP.UnitAngryBuffCast, self.GP)
	self:AddAction("单位-受到伤害", self.GP.UnitDealDamage, self.GP)
	self:AddAction("单位-受到治疗", self.GP.UnitHealHp, self.GP)
	self:AddAction("单位-回复魔力", self.GP.UnitForceMp, self.GP)
	self:AddAction("单位-回复护盾", self.GP.AddShield, self.GP)
	self:AddAction("单位-回复怒气", self.GP.AddAngry, self.GP)
	self:AddAction("单位-添加buff", self.GP.UnitAddBuff, self.GP)
	self:AddAction("单位-移除buff", self.GP.UnitRemoveBuff, self.GP)
	self:AddAction("单位-无法行动", self.GP.UnitNotAction, self.GP)
	self:AddAction("单位-闪避", self.GP.UnitMissing, self.GP)
	self:AddAction("单位-封印卡牌技能", self.GP.UnitDisableCardSkill, self.GP)
	self:AddAction("技能-更新强化层数", self.GP.SkillUpdateStackPower, self.GP)
	self:AddAction("游戏-结束", self.GP.GameOver, self.GP)
	self:AddAction("锁定目标", self.GP.SelectTarget, self.GP)
	self:AddAction("预览技能目标", self.GP.SkillPreviewTargets, self.GP)
	self:AddAction("单位-随机技能", self.GP.UnitRandomSkill, self.GP)
	self:AddAction("单位-更新buff", self.GP.UnitUpdateBuff, self.GP)
	self:AddAction("单位-buff叠层数", self.GP.UnitBuffStack, self.GP)
	self:AddAction("单位-buff同步数据", self.GP.UpdateBuffData, self.GP)
	self:AddAction("单位-死亡", self.GP.UnitDie, self.GP)
	self:AddAction("单位-复活", self.GP.UnitReborn, self.GP)
	self:AddAction("单位-添加buff失败", self.GP.UnitAddBuffFail, self.GP)
	self:AddAction("单位-Buff自定义消息", self.GP.UnitBuffCutomMsg, self.GP)
	self:AddAction("技能-飘字", self.GP.SkillFloatTip, self.GP)
	self:AddAction("鞭尸", self.GP.Whipped, self.GP)
	self:AddAction("鞭尸掉落", self.GP.WhippedDrop, self.GP)
	self:AddAction("游戏-操作记录", self.GP.GameOperatorRecord, self.GP)
	self:AddAction("游戏-数据统计", self.GP.GameResultData, self.GP)
	self:AddAction("选择卡牌", self.GP.PickCard, self.GP)
	self:AddAction("单位-添加特效", self.GP.UnitAttachFx, self.GP)
	self:AddAction("单位-添加UI特效", self.GP.UnitAttachUIFx, self.GP)
	self:AddAction("单位-添加Icon特效", self.GP.UnitAttachIconFx, self.GP)
end

function GameMessage:AddAction(eventId, fun, obj)
	if not self.MsgActionMap[eventId] then
		self.MsgActionMap[eventId] = {}
		self.MsgActionMap[eventId].Action = fun
		self.MsgActionMap[eventId].Object = obj
	end
end

function GameMessage:DoMsgAction(eventId, ...)
	local val

	if self.MsgActionMap[eventId] then
		local fun = self.MsgActionMap[eventId].Action
		local obj = self.MsgActionMap[eventId].Object

		val = fun(obj, ...)
	else
		print("<color=red>" .. eventId .. " 未处理</color>")
	end

	return val
end
