-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/PersistentStoreUtil.lua

PersistentStoreUtil = {}
PersistentStoreUtil.KEY_AUTHORIZE_ID = "KEY_AUTHORIZE_ID"
PersistentStoreUtil.PUSH_TOKEN = "PUSH_TOKEN"
PersistentStoreUtil.KEY_CREATED_PLAYER = "KEY_CREATED_PLAYER"
PersistentStoreUtil.PerformUnLock = "PerformUnLock"
PersistentStoreUtil.PerformGroupSelectMode = "PerformGroupSelectMode"
PersistentStoreUtil.SupportPlayed = "SupportPlayed"
PersistentStoreUtil.LastSelectPerformGroupID = "LastSelectPerformGroupID"
PersistentStoreUtil.SpecialPerformGroupSelectMode = "SpecialPerformGroupSelectMode"
PersistentStoreUtil.LastSelectSpecialPerformGroupID = "LastSelectSpecialPerformGroupID"
PersistentStoreUtil.SupportPlayed = "SupportPlayed"
PersistentStoreUtil.LastViewFavorRank = "LastViewFavorRank"
PersistentStoreUtil.FavorMotionUnLock = "FavorMotionUnLock"
PersistentStoreUtil.KEY_LIST_FAVOR_POP = "KEY_LIST_FAVOR_POP"
PersistentStoreUtil.KEY_STAGE_UNLOCKED = "KEY_STAGE_UNLOCKED"
PersistentStoreUtil.KEY_FIGHT_AUTO_MODE = "KEY_FIGHT_AUTO_MODE"
PersistentStoreUtil.KEY_FIGHT_SPEED_MODE = "KEY_FIGHT_SPEED_MODE"
PersistentStoreUtil.KEY_FIGHT_SKIP_TL_MODE = "KEY_FIGHT_SKIP_TL_MODE"
PersistentStoreUtil.KEY_FAVOR_STORY_UNLOCKED = "KEY_FAVOR_STORY_UNLOCKED"
PersistentStoreUtil.KEY_FAVOR_STORY_ENTER = "KEY_FAVOR_STORY_ENTER"
PersistentStoreUtil.KEY_CHAPTER_ENTER = "KEY_CHAPTER_ENTER_"
PersistentStoreUtil.KEY_STAGE_ENTER = "KEY_STAGE_ENTER_"
PersistentStoreUtil.KEY_TEAM_ENTER = "KEY_TEAM_ENTER_"
PersistentStoreUtil.KEY_ACTIVE_ASSET = "KEY_ACTIVE_ASSET"
PersistentStoreUtil.KEY_ACTIVE_BOSS = "KEY_ACTIVE_BOSS"
PersistentStoreUtil.KEY_DAY_TIME_REFRESH = "KEY_DAY_TIME_REFRESH"
PersistentStoreUtil.KEY_NEW_ROLE_CARD = "KEY_NEW_ROLE_CARD"
PersistentStoreUtil.KEY_NEW_ROLE = "KEY_NEW_ROLE"
PersistentStoreUtil.KEY_ROLE_CARD_SELECT = "KEY_ROLE_CARD_SELECT"
PersistentStoreUtil.KEY_TEAM_LIST_INDEX = "KEY_TEAM_LIST_INDEX"
PersistentStoreUtil.KEY_SCENE_SELECT_ID = "KEY_SCENE_SELECT_ID"
PersistentStoreUtil.KEY_BATTLE_ENUM_ID = "KEY_BATTLE_ENUM_ID"
PersistentStoreUtil.KEY_BATTLE_HARD_ENUM_ID = "KEY_BATTLE_HARD_ENUM_ID"
PersistentStoreUtil.KEY_BATTLE_TYPE_ENUM_ID = "KEY_BATTLE_TYPE_ENUM_ID"
PersistentStoreUtil.KEY_BATTLE_COMMON_TEAM_ROLE_LIST = "KEY_BATTLE_COMMON_TEAM_ROLE_LIST"
PersistentStoreUtil.KEY_BATTLE_COMMON_TEAM_ROLE_CARD_LIST = "KEY_BATTLE_COMMON_TEAM_ROLE_CARD_LIST"
PersistentStoreUtil.KEY_ROLE_HEART_STATE = "KEY_ROLE_HEART_STATE"
PersistentStoreUtil.KEY_ROLE_HEART_FIRST_STATE = "KEY_ROLE_HEART_FIRST_STATE"
PersistentStoreUtil.KEY_ROLE_ICON_FIRST_STATE = "KEY_ROLE_ICON_FIRST_STATE"
PersistentStoreUtil.KEY_TIP_WINDOW_ONGAME_STADE = "KEY_TIP_WINDOW_ONGAME_STADE"
PersistentStoreUtil.KEY_ROLE_CARD_ICON_FIRST_STATE = "KEY_ROLE_CARD_ICON_FIRST_STATE"
PersistentStoreUtil.KEY_BOSS_LIVE_CURINDEX_STADE = "KEY_BOSS_LIVE_CURINDEX_STADE"
PersistentStoreUtil.KEY_BOSS_LIVE_CURINDEX_STADE = "KEY_BOSS_LIVE_CURINDEX_STADE"
PersistentStoreUtil.KEY_COMMON_INTEGEALPOINT_LIMIT_DOT_LIST = "KEY_COMMON_INTEGEALPOINT_LIMIT_DOT_LIST"
PersistentStoreUtil.KEY_TIP_WINDOW_STADE = "KEY_TIP_WINDOW_STADE"
PersistentStoreUtil.KEY_TIP_WINDOW_VIDEO_STADE = "KEY_TIP_WINDOW_VIDEO_STADE"
PersistentStoreUtil.KEY_TIP_WINDOW_AWARD_STADE = "KEY_TIP_WINDOW_AWARD_STADE"
PersistentStoreUtil.KEY_TIP_WINDOW_PAT_FACE_STADE = "KEY_TIP_WINDOW_PAT_FACE_STADE"
PersistentStoreUtil.KEY_TIP_WINDOW_AWARD_SIGN_STADE = "KEY_TIP_WINDOW_AWARD_SIGN_STADE"
PersistentStoreUtil.KEY_LUCKY_BACK_ITEM_PRODUCT_LIST = "KEY_LUCKY_BACK_ITEM_PRODUCT_LIST"
PersistentStoreUtil.KEY_OPTIONAL_ASSET_AUTO_DELECT = "KEY_OPTIONAL_ASSET_AUTO_DELECT"
PersistentStoreUtil.KEY_PLAYER_BIRTHDAY_STATE = "KEY_PLAYER_BIRTHDAY_STATE"
PersistentStoreUtil.KEY_BOSSACTIVITY_DOT_STATE = "KEY_BOSSACTIVITY_DOT_STATE"
PersistentStoreUtil.KEY_WEBVIEW_TIME_STADE = "KEY_WEBVIEW_TIME_STADE"
PersistentStoreUtil.KEY_NEXT_STAGE_SHOW = "KEY_NEXT_STAGE_SHOW"
PersistentStoreUtil.KEY_WEBVIEW_TIME = "KEY_WEBVIEW_TIME"
PersistentStoreUtil.KEY_BOSSACTIVITY_ENTER_STATE = "KEY_BOSSACTIVITY_ENTER_STATE"
PersistentStoreUtil.KEY_PICTURE_ROLECARD_SKILLID = "KEY_PICTURE_ROLECARD_SKILLID"
PersistentStoreUtil.KEY_PICTURE_ROLECARD_PICTURE = "KEY_PICTURE_ROLECARD_PICTURE"
PersistentStoreUtil.KEY_PICTURE_VIDEO = "KEY_PICTURE_VIDEO"
PersistentStoreUtil.KEY_PICTURE_SONG = "KEY_PICTURE_SONG"
PersistentStoreUtil.KEY_PICTURE_ROLE = "KEY_PICTURE_ROLE"
PersistentStoreUtil.KEY_DLGTHEME_OPEN_STATE = "KEY_DLGTHEME_OPEN_STATE"
PersistentStoreUtil.KEY_RANK_DOT_STATE = "KEY_RANK_DOT_STATE"
PersistentStoreUtil.KEY_ROLE_NEW_AVATAR = "KEY_ROLE_NEW_AVATAR"
PersistentStoreUtil.KEY_NEW_PHONE_CALL = "KEY_NEW_PHONE_CALL"
PersistentStoreUtil.KEY_NEW_TOPIC = "KEY_NEW_TOPIC"
PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG = "KEY_OPEN_PHONE_CALL_MSG"
PersistentStoreUtil.KEY_OPEN_FIRST_CHARGE = "KEY_OPEN_FIRST_CHARGE"
PersistentStoreUtil.KEY_VIEW_TIME_LAST = "KEY_VIEW_TIME_LAST"
PersistentStoreUtil.KEY_CHOOSE_START_CARD_STATE = "KEY_CHOOSE_START_CARD_STATE"
PersistentStoreUtil.KEY_NEWBIE_STAGEID = "KEY_NEWBIE_STAGEID"
PersistentStoreUtil.KEY_ACTIVITY_POOL_COUNT_SETTING = "KEY_ACTIVITY_POOL_COUNT_SETTING"
PersistentStoreUtil.KEY_ACCOUNT_DELETED = "KEY_ACCOUNT_DELETED"
ePSKey = {
	Dot_Player_Head = "Dot_Player_Head",
	Dot_Bag = "Dot_Bag",
	Dot_PVP = "Dot_PVP",
	Dot_WORK = "Dot_WORK",
	Dot_FRIEND = "Dot_FRIEND",
	Dot_TASK = "Dot_TASK",
	Dot_THEME = "Dot_THEME",
	Dot_MAIL = "Dot_MAIL",
	SceneId = "SceneId",
	Dot_BossRaid = "Dot_BossRaid",
	Dot_SHOP = "Dot_SHOP",
	Dot_SMS_CALL = "Dot_SMS_CALL",
	Dot_BONDAGE = "Dot_BONDAGE"
}

