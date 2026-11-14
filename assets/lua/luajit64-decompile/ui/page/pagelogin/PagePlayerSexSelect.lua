-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PagePlayerSexSelect.lua

PagePlayerSexSelect = class("PagePlayerSexSelect", PageBase)

function PagePlayerSexSelect:ctor(playerCreate)
	self.PlayerCreate = playerCreate
end

function PagePlayerSexSelect:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageLogin/PagePlayerSexSelect")
end

function PagePlayerSexSelect:OnPageLoaded()
	return
end

function PagePlayerSexSelect:OnEnter()
	local img_Male = self:GetChildComponent("Img_Male", "Transform")
	local img_Woman = self:GetChildComponent("Img_Woman", "Transform")
	local Img_Skin1 = self:GetChildComponent("Img_Skin1", "Transform")
	local Img_Skin2 = self:GetChildComponent("Img_Skin2", "Transform")

	self:PlaySwimAnim(img_Male)
	self:PlaySwimAnim(img_Woman)
	self:PlaySwimAnim(Img_Skin1)
	self:PlaySwimAnim(Img_Skin2)

	self.Btn_Male = self:GetChildComponent("Img_Male", "Button")
	self.Btn_Woman = self:GetChildComponent("Img_Woman", "Button")
	self.Img_Skin1 = self:GetChildComponent("Img_Skin1", "Button")
	self.Img_Skin2 = self:GetChildComponent("Img_Skin2", "Button")
	self.Text_NameLeft = self:GetChildComponent("Img_QuestionBk/Image_BgNameLeft/Text_NameLeft", "Text")

	UIUtility.SetText(self.Text_NameLeft, Localization.Get("DESC_WANG_ASSISTANT"))

	self.txt_QuestionDesc = self:GetChildComponent("Img_QuestionBk/Txt_QuestionDesc", "Text")

	UIUtility.SetText(self.txt_QuestionDesc, Localization.Get("DESC_PleaseSelectYourSex"))
end

function PagePlayerSexSelect:OnLeave()
	self.Btn_Male = nil
	self.Btn_Woman = nil
	self.Text_NameLeft = nil
end

function PagePlayerSexSelect:OnRegisterEvent()
	self:AutoRegistClick(self.Btn_Male.gameObject, self.OnClickedMaleBtn)
	self:AutoRegistClick(self.Btn_Woman.gameObject, self.OnClickedWomanBtn)
	self:AutoRegistClick(self.Img_Skin1.gameObject, self.OnClickedSkin1Btn)
	self:AutoRegistClick(self.Img_Skin2.gameObject, self.OnClickedSkin2Btn)
end

function PagePlayerSexSelect:OnUnRegisterEvent()
	return
end

function PagePlayerSexSelect:PlaySwimAnim(doTweenTrans)
	if doTweenTrans == nil then
		return
	end

	local duration = Mathf.Random(4, 10) * 0.1
	local yOffset = Mathf.Random(10, 20)
	local endYValue = yOffset + doTweenTrans.localPosition.y
	local tween = DG.Tweening.ShortcutExtensions.DOLocalMoveY(doTweenTrans, endYValue, duration, false)

	UIUtility.SetLoop(tween, -1)
end

function PagePlayerSexSelect:OnClickedSkin1Btn(...)
	self.PlayerCreate.initSkin = 1
	PlayerInst.InfoPlayer.initSkin = 1

	self:Close()
	InstructionMgr:UploadAnalysis(-2)
end

function PagePlayerSexSelect:OnClickedSkin2Btn(...)
	self.PlayerCreate.initSkin = 2
	PlayerInst.InfoPlayer.initSkin = 2

	self:Close()
	InstructionMgr:UploadAnalysis(-2)
end

function PagePlayerSexSelect:OnClickedMaleBtn()
	self.PlayerCreate.PlayerSex = Gender.Man

	self:OnClickedSkin1Btn()
end

function PagePlayerSexSelect:OnClickedWomanBtn()
	self.PlayerCreate.PlayerSex = Gender.Woman

	self:OnClickedSkin1Btn()
end

function PagePlayerSexSelect:ShowSelectSkin()
	self.Btn_Male.gameObject:SetActive(false)
	self.Btn_Woman.gameObject:SetActive(false)
	self.Img_Skin2.gameObject:SetActive(true)
	self.Img_Skin1.gameObject:SetActive(true)
	UIUtility.SetText(self.txt_QuestionDesc, Localization.Get("DESC_PleaseSelectYourSkin"))
end
