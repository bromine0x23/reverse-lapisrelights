-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/DlgCardHpReply.lua

require("UI/Page/PageUnionRaid/CellCardHp")

DlgCardHpReply = class("DlgCardHpReply", UIPanel)

local eReplyType = {
	All = 2,
	Single = 1
}

function DlgCardHpReply:ctor()
	self.UIPrefabPath = "UI/PanelUnionRaid/DlgCardHpReply"
end

function DlgCardHpReply:PreLoad()
	self:LoadResAsync("UI/Common/CellCard/CellCardHp", "PrefabCellCardHp", GameObject)
end

function DlgCardHpReply:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgCardHpReply:OnLeave()
	ResourceMgr.Unload(self.PrefabCellCardHp)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.item then
		self.item:OnLeave()

		self.item = nil
	end

	InfoSoundEventMgr:OnBack()
end

function DlgCardHpReply:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	self:AddClick(self.BtnUse, self.OnClickedBtnUse)

	for i = 1, 2 do
		self:AddClick(self["BtnEssence" .. i], self.OnClickedBtnEssence)
	end

	Event.Instance:Add("UpdateRaidSystem", self.Close, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateCostPanel, self)
end

function DlgCardHpReply:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	self:RemoveClick(self.BtnUse, self.OnClickedBtnUse)

	for i = 1, 2 do
		self:RemoveClick(self["BtnEssence" .. i], self.OnClickedBtnEssence)
	end

	Event.Instance:Remove("UpdateRaidSystem", self.Close, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateCostPanel, self)
end

function DlgCardHpReply:OnEnter(vParam)
	local txt = self:GetChildComponent("Panel/Title/Text", "Text")

	txt.text = _("Raid_Card_Reply")
	txt = self:GetChildComponent("Panel/GoItem/BtnUse/Text", "Text")
	txt.text = _("Btn_ItemUse")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.BtnUse = self:GetChildGameObject("Panel/GoItem/BtnUse")
	self.ImgBtnUse = GOUtil.GetComponent(self.BtnUse, "Image")
	self.TxtHold = self:GetChildComponent("Panel/GoItem/TxtHold", "Text")

	for i = 1, 2 do
		self["BtnEssence" .. i] = self:GetChildGameObject("Panel/" .. i)
		self["SelEssence" .. i] = self:GetChildGameObject("Panel/" .. i .. "/Select")
		self["EssenceIcon" .. i] = self:GetChildComponent("Panel/" .. i .. "/Icon", "Image")
		self["EssenceName" .. i] = self:GetChildComponent("Panel/" .. i .. "/Text", "Text")
	end

	self.TxtEssencePrompt = self:GetChildComponent("Panel/Text", "Text")
	self.TextNoneCardPrompt = self:GetChildComponent("Panel/TextPrompt", "Text")
	self.TextNoneCardPrompt.text = _("Msg_Restore_Card_Need_None")

	local cell = self:GetChildGameObject("Panel/GoItem/Cell")

	self.item = CellItem(cell)

	self.item:InitItemByRoot(cell)

	self.item.tipData = {
		showNum = true,
		initPanelIndex = 3,
		needFromBtn = true,
		callback = function()
			self:Close()
		end
	}

	self:Init(vParam)
end

function DlgCardHpReply:Init(fromCardView)
	self.fromCardView = fromCardView

	local listData = ItemManager:GetItemListByType("I_HP_RECOVER")

	self.listItem = {}

	for _, v in ipairs(listData) do
		local infoItem = ItemManager:Get(v.ID)

		table.insert(self.listItem, infoItem)
	end

	table.sort(self.listItem, function(a, b)
		return tonumber(a.data.SubType) < tonumber(b.data.SubType)
	end)

	for i = 1, #self.listItem do
		SetImageSprite(self["EssenceIcon" .. i], self.listItem[i]:GetIcon(), self)

		self["EssenceName" .. i].text = Lang(self.listItem[i].data.Name)
	end

	self.curItemIdx = 1

	self:UpdatePanel()
end

function DlgCardHpReply:UpdatePanel()
	self.listSlectCardId = {}
	self.infoItem = self.listItem[self.curItemIdx]
	self.itemType = tonumber(self.infoItem.data.SubType)

	self.item:UpdateNoNumType(self.infoItem)

	if self.itemType == eReplyType.Single then
		self.TxtEssencePrompt.text = _("Desc_Use_Essence_Single")
	else
		self.TxtEssencePrompt.text = _("Desc_Use_Essence_All")
	end

	self:UpdateCostPanel()

	for i = 1, 2 do
		GOUtil.SetActive(self["SelEssence" .. i], i == self.curItemIdx)

		local color

		if i == self.curItemIdx then
			color = getColorFromString("FFFFFF")
		else
			color = getColorFromString("585E62")
		end

		UIUtil.SetGraphicColorRGB(self["EssenceName" .. i], color.r, color.g, color.b)
	end

	self:UpdateScrollView()
end

function DlgCardHpReply:UpdateCostPanel()
	self.itemCount = ItemManager:GetItemCount(self.infoItem.id)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnUse, TenaryOp(self.itemCount == 0, 1, 0)))
	self:UpdateCostNum()
end