function PersistentStoreUtil.HasBool(vKey)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. vKey, -1) ~= -1
end

function PersistentStoreUtil.GetBool(vKey, vDefaultValue)
	vDefaultValue = vDefaultValue and 1 or 0

	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. vKey, vDefaultValue) == 1
end

function PersistentStoreUtil.SetBool(vKey, vBoolValue)
	vBoolValue = vBoolValue and 1 or 0

	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. vKey, vBoolValue)
end

function PersistentStoreUtil.SetFloat(vKey, vValue)
	PlayerPrefs.SetFloat(PlayerInst.InfoPlayer.pid .. vKey, vValue)
end

function PersistentStoreUtil.GetFloat(vKey, vValue)
	return PlayerPrefs.GetFloat(PlayerInst.InfoPlayer.pid .. vKey, vValue)
end

function PersistentStoreUtil.SetInt(vKey, vValue)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. vKey, vValue)
end

function PersistentStoreUtil.GetInt(vKey)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. vKey)
end

function PersistentStoreUtil.GetString(vKey)
	return PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. vKey, "")
end

function PersistentStoreUtil.SetString(vKey, str)
	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. vKey, str)
end

function PersistentStoreUtil.WrapList(listValue)
	local str = ""

	for i = 1, #listValue do
		if i == 1 then
			str = listValue[i]
		else
			str = str .. "," .. listValue[i]
		end
	end

	return str
