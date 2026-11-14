-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/DlgAvatarSelBuy.lua

DlgAvatarSelBuy = class("DlgAvatarSelBuy", UIPanel)

function DlgAvatarSelBuy:ctor(parent)
	self.UIPrefabPath = "UI/PageFittingroom/DlgAvatarSelBuy"
	self.parentPage = parent
end

function DlgAvatarSelBuy:Purge()
	self.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgAvatarSelBuy:PreLoad()
	self:LoadResAsync("UI/PageFittingroom/CellAvatar", "PrefabCell", GameObject)
end

function DlgAvatarSelBuy:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnButtonQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonOK, self.OnButtonOK, PATH_SFX_UI_CONFIRM)
end

function DlgAvatarSelBuy:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnButtonQuit)
	self:RemoveClick(self.ButtonOK, self.OnButtonOK)
end

function DlgAvatarSelBuy:OnEnter(vParam)
	self:DealWithLocalization(vParam.hasNotBindBP)

	for i = 1, 6 do
		self["GoCost" .. i] = self:GetChildGameObject("Panel/CostGroup/" .. i)
		self["ImgIcon" .. i] = GOUtil.FindChildComponent(self["GoCost" .. i], "Image", "Image")
		self["TxtNeed" .. i] = GOUtil.FindChildComponent(self["GoCost" .. i], "TextNum", "Text")
		self["CostState" .. i] = false
	end

	self.TextPrompt = self:GetChildComponent("Panel/Text", "Text")
	self.TextPrompt.text = _("Desc_BpPromptMessage")
	self.ButtonQuit = self:GetChildGameObject("Panel/Button")
	self.ButtonOK = self:GetChildGameObject("Panel/Button_OK")

	self:InitData(vParam)
end

function DlgAvatarSelBuy:DealWithLocalization(hasNotBindBP)
	local txt = self:GetChildComponent("Panel/Title/Text", "Text")

	txt.text = _("Desc_ShopCar")
	txt = self:GetChildComponent("Panel/Button_OK/Text", "Text")
	txt.text = _("UI_Purchase")
end

function DlgAvatarSelBuy:InitData(vParam)
	if not vParam then
		return
	end

	self.infoRole = vParam.infoRole
	self.listAvatar = vParam.listAvatar or {}
	self.isSave = vParam.isSave

	local existNotBind = false

	for _, avatardata in ipairs(self.listAvatar) do
		if avatardata.InfoAvatar:IsBPAvatar() then
			if avatardata.Geted then
				existNotBind = true
			end
		elseif avatardata.IsUnlocked then
			avatardata.checkmark = true
		end
	end

	GOUtil.SetActive(self.TextPrompt, existNotBind)
	self:UpdateCost()
	self:UpdateScrollView()
end

function DlgAvatarSelBuy:UpdateScrollView()
	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listAvatar

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		item:UpdateData(self.listAvatar[index], self.selectIndex, self.infoRole, true, true)
		item:ShowCheckMark(self.listAvatar[index])
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellAvatar, self, true, addCallback, updateCallback)
end

function DlgAvatarSelBuy:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	self.selectIndex = info.Item.Index

	local avatarData = self.listAvatar[self.selectIndex]

	if avatarData.InfoAvatar:IsBPAvatar() or not avatarData.IsUnlocked then
		return
	end

	avatarData.checkmark = not avatarData.checkmark

	info.Item:ShowCheckMark(avatarData)
	self:UpdateCost()
end

