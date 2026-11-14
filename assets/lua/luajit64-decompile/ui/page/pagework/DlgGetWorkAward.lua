-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageWork/DlgGetWorkAward.lua

DlgGetWorkAward = class("DlgGetWorkAward", UIPanel)

function DlgGetWorkAward:ctor()
	self.UIPrefabPath = "UI/PanelWork/DlgGetWorkAward"
end

function DlgGetWorkAward:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem", GameObject)
	self:LoadResAsync("Fx/UI/FX_UI_Welfare/FX_UI_Welfare_RT", "FX_UI_Welfare_RT", Texture)
	self:LoadResAsync("Fx/UI/FX_UI_Welfare/FX_UI_Welfare_Mat", "FX_UI_Welfare_Mat", Material)
end

function DlgGetWorkAward:Purge()
	if self.cb then
		self.cb()

		self.cb = nil
	end

	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellItem)
	ResourceMgr.Unload(self.FX_UI_Welfare_RT)
	ResourceMgr.Unload(self.FX_UI_Welfare_Mat)

	for _, v in ipairs(self.listCell1) do
		if v.OnLeave ~= nil then
			v:OnLeave()
		end
	end

	self.listCell1 = nil

	for _, v in ipairs(self.listCell2) do
		if v.OnLeave ~= nil then
			v:OnLeave()
		end
	end

	self.listCell2 = nil
end

function DlgGetWorkAward:OnRegisterEvent()
	self:AddClick(self.ButtonConfirm, self.OnClickBtnConfirm)
end

function DlgGetWorkAward:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonConfirm, self.OnClickBtnConfirm)
end

function DlgGetWorkAward:OnEnter(vParam)
	self:DealWithLocalization()

	self.TxtPerform = self:GetChildComponent("Panel/Prompt/Text", "Text")
	self.ButtonConfirm = self:GetChildGameObject("Panel/Button")

	self:Init(unpack(vParam))
end

function DlgGetWorkAward:DealWithLocalization()
	txt = self:GetChildComponent("Panel/Base/Image/Text", "Text")
	txt.text = _("Desc_Work_Basic_Remuneration")
	txt = self:GetChildComponent("Panel/Extra/Image/Text", "Text")
	txt.text = _("Desc_Work_Extra_Remuneration")
	txt = self:GetChildComponent("Panel/Button/Text", "Text")
	txt.text = Lang(12243)
end

function DlgGetWorkAward:Init(infoWork, setter, callback)
	if infoWork == nil or setter == nil then
		return
	end

	self.cb = callback

	local imgBgWork = self:GetChildComponent("Panel/BgWork", "RawImage")

	UIUtil.SetRawImageTexture(imgBgWork, "Texture/Work/" .. infoWork.data.BGIcon, self)
	UIUtil.SetImageSprite(self:GetChildComponent("Panel/Title", "Image"), "UI/PanelWork/AtlasPanelWork/BG_missionline_a0" .. infoWork.data.Type, self)
	UIUtil.SetImageSprite(self:GetChildComponent("Panel/Title/Icon", "Image"), "UI/PanelWork/AtlasPanelWork/IC_MIS_0" .. infoWork.data.Type .. "_1", self)

	local listCardId = infoWork.pb.roleCardIds or {}

	for i = 1, 3 do
		local imgPaper = self:GetChildComponent("Panel/BgWork/Paper2/" .. i, "Image")

		GOUtil.SetActive(imgPaper, i <= #listCardId)

		if i <= #listCardId then
			local infoRole = RoleCardMgr:GetRole(listCardId[i])

			UIUtil.SetImageOverrideSprite(imgPaper, infoRole.actorData.PaperIcon, self)
		end
	end

	self.listCell1 = {}
	self.listCell2 = {}

	local ContentBase = self:GetChildGameObject("Panel/Base/ScrollArea/Content")
	local ContentExtra = self:GetChildGameObject("Panel/Extra/ScrollArea/Content")

	local function CreateCellItem(_idx, _info, _type)
		local parent = ContentBase

		if _type == 2 then
			parent = ContentExtra
		end

		local cell = CellItem(self.PrefabCellItem, parent, self)

		cell:Create()
		GOUtil.SetTransformLocalScale(cell.UIRootObject, 0.95)

		local notGet = _info:GetNum() <= 0

		cell:UpdateData(_idx, _info, true, notGet)

		if notGet then
			cell:SetNotGet()
		elseif _type == 2 then
			cell:SetEffect(self.FX_UI_Welfare_RT, self.FX_UI_Welfare_Mat)
		end

		table.insert(self["listCell" .. _type], cell)
	end

	local function DealWithAwards(list, _type)
		for k, v in ipairs(list) do
			local info

			if v.asset and v.asset == protocol_pb.I_SOUL then
				local itemId = ItemManager:GetCardSoulId(v.id)

				info = ItemManager:GetValueItem(itemId, v.num)
			else
				info = ItemManager:GetValueItem(v.id, v.num)
			end

			if info then
				CreateCellItem(k, info, _type)
			end
		end
	end

	local setterList = SetterData.ConvertSettersToPbItems(setter)

	local function GetSetter(_type)
		local t = {}
		local from = _type == 1 and protocol_pb.AF_NORMAL or protocol_pb.AF_EXTRA_AWARD

		for _, s in ipairs(setterList) do
			if s.from == from and s.num > 0 then
				table.insert(t, {
					asset = s.asset,
					id = s.id,
					num = s.num
				})
			end
		end

		return t
	end

	DealWithAwards(GetSetter(1), 1)

	local list = GetSetter(2)

	if #list == 0 then
		local awards = ItemManager.GetRewardPackItems(infoWork.data.SuccessReward)
		local t = {}

		for _, v in ipairs(awards) do
			table.insert(t, {
				num = 0,
				id = v[1]
			})
		end

		DealWithAwards(t, 2)
	else
		DealWithAwards(list, 2)
	end

	if #list > 0 then
		self.TxtPerform.text = _("Desc_Work_Complete_Perfect")
	else
		self.TxtPerform.text = _("Desc_Work_Complete_Not_Perfect")
	end
end

function DlgGetWorkAward:OnClickBtnConfirm()
	if SetterData.haveOverItem then
		SetterData.haveOverItem = false

		UIMgr.ShowMsg(_("Msg_OverItem_Common"))
	end

	self:Close()
end
