-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgItemTip.lua

require("UI/Item/UIItemBase")
require("UI/UIScrollTool")
require("UI/Item/CellItem")

CellAccess = class("CellAccess", UIItemBase)
TIMESPACE_MEDAL = 77770053

function CellAccess:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellAccess:OnEnter()
	local g = self.UIRootObject

	self.BG = GOUtil.GetComponent(g, "Image")
	self.img_line = GOUtil.FindChildComponent(g, "img_line", "Image")
	self.img_type = GOUtil.FindChildComponent(g, "img_type", "Image")
	self.tex_type = GOUtil.FindChildComponent(g, "img_type/tex_type", "Text")
	self.goStar = GOUtil.FindChildGameObject(g, "Star")

	for i = 1, 3 do
		self["Star" .. i] = GOUtil.FindChildGameObject(g, "Star/Star" .. i)
	end

	self.Button = GOUtil.FindChildGameObject(g, "Button")
	self.Text = GOUtil.FindChildComponent(g, "Text", "Text")
	self.GoGray = GOUtil.FindChildGameObject(g, "ButtonGray")
	TextAuto = GOUtil.FindChildComponent(g, "Button/Text", "Text")
	TextAuto.text = _("UI_Click_Go")
	TextAuto = GOUtil.FindChildComponent(g, "ButtonGray/Text", "Text")
	TextAuto.text = _("UI_Click_Go")
end

DlgItemTip = class("DlgItemTip", UIPanel)

function DlgItemTip:ctor()
	self.UIPrefabPath = "UI/PageBag/DlgItemTip"
	self.callback = nil
	self.closed = true
end

function DlgItemTip:Purge()
	if self.PageItemSyn then
		self.PageItemSyn:Purge()
	end

	if self.UIScrollToolPanel then
		self.UIScrollToolPanel:Purge()

		self.UIScrollToolPanel = nil
	end

	if self.isLimit then
		UIMgr.RemoveUpdatePanel(self)
	end

	DlgItemTip.base.Purge(self)
end

function DlgItemTip:PreLoad()
	self.PrefabCellAccess = ResourceMgr.LoadSync("UI/PageBag/CellFrom")
	self.PrefabCellItem = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function DlgItemTip:OnEnter(vParam)
	self.ButtonBg = self:GetChildGameObject("Image")
	self.ButtonQuit = self:GetChildGameObject("Panel/ButtonQuit")
	self.PanelFrom = self:GetChildGameObject("Panel/PanelFrom")
	self.PanelGift = self:GetChildGameObject("Panel/PanelGift")
	self.PanelDetail = self:GetChildGameObject("Panel/PanelDetail")
	self.ButtonFromGift = self:GetChildGameObject("Panel/PanelGift/Button")
	self.ButtonDetail = self:GetChildGameObject("Panel/PanelFrom/Button")
	self.ButtonFromDetail = self:GetChildGameObject("Panel/PanelDetail/Button")
	self.Button1 = self:GetChildGameObject("Panel/PanelGift/Button1")
	self.Button2 = self:GetChildGameObject("Panel/PanelGift/Button2")
	self.ButtonUp = self:GetChildGameObject("Panel/PanelGift/ButtonUp")
	self.InputField = self:GetChildComponent("Panel/PanelGift/InputField", "InputField")
	self.ButtonOk = self:GetChildGameObject("Panel/PanelGift/ButtonOk")
	self.ButtonUse = self:GetChildGameObject("Panel/ButtonUse")
	self.ButtonSyn = self:GetChildGameObject("Panel/SynButton")
	self.BtnUnlock = self:GetChildGameObject("Panel/PanelDetail/BtnUnlock")
	self.TextGift1 = self:GetChildComponent("Panel/PanelGift/Text1", "TextView")
	self.TextGift2 = self:GetChildComponent("Panel/PanelGift/Text2", "TextView")
	self.TextDetail1 = self:GetChildComponent("Panel/PanelDetail/Text1", "TextView")
	self.TextDetail2 = self:GetChildComponent("Panel/PanelDetail/Text2", "TextView")
	self.TextFrom1 = self:GetChildComponent("Panel/PanelFrom/Text1", "Text")

	self.TextFrom1.gameObject:SetActive(false)

	self.GoCellItem = self:GetChildGameObject("Panel/CellItem")
	self.TextItemName = self:GetChildComponent("Panel/Bg/Text", "Text")
	self.GoTime = self:GetChildGameObject("Panel/ImgTime")
	self.TextTime = self:GetChildComponent("Panel/ImgTime/Text", "Text")

	self:InitScrollView()

	self.ScrollView = self:GetChildGameObject("Panel/ScrollView")
	self.SelCardContent = self:GetChildGameObject("Panel/ScrollView/Viewport/Content")

	self.ScrollView:SetActive(false)

	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Title/Text/", "Text")
	TextAuto.text = _("ItemTip_UnionActive")
	TextAuto = self:GetChildComponent("Panel/PanelFrom/Button/Text/", "Text")
	TextAuto.text = Lang(5000054)
	TextAuto = self:GetChildComponent("Panel/PanelFrom/Text1/", "Text")
	TextAuto.text = Lang(5000055)
	TextAuto = self:GetChildComponent("Panel/PanelGift/Button/Text/", "Text")
	TextAuto.text = Lang(5000056)
	TextAuto = self:GetChildComponent("Panel/PanelGift/ButtonOk/Text/", "Text")
	TextAuto.text = Lang(5000057)
	TextAuto = self:GetChildComponent("Panel/CellItem/2/Text/", "Text")
	TextAuto.text = Lang(5000058)
	TextAuto = self:GetChildComponent("Panel/PanelDetail/Button/Text/", "Text")
	TextAuto.text = _("PageFittingroom_btnType_from")
	TextAuto = self:GetChildComponent("Panel/SynButton/Text", "Text")
	TextAuto.text = _("Item_Synthetize")
	TextAuto = self:GetChildComponent("Panel/ButtonUse/Text", "Text")
	TextAuto.text = _("UI_Use")
	TextAuto = self:GetChildComponent("Panel/PanelDetail/BtnUnlock/Text", "Text")
	TextAuto.text = _("Desc_goUnlock")

	self:Show(unpack(vParam))
end

function DlgItemTip:OnQuit()
	if self.callback then
		self.callback = nil
	end

	self:Hide()
end

