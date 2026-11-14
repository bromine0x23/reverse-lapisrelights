-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/CellSong.lua

require("UI/Item/UIItemBase")

CellSong = class("CellSong", UIItemBase)

function CellSong:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellSong:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end

function CellSong:OnEnter(vParam)
	local g = self.UIRootObject

	self.Image = GOUtil.FindChildComponent(g, "", "Image")
	self.Name = GOUtil.FindChildComponent(g, "Text", "Text")
	self.Time = GOUtil.FindChildComponent(g, "time", "Text")
	self.Lock = GOUtil.FindChildGameObject(g, "Lock")
	self.AwardBtn = GOUtil.FindChildGameObject(g, "AwardBtn")
	self.AwardIcon = GOUtil.FindChildComponent(g, "AwardBtn/Icon", "Image")
	self.AwardCount = GOUtil.FindChildComponent(g, "AwardBtn/Text", "Text")
	self.AwardImg1 = GOUtil.FindChildComponent(self.AwardBtn, "bg", "Image")
	self.AwardImg2 = GOUtil.FindChildComponent(self.AwardBtn, "Image", "Image")
	self.Animator = GOUtil.FindChildComponent(g, "AwardBtn", "Animator")
end

function CellSong:OnRegisterEvent()
	self:AddListener(self.AwardBtn, self.OnClickGetAward, EventTriggerType.PointerClick)
end

function CellSong:OnUnRegisterEvent()
	self:RemoveListener(self.AwardBtn, self.OnClickGetAward, EventTriggerType.PointerClick)
end

function CellSong:UpdateData(info)
	self.data = info

	UIUtil.SetImageSprite(self.AwardIcon, ItemManager:GetIcon(self.data.Award[1][1]), self.page)

	self.AwardCount.text = "x" .. self.data.Award[1][2]

	UIUtil.SetImageSprite(self.Image, self.data.ImagePath, self.page, false)

	self.Name.text = Lang(info.Name)
	self.Time.text = self:GetTimeStr(info.Length)

	if not ChapterMgr:GetStage(self.data.UnlockStageId):IsPass() then
		self.Lock:SetActive(true)
		self:SetAwardBtn(false)
	else
		local isGetAward = table.contains(CollectionManager.songAwardList, self.data.ID)

		self:SetAwardBtn(not isGetAward)
		self.Lock:SetActive(false)
	end
end

function CellSong:GetTimeStr(second)
	local d, h, m, s = GetTimeFormatBySec(second)

	if s < 10 then
		s = "0" .. s
	end

	if m < 10 then
		m = "0" .. m
	end

	return m .. ":" .. s
end

function CellSong:OnClickGetAward()
	if not self.canGet then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	NetManager:RequestGetCollectionAward(eCollectionAwardType.SONG, {
		self.data.ID
	}, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			table.insert(CollectionManager.songAwardList, self.data.ID)
			Event.Instance:Fire("UpdateRedDot")
			self:SetAwardBtn(false)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function CellSong:SetAwardBtn(canGet)
	if table.contains(CollectionManager.songAwardList, self.data.ID) then
		self.AwardBtn:SetActive(false)

		return
	end

	self.AwardBtn:SetActive(true)

	self.canGet = canGet

	local gray = TenaryOp(canGet, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.AwardImg1, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.AwardImg2, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.AwardIcon, gray))

	if canGet then
		self.Animator:Play("Award_Get", 0, 0)
		GOUtil.SetTextColor(self.AwardCount.gameObject, 193, 115, 158)
	else
		self.Animator:Play("Empty", 0, 0)
		GOUtil.SetTextColor(self.AwardCount.gameObject, 88, 94, 109)
	end
end
