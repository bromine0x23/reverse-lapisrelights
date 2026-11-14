-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/DlgAttrDetail.lua

DlgAttrDetail = class("DlgAttrDetail", UIPanel)

function DlgAttrDetail:ctor()
	self.UIPrefabPath = "UI/PanelRole/DlgAttrDetail"
	self.close_Cb = nil
	self.enter_Cb = nil
end

function DlgAttrDetail:Purge()
	self.base.Purge(self)

	self.close_Cb = nil
	self.enter_Cb = nil
end

function DlgAttrDetail:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.OnClickedBtnClose, PATH_SFX_UI_CANCEL)
end

function DlgAttrDetail:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgAttrDetail:OnEnter(vParam)
	self:DealWithLocalization()

	self.BtnClose = self:GetChildGameObject("Panel/Button")

	local goPanel = self:GetChildGameObject("Panel")

	GOUtil.SetTransformLocalScale(goPanel, 0)

	if not vParam then
		return
	end

	local infoRole = vParam.infoRole
	local infoRoleCard = vParam.infoRoleCard

	self.close_Cb = vParam.cb
	self.enter_Cb = vParam.panelCb

	if self.enter_Cb then
		self.enter_Cb()

		self.enter_Cb = nil
	end

	local scrollArea = self:GetChildGameObject("Panel/Attr/ScrollArea")

	GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	local content = self:GetChildGameObject("Panel/Attr/ScrollArea/Content")
	local att = self:GetChildGameObject("Panel/Attr/Att")

	att:SetActive(true)

	local function GetNumValue(key, value)
		if GetAttValueType(key) == eValueType.Abs then
			return math.floor(value + 0.5)
		else
			return value
		end
	end

	local function GetFomatValue(key, value)
		if GetAttValueType(key) == eValueType.Abs then
			return value
		else
			local v = string.format("%.1f", value * 100)

			if string.sub(v, #v - 1, -1) == ".0" then
				v = string.sub(v, 1, -3)
			end

			return v .. "%"
		end
	end

	local attr = infoRole:UpdateAttWithCard(infoRoleCard)
	local sum, attV

	for k, v in pairs(ATTRIBUTE_NAME) do
		sum = 0
		attV = 0

		local go = GOUtil.Instantiate(att, content)
		local txt = GOUtil.FindChildComponent(go, "Image/Text", "Text")

		txt.text = _("eAttType_" .. k)
		txt = GOUtil.FindChildComponent(go, "Text1", "Text")
		txt.text = GetFomatValue(v, attr:Get(v))
		txt = GOUtil.FindChildComponent(go, "Text2", "Text")
		attV = GetNumValue(v, infoRole.baseAtt:Get(v))
		txt.text = "+" .. GetFomatValue(v, attV)
		sum = sum + attV
		txt = GOUtil.FindChildComponent(go, "Text3", "Text")
		attV = GetNumValue(v, infoRoleCard:GetAtt(v))
		txt.text = "+" .. GetFomatValue(v, attV)
		sum = sum + attV
		txt = GOUtil.FindChildComponent(go, "Text4", "Text")
		attV = GetNumValue(v, infoRole.equipBaseAtt:Get(v))
		txt.text = "+" .. GetFomatValue(v, attV)
		sum = sum + attV

		local attrEnchant = AttributeOwner()

		attrEnchant:SetBase(v, infoRole.equipBaseAtt:Get(v))
		attrEnchant:ModMul(v, infoRole.equipEnchantAtt:GetExtraMul(v))
		attrEnchant:ModAdd(v, infoRole.equipEnchantAtt:GetExtraAdd(v))

		attV = GetNumValue(v, attrEnchant.attcomponent:CalculateLevelGain(v, 1))
		txt = GOUtil.FindChildComponent(go, "Text5", "Text")
		txt.text = "+" .. GetFomatValue(v, attV)
		sum = sum + attV
		txt = GOUtil.FindChildComponent(go, "Text6", "Text")
		txt.text = "+" .. GetFomatValue(v, attr:Get(v) - sum)

		local col1, col2 = Color.New(0.9333333333333333, 0.9333333333333333, 0.9333333333333333, 1), Color.New(0.7058823529411765, 0.7058823529411765, 0.7058823529411765, 1)

		if k % 2 == 0 then
			col1 = Color.New(0.9019607843137255, 0.9647058823529412, 0.9647058823529412, 1)
			col2 = Color.New(0.39215686274509803, 0.7176470588235294, 0.7725490196078432, 1)
		end

		local img = GOUtil.GetComponent(go, "Image")

		img.color = col1
		img = GOUtil.FindChildComponent(go, "Image", "Image")
		img.color = col2
	end

	att:SetActive(false)
end

function DlgAttrDetail:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/Title/Text", "Text")
	Text.text = _("DlgAttrDetail_Preparation")
	Text = self:GetChildComponent("Panel/Attr/Image/Text1", "Text")
	Text.text = _("Desc_TotalAttr")
	Text = self:GetChildComponent("Panel/Attr/Image/Text2", "Text")
	Text.text = _("Mail_From_Idol")
	Text = self:GetChildComponent("Panel/Attr/Image/Text3", "Text")
	Text.text = _("Desc_WorldMap_4")
	Text = self:GetChildComponent("Panel/Attr/Image/Text4", "Text")
	Text.text = _("Item_From_11_1")
	Text = self:GetChildComponent("Panel/Attr/Image/Text5", "Text")
	Text.text = Lang(490023)
	Text = self:GetChildComponent("Panel/Attr/Image/Text6", "Text")
	Text.text = _("Desc_OtherAttr")
end

function DlgAttrDetail:OnClickedBtnClose()
	if self.close_Cb then
		self.close_Cb()

		self.close_Cb = nil
	end

	self:Close()
end

function DlgAttrDetail:OnBackAndroid()
	self:OnClickedBtnClose()
end