end

function PersistentStoreUtil.UnWrapList(strListValue)
	local list = string.split(strListValue, ",")

	return list
end

function PersistentStoreUtil.SetList(key, list)
	for i = 1, #list do
		PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. key .. i, list[i])
	end

	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. key .. "Count", #list)
end

function PersistentStoreUtil.DelList(key)
	local list = PersistentStoreUtil.GetList(key)

	for i = 1, #list do
		PlayerPrefs.DeleteKey(PlayerInst.InfoPlayer.pid .. key .. i)
	end

	PlayerPrefs.DeleteKey(PlayerInst.InfoPlayer.pid .. key .. "Count")
end

function PersistentStoreUtil.AddList(key, value)
	local count = PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. key .. "Count")

	count = count + 1

	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. key .. count, value)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. key .. "Count", count)
end

function PersistentStoreUtil.PopList(key)
	local count = PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. key .. "Count")

	count = count - 1

	if count - 1 <= 0 then
		count = 0
	end

	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. key .. "Count", count)
end

function PersistentStoreUtil.GetList(key)
	local list = {}
	local count = PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. key .. "Count")
	local s = ""

	for i = 1, count do
		local v = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. key .. i, "")

		table.insert(list, v)
	end

	return list
end

function PersistentStoreUtil.GetListCount(key)
	local count = PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. key .. "Count")

	return count
