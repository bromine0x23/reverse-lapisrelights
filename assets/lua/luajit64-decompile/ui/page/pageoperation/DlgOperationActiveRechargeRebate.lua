-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveRechargeRebate.lua

require("UI/Item/UIItemBase")

DlgOperationActiveRechargeRebate = class("DlgOperationActiveRechargeRebate", UIItemBase)

function DlgOperationActiveRechargeRebate:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveRechargeRebate:Purge()
	self:UnloadRef()
end

function DlgOperationActiveRechargeRebate:UnloadRef()
	self:RemoveClick(self.btn_open, self.OnClickedOpen)
	self.infoActive:ClearOperationSpine()
	UnloadAllImageSprite(self)
end

function DlgOperationActiveRechargeRebate:OnRegisterEvent()
	return
end

function DlgOperationActiveRechargeRebate:OnUnRegisterEvent()
	return
end

function DlgOperationActiveRechargeRebate:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell

	local g = self.UIRootObject

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.btn_open = GOUtil.FindChildGameObject(g, "Panel/btn_open")
	self.HorLayoutText1 = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/HorLayout/Text1", "Text")
	self.HorLayoutText2 = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/HorLayout/Text2", "Text")

	self:AddClick(self.btn_open, self.OnClickedOpen)
end

function DlgOperationActiveRechargeRebate:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveRechargeRebate:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	local Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 1, "Text")

	Text.text = _("Desc_Rebate")
	Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 2, "Text")

	local info = OperationActiveMgr:GetRechargeRebate()

	if info then
		self.rebateValue = info.data.DailyTime[1][1]

		if info.pb.record <= 30000 then
			local value1 = 10
			local value2 = 10

			self.HorLayoutText1.text = info.pb.record * value1 / 100
			self.HorLayoutText2.text = info.pb.record * value2 / 100
		else
			local tempRecord = 0
			local sumValue1 = 0
			local value2 = 10

			self.HorLayoutText2.text = info.pb.record * value2 / 100

			local value1 = 10

			tempRecord = info.pb.record - 30000
			sumValue1 = 30000 * value1 / 100
			value1 = 5
			sumValue1 = tempRecord * value1 / 100 + sumValue1
			self.HorLayoutText1.text = sumValue1
		end
	end

	self:DealWithLocalization(self.ActiveID)
end

function DlgOperationActiveRechargeRebate:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	local Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 1, "Text")

	Text.text = _("Desc_Rebate")
	Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 2, "Text")

	local info = OperationActiveMgr:GetRechargeRebate()

	if info then
		self.rebateValue = info.data.DailyTime[1][1]

		if info.pb.record <= 30000 then
			local value1 = 10
			local value2 = 10

			self.HorLayoutText1.text = info.pb.record * value1 / 100
			self.HorLayoutText2.text = info.pb.record * value2 / 100
		else
			local tempRecord = 0
			local sumValue1 = 0
			local value2 = 10

			self.HorLayoutText2.text = info.pb.record * value2 / 100

			local value1 = 10

			tempRecord = info.pb.record - 30000
			sumValue1 = 30000 * value1 / 100
			value1 = 5
			sumValue1 = tempRecord * value1 / 100 + sumValue1
			self.HorLayoutText1.text = sumValue1
		end
	end
end

function DlgOperationActiveRechargeRebate:OnClickedOpen()
	require("UI/Page/PageShop/PageShop")

	local data = {
		tagIndex = 1,
		tabMainIndex = tabMainType.charge
	}

	OperationActiveMgr.Tag = eOperationActive.RechargeRebate

	PageShop.InitNetData(data)
	InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(501).data.VocalBank)
	InfoSoundEventMgr:Play("VocalCommon6", RoleMgr:GetRole(501).data.VocalCommon6)
end
