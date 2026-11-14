-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/UIItemGetCharInfo.lua

require("UI/Item/UIItemBase")

UIItemGetCharInfo = class("UIItemGetCharInfo", UIItemBase)

function UIItemGetCharInfo:ctor(itemPrefabCache, parent, ownerUI)
	self.OnClick = nil
end

function UIItemGetCharInfo:OnEnter(vParam)
	self.Img_Deca = GOUtil.FindChildComponent(self.UIRootObject, "Img_Deca", "Image")
	self.Img_Icon = GOUtil.FindChildComponent(self.UIRootObject, "Img_Icon", "Image")
	self.RootTrans = GOUtil.GetComponent(self.UIRootObject, "Transform")
	self.Txt_Name = GOUtil.FindChildComponent(self.UIRootObject, "Txt_Name", "Text")
	self.Txt_Pro = GOUtil.FindChildComponent(self.UIRootObject, "Txt_Pro", "Text")
	self.Txt_Intro = GOUtil.FindChildComponent(self.UIRootObject, "Txt_Intro", "Text")
	self.Img_Tips1 = GOUtil.FindChildGameObject(self.UIRootObject, "Img_Tips1")
	self.Img_Tips2 = GOUtil.FindChildGameObject(self.UIRootObject, "Img_Tips2")
	self.Img_Tips3 = GOUtil.FindChildGameObject(self.UIRootObject, "Img_Tips3")
	self.Tip1Text = GOUtil.FindChildComponent(self.UIRootObject, "Img_Tips1/Text", "Text")
	self.Tip2Text = GOUtil.FindChildComponent(self.UIRootObject, "Img_Tips2/Text", "Text")
	self.Tip3Text = GOUtil.FindChildComponent(self.UIRootObject, "Img_Tips3/Text", "Text")
	self.Img_Attri = GOUtil.FindChildComponent(self.UIRootObject, "Img_Attri", "Image")
	self.Img_Pro = GOUtil.FindChildComponent(self.UIRootObject, "Txt_Pro/Img_Pro", "Image")
	self.Img_Team = GOUtil.FindChildComponent(self.UIRootObject, "Img_Team", "Image")

	for i = 1, 3 do
		UIUtility.SetVisible(self["Img_Tips" .. i], false)
	end
end

function UIItemGetCharInfo:OnLeave()
	self.Img_Deca = nil
	self.Img_Icon = nil
	self.RootTrans = nil
	self.Txt_Name = nil
	self.Txt_Pro = nil
	self.Txt_Intro = nil
	self.Img_Tips1 = nil
	self.Img_Tips2 = nil
	self.Img_Tips3 = nil
	self.Tip1Text = nil
	self.Tip2Text = nil
	self.Tip3Text = nil
	self.Img_Attri = nil
	self.Img_Pro = nil
	self.Img_Team = nil
end

function UIItemGetCharInfo:OnRegisterEvent()
	return
end

function UIItemGetCharInfo:OnUnRegisterEvent()
	return
end

function UIItemGetCharInfo:SetItem(charID, reasonTipsTbl)
	UIUtility.SetSprite(self.Img_Deca, self:GetDecoImg(self.Index), false)

	local infoChar = CharacterMgr:GetCharacter(charID)

	UIUtility.SetSprite(self.Img_Icon, PATH_CHAR_HEAD .. infoChar:GetCharacterHeadIcon(), false)
	UIUtility.SetText(self.Txt_Name, infoChar.data.Name:ToLanguage())
	UIUtility.SetText(self.Txt_Pro, GetJobName(infoChar.data.Job))
	UIUtility.SetText(self.Txt_Intro, infoChar.infoData.Intro:ToLanguage())
	UIUtility.SetSprite(self.Img_Team, GetTeamIcon(infoChar.data.TeamID:get_Item(0), false), false)

	if reasonTipsTbl ~= nil then
		local tipCount = Mathf.Min(#reasonTipsTbl, 3)

		for i = 1, tipCount do
			UIUtility.SetVisible(self["Img_Tips" .. i], true)
			UIUtility.SetText(self["Tip" .. i .. "Text"], reasonTipsTbl[i])
		end
	end

	UIUtility.SetSprite(self.Img_Attri, "UIDyAtlas/Mist/" .. infoChar.data.AttributeChart, false)
	UIUtility.SetSprite(self.Img_Pro, GetJobIcon(infoChar.data.Job, true), false)
end

function UIItemGetCharInfo:SetPos(pos)
	UIUtility.SetTransLocalPos(self.RootTrans, pos)
end

function UIItemGetCharInfo:GetDecoImg(idx)
	return "UIDyAtlas/Mist/ui_bg_pact_0" .. 2 + idx
end
