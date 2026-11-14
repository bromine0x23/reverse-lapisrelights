-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/CellUnionWish.lua

require("UI/Item/UIItemBase")

CellUnionWish = class("CellUnionWish", UIItemBase)

function CellUnionWish:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellUnionWish:OnEnter(vParam)
	local g = self.UIRootObject

	self:DealWithLocalization(g)

	self.GoNone = GOUtil.FindChildGameObject(g, "None")
	self.GoPanel = GOUtil.FindChildGameObject(g, "Panel")
	self.GoBg1 = GOUtil.FindChildGameObject(g, "Panel/Bg1")
	self.GoBg2 = GOUtil.FindChildGameObject(g, "Panel/Bg2")
	self.GoDot = GOUtil.FindChildGameObject(self.GoBg1, "Dot")
	self.TxtPlayerName = GOUtil.FindChildComponent(g, "Panel/TxtPlayerName", "Text")
	self.ImgStoneIcon = GOUtil.FindChildComponent(g, "Panel/ImgStoneIcon", "Image")
	self.TxtStoneName = GOUtil.FindChildComponent(g, "Panel/TxtStoneName", "Text")
	self.TxtHoldCount = GOUtil.FindChildComponent(g, "Panel/TxtHoldCount", "Text")
	self.ImgRate = GOUtil.FindChildComponent(g, "Panel/WishRate/Bar", "Image")
	self.TxtRate = GOUtil.FindChildComponent(g, "Panel/WishRate/TxtRate", "Text")
	self.GoGeted = GOUtil.FindChildGameObject(g, "Panel/GoGeted")
	self.GoGifted = GOUtil.FindChildGameObject(g, "Panel/GoGifted")
	self.GoMine = GOUtil.FindChildGameObject(g, "Panel/TxtMine")
	self.BtnGift = GOUtil.FindChildGameObject(g, "Panel/BtnGift")
	self.ImgGift = GOUtil.GetComponent(self.BtnGift, "Image")

	self:AddClick(self.BtnGift, self.OnClickedBtnGift)
end

function CellUnionWish:DealWithLocalization(g)
	local txt

	txt = GOUtil.FindChildComponent(g, "Panel/BtnGift/Text", "Text")
	txt.text = _("UI_Donate_Once")
	txt = GOUtil.FindChildComponent(g, "Panel/TxtMine", "Text")
	txt.text = _("Union_Wish_Mine")
end

function CellUnionWish:UpdateData(infoUnionWish, index)
	GOUtil.SetActive(self.GoNone, infoUnionWish.pb == nil)
	GOUtil.SetActive(self.GoPanel, infoUnionWish.pb ~= nil)

	if not infoUnionWish.pb then
		return
	end

	self.info = infoUnionWish

	local infoCard = RoleCardMgr:GetRoleCard(infoUnionWish.pb.roleCard)

	self.isHave = infoCard.pb.soul > 0

	local soulId = ItemManager:GetCardSoulId(infoUnionWish.pb.roleCard)
	local infoItem = ItemManager:Get(soulId)

	self.TxtPlayerName.text = infoUnionWish.pb.playerName

	SetImageSprite(self.ImgStoneIcon, infoItem:GetIcon(), self)

	self.TxtStoneName.text = Lang(infoItem.data.Name)
	self.TxtHoldCount.text = _("Desc_itemTipNum") .. infoCard.pb.soul
	self.ImgRate.fillAmount = infoUnionWish.pb.grant / infoUnionWish.pb.need
	self.TxtRate.text = infoUnionWish.pb.grant .. "/" .. infoUnionWish.pb.need

	local isMine = infoUnionWish:IsMine()
	local isReached = infoUnionWish:IsReached()
	local isGifted = infoUnionWish:IsGifted()

	GOUtil.SetActive(self.GoBg1, isMine)
	GOUtil.SetActive(self.GoBg2, not isMine)
	GOUtil.SetActive(self.GoDot, isMine and UnionRDL.WishRDL.HasWishDot())
	GOUtil.SetActive(self.GoMine, isMine and not isReached)
	GOUtil.SetActive(self.GoGeted, isReached)
	GOUtil.SetActive(self.GoGifted, isGifted and not isReached)
	GOUtil.SetActive(self.BtnGift, not isMine and not isReached and not isGifted)
	DealWithListRef(self, UIUtil.SetImageGray(self.ImgGift, TenaryOp(self.isHave, 0, 1)))
end

function CellUnionWish:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.BtnGift, self.OnClickedBtnGift)
end

function CellUnionWish:OnClickedBtnGift()
	if not self.isHave then
		UIMgr.ShowMsg(_("Msg_Star_Stone_Null"))

		return
	end

	local playerId = self.info.id
	local grant = 1

	local function callback(index3)
		if index3 == 1 then
			local function wrap_cb(vMsg)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vMsg.result.code == NetManager.Result_Sucess then
					self.info:ChangeSelfGrant()
					self.info:ChangeGrant(grant)

					if self.page then
						self.page:UpdateWishList()
					else
						Event.Instance:Fire("UpdateWishList")
					end
				elseif vMsg.result.code == 2 then
					PageUnion.GoBackMainPage(vMsg)
				elseif vMsg.result.code == 3 then
					UIMgr.ShowMsg(vMsg.result.desc, vMsg)

					if self.page then
						self.page.RequestData()
					end
				else
					UIMgr.ShowMsg(vMsg.result.desc, vMsg)
				end
			end

			NetManager:RequestReachPlayerWish(playerId, grant, wrap_cb)
			LoadingMgr.Show(eLoadingType.Repeat)
		end
	end

	local strTitle = _("Desc_Alert")
	local strOkText = _("UI_OK")
	local strCancelText = _("Quite_Cancel")
	local msg = _("Desc_Gift_Wish_Tips")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, msg, callback, strOkText, strCancelText)
end
