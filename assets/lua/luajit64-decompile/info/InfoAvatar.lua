-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoAvatar.lua

local AvatarData = require("luaData/AvatarData")
local CharAvatarListData = require("luaData/CharAvatarListData")
local AvatarAssetData = require("luaData/AvatarAsset")

require("Info/AttributeAgent")

eAvatarTabType = {
	BP = "BP",
	FaceUp = "FaceUp",
	FaceDown = "FaceDown",
	Ornament = "Ornament",
	Body = "Body",
	Back = "Back",
	Event = "Event",
	Waist = "Waist"
}
eAvatarFrom = {
	default = 0,
	talent = 2,
	tea_party = 12,
	equip_break = 9,
	event = 3,
	battle_pass = 7,
	manual = 6,
	limit_card_pool = 11,
	role_birthday = 10,
	shop = 4,
	recharge = 8,
	card = 5,
	petal = 1
}
eAvatarFitType = {
	BP = 1,
	Public = 2,
	Common = 0
}

local eAvatarLockType = {
	NotNeedUnlock = 0,
	NeedUnlock = 1
}

InfoAvatar = class("InfoAvatar", InfoBase)

function InfoAvatar:ctor(id)
	self.id = id
	self.data = AvatarData[id]

	AvatarManager.dictAvatar:Set(self.id, self)

	self.attrs = AttributeOwner()

	self:SetAtt()

	self.startTime = not string.isNullOrEmpty(self.data.StartTime) and GetTimeTampByString(self.data.StartTime) or 0
	self.endTime = not string.isNullOrEmpty(self.data.EndTime) and GetTimeTampByString(self.data.EndTime) or 0
	self.publishTime = not string.isNullOrEmpty(self.data.Publish_At) and GetTimeTampByString(self.data.Publish_At) or 0
end

function InfoAvatar:SetAtt()
	local tab1, tab2, tab3 = self.data.SkinAttList, self.data.Argus1, self.data.Argus2

	for k, v in pairs(GetMapTab({
		tab1,
		tab2,
		tab3
	})) do
		local value = 0

		if GetAttValueType(k) == eValueType.Abs then
			value = v
		else
			value = v / 1000
		end

		self.attrs:ModExtraAdd(k, value)
	end

	local tab = self.data.SkinAttListPer

	for k, v in ipairs(ATTRIBUTE_MAP[1]) do
		if tab[k] then
			self.attrs:ModExtraMul(v, tab[k] / 1000)
		end
	end
end

function InfoAvatar:GetAddAtt(att)
	return self.attrs:GetExtraAdd(att)
end

function InfoAvatar:GetMulAtt(att)
	return self.attrs:GetExtraMul(att)
end

function InfoAvatar:IsWeaponAvatar()
	if self.data.Slot[1] == "Weapon" then
		return true
	end

	return false
end

function InfoAvatar:IsBPAvatar()
	if self.data.AvatarType == eAvatarFitType.BP then
		return true
	end

	return false
end

function InfoAvatar:GetBPAddAtt()
	if self:IsBPAvatar() then
		for k, v in ipairs(ATTRIBUTE_NAME) do
			local att = self:GetAddAtt(v)

			if att > 0 then
				return k, att
			end

			att = self:GetMulAtt(v)

			if att > 0 then
				return k, att
			end
		end
	end

	return 0, 0
end

function InfoAvatar:IsExist()
	if self.startTime == 0 and self.endTime == 0 and self.publishTime == 0 then
		return true
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if curServerTime >= self.publishTime then
		if self.endTime == 0 then
			return curServerTime >= self.startTime
		end

		return curServerTime >= self.startTime and curServerTime < self.endTime
	end

	return false
end

function InfoAvatar:IsPublic()
	return self.data.AvatarType == eAvatarFitType.BP or self.data.AvatarType == eAvatarFitType.Public
end

AvatarManager = {}
AvatarManager.dictAvatar = AvatarManager.dictAvatar or Record()
AvatarManager.curTabIndex = 0
AvatarManager.needPresave = false
AvatarManager.LastEquipAvatar = {}
AvatarManager.BPAvatarList = {}

