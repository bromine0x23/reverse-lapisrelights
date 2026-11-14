-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageChapter/DlgGetSweepAward.lua

require("UI/Item/CellItem")
require("UI/Dlg/Common/DlgItemOverRemind")

DlgGetSweepAward = class("DlgGetSweepAward", UIPanel)

function DlgGetSweepAward:ctor()
	self.callback = nil
	self.UIPrefabPath = "UI/PageChapter/DlgGetSweepAward"
end

function DlgGetSweepAward:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function DlgGetSweepAward:Purge()
	DlgGetSweepAward.base.Purge(self)
	self:OnLeave()
	ResourceMgr.Unload(self.PrefabCellItem)

	self.PrefabCellItem = nil
end

function DlgGetSweepAward:OnLeave()
	self.Button = nil

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end

	if self.listItem and #self.listItem > 0 then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	InfoSoundEventMgr:OnBack()
end

function DlgGetSweepAward:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClickedButton)
end

function DlgGetSweepAward:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClickedButton)
end

function DlgGetSweepAward:DealWithLocalization(vParam)
	local Text

	Text = self:GetChildComponent("Panel/BgTitle/Text", "Text")

	if vParam and vParam.title then
		Text.text = vParam.title
	else
		Text.text = _("PageChapter_Award")
	end

	Text = self:GetChildComponent("Panel/Button/Text", "Text")
	Text.text = _("UI_OK")
	Text = self:GetChildComponent("Panel/Player/TextLv", "Text")
	Text.text = Lang(96001)
	Text = self:GetChildComponent("Panel/ScrollArea2/Viewport/Content/Tag1/Text", "Text")
	Text.text = Lang(12417)
	Text = self:GetChildComponent("Panel/ScrollArea2/Viewport/Content/Tag2/Text", "Text")
	Text.text = _("Drop_Award_Extra")
end