end

function PersistentStoreUtil.GetTeamEnter(teamId)
	local temp = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_TEAM_ENTER .. teamId, false)

	return temp
end

function PersistentStoreUtil.SetTeamEnter(teamId, value)
	return PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_TEAM_ENTER .. teamId, value)
end

function PersistentStoreUtil.GetChapterEnter(chapterId)
	local temp = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_CHAPTER_ENTER .. chapterId, false)

	return temp
end

function PersistentStoreUtil.SetChapterEnter(chapterId, value)
	return PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_CHAPTER_ENTER .. chapterId, value)
end

function PersistentStoreUtil.GetStageEnter(stageId)
	local temp = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_STAGE_ENTER .. stageId, false)

	return temp
end

function PersistentStoreUtil.SetStageEnter(stageId, value)
	return PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_STAGE_ENTER .. stageId, value)
end

function PersistentStoreUtil.GetAssetActiveEnter(assetId)
	local temp = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_ACTIVE_ASSET .. assetId, false)

	return temp
end

function PersistentStoreUtil.SetAssetActiveEnter(assetId, value)
	return PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_ACTIVE_ASSET .. assetId, value)
end

function PersistentStoreUtil.GetBossActiveEnter()
	local temp = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_ACTIVE_BOSS, false)

	return temp
end

function PersistentStoreUtil.SetBossActiveEnter(value)
	return PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_ACTIVE_BOSS, value)
end

function PersistentStoreUtil.GetSkillNodeClicked(id)
	local temp = PersistentStoreUtil.GetBool("SNClicked" .. id, false)

	return temp
end

function PersistentStoreUtil.SetSkillNodeClicked(id, vValue)
	return PersistentStoreUtil.SetBool("SNClicked" .. id, vValue)
end

function PersistentStoreUtil.GetMissOffset()
	local temp = PersistentStoreUtil.GetFloat("MissOffset", 0.3)

	temp = math.floor(temp * 100)

	return temp / 100
end

function PersistentStoreUtil.SetMissOffset(vValue)
	return PersistentStoreUtil.SetFloat("MissOffset", vValue)
end

function PersistentStoreUtil.GetPerfectOffset()
	local temp = PersistentStoreUtil.GetFloat("PerfectOffset", 0)

	return temp
end

function PersistentStoreUtil.SetPerfectOffset(vValue)
	return PersistentStoreUtil.SetFloat("PerfectOffset", vValue)
end

function PersistentStoreUtil.GetPerfectTimeOffset()
	local temp = PersistentStoreUtil.GetFloat("PerfectTimeOffset", 0)

	return temp
end

function PersistentStoreUtil.SetPerfectTimeOffset(vValue)
	return PersistentStoreUtil.SetFloat("PerfectTimeOffset", vValue)
end

function PersistentStoreUtil.GetIsAutoHit()
	return PersistentStoreUtil.GetBool("IsAutoHit", false)
end

function PersistentStoreUtil.SetIsAutoHit(vValue)
	return PersistentStoreUtil.SetBool("IsAutoHit", vValue)
end

function PersistentStoreUtil.SetIsNoticeAd(vValue)
	PersistentStoreUtil.SetNoticeAdTime(NetData:GetCurServerTime())

	return PersistentStoreUtil.SetBool("IsNoticeAd", vValue)
end

function PersistentStoreUtil.GetIsNoticeAd()
	local time = PersistentStoreUtil.GetNoticeAdTime()

	if time == 0 then
		return true
	elseif not TimeIsNotToday(time) then
		return PersistentStoreUtil.GetBool("IsNoticeAd", true)
	else
		return true
	end
end

function PersistentStoreUtil.GetNoticeAdTime()
	local temp = PersistentStoreUtil.GetFloat("NoticeAdTime", 0)

	return temp
end

function PersistentStoreUtil.SetNoticeAdTime(vValue)
	return PersistentStoreUtil.SetFloat("NoticeAdTime", vValue)
end

function PersistentStoreUtil.GetGameSoundState()
	return PlayerPrefs.GetInt("GameSoundState", 1)
end

function PersistentStoreUtil.SetGameSoundState(vValue)
	return PlayerPrefs.SetInt("GameSoundState", vValue)
end

