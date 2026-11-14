-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CardRDL/CardComposeRDL.lua

local CardComposeRDL = {}
local KEY_RD_CARD_COMPOSE = "KEY_RD_CARD_COMPOSE"
local VIEWD_COMPOSE = false
local CanComposeCardIds = {}

local function CanComposeCard(card)
	local aim = 0
	local rank = card.data.Rank
	local data = GetConfigArgJson("CardSynthesisCost")

	if rank == "R" then
		aim = data[1]
	elseif rank == "SR" then
		aim = data[2]
	elseif rank == "SSR" then
		aim = data[3]
	elseif rank == "UR" then
		aim = data[4]
	end

	if aim <= card.pb.soul then
		return true
	end

	return false
end

function CardComposeRDL.Init()
	CardComposeRDL.ReCalculateCardCompose()
end

function CardComposeRDL.ReCalculateCardCompose()
	CardRDL.ResetAllNotHoldCard()

	for _, card in pairs(CardRDL.All_NOT_HOLD_CARD) do
		if CanComposeCard(card) then
			if not table.contains(CanComposeCardIds, card.id) then
				table.insert(CanComposeCardIds, card.id)
				RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Card_Branch_Path.Compose, 1, card.id)
			end
		elseif table.contains(CanComposeCardIds, card.id) then
			table.removeByValue(CanComposeCardIds, card.id)
			RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Card_Branch_Path.Compose, 0, card.id)
		end
	end
end

function CardComposeRDL.RemoveCardCompose(card)
	if table.contains(CanComposeCardIds, card.id) then
		table.removeByValue(CanComposeCardIds, card.id)
	end

	RedDotSystemMgr.RemoveNode(RD_Card_Branch_Path.Compose, card.id)
end

function CardComposeRDL.DealViewd()
	if not VIEWD_COMPOSE then
		local node = RedDotSystemMgr.GetNode("Card/Compose")

		if node.Value > 0 then
			VIEWD_COMPOSE = true

			RedDotSystemMgr.SetNodeViewState("Card/Compose", true)
		end
	end
end

function CardComposeRDL.IsCanCompose(cardId)
	return table.contains(CanComposeCardIds, cardId)
end

return CardComposeRDL
