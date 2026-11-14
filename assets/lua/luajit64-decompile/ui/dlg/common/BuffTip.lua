-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/BuffTip.lua

local BuffData = require("luaData/BattleBuffData")

BuffTip = class("BuffTip", UIPanel)

function BuffTip:ctor()
	BuffTip.base.ctor(self, "UI/CommonTip/BuffTip/BuffTip")

	self.closed = true
end

function BuffTip:OnEnter(vParam)
	self.itemSource = self:GetChildGameObject("Item")
	self.items = {}

	self:CreateItem(self.itemSource)
	self:Open(unpack(vParam))
end

function BuffTip:Open(buffs, scenePos, offset)
	if #buffs == 0 then
		return
	end

	self.buffs = buffs

	local createCount = #buffs - #self.items

	if createCount > 0 then
		for i = 1, createCount do
			local obj = GOUtil.InstantiateUI(self.itemSource, self.UIRootObject)

			self:CreateItem(obj)
		end
	end

	self:UpdateAllItem()

	local parentGo = self.UIRootObject.transform.parent.gameObject

	if offset ~= nil then
		self.UIRootObject.transform.localPosition = UIUtil.GetTipsPos(parentGo, scenePos, self.UIRootObject, offset)
	else
		self.UIRootObject.transform.localPosition = UIUtil.GetTipsPos(parentGo, scenePos, self.UIRootObject)
	end
end

function BuffTip:CreateItem(obj)
	local item = BuffTipItem(obj)

	table.insert(self.items, item)
end

function BuffTip:UpdateAllItem()
	local totalCount = #self.buffs

	for i, buff in ipairs(self.buffs) do
		local item = self.items[i]

		item:Update(buff, i < totalCount)
	end
end

function BuffTip:Hide()
	self:Close()

	if self.items then
		for i, item in ipairs(self.items) do
			UnloadAllImageSprite(item)
		end
	end

	self.buffs = {}
end

BuffTipItem = class("BuffTipItem")

function BuffTipItem:ctor(obj)
	self.uiRoot = obj

	self:Hide()

	self.icon = GOUtil.FindChildComponent(self.uiRoot, "Icon", "Image")
	self.desc = GOUtil.FindChildComponent(self.uiRoot, "TxtDesc", "Text")
	self.line = GOUtil.FindChildComponent(self.uiRoot, "Line", "Image")
end

function BuffTipItem:Update(buff, showLine)
	UIUtil.SetImageSprite(self.icon, buff.IconPath, self)

	self.desc.text = BuffTip.GetDesc(buff.BuffId, buff.skillPower, buff.remainRound, false, 0, buff.Stack, buff.LogicData)

	self.uiRoot:SetActive(true)

	self.line.enabled = showLine
end

function BuffTipItem:Hide()
	self.uiRoot:SetActive(false)
end

