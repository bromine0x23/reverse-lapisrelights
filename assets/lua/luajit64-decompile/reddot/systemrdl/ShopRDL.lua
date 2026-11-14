-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ShopRDL.lua

ShopRDL = {}

local RD_Shop_Branch_Path = {
	Acc = "Shop/Acc",
	Shop = "Shop/%d/%d"
}
local Can_Receive_Goods = {}
local Acc_Receive_Value = 0

function ShopRDL.Init()
	local lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Shop)

	if lock then
		RedDotSystemMgr.SetNodeLockState("Shop", true)
	end

	ShopRDL.InitShop()
	ShopRDL.RunShopRD()
	ShopRDL.RunAccRD()
end

function ShopRDL.InitShop()
	Can_Receive_Goods = {}

	local listAll = ShopManager.listAll

	for k, listShop in pairs(listAll) do
		local idx = ShopManager:FindTabIndexByType(k)

		Can_Receive_Goods[idx] = Can_Receive_Goods[idx] or {}

		for j = 1, #listShop do
			local infoShop = listShop[j]
			local listGood = infoShop.listGood

			if infoShop.id then
				Can_Receive_Goods[idx][infoShop.id] = Can_Receive_Goods[idx][infoShop.id] or {}

				if k ~= tabMainType.month then
					for n = 1, #listGood do
						local info = listGood[n]

						if info == nil then
							break
						end

						if info.data == nil then
							break
						end

						local discount = info.data.Discount
						local costValue = info.data.CostValue
						local isFree = false

						if info.data.Discount == 100 then
							if info.data.CostType == 1 then
								if costValue[1] == 0 then
									isFree = true
								end
							elseif costValue[2] == 0 then
								isFree = true
							end
						elseif info.data.CostType == 1 then
							local cost2 = math.floor(costValue[1] * (discount / 100))

							if tonumber(cost2) == 0 then
								isFree = true
							end
						else
							local cost2 = math.floor(costValue[2] * (discount / 100))

							if tonumber(cost2) == 0 then
								isFree = true
							end
						end

						if isFree and info.pb.myCount <= 0 and not table.contains(Can_Receive_Goods[idx][infoShop.id], info.data.ID) then
							table.insert(Can_Receive_Goods[idx][infoShop.id], info.data.ID)
						end
					end
				else
					local infoProduct = ShopManager:GetProduct(listGood[1].id)

					if infoProduct.id == 40005 and ShopManager:GetGrowthFund() and infoProduct:CanGetAward() and not table.contains(Can_Receive_Goods[idx][infoShop.id], infoProduct.data.ID) then
						table.insert(Can_Receive_Goods[idx][infoShop.id], infoProduct.data.ID)
					end

					if infoProduct.endAt > 0 and #infoProduct.data.RefreshAward > 0 and infoProduct:CanGetAward() and not table.contains(Can_Receive_Goods[idx][infoShop.id], infoProduct.data.ID) then
						table.insert(Can_Receive_Goods[idx][infoShop.id], infoProduct.data.ID)
					end
				end
			end
		end
	end
end

function ShopRDL.RunShopRD()
	for k, v in pairs(Can_Receive_Goods) do
		if not NoPay or k ~= 1 and k ~= 2 and k ~= 5 then
			for i, j in pairs(v) do
				RedDotSystemMgr.SetNodeValueByFormatPath(RD_Shop_Branch_Path.Shop, #j, k, i)
			end
		end
	end
end

function ShopRDL.RemoveGood(id)
	for k, v in pairs(Can_Receive_Goods) do
		for i, j in pairs(v) do
			if table.contains(j, id) then
				table.removeByValue(j, id)
				RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Shop_Branch_Path.Shop, -1, k, i)
			end
		end
	end
end

function ShopRDL.HasDotSecondTab(tabIdx, shopId)
	local temp = Can_Receive_Goods[tabIdx]

	if temp and temp[shopId] and #temp[shopId] > 0 then
		return true
	end

	return false
end

function ShopRDL.RunAccRD()
	local value = 0

	if ShopManager:CheckAccDot() then
		value = 1
	end

	if Acc_Receive_Value ~= value then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Shop_Branch_Path.Acc, value)

		Acc_Receive_Value = value
	end
end

return ShopRDL