function AvatarManager:GetAvatar(id)
	if type(id) == "string" then
		id = tonumber("0x" .. id)
	end

	local ret = self.dictAvatar:GetValue(id)

	ret = ret or InfoAvatar(id)

	return ret
end

function AvatarManager:GetAvatarAssetPath(avatarId, roleId)
	local infoAvatar = self:GetAvatar(avatarId)

	if infoAvatar then
		if roleId ~= nil and infoAvatar:IsPublic() then
			for _, v in pairs(AvatarAssetData) do
				if v.AvatarID == avatarId then
					for _, n in pairs(v.AvatarPath) do
						if n[1] == roleId then
							return n[2]
						end
					end
				end
			end
		end

		return infoAvatar.data.AvatarPath
	end

	return ""
end

function AvatarManager.GetListAvatarByTabType(infoRole, avatarTabType)
	local list = {}

	for _, v in pairs(AvatarData) do
		if v.AvatarTabType == avatarTabType then
			local resultData = AvatarManager:GetAvatarData(infoRole, v.ID)

			if resultData and resultData.InfoAvatar:IsExist() then
				table.insert(list, resultData)
			end
		end
	end

	return list
end

function AvatarManager:GetListAvatar(infoRole, avatarTabType)
	local resultList = {}

	if avatarTabType == eAvatarTabType.BP then
		if next(self.BPAvatarList) ~= nil then
			for _, v in ipairs(self.BPAvatarList) do
				v = AvatarManager:GetAvatarData(infoRole, v.id)

				if v and v.InfoAvatar:IsExist() then
					table.insert(resultList, v)
				end
			end
		else
			resultList = AvatarManager.GetListAvatarByTabType(infoRole, avatarTabType)
			self.BPAvatarList = resultList
		end
	else
		local data = CharAvatarListData[infoRole.data.CharAvatarListID]

		for i = 1, #data.Avatar do
			local avatarId = data.Avatar[i]
			local infoAvatar = self:GetAvatar(avatarId)

			if infoAvatar.data.AvatarTabType == avatarTabType then
				local resultData = AvatarManager:GetAvatarData(infoRole, avatarId)

				if resultData and resultData.InfoAvatar:IsExist() then
					resultData.Order = i

					table.insert(resultList, resultData)
				end
			end
		end
	end

	return resultList
end

function AvatarManager:GetAvatarData(infoRole, avatarId)
	local resultData = {}

	resultData.id = avatarId
	resultData.InfoAvatar = self:GetAvatar(avatarId)
	resultData.IsUnlocked = self:IsUnlocked(infoRole, resultData.InfoAvatar)

	if resultData.InfoAvatar.data.Lock == eAvatarLockType.NotNeedUnlock then
		resultData.IsUnlocked = true
	end

	resultData.IsCanGotoGet = self:IsCanGotoGet(resultData.InfoAvatar)

	local GetedTime = -1

	if resultData.InfoAvatar:IsBPAvatar() then
		GetedTime = PlayerInst:GetBPAvatarIdx(avatarId)
	else
		GetedTime = table.getIndex(infoRole.pb.avatars, avatarId)
	end

	resultData.Geted = GetedTime > 0
	resultData.GetedTime = GetedTime

	if resultData.Geted then
		resultData.IsUnlocked = true
	end

	local avatarIds = infoRole:GetEquipAvatarIds()

	resultData.RealEquiped = false

	local hasEquiped = table.getIndex(avatarIds, avatarId) > 0

	if resultData.Geted then
		if resultData.InfoAvatar:IsBPAvatar() then
			local bp = PlayerInst:GetBPAvatar(avatarId)

			if bp.roleId == infoRole.id then
				resultData.RealEquiped = hasEquiped
			end
		else
			resultData.RealEquiped = hasEquiped
		end
	end

	resultData.Equiped = hasEquiped
	resultData.checkmark = false

	return resultData
end

