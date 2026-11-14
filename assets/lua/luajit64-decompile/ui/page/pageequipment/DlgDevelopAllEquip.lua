-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgDevelopAllEquip.lua

DlgDevelopAllEquip = class("DlgDevelopAllEquip", UIPanel)

function DlgDevelopAllEquip:ctor()
	DlgDevelopAllEquip.base.ctor(self, "UI/PanelEquipment/DlgDevelopAllEquip")
end

function DlgDevelopAllEquip:Purge()
	self.base.Purge(self)
	RoleCardMgr:GetRoleCard(self.infoRole.pb.roleCardId):UpdateSimData()

	for m, v1 in ipairs(self.cellChoose) do
		for n, v2 in ipairs(v1.listItem) do
			v2:Purge()
		end
	end
end

function DlgDevelopAllEquip:PreLoad()
	return
end

function DlgDevelopAllEquip:OnRegisterEvent()
	self:AddClick(self.DevelopButton.gameObject, self.OnClickDevelopButton)
	self:AddClick(self.BtnClose, self.Close)
	self:AddClick(self.cellChoose[1].ButtonAll, self.OnClickEquipDevelopAllItem)
	self:AddClick(self.cellChoose[2].ButtonAll, self.OnClickEquipBreakAllItem)
end

function DlgDevelopAllEquip:OnUnRegisterEvent()
	self:RemoveClick(self.DevelopButton.gameObject, self.OnClickDevelopButton)
	self:RemoveClick(self.BtnClose, self.Close)
	self:RemoveClick(self.cellChoose[1].ButtonAll, self.OnClickEquipDevelopAllItem)
	self:RemoveClick(self.cellChoose[2].ButtonAll, self.OnClickEquipBreakAllItem)
end

function DlgDevelopAllEquip:OnEnter(vParam)
	self:DealWithLocalization()

	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.DevelopButton = self:GetChildComponent("Panel/Button", "Image")
	self.Text = self:GetChildComponent("Panel/Button/Text", "Text")
	self.cellChoose = {}

	for i = 1, 2 do
		local cell = {}
		local g = self:GetChildGameObject("Panel/Group/ScrollArea/Content/CellDevelopAllINeed" .. i)

		cell.obj = g
		cell.tital = GOUtil.FindChildComponent(g, "Tital", "Text")
		cell.ChooseTip = GOUtil.FindChildGameObject(g, "ChooseTip")
		cell.ChooseInfo = GOUtil.FindChildGameObject(g, "ChooseInfo")
		cell.Arrow = GOUtil.FindChildGameObject(g, "ChooseInfo/Arrow")
		cell.TipDevelopText = GOUtil.FindChildComponent(g, "ChooseInfo/TipDevelopText", "Text")
		cell.CardLevelMin = GOUtil.FindChildComponent(g, "ChooseInfo/CardLevelMin", "Text")
		cell.CardLevelMax = GOUtil.FindChildComponent(g, "ChooseInfo/CardLevelMax", "Text")
		cell.listItem = {}

		for i = 1, 7 do
			cell["Item" .. i] = GOUtil.FindChildGameObject(g, "ChooseInfo/NeedItemList/" .. i)

			local gItem = cell["Item" .. i]
			local item = CellItem(gItem)

			item:InitItemByRoot(gItem)
			table.insert(cell.listItem, item)
		end

		cell.head = GOUtil.FindChildComponent(g, "ChooseInfo/NeedItemList/MyCellCard/CardIcon", "Image")
		cell.headFrame = GOUtil.FindChildComponent(g, "ChooseInfo/NeedItemList/MyCellCard/HeadFrame", "Image")
		cell.job = GOUtil.FindChildComponent(g, "ChooseInfo/NeedItemList/MyCellCard/Job", "Image")
		cell.MyCellCard = GOUtil.FindChildGameObject(g, "ChooseInfo/NeedItemList/MyCellCard")
		cell.ButtonAll = GOUtil.FindChildGameObject(g, "ChooseInfo/NeedItemList/ButtonAll")
		cell.ButtonAllText = GOUtil.FindChildComponent(g, "ChooseInfo/NeedItemList/ButtonAll/Text", "Text")

		table.insert(self.cellChoose, cell)
	end

	self:InitData(vParam)
end