function PersistentStoreUtil.GetRoleSkinUseState(roleIdSkinId)
	return PersistentStoreUtil.GetBool("SkinState" .. roleIdSkinId, false)
end

function PersistentStoreUtil.SetRoleSkinUseState(roleIdSkinId, vValue)
	PersistentStoreUtil.SetBool("SkinState" .. roleIdSkinId, vValue)
end

function PersistentStoreUtil.GetGameMusicState()
	return PersistentStoreUtil.GetInt("GameMusicState", 1)
end

function PersistentStoreUtil.SetGameMusicState(vValue)
	return PersistentStoreUtil.SetInt("GameMusicState", vValue)
end

function PersistentStoreUtil.GetSavePowerdState()
	return PersistentStoreUtil.GetBool("SavePowerdState", false)
end

function PersistentStoreUtil.SetSavePowerdState(vValue)
	return PersistentStoreUtil.SetBool("SavePowerdState", vValue)
end

function PersistentStoreUtil.GetAntiAliasing()
	return PersistentStoreUtil.GetBool("AntiAliasing", true)
end

function PersistentStoreUtil.SetAntiAliasing(vValue)
	return PersistentStoreUtil.SetBool("AntiAliasing", vValue)
end

function PersistentStoreUtil.GetHighFPSMode()
	return PersistentStoreUtil.GetBool("HighFPSMode", true)
end

function PersistentStoreUtil.SetHighFPSMode(vValue)
	return PersistentStoreUtil.SetBool("HighFPSMode", vValue)
end

function PersistentStoreUtil.GetIsHideBarrage()
	return PersistentStoreUtil.GetBool("IsHideBarrage", false)
end

function PersistentStoreUtil.SetIsHideBarrage(vValue)
	return PersistentStoreUtil.SetBool("IsHideBarrage", vValue)
end

function PersistentStoreUtil.GetUnlockChapterId()
	return PersistentStoreUtil.GetInt("UnlockChapterId")
end

function PersistentStoreUtil.SetUnlockChapterId(vValue)
	PersistentStoreUtil.SetInt("UnlockChapterId", vValue)
end

function PersistentStoreUtil.GetUnlockStageId()
	return PersistentStoreUtil.GetInt("UnlockStageId")
end

function PersistentStoreUtil.SetUnlockStageId(vValue)
	PersistentStoreUtil.SetInt("UnlockStageId", vValue)
end

function PersistentStoreUtil.GetGameSoundValue()
	return PlayerPrefs.GetInt("GameSoundValue", 3)
end

function PersistentStoreUtil.SetGameSoundValue(vValue)
	PlayerPrefs.SetInt("GameSoundValue", vValue)
end

function PersistentStoreUtil.Get3DGameQuality()
	return PlayerPrefs.GetInt("3DGameQuality", 1)
end

function PersistentStoreUtil.Set3DGameQuality(vValue)
	PlayerPrefs.SetInt("3DGameQuality", vValue)
end

function PersistentStoreUtil.Get3DDanceQuality()
	return PlayerPrefs.GetInt("3DDanceQuality", 1)
end

function PersistentStoreUtil.Set3DDanceQuality(vValue)
	PlayerPrefs.SetInt("3DDanceQuality", vValue)
end

function PersistentStoreUtil.GetLastSelectChapter()
	return PersistentStoreUtil.GetInt("LastSelectChapter")
end

function PersistentStoreUtil.SetLastSelectChapter(value)
	PersistentStoreUtil.SetInt("LastSelectChapter", value)
end

function PersistentStoreUtil.GetIsCloseStory()
	return PersistentStoreUtil.GetBool("IsCloseStory", false)
end

function PersistentStoreUtil.SetIsCloseStory(value)
	PersistentStoreUtil.SetBool("IsCloseStory", value)
end

function PersistentStoreUtil.SetIntonationOffset(vValue)
	PersistentStoreUtil.SetFloat("IntonationOffset", vValue)
end

function PersistentStoreUtil.GetIntonationOffset()
	local v = PersistentStoreUtil.GetFloat("IntonationOffset", 0)

	return v
end

function PersistentStoreUtil.GetTutorialView(id)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. "tutView" .. id)
end

function PersistentStoreUtil.SetTutorialView(id)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. "tutView" .. id, 1)
end

function PersistentStoreUtil.GetUnlockTip(id)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. "UnlockTip" .. id)
end

