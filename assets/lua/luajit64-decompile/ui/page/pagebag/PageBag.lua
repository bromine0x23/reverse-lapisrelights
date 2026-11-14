-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBag/PageBag.lua

require("UI/Item/CellItem")
require("UI/Page/PageBag/CellBagItem")
require("UI/Page/PageBag/DlgItemExpireChange")
require("UI/Page/PageBag/DlgRoleCardChange")

PageBag = class("PageBag", UIPanel)

function PageBag:ctor()
	self.UIPrefabPath = "UI/PageBag/PageBag"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_Bag"),
		callback = self.OnBack,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageBag:PreLoad()
	self:LoadResAsync("UI/PageBag/CellBagItem", "PrefabCellBagItem")
end

function PageBag:FormatButtonText(text)
	local s = string.gsub(text, "<[^>]*>", "")

	return s
end

function PageBag:Purge()
	PageBag.base.Purge(self)
	UITweenUtil.RemoveTween(self.tagGroup.transform)
	ResourceMgr.Unload(self.PrefabCellBagItem)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	self.UIScrollTool = nil

	BagRDL.Remove(nil, self.tabMainIndex)
end

function PageBag:OnRegisterEvent()
	for i = 1, self.tabMainCount do
		self:AddClick(self["TabMain" .. i], self.OnButtonTabMain)
	end

	Event.Instance:Add("ShowBag", self.ShowBag, self)
	Event.Instance:Add("UpdateBag", self.UpdateBag, self)
end

function PageBag:OnUnRegisterEvent()
	for i = 1, self.tabMainCount do
		self:RemoveClick(self["TabMain" .. i], self.OnButtonTabMain)
	end

	Event.Instance:Remove("ShowBag", self.ShowBag, self)
	Event.Instance:Remove("UpdateBag", self.UpdateBag, self)
end

function PageBag:OnEnter()
	self.tagGroup = self:GetChildGameObject("TabGroup")
	self.GoImage = self:GetChildGameObject("Panel/Image")
	self.panel = self:GetChildGameObject("Panel")
	self.GoText = self:GetChildGameObject("Panel/NoItemTip")
	self.TextTip = self:GetChildComponent("Panel/NoItemTip/Text", "Text")
	self.Anim = self:GetChildComponent("", "Animation")
	self.TextTip.text = _("Desc_noItem")
	self.tabMainCount = 5

	for i = 1, self.tabMainCount do
		self["TabMain" .. i] = self:GetChildGameObject("TabGroup/panel/" .. i .. "/Button")
		self["TabMainSel" .. i] = self:GetChildGameObject("TabGroup/panel/" .. i .. "/Sel")
	end

	local TextAuto

	TextAuto = self:GetChildComponent("TabGroup/panel/1/Button/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000047))
	TextAuto = self:GetChildComponent("TabGroup/panel/2/Button/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(8111025))
	TextAuto = self:GetChildComponent("TabGroup/panel/3/Button/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000049))
	TextAuto = self:GetChildComponent("TabGroup/panel/4/Button/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000050))
	TextAuto = self:GetChildComponent("TabGroup/panel/5/Button/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000051))
	TextAuto = self:GetChildComponent("TabGroup/panel/1/Sel/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000047))
	TextAuto = self:GetChildComponent("TabGroup/panel/2/Sel/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(8111025))
	TextAuto = self:GetChildComponent("TabGroup/panel/3/Sel/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000049))
	TextAuto = self:GetChildComponent("TabGroup/panel/4/Sel/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000050))
	TextAuto = self:GetChildComponent("TabGroup/panel/5/Sel/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000051))

	self:InitData()
	self:InitScrollView()
	self:UpdateTabMain()
	self:DealWithExpireItem()

	local go = self:GetChildGameObject("TabGroup/panel")

	UITweenUtil.CommonTweenRight(go.transform, 100, 0.14)
end

function PageBag:Getlist(assetFrom, listSetter)
	local list = {}

	for _, s in pairs(listSetter) do
		if s.from == assetFrom then
			table.insert(list, s)
		end
	end

	return list
end

function PageBag:DealWithExpireItem()
	NetManager:RequestExpireItemExchange(function(pb)
		if pb.result.code == NetManager.Result_Sucess then
			local setter = SetterData.GetSetterData(pb.setter)

			setter:Parse()

			local listNormal = self:Getlist(protocol_pb.AF_NORMAL, setter.list)
			local listExchange = self:Getlist(protocol_pb.AF_ITEM_EXCHANGE, setter.list)

			if listNormal and #listNormal > 0 then
				UIMgr.AddPanel(DlgItemExpireChange(), {
					listNormal = listNormal,
					listExchange = listExchange
				})
			end
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end

function PageBag:InitData()
	self.tabMainIndex = 1
	self.dictAll = {}

	for i = 1, self.tabMainCount do
		self.dictAll[i] = ItemManager:GetBagList(i)
	end

	if ItemManager.tabIndex ~= 0 then
		self.tabMainIndex = ItemManager.tabIndex
	end
end

function PageBag:OnBack()
	UIMgr.PopPanel()
end

function PageBag:ShowBag(isShow)
	SetActiveFunc(self.UIRootObject, isShow)
end

function PageBag:UpdateBag()
	self.dictAll = {}

	for i = 1, self.tabMainCount do
		self.dictAll[i] = ItemManager:GetBagList(i)
	end

	self:UpdateTabMain()
end

function PageBag:OnButtonTabMain(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	if self.tabMainIndex == index then
		return
	end

	BagRDL.Remove(nil, self.tabMainIndex)

	self.tabMainIndex = index

	self:UpdateTabMain()

	ItemManager.tabIndex = index

	self.Anim:Play("PageBag_show")
end

function PageBag:UpdateTabMain()
	for i = 1, self.tabMainCount do
		SetActiveFunc(self["TabMainSel" .. i], false)
	end

	SetActiveFunc(self["TabMainSel" .. self.tabMainIndex], true)
	self.UIScrollTool:UpdateListData(self.dictAll[self.tabMainIndex])

	local list = self.dictAll[self.tabMainIndex]
	local hasPack = false

	SetActiveFunc(self.GoImage, #list <= 0)
	SetActiveFunc(self.GoText, #list <= 0)
end

function PageBag:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.dictAll[self.tabMainIndex]

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCellBagItem, CellBagItem, self, false)
end

function PageBag:UpdateCell(item, index)
	item.Index = index

	local list = self.dictAll[self.tabMainIndex]
	local info = list[index]

	item:UpdateData(info)
end

function PageBag:AddCellClick(item)
	self:AddClick(item.GoClick, self.OnClickedCell)

	item.CellItem.noClick = true
end

function PageBag:OnClickedCell(data)
	local go = data.pointerPress.transform.parent.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local list = self.dictAll[self.tabMainIndex]
	local infoItem = list[info.Item.Index]

	if infoItem:GetType() == eItemType.I_PACK_CARD then
		UIMgr.AddPanel(DlgRoleCardChange(), {
			info = infoItem
		})
	else
		UIMgr.ShowItemTip(infoItem, 3, true, true)
	end

	BagRDL.Remove(infoItem.id, self.tabMainIndex)
	info.Item:UpdateDot()
end

function PageBag:UpdateBagListKeepPos()
	self.UIScrollTool:UpdateBagListKeepPos(self.dictAll[self.tabMainIndex])
end
