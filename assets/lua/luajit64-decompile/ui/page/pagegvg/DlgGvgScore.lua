-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgScore.lua

DlgGvgScore = class("DlgGvgScore", UIPanel)

require("UI/Item/UIItemBase")

local DlgGvgScoreItem = class("DlgGvgScoreItem", UIItemBase)

function DlgGvgScore:ctor()
	self.UIPrefabPath = "UI/PageGvg/DlgGvgScore"
end

function DlgGvgScore:Purge()
	DlgGvgScore.base.Purge(self)

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	self.UIScrollToolPanel:Purge()
end

function DlgGvgScore:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PageGvg/CellGvgScore")
end

function DlgGvgScore:OnRegisterEvent()
	self:AddClick(self.closeBtn, self.OnClickedBtnQuit)
	Event.Instance:Add("EVENT_GVG_SCORE", self.Refresh, self)
end

function DlgGvgScore:OnUnRegisterEvent()
	self:RemoveClick(self.closeBtn, self.OnClickedBtnQuit)
	Event.Instance:Remove("EVENT_GVG_SCORE", self.Refresh, self)
end

function DlgGvgScore:OnEnter(vParam)
	self.closeBtn = self:GetChildGameObject("Panel/Close/obj_click")
	self.obj_empty = self:GetChildGameObject("Panel/obj_empty")
	self.UIScrollContent = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	self.UIScrollToolPanel = UIScrollTool()
	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")

	Infogvg.net:RequestLog()
end

function DlgGvgScore:Refresh()
	local datas = Infogvg.rank.gvglog
	local count = #datas

	local function onAdd(item)
		return
	end

	local function onUpdate(item, index)
		local data = datas[index]

		item:Refresh(data)
	end

	self.UIScrollToolPanel:InitList(self.ScrollArea, self.UIScrollContent, count, self.PrefabCell, DlgGvgScoreItem, self, false, onAdd, onUpdate)
	GOUtil.SetActive(self.obj_empty, count == 0)
end

function DlgGvgScore:OnClickedBtnQuit()
	self:Close()
end

function DlgGvgScoreItem:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgGvgScoreItem:Create(vParam)
	DlgGvgScoreItem.base.Create(self, vParam)
end

function DlgGvgScoreItem:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end

local function _GetStrLogoutTime(t)
	local disTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond - tonumber(t)
	local str = ""

	if disTime < 86400 then
		if disTime > 3600 then
			local hour = math.floor(disTime / 3600)

			str = string.format(_("Desc_Hours_Ago"), hour)
		else
			local minute = math.floor(disTime / 60)

			if minute == 0 then
				str = _("Desc_Just_Ago")
			else
				str = string.format(_("Desc_Minutes_Ago"), minute)
			end
		end
	else
		local day = math.floor(disTime / 86400)

		if day > 7 then
			day = 7
		end

		str = string.format(_("Desc_Days_Ago"), day)
	end

	return str
end

function DlgGvgScoreItem:OnEnter()
	self.img_icon = self:GetChildComponent("Icon", "Image")
	self.img_frame = self:GetChildComponent("Frame", "Image")
	self.txt_score = self:GetChildComponent("Score", "Text")
	self.txt_stage = self:GetChildComponent("Stage", "Text")
	self.txt_name = self:GetChildComponent("Name", "Text")
	self.txt_time = self:GetChildComponent("Time", "Text")
	self.obj_killer = self:GetChildGameObject("img_killer")
	self.obj_pass = self:GetChildGameObject("img_pass")

	self:OnRegisterEvent()
end

function DlgGvgScoreItem:OnRegisterEvent()
	return
end

function DlgGvgScoreItem:OnUnRegisterEvent()
	return
end

function DlgGvgScoreItem:Refresh(data)
	self.txt_name.text = data.name

	local infoStage = InfoStage(data.stageId)

	self.txt_stage.text = Lang(infoStage.data.Name)
	self.txt_time.text = _GetStrLogoutTime(data.battleTime)
	self.txt_score.text = data.costBlood

	GOUtil.SetActive(self.obj_killer, data.stage == 2)
	GOUtil.SetActive(self.obj_pass, data.stage == 1)

	local infoItem = ItemManager:Get(data.headId)

	UIUtil.SetImageSprite(self.img_icon, infoItem:GetIcon(), self)

	infoItem = ItemManager:Get(data.headFrame)

	UIUtil.SetImageSprite(self.img_frame, infoItem:GetIcon(), self)
end
