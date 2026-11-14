-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBondage/DlgBondageSkillUpgrade.lua

require("UI/Page/PageRoleCard/Cell/CellUseItem")
require("UI/Page/PageRoleCard/Cell/CellCostItem")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

DlgBondageSkillUpgrade = class("DlgBondageSkillUpgrade", UIPanel)

function DlgBondageSkillUpgrade:ctor()
	self.UIPrefabPath = "UI/PanelBondage/DlgBondageSkillUpgrade"
end

function DlgBondageSkillUpgrade:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellUseItem", "PrefabCell", GameObject)
	self:LoadResAsync("UI/PanelRoleCard/CellCostItem", "PrefabCellCostItem", GameObject)
end

function DlgBondageSkillUpgrade:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgBondageSkillUpgrade:OnLeave()
	ResourceMgr.Unload(self.PrefabCell)
	ResourceMgr.Unload(self.PrefabCellCostItem)

	if self.listCellCostItem then
		for _, v in ipairs(self.listCellCostItem) do
			v:OnLeave()
		end

		self.listCellCostItem = nil
	end

	if self.listCellUseItem then
		for _, v in pairs(self.listCellUseItem) do
			v:OnLeave()
		end

		self.listCellUseItem = nil
	end

	if self.EffPath then
		EffectMgr:UnLoadEffect(self.EffPath)

		self.EffPath = nil
	end
end

function DlgBondageSkillUpgrade:OnRegisterEvent()
	self:AddClick(self.BtnBatch, self.OnClickedBtnBatch)
	self:AddClick(self.BtnUpLv, self.OnClickedBtnUpLv)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	self:AddClick(self.BtnGoto, self.OnClickedGotoGet)
end

function DlgBondageSkillUpgrade:OnUnRegisterEvent()
	self:RemoveClick(self.BtnBatch, self.OnClickedBtnBatch)
	self:RemoveClick(self.BtnUpLv, self.OnClickedBtnUpLv)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	self:RemoveClick(self.BtnGoto, self.OnClickedGotoGet)
end

function DlgBondageSkillUpgrade:OnEnter(vParam)
	self:DealWithLocalization()

	self.RootAnim = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.Panel2 = self:GetChildGameObject("Panel2")
	self.EffPoint = self:GetChildGameObject("Panel2/EffPoint")
	self.TxtNeed = self:GetChildComponent("Panel2/Bg/TxtNeed", "Text")
	self.GoContent = self:GetChildGameObject("Panel2/Bg/Group/Content")
	self.BtnUpLv = self:GetChildGameObject("Panel1/BtnUpLv")
	self.ImgBtn = self:GetChildComponent("Panel1/BtnUpLv", "Image")
	self.BtnClose = self:GetChildGameObject("Panel1/BtnClose")
	self.BtnBatch = self:GetChildGameObject("Panel2/BtnBatch")
	self.BtnGoto = self:GetChildGameObject("Panel2/BtnGoto")
	self.GotoGet = self:GetChildGameObject("Panel2/Bg/GotoGet")
	self.EffPath = "Fx/UI/FX_UI_Welfare/FX_UI_DlgBondageSkillUpgrade"

	self:Init(vParam)
end

function DlgBondageSkillUpgrade:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel1/Title/Text", "Text")
	txt.text = _("Desc_SkillLevelUp")
	txt = self:GetChildComponent("Panel2/Title/Text", "Text")
	txt.text = _("Desc_AddItemList")
	txt = self:GetChildComponent("Panel1/BtnUpLv/Text", "Text")
	txt.text = _("PageRoleCard_TextUp")
	txt = self:GetChildComponent("Panel2/BtnBatch/Text", "Text")
	txt.text = _("Desc_BatchAdd")
	txt = self:GetChildComponent("Panel2/BtnGoto/Text", "Text")
	txt.text = Lang(42330)
	txt = self:GetChildComponent("Panel1/Bg/Text", "Text")
	txt.text = Lang(42476)
	txt = self:GetChildComponent("Panel2/Bg/GotoGet/Text", "Text")
	txt.text = _("Desc_Assets_None_Temp")
end

function DlgBondageSkillUpgrade:Init(data)
	self.infoSkill = data.skill
	self.infoCombination = data.comb
	self.listCost = CombBondageMgr:GetSkillUpCost(self.infoSkill)
	self.curIndex = 0
	self.listUseItem = {}
	self.curSelIndex = 0

	self:PackageSelectItem()
	self:InitSkill()
	self:InitCost()
	self:CheckCostEnough()
end

