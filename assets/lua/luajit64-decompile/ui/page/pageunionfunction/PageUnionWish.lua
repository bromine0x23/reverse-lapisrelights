-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/PageUnionWish.lua

require("UI/Page/PageUnionFunction/CellUnionWish")
require("UI/Page/PageUnionFunction/DlgWishRelease")
require("UI/Page/PageUnionFunction/DlgWishDetail")
require("UI/Page/PageUnionFunction/DlgWishRecord")

PageUnionWish = class("PageUnionWish", UIPanel)

function PageUnionWish:ctor()
	self.UIPrefabPath = "UI/PanelUnionFunction/PanelUnionWish"

	self:AddChildPanel(DlgExit(), {
		title = _("Item_From_19_3"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageUnionWish:PreLoad()
	self:LoadResAsync("UI/PanelUnionFunction/CellUnionWish", "PrefabCellUnionWish", GameObject)
end

function PageUnionWish:OnBack()
	local prePanel = UIMgr.GetPrePanel()

	if prePanel.className == "PageUnion" then
		UIMgr.PopPanel({
			isShowBank = true,
			needRequestUnion = true
		})
	else
		UIMgr.PopPanel()
	end
end

function PageUnionWish:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function PageUnionWish:OnLeave()
	ResourceMgr.Unload(self.PrefabCellUnionWish)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	UITweenUtil.RemoveTween(self.content)
end

function PageUnionWish:OnRegisterEvent()
	self:AddClick(self.BtnView, self.OnClickedBtnView)
	self:AddClick(self.BtnWish, self.OnClickedBtnWish)
	Event.Instance:Add("UpdateWishList", self.UpdateWishList, self)
	Event.Instance:Add("UpdateUnionWish", self.UpdatePanel, self)
	Event.Instance:Add("UpdateWishData", self.RequestWishAward, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateWishList, self)
end

function PageUnionWish:OnUnRegisterEvent()
	self:RemoveClick(self.BtnView, self.OnClickedBtnView)
	self:RemoveClick(self.BtnWish, self.OnClickedBtnWish)
	Event.Instance:Remove("UpdateWishList", self.UpdateWishList, self)
	Event.Instance:Remove("UpdateUnionWish", self.UpdatePanel, self)
	Event.Instance:Remove("UpdateWishData", self.RequestWishAward, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateWishList, self)
end

function PageUnionWish.RequestData(cb, notNeedLeave)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if cb then
				cb()
			end
		elseif vMsg.result.code == 2 then
			if not notNeedLeave then
				PageUnion.GoBackMainPage(vMsg)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestUnionWishList(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageUnionWish:RequestWishAward()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			UnionWishRecvMgr:ChangeCanReceiveState(false)
			self:UpdateScrollView()

			if self.DlgWishDetail ~= nil and GOUtil.IsActiveSelf(self.DlgWishDetail.UIRootObject) then
				self.DlgWishDetail:UpdateScrollView()
			end
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetWish(wrap_cb)
end

function PageUnionWish:OnEnter()
	if not GuideMgr:IsGuided(GuideFunctionType.UnionWish) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.UnionWish)
	end

	self:DealWithLocalization()

	self.TimeIsShow = true
	self.GoRefTime = self:GetChildGameObject("Panel/PdtWish/RefTime")
	self.TxtTime = self:GetChildComponent("Panel/PdtWish/RefTime/TxtTime", "Text")
	self.GoNoneWish = self:GetChildGameObject("Panel/GoNone")
	self.BtnWish = self:GetChildGameObject("Panel/PdtWish/BtnWish")
	self.ImgBtnWish = GOUtil.GetComponent(self.BtnWish, "Image")
	self.BtnView = self:GetChildGameObject("BtnView")

	self:UpdatePanel()

	if UnionWishRecvMgr.ExistCanReceive then
		self:RequestWishAward()
	end
end

function PageUnionWish:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/PdtWish/BtnWish/Text", "Text")
	txt.text = Lang(2010)
	txt = self:GetChildComponent("Panel/PdtWish/RefTime/Text", "Text")
	txt.text = _("Union_Wish_Countdown")
	txt = self:GetChildComponent("Panel/GoNone/Text", "Text")
	txt.text = _("Desc_Union_Wish_None")
end

function PageUnionWish:UpdatePanel()
	self.listUnionWish = UnionWishMgr.listUnionWish or {}

	GOUtil.SetActive(self.GoNoneWish, next(self.listUnionWish) == nil)
	self:UpdateScrollView()

	self.canRelease = UnionWishMgr:CanReleaseWish()

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnWish, TenaryOp(self.canRelease, 0, 1)))

	if self.canRelease and self.TimeIsShow then
		GOUtil.SetActive(self.GoRefTime, false)

		self.TimeIsShow = false
	end
end

function PageUnionWish:OnUpdateSecond()
	if self.canRelease then
		return
	end

	if self.TxtTime == nil then
		return
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if not self.nextRefreshTime then
		local dataTable = os.date("*t", curServerTime)
		local pHour = 4

		if pHour <= dataTable.hour then
			local time = curServerTime + 1 * DateUtil.SecsPerDay

			dataTable = os.date("*t", time)
		end

		self.nextRefreshTime = os.time({
			second = 0,
			minute = 0,
			day = dataTable.day,
			month = dataTable.month,
			year = dataTable.year,
			hour = pHour
		})
	end

	if curServerTime <= self.nextRefreshTime then
		self.TxtTime.text = GetTimeFormatBySecond(self.nextRefreshTime - curServerTime, "hour")
	else
		self.nextRefreshTime = nil
	end

	if not self.TimeIsShow then
		GOUtil.SetActive(self.GoRefTime, true)

		self.TimeIsShow = true
	end
end

function PageUnionWish:UpdateScrollView()
	if self.UIScrollTool then
		self.UIScrollTool:UpdateListData(self.listUnionWish)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollArea")

	self.content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")

	local count = #self.listUnionWish

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCellUnionWish)
	end

	local function updateCallback(item, index)
		item:UpdateData(self.listUnionWish[index])
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCellUnionWish, CellUnionWish, self, false, addCallback, updateCallback)
	UITweenUtil.OrderAlphaAnim(self.content, 0.2)
