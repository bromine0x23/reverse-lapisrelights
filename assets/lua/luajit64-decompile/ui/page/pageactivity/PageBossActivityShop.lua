-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/PageBossActivityShop.lua

require("UI/Page/PageActivity/CellPoolTab")
require("UI/Item/CellItem")
require("UI/Page/PageCardShop/DlgDrawCard")
require("UI/Dlg/Common/DlgGetAward")

PageBossActivityShop = class("PageBossActivityShop", UIPanel)

function PageBossActivityShop:ctor()
	self.UIPrefabPath = "UI/PanelActivity/PanelBossActivityShop"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_ActPool"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})

	self.DlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.DlgAssetsInfo)
end

function PageBossActivityShop:OnBack()
	if PageBossActivity.GetCurBossActive() == nil then
		PageBossActivity.EndActiveBackMain()
	else
		UIMgr.PopPanel({})
	end
end

function PageBossActivityShop:PreLoad()
	self:LoadResAsync("UI/PanelActivity/CellPoolTab", "PrefabCellPoolTab")
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
	self:LoadResAsync("UI/PanelActivity/FX_PanelBossActivityShop_AnimGlow", "PrefabAnim")
	self:LoadResAsync("Actors/Avatars/PROP/BG_Prop_20/Eff_BG_Prop_20_Glow", "PrefabEffect")
end

function PageBossActivityShop:Purge()
	ResourceMgr.Unload(self.PrefabCellPoolTab)
	ResourceMgr.Unload(self.PrefabCellItem)
	ResourceMgr.Unload(self.PrefabProp)
	ResourceMgr.Unload(self.PrefabAnim)
	ResourceMgr.Unload(self.PrefabEffect)

	if self.UITabScrollTool then
		self.UITabScrollTool:Purge()
	end

	self.UITabScrollTool = nil

	if self.UICellScrollTool then
		self.UICellScrollTool:Purge()
	end

	self.UICellScrollTool = nil

	if self.PropPos then
		GameObject.Destroy(self.PropPos)
	end

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)
	end

	if self.timer1 then
		TimerMgr.RemoveTimer(self.timer1)
	end

	if self.motionFactory then
		self.motionFactory:Purge()
	end

	PageBossActivityShop.base.Purge(self)
end

function PageBossActivityShop:OnRegisterEvent()
	self:AddClick(self.ButtonOne, self.OnClickedButtonOne)
	self:AddClick(self.ButtonTen, self.OnClickedButtonTen)
	self:AddClick(self.ButtonOpenNewPool, self.OnClickedOpenNewPool)
	self:AddClick(self.Setting, self.OnClickedSetting)
	Event.Instance:Add("ClickPoolTab", self.OnClickPoolTab, self)
	Event.Instance:Add("UpdateCountSetting", self.OnSetDrawCount, self)
end

function PageBossActivityShop:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonOne, self.OnClickedButtonOne)
	self:RemoveClick(self.ButtonTen, self.OnClickedButtonTen)
	self:RemoveClick(self.ButtonOpenNewPool, self.OnClickedOpenNewPool)
	self:RemoveClick(self.Setting, self.OnClickedSetting)
	Event.Instance:Remove("ClickPoolTab", self.OnClickPoolTab, self)
	Event.Instance:Remove("UpdateCountSetting", self.OnSetDrawCount, self)
end