function AvatarManager:GetWeaponAvatarData(infoRole, id)
	local resultData = {}

	resultData.id = id
	resultData.InfoAvatar = self:GetAvatar(id)
	resultData.IsUnlocked = self:IsUnlocked(infoRole, resultData.InfoAvatar)

	if resultData.InfoAvatar.data.Lock == 0 then
		resultData.IsUnlocked = true
	end

	resultData.IsCanGotoGet = self:IsCanGotoGet(resultData.InfoAvatar)

	local hasEquiped = infoRole.pb.weaponAvatar == id

	resultData.RealEquiped = hasEquiped
	resultData.Equiped = hasEquiped

	local GetedTime = table.getIndex(infoRole.pb.avatars, id)

	resultData.Geted = GetedTime > 0
	resultData.GetedTime = GetedTime

	if resultData.Geted then
		resultData.IsUnlocked = true
	end

	return resultData
end

function AvatarManager:GetWeaponAvatarList(infoRole)
	local resultList = {}

	for i = 1, #infoRole.data.WeaponAvatarList do
		local avatarId = infoRole.data.WeaponAvatarList[i]
		local resultData = AvatarManager:GetWeaponAvatarData(infoRole, avatarId)

		if resultData and resultData.InfoAvatar:IsExist() then
			table.insert(resultList, resultData)
		end
	end

	return resultList
end

function AvatarManager:IsUnlocked(infoRole, infoAvatar)
	if not infoAvatar then
		return false
	end

	if infoAvatar.data.Lock == 0 then
		return true
	end

	if infoAvatar:IsBPAvatar() then
		return PlayerInst:IsBPGeted(infoAvatar.id)
	end

	if table.getIndex(infoRole.pb.avatars, infoAvatar.id) ~= -1 then
		return true
	end

	return false
end

function AvatarManager:IsCanGotoGet(infoAvatar)
	local fromWhere = infoAvatar.data.FromWhere
	local extra

	if fromWhere == eAvatarFrom.event then
		return false
	elseif fromWhere == eAvatarFrom.petal then
		extra = infoAvatar.data.FromRoleCardID

		if extra ~= 0 then
			local card = RoleCardMgr:GetRoleCard(extra)

			if card and card:IsHold() then
				return true
			end
		end

		return false
	elseif fromWhere == eAvatarFrom.battle_pass then
		extra = infoAvatar.data.AvatarFrom

		local infoActive = OperationActiveMgr:Get(extra)

		if infoActive and infoActive:IsOpening() then
			return true
		end

		return false
	elseif fromWhere == eAvatarFrom.role_birthday then
		extra = infoAvatar.data.AvatarFrom

		local infoActive = OperationActiveMgr:Get(extra)

		if infoActive and infoActive:IsOpening() then
			return true
		end

		return false
	elseif fromWhere == eAvatarFrom.limit_card_pool then
		extra = infoAvatar.data.AvatarFrom

		local infoCardPool = CardPoolManager:Get(extra)

		if not infoCardPool then
			return false
		end

		local openTime, endTime

		if infoCardPool.data.CreateAccountPoolTime ~= 0 then
			openTime = tonumber(PlayerInst.InfoPlayer:GetRegisterTime())
			endTime = tonumber(PlayerInst.InfoPlayer:GetRegisterTime()) + infoCardPool.data.CreateAccountPoolTime * 3600
		else
			openTime = GetTimeTampByString(infoCardPool.data.OpenTime)
			endTime = GetTimeTampByString(infoCardPool.data.EndTime)
		end

		local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		if openTime <= curTime and curTime <= endTime then
			return true
		end

		return false
	elseif fromWhere == eAvatarFrom.tea_party then
		extra = infoAvatar.data.AvatarFrom

		local infoActive = ActiveMgr:GetActive(extra)

		if infoActive and infoActive:IsShowOpen() then
			return true
		end

		return false
	end

	return true
end

function AvatarManager:FindAvatarBySlot(listAvatarId, slotList)
	for _, id in pairs(listAvatarId) do
		if id then
			local infoAvatar = self:GetAvatar(id)

			for k, v in ipairs(slotList) do
				if table.contains(infoAvatar.data.Slot, v) then
					return true, id
				end
			end
		end
	end

	return false, nil
end

