-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/DlgWishDetail.lua

require("UI/Page/PageUnionFunction/CellPlayerGift")

DlgWishDetail = class("DlgWishDetail", UIPanel)

function DlgWishDetail:ctor()
	self.UIPrefabPath = "UI/PanelUnionFunction/DlgWishDetail"
end

function DlgWishDetail:PreLoad()
	self:LoadResAsync("UI/PanelUnionFunction/CellPlayerGift", "PrefabCellPlayerGift", GameObject)
end

function DlgWishDetail:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellPlayerGift)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgWishDetail:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgWishDetail:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgWishDetail:OnEnter(vParam)
	self:DealWithLocalization()

	self.TxtSoulName = self:GetChildComponent("Panel/Stone/BgName/TxtName", "Text")
	self.TxtSoulHold = self:GetChildComponent("Panel/Stone/BgName/TxtHold", "Text")
	self.ImgSoulIcon = self:GetChildComponent("Panel/Stone/BgIcon/Icon", "Image")
	self.ImgSoulRate = self:GetChildComponent("Panel/Stone/BgRate/Rate", "Image")
	self.TxtCompRate = self:GetChildComponent("Panel/Stone/TxtCompNum", "Text")
	self.GoPrompt = self:GetChildGameObject("Panel/Gift/TxtNone")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")

	self:UpdatePanel()
end

function DlgWishDetail:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/Title/Text", "Text")
	Text.text = _("Union_Wish_Geted")
	Text = self:GetChildComponent("Panel/Gift/TxtNone", "Text")
	Text.text = _("Desc_Wish_Geted_None")
end

function DlgWishDetail:UpdatePanel()
	self:UpdateWish()
	self:UpdateGiftList()
end

function DlgWishDetail:UpdateWish()
	self.infoMineWish = UnionWishMgr:GetMineWishs()[1]

	local infoSoul = self.infoMineWish:GetWishSoul()

	self.TxtSoulName.text = Lang(infoSoul.data.Name)
	self.TxtSoulHold.text = _("Desc_itemTipNum") .. self.infoMineWish:GetWishCard().pb.soul

	SetImageSprite(self.ImgSoulIcon, infoSoul:GetIcon(), self)

	self.ImgSoulRate.fillAmount = self.infoMineWish.pb.grant / self.infoMineWish.pb.need
	self.TxtCompRate.text = string.format(_("Desc_Wish_Finish"), self.infoMineWish.pb.grant)
end

function DlgWishDetail:UpdateGiftList()
	self.listRecvGift = UnionWishRecvMgr.listRecvGift

	if #self.listRecvGift ~= 0 then
		SetActiveFunc(self.GoPrompt, false)
	end

	self:UpdateScrollView()
end

function DlgWishDetail:UpdateScrollView()
	if self.UIScrollTool then
		self.UIScrollTool:UpdateListDataKeepPos(self.listRecvGift)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/Gift/ScrollArea")
	local content = self:GetChildComponent("Panel/Gift/ScrollArea/Content", "RectTransform")
	local count = #self.listRecvGift

	local function addCallback(item)
		return
	end

	local function updateCallback(item, index)
		local info = self.listRecvGift[index]

		item:UpdateData(info)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellPlayerGift, CellPlayerGift, self, false, addCallback, updateCallback)
end

function DlgWishDetail:Show(isShow)
	self.UIRootObject:SetActive(isShow)
end

function DlgWishDetail:OnClickedBtnClose()
	self:Show(false)
	UnionRDL.WishRDL.SubRD()
	Event.Instance:Fire("UpdateWishList")
end
