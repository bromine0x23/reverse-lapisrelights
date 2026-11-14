-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/BillingManager.lua

BillingManager = {}
BillingManager.OnPaySuceed = "OnPaySuceed"

local listLimitedProducts = require("luaData/m_billing_limited_product")

require("UI/Page/PagePay/PageAgeLimitConfirm")
require("Info/Player")

local customizedErrorMsg = ""

function BillingManager.DefaultPrePurchaseRequest(preProduct, cb_suceed, cb_failed)
	customizedErrorMsg = ""

	local function wrap_cb(res)
		print("on prepay back " .. res.result.code)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if res.result.code == NetManager.Result_Sucess then
			OzBillingJackPot.OnGamePrePaysucceedLua(cb_suceed, preProduct, PlayerInst.InfoPlayer.pid)
		else
			if res.resultCode == protocol_pb.failure_overflow_max_coin then
				customizedErrorMsg = _("PageAgeSetting_description12")
			end

			OzBillingJackPot.OnGamePrePayFailedLua(cb_failed, preProduct.Id, res.result.desc)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestPrepurchase(preProduct.Id, wrap_cb)
end

function BillingManager.DebugPurchasedRequest(prodId, cb_suceed, cb_failed)
	local function wrap_cb(res)
		print("on pay back " .. res.result.code)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if res.result.code == NetManager.Result_Sucess then
			OzBillingJackPot.OnGamePaysucceedLua(cb_suceed)
		else
			OzBillingJackPot.OnGamePayFailedDebugLua(cb_failed, res.result.desc)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestDebugBillTask(prodId, wrap_cb)
end

function BillingManager.DefaultPurchasedRequest(proId, receipt, transId, price, formattedprice, cb_suceed, cb_failed)
	print("start resume buy")
	print(proId)
	print(receipt)
	print(transId)
	print(price)
	print(formattedprice)

	local function wrap_cb(res)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if res.resultCode == protocol_pb.processed_successfully or res.resultCode == protocol_pb.payload_diff_current then
			OzBillingJackPot.OnGamePaysucceedLua(cb_suceed)

			if res.resultCode == protocol_pb.processed_successfully then
				local storeData = BaseDataUtil.GetProductMasterInfoByPid(proId)

				Event.Instance:Fire(BillingManager.OnPaySuceed, {
					id = storeData.mid,
					type = storeData.type
				})
			end
		elseif res.resultCode == protocol_pb.failure_amount_limit_exceeded or res.resultCode == protocol_pb.failure_out_of_salable_term then
			OzBillingJackPot.OnGamePaysucceedLua(cb_suceed)
		else
			OzBillingJackPot.OnGamePayFailedLua(cb_failed, res.message, res.resultCode)
		end
	end

	local platform = Application.platform:ToInt() == RuntimePlatform.Android and protocol_pb.google or protocol_pb.apple

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBillTask(receipt, transId, price, formattedprice, platform, wrap_cb)
end

function BillingManager.Purchase(id, billingProId, productType, onRecipt, onSuceed, onFailed)
	print("purchase product " .. id)
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestSaveOperationLog(productType, tonumber(id), protocol_pb.start, function()
		LoadingMgr.Hide(eLoadingType.Repeat)
		OzBillingJackPot.Purchase(billingProId, onRecipt, onSuceed, function(err)
			local status = err.IsCancelled and protocol_pb.cancel or protocol_pb.failure

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestSaveOperationLog(productType, tonumber(id), status, function()
				LoadingMgr.Hide(eLoadingType.Repeat)
				onFailed(err)
			end)
		end)
	end)
end

function BillingManager:CheckPayStateAndPurchase(productId, shopProductId, price, productType, root, isSecond)
	if not OzBillingJackPot.IsBillingSupported() then
		UIMgr.ShowDialog(_("PageShop_error_description"), nil)

		return
	end

	print(productId)
	print(shopProductId)

	local function canBuyAction()
		local numPrice = tonumber(price)

		if PlayerInst.InfoPlayer.billingState ~= nil and PlayerInst.InfoPlayer.billingState.age ~= -1 then
			if PlayerInst.InfoPlayer.billingState.age < 18 then
				self:CheckBeforePurchase(productId, shopProductId, numPrice, productType, root)
			else
				self:PurchaseNormally(productId, shopProductId, productType)
			end
		else
			require("UI/Page/PagePay/PageAgeSetting")
			UIMgr.AddPanel(PageAgeSetting(), {
				callback = function()
					BillingManager:CheckPayStateAndPurchase(productId, shopProductId, price, productType, root, true)
				end
			}, root)
		end
	end

	if not isSecond and self:NeedDebtCaution(productId) then
		UIMgr.ShowCommon(DlgCommonEvent.Type.Large, _("Tittle_Affirm"), {
			text = _("Deduct_Snscion_inform"),
			align = TextAnchor.MiddleLeft
		}, function(index)
			if index == 1 then
				canBuyAction()
			end
		end, _("PagePlatform__ok"), _("PagePlatform__cancel"))
	else
		canBuyAction()
	end
end

function BillingManager:NeedDebtCaution(productId)
	if not PlayerInst.InfoPlayer.isFreeCoinDebt then
		return false
	end

	local content = require("luaData/m_billing_product_content")
	local isDebtItem = false
	local monthCard = {
		7,
		8,
		9
	}
	local numProdId = tonumber(productId)

	if table.contains(monthCard, numProdId) then
		isDebtItem = numProdId ~= 8
	else
		for k, v in pairs(content) do
			if tonumber(v.product_id) == numProdId and v.is_paid == "FALSE" and v.content_type == "sns_coin" then
				isDebtItem = true

				break
			end
		end
	end

	return isDebtItem
end

