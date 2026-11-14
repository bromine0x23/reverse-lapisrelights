-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageWork/CellWork.lua

require("UI/Item/UIItemBase")

CellWork = class("CellWork", UIItemBase)

function CellWork:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellWork:Create(vParam)
	CellWork.base.Create(self, vParam)
end

function CellWork:OnEnter()
	local g = self.UIRootObject
	local txt

	txt = GOUtil.FindChildComponent(g, "Panel1/BaseAward/Title/Text", "Text")
	txt.text = _("PageWork_Reward")
	txt = GOUtil.FindChildComponent(g, "Panel1/Condition/Title/Text", "Text")
	txt.text = _("PageWork_Condition")
	txt = GOUtil.FindChildComponent(g, "Panel2/Text", "Text")
	txt.text = _("Desc_More_Work_Get")
	self.Panel1 = GOUtil.FindChildGameObject(g, "Panel1")
	self.Panel2 = GOUtil.FindChildGameObject(g, "Panel2")
	self.TxtWorkName = GOUtil.FindChildComponent(g, "Panel1/TxtName", "Text")
	self.ImgWorkType1 = GOUtil.FindChildComponent(g, "Panel1/Info", "Image")
	self.ImgWorkType2 = GOUtil.FindChildComponent(g, "Panel1/Info/Type", "Image")

	for i = 1, 6 do
		self["ImgQuality" .. i] = GOUtil.FindChildComponent(g, "Panel1/Info/Level/" .. i, "Image")
	end

	self.GoGroup = GOUtil.FindChildGameObject(g, "Panel1/BaseAward/Group")
	self.GoCell = GOUtil.FindChildGameObject(g, "Panel1/BaseAward/Group/1")
	self.GoConGroup = GOUtil.FindChildGameObject(g, "Panel1/Condition/Group")
	self.GoCellCon = GOUtil.FindChildGameObject(g, "Panel1/Condition/Group/1")
	self.listGoAward = {}

	self:AddClick(self.GoCell, self.OnClickBaseAward)
	table.insert(self.listGoAward, self.GoCell)

	self.listGoCondition = {}

	self:AddClick(self.GoCellCon, self.OnClickCondition)
	table.insert(self.listGoCondition, self.GoCellCon)

	local gItem = GOUtil.FindChildGameObject(g, "Panel1/Other/ExtraReward/Cell")

	self.item = CellItem(gItem)

	self.item:InitItemByRoot(gItem)

	self.TxtProbability = GOUtil.FindChildComponent(g, "Panel1/Other/ExtraReward/TextPro", "Text")
	self.GoTime = GOUtil.FindChildGameObject(g, "Panel1/Other/Time")
	self.GoImgClock = GOUtil.FindChildGameObject(self.GoTime, "Image")
	self.TxtTime = GOUtil.FindChildComponent(self.GoTime, "TextTime", "Text")
	self.GoDot = GOUtil.FindChildGameObject(g, "Panel1/GoDot")
	self.GoBought = GOUtil.FindChildGameObject(g, "Panel1/GoBought")
	self.GoCompleted = GOUtil.FindChildGameObject(g, "Panel1/GoCompleted")
	self.GoSelect = GOUtil.FindChildGameObject(g, "Panel1/GoSelect")
	self.State1 = true
	self.State2 = false
	self.State3 = false
	self.State4 = false
	self.State5 = false
end

function CellWork:OnLeave()
	UnloadAllImageSprite(self)

	if self.item and self.item.OnLeave then
		self.item:OnLeave()
	end

	if self.listGoAward then
		for _, v in ipairs(self.listGoAward) do
			self:RemoveClick(v, self.OnClickBaseAward)
		end
	end

	if self.listGoCondition then
		for _, v in ipairs(self.listGoCondition) do
			self:RemoveClick(go, self.OnClickCondition)
		end
	end
end

function CellWork:UpdateData(data, index)
	if not data then
		return
	end

	self.type = data.info ~= nil and 1 or 2
	self.index = index

	GOUtil.SetActive(self.Panel1, self.type == 1)
	GOUtil.SetActive(self.Panel2, self.type == 2)

	if self.type == 1 then
		self.infoWork = data.info

		self:UpdateWorkInfo()
	elseif self.type == 2 then
		self:UpdateAddition()
	end
