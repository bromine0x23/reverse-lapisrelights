-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/LoadingMgr.lua

require("UI/Loading/LoadingRepeat")
require("UI/Loading/LoadingProgress")
require("UI/Loading/LoadingBlackCurtain")

eLoadingType = {
	Repeat = 0,
	BlackCurtain = 2,
	Progress = 1,
	RepeatPay = 3
}
LoadingMgr = {}

local loadingLayerNode, loadingRepeat, loadingRepeatPay, loadingProgress, loadingBlackCurtain
local protocolIds = {}

function LoadingMgr.Init()
	loadingLayerNode = UIManager.GetLayerNode("LOADING")
	loadingRepeat = LoadingRepeat(loadingLayerNode)
	loadingRepeatPay = LoadingRepeat(loadingLayerNode)
	loadingProgress = LoadingProgress(loadingLayerNode)
	loadingBlackCurtain = LoadingBlackCurtain(loadingLayerNode)
end

function LoadingMgr.Show(type, protocolId)
	if type == eLoadingType.Repeat then
		loadingRepeat:Show()
	elseif type == eLoadingType.Progress then
		loadingProgress:Show()
	elseif type == eLoadingType.BlackCurtain then
		loadingBlackCurtain:Show()
	elseif type == eLoadingType.RepeatPay then
		loadingRepeatPay:Show()
	end
end

function LoadingMgr.Hide(type, protocolId)
	if type == eLoadingType.Repeat then
		loadingRepeat:Hide()
	elseif type == eLoadingType.Progress then
		loadingProgress:Hide()
	elseif type == eLoadingType.BlackCurtain then
		loadingBlackCurtain:Hide()
	elseif type == eLoadingType.RepeatPay then
		loadingRepeatPay:Hide()
	end
end

function LoadingMgr.IsLoading()
	return loadingRepeat.ReferenceCount > 0 or loadingProgress.LoadingUI
end

function LoadingMgr.SetProgress(percent)
	loadingProgress:SetProgress(percent)
end

function LoadingMgr.ForceHideRepeat()
	loadingRepeat.ReferenceCount = 0

	loadingRepeat:Hide()
end
