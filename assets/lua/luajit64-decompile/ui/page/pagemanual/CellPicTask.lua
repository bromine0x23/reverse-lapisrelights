-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/CellPicTask.lua

require("UI/Item/UIItemBase")
require("UI/Item/CellItem")

CellPicTask = class("CellPicTask", UIItemBase)

function CellPicTask:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.PrefabCellItem = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function CellPicTask:OnLeave()
	self:OnUnRegisterEvent()
end

function CellPicTask:OnEnter(vParam)
	local g = self.UIRootObject

	self.ItemBg = GOUtil.FindChildGameObject(g, "ItemBg")
	self.Active = GOUtil.FindChildGameObject(g, "Active")
	self.Button = GOUtil.FindChildGameObject(g, "Button")
	self.Lock = GOUtil.FindChildGameObject(g, "Lock")
	self.Attr = self:GetChildGameObject("Attr")
	self.TextNum = GOUtil.FindChildComponent(g, "Num", "Text")
	self.TaskName = GOUtil.FindChildComponent(g, "TaskName", "Text")
	self.ImageFill = GOUtil.FindChildComponent(g, "ImageBar/ImageFill", "Image")

	local text = GOUtil.FindChildComponent(g, "Award/Text", "Text")

	text.text = _("Desc_ActiveReward")
	text = GOUtil.FindChildComponent(g, "Button/Text", "Text")
	text.text = _("PicTask_Active")

	for i = 1, 4 do
		self["TxtValue" .. i] = self:GetChildComponent("Attr/" .. i .. "/TxtValue", "Text")
	end

	for i = 1, 4 do
		self:GetChildComponent("Attr/" .. i .. "/Text", "Text").text = _("eAttType_" .. i)
	end

	self.cellItemList = {}

	GOUtil.SetFont(self.TaskName, UIMgr.JPFonts.W5)
end

function CellPicTask:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClicked)
	self:AddClick(self.UIRootObject, self.OnClickedRoot)
end

function CellPicTask:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClicked)
	self:RemoveClick(self.UIRootObject, self.OnClickedRoot)
end

function CellPicTask:OnClicked()
	if not self.info:IsGetAward() and CollectionManager:CheckPreTaskActive(self.info.data.ID) then
		require("UI/Page/PageManual/DlgUnlockTask")
		UIMgr.AddPanel(DlgUnlockTask(), {
			info = self.info
		})
	end
end

function CellPicTask:OnClickedRoot()
	if not self.info:IsGetAward() and not CollectionManager:CheckPreTaskActive(self.info.data.ID) then
		UIMgr.ShowMsg(_("TipsNoFinish"))
	end
end

function CellPicTask:UpdateData(info)
	self.info = info

	if info:IsGetAward() then
		self.Active:SetActive(true)
		self.Button:SetActive(false)
		self.Lock:SetActive(false)
	elseif CollectionManager:CheckPreTaskActive(info.data.ID) then
		self.Active:SetActive(false)
		self.Button:SetActive(true)
		self.Lock:SetActive(false)
	else
		self.Active:SetActive(false)
		self.Button:SetActive(false)
		self.Lock:SetActive(true)
	end

	self:UpdateProgress(info.data.ID)

	local itemList = info.data.Reward
	local skillAttr

	for i = #itemList, 1, -1 do
		if itemList[i][1] == 2 then
			local infoTalent = TalentManager:Get(itemList[i][2])

			skillAttr = infoTalent.data.Argus1[1]
		end
	end

	if not skillAttr then
		self.ItemBg:SetActive(true)
		self.Attr:SetActive(false)

		if #self.cellItemList < #itemList then
			local initItemCount = #itemList - #self.cellItemList

			for i = 1, initItemCount do
				local item = CellItem(self.PrefabCellItem, self.ItemBg)

				item:Create()
				GOUtil.SetTransformLocalScale(item.UIRootObject, 1)
				table.insert(self.cellItemList, item)
				self:AddClick(item.UIRootObject, function()
					if item.info:GetType() == eItemType.R_PICTURE and self.info:IsGetAward() then
						Event.Instance:Fire("OpenDlgIllustration", item.info:GetNum(), self.info.data.roleId)
					end
				end)
			end
		end

		for i, v in ipairs(self.cellItemList) do
			if i <= #itemList then
				v.UIRootObject:SetActive(true)

				local infoItem = ItemManager:GetValueItem(itemList[i][2], itemList[i][3])

				v:UpdateWithNumType(infoItem)

				if infoItem:GetType() == eItemType.R_PICTURE and info:IsGetAward() then
					v.noClick = true
				else
					v.noClick = false
				end
			else
				v.UIRootObject:SetActive(false)
			end
		end
	else
		self.ItemBg:SetActive(false)
		self.Attr:SetActive(true)

		for i = 1, 4 do
			self["TxtValue" .. i].text = skillAttr[i]
		end
	end

	self.TaskName.text = info:GetTaskDesc()
end

function CellPicTask:UpdateProgress(id)
	local curNum, totalNum = CollectionManager:GetProgress(id)

	self.TextNum.text = TenaryOp(totalNum <= curNum, totalNum, curNum) .. "/" .. totalNum
	self.ImageFill.transform.localScale = Vector3(TenaryOp(totalNum <= curNum, totalNum, curNum) / totalNum, 1, 1)
end
