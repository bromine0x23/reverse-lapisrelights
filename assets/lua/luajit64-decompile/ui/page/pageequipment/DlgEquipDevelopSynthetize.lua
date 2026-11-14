-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageEquipment/DlgEquipDevelopSynthetize.lua

require("UI/Page/PageEquipment/CellReel")
require("UI/Page/PageEquipment/DlgEnchant")
require("UI/Item/CellItem")

DlgEquipDevelopSynthetize = class("DlgEquipDevelopSynthetize", UIPanel)
reelPrice = {
	1000,
	5000,
	50000
}

local effectPath = "Fx/UI/Eff_Ui_PanelEquipEnchant/Eff_Ui_PanelEquipEnchant/FX_UI_Synthesis/FX_UI_Synthesis_1"

function DlgEquipDevelopSynthetize:ctor()
	self.UIPrefabPath = "UI/PanelEquipment/PanelEquipDevelopSynthetize"
end

function DlgEquipDevelopSynthetize:PreLoad()
	self:LoadResAsync("UI/PanelEquipment/CellReel", "PrefabCellReel", GameObject)
end

function DlgEquipDevelopSynthetize:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgEquipDevelopSynthetize:OnLeave()
	ResourceMgr.Unload(self.PrefabCellReel)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	for i = 1, 2 do
		self["Btn" .. i] = nil
		self["Select" .. i] = nil
		self["Tab" .. i] = nil
		self["TabPanel" .. i] = nil
	end

	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_WC")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_SW")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Glow01")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_FuMo/Eff_Ui_FuMo_Glow01_B")
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_Welfare/FX_UI_PanelEnchant")
end

function DlgEquipDevelopSynthetize:OnRegisterEvent()
	for i = 1, 2 do
		self:AddClick(self["Btn" .. i], self.OnClickedBtn)
	end

	self:AddListener(self.BtnSyn1, self.OnPointDown, EventTriggerType.PointerDown)
	self:AddListener(self.BtnSyn1, self.OnPointUp, EventTriggerType.PointerUp)
	self:AddListener(self.BtnSyn1, self.OnPointerLongPress, EventTriggerType.PointerRepeat)
	self:AddClick(self.Button1, self.OnClickedButtonAdjust)
	self:AddClick(self.Button2, self.OnClickedButtonAdjust)
	self:AddClick(self.ButtonUp, self.OnClickedButtonAdjust)
	self:AddClick(self.BtnSyn2, self.OnClickedButtonSyn2)
	self:AddClick(self.BtnAddAll, self.OnClickedButtonAddAll)
	self:AddClick(self.BtnfromItemCell, self.OnClickedFromItemCell)
	Event.Instance:Add("UpdateEnchantPanel", self.UpdateEnchantPanel, self)
end

function DlgEquipDevelopSynthetize:OnUnRegisterEvent()
	for i = 1, 2 do
		self:RemoveClick(self["Btn" .. i], self.OnClickedBtn)
	end

	self:RemoveListener(self.BtnSyn1, self.OnPointDown, EventTriggerType.PointerDown)
	self:RemoveListener(self.BtnSyn1, self.OnPointUp, EventTriggerType.PointerUp)
	self:RemoveListener(self.BtnSyn1, self.OnPointerLongPress, EventTriggerType.PointerRepeat)
	self:RemoveClick(self.Button1, self.OnClickedButtonAdjust)
	self:RemoveClick(self.Button2, self.OnClickedButtonAdjust)
	self:RemoveClick(self.ButtonUp, self.OnClickedButtonAdjust)
	self:RemoveClick(self.BtnSyn2, self.OnClickedButtonSyn2)
	self:RemoveClick(self.BtnAddAll, self.OnClickedButtonAddAll)
	self:RemoveClick(self.BtnfromItemCell, self.OnClickedFromItemCell)
	Event.Instance:Remove("UpdateEnchantPanel", self.UpdateEnchantPanel, self)
end

