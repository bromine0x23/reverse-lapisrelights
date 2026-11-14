-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/PageChooseAddCard.lua

require("UI/Page/PageTeam/AddCard")

PageChooseAddCard = class("PageChooseAddCard", UIPanel)

function PageChooseAddCard:ctor()
	self.UIPrefabPath = "UI/PanelChooseCard/PanelChooseAddCard"

	self:AddChildPanel(DlgExit(), {
		title = _("pageAddCardTitle"),
		callback = self.OnBack,
		panel = self
	})
end

function PageChooseAddCard:PreLoad()
	self.roleCardPreLoad = ResourceMgr.LoadSync("UI/PanelChooseCard/AddCard")
end

function PageChooseAddCard:Purge()
	PageChooseAddCard.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	if self.roleCardPreLoad then
		ResourceMgr.Unload(self.roleCardPreLoad)

		self.roleCardPreLoad = nil
	end
end

function PageChooseAddCard:OnBack()
	UIMgr.PopPanel()
end

function PageChooseAddCard:OnRegisterEvent()
	return
end

function PageChooseAddCard:OnUnRegisterEvent()
	return
end

function PageChooseAddCard:OnEnter(vParam)
	self.clickSlot = vParam.clickSlot
	self.teamSystemAgent = vParam.teamSystemAgent
	self.teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]

	self:GetInitCardData()
	self:CreateRoleCard()
end

function PageChooseAddCard:SortFunc()
	local allCardList = {}
	local upingCardList = {}

	for i, v in ipairs(RoleCardMgr:GetAllHoldCard()) do
		local cardData = RoleCardMgr:GetAllHoldCard()[i]
		local teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
		local clickUpCard = self.clickSlot.addInfoRoleCard
		local clickCardId = clickUpCard and clickUpCard.id or 0
		local isUp = teamAgent:GetAddCardIdx(cardData.id) ~= -1

		if isUp then
			cardData.uping = teamAgent:GetAddCardIdx(cardData.id)

			table.insert(upingCardList, cardData)
		else
			cardData.uping = false

			table.insert(allCardList, cardData)
		end
	end

	table.sort(upingCardList, function(a, b)
		local aVal = a.uping
		local bVal = b.uping

		return bVal < aVal
	end)
	table.sort(allCardList, function(a, b)
		local aVal = math.floor(RoleCardMgr:GetFightValue(nil, nil, a))
		local bVal = math.floor(RoleCardMgr:GetFightValue(nil, nil, b))

		return bVal < aVal
	end)

	for i = 1, #upingCardList do
		table.insert(allCardList, 1, upingCardList[i])
	end

	return allCardList
end

function PageChooseAddCard:GetInitCardData()
	self.listCard = RoleCardMgr:GetAllHoldCard()

	table.sort(self.listCard, function(a, b)
		local aVal = math.floor(RoleCardMgr:GetFightValue(nil, nil, a))
		local bVal = math.floor(RoleCardMgr:GetFightValue(nil, nil, b))

		return bVal < aVal
	end)

	self.listCard = self:SortFunc()

	CardSwitchMgr:ResetCardIdsByBattle(self.listCard)
end

function PageChooseAddCard:GetFightValue(infoCard)
	local initValue = infoCard.data.FightValue
	local levelValue = infoCard.curLevel > 0 and (infoCard.curLevel - 1) * infoCard.data.LevelValue or 0
	local starValue = infoCard.curStarLevel > 0 and infoCard.data.StarValue[infoCard.curStarLevel] or 0
	local flowerValue = infoCard.curPetal > 0 and infoCard.data.FlowerValue[infoCard.curPetal] or 0

	return initValue + levelValue + starValue + flowerValue
end

function PageChooseAddCard:CreateRoleCard()
	local ScrollArea = self:GetChildGameObject("ScrollArea")
	local content = self:GetChildComponent("ScrollArea/Content", "Transform")
	local count = #self.listCard

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.roleCardPreLoad, AddCard, self, false)
end

function PageChooseAddCard:UpdateCards()
	self.UIScrollTool:UpdateListData(self.listCard)
end

function PageChooseAddCard:UpdateCell(item, index)
	local cardData = self.listCard[index]

	item:UpdateData(self.teamSystemAgent, self.clickSlot, cardData)
end

function PageChooseAddCard:AddCellClick(item)
	return
end
