-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/PageCMD.lua

require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeMonster")
require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgMonsterSkill")
require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeScene")
require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgChangeSession")
require("UI/Page/PageFight/Dlg/DebugPanels/GMDlgUnitDetail")

local dropDatas = {
	{
		funName = "ClearCMD",
		title = "CMD"
	},
	{
		funName = "Win",
		title = "勝利"
	},
	{
		funName = "OnBtnRound",
		title = "ターンの更新"
	},
	{
		funName = "OnBtnWave",
		title = "Wave数の更新"
	},
	{
		funName = "AddBuff",
		title = "バフ追加"
	},
	{
		funName = "RemoveBuff",
		title = "バフ除去"
	},
	{
		funName = "RecoverMp",
		title = "MP回復"
	},
	{
		funName = "RecoverShield",
		title = "シールド回復"
	},
	{
		funName = "RemoveAllBuff",
		title = "全域バフ除去"
	},
	{
		funName = "MonsterSkill",
		title = "スキル発動"
	},
	{
		funName = "CastSkill",
		title = "スキル発動(カスタムskillId)"
	},
	{
		funName = "ChageSession",
		title = "session珠変更"
	},
	{
		funName = "UnitAttribute",
		title = "ステータス確認"
	},
	{
		funName = "ChangeMonster",
		title = "魔獣を変更"
	},
	{
		funName = "OnBtnScene",
		title = "Scene"
	},
	{
		funName = "ChcekSkillAndBuff",
		title = "プリントスキルbuff"
	},
	{
		funName = "OnBtnGod",
		title = "God"
	},
	{
		funName = "SceneSkillViewer",
		title = "デバッグ画面まで戻る"
	},
	{
		funName = "SaveFight",
		title = "バトル履歴セーブ"
	}
}

PageCMD = class("PageCMD", UIPanel_sync)

function PageCMD:ctor()
	PageCMD.base.ctor(self, "UI/PageFight/Dlg/PageCMD")
end

function PageCMD:Cache()
	PageCMD.base.Cache(self)
end

function PageCMD:Close(tParam)
	PageCMD.base.Close(self, tParam)
end

function PageCMD:Purge()
	PageCMD.base.Purge(self)

	self.GL = nil

	UIMgr:RemoveSafeArea(self)
end

function PageCMD:OnRegisterEvent()
	self:AddClick(self.btn_confirm, self.OnBtnConfirm)
	self:AddClick(self.btn_closeOp, self.OnBtnCloseOp)
	self.dropDown.onValueChanged:AddListener(function(idx)
		self:OnDropdown(idx)
	end)
	self.toggles[6].onValueChanged:AddListener(function(val)
		self:OnPlayerCampToggle(val)
	end)
end

function PageCMD:OnUnRegisterEvent()
	self:RemoveClick(self.btn_confirm, self.OnBtnConfirm)
	self:RemoveClick(self.btn_closeOp, self.OnBtnCloseOp)
	self.dropDown.onValueChanged:RemoveListener(function(idx)
		self:OnDropdown(idx)
	end)
	self.toggles[6].onValueChanged:RemoveListener(function(val)
		self:OnPlayerCampToggle(val)
	end)
end

function PageCMD:SetGL(gl)
	self.GL = gl
end

function PageCMD:OnEnter(vParam)
	UIMgr:SetSafeArea(self, self.UIRootObject)

	self.GL = nil

	Event.Instance:Fire("CMD_PageCMD", self)

	self.dropDown = self:GetChildComponent("Dropdown", "Dropdown")

	self.dropDown.options:Clear()

	for _, data in ipairs(dropDatas) do
		local tempData = UnityEngine.UI.Dropdown.OptionData()

		tempData.text = data.title

		self.dropDown.options:Add(tempData)
	end

	self.obj_operator = self:GetChildGameObject("panel/operator")

	GOUtil.SetActive(self.obj_operator, false)

	self.btn_confirm = self:GetChildGameObject("panel/operator/btn_confirm")
	self.btn_closeOp = self:GetChildGameObject("panel/operator/btn_closeOp")

	function self.confirmcallback()
		return
	end

	self.inputField = self:GetChildComponent("panel/operator/InputField", "InputField")
	self.txt_desc = self:GetChildComponent("panel/operator/txt_desc", "Text")
	self.obj_toggles = self:GetChildGameObject("panel/operator/toggles")
	self.toggles = {}

	for i = 1, self.obj_toggles.transform.childCount do
		local go = self.obj_toggles.transform:GetChild(i - 1).gameObject
		local toggle = GOUtil.GetComponent(go, "Toggle")

		table.insert(self.toggles, toggle)
	end
