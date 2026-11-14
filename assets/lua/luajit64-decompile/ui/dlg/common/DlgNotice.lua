-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgNotice.lua

DlgNotice = class("DlgNotice", DlgBase)

function DlgNotice:Init()
	return
end

function DlgNotice:ctor()
	return
end

function DlgNotice:Cache()
	self:SubmitUIPrefabCacheLua("UI/Common/PanelNotice")
end

function DlgNotice:Purge()
	DlgNotice.base.Purge(self)

	self.TweenRoot = nil
	self.Button_Mask = nil
	self.PanelBg = nil
	self.ImgBg = nil
end

function DlgNotice:OnEnter(vParam)
	self.cb = vParam.cb
	self.TweenRoot = self:FindGameObjectInChild("TweenRoot")
	self.Button_Mask = self:GetChildGameObject("Button_Mask")
	self.PanelBg = self:GetChildGameObject("TweenRoot/PanelBg")
	self.ImgBg = self:GetChildComponent("TweenRoot/PanelBg", "Image")
	self.btn_notTip = self:GetChildGameObject("GameObject/btn_notTip")
	self.rightTip = self:GetChildGameObject("GameObject/btn_notTip/right")

	self.rightTip:SetActive(not PersistentStoreUtil.GetIsNoticeAd())

	self.scrollviewObj = self:GetChildGameObject("TweenRoot/PanelBg/scrollview")
	self.ScrollView = GOUtil.AddMissingComponent(self.scrollviewObj, "UIScrollView")
	self.ScrollView.vertical = true
	self.ScrollView.content = self:GetChildComponent("TweenRoot/PanelBg/scrollview/content", "Transform")
	self.TextTitle = self:GetChildComponent("TweenRoot/PanelBg/Text1", "Text")
	self.Text = self:GetChildComponent("TweenRoot/PanelBg/scrollview/content/Text", "Text")
	self.TextTitle.text = vParam.title
	self.Text.text = string.gsub(vParam.text, "\\n", "\n")
end

function DlgNotice:OnLeave()
	self.TweenRoot = nil
	self.Button_Mask = nil
	self.PanelBg = nil
	self.ImgBg = nil
end

function DlgNotice:Close(tParam)
	DlgNotice.base.Close(self, tParam)
	ClearDlgMemory(DlgNotice.Instance)

	DlgNotice.Instance = nil

	if self.cb ~= nil then
		self.cb()

		self.cb = nil
	end
end

function DlgNotice:OnRegisterEvent()
	self:AutoRegistClick(self.Button_Mask.gameObject, self.OnClickedBtn)
	self:AutoRegistClick(self.PanelBg.gameObject, self.OnClickedBtn)
	self:AutoRegistClick(self.btn_notTip, self.OnClickedIsOrNotNotice)
end

function DlgNotice:OnUnRegisterEvent()
	return
end

function DlgNotice:OnClickedIsOrNotNotice()
	local status = self.rightTip.activeSelf

	self.rightTip:SetActive(not status)
	PersistentStoreUtil.SetIsNoticeAd(status)
end

function DlgNotice:OnClickedBtn()
	self:Close()

	local IsLastDaySign = InfoGameInst.gameInfo.sevenMarkTime == 0 or TimeIsNotToday(InfoGameInst.gameInfo.sevenMarkTime)

	if FirstSevenDay and IsLastDaySign and InfoGameInst.gameInfo.sevenMark < 7 then
		FirstSevenDay = false

		CreateDlgInPage(DlgLoginSeven.GetInstance(), nil)
	end
end

function DlgNotice.GetInstance()
	DlgNotice.Instance = DlgNotice.Instance or DlgNotice()

	return DlgNotice.Instance
end
