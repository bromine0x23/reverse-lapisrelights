-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCaution/CautionBuilder.lua

require("UI/Page/PageCaution/PageCaution")

local m_caution_setting = require("luaData/m_caution_setting")

CautionBuilder = {}

function CautionBuilder.OpenCautionPopup(cautionInfo)
	CautionBuilder.OpenPop(cautionInfo, nil, false)
end

function CautionBuilder.OpenCautionRebootPopup(cautionInfo)
	UIMgr.AddPanel(PageCaution(), {
		callback = function()
			Oz.Framework.Launcher.Instance:Restart()
		end
	}, UIMgr.UIPopupObject)
end

function CautionBuilder.OpenCautionPopupOpt(cautionInfo, onSuccess, isCallReadApi)
	CautionBuilder.OpenPop(cautionInfo, function()
		if cautionInfo.cautionScene == protocol_pb.home and cautionInfo.cautionType == protocol_pb.cautionBilling or cautionInfo.cautionScene == protocol_pb.home and cautionInfo.cautionType == protocol_pb.cautionRestrictionBilling or cautionInfo.cautionScene == protocol_pb.shop then
			onSuccess()
		end
	end, isCallReadApi)
end

function CautionBuilder.OpenPopForeverBan(content, onSuccess)
	LoadingMgr.Hide(eLoadingType.Repeat)
	UIMgr.AddPanel(PageCaution(), {
		banForever = true,
		content = content,
		callback = function()
			onSuccess()
		end
	}, UIMgr.UIPopupObject)
end

function CautionBuilder.OpenPop(cautionInfo, onSuccess, isCallReadApi)
	UIMgr.AddPanel(PageCaution(), {
		caution_info = CautionBuilder.GetCautionSetting(cautionInfo),
		useCheckBox = cautionInfo.cautionType == protocol_pb.cautionOnly or cautionInfo.cautionType == protocol_pb.cautionBilling,
		callback = function()
			local function action()
				onSuccess()
			end

			if isCallReadApi then
				CautionBuilder.ReadCaution(cautionInfo, action)

				return
			end

			action()
		end
	}, UIMgr.UIPopupObject)
end

function CautionBuilder.ReadCaution(cautionInfo, act)
	local function warp_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if act then
			act()
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:ReadCaution(cautionInfo.cautionId, warp_cb)
end

function CautionBuilder.GetCautionSetting(cautionInfo)
	local scene = "home"
	local method = "caution_billing"

	if cautionInfo.cautionScene == protocol_pb.shop then
		scene = "shop"
	end

	if cautionInfo.cautionType == protocol_pb.cautionRestrictionBilling then
		method = "caution_restriction_billing"
	end

	local caution = m_caution_setting[scene .. "+" .. method]

	caution.title = cautionInfo.title
	caution.message = cautionInfo.message

	return caution
end
