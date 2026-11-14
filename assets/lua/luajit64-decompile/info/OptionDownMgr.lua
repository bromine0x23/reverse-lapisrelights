-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/OptionDownMgr.lua

local DownloadConfig = require("luaData/DownloadConfig")

OptionDownMgr = {}
eDownloadType = {
	onlySound = 2,
	onlyVideo = 1,
	all = 3,
	none = 4
}
OptionDownMgr.init = false
OptionDownMgr.OptionDownStageData = {}
OptionDownMgr.OptionDownTopicData = {}
OptionDownMgr.OptionDownVideoData = {}
OptionDownMgr.CurDownloadList = {}
OptionDownMgr.needTips = true

function OptionDownMgr:Init()
	local finishAsset = {}

	for i, v in pairs(DownloadConfig) do
		if v.StageId and v.StageId ~= 0 then
			self.OptionDownStageData[v.StageId] = v

			if ChapterMgr:GetStage(v.StageId):IsPass() then
				for m, n in pairs(v.BundleName) do
					table.insert(finishAsset, string.lower(n))
				end

				for m, n in pairs(v.SoundBankName) do
					table.insert(finishAsset, n)
				end
			end
		end

		if v.TopicId and v.TopicId ~= 0 then
			OptionDownMgr.OptionDownTopicData[v.TopicId] = v

			if PhoneCallManager:Get(v.TopicId).pb.status == 1 then
				for m, n in pairs(v.BundleName) do
					table.insert(finishAsset, string.lower(n))
				end

				for m, n in pairs(v.SoundBankName) do
					table.insert(finishAsset, n)
				end
			end
		end

		for i, v in ipairs(v.BundleName) do
			table.insert(self.OptionDownVideoData, string.lower(v))
		end
	end

	OptionDownMgr.init = true

	if not PersistentStoreUtil.HasBool(PersistentStoreUtil.KEY_OPTIONAL_ASSET_AUTO_DELECT) then
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPTIONAL_ASSET_AUTO_DELECT, false)
	end

	if #finishAsset > 0 and PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_OPTIONAL_ASSET_AUTO_DELECT) then
		OptionDownMgr:DelectFinishAsset(finishAsset)
	end
end

function OptionDownMgr:GetKeyByStageID(stageId, openFrom)
	local key

	if stageId ~= 0 then
		if openFrom == 1 then
			key = "Stage" .. stageId
		elseif openFrom == 2 then
			key = "Topic" .. stageId
		else
			key = "Video" .. stageId
		end
	else
		key = 0
	end

	return key
end

function OptionDownMgr:DelectFinishAsset(data)
	return OptionalDownload.Instance:DelectExistAsset(data)
end

function OptionDownMgr:CheckVideoExist(path)
	local path = string.lower(path)

	if not table.contains(OptionDownMgr.OptionDownVideoData, path) then
		return true
	end

	return OptionalDownload.Instance:CheckBundleExist(path)
end

function OptionDownMgr:CheckBundleExist(stageId, openFrom)
	local OptionDownData

	if openFrom == 1 then
		OptionDownData = OptionDownMgr.OptionDownStageData
	else
		OptionDownData = OptionDownMgr.OptionDownTopicData
	end

	if OptionDownData[stageId] == nil then
		return true
	end

	local bundleName = {}

	for i = 1, #OptionDownData[stageId].BundleName do
		table.insert(bundleName, string.lower(OptionDownData[stageId].BundleName[i]))
	end

	local bundleExist = OptionalDownload.Instance:CheckBundleExist(bundleName)
	local soundBanksExist = OptionalDownload.Instance:CheckBundleExist(OptionDownData[stageId].SoundBankName)

	if bundleExist and soundBanksExist then
		return true
	elseif not bundleExist and soundBanksExist then
		return false, eDownloadType.onlySound
	elseif not soundBanksExist and bundleExist then
		return false, eDownloadType.onlyVideo
	else
		return false, eDownloadType.none
	end
end