function DlgItemTip:OnRegisterEvent()
	self:AddClick(self.ButtonBg, self.OnQuit)
	self:AddClick(self.ButtonQuit, self.OnQuit)
	self:AddClick(self.ButtonDetail, self.OnGoDetail)
	self:AddClick(self.ButtonFromGift, self.OnGoFrom)
	self:AddClick(self.ButtonFromDetail, self.OnGoFrom)
	self:AddClick(self.ButtonSyn, self.OnClickGemSyn)
	self:AddClick(self.Button1, self.OnClickedButtonAdjust)
	self:AddClick(self.Button2, self.OnClickedButtonAdjust)
	self:AddClick(self.ButtonUp, self.OnClickedButtonAdjust)
	self:AddClick(self.ButtonOk, self.OnClickedButtonUse)
	self:AddClick(self.ButtonUse, self.OnClickedButtonCardPackUse)
	self:AddClick(self.BtnUnlock, self.OnClickedBtnUnlock)
end

function DlgItemTip:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonBg, self.OnQuit)
	self:RemoveClick(self.ButtonQuit, self.OnQuit)
	self:RemoveClick(self.ButtonDetail, self.OnGoDetail)
	self:RemoveClick(self.ButtonFromGift, self.OnGoFrom)
	self:RemoveClick(self.ButtonFromDetail, self.OnGoFrom)
	self:RemoveClick(self.ButtonSyn, self.OnClickGemSyn)
	self:RemoveClick(self.Button1, self.OnClickedButtonAdjust)
	self:RemoveClick(self.Button2, self.OnClickedButtonAdjust)
	self:RemoveClick(self.ButtonUp, self.OnClickedButtonAdjust)
	self:RemoveClick(self.ButtonOk, self.OnClickedButtonUse)
	self:RemoveClick(self.ButtonUse, self.OnClickedButtonCardPackUse)
	self:RemoveClick(self.BtnUnlock, self.OnClickedBtnUnlock)
end

function DlgItemTip:OnClickedButtonAdjust(data)
	local go = data.pointerPress
	local infoItem = self.infoItem
	local maxNum = infoItem:GetCurResNum()

	if maxNum == 0 then
		maxNum = 1
	end

	if go.name == "Button1" then
		self.adjustNum = self.adjustNum - 1

		if self.adjustNum < 1 then
			self.adjustNum = 1
		end
	elseif go.name == "Button2" then
		self.adjustNum = self.adjustNum + 1

		if maxNum < self.adjustNum then
			self.adjustNum = maxNum
		end
	elseif go.name == "ButtonUp" then
		self.adjustNum = maxNum
	end

	if self.buyNum ~= self.adjustNum then
		self.buyNum = self.adjustNum
		self.InputField.text = self.buyNum
	end
end