end

function PageCMD:Open(callback, camp)
	self:Show(true)
end

function PageCMD:OnBtnCMD()
	GOUtil.SetActive(self.obj_panel, not self.obj_panel.activeSelf)
end

function PageCMD:OnBtnConfirm()
	self.confirmcallback()
end

function PageCMD:OnBtnCloseOp()
	self:Style(nil)
end

function PageCMD:CurCamp()
	if self.toggles[6].isOn == true then
		return EnumFight.Camp.PLAYER
	else
		return EnumFight.Camp.ENEMY
	end
end

function PageCMD:GetOrders()
	local orders = {}

	for i = 1, 5 do
		if self.toggles[i].isOn == true then
			table.insert(orders, i)
		end
	end

	return orders
end

function PageCMD:GetInput()
	return self.inputField.text
end

function PageCMD:GetInputNumber()
	return tonumber(self.inputField.text)
end

function PageCMD:GetUnit()
	if self:CurCamp() == EnumFight.Camp.PLAYER then
		return self.GL.UnitMgr:Selector():Camp(EnumFight.Camp.PLAYER):Order(self:GetOrders()[1]):Get()
	else
		return self.GL.RunTime.CurSelectTarget
	end
end

function PageCMD:UnitIpairs()
	if self:CurCamp() == EnumFight.Camp.PLAYER then
		local units = {}

		for i, unit in self.GL.UnitMgr:Selector():Camp(EnumFight.Camp.PLAYER):Ipairs() do
			if self.toggles[i].isOn == true then
				table.insert(units, unit)
			end
		end

		return ipairs(units)
	else
		return ipairs({
			self.GL.RunTime.CurSelectTarget
		})
	end
end

function PageCMD:Style(input, toggle, str)
	if input == nil then
		GOUtil.SetActive(self.obj_operator, false)

		return
	end

	GOUtil.SetActive(self.obj_operator, true)
	GOUtil.SetActive(self.btn_confirm, true)
	GOUtil.SetActive(self.inputField.gameObject, input == true)
	GOUtil.SetActive(self.obj_toggles, toggle == true)

	if str then
		self.txt_desc.text = str
	else
		self.txt_desc.text = ""
	end
end

function PageCMD:OnDropdown(idx)
	if idx == 0 then
		GOUtil.SetActive(self.obj_operator, false)
	end

	local data = dropDatas[idx + 1]

	if self[data.funName] then
		self[data.funName](self)

		return
	else
		print("cmd:" .. data.title .. "  対応方法が定義されていない！！")
	end
end

function PageCMD:OnPlayerCampToggle(val)
	for i = 1, 5 do
		GOUtil.SetActive(self.toggles[i].gameObject, val == true)
	end
end

function PageCMD:ClearCMD()
	GOUtil.SetActive(self.obj_operator, false)
end

function PageCMD:SceneSkillViewer()
	SceneMgr.GetCurrentScene().GP:PurgeAll()

	local sceneName = "SkillViewer"

	SceneMgr.LoadScene(sceneName, nil)
end

function PageCMD:AddBuff()
	self:Style(true, true, "ターゲットを選び、buffIdを入力")

	function self.confirmcallback()
		local buffId = self:GetInputNumber()

		for i, unit in self:UnitIpairs() do
			unit:AddBuff(buffId, unit, nil)
		end
	end
end

function PageCMD:RemoveBuff()
	self:Style(false, true, "ターゲットを選び、buffを除去")

	function self.confirmcallback()
		for i, unit in self:UnitIpairs() do
			for j = #unit.Buffs, 1, -1 do
				local buff = unit.Buffs[j]

				if buff.BuffId ~= 99999 then
					buff:RemoveSelf()
				end
			end
		end
	end
end

function PageCMD:RemoveAllBuff()
	for waveIdx = 1, 2 do
		for i, unit in self.GL.UnitMgr:Selector():Camp(waveIdx):Alive():Ipairs() do
			for j = #unit.Buffs, 1, -1 do
				local buff = unit.Buffs[j]

				if buff.BuffId ~= 99999 then
					buff:RemoveSelf()
				end
			end
		end
	end
end

function PageCMD:OnBtnRound()
	self:Style(false, false, false)

	function self.confirmcallback()
		self.GL.RunTime:CMDRefreshRound()
	end
end

function PageCMD:OnBtnWave()
	self:Style(false, false, false)

	function self.confirmcallback()
		self.GL.RunTime:CMDRefreshWave()
	end
end

function PageCMD:OnBtnScene()
	UIMgr.AddPanel(GMDlgChangeScene())
end