function DlgEquipDevelopSynthetize:OnEnter(vParam)
	self.synItemCount = 1
	self.adjustNum = 1
	self.buyNum = 1
	self.ssrCurReelIdx = {}
	self.ssrCurReelGrayed = {}
	self.selectedSSRNum = 0
	self.curReelIdx = 0

	for i = 1, 2 do
		self["TabPanel" .. i] = self:GetChildGameObject("Synthetize/Tab" .. i)
		self["Tab" .. i] = self:GetChildGameObject("Synthetize/BtnGroup/Tab" .. i)
		self["Btn" .. i] = self:GetChildGameObject("Synthetize/BtnGroup/Tab" .. i .. "/Btn")
		self["Select" .. i] = self:GetChildGameObject("Synthetize/BtnGroup/Tab" .. i .. "/Select")
		self["Btn" .. i].name = i
	end

	local go

	self.cellItem = CellItem()
	self.fromItem = CellItem()
	self.toItem = CellItem()

	self.cellItem:Init(self:GetChildGameObject("Synthetize/Tab1/Panel/Describe/CellItem"))

	self.BtnfromItemCell = self:GetChildGameObject("Synthetize/Tab1/Panel/Synthetize/PanelSynthetize/FromItem")

	self.fromItem:Init(self:GetChildGameObject("Synthetize/Tab1/Panel/Synthetize/PanelSynthetize/FromItem/CellItem"))
	self.toItem:Init(self:GetChildGameObject("Synthetize/Tab1/Panel/Synthetize/PanelSynthetize/ToItem"))

	self.cellItemText = self:GetChildComponent("Synthetize/Tab1/Panel/Describe/ItemNameBg/ItemName", "Text")
	self.cellItemPrice = self:GetChildComponent("Synthetize/Tab1/Panel/Synthetize/PanelSynthetize/Gold/Text", "Text")
	self.cellItemDes = self:GetChildComponent("Synthetize/Tab1/Panel/Describe/ItemDes/Text", "Text")
	self.BtnSyn1 = self:GetChildGameObject("Synthetize/Tab1/Panel/Synthetize/PanelSynthetize/BtnSyn")
	self.EffectRoot = self:GetChildGameObject("Synthetize/Tab1/Panel/Synthetize/PanelSynthetize/effect")
	self.Button1 = self:GetChildGameObject("Synthetize/Tab2/Panel/Synthetize/Bg/Info3/Button1")
	self.Button2 = self:GetChildGameObject("Synthetize/Tab2/Panel/Synthetize/Bg/Info3/Button2")
	self.ButtonUp = self:GetChildGameObject("Synthetize/Tab2/Panel/Synthetize/Bg/Info3/ButtonUp")
	self.Tab2RequireField = self:GetChildComponent("Synthetize/Tab2/Panel/Synthetize/Bg/Require", "Text")
	self.Tab2GoldCostField = self:GetChildComponent("Synthetize/Tab2/Panel/Synthetize/BtnUpLv/Gold/Text", "Text")
	self.BtnSyn2 = self:GetChildGameObject("Synthetize/Tab2/Panel/Synthetize/BtnUpLv")
	self.BtnAddAll = self:GetChildGameObject("Synthetize/Tab2/Panel/Panel2/BtnBatch")
	self.InputField = self:GetChildComponent("Synthetize/Tab2/Panel/Synthetize/Bg/Info3/InputField", "InputField")
	go = self:GetChildGameObject("Synthetize/Tab2/Panel/Synthetize/BtnUpLv/Gold/Image").gameObject

	GOUtil.SetTransformLocalPosition(go, -20, go.transform.localPosition.y, 0)

	self.InputField.interactable = false

	self:DealWithLocalization()

	self.GoReelList = self:GetChildGameObject("ReelList")

	self:InitReelList()
	self:InitSSRReelList()
	self:InitData(vParam)
	self:UpdateGroupTab(1)
	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon9", self.infoRole.data.VocalCommon9)
	self:UpdateSynthetizePanel(1)
end