function DlgItemTip:OnClickedButtonUse()
	NetManager:RequestUseItemChest(self.infoItem.id, 0, self.buyNum, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self:OnQuit()
			Event.Instance:Fire("UpdateBag")
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgItemTip:OnClickedButtonCardPackUse()
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

function DlgItemTip:UseItem(_selCardId)
	if _selCardId == nil then
		_selCardId = 0
	end

	NetManager:RequestUseItemChest(self.infoItem.id, _selCardId, 1, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self:OnQuit()
			Event.Instance:Fire("UpdateBag")
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgItemTip:OnSelCard(selCard)
	self.selCardId = selCard.value

	for i = 1, #self.listItem do
		local item = self.listItem[i]

		item.ImgSel:SetActive(false)
	end
end

function DlgItemTip:OnGoDetail()
	self.PanelFrom:SetActive(false)
	self.PanelGift:SetActive(false)
	self.PanelDetail:SetActive(false)

	if self.tag == 2 then
		self.PanelGift:SetActive(true)
	else
		self.PanelDetail:SetActive(true)
	end
end

function DlgItemTip:OnGoFrom()
	self.PanelFrom:SetActive(true)
	self.PanelGift:SetActive(false)
	self.PanelDetail:SetActive(false)
end

function DlgItemTip:OnClickGemSyn()
	if self.initPanelIndex == 3 then
		require("UI/Page/PageSynthetize/PageGemSynthetize")
		UIMgr.AddPanel(PageGemSynthetize(), {
			itemInfo = self.infoItem
		})
	elseif self.initPanelIndex == 4 then
		require("UI/Page/PageSynthetize/PageItemSynthetize")
		UIMgr.AddPanel(PageItemSynthetize(), {
			itemInfo = self.infoItem
		})
	end

	self:OnQuit()
end

function DlgItemTip:OnClickedBtnUnlock()
	local infoAvatar = AvatarManager:GetAvatar(self.infoItem.pb.num)

	Event.Instance:Fire("GotoFromWhere", infoAvatar)
	self:OnQuit()
end

function DlgItemTip:Show(info, initPanelIndex, showNum, needFromBtn, callback, needItem)
	self.PanelFrom:SetActive(false)
	self.PanelGift:SetActive(false)
	self.PanelDetail:SetActive(false)
	self.ButtonFromGift:SetActive(false)
	self.ButtonFromDetail:SetActive(false)
	self.GoTime:SetActive(false)
	self.ButtonSyn:SetActive(false)
	self.ButtonUse:SetActive(false)
	self.ScrollView:SetActive(false)

	self.tag = 1
	self.needItem = needItem
	self.initPanelIndex = initPanelIndex
	self.cellItem = CellItem()

	self.cellItem:Init(self.GoCellItem)
	self.cellItem:UpdateNoNumType(info)

	if info.data.Type == "CLUB_GVG_SKILL" then
		local TextAuto = self:GetChildComponent("Panel/Title/Text/", "Text")

		TextAuto.text = _("BossRaid_Alert_1")
	end

	self.cellItem.ItemName.gameObject:SetActive(false)

	if info.belong then
		local path = info:GetIcon() .. "_0" .. info.belong

		self.cellItem:ResetItemIcon(path)
	end

	GOUtil.SetActive(self.cellItem.ItemName, info.data.ShowNum == 1)

	if info.data.ShowNum == 1 then
		if info.data.Type == "" or info:GetType() == eItemType.I_SOUL and info.data.Value == 0 then
			self.cellItem.ItemName.text = ""
		else
			self.cellItem.ItemName.text = _("Desc_itemTipNum") .. NumMagnitudeConversion(ItemManager:GetItemCount(info.data.ID), 0)
		end
	end

	self.isLimit = info.data.Time ~= "" or info.clearTime ~= 0

	self.cellItem.gImgLimit:SetActive(self.isLimit)

	if self.isLimit then
		self.isOveTime = false

		UIMgr.SetUpdatePanel(self)

		local InfoTitle = require("Info/InfoTitle")

		if info:GetType() == eItemType.P_MEDAL and not InfoTitle:TitleIsUnlock(info.data.id) then
			-- block empty
		else
			local curServerTime = NetData:GetCurServerTime()
			local endTime = info.clearTime * DateUtil.MillsPerSecond

			if info.data.ID == TIMESPACE_MEDAL then
				endTime = TimeSpaceChapterMgr.EndTime * DateUtil.MillsPerSecond
			end

			if curServerTime < endTime then
				self.TextTime.text = DateUtil.GetTwoMomentByMillis(endTime - curServerTime) .. _("Desc_RecoveryTime")
			else
				self.TextTime.text = _("Desc_StaleDated")
				self.isOveTime = true
			end

			self.GoTime:SetActive(true)
		end
	end

	local strName, strDesc = info:GetNameAndDesc()

	self.TextItemName.text = strName
	self.TextGift1.Text = ModifyRichTextForTextView(strDesc)
	self.TextDetail1.Text = ModifyRichTextForTextView(strDesc)
	self.TextGift2.Text = Lang(info.data.UseInfo)
	self.TextDetail2.Text = Lang(info.data.UseInfo)

	do
		local isLock = false
		local canGotoGet = false

		if info.data.Type == "R_AVATAR" or info.data.Type == "P_AVATAR" then
			local infoAvatar = AvatarManager:GetAvatar(info.pb.num)

			if info.tempRoleId then
				local infoRole = RoleMgr:GetRole(info.tempRoleId)

				isLock = not AvatarManager:IsUnlocked(infoRole, infoAvatar)
				canGotoGet = AvatarManager:IsCanGotoGet(infoAvatar)
				info.tempRoleId = nil
			end

			if infoAvatar:IsWeaponAvatar() then
				if isLock then
					self.TextDetail2.Text = ModifyRichTextForTextView(_("Avatar_From_" .. infoAvatar.data.FromWhere))
				end
			elseif info.data.Type == "P_AVATAR" then
				local str

				if isLock then
					if canGotoGet then
						str = AvatarManager.GetStrAtt(infoAvatar, true)[1] .. "\n" .. _("Avatar_From_" .. infoAvatar.data.FromWhere)
					else
						str = AvatarManager.GetStrAtt(infoAvatar, true)[1] .. "\n" .. _("Tip_AatarExpired_" .. infoAvatar.data.FromWhere)
					end
				else
					str = AvatarManager.GetStrAtt(infoAvatar, true)[1]
				end

				self.TextDetail2.Text = ModifyRichTextForTextView(str)
			elseif isLock then
				local fromWhere = infoAvatar.data.FromWhere
				local str

				if fromWhere == eAvatarFrom.petal or fromWhere == eAvatarFrom.card or fromWhere == eAvatarFrom.limit_card_pool then
					local card = RoleCardMgr:GetRoleCard(infoAvatar.data.FromRoleCardID)

					if canGotoGet then
						str = string.format(_("Avatar_From_" .. fromWhere), card:GetName())
					else
						str = string.format(_("Avatar_From_" .. fromWhere), card:GetName()) .. "\n" .. _("Tip_AatarExpired_" .. fromWhere)
					end
				elseif canGotoGet then
					str = _("Avatar_From_" .. fromWhere)
				else
					str = _("Avatar_From_" .. fromWhere) .. "\n" .. _("Tip_AatarExpired_" .. fromWhere)
				end

				self.TextDetail2.Text = ModifyRichTextForTextView(str)
			end
		end

		GOUtil.SetActive(self.BtnUnlock, isLock and canGotoGet)
	end

	initPanelIndex = initPanelIndex or 1

	if initPanelIndex == 1 then
		self.PanelDetail:SetActive(true)
	elseif initPanelIndex == 2 then
		self.PanelFrom:SetActive(true)
		self.ButtonFromGift:SetActive(true)
		self.ButtonFromDetail:SetActive(true)
	elseif initPanelIndex == 3 or initPanelIndex == 4 then
		self.PanelDetail:SetActive(true)

		if info:GetType() == eItemType.I_PACK then
			self.tag = 2

			self.PanelGift:SetActive(true)
			self.PanelDetail:SetActive(false)
		elseif info:GetType() == eItemType.I_GEM then
			if initPanelIndex == 3 then
				local gemList = ItemManager:GetItemListByType("I_GEM")

				for i, v in ipairs(gemList) do
					if ItemManager:Get(v.ID):IsTargetItem(info.id) then
						self.ButtonSyn:SetActive(true)

						break
					end
				end
			else
				local item1, item2 = info:GetRequireItem()

				if item1 ~= nil or item2 ~= nil then
					self.ButtonSyn:SetActive(true)
				end
			end
		elseif info:GetType() == eItemType.I_PACK_RANDOM_CARD then
			self.selCardId = 0

			self.ButtonUse:SetActive(true)
		elseif info:GetType() == eItemType.I_PACK_CARD then
			self.ScrollView:SetActive(true)
			self.ButtonUse:SetActive(true)
			GOUtil.DestroyAllChildren(self.SelCardContent)

			local RewardPack = require("luaData/RewardPack")

			self.listItem = {}

			local list = RewardPack[info.data.UseId].ItemList

			for i = 1, #list do
				local data = list[i]
				local item = CellItem(self.PrefabCellItem, self.SelCardContent, self)

				item:Create()

				local infoItem = ItemManager:GetValueItem(data[1], data[2])

				item:UpdateNoNumType(infoItem, false)
				item:SetSelCardCallback(self, self.OnSelCard)
				table.insert(self.listItem, item)

				if i == 1 then
					self.selCardId = data[2]

					item.ImgSel:SetActive(true)
				end
			end
		end
	end

	if needFromBtn then
		self.ButtonFromGift:SetActive(true)
		self.ButtonFromDetail:SetActive(true)
	end

	self.listFromWhere = info.data.FromWhere

	if info.data.FromWhere and #info.data.FromWhere == 0 then
		self.ButtonFromGift:SetActive(false)
		self.ButtonFromDetail:SetActive(false)
	else
		self:UpdateScrollView()
	end

	self.buyNum = 1
	self.adjustNum = self.buyNum
	self.InputField.text = self.buyNum
	self.infoItem = info

	if callback then
		self.callback = callback
	end
end

function DlgItemTip:Hide()
	if self.cellItem ~= nil then
		self.cellItem:OnLeave()

		self.cellItem = nil
	end

	if self.listItem and next(self.listItem) ~= nil then
		for _, v in ipairs(self.listItem) do
			v:OnLeave()
		end

		self.listItem = nil
	end

	UnloadAllImageSprite(self)

	self.callback = nil

	self:Close()
end

function DlgItemTip:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/PanelFrom/ScrollArea")

	self.ScrollArea = ScrollArea
	self.content = self:GetChildComponent("Panel/PanelFrom/ScrollArea/Content", "Transform")
	self.UIScrollToolPanel = UIScrollTool()
end

function DlgItemTip:UpdateScrollView()
	local function AddClick(item)
		self:AddCellClick(item)
	end

	local function CellUpdate(item, index)
		item:Create()

		item.UIRootObject.name = index

		self:UpdateCell(item, index)
	end

	self.UIScrollToolPanel:InitList(self.ScrollArea, self.content, #self.listFromWhere, self.PrefabCellAccess, CellAccess, self, false, AddClick, CellUpdate)
end

function DlgItemTip:SetScrollViewAnchoredPosition()
	local index = 1

	for i = 1, #self.listFromWhere do
		local data = self.listFromWhere[i]
		local isOpen = DlgItemTip.IsOpen(data)

		if not isOpen then
			index = i - 2

			break
		elseif isOpen and i == #self.listFromWhere then
			index = i - 2

			break
		end
	end

	local pos = Vector2(0, index * 92)

	self.UIScrollToolPanel:SetContentPosImmediate(pos or Vector2.zero, self.listFromWhere)
end

function DlgItemTip:UpdateCell(item, index)
	item.Index = index

	local data = self.listFromWhere[index]

	if not data then
		return
	end

	local fromType = data[1]
	local fromIndex, fromIndex2

	if data[2] then
		fromIndex = data[2]
	end

	if fromType ~= 11 and fromType ~= 16 or fromType == 16 and fromIndex ~= nil then
		-- block empty
	else
		fromIndex = 1
	end

	if fromType == 18 then
		if data[3] then
			fromIndex = 1
		else
			fromIndex = 0
		end
	elseif data[3] and data[3] > 0 and fromType ~= 10 then
		fromIndex2 = data[3]
	end

	local txtAccess = item.Text

	txtAccess.text = _("Item_From_" .. fromType)

	if fromIndex then
		txtAccess.text = _("Item_From_" .. fromType .. "_" .. fromIndex)
	end

	if fromIndex2 then
		txtAccess.text = _("Item_From_" .. fromType .. "_" .. fromIndex .. "_" .. fromIndex2)
	end

	if (fromType == 8 or fromType == 22) and fromIndex and fromIndex > 1 then
		local id = data[3]
		local infoStage = ChapterMgr:GetStage(id)

		if infoStage and infoStage.data then
			local _, cIdx, sIdx = ChapterMgr:GetChapterByStageID(id)

			txtAccess.text = cIdx .. "-" .. sIdx .. " " .. infoStage:GetName()
		end
	end

	local isOpen = DlgItemTip.IsOpen(data)

	item.GoGray:SetActive(not isOpen)

	if fromType == 10 and data[3] and RoleCardMgr:GetRoleCard(data[3]) and not RoleCardMgr:GetRoleCard(data[3]):IsGet() then
		item.GoGray:SetActive(true)
	end

	if not isOpen then
		UIUtil.SetImageSprite(item.BG, "UI/Common/DlgItemAccess/AtlasItemAccess/BG_shortcut_frame_02", self)
	else
		UIUtil.SetImageSprite(item.BG, "UI/Common/DlgItemAccess/AtlasItemAccess/BG_shortcut_frame_01", self)
	end
end

function DlgItemTip:AddCellClick(item)
	self:AddClick(item.Button, self.OnClickedCell)
	self:AddClick(item.GoGray, self.OnClickedCellGoGray)
end

function DlgItemTip:OnClickedCellGoGray(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)
	local fromWhere = self.listFromWhere[index]

	DlgItemTip.GoToFrom(fromWhere, false, self.callback, self.needItem)
end

function DlgItemTip:OnClickedCell(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)
	local fromWhere = self.listFromWhere[index]

	DlgItemTip.GoToFrom(fromWhere, false, self.callback, self.needItem)
	self:OnQuit()
end

function DlgItemTip.IsOpen(fromWhere)
	local result = true
	local fromType = fromWhere[1]

	if fromType == 1 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Shop)
	elseif fromType == 2 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.DrawCard)
	elseif fromType == 3 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Boss)
	elseif fromType == 4 or fromType == 5 or fromType == 6 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.AssetPass)

		if result then
			local fromIndex = fromWhere[2]
			local resIndex = 1

			if fromType == 4 then
				resIndex = 1
			elseif fromType == 5 then
				resIndex = 2
			elseif fromType == 6 then
				resIndex = 3
			end

			local listActive = PassMgr:GetBranchActiveList(3, resIndex)
			local activeId = listActive[fromIndex].ID
			local info = ActiveMgr:GetActive(listActive[fromIndex].ID)

			if not info:TodayIsOpen() then
				result = false
			end
		end
	elseif fromType == 7 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.TeamPass)
	elseif fromType == 8 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Fight)

		if result then
			local fromIndex = fromWhere[2]

			if fromIndex == 0 then
				-- block empty
			else
				local id = fromWhere[3]
				local infoStage = ChapterMgr:GetStage(id)

				if not infoStage then
					result = false
				end

				if not infoStage:IsOpen() then
					result = false
				end
			end
		end
	elseif fromType == 9 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.AssetPass)
	elseif fromType == 10 then
		local fromIndex = fromWhere[2]

		if fromIndex == 1 then
			result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Card)
		else
			result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardPass)
		end
	elseif fromType == 11 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Equipment)

		if result then
			require("UI/Page/PageEquipment/PageEquipDevelop")

			local roleId = fromWhere[2]
			local slotId = fromWhere[3]

			if slotId and slotId > 0 then
				if roleId <= 0 then
					local listRole = RoleMgr:GetAllHoldRole()

					roleId = listRole[1].id
				end

				require("UI/Page/PageEquipment/PageEquipDevelop")

				result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Enchant)

				if result and not PageEquip.IsSlotUnlocked(roleId, slotId) then
					result = false
				end
			end
		end
	elseif fromType == 12 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Work)
	elseif fromType == 13 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Friend)
	elseif fromType == 14 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Dress)
	elseif fromType == 15 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Talent)
	elseif fromType == 16 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Operation)
	elseif fromType == 17 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.TimeTask)
	elseif fromType == 18 then
		local roleId = fromWhere[2]
		local tag = fromWhere[3]
		local infoRole

		if roleId <= 0 then
			local listRole = RoleMgr:GetAllHoldRole()

			roleId = listRole[1].id
		else
			local infoRole = RoleMgr:GetRole(roleId)

			if not infoRole.hold then
				result = false
			end
		end
	elseif fromType == 19 then
		if not UnionMgr.HasUnion() then
			result = false
		end
	elseif fromType == 20 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PVP)
	elseif fromType == 21 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Tower)
	elseif fromType == 22 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Defficult)

		if result then
			local fromIndex = fromWhere[2]

			if fromIndex == 0 then
				-- block empty
			else
				local id = fromWhere[3]
				local infoStage = ChapterMgr:GetStage(id)

				if not infoStage then
					result = false
				end

				if not infoStage:IsOpen() then
					result = false
				end
			end
		end
	elseif fromType == 23 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Bondage)
	elseif fromType == 24 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.BossLive)
	elseif fromType == 25 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Communication)
	elseif fromType == 26 then
		result = true
	elseif fromType == 27 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Theme)
	elseif fromType == 30 then
		result = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Player)
	end

	return result