function PageBossActivityShop:OnEnter(vParam)
	self.activeId = vParam.activeId

	if not GuideMgr:IsGuided(GuideFunctionType.GiftBag) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.GiftBag)
	end

	self.listPool = ActiveCardPoolMgr:GetAll(self.activeId)
	self.ButtonOne = self:GetChildGameObject("Main/ButtonOne")
	self.ImgBtnOne = GOUtil.GetComponent(self.ButtonOne, "Image")
	self.ButtonOneDot = self:GetChildGameObject("Main/ButtonOne/Dot")

	self.ButtonOneDot:SetActive(ChapterMgr:HaveBossActivityShopDot(1, self.activeId))

	self.ButtonTen = self:GetChildGameObject("Main/ButtonTen")
	self.ImgBtnTen = GOUtil.GetComponent(self.ButtonTen, "Image")
	self.ButtonTenDot = self:GetChildGameObject("Main/ButtonTen/Dot")

	self.ButtonTenDot:SetActive(ChapterMgr:HaveBossActivityShopDot(1, self.activeId))

	self.ButtonOpenNewPool = self:GetChildGameObject("Main/ButtonOpenNewPool")
	self.ImageDrawIcon1 = self:GetChildComponent("Main/ButtonOne/ImageIcon", "Image")
	self.ImageDrawIcon2 = self:GetChildComponent("Main/ButtonTen/ImageIcon", "Image")
	self.TextDraw1 = self:GetChildComponent("Main/ButtonOne/Text", "Text")
	self.TextDraw2 = self:GetChildComponent("Main/ButtonTen/Text", "Text")
	self.TextNum1 = self:GetChildComponent("Main/ButtonOne/TextNum", "Text")
	self.TextNum2 = self:GetChildComponent("Main/ButtonTen/TextNum", "Text")
	self.OpenNewTip = self:GetChildGameObject("Main/OpenNewTip")
	self.DrawMask = self:GetChildGameObject("Main/DrawMask")
	self.OpenNewTiptext = self:GetChildComponent("Main/OpenNewTip/Text", "Text")
	self.PropPos = GOUtil.NewGameObject("PropPos", nil)
	self.renderCtrl = self:GetChildComponent("Main/RawImage", "UI3DRenderControl")
	self.RawImage = self:GetChildComponent("Main/RawImage", "RawImage")
	self.Lock = self:GetChildGameObject("Main/Lock")
	self.LockText = self:GetChildComponent("Main/Lock/Text", "Text")
	self.ItemMask = self:GetChildGameObject("Main/Image/ItemMask")
	self.Setting = self:GetChildGameObject("Main/Setting")

	local localText = self:GetChildComponent("Main/ButtonOpenNewPool/Text", "Text")

	localText.text = _("Activate_Boxgacha")
	self.selectIndex = 1

	for i = 1, #self.listPool do
		if self.listPool[i].status == 2 and not self.listPool[i]:IsDrawOut() then
			self.selectIndex = i
		end
	end

	if self.selectIndex > #self.listPool then
		self.selectIndex = #self.listPool
	end

	self:CreatProp()
	self:InitTabScrollView()
	self:InitCellItemScrollView()
	self:UpdateTab(true)
	self:UpdateCountSetting()
	self:UpdateCellItems()
	self:UpdateCost()
end

function PageBossActivityShop:InitTabScrollView()
	local ScrollArea = self:GetChildGameObject("Main/ScrollArea2")
	local content = self:GetChildComponent("Main/ScrollArea2/Content", "Transform")
	local count = #self.listPool

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		local info = self.listPool[index]

		item:UpdateData(info, self.selectIndex)
	end

	self.UITabScrollTool = UIScrollTool()

	self.UITabScrollTool:InitList(ScrollArea, content, count, self.PrefabCellPoolTab, CellPoolTab, self, false, addClick, updateTab)
end

function PageBossActivityShop:InitCellItemScrollView()
	local ScrollArea = self:GetChildGameObject("Main/Image/ScrollArea")
	local content = self:GetChildComponent("Main/Image/ScrollArea/Content", "Transform")
	local count = 0

	local function addClick(...)
		return
	end

	local function updateData(item, index)
		local poolInfo = self.listPool[self.selectIndex]
		local itemInfo = self.listCellItemData[index]

		item:UpdateWithNumType(itemInfo)

		local num = itemInfo.maxBuyNum - itemInfo.curBuyNum

		item:SetLeftCount(itemInfo.catelog == 2, num, poolInfo.data.NoLimit ~= 1)
		GOUtil.SetTransformLocalScale(item.UIRootObject, 1.08)
		item:SetShowImgParty(index % 5 == 1)
	end

	self.UICellScrollTool = UIScrollTool()

	self.UICellScrollTool:InitList(ScrollArea, content, count, self.PrefabCellItem, CellItem, self, false, addClick, updateData)
end

