-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFriend/DlgFriendPanel.lua

DlgFriendPanel = class("DlgFriendPanel", UIPanel)

function DlgFriendPanel:ctor()
	self.UIPrefabPath = "UI/PanelFriend/PanelFriend"
end

function DlgFriendPanel:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PanelFriend/CellFriend")
end

function DlgFriendPanel:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
	UITweenUtil.RemoveTween(self.content)
	ResourceMgr.Unload(self.PrefabCell)

	if self.UIScrollTool ~= nil then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgFriendPanel:OnRegisterEvent()
	self:AddClick(self.BtnSend, self.OnClickedBtnSend)
	self:AddClick(self.BtnRecv, self.OnClickedBtnRecv)
	self:AddClick(self.BtnShop, self.OnClickedBtnShop)
	self:AddClick(self.GuideBtn, self.OnClickedGuideBtn)
	Event.Instance:Add("RefreshFriendPanel", self.UpdatePanel, self)
end

function DlgFriendPanel:OnUnRegisterEvent()
	self:RemoveClick(self.BtnSend, self.OnClickedBtnSend)
	self:RemoveClick(self.BtnRecv, self.OnClickedBtnRecv)
	self:RemoveClick(self.BtnShop, self.OnClickedBtnShop)
	self:RemoveClick(self.GuideBtn, self.OnClickedGuideBtn)
	Event.Instance:Remove("RefreshFriendPanel", self.UpdatePanel, self)
end

function DlgFriendPanel:OnEnter(vParam)
	if not GuideMgr:IsGuided(GuideFunctionType.Friend) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.Friend)
	end

	self:DealWithLocalization()

	self.TxtFriendCount = self:GetChildComponent("Panel/TextCount", "Text")
	self.TxtFriendCoin = self:GetChildComponent("Panel/FriendCoin/CoinBar/Text", "Text")
	self.ImgFriendCoinBar = self:GetChildComponent("Panel/FriendCoin/CoinBar/Image", "Image")
	self.GoNoFriend = self:GetChildGameObject("Panel/GoNoFriend")
	self.BtnSend = self:GetChildGameObject("Panel/BtnSend")
	self.BtnRecv = self:GetChildGameObject("Panel/BtnRecv")
	self.BtnShop = self:GetChildGameObject("Panel/BtnShop")
	self.GuideBtn = self:GetChildGameObject("Panel/bg_title2/GuideBtn")
	self.GoBtnSendDisable = self:GetChildGameObject("Panel/BtnSend/Image")
end

function DlgFriendPanel:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/FriendCoin/Text", "Text")
	Text.text = _("Desc_Friend_CoinToday")
	Text = self:GetChildComponent("Panel/BtnRecv/Text", "Text")
	Text.text = _("Desc_OneKeyInteraction")
	Text = self:GetChildComponent("Panel/BtnSend/Text", "Text")
	Text.text = _("Desc_OneKeyInteraction")
	Text = self:GetChildComponent("Panel/BtnShop/Text", "Text")
	Text.text = _("FriendPanel_ShopButton")
	Text = self:GetChildComponent("Panel/GoNoFriend/Text", "Text")
	Text.text = _("Desc_Friend_None_Temp")
end

function DlgFriendPanel:Show()
	SetActiveFunc(self.UIRootObject, true)
	self:UpdatePanel()
	UITweenUtil.RemoveTween(self.content)
	UITweenUtil.OrderAlphaAnim(self.content, 0.2)
end

function DlgFriendPanel:Hide()
	SetActiveFunc(self.UIRootObject, false)
end

function DlgFriendPanel:UpdatePanel()
	self.listFriend = FriendMgr:SortFriend(FriendMgr:GetFriendList())

	if self.inited then
		self.UIScrollTool:UpdateListDataKeepPos(self.listFriend)
	else
		self:InitFriendList()

		self.inited = true
	end

	local curFriendCnt = #self.listFriend

	SetActiveFunc(self.GoNoFriend, curFriendCnt == 0)

	local canR = not InfoGameInst:IsOverRecvFriendCoinNumToday()
	local haveR = not FriendMgr:IsRecvAllFriendToday()
	local haveS = not FriendMgr:IsGiftAllFriendToday()
	local gray = TenaryOp(haveS, 0, 1)

	gray = TenaryOp(haveS or haveR, 0, 1)

	GOUtil.SetActive(self.GoBtnSendDisable, gray == 1)

	self.TxtFriendCount.text = string.format(_("Friend_Num"), "：" .. curFriendCnt .. "/" .. FriendMgr.maxFriendNum)

	local curNum = InfoGameInst.todayRecvFriendCoinNum
	local maxNum = InfoGameInst.maxRecvFriendCoinNum
	local k = GetConfigArgInt("FriendGiftCoin")

	self.TxtFriendCoin.text = curNum * k .. "/" .. maxNum * k
	self.ImgFriendCoinBar.fillAmount = curNum / maxNum
end

function DlgFriendPanel:InitFriendList()
	local scrollArea = self:GetChildGameObject("Panel/FriendList/ScrollArea")

	self.content = self:GetChildComponent("Panel/FriendList/ScrollArea/Content", "RectTransform")

	local count = #self.listFriend

	local function cb()
		Event.Instance:Fire("RefreshFriendPanel")
	end

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updCallback(item, index)
		local infoFriend = self.listFriend[index]

		item:UpdateData(infoFriend, eFLType.friend, cb)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCell, CellFriend, self, false, addCallback, updCallback)
end

function DlgFriendPanel:OnClickedBtnSend()
	if #self.listFriend == 0 then
		UIMgr.ShowMsg(Lang(12505))

		return
	end

	local function func1(...)
		if FriendMgr:IsGiftAllFriendToday() then
			return
		end

		local data = {
			type = 1,
			callback = function()
				self:UpdatePanel()
			end
		}

		Event.Instance:Fire("OperateFriendshipCoin", data)
	end

	local function func2(...)
		if FriendMgr:IsRecvAllFriendToday() then
			return
		end

		local data = {
			type = 2,
			callback = function()
				self:UpdatePanel()
			end
		}

		Event.Instance:Fire("OperateFriendshipCoin", data)
	end

	func2()
	func1()
end

function DlgFriendPanel:OnClickedBtnRecv()
	if #self.listFriend == 0 then
		UIMgr.ShowMsg(Lang(12505))

		return
	end

	if FriendMgr:IsRecvAllFriendToday() then
		UIMgr.ShowMsg(Lang(12507))

		return
	end

	local data = {
		type = 2,
		callback = function()
			self:UpdatePanel()
		end
	}

	Event.Instance:Fire("OperateFriendshipCoin", data)
end

function DlgFriendPanel:OnClickedBtnShop()
	require("UI/Page/PageShop/PageShop")

	local data = {
		tagIndex = 2,
		tabMainIndex = tabMainType.exchange
	}

	PageShop.InitNetData(data)
	self.parentPanel:Close()
end

function DlgFriendPanel:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Friend)
end