function AvatarManager:IsSameSlotAvatar(id1, id2)
	local avatar1 = self:GetAvatar(id1)
	local avatar2 = self:GetAvatar(id2)

	if not avatar1 or not avatar2 then
		return false
	end

	for _, v in ipairs(avatar1.data.Slot) do
		if table.contains(avatar2.data.Slot, v) then
			return true
		end
	end

	return false
end

function AvatarManager.GetStrAtt(infoAvatar, isAdd)
	local list = {}

	for k, v in ipairs(ATTRIBUTE_NAME) do
		local att = infoAvatar:GetAddAtt(v)

		if att > 0 then
			list[k] = att
		end
	end

	local cnt = table.getCount(list)
	local listStr = {}

	if cnt > 0 then
		local i = 1

		for k, v in pairsByKeys(list) do
			local str = ""
			local strAdd = isAdd and "+" or "-"

			if GetAttValueType(GetAttENKey(k)) == eValueType.Abs then
				str = _("eAttType_" .. k) .. strAdd .. v
			else
				str = _("eAttType_" .. k) .. strAdd .. v * 100 .. "%"
			end

			i = i + 1

			table.insert(listStr, str)
		end
	end

	return listStr
end

function AvatarManager.IsBPAvatar(id)
	if AvatarData[id] then
		return AvatarData[id].AvatarType == eAvatarFitType.BP
	end

	return false
end

