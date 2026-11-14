-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/ResourceMgr.lua

ResourceMgr = {}

local BlockHandles = {}
local CacheBlocks = {}

local function OnProgress(blockHandle, progress)
	CacheBlocks[blockHandle].Progress = progress

	LoadingMgr.SetProgress(progress)
end

local function OnFinish(blockHandle)
	local handObj = CacheBlocks[blockHandle]

	if handObj ~= nil then
		handObj.OnFinish(handObj.Params)

		CacheBlocks[blockHandle] = nil
	end
end

local function OnLoaded(blockHandle, resHandle, loadedObject)
	local assigner = CacheBlocks[blockHandle][resHandle]

	assigner._Object[assigner._Field] = loadedObject
end

function ResourceMgr.LoadSync(path, type)
	if type ~= nil then
		return ResourceManager.LoadSync(path, typeof(type))
	else
		return ResourceManager.LoadSync(path, typeof(GameObject))
	end
end

function ResourceMgr.BeginSubmit(callback, param)
	local blockHandle = ResourceManager.Begin(OnFinish, OnProgress)

	table.insert(BlockHandles, blockHandle)

	CacheBlocks[blockHandle] = {
		OnFinish = callback,
		Params = param
	}

	return blockHandle
end

function ResourceMgr.EndSubmit()
	local blockTag = BlockHandles[#BlockHandles]

	table.remove(BlockHandles)
	ResourceManager.End()
end

function ResourceMgr.Cancel(id)
	ResourceManager.Cancel(id)

	local handObj = CacheBlocks[id]

	if handObj ~= nil then
		CacheBlocks[id] = nil
	end
end

function ResourceMgr.SubmitCache(path, table, field, type)
	local resHandle

	if type ~= nil then
		resHandle = ResourceManager.Request(path, typeof(type), OnLoaded)
	else
		resHandle = ResourceManager.Request(path, typeof(GameObject), OnLoaded)
	end

	CacheBlocks[BlockHandles[#BlockHandles]][resHandle] = {
		_Object = table,
		_Field = field
	}

	return resHandle
end

function ResourceMgr.Unload(asset)
	if asset ~= nil then
		ResourceManager.Unload(asset)
	end
end

function ResourceMgr.UnloadAll()
	ResourceManager.UnloadAll()
end

function ResourceMgr.SetMaxCoroutine(n)
	ResourceManager.SetMaxCoroutine(n)
end