function DlgDevelopAllEquip:DealWithLocalization()
	local text

	text = self:GetChildComponent("Panel/Group/ScrollArea/Content/CellDevelopAllINeed1/Tital", "Text")
	text.text = _("Equip_Lv")
	text = self:GetChildComponent("Panel/Group/ScrollArea/Content/CellDevelopAllINeed2/Tital", "Text")
	text.text = _("Intensify_Break")
	text = self:GetChildComponent("Panel/Group/ScrollArea/Content/CellDevelopAllINeed3/Tital", "Text")
	text.text = _("Card_Lv")
	text = self:GetChildComponent("Panel/Group/ScrollArea/Content/CellDevelopAllINeed1/ChooseTip", "Text")
	text.text = _("Lv_Select")
	text = self:GetChildComponent("Panel/Group/ScrollArea/Content/CellDevelopAllINeed2/ChooseTip", "Text")
	text.text = _("Lv_Select")
	text = self:GetChildComponent("Panel/Group/ScrollArea/Content/CellDevelopAllINeed3/ChooseTip", "Text")
	text.text = _("Lv_Select")
	text = self:GetChildComponent("Panel/Group/ScrollArea/Content/CellDevelopAllINeed1/ChooseInfo/TipDevelopText", "Text")
	text.text = _("Auto_Compose_Makings")
	text = self:GetChildComponent("Panel/Group/ScrollArea/Content/CellDevelopAllINeed2/ChooseInfo/TipDevelopText", "Text")
	text.text = _("Auto_Compose_Makings")
end

function DlgDevelopAllEquip:InitData(data)
	self.chooseList = {}
	self.data = data
	self.infoRole = RoleMgr:GetRole(self.data.roleId)

	RoleCardMgr:GetRoleCard(self.infoRole.pb.roleCardId):UpdateSimData()
	self:UpdataClick()
end

function DlgDevelopAllEquip:UpdatePanel()
	self:UpdataButton()

	self.equipDevelopList = nil
	self.equipBreakList = nil
	self.cardDevelopList = nil
	self.alreadyCost = {}

	for i, v in ipairs(self.chooseList) do
		local curNeed = {}
		local showItem = 7

		if v == 1 then
			curNeed = EquipmentManager:GetAllEquipDevelopNeedItem(self.infoRole, self.alreadyCost)

			if curNeed == nil then
				curNeed = {}
			end

			self.equipDevelopList = curNeed

			if table.getItemCount(curNeed) > 7 then
				showItem = 6

				self.cellChoose[v].ButtonAll:SetActive(true)

				self.cellChoose[v].ButtonAllText.text = string.format(_("Lntensify_Leftover"), table.getItemCount(curNeed) - showItem)
			else
				showItem = table.getItemCount(curNeed)

				self.cellChoose[v].ButtonAll:SetActive(false)
			end

			if table.getItemCount(curNeed) == 0 then
				self.cellChoose[v].obj:SetActive(false)
			else
				self.cellChoose[v].obj:SetActive(true)
			end
		elseif v == 2 then
			curNeed = EquipmentManager:GetAllEquipBreakNeedItem(self.infoRole, self.alreadyCost)

			if curNeed == nil then
				curNeed = {}
			end

			self.equipBreakList = curNeed

			if table.getItemCount(curNeed) > 7 then
				showItem = 6

				self.cellChoose[v].ButtonAll:SetActive(true)

				self.cellChoose[v].ButtonAllText.text = string.format(_("Lntensify_Leftover"), table.getItemCount(curNeed) - showItem)
			else
				showItem = table.getItemCount(curNeed)

				self.cellChoose[v].ButtonAll:SetActive(false)
			end

			if table.getItemCount(curNeed) == 0 then
				self.cellChoose[v].obj:SetActive(false)
			else
				self.cellChoose[v].obj:SetActive(true)
			end
		end

		if table.getItemCount(curNeed) > 0 then
			for k, needValue in pairs(curNeed) do
				if self.alreadyCost[k] == nil then
					self.alreadyCost[k] = needValue
				else
					self.alreadyCost[k] = needValue + self.alreadyCost[k]
				end
			end

			local needItemInfos = {}

			for itemId, itemNum in pairs(curNeed) do
				local info = ItemManager:GetValueItem(itemId, itemNum)

				table.insert(needItemInfos, info)
			end

			for j = 1, 7 do
				if showItem < j then
					self.cellChoose[v].listItem[j].UIRootObject:SetActive(false)
				else
					self.cellChoose[v].listItem[j]:UpdateWithNumType(needItemInfos[j])
					self.cellChoose[v].listItem[j].UIRootObject:SetActive(true)
				end
			end

			self.cellChoose[v].ChooseInfo:SetActive(true)
			self.cellChoose[v].ChooseTip.gameObject:SetActive(false)
		end
	end

	if self.equipDevelopList and table.getItemCount(self.equipDevelopList) == 0 then
		table.removeByValue(self.chooseList, 1)
	end

	if self.equipBreakList and table.getItemCount(self.equipBreakList) == 0 then
		table.removeByValue(self.chooseList, 2)
	end

	RoleCardMgr:GetRoleCard(self.infoRole.pb.roleCardId):UpdateSimData()
end

function DlgDevelopAllEquip:UpdataClick(index)
	self.chooseList = {
		2,
		1
	}

	self:UpdatePanel()
end