end

function CellWork:UpdateWorkInfo()
	local infoWork = self.infoWork

	self.TxtWorkName.text = infoWork:GetName()

	UIUtil.SetImageSprite(self.ImgWorkType1, "UI/PanelWork/AtlasPanelWork/BG_missionline_a0" .. infoWork.data.Type, self)
	UIUtil.SetImageSprite(self.ImgWorkType2, "UI/PanelWork/AtlasPanelWork/IC_MIS_0" .. infoWork.data.Type .. "_1", self)

	for i = 1, 6 do
		local alpha = i <= infoWork.data.Quality and 1 or 0

		UIUtil.SetGraphicAlpha(self["ImgQuality" .. i], alpha)
	end

	local rate

	if infoWork.pb.state ~= eWorkStateType.Picked then
		rate = infoWork.data.BaseRate or 0
	else
		rate = infoWork.pb.successRatio or 0
	end

	rate = TenaryOp(rate < 0, 0, TenaryOp(rate > 100, 100, rate))
	self.TxtProbability.text = string.format(Lang(12325), "<color=#585E62><size=40>" .. rate .. "%</size></color>\n")

	local id, num = infoWork.extraReward[1][1], infoWork.extraReward[1][2]

	if infoWork.pb.state == eWorkStateType.Picked then
		num = TenaryOp(infoWork.pb.awardMultiple, num * 2, num)
	end

	local infoItem = ItemManager:GetValueItem(id, num)

	self.item:UpdateWithNumType(infoItem)

	if infoWork.pb.state == eWorkStateType.Picked then
		self.item:SetDouble(infoWork.pb.awardMultiple)
		self.item:SetExtra(not infoWork.pb.awardMultiple)
	else
		self.item:SetExtra(true)
		self.item:SetDouble(false)
	end

	if infoWork.pb.state ~= eWorkStateType.Picked then
		local minute = infoWork.data.WorkTime

		self.TxtTime.text = table.concat({
			_("Desc_Time_Limit"),
			GetTimeLimitByMinute(minute or 0)
		})

		UIUtil.SetGraphicColorRGB(self.TxtTime, 0.3686274509803922, 0.3686274509803922, 0.3686274509803922)
	else
		UIUtil.SetGraphicColorRGB(self.TxtTime, 0.8666666666666667, 0.30196078431372547, 0.40784313725490196)
	end

	self:UpdateInstantiate(1)
	self:UpdateInstantiate(2)
	self:UpdateSelectState(self.Index == self.index)

	if infoWork.pb.state == eWorkStateType.Completed and not self.State3 then
		GOUtil.SetActive(self.GoBought, true)

		self.State3 = true
	end

	if infoWork.pb.state == eWorkStateType.Unbuyed and self.State3 then
		GOUtil.SetActive(self.GoBought, false)

		self.State3 = false
	end

	if infoWork.pb.state == eWorkStateType.Normal then
		if not self.State1 then
			GOUtil.SetActive(self.GoTime, true)

			self.State1 = true
		end

		if self.State2 then
			GOUtil.SetActive(self.GoImgClock, false)

			self.State2 = false
		end

		if self.State4 then
			GOUtil.SetActive(self.GoCompleted, false)

			self.State4 = false
		end

		if self.State5 then
			GOUtil.SetActive(self.GoDot, false)

			self.State5 = false
		end
	end
end

function CellWork:UpdateSelectState(state)
	GOUtil.SetActive(self.GoSelect, state)
end

