-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CardRDL/CardBloomRDL.lua

local CardBloomRDL = {}
local KEY_RD_CARD_BLOOM = "KEY_RD_CARD_BLOOM"

local function CanBloomCard(card)
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardPetal)

	if not isOpen then
		return false
	end

	if card.curPetal >= card.maxPetal then
		return false
	else
		local listItem, listGold = RoleCardMgr:GetNextUpCost(card, 2)
		local isUR = card.cardRank == eRankType.UR

		for _, v in ipairs(listItem) do
			if next(v) ~= nil then
				if isUR then
					local infoSoul = ItemManager:GetItemByType("I_SOUL_COMMON")

					if ItemManager:GetItemCount(v[1]) + infoSoul:GetCurResNum() < v[2] then
						return false
					end
				elseif not ItemManager:IsItemHoldEnough(v[1], v[2] or 0, true) then
					return false
				end
			end
		end

		if listGold[1] and listGold[1][1] and not ItemManager:IsItemHoldEnough(listGold[1][1], listGold[1][2], true) then
			return false
		end
	end

	return true
end

function CardBloomRDL.RunCardBloom(card)
	local value = 0

	if CanBloomCard(card) then
		value = 1
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Card_Branch_Path.Bloom, value, card.id)

	local lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardPetal)

	if lock then
		local path = RedDotSystemMgr.GetFormatPath("Bloom/%d", card.id)

		RedDotSystemMgr.SetNodeLockState(path, true)
	end
end

function CardBloomRDL.ReCalculateCardBloom()
	for _, card in pairs(CardRDL.ALL_HOLD_CARD) do
		CardBloomRDL.RunCardBloom(card)
	end
end

function CardBloomRDL.ReCalculateURCardBloom()
	for _, card in pairs(CardRDL.ALL_HOLD_CARD) do
		if GetRankType(card.data.Rank) == eRankType.UR then
			CardBloomRDL.RunCardBloom(card)
		end
	end
end

return CardBloomRDL
