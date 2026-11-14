-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTimeSpace/CellTimeSpaceTask.lua

require("UI/Item/UIItemBase")

CellTimeSpaceTask = class("CellTimeSpaceTask", UIItemBase)

function CellTimeSpaceTask:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTimeSpaceTask:OnEnter(vParam)
	local g = self.UIRootObject

	self:DealWithLocalization(g)

	self.TextFrom = GOUtil.FindChildComponent(g, "Title/Text", "Text")
	self.TextInfo = GOUtil.FindChildComponent(g, "Title/TextInfo", "Text")
	self.TextNum = GOUtil.FindChildComponent(g, "ImageBar/TextNum", "Text")
	self.ButtonGet = GOUtil.FindChildGameObject(g, "ButtonGet")
	self.ButtonGo = GOUtil.FindChildGameObject(g, "ButtonGo")
	self.GoGeted = GOUtil.FindChildGameObject(g, "GoGeted")

	self:AddClick(self.ButtonGet, self.OnClickedGet)
	self:AddClick(self.ButtonGo, self.OnClickedGo)

	self.listItem = {}

	for i = 1, 4 do
		local gItem = GOUtil.FindChildGameObject(g, "ItemGroup/" .. i)
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.ImageFill = GOUtil.FindChildComponent(g, "ImageBar/ImageFill", "Image")
end

function CellTimeSpaceTask:DealWithLocalization(g)
	local txt

	txt = GOUtil.FindChildComponent(g, "ButtonGet/Text", "Text")
	txt.text = _("Desc_Get")
	txt = GOUtil.FindChildComponent(g, "ButtonGo/Text", "Text")
	txt.text = _("UI_Go")
end

function CellTimeSpaceTask:OnLeave()
	if self.listItem then
		for _, v in ipairs(self.listItem) do
			v:OnLeave()
		end

		self.listItem = nil
	end

	self:RemoveClick(self.ButtonGet, self.OnClickedGet)
	self:RemoveClick(self.ButtonGo, self.OnClickedGo)
end

function CellTimeSpaceTask:OnClickedGet()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			Event.Instance:Fire("TaskCompleteUpdate")

			if self.info then
				local characterId = 105

				InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(characterId).data.VocalBank)

				local num = math.random(1, 3)

				if num == 1 then
					InfoSoundEventMgr:Play("VocalCommon10", RoleMgr:GetRole(characterId).data.VocalCommon10)
				elseif num == 2 then
					InfoSoundEventMgr:Play("VocalCommon6", RoleMgr:GetRole(characterId).data.VocalCommon6)
				elseif num == 3 then
					InfoSoundEventMgr:Play("VocalCustomsclearance3", RoleMgr:GetRole(characterId).data.VocalCustomsclearance3)
				end
			end
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	for _, v in ipairs(self.listAward) do
		if v[1] == 514 or v[1] == 515 or v[1] == 519 or v[1] == 562 then
			table.insert(TaskManager.integralList, v)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestTaskChange({
		self.info.pb.id
	}, wrap_cb)
end

function CellTimeSpaceTask:OnClickedGo()
	if self.info and #self.info.data.FromWhere > 0 then
		DlgItemTip.GoToFrom(self.info.data.FromWhere[1])
	end
end

function CellTimeSpaceTask:UpdateData(info)
	self.info = info
	self.TextFrom.text = info:GetName()
	self.TextInfo.text = info:GetDescTitle()

	local curNum = info:GetCurNum()
	local needNum = info:GetNeedNum()

	self.TextNum.text = "<color=#65ccdc>" .. curNum .. "</color>" .. "/" .. needNum
	self.ImageFill.gameObject.transform.localScale = Vector3(TenaryOp(curNum / needNum > 1, 1, curNum / needNum), 1, 1)

	local isComple = info:IsComplete()
	local isGeted = info:IsGetAward()

	SetActiveFunc(self.ButtonGet, not isGeted and isComple)
	SetActiveFunc(self.ButtonGo, not isComple and next(self.info.data.FromWhere) ~= nil)
	SetActiveFunc(self.GoGeted, isGeted)

	self.listAward = info.data.Reward

	for i = 1, 4 do
		local item = self.listItem[i]
		local listAward = info.data.Reward[i]

		if listAward then
			local infoItem = ItemManager:GetValueItem(listAward[1], listAward[2])

			item:UpdateWithNumType(infoItem)
			SetActiveFunc(item.UIRootObject, true)
		else
			SetActiveFunc(item.UIRootObject, false)
		end
	end
end
