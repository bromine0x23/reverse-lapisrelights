-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/UIItemQuestionOption.lua

require("UI/Item/UIItemBase")

UIItemQuestionOption = class("UIItemQuestionOption", UIItemBase)

function UIItemQuestionOption:ctor(itemPrefabCache, parent, ownerUI)
	self.OnClick = nil
end

function UIItemQuestionOption:OnEnter(vParam)
	self.Text = GOUtil.FindChildComponent(self.UIRootObject, "Img_Bk/Text", "Text")
	self.Img_Bk = GOUtil.FindChildComponent(self.UIRootObject, "Img_Bk", "RectTransform")
	self.Img_BkImg = GOUtil.FindChildComponent(self.UIRootObject, "Img_Bk", "Image")
	self.RootRT = GOUtil.GetComponent(self.UIRootObject, "RectTransform")
	self.Img_SpriteAnim = GOUtil.FindChildComponent(self.UIRootObject, "Eff_UI_Cloud", "Animator")
	self.CloudAnimLength = MxUtil.GetAnimatorAnimTime(self.Img_SpriteAnim, 0, "E_UI_Cloud")

	UIUtility.SetComponentVisible(self.Img_SpriteAnim, false)
	self:PlaySwimAnim()
end

function UIItemQuestionOption:OnLeave()
	self.Text = nil
	self.Img_Bk = nil
	self.RootRT = nil
	self.Img_BkImg = nil
end

function UIItemQuestionOption:OnRegisterEvent()
	self:AutoRegistClick(self.Img_Bk.gameObject, self.OnClickItem)
end

function UIItemQuestionOption:OnUnRegisterEvent()
	return
end

function UIItemQuestionOption:SetItem(strText)
	UIUtility.SetText(self.Text, strText)
end

function UIItemQuestionOption:SetPos(pos)
	UIUtility.SetRTPos(self.RootRT, pos)
end

function UIItemQuestionOption:SetScale(scale)
	UIUtility.SetTransScale(self.Img_Bk, scale)
	UIUtility.SetTransScale(self.Text.transform, scale)
end

function UIItemQuestionOption:PlaySwimAnim()
	local duration = Mathf.Random(4, 10) * 0.1
	local yOffset = Mathf.Random(10, 20)
	local tween = DG.Tweening.ShortcutExtensions.DOLocalMoveY(self.Img_Bk, yOffset, duration, false)

	UIUtility.SetLoop(tween, -1)
end

function UIItemQuestionOption:OnClickItem()
	if self.OnClick ~= nil then
		self.OnClick(self.Index)
	end
end

function UIItemQuestionOption:FadeOut(duration, callback)
	DG.Tweening.ShortcutExtensions46.DOFade(self.Text, 0, duration)

	local tweener = DG.Tweening.ShortcutExtensions46.DOFade(self.Img_BkImg, 0, duration)

	UIUtility.SetTweenerCallback(tweener, function()
		UIUtility.SetGraphicAlpha(self.Text, 1)
		UIUtility.SetGraphicAlpha(self.Img_BkImg, 1)

		if callback ~= nil then
			callback()
		end
	end)
end

function UIItemQuestionOption:SetItemIn(duration, callback)
	local initScale = 0
	local maxScale = 1.2
	local rootTrans = self.UIRootObject.transform

	UIUtility.SetComponentVisible(self.Img_Bk, true)
	UIUtility.SetTransScale(rootTrans, Vector3.New(initScale, initScale, initScale))

	local tweener = DG.Tweening.ShortcutExtensions.DOScale(rootTrans, maxScale, duration * 0.5)

	UIUtility.SetTweenerCallback(tweener, function()
		tweener = DG.Tweening.ShortcutExtensions.DOScale(rootTrans, 1, duration * 0.5)

		UIUtility.SetTweenerCallback(tweener, callback)
	end)
end

function UIItemQuestionOption:PlayCloudAnim(animCompleteCB)
	UIUtility.SetComponentVisible(self.Img_Bk, false)
	UIUtility.SetComponentVisible(self.Img_SpriteAnim, true)
	self.Img_SpriteAnim:Play("E_UI_Cloud", 0, 0)
	MxCoroutineHelper.StartCoroutine(self.CloudAnimLength, self.Mono, function()
		UIUtility.SetComponentVisible(self.Img_SpriteAnim, false)

		if animCompleteCB ~= nil then
			animCompleteCB()
		end
	end)
end
