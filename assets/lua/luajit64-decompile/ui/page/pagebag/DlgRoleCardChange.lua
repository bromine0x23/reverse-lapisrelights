-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBag/DlgRoleCardChange.lua

require("UI/Item/CellItem")

DlgRoleCardChange = class("DlgRoleCardChange", UIPanel)

function DlgRoleCardChange:ctor()
	self.UIPrefabPath = "UI/PageBag/DlgRoleCardChange"
end

function DlgRoleCardChange:PreLoad()
	return
end

function DlgRoleCardChange:Purge()
	DlgRoleCardChange.base.Purge(self)
end

function DlgRoleCardChange:OnRegisterEvent()
	self:AddClick(self.ButtonOK, self.OnButtonOK)
	self:AddClick(self.ButtonQuit, self.OnButtonQuit, PATH_SFX_UI_CANCEL)
end

function DlgRoleCardChange:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonOK, self.OnButtonOK)
	self:RemoveClick(self.ButtonQuit, self.OnButtonQuit)
end

function DlgRoleCardChange:OnButtonQuit()
	self:Close()
end

function DlgRoleCardChange:OnEnter(vParam)
	self.PanelMsg = self:GetChildGameObject("TweenRoot/Main/PanelMsg")

	self.PanelMsg:SetActive(false)

	self.ButtonQuit = self:GetChildGameObject("TweenRoot/Main/Button")
	self.ButtonOK = self:GetChildGameObject("TweenRoot/Main/Grid/Button_OK")

	local TextTitle = self:GetChildComponent("TweenRoot/Main/bg_title2/Text", "Text")
	local Text = self:GetChildComponent("TweenRoot/Main/Text", "Text")

	TextTitle.text = _("Desc_ChoiceCardBag")
	Text.text = _("Desc_ClickToChoice")

	local Label_OK = self:GetChildComponent("TweenRoot/Main/Grid/Button_OK/Label_OK", "Text")

	Label_OK.text = _("UI_OK")
	self.PrefabCellSelCard = self:GetChildGameObject("CellSelCard")
	self.Content = self:GetChildGameObject("TweenRoot/Main/ScrollView/Viewport/Content")

	GOUtil.DestroyAllChildren(self.Content)

	local RewardPack = require("luaData/RewardPack")

	self.infoItem = vParam.info

	local info = vParam.info

	self.listGoItem = {}
	self.listCardId = {}

	local list = RewardPack[info.data.UseId].ItemList

	for i = 1, #list do
		local data = list[i]
		local g = GOUtil.Instantiate(self.PrefabCellSelCard, self.Content)

		SetActiveFunc(g, true)

		local imgIcon = GOUtil.FindChildComponent(g, "Icon/Image", "Image")
		local bg = GOUtil.FindChildComponent(g, "bg", "Image")
		local imgJob = GOUtil.FindChildComponent(g, "ImageJob", "Image")
		local ImgLight = GOUtil.FindChildGameObject(g, "ImgLight")
		local itemId = data[1]
		local roleCardId = data[2]
		local infoCard = RoleCardMgr:GetRoleCard(roleCardId)
		local infoRole = RoleCardMgr:GetRole(roleCardId)

		SetImageSprite(imgIcon, infoCard.data.MidIcon, self)
		SetImageSprite(bg, "UIDyAtlas/RoleCardRank/BG_card_back_" .. infoCard.rank .. "_15", self)
		SetImageSprite(imgJob, "UI/PanelWork/AtlasPanelWork/ICO_" .. infoRole.data.Job .. "_01_S", self)

		g.name = i

		table.insert(self.listGoItem, g)
		table.insert(self.listCardId, roleCardId)
		self:AddListener(g, self.OnLongPressCondition, EventTriggerType.PointerLongPress)

		if i == 1 then
			self:OnSelCard(roleCardId)
			SetActiveFunc(ImgLight, true)
		end
	end
end

function DlgRoleCardChange:OnLongPressCondition(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local cardId = self.listCardId[index]

	if data.clickCount == 1 then
		print("caid:" .. cardId)
		require("UI/Page/PageRoleCard/Page/PageRoleCard")

		local data = {
			onlyShow = true,
			cardId = cardId,
			popData = {}
		}

		UIMgr.SwitchPanel(PageRoleCard(), data)
		self:Close()
	else
		self:OnSelCard(cardId)

		local g = self.listGoItem[index]
		local ImgLight = GOUtil.FindChildGameObject(g, "ImgLight")

		SetActiveFunc(ImgLight, true)
	end
end

function DlgRoleCardChange:OnButtonOK()
	if self.selCardId and self.selCardId > 0 then
		local function cb(index)
			if index == 1 then
				print("self.selCardId:" .. self.selCardId)
				self:UseItem(self.selCardId)
			end
		end

		UIMgr.ShowDialog(_("Desc_TipConfirmGetCard"), cb)
	else
		self:UseItem(0)
	end
end

function DlgRoleCardChange:UseItem(_selCardId)
	if _selCardId == nil then
		_selCardId = 0
	end

	NetManager:RequestUseItemChest(self.infoItem.id, _selCardId, 1, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self:Close()
			Event.Instance:Fire("UpdateBag")
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgRoleCardChange:OnSelCard(selCardId)
	self.selCardId = selCardId

	for i = 1, #self.listGoItem do
		local g = self.listGoItem[i]
		local ImgLight = GOUtil.FindChildGameObject(g, "ImgLight")

		SetActiveFunc(ImgLight, false)
	end
end
