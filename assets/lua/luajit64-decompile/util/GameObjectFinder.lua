-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/GameObjectFinder.lua

GameObjectFinder = class("GameObjectFinder")

function GameObjectFinder:GetRootGameObject()
	if not self.UIRootObject then
		return self:OnGetRootGameObject()
	end

	return self.UIRootObject
end

function GameObjectFinder:OnGetRootGameObject()
	error("U shoul implement OnGetRootObj function")
end

function GameObjectFinder:SetRootGameObject(vRootGameObject)
	self.UIRootObject = vRootGameObject
	self.AbsolutePath = GOUtil.GetGameObjectPath(vRootGameObject)
end

function GameObjectFinder:FreeRootGameObject()
	self.UIRootObject = nil
	self.AbsolutePath = nil
end

function GameObjectFinder:FindGameObjectInChild(vGameObjectName)
	return GOUtil.FindGameObjectInChild(self:GetRootGameObject(), vGameObjectName)
end

function GameObjectFinder:FindComponentInChild(vGameObjectName, vComponentTypeName)
	return GOUtil.FindComponentInChild(self:GetRootGameObject(), vGameObjectName, vComponentTypeName)
end

function GameObjectFinder:GetChildGameObject(internal_path)
	if self.UIRootObject == nil or string.isNullOrEmpty(internal_path) then
		return nil
	end

	return GOUtil.FindChildGameObject(self.UIRootObject, internal_path)
end

function GameObjectFinder:GetChildComponent(internal_path, com_name)
	if self.UIRootObject == nil or string.isNullOrEmpty(internal_path) or string.isNullOrEmpty(com_name) then
		return nil
	end

	return GOUtil.FindChildComponent(self.UIRootObject, internal_path, com_name)
end

function GameObjectFinder:GetComponent(parent, com_name)
	if parent == nil or string.isNullOrEmpty(com_name) then
		return nil
	end

	return GOUtil.GetComponent(parent, com_name)
end
