-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/DlgCardLevelUp.lua

require("UI/Page/PageRoleCard/Dlg/DlgUpResult")

DlgCardLevelUp = class("DlgCardLevelUp", UIPanel)

function DlgCardLevelUp:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/DlgCardLevelUp"
end

function DlgCardLevelUp:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgCardLevelUp:OnLeave()
	if self.listCellItem then
		for i = 1, #self.listCellItem do
			self.listCellItem[i]:OnLeave()
		end

		self.listCellItem = nil
	end
end

function DlgCardLevelUp:OnRegisterEvent()
	self:AddClick(self.BtnUse, self.OnClickedBtnUse)
	self:AddClick(self.BtnQuit, self.OnClickedBtnQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnBatch, self.OnClickedBtnBatch)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)

	for i = 1, 3 do
		self:AddClick(self["Goto" .. i], self.OnClickedGoto)
		self:AddClick(self["GoAdd" .. i], self.OnPointerDownAddExpItem)
		self:AddListener(self["GoAdd" .. i], self.OnPointerUpAddExpItem, EventTriggerType.PointerUp)
		self:AddListener(self["GoAdd" .. i], self.OnPointerRepeatAddExpItem, EventTriggerType.PointerRepeat)
		self:AddClick(self["GoSub" .. i], self.OnPointerDownSubExpItem)
		self:AddListener(self["GoSub" .. i], self.OnPointerRepeatSubExpItem, EventTriggerType.PointerRepeat)
	end
end

function DlgCardLevelUp:OnUnRegisterEvent()
	self:RemoveClick(self.BtnUse, self.OnClickedBtnUse)
	self:RemoveClick(self.BtnQuit, self.OnClickedBtnQuit)
	self:RemoveClick(self.BtnBatch, self.OnClickedBtnBatch)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)

	for i = 1, 3 do
		self:RemoveClick(self["Goto" .. i], self.OnClickedGoto)
		self:RemoveClick(self["GoAdd" .. i], self.OnPointerDownAddExpItem)
		self:RemoveListener(self["GoAdd" .. i], self.OnPointerUpAddExpItem, EventTriggerType.PointerUp)
		self:RemoveListener(self["GoAdd" .. i], self.OnPointerRepeatAddExpItem, EventTriggerType.PointerRepeat)
		self:RemoveClick(self["GoSub" .. i], self.OnPointerDownSubExpItem)
		self:RemoveListener(self["GoSub" .. i], self.OnPointerRepeatSubExpItem, EventTriggerType.PointerRepeat)
	end
end

function DlgCardLevelUp:OnEnter(vParam)
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = Lang(12061)
	Text = self:GetChildComponent("Panel/BtnUse/Text", "Text")
	Text.text = Lang(12249)
	Text = self:GetChildComponent("Panel/Text", "Text")
	Text.text = Lang(12993)
	self.TxtRealLv = self:GetChildComponent("Panel/Level/TxtLevel1", "Text")
	self.TxtSimuLv = self:GetChildComponent("Panel/Level/TxtLevel2", "Text")
	self.TxtExp = self:GetChildComponent("Panel/Exp/Text", "Text")
	self.RealExpBar = self:GetChildComponent("Panel/Exp/Real", "Image")
	self.SimuExpBar = self:GetChildComponent("Panel/Exp/Simu", "Image")
	self.listCellItem = {}

	for i = 1, 3 do
		self["GoItem" .. i] = self:GetChildGameObject("Panel/BgItem/Item" .. i)
		self["GoItem" .. i].name = i
		self["Cell" .. i] = GOUtil.FindChildGameObject(self["GoItem" .. i], "Cell")

		local item = CellItem(self["Cell" .. i])

		item:InitItemByRoot(self["Cell" .. i])
		table.insert(self.listCellItem, item)

		self["GoAdd" .. i] = GOUtil.FindChildGameObject(self["GoItem" .. i], "Add")
		self["GoSub" .. i] = GOUtil.FindChildGameObject(self["GoItem" .. i], "Sub")
		self["Goto" .. i] = GOUtil.FindChildGameObject(self["GoItem" .. i], "Goto")
		self["GoTxtUse" .. i] = GOUtil.FindChildGameObject(self["GoItem" .. i], "TxtUse")
		self["TxtUse" .. i] = GOUtil.GetComponent(self["GoTxtUse" .. i], "Text")
		self["GoAdd" .. i].name = "GoAdd" .. i
	end

	self.GoCoin = self:GetChildGameObject("Panel/Coin")
	self.TxtCoin = self:GetChildComponent("Panel/Coin/Text", "Text")
	self.ImgCoin = self:GetChildComponent("Panel/Coin/Icon", "Image")

	UIUtil.SetImageSprite(self.ImgCoin, ItemManager:Get(501):GetIcon(), self)

	self.GoArrow = self:GetChildGameObject("Panel/Level/ImgArrow")
	self.BtnQuit = self:GetChildGameObject("Panel/BtnQuit")
	self.BtnUse = self:GetChildGameObject("Panel/BtnUse")
	self.BtnBatch = self:GetChildGameObject("Panel/BtnBatch")
	self.ImgBtnUse = GOUtil.GetComponent(self.BtnUse, "Image")
	self.ImgBtnBatch = GOUtil.GetComponent(self.BtnBatch, "Image")

	GOUtil.SetActive(self.TxtSimuLv, false)
	GOUtil.SetActive(self.GoArrow, false)

	self.preChangeExp = 0
	self.preGray = 0

	self:Init(vParam)
	InstructionMgr:TriggerWait("ShowCardLevelUp")
