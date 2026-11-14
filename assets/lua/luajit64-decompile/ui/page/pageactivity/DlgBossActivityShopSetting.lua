-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/DlgBossActivityShopSetting.lua

DlgBossActivityShopSetting = class("DlgBossActivityShopSetting", UIPanel)

function DlgBossActivityShopSetting:ctor()
	self.UIPrefabPath = "UI/PanelActivity/DlgBossActivityShopSetting"
end

function DlgBossActivityShopSetting:PreLoad()
	return
end

function DlgBossActivityShopSetting:Purge()
	DlgBossActivityShopSetting.base.Purge(self)
	self:OnLeave()
end

function DlgBossActivityShopSetting:OnLeave()
	return
end

function DlgBossActivityShopSetting:OnRegisterEvent()
	self:AddClick(self.CloseBtn, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
	self:AddClick(self.Cancel, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
	self:AddClick(self.OK, self.OnClickedBtnEnter)

	for i = 1, 3 do
		self:AddClick(self.countTab["tab" .. i], self.OnClickCountTab)
	end
end

function DlgBossActivityShopSetting:OnUnRegisterEvent()
	self:RemoveClick(self.CloseBtn, self.OnClickedBtnClose)
	self:RemoveClick(self.Cancel, self.OnClickedBtnClose)
	self:RemoveClick(self.OK, self.OnClickedBtnEnter)

	for i = 1, 3 do
		self:RemoveClick(self.countTab["tab" .. i], self.OnClickCountTab)
	end
end

function DlgBossActivityShopSetting:OnEnter(vParam)
	self:DealWithLocalization()

	self.countTab = {}
	self.tabCountConfig = {
		10,
		50,
		100
	}
	self.selectIndex = PersistentStoreUtil.GetInt(PersistentStoreUtil.KEY_ACTIVITY_POOL_COUNT_SETTING)

	for i = 1, 3 do
		self.countTab["tab" .. i] = self:GetChildGameObject("Main/Count/" .. i)
		self.countTab["count" .. i] = self:GetChildComponent("Main/Count/" .. i .. "/Num", "Text")
		self.countTab["count" .. i].fontSize = 38
		self.countTab["count" .. i].text = self.tabCountConfig[i]
		self.countTab["select" .. i] = self:GetChildGameObject("Main/Count/" .. i .. "/Select")
	end

	SetActiveFunc(self.countTab["select" .. self.selectIndex], true)

	self.CloseBtn = self:GetChildGameObject("Main/ButtonExit")
	self.Cancel = self:GetChildGameObject("Main/Cancel")
	self.OK = self:GetChildGameObject("Main/OK")
end

function DlgBossActivityShopSetting:DealWithLocalization()
	local text

	for i = 1, 3 do
		text = self:GetChildComponent("Main/Count/" .. i .. "/Text1", "Text")
		text.text = _("Desc_ActivityDraw")
		text = self:GetChildComponent("Main/Count/" .. i .. "/Text2", "Text")
		text.text = _("Desc_ActivityCount")
	end

	text = self:GetChildComponent("Main/bg_title/Text", "Text")
	text.text = _("eReturn_setting")
	text = self:GetChildComponent("Main/OK/Text", "Text")
	text.text = _("Activity_OK")
	text = self:GetChildComponent("Main/Cancel/Text", "Text")
	text.text = _("Activity_Cancel")
	text = self:GetChildComponent("Main/Tip", "Text")
	text.text = _("Activity_CountSettingTip")
end

function DlgBossActivityShopSetting:OnClickCountTab(data)
	local go = data.pointerPressRaycast.gameObject
	local index = tonumber(go.name)

	for i = 1, 3 do
		SetActiveFunc(self.countTab["select" .. i], i == index)

		self.selectIndex = index
	end
end

function DlgBossActivityShopSetting:OnClickedBtnClose()
	self:Close()
end

function DlgBossActivityShopSetting:OnClickedBtnEnter()
	PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_ACTIVITY_POOL_COUNT_SETTING, self.selectIndex)
	Event.Instance:Fire("UpdateCountSetting")
	self:Close()
end