function BuffTip.GetDesc(buffId, skillPower, remainRound, showTotalRound, mainDescIndex, buffStack, logicData)
	if skillPower <= 0 then
		skillPower = 1
	end

	local mainDescEx = ""

	if mainDescIndex == 1 then
		mainDescEx = "Skill"
	elseif mainDescIndex == 2 then
		mainDescEx = "PR"
	end

	local buffCfg = BuffData[buffId]
	local key = ""

	print(mainDescEx)

	if buffCfg.TypeOrder ~= "" then
		key = "TypeOrder" .. mainDescEx .. "_" .. buffCfg.TypeOrder

		if buffCfg.Type == "Dot_Buff" then
			key = key .. "_" .. buffCfg.Type
		end
	else
		key = "Type" .. mainDescEx .. "_" .. buffCfg.Type
	end

	local desc = _(key)

	if string.find(desc, "{BuffCustom}") ~= nil then
		local BuffCustom = TenaryOp(buffCfg.Custom.Attri ~= nil, buffCfg.Custom.Attri, buffCfg.Custom[1])

		desc = string.gsub(desc, "{BuffCustom}", _("BuffCustom_" .. BuffCustom))
	end

	if string.find(key, "Attri") ~= nil and string.find(key, "Shield") == nil and buffCfg.Custom.StartAnd == nil and buffCfg.Custom.StartOr == nil and (key == "Type_Add_Attri_Per_Ex" or key == "Type_Add_Attri_Val" or key == "Type_Add_Attri_Val_Ex" or key == "TypeSkill_Add_Attri_Per_Ex" or key == "TypeSkill_Add_Attri_Val" or key == "TypeSkill_Add_Attri_Val_Ex" or key == "TypeSkill_Reduce_Attri_Per_Ex") then
		local ta = GetListObjByIndex(buffCfg.Custom.WeightMulVal, 1)
		local min = ta.Min
		local max = ta.Max
		local separator = _("BuffDesc_Separator")

		if showTotalRound and buffCfg.Round > 0 then
			local totalRoundDesc = _("TotalRoundDesc")

			totalRoundDesc = string.gsub(totalRoundDesc, "{Round}", buffCfg.Round)
			desc = desc .. separator .. totalRoundDesc
		end

		desc = string.gsub(desc, "{Min}", min * 100 .. "%%")

		return string.gsub(desc, "{Max}", max * 100 .. "%%")
	end

	if buffCfg.Custom.Weight ~= nil then
		key = key .. "_Random"
	end

	print(buffCfg.ID .. " " .. key .. " " .. desc)

	if string.find(key, "Random") ~= nil then
		local ta = GetListObjByIndex(buffCfg.Custom.WeightMulVal, 1)
		local min = ta.Min
		local max = ta.Max
		local value = buffCfg.Value * skillPower
		local valueStr = value .. ""

		if buffCfg.ValueType == 0 then
			valueStr = value * 100 .. "%%"
		end

		desc = string.gsub(desc, "{Value}", valueStr)

		local separator = _("BuffDesc_Separator")

		if showTotalRound and buffCfg.Round > 0 then
			local totalRoundDesc = _("TotalRoundDesc")

			totalRoundDesc = string.gsub(totalRoundDesc, "{Round}", buffCfg.Round)
			desc = desc .. separator .. totalRoundDesc
		end

		desc = string.gsub(desc, "{Min}", min * 100 .. "%%")

		return string.gsub(desc, "{Max}", max * 100 .. "%%")
	end

	if buffCfg.Custom.isFriend then
		local isFriendStr = _("isFriend_" .. buffCfg.Custom.isFriend)

		desc = string.gsub(desc, "{isFriend}", isFriendStr)
	end

	if buffCfg.Custom.SessionType then
		local sessionTypeStr = _("SessionType_" .. buffCfg.Custom.SessionType)

		desc = string.gsub(desc, "{SessionType}", sessionTypeStr)
	end

	if buffCfg.Custom.SessionTypes then
		local langs = {}

		for i, v in ipairs(buffCfg.Custom.SessionTypes) do
			table.insert(langs, _("SessionType_" .. v))
		end

		local langsStr = table.concat(langs, "、")

		desc = string.gsub(desc, "{SessionType}", langsStr)
	end

	if buffCfg.Custom.MaxStack then
		desc = string.gsub(desc, "{MaxStack}", buffCfg.Custom.MaxStack)
	end

	if string.find(desc, "{MaxStack}") ~= nil then
		desc = string.gsub(desc, "{MaxStack}", buffCfg.MaxStack)
	end

	if buffCfg.Custom.Stack then
		desc = string.gsub(desc, "{Stack}", buffCfg.Custom.Stack)
	end

	if buffCfg.Custom.Per then
		desc = string.gsub(desc, "{Per}", buffCfg.Custom.Per * 100 .. "%%")
	end

	if buffCfg.Custom.Percent then
		desc = string.gsub(desc, "{Percent}", buffCfg.Custom.Percent * 100 .. "%%")
	end

	if buffCfg.Custom.Pct ~= nil then
		desc = string.gsub(desc, "{Pct}", buffCfg.Custom.Pct * 100 .. "%%")
	end

	if buffCfg.Custom.StartAnd then
		local langs = {}

		for i, v in ipairs(buffCfg.Custom.StartAnd) do
			table.insert(langs, RoleMgr:GetRole(v):GetName())
		end

		local langsStr = table.concat(langs, _("BuffDesc_Separator"))

		desc = string.gsub(desc, "{StartAnd}", langsStr)
	end

	if buffCfg.Custom.StartOr then
		local langs = {}

		for i, v in ipairs(buffCfg.Custom.StartOr) do
			table.insert(langs, RoleMgr:GetRole(v):GetName())
		end

		local langsStr = table.concat(langs, _("BuffDesc_Separator1"))

		desc = string.gsub(desc, "{StartOr}", langsStr)
	end

	if buffCfg.Custom.NewValue then
		local valueStr = buffCfg.Custom.NewValue .. ""

		if buffCfg.ValueType == 0 then
			valueStr = buffCfg.Custom.NewValue * 100 .. "%%"
		end

		desc = string.gsub(desc, "{NewValue}", valueStr)
	end

	if buffCfg.Custom.StartRound then
		local valueStr = buffCfg.Custom.StartRound .. ""

		desc = string.gsub(desc, "{StartRound}", valueStr)
	end

	if buffCfg.Custom.Heal then
		local valueStr = buffCfg.Custom.Heal .. ""

		if buffCfg.ValueType == 0 then
			valueStr = buffCfg.Custom.Heal * 100 .. "%%"
		end

		desc = string.gsub(desc, "{Heal}", valueStr)
	end

	if buffCfg.Custom.FailBuffs ~= nil then
		local custom = {}

		for i, v in ipairs(buffCfg.Custom.FailBuffs) do
			local buffDesc = BuffTip.GetDesc(v, 1, -1, true, 0, 0, nil)

			table.insert(custom, buffDesc)
		end

		local customStr = table.concat(custom, "、")

		desc = string.Replace(desc, "{FailBuffs}", customStr)
	end

	if buffCfg.Custom.BuffIds ~= nil then
		local custom = {}

		for i, v in ipairs(buffCfg.Custom.BuffIds) do
			local buffDesc = BuffTip.GetDesc(v, 1, -1, true, 0, 0, nil)

			table.insert(custom, buffDesc)
		end

		local customStr = table.concat(custom, "、")

		desc = string.Replace(desc, "{BuffIds}", customStr)
	end

	if buffCfg.Custom.BuffId ~= nil then
		local customStr = BuffTip.GetDesc(buffCfg.Custom.BuffId, 1, -1, true, 0, 0, nil)

		desc = string.Replace(desc, "{BuffId}", customStr)
	end

	if buffCfg.Custom.Type_Order ~= nil then
		local customStr = _("BuffName_" .. buffCfg.Custom.Type_Order)

		desc = string.Replace(desc, "{Type_Order}", customStr)
	end

	if buffCfg.Custom.TypeOrders ~= nil then
		local custom = {}

		for i, v in ipairs(buffCfg.Custom.TypeOrders) do
			local customDescKey

			customDescKey = "BuffState_" .. v

			if _(customDescKey) == customDescKey then
				customDescKey = "BuffName_" .. v
			end

			local customDesc = _(customDescKey)

			if not table.contains(custom, customDesc) then
				table.insert(custom, customDesc)
			end
		end

		local customStr = table.concat(custom, "、")

		desc = string.Replace(desc, "{TypeOrders}", customStr)
	end

	if buffCfg.Custom.CD ~= nil then
		local valueStr = buffCfg.Custom.CD .. ""

		desc = string.gsub(desc, "{CD}", valueStr)
	end

	if buffCfg.Custom.Time then
		desc = string.gsub(desc, "{Time}", buffCfg.Custom.Time)
	end

	if string.find(key, "AfterAttack") and buffCfg.Custom.Buffs then
		local newBuffCfg = BuffData[GetListObjByIndex(buffCfg.Custom.Buffs, 1)]
		local value = newBuffCfg.Value * skillPower
		local valueStr = value .. ""

		if newBuffCfg.ValueType == 0 then
			valueStr = value * 100 .. "%%"
		end

		desc = string.gsub(desc, "{Value}", valueStr)

		if newBuffCfg.Custom.Time then
			desc = string.gsub(desc, "{Time}", newBuffCfg.Custom.Time)
		end
	end

	local value = buffCfg.Value * skillPower

	if logicData and (buffCfg.Custom.StartOr or buffCfg.Custom.StartAnd) then
		value = logicData
	end

	local valueStr = value .. ""

	if buffCfg.ValueType == 0 then
		valueStr = value * 100 .. "%%"
	end

	desc = string.gsub(desc, "{Value}", valueStr)

	local separator = _("BuffDesc_Separator")

	if next(buffCfg.Custom) ~= nil then
		if buffCfg.Custom.Type ~= nil then
			local custom = {}

			for i, v in ipairs(buffCfg.Custom.Type) do
				local customDescKey

				customDescKey = "BuffState_" .. v

				if _(customDescKey) == customDescKey then
					customDescKey = "BuffName_" .. v
				end

				local customDesc = _(customDescKey)

				if not table.contains(custom, customDesc) then
					table.insert(custom, customDesc)
				end
			end

			local customStr = table.concat(custom, "、")

			desc = string.gsub(desc, "{Custom}", customStr)

			if string.find(desc, "{Count}") ~= nil then
				desc = string.gsub(desc, "{Count}", buffCfg.Custom.Count)
			end
		else
			local custom = {}

			for i, v in ipairs(buffCfg.Custom) do
				local customDescKey

				customDescKey = "BuffState_" .. v

				if _(customDescKey) == customDescKey then
					customDescKey = "BuffName_" .. v
				end

				local customDesc = _(customDescKey)

				if not table.contains(custom, customDesc) then
					table.insert(custom, customDesc)
				end
			end

			local customStr = table.concat(custom, "、")

			desc = string.gsub(desc, "{Custom}", customStr)
		end
	end

	if string.find(desc, "{Round}") ~= nil then
		desc = string.gsub(desc, "{Round}", buffCfg.Round)
	else
		if showTotalRound and buffCfg.Round > 0 then
			local totalRoundDesc = _("TotalRoundDesc")

			totalRoundDesc = string.gsub(totalRoundDesc, "{Round}", buffCfg.Round)

			if string.find(desc, "{RoundPrepose}") ~= nil then
				desc = string.gsub(desc, "{RoundPrepose}", totalRoundDesc)
			else
				desc = desc .. separator .. totalRoundDesc
			end
		end

		if remainRound > 0 then
			local remainRoundDesc = _("RemainRoundDesc")

			if buffCfg.Custom.RemainRoundDisplay then
				remainRound = remainRound + buffCfg.Custom.RemainRoundDisplay
			end

			remainRoundDesc = string.gsub(remainRoundDesc, "{Round}", remainRound)
			desc = desc .. separator .. remainRoundDesc
		end
	end

	if buffStack ~= nil and buffStack > 0 then
		if string.find(desc, "{LeftTime}") ~= nil then
			desc = string.gsub(desc, "{LeftTime}", buffStack)
		else
			local buffStackDesc = _("Mark_Buff_Stacks")

			buffStackDesc = string.gsub(buffStackDesc, "{Stacks}", buffStack)
			desc = desc .. separator .. buffStackDesc
		end
	end

	return desc
