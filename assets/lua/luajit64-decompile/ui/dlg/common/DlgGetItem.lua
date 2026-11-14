-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgGetItem.lua

require("UI/Dlg/DlgBase")

DlgGetItem = class("DlgGetItem", DlgBase)

function DlgGetItem:Cache()
	self:SubmitUIPrefabCacheLua("UI/Common/DlgGetItem")
	MxResMgr.Instance:SubmitCacheLua("UI/Item/ItemItemIcon", self, "PrefabItemItemIcon")
	MxResMgr.Instance:SubmitCacheLua("UI/Common/ItemIconCard", self, "PrefabItemIconCard")
end

function DlgGetItem:Purge()
	self.PrefabItemItemIcon = nil
	self.PrefabItemIconCard = nil

	DlgGetItem.base.Purge(self)
end

function DlgGetItem:Close(tParam)
	DlgGetItem.base.Close(self, tParam)
	ClearDlgMemory(DlgGetItem.Instance)

	DlgGetItem.Instance = nil
end

function DlgGetItem:OnEnter(vParam)
	local audioPlayer = AudioPlayer({
		TakeReward = PATH_AUDIO_SE .. "SE053"
	})

	audioPlayer:Play("TakeReward")

	self.showReputationId = 0
	self.Img_Click = self:GetChildGameObject("Img_Click")
	self.Btn_Ok = self:GetChildComponent("TweenRoot/Img_Bottom/Btn_Ok", "Button")
	self.Txt_UnGetDesc = self:GetChildComponent("TweenRoot/Img_SvBg/Txt_UnGetDesc", "Text")

	local txt_Desc = self:GetChildComponent("TweenRoot/Img_SvBg/Txt_Desc", "Text")

	if vParam.funcDesc ~= nil then
		UIUtility.SetText(txt_Desc, vParam.funcDesc)
	else
		UIUtility.SetComponentVisible(txt_Desc, false)
	end

	local txt_Prompt = self:GetChildComponent("TweenRoot/Txt_Prompt", "Text")

	if vParam.prompt ~= nil then
		UIUtility.SetText(txt_Prompt, vParam.prompt)
		UIUtility.SetComponentVisible(self.Txt_UnGetDesc, false)
	else
		UIUtility.SetComponentVisible(txt_Prompt, false)

		if vParam.setter ~= nil then
			self:ShowRewardsBySetter(vParam.setter)
		else
			self:ShowRewards(vParam.pbItems)
		end
	end

	self:IsShowReputationEff(vParam)
end

function DlgGetItem:IsShowReputationEff(vParam)
	if vParam.setter ~= nil then
		print("error ..................")
	elseif vParam.pbItems ~= nil then
		for i, v in ipairs(vParam.pbItems) do
			if v.asset == protocol_pb.REPUTATION then
				self.showReputationId = v.id

				return
			end
		end
	end
end

function DlgGetItem:OnLeave()
	self.Img_Click = nil
	self.Btn_Ok = nil
	self.Txt_UnGetDesc = nil
end

function DlgGetItem:OnRegisterEventForInstruction()
	self:OnRegisterEvent()
end

function DlgGetItem:OnRegisterEvent()
	self:AutoRegistClick(self.Btn_Ok.gameObject, self.OnClose)
	self:AutoRegistClick(self.Img_Click, self.OnClose)
end

function DlgGetItem:OnUnRegisterEvent()
	return
end

function DlgGetItem:OnClose()
	self:Close()
	InstructionMgr:Process(InstructionType.GetMainTaskItem, self)

	if self.showReputationId ~= 0 then
		local data = DataManager.Instance:GetRecord_Lua("Reputation", self.showReputationId)

		if data ~= nil then
			local vParam = {}

			vParam.reputationData = data

			CreateDlgInScene(DlgGetReputation(), vParam)
		end
	end
end

