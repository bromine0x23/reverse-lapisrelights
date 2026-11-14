-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CardRDL/CardBreakRDL.lua

local CardBreakRDL = {}
local KEY_RD_CARD_BREAK = "KEY_RD_CARD_BREAK"

local function CanBreakCard(card)
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardStar)

	if not isOpen then
		return false
	end

	if card.curStarLevel >= card.maxStarLevel then
		return false
	else
		local listItem, listGold = RoleCardMgr:GetNextUpCost(card, 1)

		for i = 1, #listItem do
			if not ItemManager:IsItemHoldEnough(listItem[i][1], listItem[i][2], true) then
				return false
			end
		end

		if listGold[1] and listGold[1][1] and not ItemManager:IsItemHoldEnough(listGold[1][1], listGold[1][2], true) then
			return false
		end
	end

	return true
end

function CardBreakRDL.RunCardBreak(card)
	local value = 0

	if CanBreakCard(card) then
		value = 1
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Card_Branch_Path.Break, value, card.id)

	local lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardStar)

	if lock then
		local path = RedDotSystemMgr.GetFormatPath("Break/%d", card.id)

		RedDotSystemMgr.SetNodeLockState(path, true)
	end
end

function CardBreakRDL.ReCalculateCardBreak()
	for _, card in pairs(CardRDL.ALL_HOLD_CARD) do
		CardBreakRDL.RunCardBreak(card)
	end
end

return CardBreakRDL
