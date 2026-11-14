-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/DlgMonsterDes.lua

require("UI/Page/PageCombatReadiness/CellMonsterDetail")
require("UI/Page/PageCombatReadiness/CellSkillDetail")

DlgMonsterDes = class("DlgMonsterDes", UIPanel)

function DlgMonsterDes:ctor()
	self.UIPrefabPath = "UI/PanelCombatReadiness/DlgMonsterDes"
end

function DlgMonsterDes:PreLoad()
	self:LoadResAsync("UI/PanelCombatReadiness/CellMonsterDetail", "PrefabMonsterDetail")
	self:LoadResAsync("UI/PanelCombatReadiness/CellSkillDetail", "PrefabSkillDetail")
end

function DlgMonsterDes:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabMonsterDetail)
	ResourceMgr.Unload(self.PrefabSkillDetail)

	if self.UIScrollToolMonster then
		self.UIScrollToolMonster:Purge()

		self.UIScrollToolMonster = nil
	end

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function DlgMonsterDes:OnEnter(vParam)
	self.listMonster = vParam.listMonster
	self.currentIndex = vParam.index
	self.btnClose = GOUtil.FindChildGameObject(self.UIRootObject, "Btnclose")
	self.txtSkillNum = GOUtil.FindChildComponent(self.UIRootObject, "bg1/txt_skillNum", "Text")

	self:InitAll()
end

function DlgMonsterDes:OnLeave()
	return
end

function DlgMonsterDes:OnRegisterEvent()
	self:AddClick(self.btnClose, self.OnClickClose)
end

function DlgMonsterDes:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose, self.OnClickClose)
end

function DlgMonsterDes:OnClickClose()
	self:Close()
end

function DlgMonsterDes:InitAll()
	local ScrollArea = self:GetChildGameObject("MonsterScroll")
	local content = self:GetChildComponent("MonsterScroll/Content", "Transform")
	local count = #self.listMonster

	self.UIScrollToolMonster = UIScrollTool()

	local function ListUpdate(item, index)
		local data = self.listMonster[index]

		item:UpdateData(data, index, index == self.currentIndex, function(indexParam)
			self.currentIndex = indexParam

			self.UIScrollToolMonster:UpdateListDataKeepPos(self.listMonster)

			local infoEnemy = EnemyManager:Get(self.listMonster[self.currentIndex])

			self.listSkillId = infoEnemy.data.StageSkillIdDisplay

			self.UIScrollTool:UpdateListData(self.listSkillId)
		end)
	end

	local LayoutGroup = self:GetChildComponent("MonsterScroll/Content", "GridLayoutGroup")

	if count > 4 then
		LayoutGroup.childAlignment = UnityEngine.TextAnchor.MiddleLeft
	else
		LayoutGroup.childAlignment = UnityEngine.TextAnchor.MiddleCenter
	end

	self.UIScrollToolMonster:InitList(ScrollArea, content, count, self.PrefabMonsterDetail, CellMonsterDetail, self, true, nil, ListUpdate)
	self:InitMonsterSkill()
end

function DlgMonsterDes:InitMonsterSkill()
	local infoEnemy = EnemyManager:Get(self.listMonster[self.currentIndex])

	self.txtSkillNum.text = infoEnemy.data.BaseAttackRound

	local ScrollArea = self:GetChildGameObject("SkillScroll")
	local content = self:GetChildComponent("SkillScroll/Content", "Transform")

	self.listSkillId = infoEnemy.data.StageSkillIdDisplay

	local skillCnt = #self.listSkillId

	local function ListUpdate(item, index)
		local data = self.listSkillId[index]

		item:UpdateData(data, index)
	end

	self.UIScrollTool = self.UIScrollTool or UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, skillCnt, self.PrefabSkillDetail, CellSkillDetail, self, true, nil, ListUpdate)
end

function DlgMonsterDes:AddCellClick(item)
	return
end

function DlgMonsterDes:OnClickedCell(data)
	return
end
