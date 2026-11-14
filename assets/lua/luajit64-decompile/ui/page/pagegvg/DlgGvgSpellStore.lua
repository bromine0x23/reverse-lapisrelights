-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgSpellStore.lua

DlgGvgSpellStore = class("DlgGvgSpellStore", UIPanel)

local _item = class("DlgGvgSpellStore_item", UIPanel)

function DlgGvgSpellStore:ctor()
	self.UIPrefabPath = "UI/PageGvg/DlgGvgSpellStore"
end

function DlgGvgSpellStore:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
	UIMgr.SetUpdatePanel(nil)

	for i = #self.items, 1, -1 do
		local item = table.remove(self.items, i)

		item:Purge()
	end
end

function DlgGvgSpellStore:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose)
end

function DlgGvgSpellStore:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnBtnClose)
end

function DlgGvgSpellStore:PreLoad()
	return
end

function DlgGvgSpellStore:OnEnter(vParam)
	UIMgr.SetUpdatePanel(self)

	self.items = {}
	self.btn_close = self:GetChildGameObject("main/btn_close/obj_click")
	self.txt_tip = self:GetChildComponent("main/txt_tip", "Text")

	if Infogvg.union:IsLord() then
		self.txt_tip.color = getColorFromString("585E62")

		UIUtil.SetTextString(self.txt_tip, _("Desc_GVG_store"))
	else
		self.txt_tip.color = getColorFromString("FE0000")

		UIUtil.SetTextString(self.txt_tip, _("Desc_GVG_store_only_lord"))
	end

	local uiroot = self:GetChildGameObject("main/items").transform

	for i, item in ipairs(Infogvg.spell.items) do
		if i > uiroot.childCount then
			break
		end

		local obj = uiroot:GetChild(i - 1).gameObject
		local t = _item()

		t:Init(obj, item.uid)
		table.insert(self.items, t)
	end

	Infogvg.net:RequestGvg()
end

function DlgGvgSpellStore:OnBtnClose()
	self:Close()
end

function DlgGvgSpellStore:OnUpdateSecond()
	for i, item in ipairs(self.items) do
		item:TimeUI()
	end
end

function _item:Init(obj, uid)
	self.gameObject = obj
	self.status = 0
	self.uid = uid
	self.txt_name = GOUtil.FindChildComponent(obj, "cell/txt_name", "Text")
	self.txt_desc = GOUtil.FindChildComponent(obj, "scrollview/Viewport/content/txt", "Text")
	self.txt_time = GOUtil.FindChildComponent(obj, "actived/txt_time", "Text")
	self.obj_click = GOUtil.FindChildGameObject(obj, "notactived/btn_buy/obj_click")
	self.img_priceicon = GOUtil.FindChildComponent(obj, "notactived/img_priceicon", "Image")
	self.txt_price = GOUtil.FindChildComponent(obj, "notactived/txt_price", "Text")
	self.img_cellicon = GOUtil.FindChildComponent(obj, "cell/img_icon", "Image")
	self.img_buy = GOUtil.FindChildComponent(obj, "notactived/btn_buy", "Image")

	local spell = Infogvg.spell:Get(uid)

	if not spell then
		return
	end

	self.obj_got = GOUtil.FindChildGameObject(obj, "actived")
	self.obj_notGot = GOUtil.FindChildGameObject(obj, "notactived")

	self:RefreshOwned()
	Event.Instance:Add("EVENT_GVG_REFRESH", self.RefreshOwned, self)
	self:AddClick(self.obj_click, self.OnItemClick)
end

function _item:Purge()
	Event.Instance:Remove("EVENT_GVG_REFRESH", self.RefreshOwned, self)
	self:RemoveClick(self.obj_click, self.OnItemClick)
end

function _item:IsLord()
	if Infogvg.union:IsLord() then
		UIUtil.SetImageGray(self.img_buy, 0)
	else
		UIUtil.SetImageGray(self.img_buy, 1)
	end
end