function DlgBondageSkillUpgrade:PackageSelectItem()
	self.listRealSelect = {}
	self.listSimuSelect = {}

	for k, v in pairs(self.listCost) do
		local id = v.info.id
		local isCommon = ItemManager:IsCommonStone(id)
		local teamId = v.type or 0

		self.listRealSelect[k] = {}
		self.listSimuSelect[k] = {}

		if isCommon then
			local list = ItemManager:GetListByCommonStone(id, teamId)

			for i = 1, #list do
				local t = {
					num = 0,
					id = list[i].id
				}

				table.insert(self.listRealSelect[k], t)
				table.insert(self.listSimuSelect[k], t)
			end
		else
			local hold = v.info:GetCurResNum()
			local cost = v.cost or 0
			local t = {
				id = id,
				num = cost < hold and cost or hold
			}

			table.insert(self.listRealSelect[k], t)
			table.insert(self.listSimuSelect[k], t)
		end
	end
end

function DlgBondageSkillUpgrade:InitSkill()
	local info = self.infoSkill
	local var

	var = self:GetChildComponent("Panel1/Bg/Skill/BgInfo/TxtName", "Text")
	var.text = Lang(info.data.Name)
	var = self:GetChildComponent("Panel1/Bg/Skill/BgInfo/TxtInfo", "Text")

	local nextLv = info.pb.level + 1 > info.data.HighestLevel and info.data.HighestLevel or info.pb.level + 1

	var.text = string.format(_("Desc_Level"), "<size=32>" .. info.pb.level .. "</size>") .. "➡" .. string.format(_("Desc_Level"), "<size=32>" .. nextLv .. "</size>")
	var = self:GetChildComponent("Panel1/Bg/Skill/Icon", "Image")

	SetImageSprite(var, "UIDyAtlas/Skill/" .. info.data.Icon, self)

	var = self:GetChildComponent("Panel1/Bg/Skill/Scroll/Text", "Text")
	var.text = _("Desc_AfterLevelUp") .. skillTip.GetDesc(info.id, nextLv, 0)
end

function DlgBondageSkillUpgrade:InitCost()
	local group = self:GetChildGameObject("Panel1/Bg/Group/Content")

	self.listCellCostItem = {}

	for i = 1, #self.listCost do
		local item = CellCostItem(self.PrefabCellCostItem, group, nil, self)

		item:Create()

		item.UIRootObject.name = i

		table.insert(self.listCellCostItem, item)
	end

	self:UpdateCost()
end

function DlgBondageSkillUpgrade:UpdateCost()
	if not self.listCellCostItem then
		return
	end

	local function wrap_cb(index)
		if self.EffHandle then
			EffectMgr:Free(self.EffHandle)

			self.EffHandle = nil
		end

		if self.curIndex == index then
			if self.EffPath then
				self.EffHandle = EffectMgr:Alloc(self.EffPath, self.EffPoint, true, 1)
			end

			return
		end

		self.curIndex = index

		if self.panel2Open then
			self.RootAnim:Play("DlgBondageSkillUpgrade_Change")
		else
			self.RootAnim:Play("DlgBondageSkillUpgrade_Open")

			self.panel2Open = true
		end

		self:InitUseItem()
	end

	for k, v in ipairs(self.listCellCostItem) do
		local itemId = self.listCost[k].info.id
		local needNum = self.listCost[k].cost
		local holdNum = 0

		for _, n in ipairs(self.listRealSelect[k]) do
			holdNum = holdNum + n.num
		end

		local info = ItemManager:GetValueItem(itemId, holdNum)
		local data = {
			showBg = true,
			useEmojiNeed = true,
			showAdd = true,
			showPrompt = true,
			info = info,
			needNum = needNum,
			belong = self.listCost[k].type,
			callback = wrap_cb
		}

		v:UpdateData(data)
	end
end

