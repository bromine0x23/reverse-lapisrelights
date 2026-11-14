-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/DlgStoryAwardShow.lua

local StoryAward = require("luaData/StoryAward")

DlgStoryAwardShow = class("DlgStoryAwardShow", UIPanel)

function DlgStoryAwardShow:ctor()
	DlgStoryAwardShow.base.ctor(self, "UI/PanelPass/DlgStoryAwardShow")
end

function DlgStoryAwardShow:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function DlgStoryAwardShow:Purge()
	DlgStoryAwardShow.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)

	if self.listCellItem then
		for _, item in ipairs(self.listCellItem) do
			item:OnLeave()
		end

		self.listCellItem = nil
	end
end

function DlgStoryAwardShow:OnRegisterEvent()
	self:AddClick(self.CloseBtn, self.Close)
	self:AddClick(self.Button_OK, self.Close)
end

function DlgStoryAwardShow:OnUnRegisterEvent()
	self:RemoveClick(self.CloseBtn, self.Close)
	self:RemoveClick(self.Button_OK, self.Close)
end

function DlgStoryAwardShow:OnEnter(vParam)
	self.stageId = vParam.stageId
	self.Tital = self:GetChildComponent("Panel/bg_title/Text", "Text")
	self.CloseBtn = self:GetChildGameObject("Panel/Close")
	self.Button_OK = self:GetChildGameObject("Panel/Button_OK")
	self.TextTip = self:GetChildComponent("Panel/Image/Text", "Text")
	self.List = self:GetChildGameObject("Panel/Image/List")
	self.Label_OK = self:GetChildComponent("Panel/Button_OK/Label_OK", "Text")
	self.TextTip.text = _("Desc_StoryAwardTip")
	self.Label_OK.text = _("UI_confirm")
	self.Tital.text = _("Desc_StoryAwardTital")

	self:UpdatePanel()
end

function DlgStoryAwardShow:UpdatePanel()
	local listGroup = ChapterMgr.StoryAwardList[self.stageId]
	local itemDataList = {}

	for _, v1 in ipairs(listGroup) do
		for _, v2 in ipairs(v1.AwardId) do
			for _, v3 in ipairs(StoryAward[v2].AwardList) do
				local isHave = false

				for _, v in ipairs(itemDataList) do
					if v[1] == v3[1] and v[3] == v3[3] then
						isHave = true
					end
				end

				if not isHave then
					table.insert(itemDataList, v3)
				end
			end
		end
	end

	self.listCellItem = {}

	for i = 1, #itemDataList do
		local infoItem = ItemManager:GetValueItem(itemDataList[i][1], itemDataList[i][2], nil, itemDataList[i][3])
		local item = CellItem(self.PrefabCellItem, self.List, self)

		item:Create()
		item:UpdateNoNumType(infoItem)
		table.insert(self.listCellItem, item)
	end
end
