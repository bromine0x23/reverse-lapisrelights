-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Util/Enum.lua

eJobType = {
	Artifice = 2,
	Intelligence = 4,
	Assistance = 5,
	Speed = 3,
	Strength = 1
}

function GetJobType(strJob)
	if strJob == "Strength" then
		return eJobType.Strength
	elseif strJob == "Assistance" then
		return eJobType.Assistance
	elseif strJob == "Intelligence" then
		return eJobType.Intelligence
	elseif strJob == "Speed" then
		return eJobType.Speed
	elseif strJob == "Artifice" then
		return eJobType.Artifice
	end

	return eJobType.Strength
end

eSkillNodeType = {
	attri = 1,
	avatar = 3,
	item = 2,
	skill = 4
}
eEquipSlotType = {
	Head = 3,
	Hand = 4,
	Weapon = 1,
	Ring = 2,
	Ear = 5,
	Breast = 6
}
eChapterType = {
	bosslive = 102,
	tower = 101,
	main = 1,
	union = 100,
	role = 3,
	activity = 4,
	team = 2,
	mainhard = 6,
	bossRaid = 103,
	card = 5
}
eStageType = {
	common = 1,
	unionCommon = 7,
	bossRaid = 10,
	bossLive = 3,
	activeBoss = 4,
	unionBoss = 6,
	activeCommon = 5,
	story = 2
}
eAllSkillType = {
	system = 2,
	battle = 1
}
eBattleSkillType = {
	specialAction = 6,
	center = 3,
	attackAction = 4,
	union = 8,
	link = 7,
	none = 0,
	passive = 2,
	thumpAction = 5,
	active = 1
}
eValueType = {
	Abs = 1,
	Per = 2
}