function DlgBondageSkillUpgrade:InitUseItem()
	local teamId = self.listCost[self.curIndex].type
	local info = self.listCost[self.curIndex].info
	local list = ItemManager:GetListByCommonStone(info.id, teamId)

	self.listUseItem = {}

	for _, v in ipairs(list) do
		local selNum = 0

		for k, n in ipairs(self.listRealSelect) do
			if k ~= self.curIndex then
				for _, z in ipairs(n) do
					if v.id == z.id then
						selNum = selNum + z.num
					end
				end
			end
		end

		if selNum ~= 0 then
			local leftNum = v:GetCurResNum() - selNum

			if leftNum > 0 then
				local info = ItemManager:GetValueItem(v.id, leftNum)

				table.insert(self.listUseItem, info)
			end
		else
			table.insert(self.listUseItem, v)
		end
	end

	self.listCellUseItem = self.listCellUseItem or {}

	local function funUpdate(item, idx)
		if item then
			item:UpdateData(self.listUseItem[idx], teamId)
			self:UpdateSel(idx)
		end
	end

	if #self.listCellUseItem < #self.listUseItem then
		for i = 1, #self.listUseItem do
			if i <= #self.listCellUseItem then
				GOUtil.SetActive(self.listCellUseItem[i].UIRootObject, true)
				funUpdate(self.listCellUseItem[i], i)
			else
				local item = CellUseItem(self.PrefabCell, self.GoContent, nil, self)

				item:Create()

				item.UIRootObject.name = i

				funUpdate(item, i)
				table.insert(self.listCellUseItem, item)
			end
		end
	else
		for i = 1, #self.listCellUseItem do
			if i <= #self.listUseItem then
				GOUtil.SetActive(self.listCellUseItem[i].UIRootObject, true)
				funUpdate(self.listCellUseItem[i], i)
			else
				GOUtil.SetActive(self.listCellUseItem[i].UIRootObject, false)
			end
		end
	end

	local ishave = #self.listUseItem > 0

	GOUtil.SetActive(self.GotoGet, not ishave)
	GOUtil.SetActive(self.BtnGoto, not ishave)
	GOUtil.SetActive(self.BtnBatch, ishave)

	local selNum = 0
	local selects = self.listRealSelect[self.curIndex] or {}

	for _, v in pairs(selects) do
		selNum = selNum + v.num
	end

	local info = self.listCost[self.curIndex].info

	self.TxtNeed.text = string.format(_("Desc_EmojiText_Select"), GetEmojiId(info.id), "<color=#ED5081>" .. selNum .. "</color>/" .. self.listCost[self.curIndex].cost)
end

function DlgBondageSkillUpgrade:UpdateSel(index)
	local item = self.listCellUseItem[index]

	if item then
		local id = self.listUseItem[index].id

		for _, v in pairs(self.listRealSelect[self.curIndex]) do
			if id == v.id then
				item:UpdateSelData(v.num)
			end
		end
	end
end

function DlgBondageSkillUpgrade:OnClickedBtnBatch()
	local list = self.listUseItem

	if #list == 0 then
		UIMgr.ShowMsg(_("Desc_NoCommonStone"))

		return
	end

	for k, v in pairs(self.listSimuSelect[self.curIndex]) do
		v.num = 0

		self.listCellUseItem[k]:UpdateSelData(0)
	end

	local function fun(id, num)
		local select = self.listSimuSelect[self.curIndex]

		for _, v in pairs(select) do
			if id == v.id then
				v.num = num

				break
			end
		end
	end

	local cost = self.listCost[self.curIndex].cost
	local sum, need, hold = 0, 0, 0

	for k, v in pairs(list) do
		need = cost - sum
		hold = v:GetNum()

		if need < hold then
			fun(v.id, need)
			self.listCellUseItem[k]:UpdateSelData(need)

			sum = sum + need

			break
		else
			fun(v.id, hold)
			self.listCellUseItem[k]:UpdateSelData(hold)

			sum = sum + hold
		end
	end

	sum = TenaryOp(cost < sum, cost, sum)

	local info = self.listCost[self.curIndex].info

	if cost <= sum then
		self.TxtNeed.text = string.format(_("Desc_EmojiText_Select"), GetEmojiId(info.id), sum .. "/" .. cost)
	else
		self.TxtNeed.text = string.format(_("Desc_EmojiText_Select"), GetEmojiId(info.id), "<color=#ED5081>" .. sum .. "</color>/" .. cost)
	end

	if self.listCellCostItem and self.listCellCostItem[self.curIndex] then
		self.listCellCostItem[self.curIndex]:UpdateNum(sum)
		self.listCellCostItem[self.curIndex]:PlayEff()
	end

	self:SynchronousData()
end

function DlgBondageSkillUpgrade:SetIndex(index)
	if self.curSelIndex ~= index then
		self.curSelIndex = index
	end
end

function DlgBondageSkillUpgrade:CheckCondition()
	if self.curSelIndex == 0 then
		return false
	end

	local num = 0

	for _, v in pairs(self.listSimuSelect[self.curIndex]) do
		num = num + v.num
	end

	if num >= self.listCost[self.curIndex].cost then
		UIMgr.ShowMsg(_("Desc_AlreadyAddNeedCount"))

		return false
	end

	local infoItem = self.listUseItem[self.curSelIndex]
	local holdNum = infoItem:GetNum()
	local selNum = self.listSimuSelect[self.curIndex][self.curSelIndex].num

	if holdNum <= selNum then
		UIMgr.ShowMsg(_("Desc_NoMoreItem"))

		return false
	end

	return true
