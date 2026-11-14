-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellBattlePassAward.lua

require("UI/Item/UIItemBase")

CellBattlePassAward = class("CellBattlePassAward", UIItemBase)

function CellBattlePassAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBattlePassAward:OnEnter(vParam)
	local g = self.UIRootObject

	self.vParam = vParam

	for i = 1, 2 do
		self["GoDot" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/GoDot")
		self["Recved" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/Recved")
		self["ImgGetRecved" .. i] = GOUtil.FindChildComponent(g, "type" .. i .. "/Recved", "Image")
		self["BtnRecv" .. i] = GOUtil.FindChildGameObject(g, "type" .. i .. "/BtnRecv")
		self["Type" .. i] = GOUtil.FindChildGameObject(g, "type" .. i)
		self["Bg" .. i] = self:GetChildGameObject("Bg" .. i)
		self["BgImg" .. i] = GOUtil.FindChildComponent(g, "Bg" .. i, "Image")

		GOUtil.FindChildComponent(g, "type" .. i .. "/BtnRecv", "Image")

		self["ColRecved" .. i] = GOUtil.FindChildComponent(g, "type" .. i .. "/Recved", "Image")
	end

	self:AddClick(self["BtnRecv" .. self.vParam], self.OnClickedBtnRecv)

	self.TxtTime = GOUtil.FindChildComponent(g, "Txt_level", "Text")
	self.Bg = self:GetChildComponent("Bg", "Image")
	self.go_unaward = self:GetChildGameObject("go_unaward")
	self.go_lock = self:GetChildGameObject("go_lock")
	self.ImgBtntype2Recv = GOUtil.GetComponent(self["BtnRecv" .. 2], "Image")
	self.FX_UI_Activity = GOUtil.FindChildGameObject(g, "FX_UI_Activity")
	self.Cell = GOUtil.FindChildGameObject(g, "type1/Group/CellItem")

	SetActiveFunc(self.Cell, false)

	local scrollArea = GOUtil.FindChildGameObject(g, "type1/Group")

	self.ScrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")
	self.ScrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	self.ScrollView.horizontal = true
	self.GoCard = GOUtil.FindChildGameObject(g, "type2/Card")
	self.GoLimit = GOUtil.FindChildGameObject(g, "img_limit")
	self.CardBg = GOUtil.FindChildComponent(g, "type2/Card/CardMask/Bg", "RawImage")
	self.CardIcon = GOUtil.FindChildComponent(g, "type2/Card/CardMask/CardIcon", "RawImage")
	self.CardJob = GOUtil.FindChildComponent(g, "type2/Card/Job", "Image")
	self.CardRank = GOUtil.FindChildComponent(g, "type2/Card/CardRank", "Image")
	self.CardName = GOUtil.FindChildComponent(g, "type2/Card/CardName", "Text")
	self.Btntype2Look = GOUtil.FindChildGameObject(g, "type2/BtnLook")

	self:AddClick(self.Btntype2Look, self.OnClickedBtnLook)

	self.img_type2_limit = GOUtil.FindChildGameObject(g, "type2/img_limit")
end

function CellBattlePassAward:OnClickedBtnLook()
	local popData = {
		tag = 11
	}
	local data = {
		onlyShow = true,
		cardId = self.data.award[1][2],
		popData = popData
	}

	UIMgr.SwitchPanel(PageRoleCard, data)
end

function CellBattlePassAward:OnLeave()
	self:RemoveClick(self.Btntype2Look, self.OnClickedBtnLook)
	self:RemoveClick(self["BtnRecv" .. self.vParam], self.OnClickedBtnRecv)
	UnloadAllImageSprite(self)
	self:ClearCell()
end

function CellBattlePassAward:ClearCell()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	if self.groupHandle then
		ResourceMgr.Cancel(self.groupHandle)
	end

	if not IsNil(self.ScrollView.content) then
		GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)
	end
end

function CellBattlePassAward:UpdateData(data, listOpenActive, type, obj, endValue, day, TaskID)
	local day = data.index

	self.data = data
	self.Day = BattlePassTaskMgr:GetBattlePassLevel()
	self.infoActive = listOpenActive
	self.curindex = listOpenActive.id

	local isRecv = false
	local canRecv = self.Day >= self.data.index

	self.type = type

	if type == 1 then
		SetActiveFunc(self["Bg" .. 1], true)
		SetActiveFunc(self["Bg" .. 2], false)

		self.TxtTime.text = string.format("Lv.%s", self.data.index)
		isRecv = TaskManager:IsRecvedScoreAward(TaskID, data.index - 1)

		if not canRecv or isRecv then
			UIUtil.SetImageSprite(self["BgImg" .. 1], "UI/PanelOperation/New/AtlasCommon/BG_battlepass_frame_07", self)
		else
			UIUtil.SetImageSprite(self["BgImg" .. 1], "UI/PanelOperation/New/AtlasCommon/BG_battlepass_frame_08", self)
		end

		for i = 1, 2 do
			SetActiveFunc(self["BtnRecv" .. i], canRecv and not isRecv)
			SetActiveFunc(self.FX_UI_Activity, canRecv and not isRecv and #self.data.award ~= 0)
			SetActiveFunc(self["Recved" .. i], canRecv and isRecv)
			SetActiveFunc(self["GoDot" .. i], canRecv and not isRecv)
		end

		if not canRecv then
			SetActiveFunc(obj.fill.gameObject, false)
			SetActiveFunc(obj.fill_start.gameObject, false)
			SetActiveFunc(obj.fill_end.gameObject, false)
			SetActiveFunc(obj.icon.gameObject, self.Day + 1 == self.data.index)
			SetActiveFunc(obj.btn_icon, self.Day + 1 == self.data.index)
			SetActiveFunc(obj.img_start, self.data.index == 1)
			SetActiveFunc(obj.img_end, self.data.index == endValue)

			obj.img_bar.enabled = self.data.index ~= 1 and self.data.index ~= endValue
		else
			SetActiveFunc(obj.fill.gameObject, self.data.index ~= 1 and self.data.index ~= endValue)
			SetActiveFunc(obj.fill_start.gameObject, self.data.index == 1)
			SetActiveFunc(obj.fill_end.gameObject, self.data.index == endValue)
			SetActiveFunc(obj.icon.gameObject, false)
			SetActiveFunc(obj.btn_icon, false)
			SetActiveFunc(obj.img_start, self.data.index == 1)
			SetActiveFunc(obj.img_end, self.data.index == endValue)

			obj.img_bar.enabled = self.data.index ~= 1 and self.data.index ~= endValue
		end

		SetActiveFunc(obj.img_complete, self.Day + 1 >= self.data.index and self.data.index ~= 1)
		SetActiveFunc(obj.img_uncomplete, self.Day + 1 < self.data.index and self.data.index ~= 1)
		SetActiveFunc(obj.img_complete_end, self.Day + 1 > self.data.index and self.data.index == endValue)
		SetActiveFunc(obj.img_uncomplete_end, self.Day + 1 <= self.data.index and self.data.index == endValue)
		UIUtil.SetImageSprite(self["ImgGetRecved" .. 1], "UI/PanelOperation/New/AtlasCommon/BG_battlepass_frame_15", self)
	else
		SetActiveFunc(self["Bg" .. 1], false)
		SetActiveFunc(self["Bg" .. 2], true)

		self.TxtTime.text = string.format("Lv.%s", self.data.index)
		isRecv = TaskManager:IsRecvedPayScoreAward(TaskID, data.index - 1)

		local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()
		local isgray = State == true and canRecv
		local gray = TenaryOp(isgray, 0, 1)

		SetActiveFunc(self.go_lock, not State)

		if not canRecv or isRecv then
			UIUtil.SetImageSprite(self["BgImg" .. 2], "UI/PanelOperation/New/AtlasCommon/BG_battlepass_frame_06", self)
		else
			UIUtil.SetImageSprite(self["BgImg" .. 2], "UI/PanelOperation/New/AtlasCommon/BG_battlepass_frame_09", self)
		end

		for i = 1, 2 do
			SetActiveFunc(self["BtnRecv" .. i], canRecv and not isRecv)
			SetActiveFunc(self.FX_UI_Activity, canRecv and not isRecv and #self.data.award ~= 0 and State)
			SetActiveFunc(self["Recved" .. i], canRecv and isRecv)
			SetActiveFunc(self["GoDot" .. i], isgray and not isRecv)
		end

		UIUtil.SetImageSprite(self["ImgGetRecved" .. 1], "UI/PanelOperation/New/AtlasCommon/BG_battlepass_frame_16", self)
	end

	SetActiveFunc(self.TxtTime.gameObject, true)

	self.type = type
	type = self.data.isCard

	if type == 1 or type == nil then
		SetActiveFunc(self["Type" .. 1], #self.data.award ~= 0)
		SetActiveFunc(self["Type" .. 2], false)
		self:ClearCell()

		self.listItem = {}

		SetActiveFunc(self.Cell, true)
		SetActiveFunc(self.go_unaward, #self.data.award == 0)

		if #self.data.award == 0 then
			SetActiveFunc(self["Bg" .. 1], false)
			SetActiveFunc(self["Bg" .. 2], false)
			SetActiveFunc(self.TxtTime.gameObject, false)
		end

		for i = 1, #self.data.award do
			local award = self.data.award[i]

			if award then
				local infoItem = ItemManager:GetValueItem(award[1], award[2])
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

		if #self.data.award <= 2 then
			self.ScrollView.horizontal = false
			self.ScrollView.enabled = false
		else
			self.ScrollView.enabled = true
			self.ScrollView.horizontal = true
		end
	else
		SetActiveFunc(self["Type" .. 1], false)
		SetActiveFunc(self["Type" .. 2], true)

		local cardId = data.award[1][2]
		local infoRoleCard = InfoRoleCard(cardId)
		local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

		SetActiveFunc(self.go_unaward, false)
		GOUtil.DestroyAllChildren(self.CardIcon.gameObject)

		if infoRoleCard.data.SpineData ~= "" then
			SetActiveFunc(self.CardBg.gameObject, false)

			self.CardIcon.enabled = false
			self.groupHandle = ResourceMgr.BeginSubmit(function(spineGo)
				if self.UIRootObject ~= nil then
					local cardSpine = self.spineObj

					if cardSpine then
						local spine = GOUtil.InstantiateUIPrefab(cardSpine, spineGo)

						if GOUtil.GetComponent(spine, "SpineAspectRatioFitter") then
							GOUtil.GetComponent(spine, "SpineAspectRatioFitter").enabled = false
						end
					end
				end
			end, self.CardIcon.gameObject)

			ResourceMgr.SubmitCache(infoRoleCard.data.SpineData .. "_Anim", self, "spineObj", GameObject)
			ResourceMgr.EndSubmit()
		else
			SetActiveFunc(self.CardBg.gameObject, true)

			self.CardIcon.enabled = true

			RoleCardMgr:SetInfoPanel(infoRoleCard, self.CardIcon, self.CardBg)
		end

		RoleCardMgr:SetCardLocation(infoRoleCard, self.CardIcon.gameObject, 3)

		if infoRoleCard.data.ID == 103202 then
			GOUtil.SetTransformLocalScale(self.CardIcon.gameObject, 0.34)
		end

		self.CardName.text = infoRoleCard:GetName()

		UIUtil.SetImageSprite(self.CardJob, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S", self)
		UIUtil.SetImageSprite(self.CardRank, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoRoleCard.rank .. "_10", self)
		SetActiveFunc(self.Btntype2Look, not isRecv)
		SetActiveFunc(self.img_type2_limit, self.data.index == 7)
	end

	self:JPHideBtnIcon(obj)
end

function CellBattlePassAward:JPHideBtnIcon(obj)
	SetActiveFunc(obj.btn_icon, false)
end

function CellBattlePassAward:OnClickedBtnRecv(data)
	local infoOperationActive = OperationActiveMgr:Get(self.curindex)
	local canRecv = self.Day < self.data.index

	if canRecv then
		UIMgr.ShowMsg(_("Desc_Waiting"))

		return
	end

	if self.type == 2 then
		local GoodsId, State = OperationActiveMgr:GetBattlePassMonthIdState()

		if not State then
			UIMgr.ShowMsg(_("PageTalentTree_NotActive"))

			return
		end
	end

	Event.Instance:Fire("SaveBattlePass1ViewPos")
	Event.Instance:Fire("ReceiveOperationActiveAward", self.data.index, true, self.type == 2)
end
