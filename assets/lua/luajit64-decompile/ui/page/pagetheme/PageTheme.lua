-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTheme/PageTheme.lua

require("UI/Page/PageTheme/CellTheme")
require("Util/Container")
require("UI/UIAlbum")
require("Info/InfoTheme")
require("UI/Page/PageTheme/CellThemeSel")

PageTheme = class("PageTheme", UIPanel)

function PageTheme:ctor()
	self.UIPrefabPath = "UI/PageTheme/PageTheme"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_theme"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		type = 1,
		x = -600,
		y = -42,
		AssetInfos = {
			1051,
			502,
			501
		}
	})
end

function PageTheme:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem", GameObject)
	self:LoadResAsync("UI/PageTheme/CellSel2", "PrefabCellSel", GameObject)
	self:LoadResAsync("UI/PageTheme/CellTheme", "PrefabCell", GameObject)
end

function PageTheme:Purge()
	PageTheme.base.Purge(self)

	if self.UIAlbum then
		self.UIAlbum:Purge()

		self.UIAlbum = nil
	end

	if self.itemGoList then
		for i = 1, #self.itemGoList do
			if self.itemGoList[i] then
				self.itemGoList[i]:OnLeave()
			end
		end

		self.itemGoList = nil
	end

	if self.itemCellSelList then
		for i = 1, #self.itemCellSelList do
			if self.itemCellSelList[i] then
				self.itemCellSelList[i]:OnLeave()
			end
		end

		self.itemCellSelList = nil
	end

	if self.PrefabCellItem then
		ResourceMgr.Unload(self.PrefabCellItem)

		self.PrefabCellItem = nil
	end

	if self.PrefabCellSel then
		ResourceMgr.Unload(self.PrefabCellSel)

		self.PrefabCellSel = nil
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	UIMgr.UICamera.orthographic = true
end

function PageTheme:OnRegisterEvent()
	self:AddClick(self.btn_set_seat, self.OnClickedSetSeat)
	self:AddClick(self.btn_onekey.gameObject, self.OnClickedOneKey)
	Event.Instance:Add("PageThemeInfoEvent", self.PageThemeInfoEvent, self)
	Event.Instance:Add("PageThemeUpdateInfoEvent", self.PageThemeUpdateInfoEvent, self)
end

function PageTheme:OnUnRegisterEvent()
	self:RemoveClick(self.btn_set_seat, self.OnClickedSetSeat)
	self:RemoveClick(self.btn_onekey.gameObject, self.OnClickedOneKey)
	Event.Instance:Remove("PageThemeInfoEvent", self.PageThemeInfoEvent, self)
	Event.Instance:Remove("PageThemeUpdateInfoEvent", self.PageThemeUpdateInfoEvent, self)
end

function PageTheme:OnEnter()
	UIMgr.UICamera.orthographic = false
	self.Img_ThemeIconBk = self:GetChildGameObject("Group")
	self.IdxToThemeIcon = Record()
	ThemeManager.isShowDetails = false

	if not GuideMgr:IsGuided(GuideFunctionType.ScenceSetting) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.ScenceSetting)
	end

	local Text1 = self:GetChildComponent("PanelInfo/bg/Image1/Text1", "Text")
	local Text2 = self:GetChildComponent("PanelInfo/bg/Image2/Text2", "Text")
	local Text = self:GetChildComponent("PanelInfo/bg/btn_onekey/Text", "Text")

	Text.text = _("Desc_OneKeyRec")
	Text = self:GetChildComponent("PanelInfo/bg/btn_set_seat/Text", "Text")
	Text.text = _("Desc_PosSeat")
	Text = self:GetChildComponent("PanelInfo/bg/Image2/tex_tips", "Text")
	Text.text = _("Desc_NoReward")
	self.tex_tipsGo = self:GetChildGameObject("PanelInfo/bg/Image2/tex_tips")
	self.TextTitle = self:GetChildComponent("Image/Text", "Text")
	self.TextInfo = self:GetChildComponent("PanelInfo/bg/Image1/Text", "Text")
	self.GroupItem = self:GetChildGameObject("PanelInfo/bg/Image2/GroupItem")
	self.GroupRole = self:GetChildGameObject("PanelInfo/GroupRole")
	self.btn_set_seat = self:GetChildGameObject("PanelInfo/bg/btn_set_seat")
	self.btn_onekey = self:GetChildComponent("PanelInfo/bg/btn_onekey", "Image")
	self.btn_effect = self:GetChildGameObject("PanelInfo/bg/btn_onekey/Fx_UI_009_P")
	self.Image2 = self:GetChildGameObject("PanelInfo/bg/Image2")
	self.Image1 = self:GetChildGameObject("PanelInfo/bg/Image1")
	self.tex_Desc = self:GetChildComponent("PanelInfo/bg/Image1/Text", "Text")

	self:InitData()

	local gPanel = self:GetChildGameObject("Group")
	local listData = self.listThemeAll

	self.UIAlbum = UIAlbum()

	local index = ThemeManager.SelectedID

	self.UIAlbum:Init(gPanel, listData, self.PrefabCell, CellTheme, self, index)
end

function PageTheme:InitData(listThemeAll)
	ThemeManager:ClearAll()

	self.listThemeAll = ThemeManager:GetAll()

	if listThemeAll then
		self.listThemeAll = listThemeAll
	end
end

function PageTheme:OnBack()
	ThemeManager.TypeID = 1
	ThemeManager.SelectedID = 0

	UIMgr.PopPanel()
end

function PageTheme:UpdateCell(item, index, isSel)
	item.UIRootObject.name = self.listThemeAll[index].id

	item:Update(self.listThemeAll[index], isSel, true)
end