function OptionDownMgr:RequestDownload(stageId, finishCallback, errorCallback, progressCallback, downType, openFrom)
	local OptionDownData

	if openFrom == 1 then
		OptionDownData = OptionDownMgr.OptionDownStageData
	else
		OptionDownData = OptionDownMgr.OptionDownTopicData
	end

	if OptionDownData[stageId] == nil then
		return
	end

	local list = {}

	if downType == eDownloadType.all or downType == eDownloadType.onlyVideo then
		for i = 1, #OptionDownData[stageId].BundleName do
			table.insert(list, string.lower(OptionDownData[stageId].BundleName[i]))
		end
	end

	if downType == eDownloadType.all or downType == eDownloadType.onlySound then
		for i = 1, #OptionDownData[stageId].SoundBankName do
			table.insert(list, OptionDownData[stageId].SoundBankName[i])
		end
	end

	OptionDownMgr:RequestContantCallback(OptionDownMgr:GetKeyByStageID(stageId, openFrom), list, finishCallback, errorCallback, progressCallback, true, downType)
end

function OptionDownMgr:RequestDownloadVideo(id, finishCallback, errorCallback, progressCallback, path)
	local list = {}

	if id == 0 then
		for k, v in pairs(DownloadConfig) do
			for i = 1, #v.BundleName do
				table.insert(list, string.lower(v.BundleName[i]))
			end

			for i = 1, #v.SoundBankName do
				table.insert(list, v.SoundBankName[i])
			end
		end
	else
		table.insert(list, string.lower(path))
	end

	local key = OptionDownMgr:GetKeyByStageID(id, 3)

	OptionDownMgr:RequestContantCallback(key, list, finishCallback, errorCallback, progressCallback, false)
end

function OptionDownMgr:RequestContantCallback(id, list, finishCallback, errorCallback, progressCallback, isFirst, downType)
	self.continueDownloadList = {}

	local function tmpFinishCb()
		finishCallback()

		for i = #OptionDownMgr.CurDownloadList, 1, -1 do
			if id == OptionDownMgr.CurDownloadList[i][1] then
				table.remove(OptionDownMgr.CurDownloadList, i)

				break
			end
		end
	end

	local errorCallback = function(str)
		errorCallback(str)

		for i = #OptionDownMgr.CurDownloadList, 1, -1 do
			if id == OptionDownMgr.CurDownloadList[i][1] then
				table.insert(OptionDownMgr.continueDownloadList, OptionDownMgr.CurDownloadList[i])
				table.remove(OptionDownMgr.CurDownloadList, i)
			end
		end
	end
	local groupId = OptionalDownload.Instance:RequestOptionalDownload(list, progressCallback, tmpFinishCb, errorCallback, isFirst)

	table.insert(OptionDownMgr.CurDownloadList, {
		id,
		groupId,
		downType
	})
end

function OptionDownMgr:AddCallback(stageId, finishCallback, errorCallback, progressCallback, openFrom)
	local id = OptionDownMgr:GetKeyByStageID(stageId, openFrom)

	if id == nil then
		return
	end

	local function tmpFinishCb()
		finishCallback()

		for i = #OptionDownMgr.CurDownloadList, 1, -1 do
			if id == OptionDownMgr.CurDownloadList[i][1] then
				table.remove(OptionDownMgr.CurDownloadList, i)

				break
			end
		end
	end

	local errorCallback = function(str)
		errorCallback(str)

		for i = #OptionDownMgr.CurDownloadList, 1, -1 do
			if id == OptionDownMgr.CurDownloadList[i][1] then
				table.insert(OptionDownMgr.continueDownloadList, OptionDownMgr.CurDownloadList[i])
				table.remove(OptionDownMgr.CurDownloadList, i)
			end
		end
	end

	for i, v in ipairs(OptionDownMgr.CurDownloadList) do
		if v[1] == id then
			OptionalDownload.Instance:AddCallback(v[2], tmpFinishCb, errorCallback, progressCallback)

			break
		end
	end
end

OptionDownMgr.continueDownloadList = {}

function OptionDownMgr:RemoveCallback(stageId, openFrom)
	local id = OptionDownMgr:GetKeyByStageID(stageId, openFrom)

	if id == nil then
		return
	end

	local function tmpFinishCb()
		for i = #OptionDownMgr.CurDownloadList, 1, -1 do
			if id == OptionDownMgr.CurDownloadList[i][1] then
				table.remove(OptionDownMgr.CurDownloadList, i)

				break
			end
		end
	end

	local function errorCallback(str)
		for i = #OptionDownMgr.CurDownloadList, 1, -1 do
			if id == OptionDownMgr.CurDownloadList[i][1] then
				table.insert(OptionDownMgr.continueDownloadList, OptionDownMgr.CurDownloadList[i])
				table.remove(OptionDownMgr.CurDownloadList, i)
			end
		end
	end

	for i, v in ipairs(OptionDownMgr.CurDownloadList) do
		if v[1] == id then
			OptionalDownload.Instance:RemoveCallback(v[2])
			OptionalDownload.Instance:AddCallback(v[2], tmpFinishCb, errorCallback, progressCallback)

			break
		end
	end
