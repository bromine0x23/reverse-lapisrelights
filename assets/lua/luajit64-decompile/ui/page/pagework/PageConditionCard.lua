-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageWork/PageConditionCard.lua

require("UI/Page/PageWork/CellConditionCard")
require("UI/Page/PageWork/CellCondition")

PageConditionCard = class("PageConditionCard", UIPanel)

function PageConditionCard:ctor()
	self.UIPrefabPath = "UI/PanelWork/PanelConditionCard"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_Card_Send"),
		callback = self.OnBack,
		panel = self
	})
end

function PageConditionCard:PreLoad()
	self:LoadResAsync("UI/PanelWork/CellCondition", "PrefabCellCondition", GameObject)
	self:LoadResAsync("UI/PanelWork/CellConditionCard", "PrefabCellConditionCard", GameObject)
end

function PageConditionCard:OnBack(loadBankRole)
	local data

	if loadBankRole then
		data = {
			loadBankRole = loadBankRole
		}
	end

	UIMgr.PopPanel(data)
end

function PageConditionCard:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellConditionCard)
	ResourceMgr.Unload(self.PrefabCellCondition)
	self:ClearOther()

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self.RTEffCamera.targetTexture = nil

	UnityEngine.RenderTexture.ReleaseTemporary(self.RTEffTexture)

	self.RTEffTexture = nil
end

function PageConditionCard:ClearOther()
	if self.listGoCon then
		for _, item in ipairs(self.listGoCon) do
			if item.OnLeave then
				item:OnLeave()
			end

			self:RemoveClick(item.UIRootObject, self.OnClickedCondition)
		end
	end

	GOUtil.DestroyAllChildren(self.GoGroup)
end

function PageConditionCard:OnRegisterEvent()
	self:AddClick(self.GoAll, self.OnClickedCondition)
end

function PageConditionCard:OnUnRegisterEvent()
	self:RemoveClick(self.GoAll, self.OnClickedCondition)
end

function PageConditionCard:OnEnter(vParam)
	self.RTEffCamera = self:GetChildComponent("RTEffCamera", "Camera")
	self.RTEffTexture = UnityEngine.RenderTexture.GetTemporary(64, 64)
	self.RTEffCamera.targetTexture = self.RTEffTexture

	self:DealWithLocalization()

	self.GoGroup = self:GetChildGameObject("Panel/Condition/Group")
	self.GoAll = self:GetChildGameObject("Panel/Condition/Group/1")
	self.GoAllPanel = self:GetChildGameObject("Panel/Condition/Group/1/Panel")
	self.GoAllSelect = self:GetChildGameObject("Panel/Condition/Group/1/Panel/Select")
	self.GoNone = self:GetChildGameObject("Panel/GoNone")

	self:Init(vParam)
end

function PageConditionCard:DealWithLocalization()
	local txt = self:GetChildComponent("Panel/Condition/Text", "Text")

	txt.text = Lang(12426)
	txt = self:GetChildComponent("Panel/Condition/Group/1/Panel/Text", "Text")
	txt.text = Lang(12096)
	txt = self:GetChildComponent("Panel/GoNone/Text", "Text")
	txt.text = Lang(42230)
end

function PageConditionCard:Init(vParam)
	self.infoWork = vParam.infoWork
	self.index = vParam.slotIndex
	self.curCardIdx = 1
	self.curConIdx = 1
	self.curConIdxList = {}

	self:InitPanel()
end

function PageConditionCard:InitPanel()
	local listSpe = self.infoWork.listSpecial

	self.listGoCon = {}

	for i = 1, #listSpe do
		local item = CellCondition(self.PrefabCellCondition, self.GoGroup, self)

		item:Create()

		item.UIRootObject.name = i + 1

		local data = {
			infoWork = self.infoWork,
			info = listSpe[i],
			effTex = self.RTEffTexture
		}

		item:UpdateData(data)
		self:AddClick(item.UIRootObject, self.OnClickedCondition)
		table.insert(self.listGoCon, item)
	end

	self:UpdateSelectCon()
end

function PageConditionCard:UpdateSelectCon()
	GOUtil.SetActive(self.GoAllSelect, self.curConIdx == 1)

	local y = self.curConIdx == 1 and 20 or 0

	GOUtil.SetTransformLocalPosition(self.GoAllPanel, 0, y, 0)
	self:UpdateScrollViewCard()
end

function PageConditionCard:UpdateScrollViewCard()
	self:UpdateCardList()
	GOUtil.SetActive(self.GoNone, #self.listCard <= 0)

	if self.UIScrollTool ~= nil then
		self.UIScrollTool:UpdateListData(self.listCard)

		return
	end

	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.listCard

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local card = self.listCard[index]
		local data = {
			effTex = self.RTEffTexture
		}

		item:UpdateData(card, data)

		local list = {}

		for _, v in ipairs(self.curConIdxList) do
			table.insert(list, self.infoWork.listSpecial[v - 1].info.ID)
		end

		item:UpdateCondition(list)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCellConditionCard, CellConditionCard, self, false, addCallback, updateCallback)
end

function PageConditionCard:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	self.curCardIdx = index

	self:UpdatePickedCard()
end

function PageConditionCard:OnClickedCondition(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)

	if index == 1 then
		if self.curConIdx ~= index then
			self.curConIdx = index

			table.clear(self.curConIdxList)
		else
			return
		end
	else
		self.curConIdx = index

		if table.contains(self.curConIdxList, index) then
			RemoveTableItem(self.curConIdxList, index)
		else
			table.insert(self.curConIdxList, index)
		end
	end

	if next(self.curConIdxList) == nil then
		self.curConIdx = 1
	end

	for _, v in ipairs(self.listGoCon) do
		v:UpdatePos(self.curConIdxList)
	end

	self:UpdateSelectCon()