function DlgGetSweepAward:OnEnter(vParam)
	SoundMgr.PostEvent(PATH_SFX_UI_RECEIVE_AWARD, self.UIRootObject)
	self:DealWithLocalization(vParam)

	local list = {}

	if vParam and vParam.list then
		list = vParam.list
	end

	local listExtra = {}

	if vParam and vParam.listExtra then
		listExtra = vParam.listExtra
	end

	local listHigh = {}

	if vParam and vParam.listHigh then
		listHigh = vParam.listHigh
	end

	local listActiveAward = {}

	if vParam and vParam.listActiveAward then
		listActiveAward = vParam.listActiveAward
	end

	if vParam and vParam.callback then
		self.callback = vParam.callback
	end

	self.ExpBar = self:GetChildComponent("Panel/Player/GoBar/ImgBar", "Image")
	self.Level = self:GetChildComponent("Panel/Player/TxtValue", "Text")

	local curExp = PlayerInst.InfoPlayer.curExp
	local nextExp = PlayerInst.InfoPlayer.nextExp

	self.ExpBar.fillAmount = curExp / nextExp
	self.Level.text = PlayerInst:GetCurLv()
	self.Button = self:GetChildGameObject("Panel/Button")
	self.Panel = self:GetChildGameObject("Panel")

	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea2/Viewport/Content/ScrollArea1")
	local ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")

	ScrollView.horizontal = true
	ScrollView.content = self:GetChildComponent("Panel/ScrollArea2/Viewport/Content/ScrollArea1/Content", "Transform")

	local listCombine = {}

	for i = 1, #list do
		local s = list[i]

		if listCombine[s.id] == nil then
			listCombine[s.id] = s
		else
			listCombine[s.id].num = listCombine[s.id].num + s.num
		end
	end

	local listCombine2 = {}

	for i = 1, #listHigh do
		local s = listHigh[i]

		if listCombine2[s.id] == nil then
			listCombine2[s.id] = s
		else
			listCombine2[s.id].num = listCombine2[s.id].num + s.num
		end
	end

	local listCombine3 = {}

	for i = 1, #listActiveAward do
		local s = listActiveAward[i]

		if listCombine3[s.id] == nil then
			listCombine3[s.id] = s
		else
			listCombine3[s.id].num = listCombine3[s.id].num + s.num
		end
	end

	self.listItem = {}

	local i = 1

	for _, s in pairs(listCombine) do
		local infoItem = SetterData.GetItemFromAsset(s)

		if infoItem ~= nil then
			local item = CellItem(self.PrefabCellItem, ScrollView.content.gameObject, self)

			item:Create()
			item:UpdateData(i, infoItem, true)

			local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

			scrollviewContent.scrollView = ScrollView

			table.insert(self.listItem, item)

			i = i + 1
		end
	end

	for _, s in pairs(listCombine2) do
		local infoItem = SetterData.GetItemFromAsset(s)

		if infoItem ~= nil then
			local item = CellItem(self.PrefabCellItem, ScrollView.content.gameObject, self)

			item:Create()
			item:UpdateData(i, infoItem, true)
			item:SetHigh(true)

			local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

			scrollviewContent.scrollView = ScrollView

			table.insert(self.listItem, item)

			i = i + 1
		end
	end

	for _, s in pairs(listCombine3) do
		local infoItem = SetterData.GetItemFromAsset(s)

		if infoItem ~= nil then
			local item = CellItem(self.PrefabCellItem, ScrollView.content.gameObject, self)

			item:Create()
			item:UpdateData(i, infoItem, true)
			item:SetActiveAward(true)

			local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

			scrollviewContent.scrollView = ScrollView

			table.insert(self.listItem, item)

			i = i + 1
		end
	end

	GOUtil.SetRectTransformSizeDelta(self.Panel, 1254, 486)

	if #listExtra > 0 then
		GOUtil.SetRectTransformSizeDelta(self.Panel, 1254, 700)

		local ScrollArea = self:GetChildGameObject("Panel/ScrollArea2/Viewport/Content/ScrollArea2")

		SetActiveFunc(ScrollArea, true)
		SetActiveFunc(self:GetChildGameObject("Panel/ScrollArea2/Viewport/Content/Tag2"), true)

		local ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")

		ScrollView.horizontal = true
		ScrollView.content = self:GetChildComponent("Panel/ScrollArea2/Viewport/Content/ScrollArea2/Content", "Transform")

		local listCombine = {}

		for i = 1, #listExtra do
			local s = listExtra[i]

			if listCombine[s.id] == nil then
				listCombine[s.id] = s
			else
				listCombine[s.id].num = listCombine[s.id].num + s.num
			end
		end

		local i = 1

		for _, s in pairs(listCombine) do
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem ~= nil then
				local item = CellItem(self.PrefabCellItem, ScrollView.content.gameObject, self)

				item:Create()
				item:UpdateData(i, infoItem, true)
				item:SetExtra(true)

				local scrollviewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

				scrollviewContent.scrollView = ScrollView

				table.insert(self.listItem, item)

				i = i + 1
			end
		end
	end

	local num = math.random(1, 5)

	if vParam.listRoleId and vParam.listRoleId[num] > 0 then
		local infoCRole = RoleMgr:GetRole(vParam.listRoleId[num])

		InfoSoundEventMgr:LoadBank(infoCRole.data.VocalBank)
		InfoSoundEventMgr:Play("VocalCustomsclearance", infoCRole.data.VocalCustomsclearance)
	end

	self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.1, function(...)
		ScrollView:SetContentPosImmediate(Vector2.New(30 * i, 0))
	end, {
		1
	})
end

function DlgGetSweepAward:OnClickedButton(...)
	self:Close()

	local function wrap_cb()
		if self.callback then
			self.callback()

			self.callback = nil
		end
	end

	if SetterData.haveOverItem then
		SetterData.haveOverItem = false

		UIMgr.ShowMsg(_("Msg_OverItem_Common"))
		wrap_cb()
	else
		wrap_cb()
	end
end

function DlgGetSweepAward.GetInstance()
	DlgGetSweepAward.Instance = DlgGetSweepAward.Instance or DlgGetSweepAward()

	return DlgGetSweepAward.Instance
end
