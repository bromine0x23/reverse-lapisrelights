-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/infoGvg_Net.lua

require("Info/SetterData")

local mt = {}

function mt:Vaild()
	if Infogvg.offline then
		return false
	end

	if not Infogvg.union:GetUnionData() then
		return false
	end

	return true
end

function mt:RequestGvg(isOpenUI, isSyncLoad)
	if not self:Vaild() then
		return
	end

	NetManager:RequestGvg(function(pb)
		if pb.result.code ~= NetManager.Result_Sucess then
			UIMgr.ShowMsg(pb.result.desc)

			return
		end

		Infogvg.stage:SetPb(pb)
		Event.Instance:Fire("EVENT_GVG_REFRESH")

		if isOpenUI == true then
			UIMgr.SwitchPanel(DlgGvg, nil, nil, isSyncLoad)
		end
	end)
end

function mt:RequestBuy(uid)
	if not self:Vaild() then
		return
	end

	local spell = Infogvg.spell:Get(uid)

	if not spell then
		return
	end

	NetManager:RequestGvgBuyGoods(spell.goodsId, function(vMsg)
		if vMsg.result.code ~= NetManager.Result_Sucess then
			UIMgr.ShowMsg(vMsg.result.desc)

			return
		end

		UnionMgr:SetCoin(vMsg.clubCoin)
		self:RequestGvg()
	end, true)
end

function mt:DealWithGetAward(pbSetter, fromMail, flag, panelCb, tipStr)
	local setter = SetterData.GetSetterData(pbSetter)

	setter:Parse()

	local wrap_cb

	if SetterData.showLevelup then
		function wrap_cb()
			UIMgr.AddPanel(DlgProducerLevelUp(), {
				callback = panelCb
			})
		end
	else
		wrap_cb = panelCb
	end

	local listNormal = setter:Getlist(protocol_pb.AF_NORMAL)
	local listExtra = setter:Getlist(protocol_pb.AF_EXTRA_AWARD)

	if #listNormal > 0 or #listExtra > 0 then
		local data = {
			list = setter.list,
			callback = wrap_cb,
			fromMail = fromMail,
			flag = flag,
			tip = tipStr
		}

		if OperationActiveMgr.IsActiveCommon then
			OperationActiveMgr.IsActiveCommon = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
				TimerMgr.RemoveTimer(OperationActiveMgr.IsActiveCommon)

				OperationActiveMgr.IsActiveCommon = nil

				Event.Instance:Fire("DlgOperationActiveCommonOneCloseEvent")
				UIMgr.AddPanel(DlgGetAward.GetInstance(), data)
			end, nil)
		else
			UIMgr.AddPanel(DlgGetAward.GetInstance(), data)
		end
	end
end

function mt:RequestStageReward()
	if not self:Vaild() then
		return
	end

	local stageIds = {}

	for i, stage in ipairs(Infogvg.stage.stages) do
		for j = 1, stage.leftAwardTimes do
			table.insert(stageIds, stage.stageId)
		end
	end

	if #stageIds > 0 then
		NetManager:RequestGvgSetter({}, stageIds, function(pb)
			if pb.result.code == NetManager.Result_Sucess then
				local isConfirmBtn = true

				self:DealWithGetAward(pb.setter, false, "GVGSTAGE", function()
					Event.Instance:Fire("EVENT_GVG_REWARD_STAGE", stageIds)
				end)
			else
				Event.Instance:Fire("EVENT_GVG_REWARD_STAGE", {})
			end
		end, true)
	else
		Event.Instance:Fire("EVENT_GVG_REWARD_STAGE", {})
	end
end

function mt:RequestStepReward()
	if not self:Vaild() then
		return
	end

	local steps = {}

	for i, val in ipairs(Infogvg.stage.awardStatus) do
		if val ~= 0 then
			table.insert(steps, i)
		end
	end

	if #steps > 0 then
		NetManager:RequestGvgSetter(steps, {}, function(pb)
			if pb.result.code == NetManager.Result_Sucess then
				self:DealWithGetAward(pb.setter, false, "GVGSTEP", function()
					Event.Instance:Fire("EVENT_GVG_REWARD_STEP")
				end)
			else
				Event.Instance:Fire("EVENT_GVG_REWARD_STEP")
			end
		end, true)
	else
		Event.Instance:Fire("EVENT_GVG_REWARD_STEP")
	end
end

function mt:RequestReward(steps, stageIds)
	if not self:Vaild() then
		return
	end

	NetManager:RequestGvgSetter(steps, stageIds, function(vMsg)
		return
	end, true)
end

function mt:ResponseReward(vMsg)
	if vMsg.result.code == NetManager.Result_Sucess then
		-- block empty
	else
		UIMgr.ShowMsg(vMsg.result.desc)
	end
end

function mt:RequestRank()
	if not self:Vaild() then
		return
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestRank(DlgGvgRank.rankType, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Maintain then
			Event.Instance:Fire("EVENT_GVG_MAINTAIN")

			return
		elseif pb.result.code ~= NetManager.Result_Sucess then
			UIMgr.ShowMsg(pb.result.desc)

			return
		end

		Infogvg.rank:SetRankPb(pb)
	end)
end

function mt:RequestContribution()
	if not self:Vaild() then
		return
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGvgContribution(function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Maintain then
			Event.Instance:Fire("EVENT_GVG_MAINTAIN")

			return
		elseif pb.result.code ~= NetManager.Result_Sucess then
			UIMgr.ShowMsg(pb.result.desc)

			return
		end

		Infogvg.rank:SetContributionPb(pb)
	end)
end

function mt:RequestLog()
	if not self:Vaild() then
		return
	end

	NetManager:RequestGvgLogs(UnionMgr.releUnion.id, Infogvg.stage.activeId, function(pb)
		if pb.result.code ~= NetManager.Result_Sucess then
			UIMgr.ShowMsg(pb.result.desc)

			return
		end

		Infogvg.rank:SetGvgLogPb(pb)
	end)
end

function mt:RequestMembersAndLogs()
	if not self:Vaild() then
		return
	end

	NetManager:RequestUnionMembersAndLogs(function(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			Event.Instance:Fire("EVENT_GVG_MEMBER_AND_LOG")
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function mt:RequestHelpReward()
	NetManager:RequestGvgHelpAward(function(pb)
		if pb.result.code == NetManager.Result_Sucess then
			local tipStr

			if pb.helpTimes and type(pb.helpTimes) == "number" then
				tipStr = string.format(_("Desc_GvgHelpAwardTip"), pb.helpTimes)
			end

			self:DealWithGetAward(pb.setter, false, "GVGHELP", function()
				return
			end, tipStr)
		end
	end)
end

function mt:Init()
	if self.init then
		return
	end

	self.init = true
end

return mt