function PersistentStoreUtil.SetUnlockTip(id)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. "UnlockTip" .. id, 1)
end

function PersistentStoreUtil.GetFansInfo(fansIdx)
	return PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.FansInfo .. fansIdx, "")
end

function PersistentStoreUtil.SetFansInfo(fansIdx, strInfo)
	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.FansInfo .. fansIdx, strInfo)
end

function PersistentStoreUtil.SavePlayerInfo(playerID, info)
	PlayerPrefs.SetString("playerInfo" .. playerID, info)
end

function PersistentStoreUtil.GetPlayerInfo(playerID)
	PlayerPrefs.GetString("playerInfo" .. playerID, "")
end

function PersistentStoreUtil.SetDownloadFileHash(fileName, Hash, otherKey)
	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. fileName, Hash)
end

function PersistentStoreUtil.GetDownloadFileHash(fileName)
	return PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. fileName, "")
end

function PersistentStoreUtil.GetPerformUnLock(performID)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PerformUnLock .. performID, 0)
end

function PersistentStoreUtil.SetPerformUnLock(performID, unlock)
	return PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PerformUnLock .. performID, unlock)
end

function PersistentStoreUtil.GetPerformGroupSelectMode(groupID)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PerformGroupSelectMode .. groupID, 1)
end

function PersistentStoreUtil.SetPerformGroupSelectMode(groupID, modeType)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PerformGroupSelectMode .. groupID, modeType)
end

function PersistentStoreUtil.IsSupportPlayed(supportID)
	return PersistentStoreUtil.GetBool(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.SupportPlayed .. supportID, false)
end

function PersistentStoreUtil.SetSupportPlayed(supportID, isPlayed)
	PersistentStoreUtil.SetBool(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.SupportPlayed .. supportID, isPlayed)
end

function PersistentStoreUtil.GetLastSelectPerformGroupID()
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.LastSelectPerformGroupID, 1)
end

function PersistentStoreUtil.SetLastSelectPerformGroupID(groupID)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.LastSelectPerformGroupID, groupID)
end

function PersistentStoreUtil.GetSpecialPerformGroupSelectMode(groupID)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.SpecialPerformGroupSelectMode .. groupID, 1)
end

function PersistentStoreUtil.SetSpecialPerformGroupSelectMode(groupID, modeType)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.SpecialPerformGroupSelectMode .. groupID, modeType)
end

function PersistentStoreUtil.GetLastSelectSpecialPerformGroupID(activeID)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.LastSelectSpecialPerformGroupID .. activeID, 1)
end

function PersistentStoreUtil.SetLastSelectSpecialPerformGroupID(activeID, groupID)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.LastSelectSpecialPerformGroupID .. activeID, groupID)
end

function PersistentStoreUtil.GetLastViewFavorRank(roleID)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. roleID .. PersistentStoreUtil.LastViewFavorRank, 1)
end

function PersistentStoreUtil.SetLastViewFavorRank(roleID, rank)
	return PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. roleID .. PersistentStoreUtil.LastViewFavorRank, rank)
end

function PersistentStoreUtil.FavorMotionIsUnLock(roleID, motionID)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. roleID .. "_" .. motionID .. "_" .. PersistentStoreUtil.FavorMotionUnLock, 0)
end

function PersistentStoreUtil.SetFavorMotionUnLock(roleID, motionID, unLock)
	return PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. roleID .. "_" .. motionID .. "_" .. PersistentStoreUtil.FavorMotionUnLock, unLock)
end

function PersistentStoreUtil.GetTaskState(taskType)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. tostring(taskType), 0)
end

function PersistentStoreUtil.SetTaskState(taskType, value)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. tostring(taskType), value)
end

function PersistentStoreUtil.SetTaskStateNum(taskType)
	local num = PersistentStoreUtil.GetTaskState(taskType) + 1

	PersistentStoreUtil.SetTaskState(taskType, num)
end

function PersistentStoreUtil.SetMailReadState(mailId, state)
	PersistentStoreUtil.SetBool(PlayerInst.InfoPlayer.pid .. tostring(mailId), state)
end

function PersistentStoreUtil.GetMailReadState(mailId)
	return PersistentStoreUtil.GetBool(PlayerInst.InfoPlayer.pid .. tostring(mailId), false)
end

