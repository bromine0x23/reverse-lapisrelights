-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/CellCommunicationPage.lua

require("UI/Item/UIItemBase")

CellCommunicationPage = class("CellCommunicationPage", UIItemBase)

function CellCommunicationPage:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCommunicationPage:OnEnter(vParam)
	local g = self.UIRootObject

	self.cells = {}

	for i = 1, 6 do
		local cell = {}

		cell.obj = GOUtil.FindChildGameObject(g, i)
		cell.TopicNew = GOUtil.FindChildGameObject(g, i .. "/TopicNew")
		cell.Topic = GOUtil.FindChildGameObject(g, i .. "/Topic")
		cell.PhoneNew = GOUtil.FindChildGameObject(g, i .. "/PhoneNew")
		cell.Phone = GOUtil.FindChildGameObject(g, i .. "/Phone")
		cell.None = GOUtil.FindChildGameObject(g, i .. "/None")
		cell.Name = GOUtil.FindChildComponent(g, i .. "/Name", "Text")

		table.insert(self.cells, cell)
	end

	for i = 1, 6 do
		self:AddListener(self.cells[i].obj, self.OnCellClick, EventTriggerType.PointerClick)
	end
end

function CellCommunicationPage:OnLeave()
	for i = 1, 6 do
		self:RemoveListener(self.cells[i].obj, self.OnCellClick, EventTriggerType.PointerClick)
	end

	self.data = nil
end

function CellCommunicationPage:UpdateData(data, type)
	self.data = data
	self.type = type

	for i = 1, 6 do
		if i <= #data then
			self.cells[i].TopicNew:SetActive(type == 1 and data[i].pb.status == 0)
			self.cells[i].Topic:SetActive(type == 1 and data[i].pb.status == 1)
			self.cells[i].PhoneNew:SetActive(type == 2 and data[i].pb.status == 0)
			self.cells[i].Phone:SetActive(type == 2 and data[i].pb.status == 1)
			self.cells[i].None:SetActive(false)

			self.cells[i].Name.text = Lang(data[i].data.Name)
		else
			self.cells[i].TopicNew:SetActive(false)
			self.cells[i].Topic:SetActive(false)
			self.cells[i].PhoneNew:SetActive(false)
			self.cells[i].Phone:SetActive(false)
			self.cells[i].None:SetActive(true)

			self.cells[i].Name.text = ""
		end
	end
end

function CellCommunicationPage:OnCellClick(data)
	local go = data.pointerPressRaycast.gameObject
	local index = tonumber(go.name)

	if index <= #self.data then
		if self.type == 1 then
			self.data.callback()
			SceneMgr.LoadScene("Communication", {
				roleId = self.data[index].data.RoleId,
				topicId = self.data[index].pb.id
			})
		elseif not AppConst.AssetBundleMode then
			self.data.callback()
			SceneMgr.LoadScene("Call", {
				from = 2,
				roleId = self.data[index].data.RoleId,
				callId = self.data[index].pb.id
			})
		else
			local exist, type = OptionDownMgr:CheckBundleExist(self.data[index].pb.id, 2)

			if exist then
				self.data.callback()
				SceneMgr.LoadScene("Call", {
					from = 2,
					roleId = self.data[index].data.RoleId,
					callId = self.data[index].pb.id
				})
			else
				local function cb()
					self.data.callback()
					SceneMgr.LoadScene("Call", {
						from = 2,
						roleId = self.data[index].data.RoleId,
						callId = self.data[index].pb.id
					})
				end

				local data = {}

				data.callback = cb
				data.existType = type
				data.stageId = self.data[index].pb.id
				data.openFrom = 2

				require("UI/Page/PageSetting/DlgOptionalDownload")
				UIMgr.AddPanel(DlgOptionalDownload(), data)
			end
		end
	end
end
