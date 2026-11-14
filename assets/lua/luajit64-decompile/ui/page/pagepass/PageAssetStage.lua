-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/PageAssetStage.lua

require("UI/Page/PagePass/CellCommonStage")
require("UI/Page/PageChapter/DlgStageSweep")

local InfoTeam = require("Info.InfoTeam")

PageAssetStage = class("PageAssetStage", UIPanel)

function PageAssetStage:ctor()
	PageAssetStage.base.ctor(self, "UI/PanelPass/PanelAssetStage")

	self.DlgExitObj = DlgExit()

	self:AddChildPanel(self.DlgExitObj, {
		title = _("eReturn_Gift"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PageAssetStage:PreLoad()
	self:LoadResAsync("UI/PanelPass/CellStage", "PrefabCell", GameObject)
end

function PageAssetStage:OnBack()
	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.asset)
	UIMgr.PopPanel()
end

function PageAssetStage:Purge()
	PageAssetStage.base.Purge(self)
	UITweenUtil.RemoveTween(self.content)
	UITweenUtil.RemoveTween(self.tagGroup.transform)
	self:OnLeave()

	if self.listActive[self.curTagIdx] then
		ChapterRDL.AssetRDL.DealSubNew(self.listActive[self.curTagIdx].ID)
	end
end

function PageAssetStage:OnLeave()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end
end

function PageAssetStage:OnRegisterEvent()
	self:AddClick(self.btn_add, self.OnClickedAddLeftNum)
	Event.Instance:Add(EventEnum.EnterStage, self.DealWithEnterStage, self)
	Event.Instance:Add(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Add("UpdateStageNum", self.UpdateStagePlayNum, self)
end

function PageAssetStage:OnUnRegisterEvent()
	self:RemoveClick(self.btn_add, self.OnClickedAddLeftNum)
	Event.Instance:Remove(EventEnum.EnterStage, self.DealWithEnterStage, self)
	Event.Instance:Remove(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Remove("UpdateStageNum", self.UpdateStagePlayNum, self)

	if self.listTag then
		for i = 1, #self.listTag do
			self:RemoveClick(self["BtnTag" .. i], self.OnClickedBtnTag)
			self:RemoveClick(self["GoNotAct" .. i], self.OnClickedNotAct)
		end
	end
end

function PageAssetStage:UpdateStagePlayNum()
	local isOpen = self.infoActive:TodayIsOpen()

	if not isOpen then
		-- block empty
	end

	self:UpdatePanel()
end

function PageAssetStage:OnEnter(vParam)
	local titleList = {
		"eReturn_Material",
		"eReturn_EquMat",
		"eReturn_GiftStage"
	}
	local idx = vParam.branchId
	local strTitle = _(titleList[idx])

	self.DlgExitObj:SetTextExit(strTitle)
	self:SetSafeArea(self:GetChildGameObject("SafeArea"))

	if not GuideMgr:IsGuided(GuideFunctionType.AssetPass) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.AssetPass)
	end

	self.PanelCommon = self:GetChildGameObject("SafeArea/Panel1")
	self.Bg = self:GetChildGameObject("Bg")
	self.BgImg = self:GetChildComponent("Bg", "RawImage")
	self.ImageTitle = self:GetChildComponent("SafeArea/Panel1/Img_des/Image", "Image")
	self.AssetBg = self:GetChildComponent("SafeArea/Panel1/AssetBg", "Image")
	self.AssetIcon = self:GetChildComponent("SafeArea/Panel1/AssetIcon", "Image")
	self.AssetType = self:GetChildComponent("SafeArea/Panel1/AssetType", "Image")
	self.TxtEnd = self:GetChildComponent("SafeArea/Panel1/BgScroll/Tex_time", "Text")
	self.TxtNum = self:GetChildComponent("SafeArea/Panel1/Img_des/Tex_num", "Text")
	self.TxtNumValue = self:GetChildComponent("SafeArea/Panel1/Img_des/Tex_num/Tex_num_value", "Text")
	self.Tex_time = self:GetChildGameObject("SafeArea/Panel1/BgScroll/Tex_time")
	self.Img_des = self:GetChildGameObject("SafeArea/Panel1/Img_des")
	self.btn_add = self:GetChildGameObject("SafeArea/Panel1/Img_des/btn_add")
	self.img_add = self:GetChildComponent("SafeArea/Panel1/Img_des/btn_add", "Image")
	self.TxtChapterName = self:GetChildComponent("SafeArea/Panel1/BgScroll/BgChapter/TxtName", "Text")

	local text_time = GOUtil.GetComponent(self.Tex_time, "Text")

	text_time.text = string.format(Lang(8111005), tostring(InfoGameInst.RefreshTime))

	self:Init(vParam)
end

function PageAssetStage:Init(vParam)
	self.assetPass = vParam.assetPass
	self.assetBranch = vParam.branchId
	ActiveMgr.branchId = vParam.branchId
	self.needItem = vParam.needItem

	self.PanelCommon:SetActive(self.assetBranch ~= 2)

	self.listActive = PassMgr:GetBranchActiveList(self.assetPass, self.assetBranch)
	self.Index = 1

	self:InitTag()
	self:UpdatePanel()
end

function PageAssetStage:InitTag()
	local count = #self.listActive

	self.tagGroup = self:GetChildGameObject("SafeArea/TagGroup")

	local tag = self:GetChildGameObject("SafeArea/Tag")

	self.listTag = {}

	for i = 1, count do
		local go = GOUtil.Instantiate(tag, self.tagGroup)
		local info = ActiveMgr:GetActive(self.listActive[i].ID)
		local txtName1 = GOUtil.FindChildComponent(go, "Button/Text", "Text")
		local txtName2 = GOUtil.FindChildComponent(go, "Select/Text", "Text")
		local txtName3 = GOUtil.FindChildComponent(go, "GoNotAct/Text", "Text")

		txtName1.text = Lang(info.data.Name)
		txtName2.text = Lang(info.data.Name)
		txtName3.text = Lang(info.data.Name)

		local listOpenTime = info:GetOpenDay()
		local txtActTime = GOUtil.FindChildComponent(go, "GoNotAct/TxtActTime", "Text")
		local str = ""

		for i = 1, #listOpenTime do
			str = str .. tostring(listOpenTime[i])

			if i ~= #listOpenTime then
				str = str .. "."
			end
		end

		txtActTime.text = string.format(_("Desc_Open_Week"), str)
		self["GoTag" .. i] = go
		self["BtnTag" .. i] = GOUtil.FindChildGameObject(go, "Button")
		self["SelTag" .. i] = GOUtil.FindChildGameObject(go, "Select")
		self["GoNotAct" .. i] = GOUtil.FindChildGameObject(go, "GoNotAct")

		self:AddClick(self["BtnTag" .. i], self.OnClickedBtnTag)
		self:AddClick(self["GoNotAct" .. i], self.OnClickedNotAct)

		go.name = i

		table.insert(self.listTag, go)

		if i == 1 then
			RedDotSystemMgr.SetUIRedDot(go, "Chapter/Asset/Gold")
		elseif i == 2 then
			RedDotSystemMgr.SetUIRedDot(go, "Chapter/Asset/Exp")
		elseif i == 3 then
			RedDotSystemMgr.SetUIRedDot(go, "Chapter/Asset/Item")
		end
	end

	SetActiveFunc(tag, false)
	UITweenUtil.CommonTweenRight(self.tagGroup.transform, 20, 0.14)
end

function PageAssetStage:UpdatePanel()
	local function fun()
		for i = 1, #self.listActive do
			local activeId = self.listActive[i].ID
			local info = ActiveMgr:GetActive(self.listActive[i].ID)

			if info:TodayIsOpen() then
				self.curTagIdx = i

				break
			end
		end
	end

	if not self.activeId then
		fun()
	else
		local info = ActiveMgr:GetActive(self.activeId)

		if not info:TodayIsOpen() then
			fun()
		end
	end

	if ChapterMgr.resTabIndex > 0 then
		if self.listActive[ChapterMgr.resTabIndex] then
			local info = ActiveMgr:GetActive(self.listActive[ChapterMgr.resTabIndex].ID)

			if info:TodayIsOpen() then
				self.curTagIdx = ChapterMgr.resTabIndex
			end
		end

		ChapterMgr.resTabIndex = 0
	end

	self:UpdateTagPanel()
end

function PageAssetStage:UpdateTagPanel()
	if self.listTag then
		for i = 1, #self.listTag do
			local info = ActiveMgr:GetActive(self.listActive[i].ID)
			local isOpen = info:TodayIsOpen()

			SetActiveFunc(self["GoNotAct" .. i], not isOpen)

			local isSel = i == self.curTagIdx

			SetActiveFunc(self["BtnTag" .. i], not isSel and isOpen)

			if isSel and isOpen then
				ActiveMgr.TabIndex = i
			end

			SetActiveFunc(self["SelTag" .. i], isSel and isOpen)
		end
	end

	self.activeId = self.listActive[self.curTagIdx].ID
	self.infoActive = ActiveMgr:GetActive(self.activeId)

	local chapterId = ActiveMgr:GetActiveChapter(self.activeId)

	self.listStage = ChapterMgr:GetUnLockStageList(chapterId)

	if self.assetBranch ~= 2 then
		self:UpdateCommonAssetPanel()
	end

	ChapterRDL.AssetRDL.DealSubNew(self.infoActive)
end

function PageAssetStage:OnClickedBtnTag(data)
	local go = data.pointerPress.transform.parent
	local index = tonumber(go.name)

	ChapterRDL.AssetRDL.DealSubNew(self.listActive[self.curTagIdx].ID)

	self.curTagIdx = index
	ActiveMgr.TabIndex = index
	self.needItem = nil

	self:UpdateTagPanel()
	UITweenUtil.RemoveTween(self.content)
	UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
end

function PageAssetStage:OnClickedNotAct(data)
	local go = data.pointerPress.transform.parent
	local index = tonumber(go.name)
	local info = ActiveMgr:GetActive(self.listActive[index].ID)
	local listOpenTime = info:GetOpenDay()
	local str = ""

	for i = 1, #listOpenTime do
		str = str .. tostring(listOpenTime[i])

		if i ~= #listOpenTime then
			str = str .. "."
		end
	end

	local desc = string.format(_("Desc_Open_Week"), str)

	UIMgr.ShowMsg(desc)
end

function PageAssetStage:UpdateCommonAssetPanel()
	local info = ActiveMgr:GetActive(self.listActive[self.curTagIdx].ID)
	local chapterId = ActiveMgr:GetActiveChapter(info.id)
	local infoChapter = ChapterMgr:GetChapter(chapterId)

	self.TxtChapterName.text = Lang(infoChapter.data.Title) .. "   " .. Lang(infoChapter.data.Name)

	if info:HaveDailyReward() then
		local info, hignCount = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func15)

		hignNum = hignCount + 1 - infoChapter.pb.highAwardNum
		self:GetChildComponent("SafeArea/Panel1/Img_des/Tex_HighPrize", "Text").text = string.format(_("Desc_High_Prize_Left"), "" .. hignNum)
	else
		self:GetChildComponent("SafeArea/Panel1/Img_des/Tex_HighPrize", "Text").text = string.format(_("Desc_High_Prize_Left"), "0")
	end

	if self.assetBranch == 1 then
		SetActiveFunc(self.Bg, true)
		UIUtil.SetImageSprite(self.AssetBg, "UI/PanelPass/PanelAssetStage/BG_eventtype_frame_0" .. self.curTagIdx, self, true)
		UIUtil.SetImageSprite(self.AssetIcon, "UI/PanelPass/AtlasPanelAssetStage/BG_eventtype_0" .. self.curTagIdx, self, true)
		UIUtil.SetImageSprite(self.AssetType, "UI/PanelPass/AtlasPanelAssetStage/BG_eventtype_0" .. self.curTagIdx .. "a", self)

		local strlist = {
			"Desc_DropGold",
			"Desc_DropExp",
			"Desc_DropStarItem"
		}

		self:GetChildComponent("SafeArea/Panel1/Img_des/Tex_tips", "Text").text = _(strlist[self.curTagIdx])

		UIUtil.SetRawImageTexture(self.BgImg, "Texture/PanelBG/BG_eventtype_main_0" .. self.curTagIdx)

		if self.curTagIdx == 1 then
			self.ImageTitle.color = Color.New(0.9529411764705882, 0.9176470588235294, 0.7803921568627451, 1)
		elseif self.curTagIdx == 2 then
			self.ImageTitle.color = Color.New(0.7333333333333333, 0.8549019607843137, 0.9058823529411765, 1)
		elseif self.curTagIdx == 3 then
			self.ImageTitle.color = Color.New(0.9803921568627451, 0.9568627450980393, 0.8705882352941177, 1)
		end
	else
		SetActiveFunc(self.Bg, false)
		UIUtil.SetImageSprite(self.AssetBg, "UI/PanelPass/PanelAssetStage/BG_eventtype_frame_0" .. self.curTagIdx, self, true)
		UIUtil.SetImageSprite(self.AssetIcon, "UI/PanelPass/AtlasPanelAssetStage/BG_gift_0" .. self.curTagIdx, self)
		UIUtil.SetImageSprite(self.AssetType, "UI/PanelPass/AtlasPanelAssetStage/BG_gift_0" .. self.curTagIdx .. "a", self)

		local strlist = {
			"Desc_DropSweetGift",
			"Desc_DropFoodGift",
			"Desc_DropOrnamentGift"
		}

		self:GetChildComponent("SafeArea/Panel1/Img_des/Tex_tips", "Text").text = _(strlist[self.curTagIdx])
	end

	local scrollArea = self:GetChildGameObject("SafeArea/Panel1/BgScroll/ScrollArea")

	SetActiveFunc(self.TxtNum.gameObject, false)
	SetActiveFunc(self.TxtEnd.gameObject, false)
	self.Img_des:SetActive(true)

	self.TxtEnd.text = string.format(Lang(8111005), tostring(InfoGameInst.RefreshTime))

	SetActiveFunc(self.TxtNum.gameObject, true)
	SetActiveFunc(self.TxtEnd.gameObject, true)

	do
		local singleMaxNum = self.infoActive:GetMaxArgJson(nil, self.curTagIdx)
		local singlePlayNum = ActiveMgr:GetActivePlayNum(self.activeId)

		self.leftNum = singleMaxNum - singlePlayNum
		self.TxtNum.text = _("Desc_Last_Num")
		self.TxtNumValue.text = self.leftNum

		local sumCount, count = self:GetTimes()
		local gray = TenaryOp(sumCount == count, 1, 0)

		DealWithListRef(self, UIUtil.SetImageGray(self.img_add, gray))
	end

	if not self.inited then
		self:InitStage()

		self.inited = true
	else
		self.UIScrollTool:UpdateListData(self.listStage)
	end
end

function PageAssetStage:GetTimes()
	local stage = self.listStage[1]
	local _type = stage and stage.data.ActType or ePassChallengeBuyType.Gold

	return ChapterMgr.GetTimes(_type, ShopManager.MonthPrivilegeFunc.Func20)
end

function PageAssetStage:InitStage()
	local scrollArea = self:GetChildGameObject("SafeArea/Panel1/BgScroll/ScrollArea")

	self.content = self:GetChildComponent("SafeArea/Panel1/BgScroll/ScrollArea/Content", "RectTransform")

	local count = #self.listStage

	local function AddClick(item)
		self:AddClick(GOUtil.FindChildGameObject(item.UIRootObject, "Panel/BtnEnter"), self.OnClickedCell)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCell, CellCommonStage, self, false, AddClick)

	local posY = StageScrollViewPosMgr.GetPosY(eScrollViewPosType.asset)

	if posY ~= 0 then
		self.UIScrollTool.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	end

	UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
end

function PageAssetStage:UpdateCell(item, index)
	local infoStage = self.listStage[index]
	local data = {
		infoStage = infoStage,
		needItem = self.needItem,
		sumLeftNum = self.leftNum
	}

	item:DestroyContent()
	item:UpdateData(data)
end

function PageAssetStage:OnClickedCell(data)
	local go = data.pointerPress.transform.parent.parent.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	self.info = self.listStage[info.Item.Index]

	local posY = 0

	if not self.info:IsNew() then
		posY = self.UIScrollTool.ScrollView.content.anchoredPosition.y
	end

	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.asset, posY)
end

function PageAssetStage:OnClickedAddLeftNum()
	local str = ""

	self.addLeftNumType = self.curTagIdx

	local sumCount, count = self:GetTimes()

	if sumCount <= count then
		UIMgr.ShowMsg(_("Desc_NoBuyTimes"))

		return
	end

	require("UI/Page/PageShop/DlgBuyLeftStageNum")
	UIMgr.AddPanel(DlgBuyLeftStageNum(), {
		addLeftNumType = self.addLeftNumType
	})
end

function PageAssetStage:DealWithEnterStage()
	if not self.infoActive:TodayIsOpen() then
		UIMgr.ShowMsg(_("Desc_Not_Open"))

		return
	end

	ChapterMgr.resTabIndex = self.curTagIdx
end

function PageAssetStage:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.AssetPass)
end