function PageCMD:ChcekSkillAndBuff()
	local BattleSkillData = require("GamePerform.Object.InfoBattleSkillData")

	self:Style(false, true, "ターゲットを選択")

	function self.confirmcallback()
		local unit = self:GetUnit()

		for i, skill in ipairs(unit.Skills) do
			local data = BattleSkillData:GetData(skill.SkillId)
			local desc = SkillTip.GetDesc(data.AllSkillID, skill.AllSkillLv, 1, nil)

			print("Skill:" .. skill.SkillId .. " " .. skill.ShowName .. "  " .. desc)
		end

		for i, buff in ipairs(unit.Buffs) do
			local desc = BuffTip.GetDesc(buff.BuffId, 1, buff.Round, false, 0, buff.Stack, nil)

			print("Buff:" .. buff.BuffId .. " " .. buff.ShowName .. "  " .. desc)
		end
	end
end

function PageCMD:MonsterSkill()
	UIMgr.AddPanel(GMDlgMonsterSkill())
end

function PageCMD:ChageSession()
	UIMgr.AddPanel(GMDlgChangeSession())
end

function PageCMD:ChangeMonster()
	UIMgr.AddPanel(GMDlgChangeMonster())
end

function PageCMD:Win()
	for i, unit in self.GL.UnitMgr:Selector():Camp(2):Alive():Ipairs() do
		-- block empty
	end

	self.GL:MarkGameOver(EnumFight.Camp.ENEMY)
	self.GL.RunTime:ChangeState(EnumFight.GameState.DEBUG)
end

function PageCMD:RecoverMp()
	self:Style(false, true, "ターゲット選択")

	function self.confirmcallback()
		local unit = self.GL.UnitMgr:Selector():Camp(self:CurCamp()):Alive():Get()

		unit:ForceMp(999)
	end
end

function PageCMD:RecoverShield()
	self:Style(false, true, "ターゲット選択")

	function self.confirmcallback()
		local unit = self.GL.UnitMgr:Selector():Camp(self:CurCamp()):Alive():Get()

		unit:AddShield(999)
	end
end

function PageCMD:OnBtnGod()
	self:Style(true, true, "デフォルトでは無敵、1-防御アップ、2-攻撃アップ")

	local val_99999 = 1000000

	function self.confirmcallback()
		local input = self:GetInput()

		for i, unit in self:UnitIpairs() do
			if input == "1" then
				unit:Add("减伤", val_99999)
			elseif input == "2" then
				unit:Add("增伤", val_99999)
			elseif input == "3" then
				unit:Add("最大生命", val_99999)
				unit:HealHp(val_99999, unit)
			else
				unit:Add("减伤", val_99999)
				unit:Add("增伤", val_99999)
				unit:Add("最大生命", val_99999)
				unit:HealHp(val_99999, unit)
			end
		end
	end
end

function PageCMD:CastSkill()
	self:Style(true, true, "スキル発動者を選び、スキルskillidを入力")

	function self.confirmcallback()
		local battleSkillId = self:GetInputNumber()
		local cfg = ConfigTable.BattleSkillData[battleSkillId]

		if not cfg then
			print("BattleSkillIdを入力していないか  BattleSkillDataに存在しないidである")

			return
		end

		local allSkillId = cfg.AllSkillID
		local allCfg = ConfigTable.AllSkills[allSkillId]

		if not allCfg then
			print("AllSkillsに存在しないidである " .. allSkillId)

			return
		end

		local lv = 1

		for i, id in ipairs(allCfg.BattleSkillID) do
			if id == battleSkillId then
				lv = i

				break
			end
		end

		local unit = self:GetUnit()
		local skill = unit:AddSkill(allSkillId, lv)

		self.GL.RunTime.State = EnumFight.GameState.PLAYER_CARD

		self.GL:Fire("阶段-改变", self.GL.RunTime.State, self.GL.RunTime.LastState)

		self.GL.RunTime.LastState = self.GL.RunTime.State

		self.GL.RunTime:CMDDoCard(unit, skill.SkillId)
	end
end

function PageCMD:UnitAttribute()
	self:Style(false, true, "ターゲット選択")

	function self.confirmcallback()
		local unit = self:GetUnit()

		UIMgr.AddPanel(GMDlgUnitDetail(), unit)
	end
end

function PageCMD:SaveFight()
	local jsonStr = self.GL:GetReplayJsonData()

	print(jsonStr)
	PlayerPrefs.SetString("LastFightData", jsonStr)
	self:Style(false, false, "セーブしました。デバッグ画面に戻りますか？")

	function self.confirmcallback()
		self:SceneSkillViewer()
	end
end