function PersistentStoreUtil.GetSongDownloadState(songName)
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. tostring(songName), 0)
end

function PersistentStoreUtil.SetSongDownloadState(songName, value)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. tostring(songName), value)
end

function PersistentStoreUtil.SavePVPLog(infoChar1, infoChar2, score, isWin, targetPlayerName)
	local formatStr = ""
	local secondJob = infoChar2:IsOwnSecondJob()
	local ownSecondJob = 0

	if secondJob then
		ownSecondJob = 1
	end

	formatStr = "R0ID:" .. infoChar1.id .. " " .. "R0LV:" .. infoChar1:GetLevel() .. " " .. "R0Star:" .. infoChar1:GetStarCount() .. " "
	formatStr = formatStr .. "R1ID:" .. infoChar2.id .. " " .. "R1LV:" .. infoChar2:GetLevel() .. " " .. "R1Star:" .. infoChar2:GetStarCount() .. " " .. "R1SecondJob:" .. ownSecondJob .. " "
	formatStr = formatStr .. "Score:" .. score .. " " .. "Name:" .. targetPlayerName .. " " .. "IsWin:" .. isWin

	local curMaxID = PersistentStoreUtil.GetPVPLogMaxID()
	local curLogNum = PersistentStoreUtil.GetPVPLogNum()
	local maxLogNumLimit = DataManager.Instance:GetConfigArgInt("PVPMaxLogNum")

	if curLogNum == maxLogNumLimit then
		local deleteID = curMaxID - maxLogNumLimit + 1

		PlayerPrefs.DeleteKey(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PVPLogInfo .. deleteID)
	else
		PersistentStoreUtil.SetPVPLogNum(curLogNum + 1)
	end

	curMaxID = curMaxID + 1

	PersistentStoreUtil.SetPVPLogMaxID(curMaxID)
	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PVPLogInfo .. curMaxID, formatStr)
end

function PersistentStoreUtil.GetPVPLogInfo(logID)
	local str = PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PVPLogInfo .. logID, "")
	local r0 = {}
	local r1 = {}
	local other = {}
	local strTemp = string.match(str, "R0ID:%d+")

	r0.id = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))
	strTemp = string.match(str, "R0LV:%d+")
	r0.Lv = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))

	string.match(str, "R0Star:%d+")

	r0.StarNum = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))
	strTemp = string.match(str, "R1ID:%d+")
	r1.id = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))
	strTemp = string.match(str, "R1LV:%d+")

	if strTemp ~= nil then
		r1.Lv = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))
	end

	strTemp = string.match(str, "R1Star:%d+")
	r1.StarNum = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))
	strTemp = string.match(str, "R1SecondJob:%d+")
	r1.SecondJob = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))
	strTemp = string.match(str, "Score:%d+")
	other.Score = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))
	strTemp = string.match(str, "Name:%S+")

	if strTemp ~= nil then
		other.Name = string.sub(strTemp, string.find(strTemp, ":") + 1)
	end

	strTemp = string.match(str, "IsWin:%d+")
	other.IsWin = tonumber(string.sub(strTemp, string.find(strTemp, ":") + 1))

	return r0, r1, other
end

function PersistentStoreUtil.GetPVPLogNum()
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PVPLogNum, 0)
end

function PersistentStoreUtil.SetPVPLogNum(num)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PVPLogNum, num)
end

function PersistentStoreUtil.GetPVPLogMaxID()
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PVPLogMaxID, 0)
end

function PersistentStoreUtil.SetPVPLogMaxID(num)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. PersistentStoreUtil.PVPLogMaxID, num)
end

function PersistentStoreUtil.Set2DMainShowSeat(vValue)
	PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. "2DMainShowSeat", vValue)
end

function PersistentStoreUtil.Get2DMainShowSeat()
	return PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. "2DMainShowSeat", 1)
end

function PersistentStoreUtil.SetBondageDotRefreshTime(combId, timeSec)
	PlayerPrefs.SetString(PlayerInst.InfoPlayer.pid .. ePSKey.Dot_BONDAGE .. combId, "" .. timeSec)
end

function PersistentStoreUtil.GetBondageDotRefreshTime(combId)
	return PlayerPrefs.GetString(PlayerInst.InfoPlayer.pid .. ePSKey.Dot_BONDAGE .. combId, "0")
end
