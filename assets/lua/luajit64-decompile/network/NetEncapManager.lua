-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Network/NetEncapManager.lua

NetEncapManager = {}
NetEncapManager.dictData = Record()
NetEncapManager.goodsItemList = {}

function NetEncapManager:RequestPurchasePruduct(productId, goodsNum, extra, soulCost, callback, noShowAward)
	self.dictData:Set("P121", {
		id = productId,
		num = goodsNum,
		noShowAward = noShowAward
	})

	self.goodsItemList = {}

	local infoProduct = ShopManager:GetProduct(productId)

	if infoProduct and infoProduct.data then
		for index, value in ipairs(infoProduct.data.GoodsItemList) do
			table.insert(self.goodsItemList, value[1])
		end
	end

	NetManager:RequestPurchasePruduct(productId, goodsNum, extra, soulCost, callback)
end