function PageTheme:PageThemeUpdateInfoEvent(listThemeAll, selIndex, selPbIndex)
	if listThemeAll then
		self:InitData(listThemeAll)

		for i = 1, #self.listThemeAll do
			local index = tonumber(self.UIAlbum:GetIdxToThemeIcon()[i].UIRootObject.name)
			local info = {}

			for m = 1, #self.listThemeAll do
				if index == listThemeAll[m].id then
					info = listThemeAll[m]
				end
			end

			self.UIAlbum:GetIdxToThemeIcon()[i]:Update(info, index == selIndex)
			self:UpdateInfo(i)
		end
	else
		for i = 1, #self.listThemeAll do
			local index = tonumber(self.UIAlbum:GetIdxToThemeIcon()[i].UIRootObject.name)
			local info = {}

			for m = 1, #self.listThemeAll do
				if index == self.listThemeAll[m].id then
					info = self.listThemeAll[m]
				end
			end

			self.UIAlbum:GetIdxToThemeIcon()[i]:Update(info, index == selIndex)
			self:UpdateInfo(i)
		end
	end
end

function PageTheme:UpdatePageThemeDot()
	SetActiveFunc(self.seat_dot, ThemeManager:GetDlgThemeOpenState())
end

function PageTheme:OnUpdateSecond()
	if not self.listThemeAll then
		return
	end

	for i = 1, #self.listThemeAll do
		self.UIAlbum:GetIdxToThemeIcon()[i]:UpdateTime()

		if ThemeManager.surplus[i] == 0 and self.listThemeAll[i].pb.surplus == ThemeManager:GetMaxInfoThemeSec(self.listThemeAll[i]) then
			self:UpdateInfo(i)
		end

		if not self.itemGoList[i] and ThemeManager:GetInfoThemeCount(self.listThemeAll[i]) ~= 0 then
			self:UpdateInfo(i)
		end

		if self.itemGoList[i] then
			self.itemGoList[i].ItemCount.text = ThemeManager:GetInfoThemeCount(self.listThemeAll[i])
		end
	end
end

function PageTheme:UpdateInfo(index, isUIAlbum)
	local info = self.listThemeAll[index]

	if isUIAlbum then
		self.tex_Desc.text = info:GetDesc()
	end

	local SeatCount = info.data.SeatCount
	local SeatIndex = 0

	if self.itemCellSelList then
		for i = 1, #self.itemCellSelList do
			if self.itemCellSelList[i] then
				self.itemCellSelList[i]:OnLeave()
			end
		end

		self.itemCellSelList = nil
	end

	GOUtil.DestroyAllChildren(self.GroupRole)

	self.itemCellSelList = {}

	for i = 1, info.data.SeatCount do
		local item = CellThemeSel(self.PrefabCellSel, self.GroupRole, self)

		item:Create()
		SetActiveFunc(item.panel, info.geted)

		if info.geted then
			local id = info.pb.seats[i]

			if id == 0 then
				SetActiveFunc(item.panel, false)
			else
				SeatIndex = SeatIndex + 1

				item:UpdateData(info.pb.seats[i])
			end

			table.insert(self.itemCellSelList, item)
		end
	end

	if self.itemGoList then
		for i = 1, #self.itemGoList do
			if self.itemGoList[i] then
				self.itemGoList[i]:OnLeave()
			end
		end

		self.itemGoList = nil
	end

	GOUtil.DestroyAllChildren(self.GroupItem)

	self.itemGoList = {}

	for n = 1, #self.listThemeAll do
		local info = self.listThemeAll[n]

		for i = 1, #info.data.BaseReward do
			if info.geted and ThemeManager:GetInfoThemeCount(info) ~= 0 then
				local item = CellItem(self.PrefabCellItem, self.GroupItem, self)

				item:Create()

				local listAward = info.data.BaseReward[i]
				local infoItem = ItemManager:GetValueItem(listAward[1], listAward[2])

				item:UpdateWithNumType(infoItem)

				item.ItemCount.text = ThemeManager:GetInfoThemeCount(self.listThemeAll[n])

				item:SetImgSeatNum(info.id)

				if info.pb.surplus then
					if info.pb.surplus == ThemeManager:GetMaxInfoThemeSec(info) then
						item:SetSceneAwardFull(true)
					else
						item:SetSceneAwardFull(false)
					end
				else
					item:SetSceneAwardFull(false)
				end

				table.insert(self.itemGoList, n, item)
			end
		end
	end

	SetActiveFunc(self.tex_tipsGo, #self.itemGoList == 0)

	if #self.itemGoList ~= 0 then
		UIUtil.SetImageSprite(self.btn_onekey, "UI/PageTheme/AtlasPageTheme/BTN_square_pink_01", self)
		SetActiveFunc(self.btn_effect, true)
	else
		UIUtil.SetImageSprite(self.btn_onekey, "UI/PageTheme/AtlasPageTheme/BTN_square_pink_02", self)
		SetActiveFunc(self.btn_effect, false)
	end
end

function PageTheme:OnClickedSetSeat()
	require("UI/Page/PageTheme/DlgTheme")
	UIMgr.AddPanel(DlgTheme(), {})
end

function PageTheme:OnClickedOneKey()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			for i = 1, #self.listThemeAll do
				self:UpdateInfo(i)
			end
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestGetThemeAward(0, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageTheme:PageThemeInfoEvent()
	if self.Image2.activeSelf then
		SetActiveFunc(self.Image2, false)
		SetActiveFunc(self.Image1, true)
	else
		SetActiveFunc(self.Image1, false)
		SetActiveFunc(self.Image2, true)
	end
end

function PageTheme:OnClickedBtnGuide()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.ScenceSetting)
end