end

function DlgItemTip.IsInCurPanel(className)
	local curPanel = UIMgr.GetCurPanel()

	if curPanel and curPanel.className == className then
		return true
	end

	return false
end

function DlgItemTip.GoToFrom(fromWhere, inSynthetiz, callback, needItem)
	local fromType = fromWhere[1]

	if fromType == 1 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Shop)

		if not isOpen then
			return
		end

		local mainindex = fromWhere[2]
		local secondindex = fromWhere[3]

		require("UI/Page/PageShop/PageShop")
		PageShop.InitNetData({
			tabMainIndex = mainindex,
			tagIndex = secondindex
		})
	elseif fromType == 2 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.DrawCard)

		if not isOpen then
			return
		end

		if SystemMaintainMgr:Deal(SystemMaintainType.recruit, false, true) then
			return
		end

		require("UI/Page/PageCardShop/PageCardShop")

		if fromWhere[2] then
			local function switchCardShop()
				local list = CardPoolManager:GetAll()
				local info = CardPoolManager:Get(fromWhere[2])

				for i, v in ipairs(list) do
					if v.data.ID == info.data.ID or info.data.ActiveID ~= 0 and v.data.ActiveID == info.data.ActiveID then
						PageCardShop.selectIndex = i

						break
					end
				end

				if DlgItemTip.IsInCurPanel("PageCardShop") then
					Event.Instance:Fire("PageShopCloseEvent")
					UIMgr.GetCurPanel():OnJumpCell()
				else
					LoadingMgr.Show(eLoadingType.Repeat)
					NetManager:GetSyncResource(function()
						LoadingMgr.Hide(eLoadingType.Repeat)
						UIMgr.SwitchPanel(PageCardShop, nil, false)
					end)
				end
			end

			if not CardPoolManager.init then
				local function callback(vPBMessage)
					LoadingMgr.Hide(eLoadingType.Repeat)

					if vPBMessage.result.code == NetManager.Result_Sucess then
						CardPoolManager.init = true

						for i, v in ipairs(vPBMessage.poolInfo) do
							CardPoolManager:Get(v.poolId):SetData(v)
						end

						PageCardShop.selectChooseIndex = nil

						switchCardShop()
					elseif vPBMessage.result.code == NetManager.Result_Maintain then
						UIMgr.ShowMsg(_("Desc_FuncFobid"))
					else
						UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
					end
				end

				NetManager:RequestDrawCardPool(callback)
				LoadingMgr.Show(eLoadingType.Repeat)
			else
				PageCardShop.selectChooseIndex = nil

				switchCardShop()
			end
		end
	elseif fromType == 3 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Boss)

		if isOpen then
			local isShow, msg = ActiveMgr:IsBossActiveOpen()

			if not isShow then
				UIMgr.ShowMsg(msg)

				return
			end

			local fromIndex = fromWhere[2]

			if fromIndex == 1 then
				InfoBGMEventMgr:LoadBank("PageChapter")
				require("UI/Page/PageActivity/PageBossActivityBG")
				PageBossActivityBG.OpenActivity()
			elseif fromIndex == 2 then
				require("UI/Page/PageActivity/PageBossActivityBG")

				ChapterMgr.BossActivityStageType = StageFromType.activeCommon

				PageBossActivityBG.OpenActivity()
			elseif fromIndex == 3 then
				local infoActive = PageBossActivity.GetCurBossActive()

				local function wrap_cb(vPBMessage)
					LoadingMgr.Hide(eLoadingType.Repeat)

					if vPBMessage.result.code == NetManager.Result_Sucess then
						require("UI/Page/PageActivity/PageBossActivityShop")
						UIMgr.SwitchPanel(PageBossActivityShop, {
							pools = vPBMessage.pools
						})
					else
						UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
					end
				end

				NetManager:RequestGetActityPool(infoActive.id, wrap_cb)
				LoadingMgr.Show(eLoadingType.Repeat)
			elseif fromIndex == 4 then
				require("UI/Page/PageActivity/PageBossActivityBG")

				ChapterMgr.BossActivityStageType = StageFromType.story

				PageBossActivityBG.OpenActivity()
			end
		end
	elseif fromType == 4 or fromType == 5 or fromType == 6 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.AssetPass)

		if not isOpen then
			return
		end

		local fromIndex = fromWhere[2]

		if fromType == 4 then
			ChapterMgr.resIndex = 1
		elseif fromType == 5 then
			ChapterMgr.resIndex = 2
		elseif fromType == 6 then
			ChapterMgr.resIndex = 3
		end

		local listActive = PassMgr:GetBranchActiveList(3, ChapterMgr.resIndex)
		local activeId = listActive[fromIndex].ID
		local info = ActiveMgr:GetActive(listActive[fromIndex].ID)

		if info:TodayIsOpen() then
			ChapterMgr.resTabIndex = fromIndex

			InfoBGMEventMgr:LoadBank("PageChapter")
			require("UI/Page/PagePass/PageAssetPass")
			PageAssetPass.EnterStageList(ChapterMgr.resIndex, true, needItem)
		else
			UIMgr.ShowMsg(_("Desc_Not_Open"))
		end
	elseif fromType == 7 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.TeamPass)

		if not isOpen then
			return
		end

		InfoBGMEventMgr:LoadBank("PageChapter")
		require("UI/Page/PagePass/PageTeamPass")

		local fromIndex = fromWhere[2]

		if fromIndex == 0 then
			UIMgr.SwitchPanel(PageTeamPass)
		else
			PageTeamPass.EnterStage(fromIndex)
		end
	elseif fromType == 8 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Fight)

		if not isOpen then
			return
		end

		ChapterMgr:SetBatteleTypeEnumID(0)

		local fromIndex = fromWhere[2]

		if fromIndex == 0 or fromIndex == nil then
			require("UI/Page/PageChapter/PageChapter")
			UIMgr.SwitchPanel(PageChapter, 1)
		else
			local chapterId = fromWhere[2]
			local stageId = fromWhere[3]

			if inSynthetiz then
				local infoStage = ChapterMgr:GetStage(stageId)

				if not infoStage then
					UIMgr.ShowMsg(_("Desc_NoChapter"))

					return
				end

				if not infoStage:IsOpen() then
					UIMgr.ShowMsg(_("PageTalentTree_Locked"))

					return
				end

				ChapterMgr.PageCombatReadinessType = 1

				if infoStage.data.Type == StageFromType.story then
					-- block empty
				else
					UIMgr.AddPanel(PageCombatReadiness(), {
						stageId = infoStage.id,
						isSyntherize = inSynthetiz,
						needItem = needItem
					})
				end
			else
				local infoStage = ChapterMgr:GetStage(stageId)

				if not infoStage then
					UIMgr.ShowMsg(_("Desc_NoChapter"))

					return
				end

				if not infoStage:IsOpen() then
					UIMgr.ShowMsg(_("PageTalentTree_Locked"))

					return
				end

				local infoChapter = ChapterMgr:GetChapter(chapterId)
				local isOpen = infoChapter:IsOpen()

				if not isOpen then
					return
				end

				local data = {}

				data.chapterType = 1
				data.chapterId = chapterId

				UIMgr.SwitchPanel(PageStage, data)

				if stageId then
					local infoStage = ChapterMgr:GetStage(stageId)

					if infoStage.data.Type == StageFromType.story then
						-- block empty
					else
						UIMgr.AddPanel(PageCombatReadiness(), {
							stageId = infoStage.id,
							isSyntherize = inSynthetiz,
							needItem = needItem
						})
					end
				end
			end
		end
	elseif fromType == 9 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.AssetPass)

		if not isOpen then
			return
		end
	elseif fromType == 10 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Card)

		if not isOpen then
			return
		end

		require("UI/Page/PageRoleCard/Page/PageRoleCardList")

		local fromIndex = fromWhere[2]
		local id = fromWhere[3]

		if fromIndex == 1 then
			if id and id > 0 then
				local tag = fromWhere[4]

				if tag and tag > 0 then
					UIMgr.SwitchPanel(PageRoleCard, {
						cardId = id,
						tag = tag
					})
				else
					UIMgr.SwitchPanel(PageRoleCard, {
						cardId = id
					})
				end
			else
				UIMgr.SwitchPanel(PageRoleCardList, {
					entType = eEnterType.cardMain
				})
			end
		elseif fromIndex == 2 then
			local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.CardPass)

			if not isOpen then
				return
			end

			if id and id > 0 then
				local card = RoleCardMgr:GetRoleCard(id)

				if not card or not card:IsHold() then
					UIMgr.ShowMsg(_("Msg_Target_Card_Not_Hold"))

					return
				end

				ChapterMgr.cardIndex = id
				CardExtraMgr.LastCardStageCardId = id
			end

			require("UI/Page/PagePass/PageCardStage")
			UIMgr.SwitchPanel(PageCardStage)
		elseif fromIndex == 3 then
			PageRoleCardList.DirectlyShowTeam()
		end
	elseif fromType == 11 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Equipment)

		if not isOpen then
			return
		end

		require("UI/Page/PageEquipment/PageEquip")

		local roleId = fromWhere[2]
		local slotId = fromWhere[3]

		if slotId and slotId > 0 then
			if roleId <= 0 then
				local listRole = RoleMgr:GetAllHoldRole()

				roleId = listRole[1].id
			end

			require("UI/Page/PageEquipment/PageEquipDevelop")

			local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Enchant)

			if not isOpen then
				return
			end

			if PageEquip.IsSlotUnlocked(roleId, slotId) then
				local tagIndex = fromWhere[4]

				if tagIndex and tagIndex > 0 then
					if PageEquipDevelop.IsUnlock(tagIndex, true) then
						UIMgr.SwitchPanel(PageEquipDevelop, {
							roleId = roleId,
							slotIdx = slotId,
							tag = tagIndex,
							needItem = needItem
						})
					end
				else
					UIMgr.SwitchPanel(PageEquipDevelop, {
						roleId = roleId,
						slotIdx = slotId
					})
				end
			end
		elseif roleId > 0 then
			UIMgr.SwitchPanel(PageEquip, {
				roleId = roleId
			})
		else
			UIMgr.SwitchPanel(PageEquip)
		end
	elseif fromType == 12 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Work)

		if not isOpen then
			return
		end

		if SystemMaintainMgr:Deal(SystemMaintainType.work, false, true) then
			return
		end

		require("UI/Page/PageWork/PageWork")
		UIMgr.SwitchPanel(PageWork)
	elseif fromType == 13 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Friend)

		if not isOpen then
			return
		end

		local fromIndex = fromWhere[2]

		Event.Instance:Fire("DealWithUIAnim", true)
		require("UI/Page/PageFriend/PageFriendMain")
		PageFriendMain.RequestData()
	elseif fromType == 14 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Dress)

		if not isOpen then
			return
		end

		require("UI/Page/PageFittingroom/PageFittingroom")

		local roleId = fromWhere[2]
		local tag = fromWhere[3]

		if tag and tag > 0 then
			AvatarManager.curTabIndex = tag
		end

		local infoRole

		if roleId <= 0 then
			local listRole = RoleMgr:GetAllHoldRole()

			roleId = listRole[1].id
		end

		infoRole = RoleMgr:GetRole(roleId)

		UIMgr.SwitchPanel(PageFittingroom, {
			from = 4,
			infoRole = infoRole
		})
	elseif fromType == 15 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Talent)

		if not isOpen then
			return
		end

		local roleId = fromWhere[2]

		require("UI/Page/PageRole/PageTalentTree")

		if roleId <= 0 then
			local listRole = RoleMgr:GetAllHoldRole()

			roleId = listRole[1].id
		end

		UIMgr.SwitchPanel(PageTalentTree, {
			roleId = roleId
		})
	elseif fromType == 16 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Operation)

		if not isOpen then
			return
		end

		if SystemMaintainMgr:Deal(SystemMaintainType.operation, false, true) then
			return
		end

		local tag = fromWhere[2]

		if tag == 8 and NoPay then
			return
		end

		require("UI/Page/PageOperation/PageOperationActiveNew")

		OperationActiveMgr.PageOperationActiveType = 1

		UIMgr.SwitchPanel(PageOperationActiveNew, {
			tag = tag
		})
	elseif fromType == 17 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.TimeTask)

		if not isOpen then
			return
		end

		if SystemMaintainMgr:Deal(SystemMaintainType.task, false, true) then
			return
		end

		require("UI/Page/PageOperation/DlgTimeLimitTask")
		UIMgr.SwitchPanel(DlgTimeLimitTask())
	elseif fromType == 18 then
		local roleId = fromWhere[2]
		local tag = fromWhere[3]
		local infoRole

		if roleId <= 0 then
			local listRole = RoleMgr:GetAllHoldRole()

			roleId = listRole[1].id
		else
			local infoRole = RoleMgr:GetRole(roleId)

			if not infoRole.hold then
				UIMgr.ShowMsg(_("Desc_no_role"))

				return
			end
		end

		SceneMainStage.Instance:OnEnterInteractionByRoleId(roleId, {
			from = 4,
			tag = tag
		})
	elseif fromType == 19 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Union)

		if not isOpen then
			return
		end

		local tag = fromWhere[2]

		if not UnionMgr.HasUnion() then
			if tag ~= nil then
				UIMgr.ShowMsg(_("Msg_Union_Not_Join"))
			else
				require("UI/Page/PageUnion/PageUnionJoin")

				local function cb()
					UIMgr.SwitchPanel(PageUnionJoin)
				end

				PageUnionJoin.RequestData(cb)
			end

			return
		end

		if tag == 1 then
			require("UI/Page/PageUnionFunction/PageUnionTask")

			local function cb()
				UIMgr.SwitchPanel(PageUnionTask)
			end

			PageUnionTask.RequestData(cb, true)
		elseif tag == 2 then
			require("UI/Page/PageUnionFunction/PageUnionSkill")

			local function cb()
				UIMgr.SwitchPanel(PageUnionSkill)
			end

			PageUnionSkill.RequestData(cb, true)
		elseif tag == 3 then
			require("UI/Page/PageUnionFunction/PageUnionWish")

			local function cb()
				InfoBGMEventMgr:LoadBank("PageUnion")
				UIMgr.SwitchPanel(PageUnionWish)
			end

			PageUnionWish.RequestData(cb, true)
		elseif tag == 4 then
			require("UI/Page/PageUnionRaid/PageUnionRaid")

			local function cb()
				UIMgr.SwitchPanel(PageUnionRaid)
			end

			PageUnionRaid.RequestData(cb, true)
		elseif tag == 5 then
			Infogvg:Refresh(true)
		end
	elseif fromType == 20 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.PVP)

		if not isOpen then
			return
		end

		if SystemMaintainMgr:Deal(SystemMaintainType.pvp, false, true) then
			return
		end

		local InfoPVP = require("Info/InfoPVP")
		local curtime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local endtiem = GetConfigArgInt("PVPSettleSeconds")
		local call

		if callback then
			call = callback
			callback = nil
		end

		local function pc(pb)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if pb.result.code == NetManager.Result_Maintain then
				UIMgr.ShowMsg(_("Desc_FuncFobid"))

				return
			end

			InfoPVP:SetData(pb)

			local time = InfoPVP:GetSeasondata().subSeasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			if InfoPVP.pb.season.seasonStatus ~= 1 then
				UIMgr.ShowMsg(_("PvPSeason"))
			elseif time < 0 then
				UIMgr.ShowMsg(_("PvPSeason"))
			elseif time <= endtiem or tonumber(curtime) < tonumber(InfoPVP:GetSeasondata().subSeasonBeginTime) then
				UIMgr.ShowMsg(_("PvPSeason"))
			else
				if call then
					call()
				end

				require("UI/Page/pagePVP/PagePVPMain")
				UIMgr.SwitchPanel(PagePVPMain, InfoPVP.pb)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSeasonData(0, 0, 1, pc)
	elseif fromType == 99 then
		UIMgr.PopPanel()

		timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.1, function()
			require("UI/Page/PageLogin/Account/PagePlatformSelect")
			UIMgr.AddPanel(PagePlatformSelect(), {
				useForLogin = false
			}, nil, true)
		end, {})
	elseif fromType == 21 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Tower)

		if not isOpen then
			return
		end

		InfoBGMEventMgr:LoadBank("PageChapter")
		require("UI/Page/PageTower/PageTower")
		UIMgr.SwitchPanel(PageTower)
	elseif fromType == 22 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Defficult)

		if not isOpen then
			return
		end

		if tonumber(ChapterMgr:GetCurChapter(ChapterType.main).id) <= GetConfigArgInt("HeroDungeonLock") then
			local isOpen, msg = ActiveMgr:IsBossStageUnlock(20101)

			UIMgr.ShowMsg(msg)

			return
		end

		local fromIndex = fromWhere[2]

		ChapterMgr:SetBatteleTypeEnumID(1)

		if fromIndex == 0 or fromIndex == nil then
			require("UI/Page/PageChapter/PageChapter")
			UIMgr.SwitchPanel(PageChapter, 1)
		else
			local chapterId = fromWhere[2]
			local stageId = fromWhere[3]

			if inSynthetiz then
				local infoStage = ChapterMgr:GetStage(stageId)

				if not infoStage then
					UIMgr.ShowMsg(_("Desc_NoChapter"))

					return
				end

				if not infoStage:IsOpen() then
					UIMgr.ShowMsg(_("PageTalentTree_Locked"))

					return
				end

				ChapterMgr.PageCombatReadinessType = 1

				if infoStage.data.Type == StageFromType.story then
					-- block empty
				else
					UIMgr.AddPanel(PageCombatReadiness(), {
						stageId = infoStage.id,
						isSyntherize = inSynthetiz,
						needItem = needItem
					})
				end
			else
				local infoChapter = ChapterMgr:GetChapter(chapterId)

				if not infoChapter then
					error("ChapterId is nil or not exist")

					return
				end

				local isOpen = infoChapter:IsOpen()

				if not isOpen then
					return
				end

				local data = {}

				data.chapterType = 1
				data.chapterId = chapterId

				UIMgr.SwitchPanel(PageStage, data)

				if stageId then
					local infoStage = ChapterMgr:GetStage(stageId)

					if infoStage.data.Type == StageFromType.story then
						-- block empty
					else
						UIMgr.AddPanel(PageCombatReadiness(), {
							stageId = infoStage.id,
							isSyntherize = inSynthetiz,
							needItem = needItem
						})
					end
				end
			end
		end
	elseif fromType == 23 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Bondage)

		if not isOpen then
			return
		end

		require("UI/Page/PageBondage/PageBondage")
		UIMgr.SwitchPanel(PageBondage)
	elseif fromType == 24 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.BossLive)

		if not isOpen then
			return
		end

		require("UI/Page/PageBosslive/PageBosslive")
		UIMgr.SwitchPanel(PageBosslive)
	elseif fromType == 25 then
		require("UI/Page/PageCommunication/PageAddressBook")
		UIMgr.SwitchPanel(PageAddressBook, nil)
	elseif fromType == 26 then
		if WebCamTexture.devices.Length == 0 and Application.isEditor == false then
			UIMgr.ShowArPremission(DlgCommonEvent.Type.Loading, _("ARMode_Checking"))

			return
		end

		PageInteraction.jumpARIndex = 1

		local listRole = RoleMgr:GetAllHoldRole()
		local infoRole = RoleMgr:GetRole(listRole[1].id)

		SceneMgr.LoadScene("AR", {
			index = 1,
			infoRole = infoRole
		})
	elseif fromType == 27 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Theme)

		if not isOpen then
			return
		end

		require("UI/Page/PageTheme/PageTheme")

		ThemeManager.TypeID = 1

		UIMgr.SwitchPanel(PageTheme, {})
	elseif fromType == 28 then
		if UIMgr.GetCurPanel().className == "PageActivityBossRaid" then
			Event.Instance:Fire("PageShopCloseEvent")
			Event.Instance:Fire("CloseBossRaidTask")
		elseif TutorialMgr:IsOpenTut(TutorialFunctionType.BossRaid) then
			if ActivityBossRaidMgr.bossRaidTimeData == nil then
				local activityList = ActiveMgr:GetActiveByType(eActiveType.bossraid)

				for i, v in ipairs(activityList) do
					if v:IsShowOpen() then
						ActivityBossRaidMgr.bossRaidTimeData = v

						break
					end
				end
			end

			if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
				require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")
				UIMgr.SwitchPanel(PageActivityBossRaid())
			else
				UIMgr.ShowMsg(_("Msg_Active_Over"))
			end
		end
	elseif fromType == 29 then
		local chargeExist, info = OperationActiveMgr:CheckFirstRechargeExist()

		if chargeExist then
			local openTipType = OperationActiveMgr.firstChargeType
			local getIndex = #info.pb.awardRecords
			local needMoney = info.data.DailyTime[1][getIndex + 1]

			if not NoPay then
				require("UI/Page/PageOperation/DlgFirstRecharge")
				UIMgr.AddPanel(DlgFirstRecharge())
			end
		end
	elseif fromType == 30 then
		require("UI/Page/PagePlayerInfo/PagePlayer")

		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Player)

		if not isOpen then
			return
		end

		UIMgr.SwitchPanel(PagePlayer)
	elseif fromType == 31 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.CardPass)

		if not isOpen then
			return
		end

		InfoBGMEventMgr:LoadBank("PageChapter")
		require("UI/Page/PagePass/PageCardStage")
		UIMgr.SwitchPanel(PageCardStage)
	elseif fromType == 32 then
		if not fromWhere[2] then
			return
		end

		if SystemMaintainMgr:Deal(SystemMaintainType.task, false, true) then
			return
		end

		if fromWhere[2] == 1 then
			require("UI/Page/PageTask/PageTask")

			TaskManager.tabIndex = 1

			UIMgr.SwitchPanel(PageTask, {
				entType = 1
			})
		elseif fromWhere[2] == 2 then
			require("UI/Page/PageTask/PageTask")

			TaskManager.tabIndex = 2

			UIMgr.SwitchPanel(PageTask, {
				entType = 2
			})
		elseif fromWhere[2] == 3 then
			require("UI/Page/PageTask/PageTask")

			TaskManager.tabIndex = 3

			UIMgr.SwitchPanel(PageTask, {
				entType = 3
			})
		elseif fromWhere[2] == 4 then
			require("UI/Page/PageTask/PageTask")

			TaskManager.tabIndex = 4

			UIMgr.SwitchPanel(PageTask, {
				entType = 4
			})
		end
	elseif fromType == 40 then
		local subType = fromWhere[2]

		if subType == 1 then
			require("UI/Page/PageManual/PageManualMain")
			UIMgr.SwitchPanel(PageManualMain())
		elseif subType == 2 then
			require("UI/Page/PageManual/PagePictureTeam")
			UIMgr.SwitchPanel(PagePictureTeam())
		elseif subType == 3 then
			require("UI/Page/PageManual/PageImpression")
			UIMgr.SwitchPanel(PageImpression())
		elseif subType == 4 then
			require("UI/Page/PageManual/PageStoryVideo")
			UIMgr.SwitchPanel(PageStoryVideo())
		end
	elseif fromType == 45 then
		require("UI/Page/PageTimeSpace/PageTimeSpace")
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:GetTimeSpaceData(function(msg)
			TimeSpaceChapterMgr:Refresh()
			NetManager:RequestTaskList(function()
				LoadingMgr.Hide(eLoadingType.Repeat)
				require("UI/Page/PageTimeSpace/PageTimeSpace")
				UIMgr.SwitchPanel(PageTimeSpace())
			end)
		end)
	end

	if callback then
		callback()
	end
end

function DlgItemTip:OnUpdateSecond()
	if self.isLimit and not self.isOveTime then
		local curServerTime = NetData:GetCurServerTime()
		local endTime = self.infoItem.clearTime * DateUtil.MillsPerSecond

		if self.infoItem.data.ID == TIMESPACE_MEDAL then
			endTime = TimeSpaceChapterMgr.EndTime * DateUtil.MillsPerSecond
		end

		if curServerTime < endTime then
			self.TextTime.text = DateUtil.GetTwoMomentByMillis(endTime - curServerTime) .. _("Desc_RecoveryTime")
		else
			self.TextTime.text = _("Desc_StaleDated")
			self.isOveTime = true
		end
	end
end