function PageBossActivityShop:UpdateTab(ismask)
	local info = self.listPool[self.selectIndex]
	local curNum = 0
	local maxNum = 0
	local maxTotalNum = 0
	local curTotalNum = 0

	for i = 1, #info.listItem do
		local data = info:GetPoolNum(i)

		if i == ActiveCardPoolMgr.catelog.rare then
			maxNum = maxNum + data.maxBuyNum
			curNum = curNum + data.curBuyNum
		end

		maxTotalNum = maxTotalNum + data.maxBuyNum
		curTotalNum = curTotalNum + data.curBuyNum
	end

	curNum = maxNum - curNum
	self.curNum = curNum
	self.leftNum = maxTotalNum - curTotalNum

	if info.data.NoLimit == 1 then
		self.leftNum = -1
	end

	if self.selectIndex > 1 then
		self.ButtonOne:SetActive(info.status == 2)
		self.ButtonTen:SetActive(info.status == 2)
		self.Setting:SetActive(info.status == 2)

		if self.propIsInit then
			self.CanDrawEffect:SetActive(info.status == 2)
		end

		self.ButtonOpenNewPool:SetActive(info:IsCanOpen())
		self.OpenNewTip:SetActive(info:IsCanOpen())

		self.OpenNewTiptext.text = _("Activate_OpenTis")

		self.Lock:SetActive(info:IsLock())
		self.ItemMask:SetActive(info.status ~= 2)

		self.LockText.text = _("Active_Lock")
		self.RawImage.color = TenaryOp(info.status == 2, Color.New(1, 1, 1, 1), getColorFromString("8C8C8C"))
	else
		self.ButtonOne:SetActive(true)
		self.ButtonTen:SetActive(true)
		self.Setting:SetActive(true)
		self.ItemMask:SetActive(false)
		self.ButtonOpenNewPool:SetActive(false)
		self.Lock:SetActive(false)

		if self.propIsInit then
			self.CanDrawEffect:SetActive(true)
		end

		self.OpenNewTip:SetActive(false)

		self.RawImage.color = Color.New(1, 1, 1, 1)
	end
end

function PageBossActivityShop:UpdateCellItems(isKeep)
	self.listCellItemData = {}

	local info = self.listPool[self.selectIndex]
	local listNormal = info.listItem[1]
	local list = info.listItem[2]

	for i = 1, #list do
		table.insert(self.listCellItemData, list[i])
	end

	for i = 1, #listNormal do
		table.insert(self.listCellItemData, listNormal[i])
	end

	if isKeep then
		self.UICellScrollTool:UpdateListDataKeepPos(self.listCellItemData)
	else
		self.UICellScrollTool:UpdateListData(self.listCellItemData)
	end
end

function PageBossActivityShop:UpdateCost()
	local info = self.listPool[self.selectIndex]
	local itemId = info.data.OneCost[1]
	local itemNum = info.data.OneCost[2]
	local pathIcon = ItemManager:GetIcon(itemId)

	if self.DlgAssetsInfo then
		local assetIds = {}

		assetIds[1] = info.data.OneCost[1]
		assetIds[2] = ItemManager:GetItemByType("P_DIAMOND").id
		assetIds[3] = ItemManager:GetItemByType("P_GOLD").id

		self.DlgAssetsInfo:ResetByList(assetIds)
	end

	UIUtil.SetImageOverrideSprite(self.ImageDrawIcon1, pathIcon, self)
	UIUtil.SetImageOverrideSprite(self.ImageDrawIcon2, pathIcon, self)
	self.ButtonOneDot:SetActive(ChapterMgr:HaveBossActivityShopDot(1, self.activeId))
	self.ButtonTenDot:SetActive(ChapterMgr:HaveBossActivityShopDot(1, self.activeId))

	local num = self.countSetting

	if self.leftNum < self.countSetting and self.leftNum > 0 and info.data.NoLimit ~= 1 then
		num = self.leftNum
	end

	local curItemCount = ItemManager:GetItemCount(itemId)
	local canDrawTimes = math.floor(curItemCount / itemNum)

	if canDrawTimes < num and canDrawTimes > 0 then
		num = canDrawTimes
		self.leftNum = canDrawTimes

		if info.data.NoLimit == 1 then
			self.leftNum = -1
		end
	end

	self.TextDraw1.text = string.format(_("Boxgacha_Number"), 1)
	self.TextDraw2.text = string.format(_("Boxgacha_Number"), num)
	self.TextNum1.text = itemNum
	self.TextNum2.text = num * itemNum
	self.realNum = num * itemNum

	local gray = TenaryOp(self.leftNum <= 0 and info.data.NoLimit ~= 1 or curItemCount < itemNum, 1, 0)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnOne, gray))

	gray = TenaryOp(self.leftNum <= 0 and info.data.NoLimit ~= 1 or curItemCount < num * itemNum, 1, 0)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnTen, gray))
end

function PageBossActivityShop:OnClickedButtonOne()
	if self.isTimeEvent then
		return
	end

	self.isJunmp = false

	self:DrawItem(1, self.ButtonOne)
end