function DlgEquipDevelopSynthetize:DealWithLocalization()
	self.Tab2RequireField.text = "必要な数<color=red>20</color>"

	local txt

	txt = self:GetChildComponent("ReelList/Text", "Text")
	txt.text = "魔導書一覧"
	txt = self:GetChildComponent("Synthetize/Title/Text", "Text")
	txt.text = "魔導書獲得"
	txt = self:GetChildComponent("Synthetize/BtnGroup/Tab1/Select/Text", "Text")
	txt.text = "同属性合成"
	txt = self:GetChildComponent("Synthetize/BtnGroup/Tab1/1/Text", "Text")
	txt.text = "同属性合成"
	txt = self:GetChildComponent("Synthetize/BtnGroup/Tab2/Select/Text", "Text")
	txt.text = "同級合成"
	txt = self:GetChildComponent("Synthetize/BtnGroup/Tab2/2/Text", "Text")
	txt.text = "同級合成"
	txt = self:GetChildComponent("Synthetize/Tab1/Panel/Synthetize/PanelSynthetize/FromItem/TxtNeed", "Text")
	txt.text = "消費：20"
	txt = self:GetChildComponent("Synthetize/Tab2/Panel/Synthetize/Bg/Text", "Text")
	txt.text = ""
end

function DlgEquipDevelopSynthetize:OnPointDown()
	if self.fromItem.info:GetNum() < 20 or PlayerInst:GetGold() < reelPrice[self.infoLowerReel.data.Quality] then
		return
	end

	self.IsLongPress = false
	self.longPressDisable = false
end

function DlgEquipDevelopSynthetize:OnPointUp()
	if self.fromItem.info:GetNum() < 20 then
		UIMgr.ShowMsg(Lang(42180))

		return
	end

	if PlayerInst:GetGold() < reelPrice[self.infoLowerReel.data.Quality] then
		UIMgr.ShowMsg(Lang(12196))

		return
	end

	if not self.IsLongPress then
		local item1 = self.infoLowerReel
		local money = reelPrice[self.infoLowerReel.data.Quality]

		if item1:GetCurResNum() >= 20 and money <= PlayerInst:GetGold() then
			self.synItemCount = 1

			EffectMgr:Alloc(effectPath, self.EffectRoot, true, 2)
		else
			if money > PlayerInst:GetGold() then
				UIMgr.ShowMsg(Lang(12196))
			else
				UIMgr.ShowMsg(Lang(42180))
			end

			return
		end

		self:OnClickedSynthetize()
	elseif self.synItemCount ~= 0 then
		if not self.isPlayEff then
			EffectMgr:Alloc(effectPath, self.EffectRoot, true, 2)
		end

		self:OnClickedSynthetize()
	end

	self.isPlayEff = false
end

function DlgEquipDevelopSynthetize:OnPointerLongPress(data)
	if self.fromItem.info:GetNum() < 20 or PlayerInst:GetGold() < reelPrice[self.infoLowerReel.data.Quality] then
		return
	end

	if self.longPressDisable then
		return
	end

	self.IsLongPress = true

	self:SimulateCostItem()
end

function DlgEquipDevelopSynthetize:SimulateCostItem()
	local item1 = self.infoLowerReel
	local money = reelPrice[self.infoLowerReel.data.Quality]

	if item1:GetCurResNum() >= 20 * (self.synItemCount + 1) and PlayerInst:GetGold() >= money * (self.synItemCount + 1) then
		self.synItemCount = self.synItemCount + 1
	else
		if self.synItemCount > 0 then
			self.isPlayEff = true

			EffectMgr:Alloc(effectPath, self.EffectRoot, true, 2)
		end

		self.longPressDisable = true

		return
	end

	EffectMgr:Alloc(effectPath .. "a", self.EffectRoot, true, 2)
	self:UpdateTree()

	local usedNum = self.synItemCount * 20

	self.toItem:UpdateNumOnly(self.toItem.info:GetNum() + self.synItemCount)
	self.fromItem:UpdateNumOnly(self.fromItem.info:GetNum() - usedNum)
	self.fromItem:UpdateNumColor(usedNum > self.fromItem.info:GetNum() and "FF0000" or "585E62")
