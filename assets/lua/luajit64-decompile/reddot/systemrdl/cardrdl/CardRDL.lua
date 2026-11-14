-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CardRDL/CardRDL.lua

CardRDL = {}
CardRDL.ALL_HOLD_CARD = {}
CardRDL.All_NOT_HOLD_CARD = {}
RD_Card_Branch_Path = {
	LvUp = "LvUp/%d",
	Bloom = "Bloom/%d",
	Compose = "Card/Compose/%d",
	Stage_Fight = "Stage/%d/Fight",
	New = "Card/New/%d",
	Stage_Story = "Stage/%d/Story",
	Break = "Break/%d"
}
CardRDL.NewRDL = require("RedDot/SystemRDL/CardRDL/CardNewRDL")
CardRDL.LvUpRDL = require("RedDot/SystemRDL/CardRDL/CardLvUpRDL")
CardRDL.BreakRDL = require("RedDot/SystemRDL/CardRDL/CardBreakRDL")
CardRDL.BloomRDL = require("RedDot/SystemRDL/CardRDL/CardBloomRDL")
CardRDL.StageRDL = require("RedDot/SystemRDL/CardRDL/CardStageRDL")
CardRDL.ComposeRDL = require("RedDot/SystemRDL/CardRDL/CardComposeRDL")

function CardRDL.ResetAllCard()
	CardRDL.ALL_HOLD_CARD = RoleCardMgr:GetAllHoldCard()

	CardRDL.ResetAllNotHoldCard()
end

function CardRDL.ResetAllNotHoldCard()
	CardRDL.All_NOT_HOLD_CARD = RoleCardMgr:GetAllNotHoldCard()
end

function CardRDL.Init()
	CardRDL.ResetAllCard()
	CardRDL.NewRDL.Init()
	CardRDL.ComposeRDL.Init()
	CardRDL.InitRD()
end

function CardRDL.InitRD()
	for _, card in ipairs(CardRDL.ALL_HOLD_CARD) do
		CardRDL.NewRDL.RunNewCard(card)
		CardRDL.InitCard(card)
	end
end

function CardRDL.InitCard(card)
	CardRDL.LvUpRDL.RunCardLvUp(card)
	CardRDL.BreakRDL.RunCardBreak(card)
	CardRDL.BloomRDL.RunCardBloom(card)
	CardRDL.StageRDL.RunCardStage(card)
end

function CardRDL.PushNewCard(card)
	if not card or not card:IsHold() then
		return
	end

	table.insert(CardRDL.ALL_HOLD_CARD, card)

	for k, temp in pairs(CardRDL.All_NOT_HOLD_CARD) do
		if temp.id == card.id then
			table.remove(CardRDL.All_NOT_HOLD_CARD, k)
			CardRDL.ComposeRDL.RemoveCardCompose(card)

			break
		end
	end

	CardRDL.InitCard(card)
end

return CardRDL
