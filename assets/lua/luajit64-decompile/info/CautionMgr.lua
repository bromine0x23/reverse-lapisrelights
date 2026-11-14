-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/CautionMgr.lua

CautionMgr = class("CautionMgr")

local cautionSetting = require("luaData/m_caution_setting")

function CautionMgr:ctor()
	return
end

function CautionMgr:GetCautionPopInfo(sceneId)
	local caution = self:GetCaution(sceneId)

	if not caution then
		return nil
	end

	if caution.cautionScene == protocol_pb.home and caution.cautionType == protocol_pb.cautionOnly and not PlayerInst.InfoPlayer.showHomeCaution then
		return nil
	end

	local master = cautionSetting[self:GetStrCS(caution.cautionScene) .. "+" .. self:GetStrCT(caution.cautionType)]

	if not master or master.is_once == "1" and caution.lookAt ~= 0 then
		return nil
	end

	return caution
end

function CautionMgr:GetStrCS(cautScene)
	if cautScene == protocol_pb.home then
		return "home"
	elseif cautScene == protocol_pb.shop then
		return "shop"
	end

	return ""
end

function CautionMgr:GetStrCT(cautType)
	if cautType == protocol_pb.cautionOnly then
		return "caution_only"
	elseif cautType == protocol_pb.cautionBilling then
		return "caution_billing"
	elseif cautType == protocol_pb.cautionRestriction then
		return "caution_restriction"
	elseif cautType == protocol_pb.cautionRestrictionBilling then
		return "caution_restriction_billing"
	end

	return ""
end

function CautionMgr:GetCaution(sid)
	print("========= GET CAUTION ===========")

	local now = NetData:GetCurServerTime() / 1000

	for i = 1, #PlayerInst.InfoPlayer.cautions do
		local v = PlayerInst.InfoPlayer.cautions[i]

		if now > v.startAt and (v.endAt <= 0 or now < v.endAt) and (v.cautionScene == sid or v.cautionType == protocol_pb.cautionRestriction and v.cautionScene == protocol_pb.home) then
			return v
		end
	end

	return nil
end