end

function OptionDownMgr:CheckIsDownload(stageId, openFrom)
	local id = OptionDownMgr:GetKeyByStageID(stageId, openFrom)

	if id == nil then
		return
	end

	for i, v in ipairs(OptionDownMgr.CurDownloadList) do
		if v[1] == id then
			return OptionalDownload.Instance:CheckIsDownload(v[2]), v[3]
		end
	end

	return false
end

function OptionDownMgr:CancelOptionalDownload(stageId, openFrom)
	local id = OptionDownMgr:GetKeyByStageID(stageId, openFrom)

	if id == nil then
		return
	end

	for i = #OptionDownMgr.CurDownloadList, 1, -1 do
		if id == OptionDownMgr.CurDownloadList[i][1] then
			OptionalDownload.Instance:CancelOptionalDownload(OptionDownMgr.CurDownloadList[i][2])
			table.remove(OptionDownMgr.CurDownloadList, i)
		end
	end
end

function OptionDownMgr:GetAllDownSize()
	local list = {}

	for k, v in pairs(DownloadConfig) do
		for i = 1, #v.BundleName do
			table.insert(list, string.lower(v.BundleName[i]))
		end

		for i = 1, #v.SoundBankName do
			table.insert(list, v.SoundBankName[i])
		end
	end

	return OptionalDownload.Instance:GetOptionalDownloadSize(list)
end

function OptionDownMgr:CheckAll(callback)
	local list = {}

	for k, v in pairs(DownloadConfig) do
		for i = 1, #v.BundleName do
			table.insert(list, string.lower(v.BundleName[i]))
		end

		for i = 1, #v.SoundBankName do
			table.insert(list, v.SoundBankName[i])
		end
	end

	local exist = OptionalDownload.Instance:CheckBundleExist(list)

	if callback then
		callback(exist)
	end
end

function OptionDownMgr:GetDownSize(stageId, type, openFrom)
	local OptionDownData

	if openFrom == 1 then
		OptionDownData = OptionDownMgr.OptionDownStageData
	else
		OptionDownData = OptionDownMgr.OptionDownTopicData
	end

	local list = {}

	if type == eDownloadType.onlyVideo or type == eDownloadType.all then
		for i = 1, #OptionDownData[stageId].BundleName do
			table.insert(list, string.lower(OptionDownData[stageId].BundleName[i]))
		end
	end

	if type == eDownloadType.onlySound or type == eDownloadType.all then
		for i = 1, #OptionDownData[stageId].SoundBankName do
			table.insert(list, OptionDownData[stageId].SoundBankName[i])
		end
	end

	return OptionalDownload.Instance:GetOptionalDownloadSize(list)
end

function OptionDownMgr:GetAllAlreadyDownSize()
	local list = {}

	for k, v in pairs(DownloadConfig) do
		for i = 1, #v.BundleName do
			table.insert(list, string.lower(v.BundleName[i]))
		end

		for i = 1, #v.SoundBankName do
			table.insert(list, v.SoundBankName[i])
		end
	end

	return OptionalDownload.Instance:GetOptionalAlreadyDownloadSize(list)
end

function OptionDownMgr:DelectAlreadyDown()
	local list = {}

	for k, v in pairs(DownloadConfig) do
		for i = 1, #v.BundleName do
			table.insert(list, string.lower(v.BundleName[i]))
		end

		for i = 1, #v.SoundBankName do
			table.insert(list, v.SoundBankName[i])
		end
	end

	return OptionDownMgr:DelectFinishAsset(list)
end

function OptionDownMgr:ContinueDownload()
	for k, v in pairs(self.continueDownloadList) do
		table.insert(self.CurDownloadList, v)
	end

	self.continueDownloadList = {}

	OptionalDownload.Instance:ContinueDownload()
end

function OptionDownMgr:CancleContinueDownload()
	OptionalDownload.Instance:CancleContinueDownload()

	OptionDownMgr.CurDownloadList = {}
	self.continueDownloadList = {}
end
