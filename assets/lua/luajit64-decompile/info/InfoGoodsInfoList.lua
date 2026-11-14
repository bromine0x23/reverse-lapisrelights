-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoGoodsInfoList.lua

InfoGoodsInfoList = class("InfoGoodsInfoList", InfoBase)

local ActiveConditionData = require("luaData/ActiveCondition")

function InfoGoodsInfoList:ctor(pb)
	self.pb = {}
end

GoodsInfoListMgr = {}
GoodsInfoListMgr.isFirst = true

function GoodsInfoListMgr:SetData(pb)
	self.goodsInfoList = {}

	for i = 1, #pb do
		self.goodsInfoList[i] = {}
		self.goodsInfoList[i].id = pb[i].id
		self.goodsInfoList[i].endTime = pb[i].endTime
	end

	self:SetLuckyRewardData()
end

function GoodsInfoListMgr:AddData(pb)
	local goodsInfo = {}

	goodsInfo.id = pb.activeGoods.id
	goodsInfo.endTime = tonumber(pb.activeGoods.endTime)

	table.insert(self.goodsInfoList, goodsInfo)

	for n in pairsByKeys(ActiveConditionData) do
		if ActiveConditionData[n].GoodsID == goodsInfo.id then
			goodsInfo.data = ActiveConditionData[n]
			goodsInfo.isShow = false
			self.luckyList[ActiveConditionData[n].CycleType] = goodsInfo

			break
		end
	end
end

function GoodsInfoListMgr:RemoveData(i)
	table.remove(self.goodsInfoList, i)
end

function GoodsInfoListMgr:SetLuckyRewardData()
	self.luckyList = {}

	for i = 1, #self.goodsInfoList do
		for n in pairsByKeys(ActiveConditionData) do
			if ActiveConditionData[n].GoodsID == self.goodsInfoList[i].id then
				local goodsInfo = {}

				goodsInfo.id = self.goodsInfoList[i].id
				goodsInfo.isShow = false
				goodsInfo.endTime = tonumber(self.goodsInfoList[i].endTime)
				goodsInfo.data = ActiveConditionData[n]
				self.luckyList[ActiveConditionData[n].CycleType] = goodsInfo

				break
			end
		end
	end
end

function GoodsInfoListMgr:GetLuckyList()
	return self.luckyList
end

function GoodsInfoListMgr:RemoveLuckyByType(cycleType)
	self.luckyList[cycleType] = nil
end
