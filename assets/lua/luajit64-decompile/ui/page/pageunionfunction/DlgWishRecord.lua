-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/DlgWishRecord.lua

require("UI/Page/PageUnionFunction/CellWishRecord")

DlgWishRecord = class("DlgWishRecord", UIPanel)

function DlgWishRecord:ctor()
	self.UIPrefabPath = "UI/PanelUnionFunction/DlgWishRecord"
end

function DlgWishRecord:PreLoad()
	self:LoadResAsync("UI/PanelUnionFunction/CellWishRecord", "PrefabCellWishRecord", GameObject)
end

function DlgWishRecord:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellWishRecord)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgWishRecord:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgWishRecord:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgWishRecord:OnEnter(vParam)
	self:DealWithlocalization()

	self.GoPrompt = self:GetChildGameObject("Panel/Text")
	self.BtnClose = self:GetChildGameObject("Panel/Button")

	self:UpdatePanel()
end

function DlgWishRecord:DealWithlocalization()
	local txt

	txt = self:GetChildComponent("Panel/Title/Text", "Text")
	txt.text = _("Union_Wish_Record")
	txt = self:GetChildComponent("Panel/Text", "Text")
	txt.text = _("Desc_Union_Wish_Record_None")
end

function DlgWishRecord.RequestData()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			UIMgr.AddPanel(DlgWishRecord())
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestMineWishRecords(wrap_cb)
end

function DlgWishRecord:UpdatePanel()
	self.listRecord = UnionWishRecordMgr.listRecord or {}

	if #self.listRecord ~= 0 then
		GOUtil.SetActive(self.GoPrompt, false)
	end

	self:UpdateScrollView()
end

function DlgWishRecord:UpdateScrollView()
	if self.UIScrollTool then
		self.UIScrollTool:UpdateListDataKeepPos(self.listRecord)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.listRecord

	local function addCallback(item)
		return
	end

	local function updateCallback(item, index)
		local info = self.listRecord[index]

		item:UpdateData(info)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellWishRecord, CellWishRecord, self, false, addCallback, updateCallback)
end

function DlgWishRecord:OnClickedBtnClose()
	self:Close()
end
