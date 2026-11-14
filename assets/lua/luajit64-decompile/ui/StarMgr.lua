-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/StarMgr.lua

StarMgr = class("StarMgr")

function StarMgr:ctor(starPrefab, parent, maxNum)
	self.Parent = parent
	self.StarPrefab = starPrefab
	self.MaxNum = maxNum

	if starPrefab == nil then
		error("StarMgr starPrefab is nil!")
	end

	self:GenStarContainer()
end

function StarMgr:GenStarContainer()
	self.CacheStarInfoContainer = Container()

	if self.StarPrefab == nil then
		return
	end

	for i = 1, self.MaxNum do
		local starGo = GOUtil.InstantiatePrefab(self.StarPrefab, self.Parent)
		local ctrlGo

		if starGo ~= nil then
			if starGo.transform.childCount > 0 then
				ctrlGo = starGo.transform:GetChild(0).gameObject
			end

			self.CacheStarInfoContainer:Push({
				Root = starGo,
				CtrlGo = ctrlGo
			})
		end
	end
end

function StarMgr:Show(showNum)
	for i, v in self.CacheStarInfoContainer:Enumerator() do
		if v ~= nil and v.Root ~= nil and v.CtrlGo ~= nil then
			UIUtility.SetVisible(v.CtrlGo, i <= showNum)
		end
	end
end

function StarMgr:Destroy()
	for i, v in self.CacheStarInfoContainer:Enumerator() do
		if v ~= nil and not IsNil(v.Root) then
			Object.Destroy(v.Root)
		end
	end

	self.CacheStarInfoContainer = nil
	self.Parent = nil
	self.StarPrefab = nil
	self.MaxNum = nil
end