function DlgCardHpReply:UpdateCostNum()
	if self.itemType == eReplyType.Single then
		local leftCnt = self.itemCount - #self.listSlectCardId

		if leftCnt < self.itemCount then
			if leftCnt <= 0 then
				self.TxtHold.text = _("Desc_Remaining") .. "<color=red>0</color>/" .. self.itemCount
			else
				self.TxtHold.text = _("Desc_Remaining") .. leftCnt .. "/" .. self.itemCount
			end
		else
			self.TxtHold.text = _("Desc_Remaining") .. self.itemCount
		end
	else
		self.TxtHold.text = _("Desc_Remaining") .. self.itemCount
	end
end

function DlgCardHpReply:UpdateScrollView(type)
	self.listCard = {}

	local list = RoleCardMgr:GetAllHoldCard()

	for _, card in ipairs(list) do
		if card.curCommRaidHpPer ~= 1 then
			card.tempCombatPower = RoleCardMgr:GetCardFightValue(card)

			table.insert(self.listCard, card)
		end
	end

	local function Sort(a, b)
		return a.tempCombatPower > b.tempCombatPower
	end

	table.sort(self.listCard, Sort)
	GOUtil.SetActive(self.TextNoneCardPrompt, #self.listCard == 0)

	if self.inited then
		if type == 1 then
			self.UIScrollTool:UpdateListData(self.listCard)
		else
			self.UIScrollTool:UpdateListDataKeepPos(self.listCard)
		end

		return
	end

	self.inited = true

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.listCard

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local infoCard = self.listCard[index]

		item:UpdateData(infoCard, union, self.itemType == eReplyType.All)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellCardHp, CellCardHp, self, false, addCallback, updateCallback)
end

function DlgCardHpReply:OnClickedCell(data)
	if self.itemType == eReplyType.All then
		return
	end

	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local cardId = self.listCard[index].id
	local isSel = table.contains(self.listSlectCardId, cardId)

	if isSel then
		table.removeByValue(self.listSlectCardId, cardId)
		info.Item:UpdateSelect(false)
	elseif self.itemCount <= #self.listSlectCardId then
		UIMgr.ShowMsg(_("Desc_Item_Not_Enough"))

		return
	else
		table.insert(self.listSlectCardId, cardId)
		info.Item:UpdateSelect(true)
	end

	self:UpdateCostNum()
end

function DlgCardHpReply:OnClickedBtnUse()
	if #self.listCard == 0 then
		UIMgr.ShowMsg(_("Msg_Restore_Card_Need_None"))

		return
	end

	local cost = 0

	if self.itemType == eReplyType.Single then
		cost = #self.listSlectCardId

		if cost == 0 then
			UIMgr.ShowMsg(_("Msg_Select_Card_Please"))

			return
		end
	else
		cost = GetConfigArgInt("ClubHpRecoverCostNum")
	end

	if cost > self.itemCount then
		UIMgr.ShowMsg(_("Desc_Item_Not_Enough"))

		return
	end

	local function cb(index)
		if index == 1 then
			local function wrap_cb(vMsg)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vMsg.result.code == NetManager.Result_Sucess then
					UIMgr.ShowMsg(_("Msg_Restore_Hp_Card"))

					local num = 1
					local role

					if self.itemType == eReplyType.Single then
						num = math.random(1, #self.listSlectCardId)

						for k, id in ipairs(self.listSlectCardId) do
							local infoCard = RoleCardMgr:GetRoleCard(id)

							infoCard:ChangeClubCardHpPercent(self.infoItem.data.Value)

							if num == k then
								role = RoleCardMgr:GetRole(infoCard.id)
							end
						end

						self:UpdateScrollView(2)
					else
						num = math.random(1, #self.listCard)

						for k, infoCard in ipairs(self.listCard) do
							infoCard:ChangeClubCardHpPercent(self.infoItem.data.Value)

							if num == k then
								role = RoleCardMgr:GetRole(infoCard.id)
							end
						end

						self:UpdateScrollView(1)
					end

					if role then
						InfoSoundEventMgr:LoadBank(role.data.VocalBank)
						InfoSoundEventMgr:Play("VocalCommon6", role.data.VocalCommon6)
					end

					self.listSlectCardId = {}

					self:UpdateCostPanel()
				elseif vMsg.result.code == 2 then
					self:Close()
					PageUnion.GoBackMainPage(vMsg)
				else
					UIMgr.ShowMsg(vMsg.result.desc, vMsg)
				end
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestRestoreCardHp(self.infoItem.id, self.listSlectCardId, wrap_cb)
		end
	end

	local msg = _("Msg_Restore_CardHp_OrNot")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Desc_Alert"), msg, cb, _("UI_Yes"), _("UI_No"), false)
end

function DlgCardHpReply:OnClickedBtnEssence(data)
	local index = tonumber(data.pointerPress.name)

	if self.curItemIdx == index then
		return
	end

	self.curItemIdx = index

	self:UpdatePanel()
end

function DlgCardHpReply:OnClickedBtnClose()
	self:Close()

	if self.fromCardView then
		require("UI/Page/PageUnionRaid/DlgRaidCardView")
		UIMgr.AddPanel(DlgRaidCardView())
	end
end
