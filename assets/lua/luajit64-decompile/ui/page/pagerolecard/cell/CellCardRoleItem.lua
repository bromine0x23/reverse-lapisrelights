-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Cell/CellCardRoleItem.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageRoleCard/Cell/CellCard")

local InfoTeam = require("Info/InfoTeam")

CellCardRoleItem = class("CellCardRoleItem", UIItemBase)

function CellCardRoleItem:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCardRoleItem:Create(vParam)
	CellCardRoleItem.base.Create(self, vParam)
end

function CellCardRoleItem:OnEnter()
	local g = self.UIRootObject

	self.PrefabCell = ResourceMgr.LoadSync("UI/Common/CellCard/CellCard")
	self.myRoleCardPreLoad = ResourceMgr.LoadSync("UI/PanelChooseCard/MyRoleCard")
	self.go_head = GOUtil.FindChildGameObject(g, "img_head")
	self.img_head = self:GetChildComponent("img_head", "Image")
	self.go_new = GOUtil.FindChildGameObject(g, "img_head/go_new")
	self.img_logo = GOUtil.FindChildComponent(g, "img_head/bg_logo/img_logo", "Image")

	GOUtil.SetRectTransformAnchoredPosition(GOUtil.FindChildGameObject(g, "img_head/img_job"), -150, -72.4)

	self.img_job = GOUtil.FindChildComponent(g, "img_head/img_job", "Image")
	self.tex_name = GOUtil.FindChildComponent(g, "img_head/bg_name/tex_name", "Text")
	self.tex_name.fontSize = 40
	self.tex_fight = GOUtil.FindChildComponent(g, "img_head/tex_fight", "Text")
	self.go_up = self:GetChildGameObject("img_head/go_up")
	self.BG = self:GetChildGameObject("BG")
	self.btn_gorole = self:GetChildGameObject("img_head/btn_gorole")

	self:AddClick(self.btn_gorole, self.OnClickedGoRole)

	local Text = GOUtil.FindChildComponent(g, "img_head/Text", "Text")

	Text.text = _("Desc_Combat_Role_Score")
	Text = self:GetChildComponent("img_head/go_up/Text", "Text")
	Text.text = Lang(5000013)
	self.scrollArea = GOUtil.FindChildGameObject(g, "ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.CanvasGroup = self:GetChildComponent("img_head", "CanvasGroup")
end

function CellCardRoleItem:RefreshPosition()
	Event.Instance:Fire("RefreshUIScrollTooPosition")
end

function CellCardRoleItem:OnLeave()
	if self.UIScrollTool ~= nil then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.myRoleCardPreLoad then
		ResourceMgr.Unload(self.myRoleCardPreLoad)

		self.myRoleCardPreLoad = nil
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	if self.PrefabCellUnCard then
		ResourceMgr.Unload(self.PrefabCellUnCard)

		self.PrefabCellUnCard = nil
	end

	self:RemoveClick(self.btn_gorole, self.OnClickedGoRole)
	UnloadAllImageSprite(self)
end

function CellCardRoleItem:OnClickedGoRole()
	local posY = self.parentScoll.ScrollView.content.anchoredPosition.y

	CardExtraMgr:SetCardViewPosY(posY)
	require("UI/Page/PageRole/PageRole")
	UIMgr.SwitchPanel(PageRole, {
		roleId = self.info.id
	})
end

function CellCardRoleItem:OnClickedGoAdd()
	return
end

function CellCardRoleItem:OnClickedGoGet()
	return
end

function CellCardRoleItem:UpdateData(infoRole, isOpen, myCardList, Index, parentScoll)
	self.info = infoRole
	self.parentScoll = parentScoll

	self.go_new:SetActive(RoleRDL.NewRDL.IsNewRole(infoRole))
	SetImageSprite(self.img_job, "UI/Common/CellCard/AtlasCellCard/ICO_" .. infoRole.data.Job .. "_01_S", self)

	self.tex_name.text = infoRole:GetName()
	self.tex_fight.text = Mathf.Floor(RoleMgr:GetRoleScore(infoRole))
	self.isOpen = CardExtraMgr.detailsLookInfo

	SetImageSprite(self.img_head, "UIDyAtlas/CharacterRoleIcon/IC_teamsel_" .. infoRole.data.Enname .. "_01", self)
	self.BG:SetActive(Index % 2 == 1)

	self.listRoleCard = RoleCardMgr:GetRoleHoldCard(infoRole.id)

	CardSortMgr.CardFilterSort(CardSortMgr.SORT_TYPES.POWER, self.listRoleCard)

	local pickCardId = infoRole:GetRoleCardId()
	local rank = RoleCardMgr:GetRoleCard(pickCardId).rank

	UIUtil.SetImageSprite(self.img_logo, "UI/AtlasRank/IC_card_logo_" .. rank, self)
	self.go_up:SetActive(false)

	local teamList = InfoTeam.stageTeams[TeamMgr.Instance:GetTeamIndex()].roleCardTeams

	for n = 1, #teamList do
		if teamList[n] ~= 0 and RoleCardMgr:GetRoleId(teamList[n]) == infoRole.id then
			self.go_up:SetActive(true)

			break
		end
	end

	if myCardList then
		local count = #self.listRoleCard

		if count <= 5 then
			count = 5
		end

		if self.UIScrollTool then
			self.UIScrollTool.ScrollView:ResetScrollView(count, false)

			return
		end

		local function addCallback(item)
			self:AddClick(item.UIRootObject, nil)
		end

		local function updateCallback(item, index)
			local cardData = self.listRoleCard[index]

			if cardData then
				item:UpdateData(myCardList.teamSystemAgent, myCardList.clickSlot, cardData, myCardList.upCardListIds, false, self.parentScoll)
			else
				item:UpdateData(index)
			end
		end

		self.UIScrollTool = UIScrollTool()

		self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.myRoleCardPreLoad, MyRoleCard, self, true, addCallback, updateCallback)
	else
		local count = #self.listRoleCard

		if count <= 5 then
			count = 5
		end

		if self.UIScrollTool then
			self.UIScrollTool.ScrollView:ResetScrollView(count, false)

			return
		end

		local function addCallback(item)
			self:AddClick(item.UIRootObject, self.OnClickedCell)
		end

		local function updateCallback(item, index)
			local info = self.listRoleCard[index]

			if info then
				local data = {
					cardId = info.id,
					team = InfoTeam.stageTeams[TeamMgr.Instance:GetTeamIndex()].roleCardTeams
				}

				item:UpdateData(data)
			else
				item:UpdateData({
					index = index
				})
			end
		end

		self.UIScrollTool = UIScrollTool()

		self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellCard, self, true, addCallback, updateCallback)
	end
end

function CellCardRoleItem:OnClickedCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	self.isOpen = CardExtraMgr.detailsLookInfo

	if not self.listRoleCard[index] then
		return
	end

	local cardId = self.listRoleCard[index].id

	if not self.isOpen then
		if CardExtraMgr.enterType ~= eEnterType.cardShow then
			local posY = self.parentScoll.ScrollView.content.anchoredPosition.y

			CardExtraMgr:SetCardViewPosY(posY)

			local data = {
				tag = 1,
				cardId = cardId
			}

			CardSwitchMgr:ResetCardIdsByRole(RoleCardMgr:GetRoleId(cardId))
			UIMgr.SwitchPanel(PageRoleCard, data)
		else
			Event.Instance:Fire("DealWithShowCard", cardId)
		end
	else
		local param = {}

		param.call = nil
		param.infoRoleCard = self.listRoleCard[index]

		require("UI/Page/PageTeam/DlgCardDetail")
		UIMgr.AddPanel(DlgCardDetail(), param)
	end
end

function CellCardRoleItem:SetAlpha(alpha)
	self.CanvasGroup.alpha = alpha
end

function CellCardRoleItem:PlayAnim()
	self.Animator:Play("CellCardRoleItem_show")
end
