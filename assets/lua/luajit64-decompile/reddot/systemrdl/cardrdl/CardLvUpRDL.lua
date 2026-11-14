-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CardRDL/CardLvUpRDL.lua

local CardLvUpRDL = {}
local ALL_EXP_ITEM = ItemManager.listExpId

local function CanLevelUp(card)
	if card.pb.levelExp > LevelManager:GetRoleCardExp(1) then
		return false
	end

	if card.curLevel >= card.maxLevel then
		return false
	end

	if card.curLevel >= card.curLimitLevel then
		return false
	end

	local curExpId

	if ALL_EXP_ITEM ~= nil then
		for _, v in ipairs(ALL_EXP_ITEM) do
			if ItemManager:GetItemCount(v) > 0 then
				curExpId = v

				break
			end
		end
	end

	if curExpId == nil then
		return false
	end

	local item = ItemManager:Get(curExpId)
	local holdGold = PlayerInst:GetGold()

	if holdGold < item.data.Value * GetConfigArgInt("GoldPerExp") then
		return false
	end

	return true
end

function CardLvUpRDL.RunCardLvUp(card)
	if ALL_EXP_ITEM == nil then
		ALL_EXP_ITEM = ItemManager.listExpId
	end

	local value = 0

	if CanLevelUp(card) then
		value = 1
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Card_Branch_Path.LvUp, value, card.id)

	local lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardLevel)

	if lock then
		local path = RedDotSystemMgr.GetFormatPath("LvUp/%d", card.id)

		RedDotSystemMgr.SetNodeLockState(path, true)
	end
end

function CardLvUpRDL.ReCalculateCardLvUp()
	for _, card in pairs(CardRDL.ALL_HOLD_CARD) do
		CardLvUpRDL.RunCardLvUp(card)
	end
end

return CardLvUpRDL