end

function DlgCardLevelUp:Init(data)
	if not data or not data.roleCardId then
		return
	end

	self.infoRoleCard = RoleCardMgr:GetRoleCard(data.roleCardId)
	self.limitLevel = self.infoRoleCard.curLimitLevel
	self.listExpId = ItemManager.listExpId

	self:InitExpItem()

	self.curExpIdx = 0

	self:InitCostItem()
end

function DlgCardLevelUp:InitExpItem()
	for i = 1, 3 do
		GOUtil.SetActive(self["GoItem" .. i], i <= #self.listExpId)

		local id = self.listExpId[i]
		local num = ItemManager:GetItemCount(id)
		local infoItem = ItemManager:GetValueItem(id, num)

		self.listCellItem[i]:UpdateWithNumType(infoItem)
	end

	self.IsExpEnough = true
	self.IsGoldEnough = true

	self:CheckBatch()
end

function DlgCardLevelUp:CheckBatch()
	local preExpEnough = self.IsExpEnough
	local preGoldEnough = self.IsGoldEnough
	local infoExp

	for i = 1, #self.listExpId do
		local info = ItemManager:Get(self.listExpId[i])
		local count = info:GetCurResNum()

		if count > 0 then
			infoExp = info

			break
		end
	end

	if not infoExp then
		self.IsExpEnough = false
	else
		self.IsExpEnough = true

		local goldCnt = PlayerInst:GetGold()

		if goldCnt < infoExp.data.Value * GetConfigArgInt("GoldPerExp") then
			self.IsGoldEnough = false
		else
			self.IsGoldEnough = true
		end
	end

	if preExpEnough ~= self.IsExpEnough or preGoldEnough ~= self.IsGoldEnough then
		local gray = self.IsExpEnough and self.IsGoldEnough and 0 or 1

		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnBatch, gray))
	end
end

function DlgCardLevelUp:InitCostItem()
	self.listCostItem = {}

	for i = 1, #self.listExpId do
		if i > 3 then
			break
		end

		local temp = {
			num = 0,
			id = self.listExpId[i]
		}

		table.insert(self.listCostItem, temp)
	end

	self:UpdatePanel()
	self:UpdateLevel()
end

function DlgCardLevelUp:UpdateCostItem(_type)
	local itemIdx = self.curExpIdx
	local addNum = 1
	local subNum = -1

	if _type == 1 then
		self.listCostItem[itemIdx].num = self.listCostItem[itemIdx].num + addNum
	else
		self.listCostItem[itemIdx].num = self.listCostItem[itemIdx].num + subNum < 0 and 0 or self.listCostItem[itemIdx].num + subNum
	end

	self:UpdatePanel()
end

