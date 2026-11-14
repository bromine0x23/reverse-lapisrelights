-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/BaseDataUtil.lua

BaseDataUtil = class("BaseDataUtil")

local billingProductAssetInfo = require("luaData/m_billing_product_asset")
local billingContentInfo = require("luaData/m_billing_product_content")
local itemData = require("luaData/ItemData")
local reasonCategories = {
	shopGoodsBuy = "SHOP_GOODS_BUY",
	buyDrawCard = "BUY_DRAW_CARD"
}

function BaseDataUtil.GetShopType(typeid)
	return protocol_pb.normal == typeid and "normal" or "pack"
end

function BaseDataUtil.GetContentVo(id, tp)
	local contentType = BaseDataUtil.GetShopType(tp)
	local result = {}

	for k, v in pairs(billingContentInfo) do
		if v.product_type == contentType and tonumber(v.product_id) == tonumber(id) and v.content_type ~= "goods_data" then
			local ct = {}

			ct.num = v.amount
			ct.is_paid = string.ToBool(v.is_paid)
			ct.price = tonumber(v.yen_price)

			if v.content_id ~= "" then
				ct.icon = "UIDyAtlas/Item/" .. itemData[v.content_id].Icon
				ct.asset = GetItemType(itemData[v.content_id].Type)
				ct.name = itemData[v.content_id].Name
				ct.id = v.content_id
			elseif v.content_type == "sns_coin" then
				ct.icon = BaseDataUtil.GetItemIcon(id, tp)
				ct.asset = protocol_pb.P_DIAMOND
			end

			table.insert(result, ct)
		end
	end

	printTable(result)

	return result
end

function BaseDataUtil.GetContentVoFromGoodsData(goodsdataid)
	local contentType = "goods_data"
	local result = {}

	for k, v in pairs(billingContentInfo) do
		if v.content_type == contentType and tonumber(v.content_id) == tonumber(goodsdataid) then
			local ct = {}

			ct.num = v.amount
			ct.is_paid = string.ToBool(v.is_paid)
			ct.price = tonumber(v.yen_price)
			ct.product_id = v.product_id
			ct.product_type = v.product_type

			table.insert(result, ct)
		end
	end

	printTable(result)

	return result
end

function BaseDataUtil.GetProductMasterInfoByPid(pid)
	local baseData

	if Application.platform:ToInt() == RuntimePlatform.Android then
		baseData = require("luaData/m_billing_google_product")
	else
		baseData = require("luaData/m_billing_apple_product")
	end

	for k, v in pairs(baseData) do
		if v.platform_product_id == pid then
			return {
				mid = v.product_id,
				type = v.product_type == "normal" and protocol_pb.normal or protocol_pb.pack
			}
		end
	end

	return nil
end

function BaseDataUtil.GetProductPriceByPid(pid)
	local baseData

	if Application.platform:ToInt() == RuntimePlatform.Android then
		baseData = require("luaData/m_billing_google_product")
	else
		baseData = require("luaData/m_billing_apple_product")
	end

	for k, v in pairs(baseData) do
		if v.platform_product_id == pid then
			return v.yen_price
		end
	end

	return nil
end

function BaseDataUtil.GetShopContent(id, type)
	local contentType = BaseDataUtil.GetShopType(type)
	local info = billingProductAssetInfo[id .. "+" .. contentType]

	if info then
		return info
	else
		return nil
	end
end

function BaseDataUtil.GetHistoryBalanceTitle(id, type)
	local contentType = BaseDataUtil.GetShopType(type)
	local info = billingProductAssetInfo[id .. "+" .. contentType]

	if info then
		return LanguageMgr.Localization(info.name)
	else
		return ""
	end
end

function BaseDataUtil.GetBillingContentInfo(product_id, type)
	local product_type = BaseDataUtil.GetShopType(type)
	local results = {}

	for k, v in pairs(billingContentInfo) do
		if v.product_type == product_type and tonumber(v.product_id) == tonumber(product_id) then
			table.insert(results, v)
		end
	end

	if #results == 1 then
		return results[1]
	elseif #results > 1 then
		for i, v in pairs(results) do
			if v.content_type == "goods_data" then
				return v
			end
		end

		return results[1]
	end

	return nil
end

function BaseDataUtil.CountPaidDiamonds(product_id, type)
	local vos = BaseDataUtil.GetContentVo(product_id, type)
	local count = 0

	for k, v in pairs(vos) do
		if v.is_paid then
			count = count + v.num
		end
	end

	return count