function DlgGetItem:ShowRewards(pbItems)
	if pbItems == nil or type(pbItems) ~= "table" or #pbItems == 0 then
		UIUtility.SetComponentVisible(self.Txt_UnGetDesc, true)
		UIUtility.SetText(self.Txt_UnGetDesc, Localization.Get("DESC_UnGetItem"))

		return
	end

	UIUtility.SetComponentVisible(self.Txt_UnGetDesc, false)

	local svTrans = self:GetChildComponent("TweenRoot/Img_SvBg/Img_Scroll", "Transform")
	local sv = UIUtility.GetUIScrollView(svTrans, false, true)

	sv:SetDrggingValidity(true)

	local itemIcon
	local itemRoots = {}

	for i, v in ipairs(pbItems) do
		local id = v.id

		if v.asset == protocol_pb.EQUIP and v.extra ~= nil and #v.extra > 0 then
			id = v.extra[1]
		end

		if v.asset ~= protocol_pb.REPUTATION and id > 0 then
			itemIcon = UIItemItemIcon(self.PrefabItemItemIcon, sv.content.gameObject, self)

			itemIcon:Create()
			itemIcon:SetItem(id, v.num, v.asset)
			itemIcon:SetScrollView({
				sv
			})

			local scrollContent = GOUtil.AddMissingComponent(itemIcon.UIRootObject, "UIScrollViewContent")

			scrollContent.scrollView = sv

			table.insert(itemRoots, itemIcon.UIRootObject)
		end
	end

	local turnOverCardsAnim = GOUtil.AddComponent(sv.content.gameObject, "UITurnOverCardsAnimation")

	if sv.content ~= nil then
		local gridLayoutGroup = GOUtil.GetComponent(sv.content.gameObject, "GridLayoutGroup")

		gridLayoutGroup:CalculateLayoutInputHorizontal()
		gridLayoutGroup:CalculateLayoutInputVertical()
		gridLayoutGroup:SetLayoutHorizontal()
		gridLayoutGroup:SetLayoutVertical()
		turnOverCardsAnim:MaskRT(sv.viewRect)
	end

	turnOverCardsAnim:Play(itemRoots, self.PrefabItemIconCard, 0.5, 0.3, function()
		sv:SetDrggingValidity(false)
	end, PATH_FX .. "Eff_UI_Icon_Reward/Eff_UI_Icon_Reward")

	local showNum = #itemRoots

	if showNum > 0 then
		self:SetIconLayoutGroup(sv, showNum)
	end
end

function DlgGetItem:ShowRewardsBySetter(setter)
	UIUtility.SetComponentVisible(self.Txt_UnGetDesc, false)

	local svTrans = self:GetChildComponent("TweenRoot/Img_SvBg/Img_Scroll", "Transform")
	local sv = UIUtility.GetUIScrollView(svTrans, false, true)

	sv:SetDrggingValidity(true)

	local itemIcon
	local itemRoots = {}

	for i, v in ipairs(setter.list) do
		if v.id > 0 then
			itemIcon = UIItemItemIcon(self.PrefabItemItemIcon, sv.content.gameObject, self)

			itemIcon:Create()
			itemIcon:SetItemWithSetter(v)
			table.insert(itemRoots, itemIcon.UIRootObject)
		end
	end

	local turnOverCardsAnim = GOUtil.AddComponent(sv.content.gameObject, "UITurnOverCardsAnimation")

	turnOverCardsAnim:Play(itemRoots, self.PrefabItemIconCard, 0.5, 0.3, function()
		sv:SetDrggingValidity(false)
	end, PATH_FX .. "Eff_UI_Icon_Reward/Eff_UI_Icon_Reward")

	local showNum = #itemRoots

	if showNum > 0 then
		self:SetIconLayoutGroup(sv, showNum)
	end
end

function DlgGetItem:SetIconLayoutGroup(scrollView, iconNum)
	if scrollView == nil or iconNum == nil then
		return
	end

	local layoutGroup = GOUtil.GetComponent(scrollView.content.gameObject, "GridLayoutGroup")

	if layoutGroup == nil then
		return
	end

	if iconNum > 4 then
		layoutGroup.childAlignment = UnityEngine.TextAnchor.UpperLeft
	else
		layoutGroup.childAlignment = UnityEngine.TextAnchor.UpperCenter
	end
end

function DlgGetItem.GetInstance()
	DlgGetItem.Instance = DlgGetItem.Instance or DlgGetItem()

	return DlgGetItem.Instance
end
