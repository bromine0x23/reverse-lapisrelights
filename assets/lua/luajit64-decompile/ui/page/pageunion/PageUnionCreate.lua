-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/PageUnionCreate.lua

require("UI/Page/PageUnion/CellUnionType")
require("UI/Page/PageUnion/PageUnion")

PageUnionCreate = class("PageUnionCreate", UIPanel)

function PageUnionCreate:ctor()
	self.UIPrefabPath = "UI/PanelUnion/PanelUnionCreate"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_CreateUnion"),
		callback = self.OnBack,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageUnionCreate:PreLoad()
	self:LoadResAsync("UI/PanelUnion/CellUnionType", "PrefabCellUnionType", GameObject)
end

function PageUnionCreate:OnBack()
	UIMgr.PopPanel()
end

function PageUnionCreate:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellUnionType)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function PageUnionCreate:OnRegisterEvent()
	self:AddClick(self.BtnSubmit, self.OnClickedBtnSubmit)
end

function PageUnionCreate:OnUnRegisterEvent()
	self:RemoveClick(self.BtnSubmit, self.OnClickedBtnSubmit)
end

function PageUnionCreate:OnEnter()
	self:DealWithLocalization()

	self.UnionTypeBg = self:GetChildComponent("PanelApply/UnionType/Role", "Image")
	self.UnionTypeAvatar = self:GetChildComponent("PanelApply/UnionType/Role/Icon", "Image")
	self.UnionTypeName = self:GetChildComponent("PanelApply/UnionType/Type/Text", "Text")
	self.InputNamePrompt = self:GetChildComponent("PanelApply/UnionInfo/Name/InputField/Placeholder", "Text")
	self.InputUnionName = self:GetChildComponent("PanelApply/UnionInfo/Name/InputField", "InputField")
	self.InputNoticePrompt = self:GetChildComponent("PanelApply/UnionInfo/Notice/InputField/Placeholder", "Text")
	self.InputUnionNotice = self:GetChildComponent("PanelApply/UnionInfo/Notice/InputField", "InputField")
	self.CostItemIcon = self:GetChildComponent("PanelApply/CreateCost/Item/Icon", "Image")
	self.CostItemNum = self:GetChildComponent("PanelApply/CreateCost/Item/Text", "Text")
	self.BtnSubmit = self:GetChildGameObject("PanelApply/BtnSubmit")
	self.TextIntro = self:GetChildComponent("PanelApply/TextIntro", "Text")

	self:InitData()
end

function PageUnionCreate:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("PanelApply/Title/Text", "Text")
	Text.text = _("Union_Application")
	Text = self:GetChildComponent("PanelApply/UnionType/Title/Text", "Text")
	Text.text = _("Union_Attribution")
	Text = self:GetChildComponent("PanelApply/UnionInfo/Name/Title/Text", "Text")
	Text.text = _("Union_Name")
	Text = self:GetChildComponent("PanelApply/UnionInfo/Notice/Title/Text", "Text")
	Text.text = Lang(5000087)
	Text = self:GetChildComponent("PanelApply/BtnSubmit/Text", "Text")
	Text.text = _("UI_Submit_Application")
	Text = self:GetChildComponent("PanelUnionType/Title/Text", "Text")
	Text.text = _("Union_Overview")
	Text = self:GetChildComponent("PanelApply/UnionInfo/Name/InputField/Placeholder", "Text")
	Text.text = _("Msg_Union_Name_Input")
	Text = self:GetChildComponent("PanelApply/UnionInfo/Notice/InputField/Placeholder", "Text")
	Text.text = _("UnionNotice_desc")
end

function PageUnionCreate:InitData()
	self.listUnionType = UnionTypeMgr:GetAllTypeData()
	self.unionTypeCount = #self.listUnionType
	self.unionTypeIndex = 1

	self:InitScrollView()
	self:UpdatePanel()
end

function PageUnionCreate:InitScrollView()
	local scrollArea = self:GetChildGameObject("PanelUnionType/ScrollArea")
	local content = self:GetChildComponent("PanelUnionType/ScrollArea/Content", "RectTransform")
	local count = self.unionTypeCount

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local unionTypeData = self.listUnionType[index]

		item:UpdateData(unionTypeData, self.unionTypeIndex)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellUnionType, CellUnionType, self, false, addCallback, updateCallback)
end

function PageUnionCreate:OnClickedCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if index == self.unionTypeIndex then
		return
	end

	local preIdx = self.unionTypeIndex

	self.unionTypeIndex = index

	self.UIScrollTool:UpdateCellSelect(preIdx, index)
	self:UpdatePanel()
end

function PageUnionCreate:UpdatePanel()
	self.unionType = self.listUnionType[self.unionTypeIndex]
	self.UnionTypeName.text = UnionTypeMgr:GetUnionTypeName(self.unionType.ID)

	local bgPath = UnionTypeMgr:GetUnionTypeBgIcon(self.unionType.ID)

	SetImageSprite(self.UnionTypeBg, bgPath, self)

	local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(self.unionType.ID)

	SetImageSprite(self.UnionTypeAvatar, avatarPath, self)

	local cost = GetConfigArgJson("ClubCreateCost")
	local infoItem = ItemManager:Get(cost[1])

	SetImageSprite(self.CostItemIcon, infoItem:GetIcon(), self)

	self.CostItemNum.text = cost[2]
	self.TextIntro.text = _("Union_SceneWord")
end

function PageUnionCreate:OnClickedBtnSubmit()
	local typeId = self.unionType.ID
	local name = self.InputUnionName.text

	if string.isNullOrEmpty(name) then
		UIMgr.ShowMsg(Lang(26000034))

		return
	end

	if LocalTimeDownNetManagerShow("P161_Response_7", 2) then
		return
	end

	local notice = self.InputUnionNotice.text

	local function wrap_cb(Msg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if Msg.result.code == NetManager.Result_Sucess then
			if UnionMgr.HasUnion() then
				UIMgr.SwitchPanel(PageUnion)
			end
		elseif Msg.result.code == 4 then
			UIMgr.ShowMsg(_("Msg_Union_Joined"))

			local function cb()
				UIMgr.SwitchPanel(PageUnion)
			end

			PageUnion.RequestData(cb)
		else
			UIMgr.ShowMsg(Msg.result.desc, Msg)
		end
	end

	local function callback(type)
		if type == DlgCommonEvent.ButtonType.Ok then
			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestCreateUnion(typeId, name, notice, wrap_cb)
		else
			LoadingMgr.Hide(eLoadingType.Repeat)
		end
	end

	local function default()
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestCreateUnion(typeId, name, notice, wrap_cb)
	end

	local price = tonumber(self.CostItemNum.text)

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Tittle_Affirm"), {
		isDiamond = true,
		text = string.format(_("Desc_CreateGuild"), price)
	}, function(idx)
		if idx == 1 then
			default()
		end
	end, _("Button_Yes"), _("Button_No"), true)
end