function AvatarManager.GotoFromWhere(infoRole, infoAvatar, cb)
	local fromWhere = infoAvatar.data.FromWhere

	if fromWhere == eAvatarFrom.petal then
		local infoRoleCard = RoleCardMgr:GetRoleCard(infoAvatar.data.FromRoleCardID)

		if not infoRoleCard:IsHold() then
			return
		end

		require("UI/Page/PageRoleCard/Page/PageRoleCard")
		UIMgr.SwitchPanel(PageRoleCard(), {
			cardId = infoAvatar.data.FromRoleCardID
		})
	elseif fromWhere == eAvatarFrom.talent then
		UIMgr.ShowMsg(_("Msg_Talent_Not_Unlock"))
	elseif fromWhere == eAvatarFrom.card then
		if SystemMaintainMgr:Deal(SystemMaintainType.recruit, false, true) then
			return
		end

		require("UI/Page/PageCardShop/PageCardShop")
		PageCardShop.InitNetData()
	elseif fromWhere == eAvatarFrom.manual then
		local openInfo = CollectionManager:GetPicOpenInfo(infoRole.id)

		if openInfo:IsGetAward() then
			require("UI/Page/PageManual/PagePictureTask")
			UIMgr.SwitchPanel(PagePictureTask, {
				roleId = infoRole.id,
				itemId = infoAvatar.id
			})
		else
			require("UI/Page/PageManual/PagePictureAlbum")
			UIMgr.SwitchPanel(PagePictureAlbum, {
				roleId = infoRole.id
			})
		end
	elseif fromWhere == eAvatarFrom.battle_pass then
		if SystemMaintainMgr:Deal(SystemMaintainType.operation, false, true) then
			return
		end

		OperationActiveMgr.PageOperationActiveType = 1

		require("UI/Page/PageOperation/PageOperationActiveNew")

		local data = {
			tag = 1
		}
		local infoActive = OperationActiveMgr:Get(infoAvatar.data.AvatarFrom)

		if infoActive then
			data.tag = infoActive.data.UIType
		end

		UIMgr.SwitchPanel(PageOperationActiveNew, data)
	elseif fromWhere == eAvatarFrom.recharge then
		require("UI/Page/PageShop/PageShop")

		if cb then
			cb()
		end

		PageShop.InitNetData({
			tagIndex = 1,
			openRecharge = true,
			tabMainIndex = tabMainType.package
		})
	elseif fromWhere == eAvatarFrom.equip_break then
		require("UI/Page/PageEquipment/PageEquipDevelop")
		UIMgr.SwitchPanel(PageEquipDevelop, {
			roleId = infoRole.id
		})
	elseif fromWhere == eAvatarFrom.role_birthday then
		if SystemMaintainMgr:Deal(SystemMaintainType.operation, false, true) then
			return
		end

		local infoActive = OperationActiveMgr:Get(infoAvatar.data.AvatarFrom)

		if infoActive and infoActive:IsOpening() then
			OperationActiveMgr.PageOperationActiveType = 2

			local uiInfo = InfoOperationActive:GetOperationUIInfo(infoActive.data.UIType .. "_" .. infoActive.data.PageOrder)

			for i = 1, 1 do
				if uiInfo and uiInfo.Video and uiInfo.Video[i] and uiInfo.Video[i][1] then
					OperationActiveMgr.RoleBirthdayVideoClip = uiInfo.Video[i][1]
				end
			end

			require("UI/Page/PageOperation/DlgRoleBirthdayAward")
			UIMgr.AddPanel(DlgRoleBirthdayAward(), {
				isShowBG = true,
				infoActive = infoActive
			})
		else
			UIMgr.ShowMsg("Tip_AatarExpired_" .. fromWhere)
		end
	elseif fromWhere == eAvatarFrom.limit_card_pool then
		if SystemMaintainMgr:Deal(SystemMaintainType.recruit, false, true) then
			return
		end

		require("UI/Page/PageCardShop/PageCardShop")

		local function switchCardShop()
			local list = CardPoolManager:GetAll()
			local info = CardPoolManager:Get(infoAvatar.data.AvatarFrom)

			for i, v in ipairs(list) do
				if v.data.ID == info.data.ID or info.data.ActiveID ~= 0 and v.data.ActiveID == info.data.ActiveID then
					PageCardShop.selectIndex = i

					break
				end
			end

			UIMgr.SwitchPanel(PageCardShop, nil, false)
		end

		if not CardPoolManager.init then
			local function wrap_cb(vPBMessage)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vPBMessage.result.code == NetManager.Result_Sucess then
					CardPoolManager.init = true

					for i, v in ipairs(vPBMessage.poolInfo) do
						CardPoolManager:Get(v.poolId):SetData(v)
					end

					PageCardShop.selectChooseIndex = nil

					switchCardShop()
				elseif vPBMessage.result.code == NetManager.Result_Maintain then
					UIMgr.ShowMsg(_("Desc_FuncFobid"))
				else
					UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
				end
			end

			NetManager:RequestDrawCardPool(wrap_cb)
			LoadingMgr.Show(eLoadingType.Repeat)
		else
			PageCardShop.selectChooseIndex = nil

			switchCardShop()
		end
	elseif fromWhere == eAvatarFrom.tea_party then
		require("UI/Page/PageActivity/PageBossActivity")

		local infoActive = PageBossActivity.GetCurBossActive()

		local function wrap_cb(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				require("UI/Page/PageActivity/PageBossActivityShop")
				UIMgr.SwitchPanel(PageBossActivityShop, {
					activeId = infoActive.id
				})
			elseif vPBMessage.result.code == NetManager.Result_Maintain then
				UIMgr.ShowMsg(_("Desc_FuncFobid"))
			else
				UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			end
		end

		NetManager:RequestGetActityPool(infoActive.id, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	end
end

local AvatarShelfTime = {}

AvatarManager.NextRefreshTime = 0

function AvatarManager.InitRefreshAvatar()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local timePulbish, timeStart = 0, 0

	for _, v in pairs(AvatarData) do
		if not string.isNullOrEmpty(v.Publish_At) or not string.isNullOrEmpty(v.StartTime) then
			timePulbish = GetTimeTampByString(v.Publish_At)
			timeStart = GetTimeTampByString(v.StartTime)

			local time = Mathf.Max(timePulbish, timeStart)

			if curServerTime < time and not table.contains(AvatarShelfTime, time) then
				table.insert(AvatarShelfTime, time)
			end
		end
	end

	table.sort(AvatarShelfTime, function(a, b)
		return a < b
	end)

	AvatarManager.NextRefreshTime = AvatarShelfTime[1] or 0
end

function AvatarManager.ResetNextRefreshTime()
	if #AvatarShelfTime > 0 then
		table.remove(AvatarShelfTime, 1)
	end

	AvatarManager.NextRefreshTime = AvatarShelfTime[1] or 0
end
