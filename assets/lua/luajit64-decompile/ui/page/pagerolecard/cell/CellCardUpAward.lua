-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Cell/CellCardUpAward.lua

require("UI/Item/UIItemBase")

CellCardUpAward = class("CellCardUpAward", UIItemBase)

function CellCardUpAward:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCardUpAward:Create(vParam)
	CellCardUpAward.base.Create(self, vParam)
end

function CellCardUpAward:OnEnter()
	local g = self.UIRootObject
	local Text = GOUtil.FindChildComponent(g, "Geted", "Text")

	Text.text = Lang(12049)
	self.TxtTitle = GOUtil.FindChildComponent(g, "Text", "Text")
	self.listItem = {}

	for i = 1, 3 do
		self["Cell" .. i] = GOUtil.FindChildGameObject(g, "Group/" .. i)

		local gItem = self["Cell" .. i]
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.GoGeted = self:GetChildGameObject("Geted")
end

function CellCardUpAward:OnLeave()
	if self.listItem then
		for i = 1, 3 do
			self.listItem[i]:OnLeave()
		end

		self.listItem = nil
	end
end

function CellCardUpAward:UpdateData(infoRoleCard, listAward, aType)
	self.infoRoleCard = infoRoleCard
	self.aType = aType
	self.index = listAward.index

	if aType == 1 then
		self.TxtTitle.text = string.format(_("Card_UpTo_Star"), tostring(self.index))
	elseif aType == 2 then
		self.TxtTitle.text = string.format(_("Card_UpTo_Petal"), _("ecNum_" .. self.index))
	end

	local awards = listAward.list

	for i = 1, 3 do
		local gItem = self["Cell" .. i]

		if i <= #awards then
			gItem:SetActive(true)
			self.listItem[i]:UpdateWithNumType(awards[i])
		else
			gItem:SetActive(false)
		end
	end

	local isRec = infoRoleCard:IsGetStarReward(self.index)
	local isCantRec = infoRoleCard.curStarLevel < self.index

	if aType == 2 then
		isRec = infoRoleCard:IsGetPetalReward(self.index)
		isCantRec = infoRoleCard.curPetal < self.index
	end

	self.GoGeted:SetActive(isRec)
end

function CellCardUpAward:OnClickedBtnRec()
	local isCanRec = self.infoRoleCard.curStarLevel >= self.index

	if self.aType == 2 then
		isCanRec = self.infoRoleCard.curPetal >= self.index
	end

	if not isCanRec then
		if self.aType == 1 then
			UIMgr.ShowMsg(_("Msg_Recv_After_Star"))
		else
			UIMgr.ShowMsg(_("Msg_Recv_After_Petal"))
		end

		return
	end

	if self.aType == 1 then
		self:RequestRecvStarAward()
	elseif self.aType == 2 then
		self:RequestRecvPetalAward()
	end
end

function CellCardUpAward:RequestRecvStarAward()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.infoRoleCard:SetGetStarReward(self.index)
			Event.Instance:Fire("UpdateAwardList")
			Event.Instance:Fire("UpdateDotNotify", 1)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestRoleCardStarAward(self.infoRoleCard.id, self.index, wrap_cb)
end

function CellCardUpAward:RequestRecvPetalAward()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.infoRoleCard:SetGetPetalReward(self.index)
			Event.Instance:Fire("UpdateAwardList")
			Event.Instance:Fire("UpdateDotNotify", 3)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestReceivePetalAward(self.infoRoleCard.id, self.index, wrap_cb)
end