function _item:TimeUI()
	local spell = Infogvg.spell:Get(self.uid)

	if not spell then
		return
	end

	if not spell.endTime then
		UIUtil.SetTextString(self.txt_time, "")

		return
	end

	local endTime = tonumber(spell.endTime)
	local serverTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local leftSec = Mathf.Floor(Mathf.Max(0, endTime - serverTime))
	local format_hms = _("Desc_Time_Format_hms")
	local format_ms = _("Desc_Time_Format_ms")
	local format_s = _("Desc_Time_Format_s")
	local d, h, m, s = GetTimeFormatBySec(leftSec)
	local strTime = ""

	if h > 0 then
		strTime = string.format(format_hms, h, m, s)
	elseif m > 0 then
		strTime = string.format(format_ms, m, s)
	elseif s > 0 then
		strTime = string.format(format_s, s)
	else
		strTime = string.format(format_s, s)
	end

	UIUtil.SetTextString(self.txt_time, strTime)

	if leftSec == 0 then
		Infogvg.net:RequestGvg()
	end
end

function _item:RefreshOwned()
	local spell = Infogvg.spell:Get(self.uid)

	if not spell then
		Infogvg:Error("対応するspell ， idが見つかりません " .. self.uid)

		return
	end

	local infoProduct = spell:GetProduct()
	local infoItem = spell:GetItem()
	local costItemId = infoProduct.data.CostValue[1]
	local costItemNum = infoProduct.data.CostValue[2]

	UIUtil.SetImageSprite(self.img_priceicon, ItemManager:Get(costItemId).data.Icon, self)

	local owned = ItemManager:GetItemCount(costItemId)
	local priceStr = owned .. "/" .. costItemNum

	UIUtil.SetTextString(self.txt_price, priceStr)

	if costItemNum <= owned then
		self.txt_price.color = getColorFromString("FFFFFF")
	else
		self.txt_price.color = getColorFromString("FE0000")
	end

	UIUtil.SetImageSprite(self.img_cellicon, infoItem.data.Icon, self)

	local _name, _desc = infoItem:GetNameAndDesc()

	UIUtil.SetTextString(self.txt_name, _name)
	UIUtil.SetTextString(self.txt_desc, _desc)

	local goted = spell:Owned()

	GOUtil.SetActive(self.obj_got, false)
	GOUtil.SetActive(self.obj_got, goted)
	GOUtil.SetActive(self.obj_notGot, not goted)
	self:TimeUI()

	local infoProduct = spell:GetProduct()
	local costItemId = infoProduct.data.CostValue[1]
	local coin = ItemManager:GetItemCount(costItemId)
	local cost = infoProduct.data.CostValue[2]

	self.status = 0

	if Infogvg.union:IsLord() == false then
		self.status = 1

		UIUtil.SetImageGray(self.img_buy, 1)
	elseif coin < cost then
		self.status = 2

		UIUtil.SetImageGray(self.img_buy, 1)
	else
		UIUtil.SetImageGray(self.img_buy, 0)

		self.status = 0
	end
end

function _item:OnItemClick()
	if self.status == 0 then
		self:OnBtnBuy()
	elseif self.status == 1 then
		UIMgr.ShowMsg(_("Desc_GVG_STORE_LESS_PREMISSION"))
	elseif self.status == 2 then
		UIMgr.ShowMsg(_("Desc_GVG_STORE_LESS_COST"))
	end
end

function _item:OnBtnBuy()
	local spell = Infogvg.spell:Get(self.uid)

	if not spell then
		return
	end

	local infoProduct = spell:GetProduct()
	local infoItem = spell:GetItem()

	local function OnCallback(index)
		if index == 1 then
			Infogvg.net:RequestBuy(self.uid)
		end
	end

	local costItemId = infoProduct.data.CostValue[1]
	local name = infoItem:GetNameAndDesc()
	local strIcon = ItemManager:Get(costItemId).data.Icon
	local cost = infoProduct.data.CostValue[2]
	local owned = ItemManager:GetItemCount(costItemId)

	Infogvg:Log("応援会資金：:" .. owned)
	UIMgr.ShowCommon(DlgCommonEvent.Type.MsgWithAlert, _("Desc_Alert"), {
		content = string.format(_("Desc_GVG_Buy_Spell"), cost, name),
		alert = string.format(_("Desc_HaveItemNum"), ItemManager:GetItemCount(costItemId))
	}, OnCallback, _("UI_Buy"))
end