function DlgDevelopAllEquip:UpdataButton(...)
	if #self.chooseList == 0 then
		self.Text.text = _("NO_Select")

		UIUtil.SetImageGray(self.DevelopButton, 1)

		self.DevelopButton.raycastTarget = false
	else
		self.Text.text = _("All_Intensify")

		UIUtil.SetImageGray(self.DevelopButton, 0)

		self.DevelopButton.raycastTarget = true
	end
end

function DlgDevelopAllEquip:OnClickDevelopButton()
	local unlockCond = self.infoRole.data.AvatarUnlock
	local infoSlot = self.infoRole:GetEquipSlot(1)
	local isAvatarUnlocked = false

	if #unlockCond > 0 and infoSlot.level >= unlockCond[1] and EquipmentManager:GetQualityIndex(infoSlot.quality, infoSlot.grade) >= unlockCond[2] + 1 then
		isAvatarUnlocked = true
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:Close()

			local levelBefore = {}
			local breaklist = {}
			local developlist = {}

			for i, v in ipairs(vMsg.slot) do
				if v.level ~= self.infoRole.pb.slots[v.slot].level then
					levelBefore[v.slot] = self.infoRole.pb.slots[v.slot].level

					table.insert(developlist, v)
				else
					table.insert(breaklist, v)
				end
			end

			for i = 1, #vMsg.slot do
				self.infoRole:UpdateEquipData(vMsg.slot[i])
			end

			local function OpenDevelop(callback)
				require("UI/Page/PageEquipment/DlgEquipDevelopResult")
				UIMgr.AddPanel(DlgEquipDevelopResult(), {
					infoRole = self.infoRole,
					slot = developlist,
					levelBefore = levelBefore,
					callback = callback
				})
			end

			local function OpenBreak(callback)
				require("UI/Page/PageRoleCard/Dlg/DlgCardUpResult")
				UIMgr.AddPanel(DlgCardUpResult(), {
					type = 4,
					infoRole = self.infoRole,
					slots = breaklist,
					callback = callback
				})
			end

			local function OpenCardDevelop(callback)
				if RoleCardMgr:GetRoleCard(self.infoRole.pb.roleCardId).curLevel > RoleCardMgr:GetRoleCard(self.infoRole.pb.roleCardId).preLevel then
					local data = {
						index = 1,
						infoRoleCard = RoleCardMgr:GetRoleCard(self.infoRole.pb.roleCardId),
						callback = callback
					}

					UIMgr.AddPanel(DlgUpResult(), data)
				end
			end

			local function OpenUnlockAvatar()
				if not isAvatarUnlocked and #unlockCond > 0 and infoSlot.level >= unlockCond[1] and EquipmentManager:GetQualityIndex(infoSlot.quality, infoSlot.grade) >= unlockCond[2] + 1 then
					local list = SetterData.ConvertSettersToPbItems(vMsg.setter)

					UIMgr.AddPanel(DlgGetAward.GetInstance(), {
						list = list
					})
				end
			end

			if table.contains(self.chooseList, 1) then
				OpenDevelop(function(...)
					if table.contains(self.chooseList, 2) then
						OpenBreak(function(...)
							if table.contains(self.chooseList, 3) then
								OpenCardDevelop(OpenUnlockAvatar)
							else
								OpenUnlockAvatar()
							end
						end)
					elseif table.contains(self.chooseList, 3) then
						OpenCardDevelop(OpenUnlockAvatar)
					else
						OpenUnlockAvatar()
					end
				end)
			elseif table.contains(self.chooseList, 2) then
				OpenBreak(function(...)
					if table.contains(self.chooseList, 3) then
						OpenCardDevelop(OpenUnlockAvatar)
					else
						OpenUnlockAvatar()
					end
				end)
			elseif table.contains(self.chooseList, 3) then
				OpenCardDevelop(OpenUnlockAvatar)
			end
		elseif vMsg.result.code == NetManager.Result_Timeout then
			local strContent = _("Desc_NoNetwork")

			UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
				Restart()
			end, _("UI_OK"), nil, false)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestDevelopAll(self.data.roleId, self.chooseList, wrap_cb)
end

function DlgDevelopAllEquip:OnClickEquipDevelopAllItem()
	require("UI/Page/PageEquipment/DlgCostAllItem")
	UIMgr.AddPanel(DlgCostAllItem(), {
		costlist = self.equipDevelopList
	})
end

function DlgDevelopAllEquip:OnClickEquipBreakAllItem()
	require("UI/Page/PageEquipment/DlgCostAllItem")
	UIMgr.AddPanel(DlgCostAllItem(), {
		costlist = self.equipBreakList
	})
end

function DlgDevelopAllEquip:OnClickCardDevelopAllItem()
	require("UI/Page/PageEquipment/DlgCostAllItem")
	UIMgr.AddPanel(DlgCostAllItem(), {
		costlist = self.cardDevelopList
	})
end
