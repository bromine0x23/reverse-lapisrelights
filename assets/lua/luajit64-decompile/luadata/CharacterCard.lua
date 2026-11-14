-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CharacterCard.lua

local CharacterCardInfo = {
	ID = {
		type = "integer"
	},
	CharacterID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	NameSpe = {
		type = "integer"
	},
	NameIcon = {
		type = "text"
	},
	Version = {
		default = "0",
		type = "integer"
	},
	Publish_At = {
		type = "text"
	},
	ShowInfo = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Rank = {
		type = "text"
	},
	CardTag = {
		default = "[]",
		type = "array"
	},
	AbilityList = {
		default = "[]",
		type = "array"
	},
	SessionWeight = {
		default = "[]",
		type = "array"
	},
	SpecialAtkSkill = {
		default = "0",
		type = "integer"
	},
	RoleStar = {
		type = "text"
	},
	HeadIcon = {
		type = "text"
	},
	SmallIcon = {
		type = "text"
	},
	BattleIcon = {
		type = "text"
	},
	MidIcon = {
		type = "text"
	},
	Icon = {
		type = "text"
	},
	FullIcon = {
		type = "text"
	},
	HitIcon = {
		type = "text"
	},
	SupportIcon = {
		type = "text"
	},
	Drift = {
		default = "[]",
		type = "array"
	},
	Rotate = {
		default = "[]",
		type = "array"
	},
	Scale = {
		default = "[]",
		type = "array"
	},
	StageMoveType = {
		type = "integer"
	},
	StarTalent = {
		default = "[]",
		type = "array"
	},
	StarReward = {
		default = "[]",
		type = "array"
	},
	StarUnlockAvatar = {
		default = "[]",
		type = "array"
	},
	BaseAttribute = {
		default = "[]",
		type = "array"
	},
	LevelAttribute = {
		default = "[]",
		type = "array"
	},
	LevelRatio1 = {
		default = "[]",
		type = "array"
	},
	LevelConstant1 = {
		default = "[]",
		type = "array"
	},
	LevelRatio2 = {
		default = "[]",
		type = "array"
	},
	LevelConstant2 = {
		default = "[]",
		type = "array"
	},
	LevelRatio3 = {
		default = "[]",
		type = "array"
	},
	LevelConstant3 = {
		default = "[]",
		type = "array"
	},
	LevelRatio4 = {
		default = "[]",
		type = "array"
	},
	LevelConstant4 = {
		default = "[]",
		type = "array"
	},
	LevelRatio5 = {
		default = "[]",
		type = "array"
	},
	LevelConstant5 = {
		default = "[]",
		type = "array"
	},
	LevelRatio6 = {
		default = "[]",
		type = "array"
	},
	LevelConstant6 = {
		default = "[]",
		type = "array"
	},
	AttriList2 = {
		default = "[]",
		type = "array"
	},
	AttriList3 = {
		default = "[]",
		type = "array"
	},
	StarAttribute = {
		default = "[]",
		type = "array"
	},
	StarAddLevelAttr = {
		default = "[]",
		type = "array"
	},
	Cost = {
		default = "[]",
		type = "array"
	},
	FightValue = {
		type = "integer"
	},
	LevelValue = {
		type = "integer"
	},
	StarValue = {
		default = "[]",
		type = "array"
	},
	FlowerValue = {
		default = "[]",
		type = "array"
	},
	Resolve = {
		default = "[]",
		type = "array"
	},
	FxMaterial = {
		type = "text"
	},
	ShareBG = {
		type = "text"
	},
	BGIcon = {
		type = "text"
	},
	SpineData = {
		type = "text"
	},
	AttachSpineData = {
		type = "text"
	},
	CardSpineDrift = {
		default = "[]",
		type = "array"
	},
	CardSpineScale = {
		default = "0",
		type = "float"
	},
	VocalBank = {
		type = "text"
	},
	VocalAtk = {
		type = "text"
	},
	VocalHit = {
		type = "text"
	},
	VocalLose = {
		type = "text"
	},
	VocalRecover = {
		type = "text"
	},
	VocalStart = {
		type = "text"
	},
	VocalWin = {
		type = "text"
	},
	VocalGet = {
		type = "text"
	},
	TextGet = {
		type = "integer"
	},
	ColorGet = {
		type = "text"
	},
	PicGet = {
		type = "text"
	},
	FlowerCost = {
		default = "[]",
		type = "array"
	},
	FlowerAtr = {
		default = "[]",
		type = "array"
	},
	FlowerAtr2 = {
		default = "[]",
		type = "array"
	},
	FlowerSkill = {
		default = "[]",
		type = "array"
	},
	FlowerAward = {
		default = "[]",
		type = "array"
	},
	CardChapter = {
		type = "integer"
	},
	CardChapterShow = {
		type = "integer"
	},
	AvatarUnlock = {
		default = "[]",
		type = "array"
	},
	Location = {
		default = "[]",
		type = "array"
	},
	SkillIconlook = {
		type = "text"
	},
	Award = {
		default = "[]",
		type = "array"
	},
	CardEffect = {
		type = "integer"
	}
}
local CharacterCardCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CharacterCard = {}

function CharacterCard:GetAllSync()
	if CharacterCardCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CharacterCard", "select * from CharacterCard")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharacterCardInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CharacterCardCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CharacterCardCtrl.hasCached = true
	CharacterCard.GetAllSync = nil
	CharacterCard.GetAllASync = nil
end

function CharacterCard:GetAllASync()
	if CharacterCardCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CharacterCard", "select * from CharacterCard", function()
		local rowsList = SqlLiteSupport.GetCacheData("CharacterCard")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharacterCardInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CharacterCardCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CharacterCardCtrl.hasCached = true
		CharacterCard.GetAllSync = nil
		CharacterCard.GetAllASync = nil
	end)
end

setmetatable(CharacterCard, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CharacterCard", SqlLiteTransfer.GenSql("CharacterCard", CharacterCardCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CharacterCardInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CharacterCard:GetAllSync()

return CharacterCard
