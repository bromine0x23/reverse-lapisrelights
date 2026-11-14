-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/DlgGvgCmd.lua

local mt = class("DlgGvgCmd", UIItemBase)

function mt:ctor(obj)
	mt.base.base.ctor(self)

	self.UIRootObject = obj
	self.btn_reqdata = self:GetChildGameObject("btns_cmd/btn_reqdata/obj_click")
	self.btn_unlock = self:GetChildGameObject("btns_cmd/btn_unlock/obj_click")
	self.btn_god = self:GetChildGameObject("btns_cmd/btn_god/obj_click")
	self.btn_over = self:GetChildGameObject("btns_cmd/btn_over/obj_click")
	self.btn_stage = self:GetChildGameObject("btns_cmd/btn_stage/obj_click")
	self.btn_autofight = self:GetChildGameObject("btns_cmd/btn_autofight/obj_click")
	self.btn_clearlocal = self:GetChildGameObject("btns_cmd/btn_clearlocal/obj_click")

	self:AddClick(self.btn_reqdata, self.OnReqData)
	self:AddClick(self.btn_unlock, self.OnUnLock)
	self:AddClick(self.btn_god, self.OnGod)
	self:AddClick(self.btn_over, self.OnOver)
	self:AddClick(self.btn_stage, self.OnStage)
	self:AddClick(self.btn_autofight, self.OnAutoFight)
	self:AddClick(self.btn_clearlocal, self.OnClearLocalAnim)
end

function mt:Purge()
	self:RemoveClick(self.btn_reqdata, self.OnReqData)
	self:RemoveClick(self.btn_unlock, self.OnUnLock)
	self:RemoveClick(self.btn_god, self.OnGod)
	self:RemoveClick(self.btn_over, self.OnOver)
	self:RemoveClick(self.btn_stage, self.OnStage)
	self:RemoveClick(self.btn_autofight, self.OnAutoFight)
	self:RemoveClick(self.btn_clearlocal, self.OnClearLocalAnim)
end

function mt:OnReqData()
	Infogvg.net:RequestGvg()
end

function mt:OnUnLock()
	Infogvg.stage.curStep = 3

	for i, stage in Infogvg.stage:Filter():Ipairs() do
		for i, monster in ipairs(stage.monsters) do
			monster:SetHp(nil)
		end
	end

	Event.Instance:Fire("EVENT_GVG_REFRESH")
end

function mt:OnGod()
	if Infogvg.god then
		Infogvg.god = nil

		Infogvg:Log("god off!")
	else
		Infogvg.god = true

		Infogvg:Log("god on!")
	end

	local txt = self:GetChildComponent("btns_cmd/btn_god/txt", "Text")

	txt.text = "最速クリア\n" .. tostring(Infogvg.god)
end

function mt:OnOver()
	require("UI/Page/PageGvg/DlgGvgOver")

	local data = {}
	local stage = Infogvg.stage:Get()

	stage = stage or Infogvg.stage.stages[1]
	data.infoStage = InfoStage(stage.stageId)
	data.setter = nil

	local ui = DlgGvgOver()

	function ui.Reward()
		return
	end

	function ui.OnBtnClose()
		ui:Close()
	end

	UIMgr.AddPanel(ui, data, self.UIRootObject)
end

function mt:OnStage()
	local s = Infogvg.stage

	local function _logFun()
		local str = " ------ stages ------- "

		str = str .. " curStep:" .. s.curStep
		str = str .. " activeId:" .. s.activeId
		str = str .. " phaseTimes:" .. s.phaseTimes
		str = str .. " score:" .. s.score
		str = str .. " contribution:" .. s.contribution
		str = str .. " awardStatus:" .. Infogvg:JsonStr(s.awardStatus)

		Infogvg:Log(str)

		for i, stage in ipairs(s.stages) do
			Infogvg:Log(stage:str())

			local hpstr = ""

			for j, monster in ipairs(stage.monsters) do
				local cur, max = monster.hp, monster.maxhp

				if cur ~= 0 and cur ~= max then
					hpstr = hpstr .. "[" .. monster.monsterIdx .. "]<color=red>" .. cur .. "/" .. max .. "</color> "
				else
					hpstr = hpstr .. "[" .. monster.monsterIdx .. "]" .. cur .. "/" .. max .. " "
				end
			end

			Infogvg:Log(hpstr)
		end
	end

	_logFun()
end

function mt:OnAutoFight()
	Infogvg.cmd:AutoFight()
end

function mt:OnClearLocalAnim()
	PersistentStoreUtil.SetInt("KEY_GVG_ID", 0)
	PersistentStoreUtil.SetInt("KEY_GVG_STEP", 1)
	PersistentStoreUtil.SetInt("KEY_GVG_RESETTIMES", 0)
	PersistentStoreUtil.SetList("KEY_GVG_PORTAL_RESETTIMES", {})
	PersistentStoreUtil.SetList("KEY_GVG_PORTAL_DEAD", {})
end

return mt