end

function PageUnionWish:SetUnionWish()
	return
end

function PageUnionWish:OnClickedCellUnionWish(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local infoUnionWish = self.listUnionWish[index]

	if infoUnionWish:IsMine() then
		local function cb()
			if self.DlgWishDetail == nil or self.DlgWishDetail.closed then
				self.DlgWishDetail = DlgWishDetail()

				self:AddChildPanel(self.DlgWishDetail)
				self.DlgWishDetail:Create(self.UIRootObject)
			else
				self.DlgWishDetail:Show(true)
				self.DlgWishDetail:UpdateScrollView()
			end
		end

		if not UnionWishRecvMgr.Requested then
			LoadingMgr.Show(eLoadingType.Repeat)

			local function wrap_cb(vMsg)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vMsg.result.code == NetManager.Result_Sucess then
					cb()
				elseif vMsg.result.code == 2 then
					PageUnion.GoBackMainPage(vMsg)
				else
					UIMgr.ShowMsg(vMsg.result.desc, vMsg)
				end
			end

			NetManager:RequestGetWish(wrap_cb)
		else
			cb()
		end
	else
		UIMgr.ShowMsg(_("Msg_View_OtherWish_Disable"))
	end
end

function PageUnionWish:UpdateWishList()
	self.UIScrollTool:UpdateListDataKeepPos(self.listUnionWish)
end

function PageUnionWish:OnClickedBtnWish()
	local canRelease = UnionWishMgr:CanReleaseWish()

	if not canRelease then
		UIMgr.ShowMsg(_("Msg_Wish_Released_Today"))

		return
	end

	UIMgr.AddPanel(DlgWishRelease())
end

function PageUnionWish:OnClickedBtnView()
	DlgWishRecord.RequestData()
end

function PageUnionWish:OnClickedBtnGuide()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.UnionWish)
end