function BillingManager:GetLimitPrice()
	local limitTb = require("luaData/m_billing_age_limit")
	local limitPrice = 0

	for k, v in pairs(limitTb) do
		if v.age >= PlayerInst.InfoPlayer.billingState.age then
			limitPrice = math.max(v.limit_price, limitPrice)

			return limitPrice
		end
	end

	return limitPrice
end

function BillingManager:CheckBeforePurchase(productId, shopProductId, price, type, root)
	local limitPrice = self:GetLimitPrice()

	if limitPrice < PlayerInst.InfoPlayer.billingState.currentMonthPurchasePrice + price then
		UIMgr.AddPanel(PageAgeLimitConfirm(), {
			is_limited = true,
			callback = function(idx)
				return
			end
		}, root)
	else
		UIMgr.AddPanel(PageAgeLimitConfirm(), {
			is_limited = false,
			callback = function(idx)
				if idx == 1 then
					self:PurchaseNormally(productId, shopProductId, type)
				else
					UIMgr.ShowDialog(_("PageAgeSetting_description7"), nil)
				end
			end
		}, root)
	end
end

function BillingManager:PurchaseNormally(productId, billingProId, productType)
	local function wrap_cb_top()
		LoadingMgr.Show(eLoadingType.Repeat)

		local isExpire = false

		BillingManager.Purchase(productId, billingProId, productType, function(receipt, transId, price, formattedprice, cb_suceed, cb_failed)
			print(receipt)
			print(transId)
			print(price)
			print(formattedprice)

			local function wrap_cb(res)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if res.resultCode == protocol_pb.processed_successfully then
					OzBillingJackPot.OnGamePaysucceedLua(cb_suceed)
				elseif res.resultCode == protocol_pb.failure_amount_limit_exceeded or res.resultCode == protocol_pb.failure_out_of_salable_term then
					isExpire = true

					OzBillingJackPot.OnGamePaysucceedLua(cb_suceed)
				else
					OzBillingJackPot.OnGamePayFailedLua(cb_failed, res.message, res.resultCode)
				end
			end

			local platform = Application.platform:ToInt() == RuntimePlatform.Android and protocol_pb.google or protocol_pb.apple

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestBillTask(receipt, transId, price, formattedprice, platform, wrap_cb)
		end, function(purchaseType)
			if isExpire then
				return
			end

			print("suceed")
			LoadingMgr.Hide(eLoadingType.Repeat)

			if purchaseType == Jackpot.Billing.PurchaseSuccessTypes.Pending then
				UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("PageShop_buy_description"), _("PageShop_order_status"), nil, _("PageAgeSetting_yes"))
			elseif purchaseType == Jackpot.Billing.PurchaseSuccessTypes.NoPurchases then
				UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("PageShop_buy_description"), _("PageShop_buy_fail"), nil, _("PageAgeSetting_yes"))
			else
				local title = BaseDataUtil.GetHistoryBalanceTitle(productId, productType)
				local localPrice = BaseDataUtil.GetProductPriceByPid(billingProId)

				if localPrice ~= nil then
					AppsFlyerService.TrackPurchaseEvent(tostring(localPrice), title, billingProId, "JPY")
				end

				Event.Instance:Fire(BillingManager.OnPaySuceed, {
					id = productId,
					type = productType
				})
			end
		end, function(err)
			print("failed")
			LoadingMgr.Hide(eLoadingType.Repeat)
			BillingManager:ShowErrorPopup(err)
		end)
	end

	local limitProdId = tonumber(productId)
	local limitType = 0

	for k, v in pairs(listLimitedProducts) do
		if limitProdId == v.product_id and v.product_type == "normal" then
			if v.limited_amount and v.limited_amount > 0 then
				limitType = limitType + 1
			end

			if v.end_at and v.end_at ~= "" then
				limitType = limitType + 2
			end

			break
		end
	end

	print(">>>>>>" .. limitType)

	if limitType > 0 then
		local msg = ""

		if limitType == 1 then
			msg = "m_caution_setting_caution_amount_limit"
		elseif limitType == 2 then
			msg = "m_caution_setting_caution_time_limit"
		elseif limitType == 3 then
			msg = "m_caution_setting_caution_amount_plus_time_limit"
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Large, _("Tittle_Affirm"), _(msg), function(index)
			if index == 1 then
				wrap_cb_top()
			else
				LoadingMgr.Hide(eLoadingType.Repeat)
			end
		end, _("UI_OK"), _("Button_Cancel"))
	else
		wrap_cb_top()
	end
end

function BillingManager:ShowErrorPopup(err)
	local errMsg = ""
	local cb

	if err.IsBillingNotSupported then
		errMsg = _("PageShop_not_billing_supported")
	end

	if err.IsCancelled then
		errMsg = _("PageShop_billing_purchase_cancel")
	end

	if err.IsFailedOnPurchasedRequest then
		if err.PurchasedResponseKind == Jackpot.Billing.PurchasedResponseKind.ReceiptOutOfDate then
			errMsg = _("PageShop_billing_expired_product")
		else
			errMsg = _("PageShop_billing_failure_platform_connect_shop")

			function cb()
				Launcher.Instance:Restart()
			end
		end
	end

	if customizedErrorMsg ~= "" then
		errMsg = customizedErrorMsg
		customizedErrorMsg = ""
	end

	if errMsg == "" then
		errMsg = _("PageShop_billing_failure_purchase_shop")
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("PageShop_buy_fail"), errMsg, cb, _("PageAgeSetting_yes"))
end

function BillingManager.Resume(call_back)
	OzBillingJackPot.Resume(call_back)
end

function BillingManager.GetProductList(ids, suceed, failed)
	LoadingMgr.Show(eLoadingType.Repeat)
	OzBillingJackPot.GetProductList(ids, suceed, failed)
end
