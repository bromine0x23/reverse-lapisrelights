-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CardRDL/CardNewRDL.lua

local CardNewRDL = {}
local KEY_RD_CARD_NEW = "KEY_RD_CARD_NEW"
local CurNewCardIds = {}

function CardNewRDL.Init()
	local t = PersistentStoreUtil.GetList(KEY_RD_CARD_NEW)

	for _, v in ipairs(t) do
		if not table.contains(CurNewCardIds, tonumber(v)) then
			table.insert(CurNewCardIds, tonumber(v))
		end
	end
end

function CardNewRDL.RunNewCard(card)
	if table.contains(CurNewCardIds, card.id) then
		RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Card_Branch_Path.New, 1, card.id)
	end
end

function CardNewRDL.AddNewCardPlayerPrefs(card)
	PersistentStoreUtil.AddList(KEY_RD_CARD_NEW, card.id)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Card_Branch_Path.New, 1, card.id)

	if not table.contains(CurNewCardIds, card.id) then
		table.insert(CurNewCardIds, card.id)
	end
end

function CardNewRDL.SubNewCardPlayerPrefs(card)
	if not table.contains(CurNewCardIds, card.id) then
		return
	else
		table.removeByValue(CurNewCardIds, card.id)
	end

	PersistentStoreUtil.SetList(KEY_RD_CARD_NEW, CurNewCardIds)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Card_Branch_Path.New, -1, card.id)
end

function CardNewRDL.IsNewCard(cardId)
	return table.contains(CurNewCardIds, cardId)
end

return CardNewRDL