function PageBossActivityShop:OnClickedButtonTen()
	if self.isTimeEvent then
		return
	end

	self.isJunmp = false

	if self.leftNum < self.countSetting and self.leftNum > 0 and self.listPool[self.selectIndex].data.NoLimit ~= 1 then
		self:DrawItem(self.leftNum, self.ButtonTen)
	else
		self:DrawItem(self.countSetting > self.realNum and self.realNum or self.countSetting, self.ButtonTen)
	end
end

function PageBossActivityShop:DrawItem(num, button)
	local info = self.listPool[self.selectIndex]

	ActiveCardPoolMgr.infoActiveCardPool = info

	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			for i, v in ipairs(vPBMessage.pool) do
				if v.poolId == self.listPool[self.selectIndex].id then
					if v.status == 3 then
						self.newPoolOpen = true
					elseif v.status == 2 and #vPBMessage.pool > 1 then
						self.newPoolCanOpen = true
					end
				end
			end

			self.DrawMask:SetActive(true)

			local eff = GOUtil.InstantiatePrefab(self.PrefabAnim, button)
			local effImage = GOUtil.FindChildComponent(eff, "FX_PanelBossActivityShop_AnimGlow/ImageIcon", "Image")
			local effAnim = GOUtil.FindChildGameObject(eff, "FX_PanelBossActivityShop_AnimGlow")

			local function Play1()
				if num > 1 then
					self.animator:Play("State 0")
				else
					self.animator:Play("State 1")
				end
			end

			local function PlayEff()
				if vPBMessage.setter then
					for k1, v1 in pairs(info.listItem[2]) do
						for _, v2 in ipairs(vPBMessage.setter) do
							if v1.id == v2.id or v1.data.Type == "I_SOUL" and v1.data.Value == v2.id then
								if num > 1 then
									SetActiveFunc(self.ball3, true)
								else
									SetActiveFunc(self.ball1, true)
								end

								return
							end
						end
					end
				end
			end

			local Play2

			function Play2()
				self.listPool = ActiveCardPoolMgr:GetAll(self.activeId)

				self.UITabScrollTool:UpdateListDataKeepPos(self.listPool)

				local data = ActiveCardPoolMgr.poolListNormal

				function data.callback()
					self:ShowPoolOpenMsg()
					self:UpdateCellItems(true)
					SetActiveFunc(self.ball1, false)
					SetActiveFunc(self.ball2, false)
					SetActiveFunc(self.ball3, false)
					self.animator:Play("Idle")
				end

				if data.listValue > 0 then
					data.goodsItemList = {}

					local listNormal = info.listItem[1]
					local list = info.listItem[2]

					for i = 1, #list do
						table.insert(data.goodsItemList, list[i].id)
					end

					for i = 1, #listNormal do
						table.insert(data.goodsItemList, listNormal[i].id)
					end

					UIMgr.AddPanel(DlgGetAward.GetInstance(), data)
					self:UpdateTab(true)
					self:UpdateCost()
				end

				self.DrawMask:SetActive(false)
				EventListenerMgr.RemoveAnimListenerEventID(effAnim, Play1, self, "Play1")

				if num > 1 then
					EventListenerMgr.RemoveAnimListenerEventID(effAnim, PlayEff, self, "PlayEff2")
				else
					EventListenerMgr.RemoveAnimListenerEventID(effAnim, PlayEff, self, "PlayEff1")
				end

				EventListenerMgr.RemoveAnimListenerEventID(effAnim, Play2, self, "Play2")
				Object.Destroy(eff)
			end

			EventListenerMgr.AddAnimListenerEventID(effAnim, Play1, self, "Play1")

			if num > 1 then
				EventListenerMgr.AddAnimListenerEventID(effAnim, PlayEff, self, "PlayEff2")
			else
				EventListenerMgr.AddAnimListenerEventID(effAnim, PlayEff, self, "PlayEff1")
			end

			EventListenerMgr.AddAnimListenerEventID(effAnim, Play2, self, "Play2")
			UIUtil.SetImageSprite(effImage, ItemManager:GetIcon(info.data.OneCost[1]), self)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestDrawActityPool(info.id, num, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageBossActivityShop:OnClickPoolTab(index)
	if index == self.selectIndex then
		return
	end

	local info = self.listPool[index]

	if info:IsDrawOut() then
		UIMgr.ShowMsg(_("Activate_Close_Tip"))

		return
	end

	self.selectIndex = index

	self.UITabScrollTool:UpdateListDataKeepPos(self.listPool)
	self:UpdateTab(true)
	self:UpdateCost()
	self:UpdateCellItems()
end

function PageBossActivityShop:OnClickedOpenNewPool()
	local function callback(index)
		if index == 1 then
			self:OpenNewPool(self.selectIndex)
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_GiftExplain"), _("Activate_Boxgacha_Tips"), callback, _("Button_Yes"), _("Button_No"), false)
end

function PageBossActivityShop:OpenNewPool(index)
	local info = self.listPool[index]
	local poolId = info.id

	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self.listPool[index].status = 2

			if index ~= self.selectIndex then
				self:OnClickPoolTab(index)
			else
				self:UpdateTab(true)
				self.UITabScrollTool:UpdateListDataKeepPos(self.listPool)
			end
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestOpenActityPool(poolId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageBossActivityShop:ShowPoolOpenMsg()
	if self.newPoolCanOpen then
		local function callback(index)
			if index == 1 then
				self:OpenNewPool(self.selectIndex + 1)
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_GiftExplain"), _("Open_Boxgacha_Tips"), callback, _("Button_Yes"), _("Button_No"), false)

		self.newPoolCanOpen = false
	elseif self.newPoolOpen then
		local function callback(index)
			if index == 1 then
				self:OnClickPoolTab(self.selectIndex + 1)
			end
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_GiftExplain"), _("Boxgacha_Off"), callback, _("Button_Yes"), false)

		self.newPoolOpen = false
	end
end

function PageBossActivityShop:CreatProp()
	ResourceMgr.BeginSubmit(function()
		local go = GOUtil.InstantiatePrefabByCenter(self.PrefabProp, self.PropPos)

		GOUtil.SetGameObjectLayer(go, LayerMask.NameToLayer("RT"))
		GOUtil.SetTransformLocalPosition(go, 0, 0, 0)

		self.CanDrawEffect = GOUtil.FindChildGameObject(go, "eff")
		self.ball1 = GOUtil.FindChildGameObject(go, "root/rotatebone/ballbone/Eff_BG_Prop_20_Glow")
		self.ball2 = GOUtil.FindChildGameObject(go, "root/rotatebone/ballbone02/Eff_BG_Prop_20_Glow")
		self.ball3 = GOUtil.FindChildGameObject(go, "root/rotatebone/ballbone03/Eff_BG_Prop_20_Glow")

		self.CanDrawEffect:SetActive(true)

		self.propIsInit = true

		local g = self.PropPos

		GOUtil.SetTransformRotation(g, 0, 145.4, 0)
		GOUtil.SetTransformLocalPosition(g, 10.55, -0.49, 2.78)
		self.renderCtrl:SetCameraPosition(10, 0, 0)

		local strACPath = "Actors/AnimationController/Free@Common"

		self.animator = GOUtil.AddComponent(go, "Animator")
		self.motionFactory = MotionFactory(strACPath)

		self.motionFactory:ApplyOverride("State 1", "Actors/Avatars/PROP/BG_Prop_20/BG_Prop_20ainim_01")
		self.motionFactory:ApplyOverride("State 0", "Actors/Avatars/PROP/BG_Prop_20/BG_Prop_20ainim_02")
		self.motionFactory:CacheSync()

		self.controller = self.motionFactory:Build()
		self.animator.runtimeAnimatorController = self.controller.OverrideAnimatorController
	end)
	ResourceMgr.SubmitCache("Actors/Avatars/PROP/BG_Prop_20/BG_Prop_20_Prefab", self, "PrefabProp", GameObject)
	ResourceMgr.EndSubmit()
end

function PageBossActivityShop:UpdateCountSetting()
	local setting = PersistentStoreUtil.GetInt(PersistentStoreUtil.KEY_ACTIVITY_POOL_COUNT_SETTING)

	if setting == 0 then
		PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_ACTIVITY_POOL_COUNT_SETTING, 1)

		setting = 1
	end

	local table = {
		10,
		50,
		100
	}

	self.countSetting = table[setting]
end

function PageBossActivityShop:OnSetDrawCount()
	self:UpdateCountSetting()
	self:UpdateCost()
end

function PageBossActivityShop:OnClickedSetting()
	require("UI.Page.PageActivity.DlgBossActivityShopSetting")
	UIMgr.AddPanel(DlgBossActivityShopSetting())
end

function PageBossActivityShop:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.GiftBag)
end

function PageBossActivityShop:OnBackAndroid()
	if self.DrawMask and GOUtil.IsActiveSelf(self.DrawMask) then
		return true
	end

	return false
end