function DlgAvatarSelBuy:UpdateCost()
	local listCost = {}

	for i = 1, #self.listAvatar do
		local avatarData = self.listAvatar[i]

		if not avatarData.InfoAvatar:IsBPAvatar() and avatarData.IsUnlocked and avatarData.checkmark then
			local infoAvatar = avatarData.InfoAvatar
			local coinId = infoAvatar.data.Cost[1]
			local coinNum = infoAvatar.data.Cost[2]

			if listCost[coinId] == nil then
				listCost[coinId] = {
					id = coinId,
					num = coinNum
				}
			else
				listCost[coinId].num = listCost[coinId].num + coinNum
			end
		end
	end

	local list = {}

	for _, v in pairs(listCost) do
		table.insert(list, v)
	end

	GOUtil.SetActive(self.ButtonOK, #list > 0)

	for i = 1, 6 do
		if i <= #list then
			if not self["CostState" .. i] then
				self["GoCost" .. i]:SetActive(true)

				self["CostState" .. i] = true
			end

			local cost = list[i]
			local id = cost.id or 501
			local num = cost.num or 0
			local strIcon = ItemManager:GetIcon(id)

			UIUtil.SetImageSprite(self["ImgIcon" .. i], strIcon, self)

			self["TxtNeed" .. i].text = cost.num .. "/" .. ItemManager:GetItemCount(id)

			local infoItem = ItemManager:Get(id)

			if num > infoItem:GetCurResNum() then
				UIUtil.SetGraphicColorRGB(self["TxtNeed" .. i], 1, 0.14901960784313725, 0.14901960784313725)
			else
				UIUtil.SetGraphicColorRGB(self["TxtNeed" .. i], 0.37254901960784315, 0.37254901960784315, 0.37254901960784315)
			end
		elseif self["CostState" .. i] then
			self["GoCost" .. i]:SetActive(false)

			self["CostState" .. i] = false
		end
	end

	self.listAll = list
end

function DlgAvatarSelBuy:OnButtonOK()
	local NotEnough = false
	local speAvatarCoin = {
		cost = 0,
		id = 0,
		hold = 0
	}

	if self.listAll then
		for _, cost in pairs(self.listAll) do
			local infoItem = ItemManager:Get(cost.id)
			local hold = infoItem:GetCurResNum()

			if hold < cost.num then
				NotEnough = true
			elseif GetItemType(infoItem.data.Type) == eItemType.I_AVATAR and infoItem.id == 1054 then
				speAvatarCoin.id = 1054
				speAvatarCoin.cost = speAvatarCoin.cost + cost.num
				speAvatarCoin.hold = hold
			end
		end
	end

	if NotEnough then
		UIMgr.ShowMsg(Lang(86001))

		return
	elseif speAvatarCoin.id ~= 0 then
		local function cb(index)
			if index == DlgCommonEvent.ButtonType.Ok then
				local listNeedBuyId = {}

				for _, avatarData in ipairs(self.listAvatar) do
					if avatarData.checkmark then
						table.insert(listNeedBuyId, avatarData.id)
					end
				end

				self:RequestBuyAvatar(listNeedBuyId)
			end
		end

		local data = {}

		data.content = _("Desc_Exist_Special_Avatar_Coin")
		data.alert = "<color=#585E62>" .. string.format(_("Desc_Cost"), string.format("[%d]%d/%d", GetEmojiId(speAvatarCoin.id), speAvatarCoin.cost, speAvatarCoin.hold)) .. "</color>"

		UIMgr.ShowCommon(DlgCommonEvent.Type.MsgWithAlert, _("Tittle_Affirm"), data, cb, _("Button_OK"), nil, true)

		return
	end

	local listNeedBuyId = {}

	for _, avatarData in ipairs(self.listAvatar) do
		if avatarData.checkmark then
			table.insert(listNeedBuyId, avatarData.id)
		end
	end

	self:RequestBuyAvatar(listNeedBuyId)
end

function DlgAvatarSelBuy:OnButtonQuit()
	self:Close()
end

function DlgAvatarSelBuy:UpdateListAvatar()
	local list = {}

	for _, v in ipairs(self.listAvatar) do
		local avatardata = AvatarManager:GetAvatarData(self.infoRole, v.id, self.parentPage.curMode.id)

		if not avatardata.Geted or avatardata.InfoAvatar:IsBPAvatar() and not PlayerInst:IsBind(avatardata.id, self.infoRole.id) then
			table.insert(list, avatardata)
		end
	end

	self.listAvatar = list

	if #self.listAvatar == 0 then
		self:Close()

		return
	end

	if self.UIScrollTool then
		self.UIScrollTool:UpdateListDataKeepPos(self.listAvatar)
	end

	self:UpdateCost()
end

function DlgAvatarSelBuy:GotoFromWhere(infoAvatar)
	if self.parentPage then
		self.parentPage:GotoFromWhere(infoAvatar)
	end

	self:Close()
end

function DlgAvatarSelBuy:RequestBind(avatarData)
	if not avatarData then
		return
	end

	local costId = 0
	local cost = 0
	local data
	local bpAvatar = PlayerInst:GetBPAvatar(avatarData.id)

	if bpAvatar and bpAvatar.roleId ~= 0 then
		costId = GetConfigArgJson("AvatarBindCost")[1]
		cost = GetConfigArgJson("AvatarBindCost")[2]
		data = {
			roleId = bpAvatar.roleId
		}
	end

	local function request()
		LoadingMgr.Show(eLoadingType.Repeat)

		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				if self.parentPage then
					self.parentPage:PlayBPBindInfo(avatarData.InfoAvatar, data)

					if self.parentPage.DlgCharacterThin then
						self.parentPage.DlgCharacterThin:UpdateRolesOrder()
					end
				end

				self:UpdateListAvatar()

				if self.isSave then
					self.parentPage:RequestSave()
				end
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		NetManager:RequestBindBPAvatar(self.infoRole.id, avatarData.id, wrap_cb)
	end

	if cost > 0 then
		local function cb(_type)
			if _type == DlgCommonEvent.ButtonType.Ok then
				local infoItem = ItemManager:Get(costId)

				if GetItemType(infoItem.data.Type) == eItemType.P_DIAMOND then
					if infoItem:GetCurResNum() < cost then
						ReplaceDiamond(cost, request)
					else
						request()
					end
				elseif ItemManager:IsItemHoldEnough(costId, cost) then
					request()
				end
			end
		end

		local msg = string.format(_("Desc_Bind_Prompt"), GetEmojiId(costId), cost)
		local emjiType = GetEmojiId(costId)

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), {
			text = msg,
			isDiamond = emjiType == eEmojiItemType.P_DIAMOND or emjiType == eEmojiItemType.P_DIAMOND_PAY
		}, cb, _("UI_Btn_Bind"), _("Quite_Cancel"), false)
	else
		request()
	end
end

function DlgAvatarSelBuy:RequestBuyAvatar(listBuyId)
	local function panelCb()
		self:UpdateListAvatar()
		Event.Instance:Fire("DoAfterBuyAvatar", self.isSave, listBuyId)
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			SoundMgr.Play(PATH_SFX_UI_SHOP_BUYSUCCESS)

			local setter = {}

			for k, avatarId in ipairs(listBuyId) do
				table.insert(self.infoRole.pb.avatars, avatarId)

				local s = {
					from = 0,
					asset = eItemType.R_AVATAR,
					id = self.infoRole.id,
					num = avatarId
				}

				table.insert(setter, s)
			end

			UIMgr.AddPanel(DlgGetAward(), {
				list = setter,
				callback = panelCb
			})
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBuyAvatar(self.infoRole.id, listBuyId, wrap_cb)
end
