-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellModelType1.lua

require("UI/Item/UIItemBase")

CellModelType1 = class("CellModelType1", UIItemBase)

function CellModelType1:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellModelType1:OnEnter()
	local g = self.UIRootObject

	for i = 1, 2 do
		self["GoDot" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/GoDot")
		self["Recved" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/Recved")
		self["BtnRecv" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/BtnRecv")
		self["img_recv" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/img_recv")
		self["BGRecved" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/BGRecved")
		self["BGUnRecved" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/BGUnRecved")

		self:AddClick(self["BtnRecv" .. i], self.OnClickedBtnRecv)

		self["TxtTime" .. i] = GOUtil.FindChildComponent(g, "type" .. i .. "/go_time/TxtTime", "Text")
		self["Type" .. i] = GOUtil.FindChildGameObject(g, "type" .. i)
		self["FX_UI_Activity" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/FX_UI_Activity")
	end

	self.Cell = GOUtil.FindChildGameObject(g, "type1/Group/CellItem")

	SetActiveFunc(self.Cell, false)

	local scrollArea = GOUtil.FindChildGameObject(g, "type1/Group")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	self.ScrollView.horizontal = true
	self.GoCard = GOUtil.FindChildGameObject(g, "type2/Card")
	self.GoLimit = GOUtil.FindChildGameObject(g, "img_limit")
	self.CardJob = GOUtil.FindChildComponent(g, "type2/CellSelCard/ImageJob", "Image")
	self.CardRank = GOUtil.FindChildComponent(g, "type2/CellSelCard/bg", "Image")
	self.CardIcon = GOUtil.FindChildComponent(g, "type2/CellSelCard/Icon/Image", "Image")
	self.Btntype2Look = GOUtil.FindChildGameObject(g, "type2/BtnLook")

	self:AddClick(self.Btntype2Look, self.OnClickedBtnLook)

	self.img_type2_limit = GOUtil.FindChildGameObject(g, "type2/img_limit")
end

function CellModelType1:OnClickedBtnLook()
	local popData = {
		tag = 4
	}
	local data = {
		onlyShow = true,
		cardId = self.data.award[1][2],
		popData = popData
	}

	UIMgr.SwitchPanel(PageRoleCard, data)
end

function CellModelType1:OnLeave()
	self:RemoveClick(self.Btntype2Look, self.OnClickedBtnLook)

	for i = 1, 2 do
		self:RemoveClick(self["BtnRecv" .. i], self.OnClickedBtnRecv)
	end

	UnloadAllImageSprite(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function CellModelType1:ClearCell()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
end

function CellModelType1:UpdateData(data, listOpenActive, type)
	local day = data.index

	self.data = data
	type = self.data.isCard
	self.infoActive = listOpenActive
	self.curindex = listOpenActive.id
	self.Day = self.infoActive.pb.record

	local canRecv = self.Day >= self.data.index
	local isRecv = self.infoActive:IsGetIndexAward(self.data.index)
	local colorTime = string.format("<color=#585e62>%s</color>", self.data.index)

	if not canRecv then
		colorTime = string.format("<color=#585e62>%s</color>", self.data.index)
	end

	self["TxtTime" .. type].text = colorTime

	if type == 1 then
		SetActiveFunc(self["Type" .. 2], false)
		self:ClearCell()

		local pack = OperationActiveMgr:GetRewardPackData(self.infoActive.data.TypeReward[self.data.index]).PackItem

		self.listItem = {}

		SetActiveFunc(self.Cell, true)

		for i = 1, #pack do
			local award = pack[i]

			if award then
				local infoItem = ItemManager:GetValueItem(award[1], award[2], nil, award[3])
				local gItem = GOUtil.Instantiate(self.Cell, self.ScrollView.content.gameObject)
				local item = CellItem(gItem)

				item:InitItemByRoot(gItem)

				if award[2] == 0 then
					item:UpdateNoNumType(infoItem)
				else
					item:UpdateWithNumType(infoItem)
				end

				table.insert(self.listItem, item)
			end
		end

		SetActiveFunc(self.Cell, false)

		if #pack <= 2 then
			self.ScrollView.horizontal = false
			self.ScrollView.enabled = false
		else
			self.ScrollView.enabled = true
			self.ScrollView.horizontal = true
		end

		SetActiveFunc(self["GoDot" .. type], canRecv and not isRecv)
		SetActiveFunc(self["BtnRecv" .. type], canRecv and not isRecv)
		SetActiveFunc(self["img_recv" .. type], canRecv and not isRecv)
		SetActiveFunc(self["Recved" .. type], canRecv and isRecv)
		SetActiveFunc(self["BGRecved" .. type], canRecv and not isRecv)
		SetActiveFunc(self["BGUnRecved" .. type], not canRecv or isRecv)
		SetActiveFunc(self["FX_UI_Activity" .. type], canRecv and not isRecv)
	else
		SetActiveFunc(self["Type" .. 1], false)

		local cardId = data.award[1][2]
		local infoRoleCard = InfoRoleCard(cardId)
		local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

		GOUtil.DestroyAllChildren(self.CardIcon.gameObject)
		UIUtil.SetImageSprite(self.CardJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S", self)
		UIUtil.SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_10", self)
		UIUtil.SetImageSprite(self.CardIcon, infoRoleCard.data.MidIcon, self)
		SetActiveFunc(self.Btntype2Look, not isRecv)
		SetActiveFunc(self.img_type2_limit, self.data.index == 7)

		local gray = TenaryOp(canRecv, 0, 1)
	end
end

function CellModelType1:OnClickedBtnRecv(data)
	local infoOperationActive = OperationActiveMgr:Get(self.curindex)
	local canRecv = self.Day >= self.data.index
	local isRecv = infoOperationActive:IsGetIndexAward(self.data.index)

	if not isRecv and not canRecv then
		UIMgr.ShowMsg(_("Desc_Waiting"))

		return
	end

	Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index)
end