function DlgCardLevelUp:UpdatePanel()
	local changeExp = 0
	local gray = 0

	for i = 1, #self.listCostItem do
		local id = self.listCostItem[i].id
		local holdNum = ItemManager:GetItemCount(id)
		local costNum = self.listCostItem[i].num
		local isCanAdd = holdNum > 0
		local isCanSub = costNum > 0

		GOUtil.SetActive(self["GoAdd" .. i], isCanAdd)
		GOUtil.SetActive(self["GoSub" .. i], isCanSub)
		GOUtil.SetActive(self["Goto" .. i], not isCanAdd)
		GOUtil.SetActive(self["GoTxtUse" .. i], isCanSub)

		self["TxtUse" .. i].text = costNum

		local remNum = Mathf.Max(holdNum - costNum, 0)
		local infoItem = ItemManager:GetValueItem(id, remNum)

		self.listCellItem[i]:UpdateNumOnly(remNum)

		changeExp = changeExp + infoItem.data.Value * costNum
	end

	local goldNum = changeExp * GetConfigArgInt("GoldPerExp")

	self.TxtCoin.text = goldNum

	local holdGold = PlayerInst:GetGold()

	if holdGold < goldNum then
		gray = 1
		self.TxtCoin.color = Color.red
	else
		self.TxtCoin.color = Color.white
	end

	if changeExp == 0 then
		gray = 1

		GOUtil.SetTransformLocalPosition(self.TxtRealLv.gameObject, 0, 0, 0)
	else
		GOUtil.SetTransformLocalPosition(self.TxtRealLv.gameObject, -190, 0, 0)
	end

	if self.preGray ~= gray then
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnUse, gray))

		self.preGray = gray
	end

	if self.preChangeExp ~= 0 and changeExp == 0 or changeExp ~= 0 and self.preChangeExp == 0 then
		GOUtil.SetActive(self.TxtSimuLv, changeExp ~= 0)
		GOUtil.SetActive(self.GoArrow, changeExp ~= 0)

		self.preChangeExp = changeExp
	end
end

function DlgCardLevelUp:UpdateLevel()
	self.TxtRealLv.text = Lang(12004) .. " <size=35>" .. self.infoRoleCard.curLevel .. "</size>/" .. self.limitLevel
	self.TxtSimuLv.text = "<color=#318D11>" .. Lang(12004) .. " <size=35>" .. self.infoRoleCard.simCurLevel .. "</size>/" .. self.limitLevel .. "</color>"

	local lastLvExp = LevelManager:GetRoleCardExp(self.infoRoleCard.curLevel - 1)

	self.TxtExp.text = self.infoRoleCard.simExp - lastLvExp .. "/" .. self.infoRoleCard.nextExp

	local curLevel = self.infoRoleCard.curLevel
	local simLevel = self.infoRoleCard.simCurLevel

	if simLevel <= curLevel then
		self.SimuExpBar.fillAmount = self.infoRoleCard.simCurExp / self.infoRoleCard.simNextExp
		self.RealExpBar.fillAmount = self.infoRoleCard.curExp / self.infoRoleCard.nextExp
	else
		self.SimuExpBar.fillAmount = 1
	end
end

function DlgCardLevelUp:CheckCondition()
	if self.curExpIdx == nil then
		return false
	end

	local curItemId = self.listExpId[self.curExpIdx]

	if not curItemId then
		return false
	end

	local infoItem = ItemManager:Get(curItemId)
	local holdNum = ItemManager:GetItemCount(curItemId)
	local seleNum = self.listCostItem[self.curExpIdx].num
	local isEnough = ItemManager:IsItemHoldEnough(curItemId, seleNum + 1)

	if not isEnough then
		return false
	end

	local curSimLevel = self.infoRoleCard.simCurLevel

	if curSimLevel >= self.limitLevel then
		if self.limitLevel >= self.infoRoleCard.maxLevel then
			UIMgr.ShowMsg(_("Msg_CardLevelMax"))
		else
			UIMgr.ShowMsg(RoleCardMgr:GetCardNextLevelLimitInfo(self.infoRoleCard, curSimLevel))
		end

		return false
	end

	return true
end