end

function BuffTip.GetBuffKey(buffId, skillPower, remainRound, showTotalRound, mainDescIndex, buffStack, logicData)
	if skillPower <= 0 then
		skillPower = 1
	end

	local mainDescEx = ""

	if mainDescIndex == 1 then
		mainDescEx = "Skill"
	elseif mainDescIndex == 2 then
		mainDescEx = "PR"
	end

	local buffCfg = BuffData[buffId]
	local key = ""

	print(mainDescEx)

	if buffCfg.TypeOrder ~= "" then
		key = "TypeOrder" .. mainDescEx .. "_" .. buffCfg.TypeOrder

		if buffCfg.Type == "Dot_Buff" then
			key = key .. "_" .. buffCfg.Type
		end
	else
		key = "Type" .. mainDescEx .. "_" .. buffCfg.Type
	end

	if buffCfg.Custom.Weight ~= nil then
		key = key .. "_Random"
	end

	return key
end

function BuffTip.GetAllBuffTips()
	local list = {}

	for k, v in pairs(BuffData) do
		local printInfo = {}

		printInfo.BuffId = v.ID
		printInfo.DescInSkill = BuffTip.GetDesc(v.ID, 1, -1, true, 1)
		printInfo.DescPRInSkill = BuffTip.GetDesc(v.ID, 1, -1, true, 2)
		printInfo.Desc = BuffTip.GetDesc(v.ID, 1, -1, false, 0, 0, nil)
		printInfo.BuffKeyInSkill = BuffTip.GetBuffKey(v.ID, 1, -1, true, 1)
		printInfo.BuffKeyPRInSkill = BuffTip.GetBuffKey(v.ID, 1, -1, true, 2)
		printInfo.BuffKey = BuffTip.GetBuffKey(v.ID, 1, -1, false, 0, 0, nil)

		table.insert(list, printInfo)
	end

	local json = require("GameLogic.Util.json4lua")
	local ret = json.encode(list)
	local path = string.gsub(Application.dataPath, "Assets", "")
	local test = assert(io.open(path .. "BuffTipDescOut.txt", "w"))

	test:write(ret)
	test:close()
end
