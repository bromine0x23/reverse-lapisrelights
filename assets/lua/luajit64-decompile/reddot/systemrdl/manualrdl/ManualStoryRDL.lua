-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ManualRDL/ManualStoryRDL.lua

local VideoData = require("luaData/VideoData")
local SongData = require("luaData/SongSubtitleData")
local ManualStoryRDL = {}
local RD_Manual_Story_Branch_Path = {
	Video = "Arrow/Manual/Story/Video",
	Song = "Arrow/Manual/Story/Song/%d"
}
local ALL_SONG_STAGE = {}
local ALL_VIDEO_STAGE = {}
local CAN_RECEIVE_SONG = {}
local CAN_RECEIVE_VIDEO = {}

function ManualStoryRDL.Init()
	CAN_RECEIVE_SONG = {}
	CAN_RECEIVE_VIDEO = {}

	local t = CollectionManager.videoAwardList or {}

	for _, video in ipairs(VideoData) do
		local stage = ChapterMgr:GetStage(video.UnlockStageId)

		ALL_VIDEO_STAGE[video.UnlockStageId] = ALL_VIDEO_STAGE[video.UnlockStageId] or {}

		if stage:IsPass() and not table.contains(t, video.ID) then
			table.insert(CAN_RECEIVE_VIDEO, video.ID)
		end

		if not table.contains(ALL_VIDEO_STAGE[video.UnlockStageId], video.ID) then
			table.insert(ALL_VIDEO_STAGE[video.UnlockStageId], video.ID)
		end
	end

	t = CollectionManager.songAwardList or {}

	for _, song in ipairs(SongData) do
		local stage = ChapterMgr:GetStage(song.UnlockStageId)

		if stage:IsPass() and not table.contains(t, song.ID) then
			CAN_RECEIVE_SONG[song.Team] = CAN_RECEIVE_SONG[song.Team] or {}

			table.insert(CAN_RECEIVE_SONG[song.Team], song.ID)
		end

		ALL_SONG_STAGE[song.UnlockStageId] = song.ID
	end

	ManualStoryRDL.InitRD()
end

function ManualStoryRDL.InitRD()
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Manual_Story_Branch_Path.Video, #CAN_RECEIVE_VIDEO)

	for k, v in pairs(CAN_RECEIVE_SONG) do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Manual_Story_Branch_Path.Song, #v, k)
	end
end

function ManualStoryRDL.AddVideo(_id)
	if table.contains(CAN_RECEIVE_VIDEO, _id) then
		return
	end

	table.insert(CAN_RECEIVE_VIDEO, _id)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Manual_Story_Branch_Path.Video, 1)
end

function ManualStoryRDL.SubVideo(_id)
	if not table.contains(CAN_RECEIVE_VIDEO, _id) then
		return
	end

	table.removeByValue(CAN_RECEIVE_VIDEO, _id)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Manual_Story_Branch_Path.Video, -1)
end

function ManualStoryRDL.AddSong(_id)
	local combid = SongData[_id].Team

	CAN_RECEIVE_SONG[combid] = CAN_RECEIVE_SONG[combid] or {}

	if table.contains(CAN_RECEIVE_SONG[combid], _id) then
		return
	end

	table.insert(CAN_RECEIVE_SONG[combid], _id)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Manual_Story_Branch_Path.Song, 1, combid)
end

function ManualStoryRDL.SubSong(_id)
	local combid = SongData[_id].Team

	CAN_RECEIVE_SONG[combid] = CAN_RECEIVE_SONG[combid] or {}

	if not table.contains(CAN_RECEIVE_SONG[combid], _id) then
		return
	end

	table.removeByValue(CAN_RECEIVE_SONG[combid], _id)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Manual_Story_Branch_Path.Song, -1, combid)
end

function ManualStoryRDL.DealWith(_stageId)
	if ALL_VIDEO_STAGE[_stageId] then
		for _, videoId in pairs(ALL_VIDEO_STAGE[_stageId]) do
			ManualStoryRDL.AddVideo(videoId)
		end
	end

	local songId = ALL_SONG_STAGE[_stageId]

	if songId ~= nil then
		ManualStoryRDL.AddSong(songId)
	end
end

function ManualStoryRDL.Get_CAN_RECEIVE_SONG()
	return CAN_RECEIVE_SONG
end

function ManualStoryRDL.Get_CAN_RECEIVE_VIDEO()
	return CAN_RECEIVE_VIDEO
end

return ManualStoryRDL