function DlgCardLevelUp:OnPointerDownAddExpItem(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	if index and index ~= self.curExpIdx then
		self.curExpIdx = index
	end

	if self.isNotFull then
		return
	end

	if not self:CheckCondition() then
		self.isNotFull = true

		return
	end

	self:RefreshSimData(1)
end

function DlgCardLevelUp:OnPointerRepeatAddExpItem(data)
	local go = data.pointerPressRaycast.gameObject

	if IsNil(go) then
		return
	end

	local index = tonumber(go.transform.parent.name)

	if index ~= self.curExpIdx then
		self.curExpIdx = index
	end

	if self.isNotFull then
		return
	end

	if not self:CheckCondition() then
		self.isNotFull = true

		return
	end

	self:RefreshSimData(1)
end

function DlgCardLevelUp:OnPointerUpAddExpItem()
	if self.isNotFull then
		self.isNotFull = nil
	end
end

function DlgCardLevelUp:OnPointerDownSubExpItem(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	if index ~= self.curExpIdx then
		self.curExpIdx = index
	end

	self:RefreshSimData(2)
end

function DlgCardLevelUp:OnPointerRepeatSubExpItem(data)
	local go = data.pointerPressRaycast.gameObject.transform.parent
	local index = tonumber(go.name)

	if index ~= self.curExpIdx then
		self.curExpIdx = index
	end

	self:RefreshSimData(2)
end

function DlgCardLevelUp:RefreshSimData(_type)
	local itemId = self.listExpId[self.curExpIdx]
	local infoItem = ItemManager:Get(itemId)
	local expAdd = infoItem.data.Value
	local num = _type == 1 and 1 or -1

	self.infoRoleCard:ChangeSimulateExp(num * expAdd)
	self:UpdateCostItem(_type)
	self:UpdateLevel()
end

function DlgCardLevelUp:OnClickedBtnUse()
	self:OnPointerUpAddExpItem()

	local haveItem = false

	for i = 1, #self.listCostItem do
		if self.listCostItem[i].num > 0 then
			haveItem = true
		end
	end

	if not haveItem then
		UIMgr.ShowMsg(_("Msg_AddMoreExpItem"))

		return
	end

	local holdGold = PlayerInst:GetGold()
	local costGold = 0

	for _, v in pairs(self.listCostItem) do
		if v.num > 0 then
			local id = v.id
			local value = ItemManager:Get(id).data.Value
			local sum = v.num * value * GetConfigArgInt("GoldPerExp")

			costGold = costGold + sum
		end
	end

	if holdGold < costGold then
		UIMgr.ShowMsg(_("Desc_Gold_Not_Enough"))

		return
	end

	local list = {}

	for i = 1, #self.listCostItem do
		if self.listCostItem[i].num > 0 then
			table.insert(list, self.listCostItem[i].id)
			table.insert(list, self.listCostItem[i].num)
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if self.infoRoleCard.curLevel > self.infoRoleCard.preLevel then
				self:Close()

				local data = {
					index = 1,
					infoRoleCard = self.infoRoleCard
				}

				UIMgr.AddPanel(DlgUpResult(), data)
			else
				self:InitCostItem()
				self:CheckBatch()
			end

			Event.Instance:Fire("UpdateAfterCardDevelop", eTabType.OverV)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestOperateItem(self.infoRoleCard.id, list, wrap_cb)
end

function DlgCardLevelUp:OnClickedGoto(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	local function wrap_cb()
		self:Close()
	end

	local curItemId = self.listExpId[index]

	UIMgr.ShowItemTip(ItemManager:Get(curItemId), 2, true, false, wrap_cb)
end

function DlgCardLevelUp:OnClickedBtnQuit()
	self.infoRoleCard:UpdateSimData()
	self:Close()
end

function DlgCardLevelUp:OnClickedBtnBatch()
	if not self.IsExpEnough then
		UIMgr.ShowMsg(_("Msg_Exp_Item_None"))

		return
	end

	if not self.IsGoldEnough then
		UIMgr.ShowMsg(_("Desc_Gold_Not_Enough"))

		return
	end

	for _, v in pairs(self.listCostItem) do
		v.num = 0

		self.infoRoleCard:UpdateSimData()
	end

	local holdGold = PlayerInst:GetGold()
	local goldExp = math.floor(holdGold / GetConfigArgInt("GoldPerExp"))
	local limitLevelExp = LevelManager:GetRoleCardExp(self.limitLevel - 1)
	local limitExp = limitLevelExp - self.infoRoleCard.pb.levelExp
	local exp = limitExp < goldExp and limitExp or goldExp
	local changeExp = 0

	for i = 1, #self.listExpId do
		local expId = self.listExpId[i]
		local info = ItemManager:Get(expId)
		local hold = info:GetCurResNum()

		if hold > 0 and exp > 0 then
			local need = math.floor(exp / info.data.Value)

			if hold <= need then
				self.listCostItem[i].num = hold
				exp = exp - hold * info.data.Value
				changeExp = changeExp + hold * info.data.Value
			else
				self.listCostItem[i].num = need
				exp = exp - need * info.data.Value
				changeExp = changeExp + need * info.data.Value

				if limitExp < goldExp and exp > 0 and holdGold >= (changeExp + info.data.Value) * GetConfigArgInt("GoldPerExp") then
					exp = exp - 1 * info.data.Value
					changeExp = changeExp + 1 * info.data.Value
					self.listCostItem[i].num = self.listCostItem[i].num + 1
				end
			end
		end
	end

	self.infoRoleCard:ChangeSimulateExp(changeExp)
	self:UpdatePanel()
	self:UpdateLevel()
end

function DlgCardLevelUp:UpdateItemDataNotify()
	self:InitExpItem()
	self:UpdatePanel()
end

function DlgCardLevelUp:UpdateNetData()
	self:UpdatePanel()
	self:UpdateLevel()
end
