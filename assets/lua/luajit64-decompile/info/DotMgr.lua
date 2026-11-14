-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/DotMgr.lua

require("Util/PersistentStoreUtil")

DotMgr = {}
DotMgr.list = {
	[ePSKey.Dot_SMS_CALL] = false
}

function DotMgr:Update(key, data)
	local hasDot = false

	if key == ePSKey.Dot_SMS_CALL then
		local listRoleId = RoleMgr:GetAllRoleId()
		local hasDot = false

		for i = 1, #listRoleId do
			local roleId = listRoleId[i]
			local listTopic = TopicManager:GetListTopic(roleId, 0)
			local listCall = PhoneCallManager:GetListTopic(roleId, 0)

			if #listTopic > 0 then
				hasDot = true
			end

			if #listCall > 0 then
				hasDot = true
			end
		end

		PersistentStoreUtil.SetBool(ePSKey.Dot_SMS_CALL, hasDot)
		Event.Instance:Fire("UpdateDot", ePSKey.Dot_SMS_CALL)
	elseif key == ePSKey.Dot_SHOP then
		PersistentStoreUtil.SetBool(key, data.isNew)

		hasDot = data.isNew

		local isShow = data.isShow

		if data.secondTag then
			PersistentStoreUtil.SetBool(key .. "secondTag" .. data.secondTag, isShow)
		end
	elseif key == ePSKey.Dot_Bag then
		local infoItem = data.infoItem
		local isShow = data.isShow

		PersistentStoreUtil.SetBool(key .. "thirdTag" .. infoItem.id, isShow)

		if isShow then
			PersistentStoreUtil.SetBool(key .. "secondTag" .. infoItem.data.BagPage, true)
			PersistentStoreUtil.SetBool(key, true)

			hasDot = true
		end
	elseif key == ePSKey.Dot_Player_Head then
		if data.id then
			PersistentStoreUtil.SetBool(key .. "thirdTag" .. data.id, data.isShow)
		end

		if data.secondTabId then
			PersistentStoreUtil.SetBool(key .. "secondTag" .. data.secondTabId, data.isShow)
		end

		if data.isNew ~= nil then
			PersistentStoreUtil.SetBool(key, data.isNew)

			hasDot = data.isNew
		end
	elseif key == ePSKey.Dot_FRIEND then
		if data and data.isNew ~= nil then
			PersistentStoreUtil.SetBool(key, data.isNew)

			hasDot = data.isNew
		end

		if data and data.secondTabId then
			PersistentStoreUtil.SetBool(key .. "secondTag" .. data.secondTabId, data.isShow)
		end
	elseif key == ePSKey.Dot_PVP then
		if data and data.isNew ~= nil then
			PersistentStoreUtil.SetBool(key, data.isNew)

			hasDot = data.isNew
		end
	elseif key == ePSKey.Dot_TASK then
		if data and data.isShow ~= nil then
			PersistentStoreUtil.SetBool(key, data.isShow)

			hasDot = data.isShow
		end

		if data and data.secondTabId then
			PersistentStoreUtil.SetBool(key .. "secondTag" .. data.secondTabId, data.isSecondShow)
		end
	elseif key == ePSKey.Dot_WORK then
		if data and data.isShow ~= nil then
			PersistentStoreUtil.SetBool(key, data.isShow)

			hasDot = data.isShow
		end

		if data and data.thirdTabId then
			PersistentStoreUtil.SetBool(key .. "thirdTag" .. data.thirdTabId, data.isThirdShow)
		end

		if data and data.secondTabId then
			PersistentStoreUtil.SetBool(key .. "secondTag" .. data.secondTabId, data.isSecondShow)
		end
	elseif key == ePSKey.Dot_MAIL then
		if data and data.isShow ~= nil then
			PersistentStoreUtil.SetBool(key, data.isShow)

			hasDot = data.isShow
		end
	elseif key == ePSKey.Dot_THEME then
		if data and data.isShow ~= nil then
			PersistentStoreUtil.SetBool(key, data.isShow)

			hasDot = data.isShow
		end
	elseif key == ePSKey.Dot_BONDAGE then
		if data and data.isShow ~= nil then
			PersistentStoreUtil.SetBool(key, data.isShow)

			hasDot = data.isShow
		end

		if data and data.thirdTabId then
			PersistentStoreUtil.SetBool(key .. "thirdTag" .. data.thirdTabId, data.isThirdShow)
		end

		if data and data.secondTabId then
			PersistentStoreUtil.SetBool(key .. "secondTag" .. data.secondTabId, data.isSecondShow)
		end
	elseif key == ePSKey.Dot_BossRaid then
		local finishList = ActivityBossRaidMgr:GetFinishedBossRaid()

		hasDot = #finishList > 0
	end

	Event.Instance:Fire("UpdateDotNotify", key, hasDot)
end

function DotMgr:HasDot(key, secondTag, thirdTag)
	local has = false
	local secondHas = false
	local thirdHas = false

	if key == ePSKey.Dot_SHOP then
		if not PersistentStoreUtil.HasBool(key) then
			has = true
		else
			has = PersistentStoreUtil.GetBool(key)
		end
	else
		has = PersistentStoreUtil.GetBool(key)
	end

	if thirdTag then
		thirdHas = PersistentStoreUtil.GetBool(key .. "thirdTag" .. thirdTag)
	end

	if secondTag then
		secondHas = PersistentStoreUtil.GetBool(key .. "secondTag" .. secondTag)
	end

	return has, secondHas, thirdHas
end

function DotMgr:Remove(key)
	DotMgr.list[key] = false

	PersistentStoreUtil.SetBool(key, false)
end

function DotMgr:Init()
	return
end