end

function PageConditionCard:UpdatePickedCard()
	local curCardId = self.listCard[self.curCardIdx].cardId
	local curRoleId = RoleCardMgr:GetRoleId(curCardId)
	local listCardId = self.infoWork.tempData.cardIds
	local pickCardId = listCardId[self.index]

	if curCardId == pickCardId then
		listCardId[self.index] = 0

		self:UpdateScrollViewCard()
	else
		local lastIdx = 0

		for k, v in ipairs(listCardId) do
			if v ~= 0 then
				local roleId = RoleCardMgr:GetRoleId(v)

				if curRoleId == roleId then
					lastIdx = k

					break
				end
			end
		end

		if lastIdx == 0 or lastIdx == self.index then
			listCardId[self.index] = curCardId

			local loadBankRole

			if lastIdx == 0 then
				loadBankRole = RoleCardMgr:GetRole(curCardId)
			end

			self:OnBack(loadBankRole)
		else
			local function wrap_cb(index)
				if index == 1 then
					listCardId[lastIdx] = 0
					listCardId[self.index] = curCardId

					self:OnBack()
				end
			end

			local infoRole = RoleMgr:GetRole(curRoleId)
			local infoRoleCard = RoleCardMgr:GetRoleCard(curCardId)
			local lastPickCardId = listCardId[lastIdx]
			local infoLastPickCard = RoleCardMgr:GetRoleCard(lastPickCardId)
			local str = string.format(_("Msg_Work_Card_Choose2"), tostring(lastIdx), infoRole:GetName(), infoLastPickCard:GetName(), infoRole:GetName(), infoRoleCard:GetName())

			if lastPickCardId == curCardId then
				str = string.format(_("Msg_Work_Card_Choose1"), tostring(lastIdx), infoRole:GetName(), infoRoleCard:GetName())
			end

			local strTitle = _("Desc_Alert")
			local strOkText = _("UI_Yes")
			local strCancelText = _("UI_No")

			UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, str, wrap_cb, strOkText, strCancelText)
		end
	end
end

function PageConditionCard:UpdateCardList()
	local listRoleCard = {}

	if self.curConIdx == 1 then
		listRoleCard = WorkMgr:GetListCanWorkCard()
	else
		listRoleCard = self:GetListConditionCard()
	end

	self.listCard = self:DealWithSelectCard(listRoleCard)
end

function PageConditionCard:GetListConditionCard()
	local listInfoCon = {}

	for _, v in ipairs(self.curConIdxList) do
		table.insert(listInfoCon, self.infoWork.listSpecial[v - 1].info)
	end

	local temp = WorkMgr:GetListCanWorkCard()
	local result = {}

	local function fun(con)
		result = {}

		for _, v in ipairs(temp) do
			if not con.Type then
				for _, z in ipairs(v.listAbility) do
					if z.ID == con.ID then
						table.insert(result, v)
					end
				end
			elseif con.Type == 1 and v.job == con.Value[2] or con.Type == 2 and v.data.CharacterID == con.Value[1] or con.Type == 3 and v.curLevel >= con.Value[2] or con.Type == 4 and v.curStarLevel >= con.Value[2] or con.Type == 5 and v.cardRank == con.Value[2] then
				table.insert(result, v)
			end
		end
	end

	for _, n in ipairs(listInfoCon) do
		fun(n)

		temp = result
	end

	return result
end

local function SetCardState(listRoleCard, listCardId, curPosIdx)
	local list = {}

	for k1, v1 in ipairs(listRoleCard) do
		local temp = {
			cardId = v1.id
		}
		local index = 0

		for k2, v2 in ipairs(listCardId) do
			if v1.id == v2 then
				index = k2

				break
			end
		end

		if index ~= 0 then
			temp.posIdx = index
			temp.style = index == curPosIdx and 1 or 2
		else
			local isPickedRole = false
			local roleId = RoleCardMgr:GetRoleId(v1.id)

			for _, v in ipairs(listCardId) do
				if v ~= 0 and roleId == RoleCardMgr:GetRoleId(v) then
					isPickedRole = true

					break
				end
			end

			temp.posIdx = 0
			temp.style = isPickedRole and 3 or 4
		end

		table.insert(list, temp)
	end

	return list
end

function PageConditionCard:DealWithSelectCard(listRoleCard)
	local listSelectCardId = self.infoWork.tempData.cardIds
	local listRolePickCard = {}

	for i = #listRoleCard, 1, -1 do
		for _, v in ipairs(listSelectCardId) do
			if listRoleCard[i].id == v then
				table.insert(listRolePickCard, listRoleCard[i])
				table.remove(listRoleCard, i)

				break
			end
		end
	end

	local listRoleUnPickCard = {}

	for i = #listRoleCard, 1, -1 do
		local roleId = listRoleCard[i].data.CharacterID

		for _, v in ipairs(listSelectCardId) do
			if v ~= 0 then
				local selRoleId = RoleCardMgr:GetRoleId(v)

				if roleId == selRoleId then
					table.insert(listRoleUnPickCard, listRoleCard[i])
					table.remove(listRoleCard, i)

					break
				end
			end
		end
	end

	local function funcSort(a, b)
		return a.id < b.id
	end

	table.sort(listRoleCard, funcSort)
	table.sort(listRolePickCard, funcSort)
	table.sort(listRoleUnPickCard, funcSort)

	for i = 1, #listRolePickCard do
		table.insert(listRoleCard, listRolePickCard[i])
	end

	for i = 1, #listRoleUnPickCard do
		table.insert(listRoleCard, listRoleUnPickCard[i])
	end

	return SetCardState(listRoleCard, listSelectCardId, self.index)
end
