-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveLevel.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellLevelAward")

DlgOperationActiveLevel = class("DlgOperationActiveLevel", UIItemBase)

function DlgOperationActiveLevel:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveLevel:Purge()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self:UnloadRef()
	UnloadAllImageSprite(self)
end

function DlgOperationActiveLevel:UnloadRef()
	if self.spineGroupHandle then
		for _, v in pairs(self.spineGroupHandle) do
			ResourceMgr.Cancel(v)
		end
	end

	if self.listRef then
		for _, v in pairs(self.listRef) do
			ResourceMgr.Unload(v)
		end

		self.listRef = nil
	end
end

function DlgOperationActiveLevel:OnRegisterEvent()
	return
end

function DlgOperationActiveLevel:OnUnRegisterEvent()
	return
end

function DlgOperationActiveLevel:OnEnter(vParam)
	self.PrefabCell = ResourceMgr.LoadSync("UI/PanelOperation/CellLevelAward")

	local g = self.UIRootObject

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
end

function DlgOperationActiveLevel:DealWithLocalization(ActiveID)
	if OperationActiveMgr.PageOperationActiveType == 1 then
		local uiInfo = InfoOperationActive:GetOperationUIInfo(ActiveID)

		if not uiInfo then
			return
		end

		for i = 1, 2 do
			local Rmg = self.BGRaw

			if uiInfo and uiInfo.Bg and uiInfo.Bg[i] and uiInfo.Bg[i][1] and Rmg then
				UIUtil.SetRawImageTexture(Rmg, uiInfo.Bg[i][1], self)
				Rmg.gameObject.transform:SetSiblingIndex(uiInfo.Bg[i][2])
			end
		end

		for i = 1, 2 do
			local goSpine = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Model/Spine/Spine" .. i)

			if uiInfo and uiInfo.Spine and uiInfo.Spine[i] and uiInfo.Spine[i][1] and goSpine and goSpine.transform.childCount == 0 then
				if not self.spineGroupHandle then
					self.spineGroupHandle = {}
				end

				self.spineGroupHandle[i] = ResourceMgr.BeginSubmit(function()
					if self.Spine then
						if not self.listRef then
							self.listRef = {}
						end

						table.insert(self.listRef, self.Spine)
						GOUtil.InstantiateUIPrefab(self.Spine, goSpine)

						goSpine.transform.localScale = Vector3(uiInfo.Spine[i][3] or 0.75, uiInfo.Spine[i][3] or 0.75, 1)

						goSpine.transform:SetSiblingIndex(uiInfo.Spine[i][2])
						GOUtil.UpdateSpineSkeleton(goSpine.gameObject)

						GOUtil.GetComponent(goSpine, "Image").enabled = false
					end
				end)

				ResourceMgr.SubmitCache(uiInfo.Spine[i][1], self, "Spine", GameObject)
				ResourceMgr.EndSubmit()
			end
		end

		for i = 1, 3 do
			local Fx = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Model/Fx")

			if uiInfo and uiInfo.Fx and uiInfo.Fx[i] and uiInfo.Fx[i][1] and Fx then
				EffectMgr:Alloc(uiInfo.Fx[i][1], Fx, true)
				Fx.gameObject.transform:SetSiblingIndex(uiInfo.Fx[i][2])
			end
		end

		for i = 1, 5 do
			local Img = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Pic/Pic" .. i, "Image")

			if uiInfo and uiInfo.Pic and uiInfo.Pic[i] and uiInfo.Pic[i][1] and Img then
				UIUtil.SetImageSprite(Img, uiInfo.Pic[i][1], self, true)
				Img.gameObject.transform:SetSiblingIndex(uiInfo.Pic[i][2])
			end
		end

		for i = 1, 3 do
			local Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. i, "Text")

			if uiInfo and uiInfo.Text and uiInfo.Text[i] and uiInfo.Text[i][1] and Text then
				Text.text = Lang(uiInfo.Text[i][1])

				Text.gameObject.transform:SetSiblingIndex(uiInfo.Text[i][2])
			end
		end
	else
		local uiInfo = InfoOperationActive:GetOperationUIInfo(ActiveID)

		if not uiInfo then
			return
		end

		for i = 1, 2 do
			local Rmg = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Bg/Bg" .. i, "RawImage")

			if uiInfo and uiInfo.Bg and uiInfo.Bg[i] and uiInfo.Bg[i][1] and Rmg then
				UIUtil.SetRawImageTexture(Rmg, uiInfo.Bg[i][1], self)
				Rmg.gameObject.transform:SetSiblingIndex(uiInfo.Bg[i][2])
			end
		end

		for i = 1, 2 do
			local goSpine = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Model/Spine/Spine" .. i)

			if uiInfo and uiInfo.Spine and uiInfo.Spine[i] and uiInfo.Spine[i][1] and goSpine and goSpine.transform.childCount == 0 then
				if not self.spineGroupHandle then
					self.spineGroupHandle = {}
				end

				self.spineGroupHandle[i] = ResourceMgr.BeginSubmit(function()
					if self.Spine then
						if not self.listRef then
							self.listRef = {}
						end

						table.insert(self.listRef, self.Spine)
						GOUtil.InstantiateUIPrefab(self.Spine, goSpine)

						goSpine.transform.localScale = Vector3(uiInfo.Spine[i][3] or 0.75, uiInfo.Spine[i][3] or 0.75, 1)

						goSpine.transform:SetSiblingIndex(uiInfo.Spine[i][2])
						GOUtil.UpdateSpineSkeleton(goSpine.gameObject)

						GOUtil.GetComponent(goSpine, "Image").enabled = false
					end
				end)

				ResourceMgr.SubmitCache(uiInfo.Spine[i][1], self, "Spine", GameObject)
				ResourceMgr.EndSubmit()
			end
		end

		for i = 1, 3 do
			local Fx = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Model/Fx")

			if uiInfo and uiInfo.Fx and uiInfo.Fx[i] and uiInfo.Fx[i][1] and Fx then
				EffectMgr:Alloc(uiInfo.Fx[i][1], Fx, true)
				Fx.gameObject.transform:SetSiblingIndex(uiInfo.Fx[i][2])
			end
		end

		for i = 1, 5 do
			local Img = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Pic/Pic" .. i, "Image")

			if uiInfo and uiInfo.Pic and uiInfo.Pic[i] and uiInfo.Pic[i][1] and Img then
				UIUtil.SetImageSprite(Img, uiInfo.Pic[i][1], self, true)
				Img.gameObject.transform:SetSiblingIndex(uiInfo.Pic[i][2])
			end
		end

		for i = 1, 3 do
			local Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. i, "Text")

			if uiInfo and uiInfo.Text and uiInfo.Text[i] and uiInfo.Text[i][1] and Text then
				Text.text = Lang(uiInfo.Text[i][1])

				Text.gameObject.transform:SetSiblingIndex(uiInfo.Text[i][2])
			end
		end
	end
end

function DlgOperationActiveLevel:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.listLevelAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	local count = #self.listLevelAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local data = self.listLevelAward[index]

		item:UpdateData(data, infoActive)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellLevelAward, self, false, addCallback, updateCallback)
end

function DlgOperationActiveLevel:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.listLevelAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	self.UIScrollTool:UpdateListDataKeepPos(self.listLevelAward)
end
