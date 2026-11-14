-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBuff/CellBuffInfo.lua

local AllSkills = require("luaData/AllSkills")

require("UI/Item/UIItemBase")

CellBuffInfo = class("CellBuffInfo", UIItemBase)

function CellBuffInfo:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBuffInfo:OnLeave()
	UIMgr.RemoveUpdatePanel(self)
	UnloadAllImageSprite(self)
end

function CellBuffInfo:OnEnter()
	self.img_icon = self:GetChildComponent("img_icon", "Image")
	self.tex_name = self:GetChildComponent("tex_name", "Text")
	self.tex_name1 = self:GetChildComponent("tex_name1", "Text")
	self.tex_info = self:GetChildComponent("tex_info", "Text")
	self.tex_time = self:GetChildComponent("tex_time", "Text")

	UIMgr.SetUpdatePanel(self)
end

function CellBuffInfo:UpdateData(info, type)
	self.info = info

	UIUtil.SetImageSprite(self.img_icon, info.Icon, self)

	local name = Lang(info.Name)

	if #name > 30 then
		self.tex_name1.gameObject:SetActive(true)
		self.tex_name.gameObject:SetActive(false)

		self.tex_name1.text = name
	else
		self.tex_name1.gameObject:SetActive(false)
		self.tex_name.gameObject:SetActive(true)

		self.tex_name.text = name
	end

	if info.SkillID == nil then
		if #info.IntValue == 0 then
			self.tex_info.text = Lang(info.Info)
		elseif info.IntValue[1] == 0 then
			local infoDes = info.IntValue[2] .. "%"

			self.tex_info.text = string.format(Lang(info.Info), infoDes)
		else
			local infoDes = info.IntValue[1]

			self.tex_info.text = string.format(Lang(info.Info), infoDes)
		end
	else
		local argus

		for _, value in pairs(AllSkills) do
			if value.ID == info.BuffSkillID then
				if #value.Argus ~= 0 then
					argus = value.Argus[1]
				elseif #value.Argus1 ~= 0 then
					argus = value.Argus1[1]
				elseif #value.Argus2 ~= 0 then
					argus = value.Argus2[1]
				elseif #value.Argus3 ~= 0 then
					argus = value.Argus3[1]
				elseif #value.SkillStageBonus ~= 0 then
					argus = value.SkillStageBonus[1]
				elseif #value.ExpAdd ~= 0 then
					argus = value.ExpAdd[1]
				elseif #value.CostAdd ~= 0 then
					argus = value.CostAdd[1]
				elseif #value.ItemExtraGroup ~= 0 then
					argus = value.ItemExtraGroup[1]
				end
			end
		end

		if argus ~= nil then
			self.tex_info.text = string.format(Lang(info.Info), argus)
		else
			self.tex_info.text = Lang(info.Info)
		end
	end

	self.tex_time.text = OperationActiveMgr:GetRemainTimeNew(info.endTime)
end

function CellBuffInfo:OnUpdateSecond()
	if self.tex_time and self.info then
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		if curServerTime <= self.info.endTime then
			self.tex_time.text = OperationActiveMgr:GetRemainTimeNew(self.info.endTime)
		else
			Event.Instance:Fire("ClosePageBuff")
		end
	end
end
