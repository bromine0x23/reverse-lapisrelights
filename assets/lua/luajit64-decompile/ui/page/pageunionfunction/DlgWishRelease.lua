-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/DlgWishRelease.lua

require("UI/Page/PageUnionFunction/CellWish")

DlgWishRelease = class("DlgWishRelease", UIPanel)

function DlgWishRelease:ctor()
	self.UIPrefabPath = "UI/PanelUnionFunction/DlgWishRelease"
end

function DlgWishRelease:PreLoad()
	self:LoadResAsync("UI/PanelUnionFunction/CellWish", "PrefabCellWish", GameObject)
end

function DlgWishRelease:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgWishRelease:OnLeave()
	ResourceMgr.Unload(self.PrefabCellWish)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgWishRelease:OnRegisterEvent()
	self:AddClick(self.BtnRelease, self.OnClickedBtnRelease)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
end

function DlgWishRelease:OnUnRegisterEvent()
	self:RemoveClick(self.BtnRelease, self.OnClickedBtnRelease)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgWishRelease:OnEnter(vParam)
	self:DealWithLocalization()

	self.BtnRelease = self:GetChildGameObject("Panel/BtnRelease")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.ImgBtnRelease = GOUtil.GetComponent(self.BtnRelease, "Image")

	self:UpdatePanel()
end

function DlgWishRelease:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/Title/Text", "Text")
	Text.text = Lang(2010)
	Text = self:GetChildComponent("Panel/BtnRelease/Text", "Text")
	Text.text = _("UI_Release")
end

function DlgWishRelease:UpdatePanel()
	self.listWish = UnionWishMgr:GetCanReleaseWishs()

	local canRelease = UnionWishMgr:CanReleaseWish()

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnRelease, TenaryOp(canRelease, 0, 1)))

	self.curWishIdx = 1

	self:InitScrollView()
end

function DlgWishRelease:InitScrollView()
	if self.inited then
		self.UIScrollTool:UpdateListData(self.listWish)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/Wish/ScrollArea")
	local content = self:GetChildComponent("Panel/Wish/ScrollArea/Content", "RectTransform")
	local count = #self.listWish

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellWish, CellWish, self)
end

function DlgWishRelease:UpdateCell(item, index)
	local info = self.listWish[index]

	item:UpdateData(info, self.curWishIdx)
end

function DlgWishRelease:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCellWish)
end

function DlgWishRelease:OnClickedCellWish(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if index == self.curWishIdx then
		return
	end

	self.curWishIdx = index

	self.UIScrollTool:UpdateListDataKeepPos(self.listWish)
end

function DlgWishRelease:OnClickedBtnRelease()
	if not self.curWishIdx then
		UIMgr.ShowMsg(_("Msg_Select_Wish_First"))

		return
	end

	local canRelease = UnionWishMgr:CanReleaseWish()

	if not canRelease then
		UIMgr.ShowMsg(_("Msg_Wish_Released_Today"))

		return
	end

	local roleCardId = self.listWish[self.curWishIdx].info.data.Value
	local need = self.listWish[self.curWishIdx].need

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			UnionWishMgr:SetMineWish(roleCardId, need)
			Event.Instance:Fire("UpdateUnionWish")
			self:Close()
		elseif vMsg.result.code == 2 then
			self:Close()
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestReleaseWish(roleCardId, need, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgWishRelease:OnClickedBtnClose()
	self:Close()
end