end

function DlgEquipDevelopSynthetize:OnClickedSynthetize()
	if self.fromItem.info:GetNum() < 20 then
		UIMgr.ShowMsg(Lang(42180))

		return
	end

	local function callback(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		self.synItemCount = 0

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdateTree()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			self:UpdateTree()
			Event.Instance:Fire(EventEnum.UpdatePlayerInfo)
		end

		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	printTable({
		self.infoLowerReel.id,
		self.synItemCount
	})
	NetManager:RequestSynthetize(self.infoReel.id, self.synItemCount, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgEquipDevelopSynthetize:UpdateTree()
	if not self.infoLowerReel then
		return
	end

	self.synItemCount = math.max(self.synItemCount, 1)

	local item1 = self.infoLowerReel
	local money = reelPrice[self.infoLowerReel.data.Quality]
	local holdNum = item1:GetCurResNum()
	local needCount = 20
	local usedNum = needCount * self.synItemCount

	if self.UIScrollTool and self.UIScrollTool.ItemRoot2ItemDict then
		for _, v in self.UIScrollTool.ItemRoot2ItemDict:Enumerator() do
			v.Item:UpdateHoldNum()
		end
	end

	if self.SSRUIScrollTool and self.SSRUIScrollTool.ItemRoot2ItemDict then
		for _, v in self.SSRUIScrollTool.ItemRoot2ItemDict:Enumerator() do
			v.Item:UpdateHoldNum()
		end
	end

	self.cellItemPrice.text = money * self.synItemCount

	self.toItem:UpdateNumOnly(self.toItem.info:GetNum())
	self.fromItem:UpdateNumOnly(self.fromItem.info:GetNum())
	self.fromItem:UpdateNumColor(usedNum > self.fromItem.info:GetNum() and "FF0000" or "585E62")
	GOUtil.SetActive(self.fromItem.gText, true)
	GOUtil.SetActive(self.toItem.gText, true)
end

function DlgEquipDevelopSynthetize:ClearSSRReelSelection()
	self.selectedSSRNum = 0
	self.ssrCurReelGrayed = {}
	self.ssrCurReelIdx = {}

	for index, v in pairs(self.listSSRReelId) do
		local id = v[1]
		local info = ItemManager:Get(id)

		self.ssrCurReelGrayed[index] = false
		self.ssrCurReelIdx[index] = false
	end

	if self.SSRUIScrollTool and self.SSRUIScrollTool.ItemRoot2ItemDict then
		for _, v in self.SSRUIScrollTool.ItemRoot2ItemDict:Enumerator() do
			v.Item:UpdateHoldNum()
			v.Item:SetGray(self.ssrCurReelGrayed[v.Item.Index])
			v.Item:UpdateSelectState(self.ssrCurReelIdx[v.Item.Index])
		end
	end

	self:UpdateSSRWillUseSuit(true)
end

function DlgEquipDevelopSynthetize:OnClickedButtonAdjust(data)
	self:ClearSSRReelSelection()

	local go = data.pointerPress
	local maxNum = 0

	if maxNum == 0 then
		maxNum = 100
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
		self.Tab2RequireField.text = "必要な数<color=red>" .. self.buyNum * 20 .. "</color>"
		self.Tab2GoldCostField.text = self.buyNum * 50000
	end
end

function DlgEquipDevelopSynthetize:OnClickedButtonSyn2()
	print("OnClickedButtonSyn2")

	local items = {}
	local totalSSRNum = self.buyNum * 20
	local requiredNum = 0
	local money = self.buyNum * 50000

	local function callback(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdateTree()
		else
			printTable({
				vMsg.result
			})
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			self:UpdateTree()
			Event.Instance:Fire(EventEnum.UpdatePlayerInfo)
		end

		LoadingMgr.Hide(eLoadingType.Repeat)
		self:ClearSSRReelSelection()
	end

	for index, v in pairs(self.listSSRReelId) do
		if self.ssrCurReelIdx[index] then
			local id = v[1]
			local info = ItemManager:Get(id)
			local amount = math.min(totalSSRNum, info:GetCurResNum())

			totalSSRNum = totalSSRNum - amount
			requiredNum = requiredNum + amount

			if totalSSRNum == 0 then
				break
			end
		end
	end

	local buyNum = math.min(self.buyNum, math.floor(requiredNum / 20))

	if buyNum * 20 - totalSSRNum < 20 then
		UIMgr.ShowMsg(Lang(42180))

		return
	end

	requiredNum = buyNum * 20

	for index, v in pairs(self.listSSRReelId) do
		if self.ssrCurReelIdx[index] then
			local id = v[1]
			local info = ItemManager:Get(id)
			local amount = math.min(requiredNum, info:GetCurResNum())

			requiredNum = requiredNum - amount

			table.insert(items, {
				id = id,
				num = amount
			})

			if requiredNum == 0 then
				break
			end
		end
	end

	if money <= PlayerInst:GetGold() then
		NetManager:RequestSynthetize2(self.infoReel.id, buyNum, items, callback)
		LoadingMgr.Show(eLoadingType.Repeat)
	else
		UIMgr.ShowMsg(Lang(12196))
	end
end

function DlgEquipDevelopSynthetize:OnClickedButtonAddAll()
	self:ClearSSRReelSelection()

	if self.SSRUIScrollTool and self.SSRUIScrollTool.ItemRoot2ItemDict then
		self.selectedSSRNum = 0
		self.ssrCurReelGrayed = {}
		self.ssrCurReelIdx = {}

		for index, v in pairs(self.listSSRReelId) do
			local noMoreNeeded = self.buyNum * 20 < self.selectedSSRNum
			local id = v[1]
			local info = ItemManager:Get(id)

			self.ssrCurReelGrayed[index] = noMoreNeeded

			if noMoreNeeded then
				self.ssrCurReelIdx[index] = false
			else
				self.ssrCurReelIdx[index] = true
				self.selectedSSRNum = self.selectedSSRNum + info:GetCurResNum()
			end
		end

		self.buyNum = math.min(self.buyNum, math.floor(self.selectedSSRNum / 20))
		self.selectedSSRNum = 0
		self.ssrCurReelGrayed = {}
		self.ssrCurReelIdx = {}

		for index, v in pairs(self.listSSRReelId) do
			local noMoreNeeded = self.buyNum * 20 <= self.selectedSSRNum
			local id = v[1]
			local info = ItemManager:Get(id)

			self.ssrCurReelGrayed[index] = noMoreNeeded

			if noMoreNeeded then
				self.ssrCurReelIdx[index] = false
			else
				self.ssrCurReelIdx[index] = true
				self.selectedSSRNum = self.selectedSSRNum + info:GetCurResNum()
			end
		end

		if self.SSRUIScrollTool and self.SSRUIScrollTool.ItemRoot2ItemDict then
			for _, v in self.SSRUIScrollTool.ItemRoot2ItemDict:Enumerator() do
				v.Item:SetGray(self.ssrCurReelGrayed[v.Item.Index])
				v.Item:UpdateSelectState(self.ssrCurReelIdx[v.Item.Index])
			end
		end

		self.selectedSSRNum = self.buyNum * 20
		self.adjustNum = self.buyNum
		self.InputField.text = self.buyNum
		self.Tab2RequireField.text = "必要な数<color=red>" .. self.buyNum * 20 .. "</color>"
		self.Tab2GoldCostField.text = self.buyNum * 50000

		printTable(self.ssrCurReelGrayed)
		printTable(self.ssrCurReelIdx)
	end
end

function DlgEquipDevelopSynthetize:OnClickedFromItemCell()
	if self.infoLowerReel.data.Quality == 1 then
		return
	end

	local index = 1

	for k, v in ipairs(self.listReelId) do
		if self.infoLowerReel.id == v[1] then
			index = k

			break
		end
	end

	self:UpdateSynthetizePanel(index)

	local y = GetContentPos(self.UIScrollTool.ScrollView, math.ceil(#self.listReelId / 3), math.ceil(index / 3), true)

	self.UIScrollTool:SetContentPosImmediate(Vector2(0, -y), self.listReelId)
	self:InitSSRReelList()
end

function DlgEquipDevelopSynthetize:Show()
	GOUtil.SetActive(self.UIRootObject, true)

	if self.UIScrollTool and self.ContentPosY and self.ContentPosY ~= 0 then
		self.UIScrollTool:SetInitPos(Vector3(0, self.ContentPosY, 0))
		self.UIScrollTool:SetContentPosImmediate(Vector2(0, self.ContentPosY), self.listReelId)
	end

	InfoSoundEventMgr:LoadBank(self.infoRole.data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon9", self.infoRole.data.VocalCommon9)
end

function DlgEquipDevelopSynthetize:Hide()
	GOUtil.SetActive(self.UIRootObject, false)

	if self.UIScrollTool then
		self.ContentPosY = self.UIScrollTool.ScrollView.content.anchoredPosition.y
	end
end

function DlgEquipDevelopSynthetize:InitReelList()
	self.listReelId = ItemManager:GetScrollItemListWithCount(2)

	local scrollArea = self:GetChildGameObject("ReelList/BgScroll/ScrollArea")
	local content = self:GetChildComponent("ReelList/BgScroll/ScrollArea/Content", "RectTransform")
	local count = #self.listReelId

	local function addCallback(item)
		self:RemoveClick(item.UIRootObject, self.OnClickedCell)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local reelId = self.listReelId[index][1]

		item:UpdateData(reelId, self.curReelIdx)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellReel, CellReel, self, false, addCallback, updateCallback)
end

function DlgEquipDevelopSynthetize:InitSSRReelList()
	self.listSSRReelId = {}

	for _, v in pairsByKeys(ItemManager:GetScrollItemListWithCount(3)) do
		if v[1] ~= 913 and v[2] > 0 then
			table.insert(self.listSSRReelId, v)
		end
	end

	local ssrScrollArea = self:GetChildGameObject("Synthetize/Tab2/Panel/Panel2/Bg/Group")
	local ssrContent = self:GetChildComponent("Synthetize/Tab2/Panel/Panel2/Bg/Group/Content", "RectTransform")
	local ssrCount = #self.listSSRReelId

	local function ssrAddCallback(item)
		self:RemoveClick(item.UIRootObject, self.OnClickedCellSSR)
		self:AddClick(item.UIRootObject, self.OnClickedCellSSR)
	end

	local function ssrUpdateCallback(item, index)
		local reelId = self.listSSRReelId[index][1]

		item:UpdateData(reelId, self.ssrCurReelIdx[index], self.ssrCurReelGrayed[index])
	end

	self.SSRUIScrollTool = UIScrollTool()

	self.SSRUIScrollTool:InitList(ssrScrollArea, ssrContent, ssrCount, self.PrefabCellReel, CellReel, self, false, ssrAddCallback, ssrUpdateCallback)
	self:ClearSSRReelSelection()
end

function DlgEquipDevelopSynthetize:InitData(vParam)
	if not vParam.slotIdx or not vParam.infoRole then
		return
	end

	self.slotIdx = vParam.slotIdx
	self.infoRole = vParam.infoRole

	if not self.IsSet then
		local imgIcon = self:GetChildComponent("ReelList/Role/Icon", "Image")
		local imgJob = self:GetChildComponent("ReelList/Role/Job", "Image")

		SetImageSprite(imgIcon, self.infoRole.actorData.CharacterIcon, self)
		SetImageSprite(imgJob, "UIDyAtlas/RoleJob/ICO_" .. self.infoRole.data.Job .. "_01_S", self)

		self.IsSet = true
	end

	self.infoSlot = self.infoRole:GetEquipSlot(self.slotIdx)
	self.infoEquip = EquipmentManager:GetEquip(self.infoRole:GetEquipId(self.slotIdx))

	self:InitEquipInfo()
	self:UpdatePanel()
end

function DlgEquipDevelopSynthetize:InitEquipInfo()
	self:ClearSSRReelSelection()
	self:UpdateWillUseSuit(true)
	self:UpdateTree()
end

function DlgEquipDevelopSynthetize:UpdateEquipLevel()
	return
end

function DlgEquipDevelopSynthetize:UpdatePanel()
	self:UpdateEquipLevel()
end

function DlgEquipDevelopSynthetize:UpdateWillUseSuit(needplay)
	self:UpdateReelInfo()
end

function DlgEquipDevelopSynthetize:UpdateSSRWillUseSuit(needplay)
	self:UpdateSSRReelInfo()
end

function DlgEquipDevelopSynthetize:UpdateReelInfo()
	if self.infoReel then
		self:UpdateGroupTab(1)
		self.Tab2:SetActive(self.infoReel.data.ID == 913)
		print(self:GetRank(self.infoReel))
	end
end

function DlgEquipDevelopSynthetize:UpdateSSRReelInfo()
	if self.ssrInfoReel then
		print(self:GetRank(self.ssrInfoReel))
	end
end

function DlgEquipDevelopSynthetize:OnClickedCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	self:UpdateSynthetizePanel(info.Item.Index)
end

function DlgEquipDevelopSynthetize:OnClickedCellSSR(data)
	local go = data.pointerPress.gameObject
	local info = self.SSRUIScrollTool.ItemRoot2ItemDict:GetValue(go)

	if info.Item:IsActive() then
		self:UpdateSynthetizeSSRPanel(info.Item.Index)
	end
end

function DlgEquipDevelopSynthetize:RequestEquipEnchant()
	local roleId = self.infoRole.id
	local slot = self.slotIdx
	local reelId = self.infoReel.id

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			local attr = vMsg.attributes
			local data = {
				infoRole = self.infoRole,
				slotIdx = slot,
				reelId = reelId,
				attr = attr
			}

			UIMgr.AddPanel(DlgEnchant(), data)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestEquipEnchant(roleId, slot, reelId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgEquipDevelopSynthetize:OnClickedBtn(data)
	local go = data.pointerPress
	local index = tonumber(go.name)

	self:UpdateGroupTab(index)
end

function DlgEquipDevelopSynthetize:UpdateGroupTab(index)
	self.curTabIndex = index

	for i = 1, 2 do
		if i == index then
			self["Btn" .. i]:SetActive(false)
			self["Select" .. i]:SetActive(true)
			self["TabPanel" .. i]:SetActive(true)
		else
			self["Btn" .. i]:SetActive(true)
			self["Select" .. i]:SetActive(false)
			self["TabPanel" .. i]:SetActive(false)
		end
	end
end

function DlgEquipDevelopSynthetize:UpdateEnchantPanel(IsSave)
	return
end

function DlgEquipDevelopSynthetize:UpdateSynthetizePanel(index)
	if self.curReelIdx == index then
		return
	end

	local hideIdx = self.curReelIdx

	self.curReelIdx = index
	self.recordReelIdx = index
	self.infoReel = ItemManager:Get(self.listReelId[index][1])
	self.infoLowerReel = ItemManager:GetLowerScrollItem(self.infoReel)

	self:UpdateReelSelect(hideIdx)
	self:UpdateWillUseSuit(true)
	self:UpdateTree()
	self:InitSSRReelList()
end

function DlgEquipDevelopSynthetize:UpdateSynthetizeSSRPanel(index)
	self.ssrCurReelIdx[index] = not self.ssrCurReelIdx[index]

	if self.ssrCurReelIdx[index] then
		self.selectedSSRNum = self.selectedSSRNum + self.SSRUIScrollTool:GetItem(index).info:GetCurResNum()
	else
		self.selectedSSRNum = self.selectedSSRNum - self.SSRUIScrollTool:GetItem(index).info:GetCurResNum()
	end

	self.ssrRecordReelIdx = index
	self.ssrInfoReel = ItemManager:Get(self.listSSRReelId[index][1])
	self.ssrInfoLowerRell = ItemManager:GetLowerScrollItem(self.ssrInfoReel)

	self:UpdateSSRReelSelect(hideIdx)
	self:UpdateSSRWillUseSuit(true)
end

function DlgEquipDevelopSynthetize:UpdateNetData()
	self:UpdatePanel()
end

function DlgEquipDevelopSynthetize:GetEnchantRank(slotIndex, reelId, attr)
	if not attr then
		return 0, 1
	end

	local ScrollData = require("luaData/ScrollData")
	local attrPool = {}
	local randomAttr = {}

	for _, v in pairs(ScrollData) do
		if v.Slot == slotIndex and v.ScrollID == reelId then
			attrPool = v.ValueList

			break
		end
	end

	for _, v in ipairs(attrPool) do
		if attr.type == v[2] and attr.param == v[3] then
			randomAttr = v

			break
		end
	end

	local min = randomAttr[#randomAttr - 1]
	local max = randomAttr[#randomAttr]
	local rate = attr.value / max
	local rank = 1
	local average = max / 5

	for i = 1, 5 do
		if attr.value <= i * average then
			rank = i

			break
		end
	end

	return rate, rank
end

function DlgEquipDevelopSynthetize:UpdateReelSelect(hideIdx, updateNum)
	if self.UIScrollTool and self.UIScrollTool.ItemRoot2ItemDict then
		for _, v in self.UIScrollTool.ItemRoot2ItemDict:Enumerator() do
			if v.Item.Index == self.curReelIdx then
				v.Item:UpdateSelectState(true)
			end

			if v.Item.Index == hideIdx then
				v.Item:UpdateSelectState(false)

				if updateNum then
					v.Item:UpdateHoldNum()
				end
			end
		end
	end

	if self.infoReel then
		self.cellItem:UpdateNoNumType(self.infoReel)
		self.cellItem:ResetItemIcon(self.infoReel.data.Icon)
		self.toItem:UpdateNoNumType(self.infoReel)
		self.toItem:ResetItemIcon(self.infoReel.data.Icon)
		self.fromItem:UpdateNoNumType(self.infoLowerReel)
		self.fromItem:ResetItemIcon(self.infoLowerReel.data.Icon)

		self.cellItemText.text, self.cellItemDes.text = self.infoReel:GetNameAndDesc()
		self.cellItemPrice.text = reelPrice[self.infoLowerReel.data.Quality]
	end
end

function DlgEquipDevelopSynthetize:UpdateSSRReelSelect(updateNum)
	if self.SSRUIScrollTool and self.SSRUIScrollTool.ItemRoot2ItemDict then
		local treatedList = {}
		local noMoreNeeded = self.buyNum * 20 <= self.selectedSSRNum

		for _, v in self.SSRUIScrollTool.ItemRoot2ItemDict:Enumerator() do
			self.ssrCurReelGrayed[v.Item.Index] = noMoreNeeded
			treatedList[v.Item.Index] = true

			if self.ssrCurReelIdx[v.Item.Index] then
				self.ssrCurReelGrayed[v.Item.Index] = false

				v.Item:SetGray(false)
				v.Item:UpdateSelectState(true)
			else
				v.Item:SetGray(noMoreNeeded)
				v.Item:UpdateSelectState(false)

				if updateNum then
					v.Item:UpdateHoldNum()
				end
			end
		end

		for index, v in pairs(self.listSSRReelId) do
			if not treatedList[index] then
				self.ssrCurReelGrayed[index] = noMoreNeeded
			end
		end
	end
end

function DlgEquipDevelopSynthetize:GetRank(info)
	local qua = info.data.Quality

	if qua == 1 then
		return "R"
	elseif qua == 2 then
		return "SR"
	elseif qua == 3 then
		return "SSR"
	elseif qua == 4 then
		return "UR"
	end

	return "R"
end
