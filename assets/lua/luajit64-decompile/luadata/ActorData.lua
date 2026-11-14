-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ActorData.lua

local ActorDataInfo = {
	ID = {
		type = "integer"
	},
	Comment = {
		type = "text"
	},
	StoryBody = {
		type = "text"
	},
	StoryScale = {
		default = "1",
		type = "float"
	},
	StoryHeight = {
		default = "0",
		type = "float"
	},
	SkeletonPrefab = {
		type = "text"
	},
	Height = {
		default = "[]",
		type = "array"
	},
	Radius = {
		default = "0",
		type = "float"
	},
	DefaultAvatars = {
		default = "[]",
		type = "array"
	},
	ScaleSettingsAsset = {
		type = "text"
	},
	FacialSettingsAsset = {
		type = "text"
	},
	EyeSettingsAsset = {
		type = "text"
	},
	VowelSettingsAsset = {
		type = "text"
	},
	DefaultController = {
		type = "integer"
	},
	CharacterIcon = {
		type = "text"
	},
	ThemeIcon = {
		type = "text"
	},
	PaperIcon = {
		type = "text"
	},
	UiShowIcon = {
		type = "text"
	},
	HeadHit = {
		type = "text"
	},
	HeadPoint = {
		type = "text"
	},
	MeleeHit = {
		type = "text"
	},
	RangeHit = {
		type = "text"
	},
	CenterPoint = {
		type = "text"
	},
	ChestPoint = {
		type = "text"
	},
	LeftHandPoint = {
		type = "text"
	},
	RightHandPoint = {
		type = "text"
	},
	RightHandFingerPoint = {
		type = "text"
	},
	LeftGunPoint = {
		type = "text"
	},
	RightGunPoint = {
		type = "text"
	},
	HeadHit1 = {
		type = "text"
	},
	SkillStart01 = {
		type = "text"
	},
	SkillStart02 = {
		type = "text"
	},
	BossLiveHit = {
		type = "text"
	}
}
local ActorDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ActorData = {}

function ActorData:GetAllSync()
	if ActorDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ActorData", "select * from ActorData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActorDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ActorDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ActorDataCtrl.hasCached = true
	ActorData.GetAllSync = nil
	ActorData.GetAllASync = nil
end

function ActorData:GetAllASync()
	if ActorDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ActorData", "select * from ActorData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ActorData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActorDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ActorDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ActorDataCtrl.hasCached = true
		ActorData.GetAllSync = nil
		ActorData.GetAllASync = nil
	end)
end

setmetatable(ActorData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ActorData", SqlLiteTransfer.GenSql("ActorData", ActorDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ActorDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ActorData:GetAllSync()

return ActorData