local function FuncUpdate(object, data, self, type)
	if type == 1 then
		local imgBaseReward = GOUtil.GetComponent(object, "Image")
		local info = ItemManager:Get(data[1])

		if info ~= nil then
			UIUtil.SetImageSprite(imgBaseReward, info:GetIcon(), self)
		end

		local txtBaseReward = GOUtil.FindChildComponent(object, "Text", "Text")

		txtBaseReward.text = data[2]
	else
		local imgIcon = GOUtil.FindChildComponent(object, "Icon", "Image")

		UIUtil.SetImageSprite(imgIcon, data.info.Icon, self)

		local imgFull = GOUtil.FindChildComponent(object, "Full", "Image")

		if self.infoWork.pb.state == eWorkStateType.Picked then
			local flag = WorkMgr:GetConditionIsMet(data.info, self.infoWork.pb.roleCardIds)
			local alpha = TenaryOp(flag, 1, 0)

			UIUtil.SetGraphicAlpha(imgFull, 0)
		else
			UIUtil.SetGraphicAlpha(imgFull, 0)
		end
	end
end

local function FuncCreate(idx, data, self, type)
	local object

	if type == 1 then
		object = GOUtil.Instantiate(self.GoCell, self.GoGroup)
	else
		object = GOUtil.Instantiate(self.GoCellCon, self.GoConGroup)
	end

	object.name = idx

	FuncUpdate(object, data, self, type)

	if type == 1 then
		self:AddClick(object, self.OnClickBaseAward)
		table.insert(self.listGoAward, object)
	else
		self:AddClick(object, self.OnClickCondition)
		table.insert(self.listGoCondition, object)
	end
end

function CellWork:UpdateInstantiate(type)
	local listObject, listData

	if type == 1 then
		self.listGoAward = self.listGoAward or {}
		listObject = self.listGoAward
		listData = self.infoWork.baseReward or {}
	else
		self.listGoCondition = self.listGoCondition or {}
		listObject = self.listGoCondition
		listData = self.infoWork.listSpecial or {}
	end

	local newCnt = #listData
	local oldCnt = #listObject

	if oldCnt < newCnt then
		for i = 1, newCnt do
			if i <= oldCnt then
				GOUtil.SetActive(listObject[i], true)
				FuncUpdate(listObject[i], listData[i], self, type)
			else
				FuncCreate(i, listData[i], self, type)
			end
		end
	else
		for i = 1, oldCnt do
			GOUtil.SetActive(listObject[i], i <= newCnt)

			if i <= newCnt then
				FuncUpdate(listObject[i], listData[i], self, type)
			end
		end
	end
end

function CellWork:UpdateAddition()
	return
end

function CellWork:OnClickCondition(data)
	local listSpe = self.infoWork.listSpecial or {}

	if next(listSpe) == nil then
		return
	end

	local index = tonumber(data.pointerPress.gameObject.name)
	local infoSpe = listSpe[index].info

	if infoSpe then
		local tipData = SkillTip.GetWorkCondData(data.position, infoSpe)

		UIMgr.ShowSkillTip(tipData)
	end
end

function CellWork:OnClickBaseAward(data)
	local index = tonumber(data.pointerPress.gameObject.name)
	local itemId = self.infoWork.baseReward[index][1] or 0
	local info = ItemManager:Get(itemId)

	if info then
		UIMgr.ShowItemTip(info)
	end
end

function CellWork:UpdateTime(second)
	if second > 0 then
		self.TxtTime.text = GetTimeFormatBySecond(second, "hour")
	end

	self:UpdateState(second)
end

function CellWork:UpdateState(second)
	if self.infoWork == nil then
		return
	end

	local isFinish = false

	if second <= 0 then
		isFinish = true
	end

	if self.infoWork.pb.state == eWorkStateType.Picked then
		if isFinish then
			if self.State1 then
				GOUtil.SetActive(self.GoTime, false)

				self.State1 = false
			end

			if not self.State4 then
				GOUtil.SetActive(self.GoCompleted, true)

				self.State4 = true
			end

			if not self.State5 then
				GOUtil.SetActive(self.GoDot, true)

				self.State5 = true
			end
		else
			if not self.State1 then
				GOUtil.SetActive(self.GoTime, true)

				self.State1 = true
			end

			if not self.State2 then
				GOUtil.SetActive(self.GoImgClock, true)

				self.State2 = true
			end

			if self.State4 then
				GOUtil.SetActive(self.GoCompleted, false)

				self.State4 = false
			end

			if self.State5 then
				GOUtil.SetActive(self.GoDot, false)

				self.State5 = false
			end
		end
	end
end