end

function BaseDataUtil.SortHistoryBalanceList(purchasedList)
	local listResult = {}
	local list1 = {}
	local list2 = {}
	local list3 = {}
	local counter = {}

	for i = 1, #purchasedList do
		local data = purchasedList[i]
		local product_id, type = data.shopProductId, data.billingProductType
		local key = product_id .. "_" .. type

		if counter[key] == nil then
			counter[key] = {
				amount = 0,
				shopProductId = product_id,
				billingProductType = type
			}
		end

		counter[key].amount = counter[key].amount + data.amount
	end

	for k, v in pairs(counter) do
		local data = v
		local product_id, type = data.shopProductId, data.billingProductType
		local info = BaseDataUtil.GetBillingContentInfo(product_id, type)

		if info.content_type ~= "sns_coin" then
			table.insert(list3, {
				shopProductId = product_id,
				billingProductType = type,
				name = string.format(_("m_virtual_money_history_BUY_MonthlyCard"), BaseDataUtil.GetHistoryBalanceTitle(product_id, type)),
				amount = data.amount
			})
		elseif info.product_type == "normal" then
			table.insert(list1, {
				shopProductId = product_id,
				billingProductType = type,
				name = string.format(_("m_virtual_money_history_BUY_DiamondSet"), BaseDataUtil.CountPaidDiamonds(product_id, type)),
				amount = data.amount
			})
		elseif info.product_type == "pack" then
			table.insert(list2, {
				shopProductId = product_id,
				billingProductType = type,
				name = string.format(_("m_virtual_money_history_BUY_DiamondSet"), BaseDataUtil.CountPaidDiamonds(product_id, type)),
				amount = data.amount
			})
		end
	end

	for i, list in ipairs({
		list1,
		list2,
		list3
	}) do
		table.sort(list, function(l, r)
			return l.shopProductId < r.shopProductId
		end)
		table.merge(listResult, list)
	end

	return listResult
end

function BaseDataUtil.GetItemIcon(id, type)
	local contentType = BaseDataUtil.GetShopType(type)
	local info = billingProductAssetInfo[id .. "+" .. contentType]

	if info then
		return info.image_asset_path
	else
		return ""
	end
end

function BaseDataUtil.GetItemDescrption(id, type)
	local contentType = BaseDataUtil.GetShopType(type)

	print(id .. "+" .. contentType)

	local info = billingProductAssetInfo[id .. "+" .. contentType]

	if info then
		return LanguageMgr.Localization(info.description)
	else
		return {}
	end
end

function BaseDataUtil.GetHistoryDeposit(id, type, price)
	local title = BaseDataUtil.GetHistoryBalanceTitle(id, type)

	return title .. "(¥" .. price .. ")"
end

function BaseDataUtil.GetHistoryConsume(cdata)
	local reasonSetting = require("luaData/m_virtual_money_history_reason_setting")
	local gachaTicketInfo = require("luaData/m_gacha_ticket")
	local reason = _(reasonSetting[cdata.reason].text) .. cdata.nameParam

	if tonumber(cdata.reasonId) > 0 then
		local reasonCat = reasonSetting[cdata.reason].reason

		if reasonCat == reasonCategories.buyDrawCard then
			reason = reason .. "-" .. Lang(require("luaData/CardPool")[cdata.reasonId].Name)
		elseif reasonCat == reasonCategories.shopGoodsBuy then
			reason = reason .. "-" .. Lang(require("luaData/GoodsData")[cdata.reasonId].Name)
		end
	end

	local contentName = ""

	if cdata.virtualMoneyType == protocol_pb.v_money_sns_coin then
		contentName = Lang(itemData[502].Name)
	elseif cdata.virtualMoneyType == protocol_pb.v_money_premium_gacha_ticket then
		contentName = Lang(itemData[gachaTicketInfo[cdata.virtualMoneyMasterId].oz_id].Name)
	end

	if cdata.free_money == 0 then
		return string.format("【%s】%s(%s)", reason, contentName, "有償:" .. cdata.paid_money)
	elseif cdata.paid_money == 0 then
		return string.format("【%s】%s(%s)", reason, contentName, "無償:" .. cdata.free_money)
	else
		return string.format("【%s】%s(%s,%s)", reason, contentName, "無償:" .. cdata.free_money, "有償:" .. cdata.paid_money)
	end
end