end

function DlgBondageSkillUpgrade:DealWithAdd(idx)
	self:SetIndex(idx)

	if self.isNotFull then
		return
	end

	if not self:CheckCondition() then
		self.isNotFull = true

		return
	end

	self:UpdateSelItem(1)
end

function DlgBondageSkillUpgrade:DealWithEndAdd()
	self:SynchronousData()

	self.isNotFull = nil
end

function DlgBondageSkillUpgrade:DealWithSub(idx)
	self:SetIndex(idx)
	self:UpdateSelItem(2)
end

function DlgBondageSkillUpgrade:DealWithEndSub()
	self:SynchronousData()
end

function DlgBondageSkillUpgrade:UpdateSelItem(_type)
	local selNum = 1
	local num = self.listSimuSelect[self.curIndex][self.curSelIndex].num

	if _type == 1 then
		num = num + selNum

		if self.listCellCostItem and self.listCellCostItem[self.curIndex] then
			self.listCellCostItem[self.curIndex]:PlayEff()
		end
	else
		num = Mathf.Max(num - selNum, 0)
	end

	self.listSimuSelect[self.curIndex][self.curSelIndex].num = num

	local totalNum = 0

	for _, v in ipairs(self.listSimuSelect[self.curIndex]) do
		totalNum = totalNum + v.num
	end

	local cost = self.listCost[self.curIndex].cost
	local info = self.listCost[self.curIndex].info

	if cost <= totalNum then
		self.TxtNeed.text = string.format(_("Desc_EmojiText_Select"), GetEmojiId(info.id), totalNum .. "/" .. cost)
	else
		self.TxtNeed.text = string.format(_("Desc_EmojiText_Select"), GetEmojiId(info.id), "<color=#ED5081>" .. totalNum .. "</color>/" .. cost)
	end

	self.listCellCostItem[self.curIndex]:UpdateNum(totalNum)
	self:UpdateSel(self.curSelIndex)
end

function DlgBondageSkillUpgrade:SynchronousData()
	for k, v in ipairs(self.listSimuSelect[self.curIndex]) do
		self.listRealSelect[self.curIndex][k].num = v.num
	end

	self:CheckCostEnough()
end

function DlgBondageSkillUpgrade:CheckCostEnough()
	self.isEnough = true

	for k, v in ipairs(self.listRealSelect) do
		local needNum = self.listCost[k].cost
		local sum = 0

		for _, n in pairs(v) do
			sum = sum + (n.num or 0)
		end

		if sum < needNum then
			self.isEnough = false

			break
		end
	end

	local gray = TenaryOp(self.isEnough, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtn, gray))
end

function DlgBondageSkillUpgrade:OnClickedGotoGet()
	ItemManager:SetSweepItem({
		self.listCost[self.curIndex].info.id,
		self.listCost[self.curIndex].cost
	})

	local info = ItemManager:GetValueItem(self.listCost[self.curIndex].info.id, 0)

	if self.listCost[self.curIndex].type and self.listCost[self.curIndex].type ~= 0 then
		info.belong = self.listCost[self.curIndex].type
	end

	local function cb()
		self:Close()
	end

	UIMgr.ShowItemTip(info, 2, true, false, cb)
end

function DlgBondageSkillUpgrade:OnClickedBtnUpLv()
	if not self.isEnough then
		UIMgr.ShowMsg(_("Desc_ClickToAdd"))

		return
	end

	local teamId = self.infoCombination.id
	local skillId = self.infoSkill.id
	local costSouls = {}

	for k, v in pairs(self.listRealSelect) do
		for i = 1, #v do
			local cardId = ItemManager:Get(v[i].id).data.Value

			table.insert(costSouls, cardId)
			table.insert(costSouls, v[i].num)
			table.insert(costSouls, k)
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			local list = self.infoCombination.listRole
			local role = list[math.random(1, #list)]

			if role ~= nil then
				InfoSoundEventMgr:LoadBank(role.data.VocalBank)
				InfoSoundEventMgr:Play("VocalCharaUp2", role.data.VocalCharaUp2)
			end

			self:Close()
			self.infoCombination:UpdateBondageSkill({
				id = skillId,
				level = self.infoSkill.pb.level + 1
			})
			Event.Instance:Fire("UpdateBondageAfterUpgrade", skillId)
			UIMgr.ShowMsg(_("Msg_FetterUpSuccess"))
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBondageSkillUpgrade(teamId, skillId, costSouls, wrap_cb)
end

function DlgBondageSkillUpgrade:OnClickedBtnClose()
	self:Close()
end
